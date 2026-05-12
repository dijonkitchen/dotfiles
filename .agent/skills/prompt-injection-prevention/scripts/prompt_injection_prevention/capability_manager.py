"""
Capability-Based Security Manager

Implements the principle of least privilege for agent tool invocations.
Inspired by CaMeL's capability model, every tool or action the agent can
perform is gated behind an explicit *capability* that must be granted
before the action is allowed to execute.

Capabilities can be:
* **Static** – granted once at agent initialisation time.
* **Dynamic** – granted (and revoked) at runtime in response to user
  approval or policy decisions.
* **Scoped** – restricted to specific arguments or resource patterns.
"""

from __future__ import annotations

import enum
import fnmatch
from dataclasses import dataclass, field
from typing import Any


class Capability(enum.Enum):
    """Predefined capability categories for common agent actions."""

    FILE_READ = "file_read"
    FILE_WRITE = "file_write"
    WEB_FETCH = "web_fetch"
    CODE_EXECUTE = "code_execute"
    DATABASE_QUERY = "database_query"
    DATABASE_WRITE = "database_write"
    SEND_EMAIL = "send_email"
    SEND_MESSAGE = "send_message"
    API_CALL = "api_call"
    SHELL_EXECUTE = "shell_execute"
    LLM_CALL = "llm_call"


@dataclass
class CapabilityGrant:
    """A concrete grant of a capability, optionally scoped."""

    capability: Capability
    resource_pattern: str = "*"  # fnmatch pattern for resources
    constraints: dict[str, Any] = field(default_factory=dict)
    reason: str = ""

    def matches_resource(self, resource: str) -> bool:
        """Return ``True`` when *resource* matches the grant's pattern."""
        return fnmatch.fnmatch(resource, self.resource_pattern)


@dataclass
class CapabilityRequest:
    """A request to exercise a capability."""

    capability: Capability
    resource: str = ""
    parameters: dict[str, Any] = field(default_factory=dict)
    requester: str = ""
    justification: str = ""


@dataclass
class CapabilityDecision:
    """The outcome of a capability check."""

    allowed: bool
    capability: Capability
    resource: str = ""
    reason: str = ""
    matching_grant: CapabilityGrant | None = None


class CapabilityManager:
    """Manages capability grants and checks for the agent.

    Example::

        mgr = CapabilityManager()
        mgr.grant(Capability.FILE_READ, resource_pattern="/safe/*")
        decision = mgr.check(Capability.FILE_READ, resource="/safe/data.txt")
        assert decision.allowed
    """

    def __init__(self) -> None:
        self._grants: list[CapabilityGrant] = []

    # ------------------------------------------------------------------
    # Grant / revoke
    # ------------------------------------------------------------------

    def grant(
        self,
        capability: Capability,
        *,
        resource_pattern: str = "*",
        constraints: dict[str, Any] | None = None,
        reason: str = "",
    ) -> CapabilityGrant:
        """Grant a capability, optionally scoped to a resource pattern."""
        g = CapabilityGrant(
            capability=capability,
            resource_pattern=resource_pattern,
            constraints=constraints or {},
            reason=reason,
        )
        self._grants.append(g)
        return g

    def revoke(self, capability: Capability, resource_pattern: str = "*") -> int:
        """Revoke grants matching *capability* and *resource_pattern*.

        Returns the number of grants removed.
        """
        before = len(self._grants)
        self._grants = [
            g
            for g in self._grants
            if not (
                g.capability == capability and g.resource_pattern == resource_pattern
            )
        ]
        return before - len(self._grants)

    def revoke_all(self) -> None:
        """Remove every capability grant."""
        self._grants.clear()

    # ------------------------------------------------------------------
    # Checking
    # ------------------------------------------------------------------

    def check(
        self,
        capability: Capability,
        resource: str = "",
    ) -> CapabilityDecision:
        """Check whether the agent currently holds a matching capability."""
        for g in self._grants:
            if g.capability == capability and g.matches_resource(resource):
                return CapabilityDecision(
                    allowed=True,
                    capability=capability,
                    resource=resource,
                    reason=g.reason or "Matching grant found",
                    matching_grant=g,
                )
        return CapabilityDecision(
            allowed=False,
            capability=capability,
            resource=resource,
            reason="No matching capability grant",
        )

    def require(
        self,
        capability: Capability,
        resource: str = "",
    ) -> CapabilityDecision:
        """Like :meth:`check` but raises on denial."""
        decision = self.check(capability, resource)
        if not decision.allowed:
            raise PermissionError(
                f"Capability {capability.value!r} denied for "
                f"resource {resource!r}: {decision.reason}"
            )
        return decision

    # ------------------------------------------------------------------
    # Introspection
    # ------------------------------------------------------------------

    def list_grants(self) -> list[CapabilityGrant]:
        return list(self._grants)

    def has_capability(self, capability: Capability) -> bool:
        return any(g.capability == capability for g in self._grants)
