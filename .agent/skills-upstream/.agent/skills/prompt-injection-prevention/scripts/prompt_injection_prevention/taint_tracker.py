"""
Taint Tracking System

Implements data-flow taint analysis inspired by CaMeL. Every piece of
data flowing through the agent is annotated with *taint labels* that
record its provenance. Data originating from untrusted sources (tool
outputs, web content, file reads, etc.) is marked as tainted and must
not be allowed to influence control-flow decisions unless explicitly
declassified through a sanitization gate.

Key ideas
---------
* ``TaintLabel`` – an enum of provenance categories.
* ``TaintedData`` – a wrapper that pairs a value with its taint labels.
* ``TaintTracker`` – a registry that propagates taint through
  concatenations, template substitutions, and other data-flow
  operations.
"""

from __future__ import annotations

import enum
import uuid
from dataclasses import dataclass, field
from typing import Any


class TaintLabel(enum.Flag):
    """Provenance categories for data flowing through an agent."""

    NONE = 0
    USER_INPUT = enum.auto()  # Direct user instruction (trusted)
    TOOL_OUTPUT = enum.auto()  # Returned by a tool invocation
    WEB_CONTENT = enum.auto()  # Fetched from the internet
    FILE_CONTENT = enum.auto()  # Read from the filesystem
    DATABASE_RESULT = enum.auto()  # Returned by a database query
    LLM_GENERATED = enum.auto()  # Produced by an LLM call
    EXTERNAL_API = enum.auto()  # Received from a third-party API
    UNKNOWN = enum.auto()  # Origin is unknown

    @property
    def is_trusted(self) -> bool:
        """Return ``True`` when the label set contains only trusted sources."""
        trusted = TaintLabel.USER_INPUT | TaintLabel.NONE
        return self & ~trusted == TaintLabel.NONE

    @property
    def is_untrusted(self) -> bool:
        return not self.is_trusted


@dataclass(frozen=True)
class TaintedData:
    """A value annotated with taint labels and a unique tracking id."""

    value: Any
    labels: TaintLabel = TaintLabel.NONE
    data_id: str = field(default_factory=lambda: uuid.uuid4().hex[:12])
    source_description: str = ""

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @property
    def is_trusted(self) -> bool:
        return self.labels.is_trusted

    @property
    def is_tainted(self) -> bool:
        return self.labels.is_untrusted

    def with_additional_label(self, label: TaintLabel) -> TaintedData:
        """Return a copy with an extra taint label."""
        return TaintedData(
            value=self.value,
            labels=self.labels | label,
            data_id=self.data_id,
            source_description=self.source_description,
        )


class TaintTracker:
    """Registry that tracks tainted data and propagates labels.

    The tracker maintains a mapping from ``data_id`` → ``TaintedData`` so
    that downstream components can look up the taint status of any piece
    of data they encounter.
    """

    def __init__(self) -> None:
        self._registry: dict[str, TaintedData] = {}

    # ------------------------------------------------------------------
    # Registration
    # ------------------------------------------------------------------

    def register(self, data: TaintedData) -> TaintedData:
        """Register a ``TaintedData`` instance and return it."""
        self._registry[data.data_id] = data
        return data

    def create_trusted(self, value: Any, description: str = "") -> TaintedData:
        """Create and register a trusted (user-supplied) datum."""
        td = TaintedData(
            value=value,
            labels=TaintLabel.USER_INPUT,
            source_description=description or "user input",
        )
        return self.register(td)

    def create_tainted(
        self,
        value: Any,
        label: TaintLabel,
        description: str = "",
    ) -> TaintedData:
        """Create and register a tainted datum."""
        if label == TaintLabel.NONE or label == TaintLabel.USER_INPUT:
            raise ValueError(
                "Use create_trusted() for trusted data. "
                "create_tainted() requires an untrusted label."
            )
        td = TaintedData(
            value=value,
            labels=label,
            source_description=description,
        )
        return self.register(td)

    # ------------------------------------------------------------------
    # Propagation
    # ------------------------------------------------------------------

    def propagate(self, *sources: TaintedData, result_value: Any) -> TaintedData:
        """Create a new datum whose taint is the union of *sources*."""
        combined = TaintLabel.NONE
        descriptions: list[str] = []
        for s in sources:
            combined |= s.labels
            if s.source_description:
                descriptions.append(s.source_description)
        td = TaintedData(
            value=result_value,
            labels=combined,
            source_description=" + ".join(descriptions),
        )
        return self.register(td)

    # ------------------------------------------------------------------
    # Lookup
    # ------------------------------------------------------------------

    def lookup(self, data_id: str) -> TaintedData | None:
        return self._registry.get(data_id)

    def is_tainted(self, data_id: str) -> bool:
        td = self.lookup(data_id)
        return td.is_tainted if td is not None else True  # default-deny

    # ------------------------------------------------------------------
    # Bulk helpers
    # ------------------------------------------------------------------

    def get_all_tainted(self) -> list[TaintedData]:
        return [td for td in self._registry.values() if td.is_tainted]

    def get_all_trusted(self) -> list[TaintedData]:
        return [td for td in self._registry.values() if td.is_trusted]

    def clear(self) -> None:
        self._registry.clear()
