# Development Scripts

This directory contains development scripts for the fieldnote project.

## Git Hooks

### Installation

After cloning the repository, run the installation script to set up git hooks:

```bash
./scripts/install-hooks.sh
```

### Pre-Push Hook

The pre-push hook builds the project before allowing a push to the remote repository. This catches compilation errors before they are pushed.

**Features:**
- Automatically builds the project for iOS Simulator
- Prevents pushing if compilation fails
- Shows compilation errors with file paths and line numbers
- Logs full build output to `/tmp/xcodebuild-prepush.log`

**Bypassing the hook:**

If you need to push without building (not recommended), use:

```bash
git push --no-verify
```

**Why this matters:**

This hook prevents broken code from being pushed to the repository, which:
- Keeps CI/CD pipelines green
- Prevents wasted time debugging compilation errors
- Maintains code quality standards
- Catches syntax errors before code review

## Maintenance

If the hooks need to be updated, modify `scripts/install-hooks.sh` and re-run it.
