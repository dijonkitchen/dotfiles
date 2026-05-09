"""Tests for DualLLMOrchestrator."""

import unittest

from prompt_injection_prevention.dual_llm import DualLLMOrchestrator
from prompt_injection_prevention.taint_tracker import TaintLabel, TaintTracker


def _echo_llm(messages, **kwargs):
    """Stub LLM that echoes the last user message."""
    for m in reversed(messages):
        if m["role"] == "user":
            return f"Echo: {m['content'][:50]}"
    return "No user message"


class TestDualLLMOrchestrator(unittest.TestCase):
    def test_privileged_returns_trusted_data(self):
        tracker = TaintTracker()
        orch = DualLLMOrchestrator(
            privileged_llm=_echo_llm,
            taint_tracker=tracker,
        )
        result = orch.process_privileged("Hello")
        self.assertTrue(result.is_trusted)
        self.assertIn("Echo", str(result.value))

    def test_quarantined_returns_tainted_data(self):
        tracker = TaintTracker()
        orch = DualLLMOrchestrator(
            privileged_llm=_echo_llm,
            taint_tracker=tracker,
        )
        result = orch.process_quarantined(
            "Some tool output",
            source_label=TaintLabel.TOOL_OUTPUT,
        )
        self.assertTrue(result.is_tainted)
        self.assertIn(TaintLabel.TOOL_OUTPUT, result.labels)
        self.assertIn(TaintLabel.LLM_GENERATED, result.labels)

    def test_separate_histories(self):
        orch = DualLLMOrchestrator(privileged_llm=_echo_llm)
        orch.process_privileged("Trusted message")
        orch.process_quarantined("Untrusted data")
        priv = orch.get_privileged_history()
        quar = orch.get_quarantined_history()
        self.assertEqual(len(priv), 2)  # user + assistant
        self.assertEqual(len(quar), 2)  # user + assistant

    def test_system_prompt_in_privileged(self):
        orch = DualLLMOrchestrator(
            privileged_llm=_echo_llm,
            system_prompt="You are a helpful assistant.",
        )
        history = orch.get_privileged_history()
        self.assertEqual(len(history), 1)
        self.assertEqual(history[0].role, "system")

    def test_clear_quarantined_history(self):
        orch = DualLLMOrchestrator(privileged_llm=_echo_llm)
        orch.process_quarantined("data")
        orch.clear_quarantined_history()
        self.assertEqual(len(orch.get_quarantined_history()), 0)

    def test_inject_trusted_summary(self):
        orch = DualLLMOrchestrator(privileged_llm=_echo_llm)
        orch.inject_trusted_summary("The file contains sales data for Q1")
        history = orch.get_privileged_history()
        self.assertEqual(len(history), 1)
        self.assertIn("[Verified summary]", history[0].content)

    def test_custom_extraction_prompt(self):
        def capture_llm(messages, **kwargs):
            return messages[-1]["content"]

        orch = DualLLMOrchestrator(
            privileged_llm=capture_llm,
            quarantined_llm=capture_llm,
        )
        result = orch.process_quarantined(
            "raw data",
            extraction_prompt="Extract numbers from: raw data",
        )
        self.assertIn("Extract numbers", str(result.value))


if __name__ == "__main__":
    unittest.main()
