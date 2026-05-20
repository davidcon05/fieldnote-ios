# Maestro Tests for FieldNote

This directory contains Maestro UI tests for the FieldNote iOS application.

## Prerequisites

1. **Install Maestro CLI:**
   ```bash
   curl -Ls "https://get.maestro.mobile.dev" | bash
   ```

2. **Boot iOS Simulator:**
   ```bash
   xcrun simctl boot "iPhone 15 Pro"
   ```

3. **Build the app:**
   ```bash
   xcodebuild -project fieldnote.xcodeproj -scheme fieldnote -sdk iphonesimulator -configuration Debug
   ```

## Running Tests

### Run all tests:
```bash
maestro test .maestro/
```

### Run single test:
```bash
maestro test .maestro/create-journal.yaml
```

### Run smoke tests only:
```bash
maestro test --include-tags smoke .maestro/
```

### Run with continuous mode (watch for changes):
```bash
maestro test --continuous .maestro/create-journal.yaml
```

## Test Files

- **`create-journal.yaml`** - Smoke test for creating a journal
- **`search-journals.yaml`** - Test search functionality

## Adding New Tests

1. Create a new `.yaml` file in this directory
2. Follow the pattern in existing tests
3. Add appropriate tags for organization
4. Reference the Maestro skill: `/Users/davidcontreras/claude-skills/maestro-mobile-testing/`

## CI/CD

Maestro tests run in GitHub Actions via manual trigger:
- Workflow: `.github/workflows/maestro-tests.yml`
- Trigger: Actions → Maestro UI Tests → Run workflow
- Status: Currently configured for local testing (Cloud integration disabled)

## Troubleshooting

**"No devices available":**
```bash
xcrun simctl list devices
xcrun simctl boot "iPhone 15 Pro"
```

**"App not launching":**
- Verify bundle ID: `com.davidcontreras.fieldnote`
- Check app is built in Debug configuration
- Try: `maestro test --app /path/to/fieldnote.app .maestro/`

**Need help?**
- Maestro Docs: https://docs.maestro.dev/
- Skill: `/Users/davidcontreras/claude-skills/maestro-mobile-testing/maestro-mobile-testing.md`
