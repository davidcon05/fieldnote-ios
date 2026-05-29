# UI Testing with Robot Pattern - Feasibility Spike

## Critical Questions

### 1. How do we clear data between tests?
### 2. Can we test SwiftData without much effort?
### 3. What gaps in unit test coverage can UI tests fill?
### 4. What tests should we add per feature?
### 5. Should we add a UITest build configuration with mock data?

---

## What We Can Test Easily

### 1. Empty States (✅ Very Easy)
- **Dashboard empty state** - "No Journals Yet"
- **Logs list empty state** - "No Logs Yet"
- **Map empty state** - "No GPS Data"
- All text, buttons, and navigation are straightforward to verify

### 2. Text Input & Navigation (✅ Easy)
- Creating journals
- Searching journals
- Filtering/sorting
- Navigation between screens
- Form validation (empty title error)

### 3. CRUD Operations (✅ Easy)
- Create journal
- Create log (text only)
- Edit log
- Delete log with confirmation dialog
- Password protection flows

### 4. Settings & Configuration (✅ Easy)
- Journal settings
- Password prompts
- Biometric auth prompts (can simulate)
- Filter sheets

## What's Challenging

### 1. Photo/Camera Tests (⚠️ Challenging)

**Problem**: iOS Simulator limitations
- Cannot access real camera
- Photo picker requires mocking
- AsyncImage loading is difficult to time
- Need to inject test images

**Solutions**:
1. **Launch Arguments Approach** (Recommended)
   ```swift
   // In app
   if ProcessInfo.processInfo.arguments.contains("--uitesting") {
       // Use mock photo URLs
       mockPhotoURLs = [Bundle.main.url(forResource: "test-photo", withExtension: "jpg")]
   }
   ```

2. **UI Test Bundles**
   - Include test images in UI test bundle
   - Copy to app container during test setup
   - Reference from file:// URLs

3. **Skip Camera, Test Gallery Flow**
   - Test photo display when photos already exist
   - Test photo deletion
   - Skip actual picker interaction

**Example**:
```swift
// Test showing photos (not capturing)
func test_logWithPhotos_displayCorrectly() {
    app.launchArguments = ["--uitesting", "--with-test-photos"]
    app.launch()

    // Navigate to a log with photos
    // Verify HeroPhotoSection displays
    XCTAssertTrue(app.images["heroPhoto"].exists)
}
```

### 2. Audio Recording (⚠️ Challenging)
- Similar to photos - simulator limitations
- Can test UI state changes (recording button, duration)
- Cannot test actual recording
- Use mock audio files for playback tests

### 3. Location Services (⚠️ Moderate)
- Simulator supports location simulation
- Can use `simctl` to set location
- Or use launch arguments to inject test coordinates

**Solution**:
```swift
// In LocationManager
if ProcessInfo.processInfo.arguments.contains("--mock-location") {
    self.location = CLLocation(latitude: 47.6062, longitude: -122.3321)
    return
}
```

### 4. Weather API (✅ Easy to Mock)
- Use launch arguments to inject mock weather
- Or use dependency injection with mock service

## Robot Pattern Structure

### Recommended Organization

```
EcoJournalUITests/
├── Robots/
│   ├── DashboardRobot.swift
│   ├── JournalRobot.swift
│   ├── NewLogRobot.swift
│   ├── LogDetailRobot.swift
│   ├── LogsListRobot.swift
│   └── MapRobot.swift
├── Screens/
│   └── (Page Object Models if needed)
├── Helpers/
│   ├── XCUIElement+Extensions.swift
│   └── TestHelpers.swift
└── Tests/
    ├── DashboardTests.swift
    ├── JournalCreationTests.swift
    ├── LogCreationTests.swift
    └── SearchTests.swift
```

### Example Robot Pattern

```swift
// DashboardRobot.swift
final class DashboardRobot {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Actions

    @discardableResult
    func tapNewJournal() -> Self {
        app.buttons["New Journal"].tap()
        return self
    }

    @discardableResult
    func searchFor(_ text: String) -> Self {
        let searchField = app.textFields["Search Journals..."]
        searchField.tap()
        searchField.typeText(text)
        return self
    }

    @discardableResult
    func selectJournal(named name: String) -> JournalRobot {
        app.staticTexts[name].tap()
        return JournalRobot(app: app)
    }

    // MARK: - Verifications

    @discardableResult
    func verifyEmptyState() -> Self {
        XCTAssertTrue(app.staticTexts["No Journals Yet"].exists)
        XCTAssertTrue(app.staticTexts["Start by adding a new journal"].exists)
        return self
    }

    @discardableResult
    func verifyJournalExists(named name: String) -> Self {
        XCTAssertTrue(app.staticTexts[name].exists)
        return self
    }

    @discardableResult
    func verifyJournalCount(_ count: Int) -> Self {
        let journals = app.staticTexts.matching(identifier: "journalCard")
        XCTAssertEqual(journals.count, count)
        return self
    }
}

// Usage in tests
func testCreateJournal() {
    DashboardRobot(app: app)
        .verifyEmptyState()
        .tapNewJournal()

    CreateJournalRobot(app: app)
        .enterName("Test Journal")
        .tapCreate()

    DashboardRobot(app: app)
        .verifyJournalExists(named: "Test Journal")
}
```

## Test Coverage Recommendations

### High Priority (Easy + High Value)
1. ✅ Dashboard empty state
2. ✅ Create journal flow
3. ✅ Search journals
4. ✅ Navigate to journal
5. ✅ Logs list empty state
6. ✅ Create log (text-only fields)
7. ✅ Password protection flows
8. ✅ Delete journal with confirmation

### Medium Priority (Moderate Effort)
1. ⚠️ Edit log flow
2. ⚠️ Filter/sort logs
3. ⚠️ Map view navigation
4. ⚠️ Display logs with existing photos (mock data)
5. ⚠️ Location display (with mocked coordinates)

### Low Priority (High Effort, Low ROI)
1. ❌ Camera capture flow (simulator limitation)
2. ❌ Photo picker selection (difficult to automate)
3. ❌ Audio recording (simulator limitation)
4. ❌ Biometric auth (requires manual interaction)
5. ❌ Real-time weather fetching (external dependency)

## Implementation Plan

### Phase 1: Foundation (Week 1)
- Set up robot pattern structure
- Create base robots for main screens
- Add launch argument handling for test mode
- Implement 5-10 core tests (empty states, creation flows)

### Phase 2: Core Flows (Week 2)
- Navigation tests
- CRUD operation tests
- Search/filter tests
- Password protection tests

### Phase 3: Advanced Features (Week 3)
- Tests with mocked photos (display only)
- Tests with mocked location
- Tests with mocked weather
- Edge cases and error handling

### Phase 4: Maintenance
- Add new tests for new features
- Keep tests aligned with feature packages
- Run nightly to catch regressions

## Alternatives Considered

### 1. Maestro (Current approach)
**Pros**:
- Simple, readable YAML syntax (no code required)
- Cross-platform (iOS, Android, Web)
- Built-in flakiness tolerance and smart waiting
- No compilation needed (instant feedback)
- Open-source (Apache 2.0)
- GitHub Actions integration (official support)

**Cons**:
- Less IDE integration, harder to debug (no Xcode debugger/breakpoints)
- No reusable code for navigation/assertions (YAML scripts vs. native code libraries)
- Cannot leverage language features (enums, protocols, type-safe helpers)
- Limited abstraction capabilities compared to Robot Pattern
- Third-party tool (not Apple's official solution)

### 2. XCUITest + Robot Pattern (Recommended)
**Pros**: Native, great IDE support, debuggable, type-safe
**Cons**: iOS-only, more verbose

### 3. Empirical Testing Results (EcoJournal App)

We ran identical UI tests on EcoJournal using both frameworks to compare real-world performance and reliability.

**Test Suite:** 3 tests (dashboard empty state, create journal, search journals)

#### Local Performance (Mac)
| Framework | Avg Time | Range | Variance | Success Rate |
|-----------|----------|-------|----------|--------------|
| **XCUITest** | **22.2s** | 21.9-22.7s | 0.8s | 100% (15/15) |
| **Maestro** | **37.4s** | 34-41s | 7s | 100% (5/5) |

**Key Finding:** XCUITest is **40% faster** locally with **8.7x lower variance** (more consistent).

#### CI Performance (GitHub Actions)
| Framework | Build Time | Test Time | Total Time | Success Rate |
|-----------|-----------|-----------|------------|--------------|
| **XCUITest** | 8+ min | ~22s | ~9 min | 100% (15/15) |
| **Maestro** | 4-5 min | ~77s | ~6-7 min | **60% (3/5)** |

**Key Findings:**
- **XCUITest:** Higher build overhead (compilation), but 100% reliable
- **Maestro:** Faster total time when successful, but **flaky in CI** (40% failure rate)
- **Maestro Flakiness:** App crashes in `dashboard-empty-state` and `search-journals` tests
- **XCUITest:** 2x faster test execution even in CI (22s vs 77s)

#### Detailed Timing Breakdown (Local - Single Run)
**XCUITest:**
- `test_dashboard_showsEmptyState`: 6.5s
- `test_createJournal_success`: 8.2s
- `test_searchJournals_success`: 7.5s
- **Total:** 22.2s

**Maestro:**
- `dashboard-empty-state.yaml`: 5-7s
- `create-journal.yaml`: 13-18s
- `search-journals.yaml`: 16-19s
- **Total:** 34-41s

#### Summary
- **Speed:** XCUITest 40% faster locally, 2x faster in CI
- **Reliability:** XCUITest 100% vs Maestro 60% (CI)
- **Consistency:** XCUITest has 8.7x lower variance (more predictable)
- **CI Overhead:** Maestro has faster build (4-5 min vs 8+ min) but unreliable tests
- **Trade-off:** Maestro's faster setup time is offset by flakiness and slower test execution

**Detailed Documentation:**
- Full comparison: `/mobile-automation/docs/maestro-vs-xcuitest-comparison.md`
- Performance baseline: `/mobile-automation/docs/maestro-performance-baseline.md`

### 4. Appium
**Pros**: Cross-platform
**Cons**: Setup complexity, slower, less reliable

## Recommendation

✅ **Proceed with XCUITest + Robot Pattern**

**Rationale**:
1. Already have XCUITest infrastructure
2. Robot pattern makes tests maintainable and readable
3. Can test 80% of features easily
4. Photo/camera limitations exist with ALL frameworks on simulator
5. Native framework = best performance and reliability
6. Aligns with feature package structure

**Photo Strategy**:
- Use launch arguments to inject mock photos
- Test photo display, not photo capture
- Run camera tests manually on device (not in CI)
- Focus automated tests on logic, not device capabilities

## Next Steps

1. ✅ Set up nightly UI tests (Done)
2. ✅ Set up unit tests on push (Done)
3. ✅ Add pre-push hook with tests (Done)
4. 📝 Create robot pattern base classes
5. 📝 Implement 5 core test scenarios
6. 📝 Add mock data injection via launch arguments
7. 📝 Document robot pattern for team

## Conclusion

UI testing with robot pattern is **highly feasible** for EcoJournal. We can achieve ~80% test coverage without dealing with simulator limitations. The remaining 20% (camera, audio) can be tested manually or on physical devices.

The robot pattern will keep tests maintainable as the app grows and aligns well with the feature package structure.
