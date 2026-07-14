#!/usr/bin/python3
"""Static contract tests for Broadcom wl image provisioning."""

from pathlib import Path
import unittest


PROJECT_ROOT = Path(__file__).resolve().parents[1]
PACKAGE_SCRIPT = PROJECT_ROOT / "files" / "scripts" / "30-packages.sh"
BUILD_WORKFLOW = PROJECT_ROOT / ".github" / "workflows" / "reusable-build.yml"


class BroadcomImageProvisioningTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.package_script = PACKAGE_SCRIPT.read_text(encoding="utf-8")
        cls.build_workflow = BUILD_WORKFLOW.read_text(encoding="utf-8")

    def test_image_installs_the_wl_akmod_and_matching_kernel_headers(self):
        self.assertIn("akmod-wl", self.package_script)
        self.assertIn("akmods", self.package_script)
        self.assertIn("kernel-devel-matched", self.package_script)

    def test_image_builds_and_verifies_wl_for_its_baked_kernel(self):
        self.assertIn('akmods --force --kernels "${kernel_version}"', self.package_script)
        self.assertIn('depmod -a "${kernel_version}"', self.package_script)
        self.assertIn('modinfo -k "${kernel_version}" wl', self.package_script)

    def test_image_uses_the_quick_setup_build_that_checks_wl(self):
        self.assertIn("'quick-setup >= 10.2.10-3'", self.package_script)

    def test_ci_asserts_the_baked_image_resolves_wl(self):
        self.assertIn('modinfo -k "${kernel_version}" wl', self.build_workflow)


if __name__ == "__main__":
    unittest.main()
