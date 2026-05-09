"""
CaMeL Defense Coordinator

Top-level façade that ties together the taint tracker, capability
manager, input sanitizer, policy engine, and dual-LLM orchestrator
into a single, easy-to-use defense layer for agent applications.

Usage::

    defense = CamelDefense()
    defense.grant_capability(Capability.FILE_READ)

    # Before executing any tool, pass the action through the defense:
    result = defense.evaluate_action(
        action_name="read_file",
        capability=Capability.FILE_READ,
        resource="/tmp/data.txt",
        inputs={"content": tool_output},
        input_taint=TaintLabel.TOOL_OUTPUT,
    )

    if result.decision == PolicyDecision.ALLOW:
        execute_tool(...)
    elif result.decision == PolicyDecision.QUARANTINE:
        request_human_review(...)
    else:
        block_action(...)
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any

from prompt_injection_prevention.capability_manager import (
    Capability,
    CapabilityDecision,
    CapabilityManager,
)
from prompt_injection_prevention.dual_llm import (
    DualLLMOrchestrator,
    LLMCallable,
)
from prompt_injection_prevention.input_sanitizer import (
    InputSanitizer,
    SanitizationResult,
)
from prompt_injection_prevention.policy_engine import (
    Action,
    PolicyDecision,
    PolicyEngine,
    PolicyEvaluation,
)
from prompt_injection_prevention.taint_tracker import (
    TaintLabel,
    TaintTracker,
    TaintedData,
)


@dataclass
class DefenseResult:
    """Aggregated result from the full defense pipeline."""

    decision: PolicyDecision
    action_name: str
    capability_check: CapabilityDecision
    sanitization: SanitizationResult
    policy_evaluation: PolicyEvaluation
    tainted_inputs: list[TaintedData] = field(default_factory=list)
    reason: str = ""

    @property
    def is_allowed(self) -> bool:
        return self.decision == PolicyDecision.ALLOW

    @property
    def needs_review(self) -> bool:
        return self.decision == PolicyDecision.QUARANTINE

    @property
    def is_denied(self) -> bool:
        return self.decision == PolicyDecision.DENY


class CamelDefense:
    """One-stop defense layer for LLM-based agents.

    Composes the following sub-systems:

    * :class:`TaintTracker` – provenance tracking
    * :class:`CapabilityManager` – least-privilege access control
    * :class:`InputSanitizer` – injection pattern detection
    * :class:`PolicyEngine` – rule-based decision making
    * :class:`DualLLMOrchestrator` – separated LLM contexts (optional)
    """

    def __init__(
        self,
        *,
        taint_tracker: TaintTracker | None = None,
        capability_manager: CapabilityManager | None = None,
        input_sanitizer: InputSanitizer | None = None,
        policy_engine: PolicyEngine | None = None,
        privileged_llm: LLMCallable | None = None,
        quarantined_llm: LLMCallable | None = None,
        system_prompt: str = "",
        install_default_rules: bool = True,
    ) -> None:
        self.tracker = taint_tracker or TaintTracker()
        self.capabilities = capability_manager or CapabilityManager()
        self.sanitizer = input_sanitizer or InputSanitizer()
        self.policy = policy_engine or PolicyEngine()

        if install_default_rules:
            self.policy.add_default_rules()

        self.orchestrator: DualLLMOrchestrator | None = None
        if privileged_llm is not None:
            self.orchestrator = DualLLMOrchestrator(
                privileged_llm=privileged_llm,
                quarantined_llm=quarantined_llm,
                taint_tracker=self.tracker,
                system_prompt=system_prompt,
            )

    # ------------------------------------------------------------------
    # Capability shortcuts
    # ------------------------------------------------------------------

    def grant_capability(
        self,
        capability: Capability,
        *,
        resource_pattern: str = "*",
        reason: str = "",
    ) -> None:
        self.capabilities.grant(
            capability,
            resource_pattern=resource_pattern,
            reason=reason,
        )

    def revoke_capability(
        self,
        capability: Capability,
        resource_pattern: str = "*",
    ) -> int:
        return self.capabilities.revoke(capability, resource_pattern)

    # ------------------------------------------------------------------
    # Core evaluation pipeline
    # ------------------------------------------------------------------

    def evaluate_action(
        self,
        *,
        action_name: str,
        capability: Capability,
        resource: str = "",
        inputs: dict[str, Any] | None = None,
        input_taint: TaintLabel = TaintLabel.NONE,
    ) -> DefenseResult:
        """Run the full CaMeL-inspired defense pipeline.

        Steps:
        1. Check that the required capability is held.
        2. Scan all string inputs for injection patterns.
        3. Register inputs with the taint tracker.
        4. Evaluate the action against the policy engine.
        5. Return an aggregated ``DefenseResult``.
        """
        inputs = inputs or {}

        # 1. Capability check
        cap_decision = self.capabilities.check(capability, resource)
        if not cap_decision.allowed:
            empty_scan = SanitizationResult(original_text="")
            empty_eval = PolicyEvaluation(
                decision=PolicyDecision.DENY,
                action=Action(name=action_name, capability=capability),
                reason="Capability not held",
            )
            return DefenseResult(
                decision=PolicyDecision.DENY,
                action_name=action_name,
                capability_check=cap_decision,
                sanitization=empty_scan,
                policy_evaluation=empty_eval,
                reason=f"Missing capability: {capability.value}",
            )

        # 2. Input sanitization – combine all string inputs
        combined_text = " ".join(str(v) for v in inputs.values() if isinstance(v, str))
        scan_result = (
            self.sanitizer.scan(combined_text)
            if combined_text
            else SanitizationResult(original_text="")
        )

        # 3. Taint registration
        tainted_inputs: list[TaintedData] = []
        for key, value in inputs.items():
            if input_taint.is_trusted:
                td = self.tracker.create_trusted(value, description=key)
            else:
                td = self.tracker.create_tainted(
                    value,
                    label=input_taint,
                    description=key,
                )
            tainted_inputs.append(td)

        # 4. Policy evaluation
        action = Action(
            name=action_name,
            capability=capability,
            resource=resource,
            parameters=inputs,
            input_taint=input_taint,
            threat_level=scan_result.threat_level,
        )
        policy_eval = self.policy.evaluate(action)

        return DefenseResult(
            decision=policy_eval.decision,
            action_name=action_name,
            capability_check=cap_decision,
            sanitization=scan_result,
            policy_evaluation=policy_eval,
            tainted_inputs=tainted_inputs,
            reason=policy_eval.reason,
        )

    # ------------------------------------------------------------------
    # Convenience: scan text only
    # ------------------------------------------------------------------

    def scan_text(self, text: str) -> SanitizationResult:
        """Scan a piece of text without evaluating an action."""
        return self.sanitizer.scan(text)

    # ------------------------------------------------------------------
    # Convenience: process via dual-LLM
    # ------------------------------------------------------------------

    def process_trusted(self, message: str, **kw: Any) -> TaintedData:
        """Process a trusted user message through the privileged LLM."""
        if self.orchestrator is None:
            raise RuntimeError(
                "No LLMs configured – pass privileged_llm to CamelDefense()"
            )
        return self.orchestrator.process_privileged(message, **kw)

    def process_untrusted(
        self,
        content: str,
        *,
        source_label: TaintLabel = TaintLabel.TOOL_OUTPUT,
        **kw: Any,
    ) -> TaintedData:
        """Process untrusted content through the quarantined LLM."""
        if self.orchestrator is None:
            raise RuntimeError(
                "No LLMs configured – pass privileged_llm to CamelDefense()"
            )
        return self.orchestrator.process_quarantined(
            content,
            source_label=source_label,
            **kw,
        )
