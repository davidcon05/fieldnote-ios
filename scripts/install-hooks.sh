#!/bin/bash

# Install git hooks for the EcoJournal project
# Run this script after cloning the repository to set up pre-push validation

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo "📦 Installing git hooks for EcoJournal..."

# Create pre-push hook
cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash

# Pre-push hook to build the project and catch compilation errors
# This prevents pushing broken code to the remote repository

echo "🔨 Running pre-push hook: Building project..."

# Build the project for iOS Simulator
xcodebuild -scheme EcoJournal -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build 2>&1 | tee /tmp/xcodebuild-prepush.log

BUILD_STATUS=${PIPESTATUS[0]}

if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ Build succeeded! Proceeding with push."
    exit 0
else
    echo ""
    echo "❌ Build failed! Push aborted."
    echo ""
    echo "Compilation errors found:"
    grep "error:" /tmp/xcodebuild-prepush.log | head -10
    echo ""
    echo "Fix the compilation errors before pushing."
    echo "Full build log: /tmp/xcodebuild-prepush.log"
    echo ""
    echo "To skip this check (not recommended), use: git push --no-verify"
    exit 1
fi
EOF

# Make hook executable
chmod +x "$HOOKS_DIR/pre-push"

echo "✅ Git hooks installed successfully!"
echo ""
echo "The pre-push hook will:"
echo "  - Build the project before every push"
echo "  - Prevent pushing if compilation fails"
echo "  - Show compilation errors if the build fails"
echo ""
echo "To bypass the hook (not recommended), use: git push --no-verify"
