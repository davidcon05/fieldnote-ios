# Preview Audit - Complete Analysis

**Date:** 2026-05-10
**Goal:** Ensure 1 preview per state variation for all views

---

## Summary

| Category | Files | Current Previews | Missing States | Status |
|----------|-------|------------------|----------------|--------|
| Components | 8 | 9 | ~15 | ⚠️ Needs Work |
| Screens | 7 | 9 | ~10 | ⚠️ Needs Work |
| **Total** | **15** | **18** | **~25** | **⚠️ 42% Coverage** |

---

## Components (8 files)

### ✅ BottomSheet.swift - GOOD
**Current Previews:** 3
- Enabled button ✅
- Disabled button ✅
- Settings example ✅

**Analysis:** Well covered - shows all button states and example usage.

**Missing:** None

---

### ⚠️ CapturePhotoButton.swift - MISSING STATES
**Current Previews:** 1
- Default state ✅

**State Properties:**
- `@State private var isPressed = false`

**Missing Previews:**
- [ ] Pressed state
- [ ] Disabled state (if applicable)

**Recommendation:**
```swift
#Preview("Default") {
    CapturePhotoButton { }
}

#Preview("Active") {
    // Show button in active/loading state if there is one
}
```

---

### ❌ CardButtonStyle.swift - NO PREVIEWS
**Current Previews:** 0

**Analysis:** This is a ButtonStyle - should have preview showing all states

**Missing Previews:**
- [ ] Normal state
- [ ] Pressed state
- [ ] Disabled state

**Recommendation:**
```swift
#Preview("Normal") {
    Button("Test Button") { }
        .buttonStyle(CardButtonStyle(highlightColor: .blue))
}

#Preview("Pressed") {
    // Show visual representation of pressed state
}
```

---

### ⚠️ GPSTelemetryCard.swift - MISSING STATES
**Current Previews:** 1 (shows 2 cards: with location, loading)

**Props that affect state:**
- `location: CLLocation?` - nil vs populated
- `isLoading: Bool` - true vs false
- `error: String?` - nil vs error
- `onRefresh: (() -> Void)?` - present vs nil

**Current Coverage:**
- With location ✅
- Loading ✅

**Missing Previews:**
- [ ] Error state (with error message)
- [ ] No location, not loading (waiting state)
- [ ] Refreshing state (isLoading while location exists)
- [ ] No refresh button (onRefresh = nil)

**Recommendation:**
```swift
#Preview {
    VStack(spacing: 16) {
        // Existing
        GPSTelemetryCard(location: CLLocation(...), isLoading: false, error: nil, onRefresh: {})
        GPSTelemetryCard(location: nil, isLoading: true, error: nil, onRefresh: {})

        // Add these:
        GPSTelemetryCard(location: nil, isLoading: false, error: "GPS unavailable", onRefresh: {})
        GPSTelemetryCard(location: nil, isLoading: false, error: nil, onRefresh: {}) // Waiting
        GPSTelemetryCard(location: CLLocation(...), isLoading: true, error: nil, onRefresh: {}) // Refreshing
        GPSTelemetryCard(location: CLLocation(...), isLoading: false, error: nil, onRefresh: nil) // No refresh
    }
}
```

---

### ⚠️ JournalSettingsSheet.swift - MISSING STATES
**Current Previews:** 1

**State Properties:** 9 different states
- Password protected vs not
- Delete confirmation showing vs hidden
- Password prompt showing vs hidden
- Various other modal states

**Missing Previews:**
- [ ] Password protected journal
- [ ] Non-password protected journal
- [ ] Delete confirmation alert showing
- [ ] Change password flow

**Recommendation:**
```swift
#Preview("No Password") {
    let journal = Journal(name: "Test")
    return JournalSettingsSheet(journal: .constant(journal), onSave: {}, onDelete: {}, keychainManager: KeychainManager())
}

#Preview("With Password") {
    let journal = Journal(name: "Secure Journal")
    journal.isPasswordProtected = true
    return JournalSettingsSheet(journal: .constant(journal), onSave: {}, onDelete: {}, keychainManager: KeychainManager())
}
```

---

### ⚠️ PasswordPromptSheet.swift - MISSING STATES
**Current Previews:** 1

**State Properties:** 4 states
- Password visible vs hidden
- Error showing vs hidden
- Shaking animation state
- Lockout message

**Missing Previews:**
- [ ] With lockout message (failed attempts)
- [ ] Password visible state
- [ ] Error state (wrong password)

**Recommendation:**
```swift
#Preview("Default") {
    PasswordPromptSheet(
        title: "Enter Password",
        message: "Unlock to continue",
        actionButtonText: "Unlock",
        onSubmit: { _ in true },
        lockoutMessage: nil,
        onBiometricAuth: nil,
        keychainManager: KeychainManager()
    )
}

#Preview("With Error") {
    // Show error state
}

#Preview("Locked Out") {
    PasswordPromptSheet(
        title: "Enter Password",
        message: "Unlock to continue",
        actionButtonText: "Unlock",
        onSubmit: { _ in false },
        lockoutMessage: "Too many attempts. Try again in 5 minutes.",
        onBiometricAuth: nil,
        keychainManager: KeychainManager()
    )
}
```

---

### ✅ RecordMemoCard.swift - ACCEPTABLE
**Current Previews:** 1

**Analysis:** Simple button card, single state preview is sufficient unless recording states are added.

**Missing:** None (for current implementation)

---

### ⚠️ WeatherDataCard.swift - MISSING STATES
**Current Previews:** 1 (shows 2 cards: with data, loading)

**Props that affect state:**
- `weather: Weather?` - nil vs populated
- `location: CLLocation?` - nil vs populated
- `isLoading: Bool`
- `error: String?`
- `onRefresh: (() -> Void)?`

**Missing Previews:**
- [ ] Error state
- [ ] No weather, waiting for location
- [ ] Refreshing state
- [ ] No refresh button (onRefresh = nil)

**Recommendation:**
```swift
#Preview {
    VStack(spacing: 16) {
        // Existing
        WeatherDataCard(weather: mockWeather, location: mockLocation, isLoading: false, error: nil, onRefresh: {})
        WeatherDataCard(weather: nil, location: nil, isLoading: true, error: nil, onRefresh: {})

        // Add these:
        WeatherDataCard(weather: nil, location: mockLocation, isLoading: false, error: "Failed to fetch weather", onRefresh: {})
        WeatherDataCard(weather: nil, location: nil, isLoading: false, error: nil, onRefresh: {}) // Waiting
        WeatherDataCard(weather: mockWeather, location: mockLocation, isLoading: true, error: nil, onRefresh: {}) // Refreshing
        WeatherDataCard(weather: mockWeather, location: mockLocation, isLoading: false, error: nil, onRefresh: nil) // No refresh
    }
}
```

---

## Screens (7 files)

### ✅ DashboardView.swift - GOOD
**Current Previews:** 2
- With journals ✅
- Empty state ✅

**Analysis:** Covers main states well.

**Possible Additions:**
- [ ] Password-protected journals (visual indicator)
- [ ] Loading state (fetching journals)

**Priority:** Low - current coverage is acceptable

---

### ⚠️ JournalContainerView.swift - MINIMAL
**Current Previews:** 1

**Analysis:** Simple wrapper view, but should show edge cases.

**Missing Previews:**
- [ ] Journal with many logs
- [ ] Password-protected journal

**Priority:** Low - mostly a wrapper

---

### ⚠️ JournalTabView.swift - MINIMAL
**Current Previews:** 1

**State Properties:**
- `@State private var selectedTab = 0` (4 tabs total)

**Missing Previews:**
- [ ] Different tab selected (Logs, New Log, Map)

**Recommendation:**
```swift
#Preview("Logs Tab") {
    NavigationStack {
        JournalTabView(journal: mockJournal)
    }
}

#Preview("Map Tab") {
    // Initialize with selectedTab = 2
}
```

**Priority:** Medium

---

### ⚠️ EditLogView.swift - CRITICAL MISSING STATES
**Current Previews:** 1

**State Properties:** 13 different states
- GPS refreshing vs not
- Weather refreshing vs not
- Weather error
- Delete confirmation
- Various alert states

**Missing Previews:**
- [ ] Log with photos (mediaURLs populated)
- [ ] Log with audio memo
- [ ] Log without GPS data
- [ ] Log without weather data
- [ ] Refreshing GPS state
- [ ] Refreshing weather state
- [ ] Weather error state
- [ ] Delete confirmation showing

**Recommendation:**
```swift
#Preview("Complete Log") {
    // Current preview - has everything
}

#Preview("Minimal Log") {
    let log = Log(notes: "Basic observation")
    // No GPS, no weather, no media
}

#Preview("GPS Refreshing") {
    // Show isRefreshingGPS = true
}

#Preview("Weather Error") {
    // Show weatherRefreshError populated
}

#Preview("With Photos") {
    let log = Log(notes: "Photo observation", mediaURLs: [URL(string: "test")!])
}

#Preview("With Audio") {
    let log = Log(notes: "Audio observation", audioMemoURL: URL(string: "test"))
}
```

**Priority:** HIGH - Complex view with many states

---

### ✅ LogsListView.swift - GOOD
**Current Previews:** 2
- Empty state ✅
- With logs ✅

**Possible Additions:**
- [ ] Single log (edge case)
- [ ] Many logs (20+) for scrolling test

**Priority:** Low - current coverage is good

---

### ❌ MapView.swift - CRITICAL MISSING STATES
**Current Previews:** 1

**Missing Previews:**
- [ ] Empty state (no logs with GPS)
- [ ] Single log
- [ ] Multiple logs
- [ ] Dense cluster (50+ logs)
- [ ] Selected pin state
- [ ] Callout showing

**Recommendation:** See `mapview-implementation-plan.md` for detailed previews

**Priority:** HIGH - Will be implemented as part of MapView feature

---

### ⚠️ NewLogView.swift - MISSING STATES
**Current Previews:** 1

**State Properties:** 7 states
- GPS loading vs loaded
- Weather loading vs loaded vs error
- Notes empty vs populated
- Save confirmation

**Missing Previews:**
- [ ] GPS loading state
- [ ] Weather error state
- [ ] Weather loaded state
- [ ] Form filled out (ready to save)

**Recommendation:**
```swift
#Preview("Initial State") {
    // Current - empty form, loading GPS/weather
}

#Preview("GPS Loading") {
    // Location still acquiring
}

#Preview("Weather Error") {
    // GPS loaded but weather failed
}

#Preview("Ready to Save") {
    // All data loaded, notes filled in
}
```

**Priority:** Medium

---

## Style Files (No Previews Needed)

### Theme.swift
**Current Previews:** 0

**Analysis:** Configuration file, no UI components.

**Action:** None needed

---

## Action Plan

### High Priority (Critical for MapView Launch)

1. **MapView.swift** - Add 5 preview states
   - Empty, single, multiple, dense, selected states
   - Part of MapView implementation

2. **EditLogView.swift** - Add 6 preview states
   - Photos, audio, minimal data, GPS refresh, weather error, delete confirmation
   - Validates all editing scenarios

### Medium Priority (Improves Development Experience)

3. **GPSTelemetryCard.swift** - Add 4 preview states
   - Error, waiting, refreshing, no refresh button

4. **WeatherDataCard.swift** - Add 4 preview states
   - Error, waiting, refreshing, no refresh button

5. **NewLogView.swift** - Add 3 preview states
   - GPS loading, weather error, ready to save

6. **JournalTabView.swift** - Add 2 preview states
   - Different tabs selected

### Low Priority (Nice to Have)

7. **CardButtonStyle.swift** - Add 3 preview states
   - Normal, pressed, disabled

8. **CapturePhotoButton.swift** - Add 1 preview state
   - Pressed/active state

9. **PasswordPromptSheet.swift** - Add 2 preview states
   - Error state, locked out state

10. **JournalSettingsSheet.swift** - Add 2 preview states
    - Password protected, no password

---

## Preview Best Practices

### Component Previews
```swift
#Preview {
    VStack(spacing: 20) {
        // State 1: Normal
        ComponentName(prop1: value1, prop2: value2)

        // State 2: Loading
        ComponentName(prop1: value1, isLoading: true)

        // State 3: Error
        ComponentName(prop1: value1, error: "Error message")
    }
    .padding()
}
```

### Screen Previews
```swift
#Preview("Happy Path") {
    NavigationStack {
        ScreenName(data: mockData)
            .modelContainer(previewContainer)
    }
}

#Preview("Empty State") {
    NavigationStack {
        ScreenName(data: emptyData)
            .modelContainer(previewContainer)
    }
}

#Preview("Error State") {
    NavigationStack {
        ScreenName(data: errorData)
            .modelContainer(previewContainer)
    }
}
```

---

## Summary Statistics

**Total Files Reviewed:** 15
**Files with Previews:** 13 (87%)
**Files without Previews:** 2 (13%)

**Current Preview Count:** 18
**Recommended Preview Count:** 43
**Coverage:** 42%

**Files Needing Most Work:**
1. MapView.swift - 5 missing states (HIGH PRIORITY)
2. EditLogView.swift - 6 missing states (HIGH PRIORITY)
3. GPSTelemetryCard.swift - 4 missing states (MEDIUM)
4. WeatherDataCard.swift - 4 missing states (MEDIUM)
5. NewLogView.swift - 3 missing states (MEDIUM)

---

## Next Steps

1. ✅ Review this audit
2. ⏭️ Prioritize which files to add previews to first
3. ⏭️ Implement high-priority previews (MapView, EditLogView)
4. ⏭️ Implement medium-priority previews (Cards, NewLogView)
5. ⏭️ Consider low-priority previews as time permits

**Estimated Work:**
- High Priority: 2-3 hours
- Medium Priority: 2-3 hours
- Low Priority: 1-2 hours
- **Total: 5-8 hours**
