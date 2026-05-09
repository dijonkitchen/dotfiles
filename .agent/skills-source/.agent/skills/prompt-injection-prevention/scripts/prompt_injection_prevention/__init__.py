"""
Prompt Injection Prevention Skill

Protect LLM-based agents against prompt injection attacks using a single
entry point — :class:`CamelDefense`.

``CamelDefense`` composes taint tracking, capability-based security,
input sanitization, policy enforcement, and an optional dual-LLM
architecture into one simple API.

Quick start::

    from prompt_injection_prevention import CamelDefense, Capability, TaintLabel

    defense = CamelDefense()
    defense.grant_capability(Capability.FILE_READ, resource_pattern="/safe/*")

    result = defense.evaluate_action(
        action_name="read_file",
        capability=Capability.FILE_READ,
        resource="/safe/report.txt",
        inputs={"query": user_query},
        input_taint=TaintLabel.USER_INPUT,
    )

    if result.is_allowed:
        ...  # proceed

Advanced types (``PolicyEngine``, ``PolicyRule``, ``InputSanitizer``,
``TaintTracker``, etc.) are still accessible via their sub-modules::

    from prompt_injection_prevention.policy_engine import PolicyRule
"""

from prompt_injection_prevention.capability_manager import Capability
from prompt_injection_prevention.input_sanitizer import ThreatLevel
from prompt_injection_prevention.policy_engine import PolicyDecision
from prompt_injection_prevention.taint_tracker import TaintLabel
from prompt_injection_prevention.camel_defense import CamelDefense, DefenseResult

__all__ = [
    "CamelDefense",
    "Capability",
    "DefenseResult",
    "PolicyDecision",
    "TaintLabel",
    "ThreatLevel",
]

__version__ = "0.1.0"
