"""
Policy Engine

The policy engine sits at the heart of the CaMeL-inspired defense. It
evaluates every proposed agent *action* against a configurable set of
*rules* that consider:

* The **taint status** of the action's inputs.
* The **capability** required by the action.
* The **threat level** reported by the input sanitizer.
* Optional **custom predicates** supplied by the integrator.

Each rule maps a condition to a ``PolicyDecision`` (ALLOW, DENY, or
QUARANTINE). Rules are evaluated in priority order; the first match
wins. If no rule matches, the engine's *default* decision applies
(DENY by default – secure by default).
"""

from __future__ import annotations

import enum
from dataclasses import dataclass, field
from typing import Any, Callable

from prompt_injection_prevention.capability_manager import Capability
from prompt_injection_prevention.input_sanitizer import ThreatLevel
from prompt_injection_prevention.taint_tracker import TaintLabel


class PolicyDecision(enum.Enum):
    ALLOW = "allow"
    DENY = "deny"
    QUARANTINE = "quarantine"  # Needs human review


@dataclass
class Action:
    """A proposed agent action that the policy engine evaluates."""

    name: str
    capability: Capability
    resource: str = ""
    parameters: dict[str, Any] = field(default_factory=dict)
    input_taint: TaintLabel = TaintLabel.NONE
    threat_level: ThreatLevel = ThreatLevel.NONE


@dataclass
class PolicyRule:
    """A single policy rule.

    Parameters
    ----------
    name:
        Human-readable rule name.
    priority:
        Lower numbers are evaluated first.
    decision:
        The decision to return when this rule matches.
    condition:
        A callable ``(Action) -> bool``. When it returns ``True`` the
        rule matches.  If ``None``, the rule always matches (useful as a
        default-allow or default-deny catch-all).
    reason:
        Explanation attached to the decision.
    """

    name: str
    priority: int
    decision: PolicyDecision
    condition: Callable[[Action], bool] | None = None
    reason: str = ""

    def matches(self, action: Action) -> bool:
        if self.condition is None:
            return True
        return self.condition(action)


@dataclass
class PolicyEvaluation:
    """Result of a policy evaluation."""

    decision: PolicyDecision
    action: Action
    matching_rule: PolicyRule | None = None
    reason: str = ""


class PolicyEngine:
    """Evaluate proposed actions against a rule set.

    Example::

        engine = PolicyEngine()
        engine.add_default_rules()
        evaluation = engine.evaluate(action)
        if evaluation.decision == PolicyDecision.DENY:
            raise PermissionError(evaluation.reason)
    """

    def __init__(
        self,
        *,
        default_decision: PolicyDecision = PolicyDecision.DENY,
    ) -> None:
        self._rules: list[PolicyRule] = []
        self._default_decision = default_decision

    # ------------------------------------------------------------------
    # Rule management
    # ------------------------------------------------------------------

    def add_rule(self, rule: PolicyRule) -> None:
        self._rules.append(rule)
        self._rules.sort(key=lambda r: r.priority)

    def remove_rule(self, name: str) -> bool:
        before = len(self._rules)
        self._rules = [r for r in self._rules if r.name != name]
        return len(self._rules) < before

    def add_default_rules(self) -> None:
        """Install a sensible set of rules inspired by CaMeL."""
        self.add_rule(
            PolicyRule(
                name="block_critical_threats",
                priority=0,
                decision=PolicyDecision.DENY,
                condition=lambda a: a.threat_level >= ThreatLevel.CRITICAL,
                reason="Input contains a critical-level injection indicator",
            )
        )
        self.add_rule(
            PolicyRule(
                name="quarantine_high_threats",
                priority=10,
                decision=PolicyDecision.QUARANTINE,
                condition=lambda a: a.threat_level >= ThreatLevel.HIGH,
                reason="Input contains a high-level injection indicator",
            )
        )
        self.add_rule(
            PolicyRule(
                name="block_tainted_code_exec",
                priority=20,
                decision=PolicyDecision.DENY,
                condition=lambda a: (
                    a.capability in (Capability.CODE_EXECUTE, Capability.SHELL_EXECUTE)
                    and a.input_taint.is_untrusted
                ),
                reason=("Code/shell execution with tainted input is not allowed"),
            )
        )
        self.add_rule(
            PolicyRule(
                name="block_tainted_write",
                priority=30,
                decision=PolicyDecision.DENY,
                condition=lambda a: (
                    a.capability in (Capability.FILE_WRITE, Capability.DATABASE_WRITE)
                    and a.input_taint.is_untrusted
                ),
                reason="Write operations with tainted input are not allowed",
            )
        )
        self.add_rule(
            PolicyRule(
                name="quarantine_tainted_comms",
                priority=40,
                decision=PolicyDecision.QUARANTINE,
                condition=lambda a: (
                    a.capability in (Capability.SEND_EMAIL, Capability.SEND_MESSAGE)
                    and a.input_taint.is_untrusted
                ),
                reason=("Communication with tainted input requires human review"),
            )
        )
        self.add_rule(
            PolicyRule(
                name="allow_trusted_actions",
                priority=100,
                decision=PolicyDecision.ALLOW,
                condition=lambda a: (
                    a.input_taint.is_trusted and a.threat_level <= ThreatLevel.LOW
                ),
                reason="Trusted input with no significant threat",
            )
        )

    # ------------------------------------------------------------------
    # Evaluation
    # ------------------------------------------------------------------

    def evaluate(self, action: Action) -> PolicyEvaluation:
        """Evaluate *action* and return the policy decision."""
        for rule in self._rules:
            if rule.matches(action):
                return PolicyEvaluation(
                    decision=rule.decision,
                    action=action,
                    matching_rule=rule,
                    reason=rule.reason,
                )
        return PolicyEvaluation(
            decision=self._default_decision,
            action=action,
            reason="No matching rule – applying default decision",
        )
