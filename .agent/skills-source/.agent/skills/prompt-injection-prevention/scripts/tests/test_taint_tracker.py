"""Tests for TaintTracker."""

import unittest

from prompt_injection_prevention.taint_tracker import (
    TaintedData,
    TaintLabel,
    TaintTracker,
)


class TestTaintLabel(unittest.TestCase):
    def test_user_input_is_trusted(self):
        self.assertTrue(TaintLabel.USER_INPUT.is_trusted)

    def test_none_is_trusted(self):
        self.assertTrue(TaintLabel.NONE.is_trusted)

    def test_tool_output_is_untrusted(self):
        self.assertTrue(TaintLabel.TOOL_OUTPUT.is_untrusted)

    def test_web_content_is_untrusted(self):
        self.assertTrue(TaintLabel.WEB_CONTENT.is_untrusted)

    def test_combined_untrusted_labels(self):
        combined = TaintLabel.TOOL_OUTPUT | TaintLabel.WEB_CONTENT
        self.assertTrue(combined.is_untrusted)

    def test_user_input_combined_with_tool_output_is_untrusted(self):
        combined = TaintLabel.USER_INPUT | TaintLabel.TOOL_OUTPUT
        self.assertTrue(combined.is_untrusted)


class TestTaintedData(unittest.TestCase):
    def test_trusted_data(self):
        td = TaintedData(value="hello", labels=TaintLabel.USER_INPUT)
        self.assertTrue(td.is_trusted)
        self.assertFalse(td.is_tainted)

    def test_tainted_data(self):
        td = TaintedData(value="hello", labels=TaintLabel.TOOL_OUTPUT)
        self.assertTrue(td.is_tainted)
        self.assertFalse(td.is_trusted)

    def test_with_additional_label(self):
        td = TaintedData(value="hello", labels=TaintLabel.TOOL_OUTPUT)
        td2 = td.with_additional_label(TaintLabel.WEB_CONTENT)
        self.assertIn(TaintLabel.TOOL_OUTPUT, td2.labels)
        self.assertIn(TaintLabel.WEB_CONTENT, td2.labels)
        # Original unchanged
        self.assertNotIn(TaintLabel.WEB_CONTENT, td.labels)

    def test_data_id_is_generated(self):
        td1 = TaintedData(value="a")
        td2 = TaintedData(value="b")
        self.assertNotEqual(td1.data_id, td2.data_id)


class TestTaintTracker(unittest.TestCase):
    def test_create_trusted(self):
        tracker = TaintTracker()
        td = tracker.create_trusted("user command")
        self.assertTrue(td.is_trusted)
        self.assertIs(tracker.lookup(td.data_id), td)

    def test_create_tainted(self):
        tracker = TaintTracker()
        td = tracker.create_tainted(
            "tool output", TaintLabel.TOOL_OUTPUT, description="api result"
        )
        self.assertTrue(td.is_tainted)
        self.assertTrue(tracker.is_tainted(td.data_id))

    def test_create_tainted_rejects_trusted_labels(self):
        tracker = TaintTracker()
        with self.assertRaises(ValueError):
            tracker.create_tainted("x", TaintLabel.NONE)
        with self.assertRaises(ValueError):
            tracker.create_tainted("x", TaintLabel.USER_INPUT)

    def test_propagate_combines_labels(self):
        tracker = TaintTracker()
        a = tracker.create_trusted("user part")
        b = tracker.create_tainted("web part", TaintLabel.WEB_CONTENT)
        combined = tracker.propagate(a, b, result_value="merged")
        self.assertTrue(combined.is_tainted)
        self.assertIn(TaintLabel.USER_INPUT, combined.labels)
        self.assertIn(TaintLabel.WEB_CONTENT, combined.labels)

    def test_unknown_id_is_tainted_by_default(self):
        tracker = TaintTracker()
        self.assertTrue(tracker.is_tainted("nonexistent"))

    def test_get_all_tainted_and_trusted(self):
        tracker = TaintTracker()
        tracker.create_trusted("a")
        tracker.create_tainted("b", TaintLabel.FILE_CONTENT)
        tracker.create_trusted("c")
        self.assertEqual(len(tracker.get_all_trusted()), 2)
        self.assertEqual(len(tracker.get_all_tainted()), 1)

    def test_clear(self):
        tracker = TaintTracker()
        tracker.create_trusted("a")
        tracker.clear()
        self.assertEqual(tracker.get_all_trusted(), [])


if __name__ == "__main__":
    unittest.main()
