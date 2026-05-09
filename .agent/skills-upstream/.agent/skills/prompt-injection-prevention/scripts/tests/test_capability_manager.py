"""Tests for CapabilityManager."""

import unittest

from prompt_injection_prevention.capability_manager import (
    Capability,
    CapabilityManager,
)


class TestCapabilityManager(unittest.TestCase):
    def test_grant_and_check(self):
        mgr = CapabilityManager()
        mgr.grant(Capability.FILE_READ)
        decision = mgr.check(Capability.FILE_READ, resource="/any/file")
        self.assertTrue(decision.allowed)

    def test_check_without_grant_denies(self):
        mgr = CapabilityManager()
        decision = mgr.check(Capability.FILE_READ)
        self.assertFalse(decision.allowed)

    def test_scoped_grant(self):
        mgr = CapabilityManager()
        mgr.grant(Capability.FILE_READ, resource_pattern="/safe/*")
        self.assertTrue(
            mgr.check(Capability.FILE_READ, resource="/safe/data.txt").allowed
        )
        self.assertFalse(
            mgr.check(Capability.FILE_READ, resource="/etc/passwd").allowed
        )

    def test_revoke(self):
        mgr = CapabilityManager()
        mgr.grant(Capability.FILE_READ)
        removed = mgr.revoke(Capability.FILE_READ)
        self.assertEqual(removed, 1)
        self.assertFalse(mgr.check(Capability.FILE_READ).allowed)

    def test_revoke_all(self):
        mgr = CapabilityManager()
        mgr.grant(Capability.FILE_READ)
        mgr.grant(Capability.WEB_FETCH)
        mgr.revoke_all()
        self.assertFalse(mgr.has_capability(Capability.FILE_READ))
        self.assertFalse(mgr.has_capability(Capability.WEB_FETCH))

    def test_require_raises_on_denial(self):
        mgr = CapabilityManager()
        with self.assertRaises(PermissionError) as ctx:
            mgr.require(Capability.SHELL_EXECUTE)
        self.assertIn("denied", str(ctx.exception))

    def test_require_succeeds_when_granted(self):
        mgr = CapabilityManager()
        mgr.grant(Capability.SHELL_EXECUTE)
        decision = mgr.require(Capability.SHELL_EXECUTE)
        self.assertTrue(decision.allowed)

    def test_list_grants(self):
        mgr = CapabilityManager()
        mgr.grant(Capability.FILE_READ, reason="test")
        grants = mgr.list_grants()
        self.assertEqual(len(grants), 1)
        self.assertEqual(grants[0].capability, Capability.FILE_READ)

    def test_has_capability(self):
        mgr = CapabilityManager()
        self.assertFalse(mgr.has_capability(Capability.FILE_READ))
        mgr.grant(Capability.FILE_READ)
        self.assertTrue(mgr.has_capability(Capability.FILE_READ))

    def test_multiple_grants_same_capability_different_scope(self):
        mgr = CapabilityManager()
        mgr.grant(Capability.FILE_READ, resource_pattern="/safe/*")
        mgr.grant(Capability.FILE_READ, resource_pattern="/tmp/*")
        self.assertTrue(mgr.check(Capability.FILE_READ, resource="/safe/a.txt").allowed)
        self.assertTrue(mgr.check(Capability.FILE_READ, resource="/tmp/b.txt").allowed)
        self.assertFalse(
            mgr.check(Capability.FILE_READ, resource="/etc/passwd").allowed
        )


if __name__ == "__main__":
    unittest.main()
