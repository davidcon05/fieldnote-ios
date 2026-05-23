#!/usr/bin/env python3
"""
FieldNote UI Test Runner
Simplifies running Maestro tests locally by handling all the setup steps.

Usage:
    ./scripts/fn-uitest.py                  # Interactive menu
    ./scripts/fn-uitest.py --run-all        # Build, install, and run all tests
    ./scripts/fn-uitest.py --test <file>    # Run specific test
    ./scripts/fn-uitest.py --debug          # Debug mode with verbose output
"""

import subprocess
import sys
import json
import argparse
from pathlib import Path
from typing import Optional, List, Dict


class Colors:
    """ANSI color codes for terminal output"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'


class FieldNoteTestRunner:
    def __init__(self, debug: bool = False):
        self.debug = debug
        self.project_root = Path(__file__).parent.parent
        self.build_path = self.project_root / "build"
        self.app_path = self.build_path / "Build/Products/Debug-iphonesimulator/fieldnote.app"
        self.maestro_dir = self.project_root / ".maestro"
        self.bundle_id = "com.davidcon.fieldnote"
        self.booted_simulator_udid: Optional[str] = None
        self.check_dependencies()

    def log(self, message: str, color: str = Colors.BLUE):
        """Print colored log message"""
        print(f"{color}{message}{Colors.END}")

    def log_section(self, title: str):
        """Print section header"""
        print(f"\n{Colors.BOLD}{Colors.HEADER}{'='*60}{Colors.END}")
        print(f"{Colors.BOLD}{Colors.HEADER}{title}{Colors.END}")
        print(f"{Colors.BOLD}{Colors.HEADER}{'='*60}{Colors.END}\n")

    def check_dependencies(self):
        """Check if required tools are installed"""
        # Check for xcodebuild
        result = subprocess.run(["which", "xcodebuild"], capture_output=True)
        if result.returncode != 0:
            self.log("❌ xcodebuild not found. Please install Xcode Command Line Tools:", Colors.RED)
            print("   xcode-select --install")
            sys.exit(1)

        # Check for maestro
        result = subprocess.run(["which", "maestro"], capture_output=True)
        if result.returncode != 0:
            self.log("❌ Maestro CLI not found. Install it with:", Colors.RED)
            print(f"{Colors.YELLOW}   curl -Ls \"https://get.maestro.mobile.dev\" | bash{Colors.END}")
            print(f"{Colors.YELLOW}   export PATH=\"$HOME/.maestro/bin:$PATH\"{Colors.END}")
            print(f"\n{Colors.CYAN}After installing, add to your ~/.zshrc:{Colors.END}")
            print(f'{Colors.YELLOW}   export PATH="$HOME/.maestro/bin:$PATH"{Colors.END}\n')
            sys.exit(1)

    def run_command(self, cmd: List[str], check: bool = True) -> subprocess.CompletedProcess:
        """Run shell command with optional debug output"""
        if self.debug:
            self.log(f"Running: {' '.join(cmd)}", Colors.CYAN)

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False
        )

        if self.debug:
            if result.stdout:
                print(result.stdout)
            if result.stderr:
                print(result.stderr, file=sys.stderr)

        if check and result.returncode != 0:
            self.log(f"❌ Command failed with exit code {result.returncode}", Colors.RED)
            if not self.debug:
                print(result.stdout)
                print(result.stderr, file=sys.stderr)
            sys.exit(result.returncode)

        return result

    def get_available_simulators(self) -> List[Dict]:
        """Get list of available iOS simulators"""
        result = self.run_command(["xcrun", "simctl", "list", "devices", "available", "--json"])
        devices_data = json.loads(result.stdout)

        simulators = []
        for runtime, devices in devices_data["devices"].items():
            if "iOS" in runtime:
                for device in devices:
                    if device.get("isAvailable", False):
                        simulators.append({
                            "name": device["name"],
                            "udid": device["udid"],
                            "runtime": runtime
                        })

        return simulators

    def get_booted_simulator(self) -> Optional[str]:
        """Get UDID of currently booted simulator"""
        result = self.run_command(["xcrun", "simctl", "list", "devices", "--json"])
        devices_data = json.loads(result.stdout)

        for runtime, devices in devices_data["devices"].items():
            for device in devices:
                if device.get("state") == "Booted":
                    return device["udid"]

        return None

    def boot_simulator(self, device_name: Optional[str] = None) -> str:
        """Boot a simulator and return its UDID"""
        self.log_section("🚀 Booting Simulator")

        # Check if one is already booted
        booted_udid = self.get_booted_simulator()
        if booted_udid:
            result = self.run_command(["xcrun", "simctl", "list", "devices", "--json"])
            devices_data = json.loads(result.stdout)
            for runtime, devices in devices_data["devices"].items():
                for device in devices:
                    if device["udid"] == booted_udid:
                        self.log(f"✅ Using already booted simulator: {device['name']}", Colors.GREEN)
                        self.booted_simulator_udid = booted_udid
                        return booted_udid

        # Get available simulators
        simulators = self.get_available_simulators()
        if not simulators:
            self.log("❌ No available simulators found", Colors.RED)
            sys.exit(1)

        # Find target simulator
        target_sim = None
        if device_name:
            target_sim = next((s for s in simulators if s["name"] == device_name), None)
        else:
            # Default to first iPhone 15 or 16
            target_sim = next((s for s in simulators if "iPhone 1" in s["name"]), simulators[0])

        if not target_sim:
            self.log(f"❌ Simulator '{device_name}' not found", Colors.RED)
            sys.exit(1)

        self.log(f"Booting {target_sim['name']}...", Colors.BLUE)
        self.run_command(["xcrun", "simctl", "boot", target_sim["udid"]])

        # Wait for boot to complete
        self.run_command(["xcrun", "simctl", "bootstatus", target_sim["udid"]])

        self.log(f"✅ Simulator booted: {target_sim['name']}", Colors.GREEN)
        self.booted_simulator_udid = target_sim["udid"]
        return target_sim["udid"]

    def build_app(self):
        """Build the FieldNote app"""
        self.log_section("🔨 Building App")

        self.run_command([
            "xcodebuild",
            "-project", str(self.project_root / "fieldnote.xcodeproj"),
            "-scheme", "fieldnote",
            "-sdk", "iphonesimulator",
            "-configuration", "Debug",
            "-derivedDataPath", str(self.build_path),
            "build"
        ])

        if not self.app_path.exists():
            self.log(f"❌ App not found at {self.app_path}", Colors.RED)
            sys.exit(1)

        self.log(f"✅ App built successfully", Colors.GREEN)

    def install_app(self, udid: str):
        """Install app on simulator"""
        self.log_section("📱 Installing App")

        self.run_command([
            "xcrun", "simctl", "install", udid, str(self.app_path)
        ])

        self.log(f"✅ App installed successfully", Colors.GREEN)

        # Verify installation and get actual bundle ID
        result = self.run_command(["xcrun", "simctl", "listapps", udid], check=False)
        if self.bundle_id in result.stdout:
            self.log(f"✅ Verified: {self.bundle_id} is installed", Colors.GREEN)
        else:
            self.log(f"⚠️  Warning: Could not verify {self.bundle_id} installation", Colors.YELLOW)

        # Read bundle ID from Info.plist to verify
        info_plist = self.app_path / "Info.plist"
        if info_plist.exists():
            plist_result = self.run_command([
                "plutil", "-extract", "CFBundleIdentifier", "raw", str(info_plist)
            ], check=False)
            if plist_result.returncode == 0:
                actual_bundle_id = plist_result.stdout.strip()
                self.log(f"📦 Actual Bundle ID from Info.plist: {actual_bundle_id}", Colors.CYAN)
                if actual_bundle_id != self.bundle_id:
                    self.log(f"⚠️  Bundle ID mismatch! Expected: {self.bundle_id}, Got: {actual_bundle_id}", Colors.RED)
                    self.log(f"💡 Update your .maestro/*.yaml files to use: appId: {actual_bundle_id}", Colors.YELLOW)

    def launch_app_manually(self, udid: str):
        """Manually launch the app to verify it can start"""
        self.log_section("🚀 Testing App Launch")

        # Try to launch the app
        result = self.run_command([
            "xcrun", "simctl", "launch", udid, self.bundle_id
        ], check=False)

        if result.returncode == 0:
            self.log(f"✅ App launched successfully", Colors.GREEN)
            # Terminate it so tests can launch fresh
            self.run_command(["xcrun", "simctl", "terminate", udid, self.bundle_id], check=False)
        else:
            self.log(f"❌ Failed to launch app manually", Colors.RED)
            self.log(f"Error: {result.stderr}", Colors.RED)
            self.log(f"\n💡 This might be a code signing or entitlements issue", Colors.YELLOW)
            return False

        return True

    def list_maestro_tests(self) -> List[Path]:
        """Get list of Maestro test files"""
        return sorted(self.maestro_dir.glob("*.yaml"))

    def run_maestro_test(self, test_file: Optional[Path] = None):
        """Run Maestro tests"""
        if test_file:
            self.log_section(f"🧪 Running Test: {test_file.name}")
            cmd = ["maestro", "test", "--platform", "ios", str(test_file)]
        else:
            self.log_section("🧪 Running All Maestro Tests")
            cmd = ["maestro", "test", "--platform", "ios", str(self.maestro_dir)]

        result = self.run_command(cmd, check=False)

        if result.returncode == 0:
            self.log("✅ All tests passed!", Colors.GREEN)
        else:
            self.log(f"❌ Tests failed with exit code {result.returncode}", Colors.RED)
            print(result.stdout)
            print(result.stderr, file=sys.stderr)

        return result.returncode

    def interactive_menu(self):
        """Show interactive menu"""
        while True:
            self.log_section("FieldNote UI Test Runner")
            print("1. 🚀 Run full test suite (build + install + test all)")
            print("2. 🔨 Build app only")
            print("3. 📱 Install app only")
            print("4. 🧪 Run Maestro tests only")
            print("5. 📝 Run specific test")
            print("6. 🔍 List available simulators")
            print("7. 📋 List installed apps on booted simulator")
            print("8. 🗑️  Uninstall app from simulator")
            print("9. ❌ Exit")

            choice = input(f"\n{Colors.CYAN}Choose an option (1-9): {Colors.END}").strip()

            if choice == "1":
                self.run_full_suite()
            elif choice == "2":
                self.build_app()
            elif choice == "3":
                udid = self.get_booted_simulator() or self.boot_simulator()
                self.install_app(udid)
            elif choice == "4":
                udid = self.get_booted_simulator()
                if not udid:
                    self.log("⚠️  No simulator booted. Boot one first.", Colors.YELLOW)
                else:
                    self.run_maestro_test()
            elif choice == "5":
                self.run_specific_test()
            elif choice == "6":
                self.list_simulators()
            elif choice == "7":
                self.list_installed_apps()
            elif choice == "8":
                self.uninstall_app()
            elif choice == "9":
                self.log("👋 Goodbye!", Colors.GREEN)
                sys.exit(0)
            else:
                self.log("Invalid choice. Try again.", Colors.RED)

            input(f"\n{Colors.YELLOW}Press Enter to continue...{Colors.END}")

    def run_full_suite(self):
        """Run complete test suite"""
        self.log_section("🎯 Running Full Test Suite")

        # Build
        self.build_app()

        # Boot simulator
        udid = self.boot_simulator()

        # Install
        self.install_app(udid)

        # Test manual launch
        if not self.launch_app_manually(udid):
            self.log("\n❌ Cannot proceed with tests - app won't launch", Colors.RED)
            return

        # Run tests
        exit_code = self.run_maestro_test()

        if exit_code == 0:
            self.log("\n🎉 Full test suite completed successfully!", Colors.GREEN)
        else:
            self.log("\n❌ Test suite failed. Check logs above.", Colors.RED)

    def run_specific_test(self):
        """Run a specific Maestro test"""
        tests = self.list_maestro_tests()

        print(f"\n{Colors.BOLD}Available tests:{Colors.END}")
        for i, test in enumerate(tests, 1):
            print(f"{i}. {test.name}")

        choice = input(f"\n{Colors.CYAN}Choose test (1-{len(tests)}): {Colors.END}").strip()

        try:
            idx = int(choice) - 1
            if 0 <= idx < len(tests):
                self.run_maestro_test(tests[idx])
            else:
                self.log("Invalid choice", Colors.RED)
        except ValueError:
            self.log("Invalid input", Colors.RED)

    def list_simulators(self):
        """List available simulators"""
        self.log_section("📱 Available Simulators")

        simulators = self.get_available_simulators()
        booted_udid = self.get_booted_simulator()

        for sim in simulators:
            status = f"{Colors.GREEN}[BOOTED]{Colors.END}" if sim["udid"] == booted_udid else ""
            print(f"{sim['name']} {status}")
            if self.debug:
                print(f"  UDID: {sim['udid']}")
                print(f"  Runtime: {sim['runtime']}")

    def list_installed_apps(self):
        """List apps installed on booted simulator"""
        self.log_section("📋 Installed Apps")

        udid = self.get_booted_simulator()
        if not udid:
            self.log("❌ No simulator is booted", Colors.RED)
            return

        result = self.run_command(["xcrun", "simctl", "listapps", udid])

        # Check for our app specifically
        if self.bundle_id in result.stdout:
            self.log(f"✅ {self.bundle_id} is installed", Colors.GREEN)
        else:
            self.log(f"❌ {self.bundle_id} is NOT installed", Colors.RED)

        if self.debug:
            print(result.stdout)

    def uninstall_app(self):
        """Uninstall app from booted simulator"""
        self.log_section("🗑️  Uninstalling App")

        udid = self.get_booted_simulator()
        if not udid:
            self.log("❌ No simulator is booted", Colors.RED)
            return

        self.run_command([
            "xcrun", "simctl", "uninstall", udid, self.bundle_id
        ])

        self.log(f"✅ App uninstalled successfully", Colors.GREEN)


def main():
    parser = argparse.ArgumentParser(description="FieldNote UI Test Runner")
    parser.add_argument("--run-all", action="store_true", help="Build, install, and run all tests")
    parser.add_argument("--test", type=str, help="Run specific test file")
    parser.add_argument("--debug", action="store_true", help="Enable debug output")
    parser.add_argument("--build-only", action="store_true", help="Only build the app")
    parser.add_argument("--install-only", action="store_true", help="Only install the app")

    args = parser.parse_args()

    runner = FieldNoteTestRunner(debug=args.debug)

    if args.run_all:
        runner.run_full_suite()
    elif args.build_only:
        runner.build_app()
    elif args.install_only:
        udid = runner.get_booted_simulator() or runner.boot_simulator()
        runner.install_app(udid)
    elif args.test:
        test_path = runner.maestro_dir / args.test
        if not test_path.exists():
            runner.log(f"❌ Test file not found: {test_path}", Colors.RED)
            sys.exit(1)
        runner.run_maestro_test(test_path)
    else:
        # Interactive mode
        runner.interactive_menu()


if __name__ == "__main__":
    main()
