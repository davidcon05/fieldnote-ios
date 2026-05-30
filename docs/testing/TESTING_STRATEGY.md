# Testing Strategy

This document outlines our testing approach for EcoJournal, including unit tests, integration tests, and UI test data strategies.

## Test Categories

### Unit Tests (Fast, Mocked)
- **Purpose**: Test business logic in isolation
- **Characteristics**:
  - Use mocks/stubs for external dependencies
  - Run in milliseconds
  - Run on every commit (pre-push hook)
  - No side effects (no disk, network, or keychain access)

### Integration Tests (Slower, Real Services)
- **Purpose**: Verify critical interactions with system APIs
- **Characteristics**:
  - Use real iOS Keychain, file system, or other system services
  - Run slower (seconds)
  - May have side effects
  - Run manually or in CI only (skipped in pre-push hook)

### UI Tests (Slowest, End-to-End)
- **Purpose**: Test user workflows
- **Characteristics**:
  - Launch full app
  - Simulate user interactions
  - Run slowest (minutes)
  - Run manually or nightly in CI

---

## Current Test Distribution

| Test Suite | Total Tests | Type | Uses Real Services? |
|------------|-------------|------|---------------------|
| Models (Journal, Log, Weather) | ~74 | Unit | No |
| ViewModels | ~93 | Unit | No (uses MockKeychainManager) |
| WeatherService | ~11 | Unit | No (uses MockURLSession) |
| AirQualityService | ~10 | Unit | No (uses MockURLSession) |
| **KeychainManager** | **~44** | **Mixed** | **Some - see below** |
| PhotoStorageService | ~10 | Integration | Yes (real file system) |

**Total: ~242 tests**

---

## KeychainManager Testing Strategy

**Problem**: KeychainManager has 44 tests that all hit the real iOS Keychain, making the test suite slow and potentially flaky.

**Solution**: Convert most to unit tests with mocks, keep a few integration tests.

### Tests to Keep as Integration Tests (2-3)

These verify the **critical path** works with real keychain:

1. **`testSavePassword_Success`** - Basic save/retrieve round-trip
   ```swift
   @Test("Save password successfully", .tags(.integration))
   func testSavePassword_Success() async throws {
       // Saves password → retrieves it → verifies format
   }
   ```

2. **`testVerifyPassword_Correct`** - Full verification flow
   ```swift
   @Test("Verify password succeeds with correct password", .tags(.integration))
   func testVerifyPassword_Correct() async throws {
       // Saves password → verifies correct password → hashing works
   }
   ```

3. **`testMultipleJournals`** (Optional) - Isolation between journals
   ```swift
   @Test("Multiple journals can have different passwords", .tags(.integration))
   func testMultipleJournals() async throws {
       // Ensures journal passwords don't interfere with each other
   }
   ```

### Tests to Convert to Unit Tests with Mocks (~41)

All edge cases and error handling:
- Password overwrites
- Case sensitivity
- Special characters (unicode, emojis, etc.)
- Empty passwords
- Very long passwords
- Deletion edge cases
- Error descriptions
- Biometric type checking (pure enum logic)

**Benefits**:
- Tests run 100x faster
- No keychain state contamination
- Can test error conditions easily
- Still have confidence from integration tests

### Implementation TODO

- [ ] Review existing `MockKeychainManager.swift`
- [ ] Enhance mock to support all test scenarios
- [ ] Refactor 41 tests to use mock
- [ ] Tag 2-3 integration tests with `.tags(.integration)`
- [ ] Update pre-push hook to skip `.integration` tests
- [ ] Document mock usage in this file

---

## Fake Data for UI Tests

**Goal**: Create realistic test data for UI testing and screenshots.

### Why Fake Data Matters

1. **Consistent UI Tests**: Same data = reproducible tests
2. **Beautiful Screenshots**: Well-crafted data for App Store
3. **Developer Experience**: Populated app on first launch
4. **Demo Mode**: Show potential features

### Fake Data Strategy

#### Option 1: Test Fixtures (Recommended)
Create JSON fixtures that can be loaded into SwiftData:

```swift
// Tests/Fixtures/sample-journals.json
[
  {
    "id": "fixture-1",
    "name": "Backyard Birds 🦅",
    "theme": "forest",
    "logs": [
      {
        "title": "Red-tailed Hawk Sighting",
        "notes": "Spotted perched on oak tree, 3:45 PM",
        "timestamp": "2025-05-15T15:45:00Z",
        "latitude": 47.6062,
        "longitude": -122.3321,
        "weather": {
          "condition": "Partly Cloudy",
          "temperature": 18.5
        },
        "photoURLs": ["sample-hawk-1.jpg"]
      }
    ]
  }
]
```

#### Option 2: Factory Pattern
Create data factories for tests:

```swift
// Tests/Factories/JournalFactory.swift
struct JournalFactory {
    static func createSampleJournal(
        name: String = "Sample Journal",
        logCount: Int = 5
    ) -> Journal {
        let journal = Journal(name: name)

        for i in 1...logCount {
            let log = Log(
                title: "Sample Log \(i)",
                notes: "This is a sample observation",
                journal: journal
            )
            journal.logs.append(log)
        }

        return journal
    }

    static func createRichJournal() -> Journal {
        // Journal with photos, weather data, locations, etc.
    }
}
```

#### Option 3: Debug Data Injection
Add a debug menu to inject test data:

```swift
#if DEBUG
struct DebugDataInjector {
    static func injectSampleData(into context: ModelContext) {
        // Create 3 journals with various themes
        // Add 10-15 logs per journal
        // Include photos, weather, locations
        // Mix of recent and old entries
    }
}
#endif
```

### Recommended Approach

**For Unit Tests**: Use factories (fast, customizable)
**For UI Tests**: Use fixtures + factories (consistent data)
**For Development**: Debug injection (one-time setup)
**For App Store Screenshots**: Hand-crafted fixtures with beautiful photos

### Sample Data Content Ideas

**Journals**:
- "Backyard Birds 🦅" (10 entries, forest theme)
- "Hiking Trails 🥾" (15 entries, mountain theme)
- "Garden Progress 🌱" (20 entries, meadow theme)

**Logs** should include:
- ✅ Titles (specific species/observations)
- ✅ Detailed notes (2-3 sentences)
- ✅ GPS coordinates (varied locations)
- ✅ Weather data (different conditions)
- ✅ Photos (nature photography)
- ✅ Timestamps (spread over weeks/months)
- ✅ Mix of morning/afternoon/evening entries

### Implementation TODO

- [ ] Create `Tests/Fixtures/` directory
- [ ] Add sample JSON fixtures
- [ ] Create `Tests/Factories/` directory
- [ ] Implement factory patterns
- [ ] Add debug data injection menu
- [ ] Source sample nature photos (royalty-free)
- [ ] Document fixture usage in test setup

---

## Running Tests

### All Tests (Full Suite)
```bash
xcodebuild test -scheme EcoJournal -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### Unit Tests Only (Fast)
```bash
# Skip integration tests
xcodebuild test -scheme EcoJournal -skip-testing:EcoJournalTests/KeychainManagerTests
```

### Specific Test Suite
```bash
xcodebuild test -scheme EcoJournal -only-testing:EcoJournalTests/WeatherServiceTests
```

### Pre-Push Hook
Automatically runs on `git push`:
- Builds the project
- Runs unit tests (skips integration tests)
- Blocks push if tests fail

Location: `.git/hooks/pre-push`

---

## Best Practices

### When Writing Tests

1. **Mock external dependencies** (network, disk, keychain)
2. **Use descriptive test names** - explains what's being tested
3. **Follow Arrange-Act-Assert** pattern
4. **One assertion per test** (generally)
5. **Clean up side effects** (keychain, files)

### When to Use Integration Tests

Only when testing:
- Real keychain interactions
- File system operations
- System framework behavior
- Security-critical code paths

### When to Use Mocks

When testing:
- Business logic
- View model state changes
- Error handling
- Edge cases
- Algorithm correctness

---

## Future Improvements

- [ ] Add UI test suite for critical flows
- [ ] Implement snapshot testing for views
- [ ] Add performance benchmarks
- [ ] Create test coverage reports
- [ ] Automate screenshot generation for App Store

---

## Resources

- [Testing Documentation](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [Swift Testing Framework](https://developer.apple.com/documentation/testing)
- [Writing Testable Code](https://developer.apple.com/videos/play/wwdc2023/10175/)
