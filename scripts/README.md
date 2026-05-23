# FieldNote Scripts

Utility scripts for building, testing, and managing the FieldNote app.

## fn-uitest.py

A unified UI test runner that simplifies running Maestro tests locally.

### Quick Start

```bash
# Interactive menu (easiest)
./scripts/fn-uitest.py

# Run everything automatically
./scripts/fn-uitest.py --run-all

# Run specific test
./scripts/fn-uitest.py --test dashboard-empty-state.yaml

# Debug mode (verbose output)
./scripts/fn-uitest.py --debug --run-all
```

### What it does

The script handles all the tedious steps:
1. ✅ Builds the app with xcodebuild
2. ✅ Finds/boots an available simulator
3. ✅ Installs the app on the simulator
4. ✅ Runs Maestro tests
5. ✅ Verifies app installation

### Interactive Menu

```
1. 🚀 Run full test suite (build + install + test all)
2. 🔨 Build app only
3. 📱 Install app only
4. 🧪 Run Maestro tests only
5. 📝 Run specific test
6. 🔍 List available simulators
7. 📋 List installed apps on booted simulator
8. 🗑️  Uninstall app from simulator
9. ❌ Exit
```

### Command Line Options

```bash
--run-all          # Build, install, and run all tests
--build-only       # Only build the app
--install-only     # Only install the app
--test <file>      # Run specific test file
--debug            # Enable verbose debug output
```

### Examples

```bash
# Full workflow in one command
./scripts/fn-uitest.py --run-all

# Build, then run specific test with debug output
./scripts/fn-uitest.py --build-only
./scripts/fn-uitest.py --test create-journal.yaml --debug

# Quick iteration: just re-run tests (assumes already built/installed)
./scripts/fn-uitest.py --test dashboard-empty-state.yaml
```

### Requirements

- Python 3.6+
- Xcode Command Line Tools
- Maestro CLI installed

### Troubleshooting

**"No simulators available"**
- Open Xcode → Settings → Platforms
- Download iOS simulator runtimes

**"App not installed"**
- Use option 7 in interactive menu to verify
- Try rebuilding with option 2

**"Maestro command not found"**
```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
export PATH="$HOME/.maestro/bin:$PATH"
```
