#!/bin/bash

# Profile Test Performance
# Runs tests and outputs timing for each test to identify slow ones

set -e

SCHEME="EcoJournal"
DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro"
OUTPUT_FILE="/tmp/test-profile-$(date +%Y%m%d-%H%M%S).txt"

echo "🧪 Profiling test performance..."
echo "Output will be saved to: $OUTPUT_FILE"
echo ""

# Run tests with verbose output and timing
xcodebuild test \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -enableCodeCoverage NO \
  2>&1 | tee "$OUTPUT_FILE"

echo ""
echo "📊 Analyzing test times..."
echo ""

# Extract test timing information
echo "=== SLOWEST TESTS (>1 second) ===" | tee -a "$OUTPUT_FILE"
grep "passed (" "$OUTPUT_FILE" | \
  sed -E 's/.*Test case .*'\''(.*)'\'' passed on .* \((.*) seconds\)/\2s - \1/' | \
  awk '{if ($1+0 > 1) print}' | \
  sort -rn | \
  head -20

echo ""
echo "=== TEST SUMMARY BY SUITE ===" | tee -a "$OUTPUT_FILE"
grep "passed (" "$OUTPUT_FILE" | \
  sed -E 's/.*Test case '\''([^\/]+)\/.*'\'' passed on .* \((.*) seconds\)/\1 \2/' | \
  awk '{suite[$1] += $2; count[$1]++} END {for (s in suite) printf "%.2fs (%d tests) - %s\n", suite[s], count[s], s}' | \
  sort -rn

echo ""
echo "Full output saved to: $OUTPUT_FILE"
