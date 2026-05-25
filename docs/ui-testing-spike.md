# UI Testing Feasibility Spike

## Question 1: How do we clear data between tests?

### Problem
SwiftData persists to disk. Tests contaminate each other.

### Solutions

#### Option A: Launch Arguments (Recommended)
```swift
// In App
if ProcessInfo.processInfo.arguments.contains("--uitesting") {
    // Use in-memory only storage
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try ModelContainer(for: Journal.self, Log.self, configurations: config)
}
```

**Pros**: Clean slate every launch, no filesystem cleanup needed
**Cons**: None really

#### Option B: Delete Container on Launch
```swift
if ProcessInfo.processInfo.arguments.contains("--uitesting") {
    let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
    try? FileManager.default.removeItem(at: storeURL)
}
```

**Pros**: Tests real persistence layer
**Cons**: Slower, can fail, race conditions

**Verdict**: Use Option A (in-memory). Fast, reliable, no cleanup needed.

---

## Question 2: Can we test SwiftData without much effort?

### Current State
- Unit tests use `ModelConfiguration(isStoredInMemoryOnly: true)` ✅
- UI tests would use same approach ✅

### What works easily:
- ✅ CRUD operations (create journal, create log, delete)
- ✅ Relationships (journal → logs)
- ✅ Queries (filtered logs, sorted journals)
- ✅ Empty states

### What's hard:
- ❌ Migration testing (need real files)
- ❌ iCloud sync (external dependency)
- ❌ Concurrent writes (need multi-process tests)

**Verdict**: Yes, SwiftData testing is straightforward with in-memory storage.

---

## Question 3: What gaps in unit test coverage can UI tests fill?

### Current Unit Test Coverage (Good)
- ✅ ViewModels (DashboardViewModel, NewLogViewModel, etc.)
- ✅ Services (WeatherService, KeychainManager, PhotoStorage)
- ✅ Models (Journal, Log, Weather)
- ✅ Business logic

### Gaps UI Tests Fill (Critical)

#### 1. **Integration Testing**
Unit tests mock dependencies. UI tests use real stack.

**Example**: Creating a journal
- Unit test: Mocks ModelContext, verifies ViewModel called insert()
- UI test: Actually saves to SwiftData, verifies it appears in list

#### 2. **Navigation Flows**
Not tested in unit tests at all.

**Examples**:
- Dashboard → Journal → Logs → LogDetail
- Create journal → Navigate to it → Create log
- Back button behavior
- Tab switching

#### 3. **User Input Validation**
Unit tests check ViewModel.isValid, but not the actual UI behavior.

**Examples**:
- Create button disabled when title empty
- Error messages displayed
- TextField validation

#### 4. **State Restoration**
Not tested in unit tests.

**Examples**:
- App backgrounded while creating log
- Return from settings
- Deep linking

#### 5. **Accessibility**
Can verify VoiceOver labels, button states, etc.

### What UI Tests Should NOT Test
- ❌ Complex business logic (unit tests do this better)
- ❌ Edge cases in calculations (unit tests)
- ❌ Mock service responses (unit tests)

**Verdict**: UI tests fill integration, navigation, and real-world flow gaps that unit tests can't cover.

---

## Question 4: What tests should we add per feature?

### Feature: Dashboard
**Unit Tests** (Already have):
- DashboardViewModel creates journal
- DashboardViewModel filters journals
- Password verification logic

**UI Tests** (Add):
- [ ] Empty state displays correctly
- [ ] Create journal flow end-to-end
- [ ] Search filters journal list
- [ ] Navigate into journal
- [ ] Delete journal with confirmation
- [ ] Password protected journal shows lock icon

**Estimated**: 6 tests, ~30 min to write

---

### Feature: Journal / Logs List
**Unit Tests** (Already have):
- NewLogViewModel validation
- NewLogViewModel saves log with weather

**UI Tests** (Add):
- [ ] Empty logs state
- [ ] Create log with title only
- [ ] Navigate to log detail
- [ ] Search/filter logs
- [ ] Delete log

**Estimated**: 5 tests, ~25 min

---

### Feature: Log Detail
**Unit Tests** (Already have):
- None currently (this is a gap!)

**UI Tests** (Add):
- [ ] Display log title, notes, timestamp
- [ ] Display weather data
- [ ] Display GPS coordinates
- [ ] Navigate to edit
- [ ] Delete log confirmation

**Estimated**: 5 tests, ~25 min

---

### Feature: Map
**Unit Tests** (Already have):
- None (View-only feature)

**UI Tests** (Add):
- [ ] Empty state when no GPS logs
- [ ] Displays pins for logs with GPS
- [ ] Tap pin shows callout
- [ ] Callout has correct info
- [ ] Navigate to log detail from callout

**Estimated**: 5 tests, ~25 min

---

### Feature: Settings / Password Protection
**Unit Tests** (Already have):
- KeychainManager tests
- DashboardViewModelPasswordTests

**UI Tests** (Add):
- [ ] Open journal settings
- [ ] Enable password protection
- [ ] Password prompt appears
- [ ] Correct password unlocks journal
- [ ] Wrong password shows error
- [ ] Disable password protection

**Estimated**: 6 tests, ~30 min

---

### Total New Tests Needed
- Dashboard: 6 tests
- Logs: 5 tests
- Log Detail: 5 tests
- Map: 5 tests
- Settings: 6 tests

**Total**: ~27 UI tests, ~2-3 hours to implement with robot pattern

---

## Question 5: Should we add a UITest build configuration?

### Current Build Configurations
- Debug (has API keys, debug symbols)
- Release (optimized, no debug symbols)

### Proposed: UITest Configuration

#### Benefits
1. **Mock Data Injection**
   ```swift
   #if UITEST
   let weatherService = MockWeatherService()
   let locationManager = MockLocationManager()
   #else
   let weatherService = WeatherService(apiKey: apiKey)
   let locationManager = LocationManager()
   #endif
   ```

2. **Faster Tests**
   - No real API calls
   - Predictable data
   - No network delays

3. **Deterministic**
   - Weather always same
   - Location always same
   - Photos pre-loaded

4. **More Coverage**
   - Can test photo display (inject test images)
   - Can test weather display (mock data)
   - Can test error states (mock failures)

#### Drawbacks
1. **Maintenance**: Another configuration to maintain
2. **Not testing real integrations**: Need some tests with real services
3. **Configuration drift**: UITEST config might diverge from Debug

### Alternative: Launch Arguments (Simpler)

Instead of new config, use launch arguments:

```swift
// In App
if ProcessInfo.processInfo.arguments.contains("--mock-weather") {
    weatherService = MockWeatherService()
}

if ProcessInfo.processInfo.arguments.contains("--mock-location") {
    locationManager = MockLocationManager()
}

if ProcessInfo.processInfo.arguments.contains("--with-test-photos") {
    // Inject test photos
}
```

Then in tests:
```swift
app.launchArguments = ["--uitesting", "--mock-weather", "--mock-location"]
```

**Pros**:
- No new build config
- Granular control per test
- Can mix real + mock services

**Cons**:
- Scattered throughout codebase
- Harder to see what's mocked

### Recommendation

**Phase 1**: Use launch arguments for now
- Simpler
- Good enough for 80% of tests
- Can add UITEST config later if needed

**Phase 2** (if tests become flaky/slow): Add UITEST configuration
- When we have 50+ UI tests
- When network flakiness causes issues
- When we need fully deterministic tests for CI

---

## Summary

### Answers

1. **Data Clearing**: Use `ModelConfiguration(isStoredInMemoryOnly: true)` via launch argument
2. **SwiftData Testing**: Yes, straightforward with in-memory storage
3. **Coverage Gaps**: Navigation, integration, real flows, state restoration
4. **Tests Per Feature**: ~27 new tests total, grouped by feature
5. **UITest Config**: Start with launch arguments, add config if needed later

### Recommendation

✅ **Proceed with UI tests using robot pattern**

**Immediate actions**:
1. Add `--uitesting` launch argument handling for in-memory storage
2. Implement robot pattern for 3 core features (Dashboard, Logs, Log Detail)
3. Write ~15 initial tests covering happy paths
4. Run nightly (already configured)

**Deferred**:
- UITEST build configuration (only if tests become flaky)
- Photo/camera testing (simulator limitations, low ROI)
- Complex edge cases (unit tests handle these better)

**Timeline**: 1 week for Phase 1 (core tests), 1-2 weeks for full coverage
