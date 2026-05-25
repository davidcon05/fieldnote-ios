# UI Test Parallelization Requirements

## Status: Future Work (Not Implemented)

**Date Created:** 2026-05-24
**Priority:** Low (After UI tests are stable and passing)

## Current State

- UI tests run **sequentially** on a single simulator
- Test plan explicitly disables parallelization: `fieldnoteUITests.xctestplan`
- 37 UI tests across 6 test suites
- Tests take ~5-10 minutes to run sequentially

## Why Parallelization is Disabled

1. **UI tests need simulator focus** - Only one simulator can be in focus at a time
2. **Current test data setup** - Tests create their own data, which can conflict
3. **Stability first** - Need all tests passing reliably before optimizing for speed
4. **Resource usage** - Multiple simulators were launching but only one actually ran tests (waste)

## Requirements for Future Parallelization

### Prerequisites (Must Be Complete First)

- [ ] All UI tests passing reliably (0 flaky tests)
- [ ] Mock data infrastructure implemented (no test data creation in tests)
- [ ] Tests are truly independent (no shared state)
- [ ] CI/CD pipeline established with consistent test runs
- [ ] **GPS/Location mocking** - Currently GPS doesn't work in UI tests, blocking log creation tests (see Disabled Tests section below)

### Technical Requirements

#### 1. Test Data Strategy

**Current (Sequential Only):**
```swift
// Each test creates its own data
func test_feature() {
    DashboardRobot(app: app).tapNewJournal()
    CreateJournalRobot(app: app).enterName("Test").tapCreate()
    // Test actual feature...
}
```

**Required for Parallelization:**
```swift
// Mock data loaded at app launch
app.launchArguments = ["--uitesting", "--mockdata=test-scenario-1"]
app.launch()

// Test assumes data exists
func test_feature() {
    DashboardRobot(app: app)
        .selectJournal("Mock Journal")
        .verifyExists()
}
```

**Implementation Needed:**
- Mock data JSON files per test scenario
- App code to detect `--mockdata` flag and load appropriate fixture
- SwiftData seed/fixture loading mechanism
- Test helper to specify which mock data to load

#### 2. Test Isolation

**Each test must be truly isolated:**
- No shared state between tests
- No assumptions about execution order
- Clean app state for each test (via mock data)
- No side effects that affect other tests

**Test Plan Configuration:**
```json
{
  "defaultOptions" : {
    "parallelizationEnabled" : true,  // Enable after mock data
    "maximumTestExecutionTimeAllowance" : 600
  },
  "testTargets" : [
    {
      "parallelizable" : true,  // Enable per-target
      "target" : {
        "name" : "fieldnoteUITests"
      }
    }
  ]
}
```

#### 3. Simulator Management

**Current:** 1 simulator, sequential execution
**Target:** Multiple simulators, parallel test classes

**Requirements:**
- Xcode Cloud or CI system with multiple macOS runners
- Sufficient macOS resources (8+ cores, 16+ GB RAM per simulator)
- Simulator pool management
- Cleanup between test runs

**Xcodebuild Command:**
```bash
# Future parallel execution
xcodebuild test \
  -scheme fieldnote \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -parallel-testing-enabled YES \
  -parallel-testing-worker-count 4 \
  -maximum-parallel-testing-workers 4
```

#### 4. Test Organization for Parallelization

**Current Structure (Good Foundation):**
```
Dashboard/Tests/DashboardTests.swift (8 tests)
Journal/Tests/JournalTests.swift (9 tests)
Logs/Tests/LogsListTests.swift (6 tests)
Logs/Tests/NewLogTests.swift (8 tests)
Map/Tests/MapTests.swift (4 tests)
```

**Parallelization Strategy:**
- Each test **class** can run in parallel (not individual tests)
- 6 test classes = up to 6 parallel workers
- Distribute by test count for balanced execution

**Optimal Distribution:**
- Worker 1: JournalTests (9 tests)
- Worker 2: DashboardTests (8 tests)
- Worker 3: NewLogTests (8 tests)
- Worker 4: LogsListTests (6 tests)
- Worker 5: MapTests (4 tests)

#### 5. CI/CD Integration

**Required Infrastructure:**
- GitHub Actions with macOS runners (or Xcode Cloud)
- Matrix builds for multiple iOS versions
- Test result reporting
- Failure artifact collection (screenshots, logs)

**Example GitHub Actions (Future):**
```yaml
name: UI Tests (Parallel)

on:
  schedule:
    - cron: '0 2 * * 5,6,0'  # Friday-Sunday only

jobs:
  ui-tests:
    runs-on: macos-14
    strategy:
      matrix:
        test-suite:
          - DashboardTests
          - JournalTests
          - NewLogTests
          - LogsListTests
          - MapTests
      fail-fast: false
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app
      - name: Run ${{ matrix.test-suite }}
        run: |
          xcodebuild test \
            -scheme fieldnote \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
            -only-testing:fieldnoteUITests/${{ matrix.test-suite }}
```

#### 6. Performance Metrics to Track

Before enabling parallelization, establish baseline:

- Total test execution time (sequential)
- Individual test execution times
- Flakiness rate (% of tests that fail intermittently)
- Resource usage (CPU, memory, disk I/O)

**Target Improvements:**
- 3-4x faster execution with 5 parallel workers
- <5% flakiness rate (ideally 0%)
- No increase in resource usage per test

### Mock Data Implementation Plan

#### Phase 1: Infrastructure
1. Create `UITestFixtures/` directory with JSON files
2. Add `MockDataLoader.swift` to handle loading
3. Detect `--mockdata` flag in app launch
4. Load fixture into SwiftData before UI appears

#### Phase 2: Fixtures
1. Create fixtures per test scenario:
   - `empty-dashboard.json` - No journals
   - `single-journal.json` - One journal, no logs
   - `journal-with-logs.json` - Journal with 3 logs
   - `multiple-journals.json` - 3 journals for search tests
   - `map-data.json` - Logs with GPS coordinates

#### Phase 3: Test Migration
1. Update test helpers to load fixtures instead of creating data
2. Remove data creation code from tests
3. Update robots to assume data exists
4. Verify tests still pass sequentially

#### Phase 4: Enable Parallelization
1. Update test plan to enable parallelization
2. Run tests in parallel locally
3. Fix any race conditions or state issues
4. Deploy to CI/CD

### Testing the Parallelization

**Validation Steps:**
1. Run all tests sequentially - baseline time
2. Enable parallelization locally
3. Run all tests in parallel - measure speedup
4. Repeat 10 times to check for flakiness
5. If flakiness <5%, deploy to CI/CD
6. Monitor for 2 weeks before considering stable

### Rollback Plan

If parallelization causes issues:

1. Revert test plan: `"parallelizationEnabled": false`
2. Keep mock data infrastructure (still useful for speed)
3. Document issues encountered
4. Revisit after addressing root causes

## Estimated Effort

**Mock Data Infrastructure:** 2-3 days
**Fixture Creation:** 1 day
**Test Migration:** 2-3 days
**Validation & Tuning:** 2-3 days
**CI/CD Integration:** 1-2 days

**Total:** ~2 weeks of focused work

## Benefits vs. Costs

**Benefits:**
- 3-4x faster test execution
- Faster feedback loop
- More tests can be added without time penalty

**Costs:**
- Mock data maintenance overhead
- More complex test infrastructure
- Potential flakiness if not done carefully
- CI/CD resource costs (multiple simulators)

## Decision: Wait Until...

- [ ] We have >100 UI tests (currently 37)
- [ ] Tests take >15 minutes to run (currently ~5-10 min)
- [ ] We have dedicated QA resources
- [ ] All tests are passing reliably for 1+ month

## Disabled Tests (Awaiting Mock Infrastructure)

The following tests are currently commented out because they require GPS/location services which don't work reliably in UI tests without proper mocking:

**JournalTests:**
- `test_journal_logAppearsInLogsTab_afterCreation` - Creates log, verifies in logs tab
- `test_journal_logAppearsInMapTab_afterCreation` - Creates log, verifies map shows log pin
- `test_journal_switchBetweenAllTabs` - Creates log, switches between all tabs

**LogsListTests:**
- `test_logsList_displaysLog_afterCreation` - Creates and displays single log
- `test_logsList_displaysMultipleLogs` - Creates and displays multiple logs
- `test_logsList_searchFindsMatchingLog` - Creates logs, tests search functionality
- `test_logsList_navigateToLogDetail` - Creates log, navigates to detail
- `test_logsList_navigateToLogDetailAndBack` - Creates log, navigates to detail and back

**MapTests:**
- `test_map_displaysMapView_afterLogCreation` - Creates log, verifies map displays
- `test_map_showsPin_forLogWithLocation` - Creates log, verifies pin on map
- `test_map_displaysMetricsPanel_whenLogsExist` - Creates log, verifies metrics panel

**NewLogTests:**
- `test_newLog_createWithTitleOnly` - Creates log with title only
- `test_newLog_createWithTitleAndNotes` - Creates log with title and notes
- `test_newLog_gpsDataCaptured` - Creates log, verifies GPS data captured
- `test_newLog_weatherDataCaptured` - Creates log, verifies weather data captured

**Root Cause:** Log creation requires GPS coordinates. In UI tests, CoreLocation doesn't provide real location data without:
1. Simulated location via scheme settings (not programmatically accessible)
2. GPX file for location simulation
3. Mock location data injected at app launch

**Solution:** Implement mock data infrastructure that allows tests to launch the app with pre-populated journals and logs, bypassing the need for GPS during test execution.

**Re-enable When:**
- Mock data can be loaded at app launch via launch arguments
- Location services can be mocked/stubbed for testing
- Tests can verify UI with pre-existing data rather than creating it

## References

- Apple WWDC: Testing in Xcode (Parallelization)
- Test plan: `fieldnoteUITests.xctestplan`
- Robot pattern skill: `~/.claude/skills/ui-testing-robot-pattern/`
- Current test structure: `fieldnoteUITests/{Feature}/Tests/`
- Disabled tests:
  - `fieldnoteUITests/Journal/Tests/JournalTests.swift` (lines 84-140) - 3 tests
  - `fieldnoteUITests/Logs/Tests/LogsListTests.swift` (lines 57-120) - 5 tests
  - `fieldnoteUITests/Map/Tests/MapTests.swift` (lines 57-94) - 3 tests
  - `fieldnoteUITests/Logs/Tests/NewLogTests.swift` (lines 55-117) - 4 tests
  - **Total: 15 tests disabled** (awaiting mock infrastructure)
