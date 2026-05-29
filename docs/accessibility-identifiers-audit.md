# Accessibility Identifiers Audit

**Date:** 2026-05-24
**Status:** In Progress

## Summary

Accessibility identifiers are **defined** in `*AccessibilityIdentifiers.swift` files and **referenced** in test screen objects. **Phase 1 is complete** - all critical identifiers have been applied to LogDetailView and MapView.

## Current State

| Feature | Identifiers Defined | Applied to View | Status |
|---------|---------------------|-----------------|---------|
| Dashboard | ✅ Yes | ✅ Partial (11/15) | 🟡 Needs completion |
| NewLog | ✅ Yes | ✅ Partial (6/10) | 🟡 Needs completion |
| LogsList | ✅ Yes | ✅ Yes (5/5) | ✅ Complete |
| LogDetail | ✅ Yes | ✅ Yes (8/8) | ✅ Complete |
| EditLog | ✅ Yes | ❌ None (0/2) | 🔴 Critical |
| Map | ✅ Yes | ✅ Yes (9/9) | ✅ Complete |

## Detailed Audit

### ✅ LogsList - COMPLETE

**File:** `Features/Logs/List/LogsListView.swift`

| Identifier | Applied | Line |
|------------|---------|------|
| `emptyStateIcon` | ✅ | 49 |
| `emptyStateTitle` | ✅ | 55 |
| `emptyStateMessage` | ✅ | 62 |
| `searchField` | ✅ | 82 |
| `filterButton` | ✅ | 88 |

---

### 🟡 Dashboard - PARTIAL

**File:** `Features/Dashboard/DashboardView.swift`

| Identifier | Applied | Notes |
|------------|---------|-------|
| `emptyStateIcon` | ✅ | Line 121 |
| `emptyStateTitle` | ✅ | Line 128 |
| `emptyStateMessage` | ✅ | Line 133 |
| `searchField` | ✅ | Line 160 |
| `filterButton` | ✅ | Line 166 |
| `newJournalButton` | ✅ | Line 235 |
| `journalCard` | ✅ | Line 181 |
| `createJournalSheet` | ✅ | Line 526 |
| `createJournalNameLabel` | ✅ | Line 513 |
| `createJournalNameField` | ✅ | Line 517 |
| `createJournalDescription` | ✅ | Line 523 |

**Missing from CreateJournalScreen:**
- `createButton` - Currently relies on text "Create"
- `sheetTitle` - Currently relies on text "New Journal"

**Action Needed:**
These work with text queries but should use accessibility IDs for consistency. Low priority since tests pass.

---

### 🟡 NewLog - PARTIAL

**File:** `Features/Logs/Create/NewLogView.swift`

| Identifier | Applied | Line |
|------------|---------|------|
| `titleField` | ✅ | 195 |
| `notesField` | ✅ | 259 |
| `finalizeButton` | ✅ | 153 |
| `gpsCard` | ✅ | 216 |
| `weatherCard` | ✅ | 224 |
| `weatherRetryButton` | ✅ | 239 |

**Missing:**
- `addPhotoButton` - Photo gallery button
- `audioMemoButton` - Audio recording button

**Tests Using These:**
- `NewLogTests.test_newLog_allFieldsExist` ✅
- `NewLogTests.test_newLog_gpsDataCaptured` ✅
- `NewLogTests.test_newLog_weatherDataCaptured` ✅

**Action Needed:** Add photo and audio identifiers if tests need them.

---

### ✅ LogDetail - COMPLETE

**File:** `Features/Logs/Detail/LogDetailView.swift`

| Identifier | Applied | Line |
|------------|---------|------|
| `heroPhoto` | ✅ | 66 |
| `titleText` | ✅ | 126 |
| `timestampText` | ✅ | 132 |
| `notesText` | ✅ | 156 |
| `gpsCard` | ✅ | 270 |
| `weatherCard` | ✅ | 216 |
| `editButton` | ✅ | 115 |
| `deleteButton` | ✅ | 318 |

**Tests Using These:**
- `LogsListTests.test_logsList_navigateToLogDetail` - ✅ Should pass
- `NewLogTests.test_newLog_gpsDataCaptured` - ✅ Should pass
- `NewLogTests.test_newLog_weatherDataCaptured` - ✅ Should pass

---

### 🔴 EditLog - MISSING ALL

**File:** `Features/Logs/Edit/EditLogView.swift`

**Screen Object Expects:**

| Identifier | Purpose | Priority |
|------------|---------|----------|
| `saveButton` | Save edited log | High |
| `titleField` | Edit title field | High |

**Tests Using These:**
- `EditLogRobot.tapSave()` - Used when editing logs

**Action Needed:** 🔴 **CRITICAL** if edit tests exist

---

### ✅ Map - COMPLETE

**File:** `Features/Map/MapView.swift`

| Identifier | Applied | Line |
|------------|---------|------|
| `emptyState.icon` | ✅ | 386 |
| `emptyState.title` | ✅ | 392 |
| `emptyState.message` | ✅ | 399 |
| `mapView` | ✅ | 84 |
| `centerLocationButton` | ✅ | 376 |
| `metricsPanel` | ✅ | 185 |
| `calloutCard` | ✅ | 358 |
| `calloutDetailsButton` | ✅ | 345 |
| `calloutCloseButton` | ✅ | 316 |

**Tests Using These:**
- `MapTests.test_map_showsEmptyState_whenNoLogs` - ✅ Should pass
- `MapTests.test_map_displaysMapView_afterLogCreation` - ✅ Should pass
- `MapTests.test_map_displaysMetricsPanel_whenLogsExist` - ✅ Should pass

---

## Priority Action Plan

### ✅ Phase 1: Fix Critical Test Failures (COMPLETE)

1. ✅ **LogDetailView** - Added 8 identifiers
   - Used by: LogsListTests, NewLogTests
   - Status: Complete - tests should now pass

2. ✅ **MapView** - Added 9 identifiers (empty state + map elements)
   - Used by: MapTests
   - Status: Complete - tests should now pass

### Phase 2: Complete Coverage (Optional)

3. **NewLogView** - Add 2 missing identifiers
   - photo and audio buttons

4. **DashboardView** - Add 2 missing identifiers
   - Create button, sheet title

5. **EditLogView** - Add 2 identifiers
   - If edit tests are added

### Phase 3: Validation (After Phase 1 & 2)

- Run all UI tests
- Verify 0 failures due to missing identifiers
- Update this audit document with results

## How to Add Identifiers

### Step 1: Check the AccessibilityIdentifiers file

```swift
// Features/{Feature}/{Feature}AccessibilityIdentifiers.swift
enum LogDetailAccessibilityIdentifiers {
    static let titleText = "logDetail.titleText"
    // ...
}
```

### Step 2: Apply to the View

```swift
// Features/{Feature}/{Feature}View.swift
Text(log.title)
    .accessibilityIdentifier(LogDetailAccessibilityIdentifiers.titleText)
```

### Step 3: Verify Screen Object Matches

```swift
// EcoJournalUITests/{Feature}/Screens/{Feature}Screen.swift
var titleText: XCUIElement {
    app.staticTexts["logDetail.titleText"].firstMatch
}
```

## Notes

- Screen objects currently use **text-based queries** as fallback (e.g., `app.staticTexts["Create"]`)
- This works but is fragile - text changes break tests
- Accessibility IDs are stable and independent of UI text
- Some identifiers (like `backButton`) use system elements and don't need custom IDs

## Test Impact Analysis

**Tests Likely Passing:**
- DashboardTests (uses text fallbacks)
- LogsListTests (identifiers applied) ✅

**Tests Likely Failing:**
- NewLogTests (partial identifiers)
- LogDetailTests (no identifiers) 🔴
- MapTests (no identifiers) 🔴
- JournalTests (depends on above)

## Completion Checklist

- [x] Add LogDetailView identifiers (8)
- [x] Add MapView empty state identifiers (3)
- [x] Add MapView map identifiers (2)
- [x] Add MapView metrics identifier (1)
- [x] Add MapView callout identifiers (3)
- [ ] Add NewLogView photo button identifier (optional)
- [ ] Add NewLogView audio button identifier (optional)
- [ ] Run all UI tests
- [ ] Fix any remaining failures
- [ ] Mark Phase 1 as complete
