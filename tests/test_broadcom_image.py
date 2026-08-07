#!/usr/bin/env python3
"""Regression coverage for Broadcom wl image boot policy."""

from pathlib import Path
import unittest


PROJECT_ROOT = Path(__file__).resolve().parents[1]
BROADCOM_SCRIPT = PROJECT_ROOT / "files" / "scripts" / "35-broadcom-wl.sh"
BUILD_WORKFLOW = PROJECT_ROOT / ".github" / "workflows" / "reusable-build.yml"
MAIN_WORKFLOW = PROJECT_ROOT / ".github" / "workflows" / "build.yml"


class BroadcomBootPolicyTests(unittest.TestCase):
    def test_wl_is_blocked_until_quick_setup_enables_it(self):
        script = BROADCOM_SCRIPT.read_text(encoding="utf-8")

        self.assertIn(
            "ln -sfn /dev/null /etc/modprobe.d/broadcom-wl-blacklist.conf",
            script,
        )
        self.assertIn('"blacklist wl"', script)
        self.assertIn('"install wl /bin/false"', script)
        self.assertIn(
            "/etc/modprobe.d/default-disable-broadcom-wl.conf",
            script,
        )

    def test_ci_verifies_the_composed_image_blocks_wl(self):
        workflow = BUILD_WORKFLOW.read_text(encoding="utf-8")

        self.assertIn(
            'test "$(readlink /etc/modprobe.d/broadcom-wl-blacklist.conf)" = /dev/null',
            workflow,
        )
        self.assertIn(
            "grep -Fxq 'blacklist wl' /etc/modprobe.d/default-disable-broadcom-wl.conf",
            workflow,
        )
        self.assertIn(
            "grep -Fxq 'install wl /bin/false' /etc/modprobe.d/default-disable-broadcom-wl.conf",
            workflow,
        )
        self.assertIn("modprobe --showconfig | grep -Fxq 'install wl /bin/false'", workflow)

    def test_build_runs_the_image_contract_tests(self):
        workflow = MAIN_WORKFLOW.read_text(encoding="utf-8")

        self.assertIn(
            'python3 -m unittest discover -s tests -p "test_*.py" -v',
            workflow,
        )


if __name__ == "__main__":
    unittest.main()
