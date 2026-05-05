# FieldNote Architecture

## Terminology

| Term | Definition | Example |
|------|------------|---------|
| **Journal** | Top-level container for related observations | "Soil Samples 2026", "Tree Survey - Oak Ridge" |
| **Log/Entry** | Individual field observation with GPS, weather, photos, notes | "Red oak sample taken at 2:15 PM" |
| **Tab** | Bottom navigation tab (Logs, New Log, Map) | User taps "New Log" to create entry |

**User mental model:** "I'm opening my Soil Samples journal to add a new log about this tree"

---

## App Navigation Structure

### Tab Names (Semantically Clear)

| Tab Position | Name | What User Does | Icon |
|--------------|------|----------------|------|
| 1 (left) | **Logs** | Views list of past log entries | `book` or `list.bullet` |
| 2 (center) | **New Log** | Creates new entry (voice, text, camera, auto GPS/weather) | `plus.circle` |
| 3 (right) | **Map** | Views log locations on map | `map` |

**Why these names:**
- "Logs" = viewing past entries (matches "New Log" terminology)
- "New Log" = action-oriented, field terminology wife uses
- "Map" = universally understood, simple

**Why this order:**
- Most common: "What did I log yesterday?" (Logs = leftmost)
- Primary field action: "Log this now" (New Log = center, easy thumb reach)
- Secondary: "Where was that sample?" (Map = rightmost)

---

### Navigation Flow

```
App Launch
    ↓
DashboardView (Journal Selection)
    ├─ Tap "Create Journal" → Create new journal
    └─ Tap journal → Navigate to JournalTabView
                            ↓
                    ┌───────────────────┐
                    │   Top Nav Bar     │
                    │ "< Journals" Back │  ← Returns to DashboardView
                    └───────────────────┘
                    ┌───────────────────┐
                    │  Bottom Tab Bar   │
                    ├───────────────────┤
                    │ Tab 1: Logs       │ → LogsView
                    │ Tab 2: New Log    │ → NewLogView
                    │ Tab 3: Map        │ → MapView
                    └───────────────────┘
```

**Why no 4th "Switch Journal" tab?**
- Standard iOS pattern: use "< Journals" back button
- Saves valuable tab slot
- Muscle memory: users expect back button in top-left

---

## File Structure

### Models/ - Data Layer

| File | Purpose | Key Properties | Why @Model or Codable? |
|------|---------|---------------|----------------------|
| `Journal.swift` | Journal entity (SwiftData) | `id`, `name`, `createdDate`, `entries: [Entry]` | @Model = persisted to database |
| `Entry.swift` | Log entry entity (SwiftData) | `id`, `timestamp`, `lat/lon`, `altitude`, `weather`, `notes`, `photoURLs` | @Model = persisted, relationship to Journal |
| `Weather.swift` | Weather data struct | `condition`, `temperature`, `humidity`, `windSpeed`, `icon` | Codable = stored as JSON in Entry, not separate table |

**Why SwiftData?**
- ✅ Native iOS persistence (zero config)
- ✅ Automatic relationships (Journal → Entries)
- ✅ iCloud sync ready (just toggle one switch)
- ✅ Observable changes (SwiftUI auto-updates)
- ❌ Alternatives: Core Data (too verbose), Firebase (needs internet), UserDefaults (can't handle relationships)

**Why Weather as struct, not @Model?**
- Fetched from API, stored inside Entry as JSON
- Don't need queries like "find all sunny logs"
- Reduces database complexity

---

### Views/ - UI Layer

| File | Screen | Responsibility | Why Separate? |
|------|--------|---------------|---------------|
| **Top-Level Navigation** |
| `DashboardView.swift` | Journal selection | List journals, create journal, select → JournalTabView | Entry point, can't skip |
| `JournalTabView.swift` | Tab container | 3 tabs + top nav "< Journals" back | Keeps nav stack clean |
| **Tab 1: Logs** |
| `LogsView.swift` | List of log entries | Query logs from SwiftData, show chronologically | Core feature: view past work |
| `LogCardView.swift` | Log preview card | Photo thumbnail, date, GPS, weather icon, first line | Reusable component |
| `LogDetailView.swift` | Full log details | All fields (GPS, weather, photos, notes) | Read-only detail view |
| **Tab 2: New Log** |
| `NewLogView.swift` | Create log form | Auto GPS/weather, photo capture, notes, save | Core feature: field data entry |
| **Tab 3: Map** |
| `MapView.swift` | Map with pins | Show logs on Apple Maps, tap → LogDetailView | Requested feature: spatial view |
| **Supporting** |
| `EmptyStateView.swift` | No logs yet | "Add first log" CTA | Reusable pattern |

**Why separate views?**
- **Reusability:** `LogCardView` used in LogsView AND potentially search results later
- **Maintainability:** Change map provider? Only touch MapView.swift
- **Clarity:** Each file = one responsibility

**Could we combine files?**
- ✅ Yes: Inline EmptyStateView into LogsView (small, only used once)
- ❌ No: Don't combine NewLogView + LogsView (different purposes, would be messy)

---

### Services/ - Business Logic Layer

| File | Purpose | Used By | Why Not in View? |
|------|---------|---------|-----------------|
| `LocationManager.swift` | CoreLocation wrapper, GPS + altitude | NewLogView, MapView | Views shouldn't manage CLLocationManager lifecycle |
| `WeatherService.swift` | OpenWeatherMap API client | NewLogView | Can mock for testing, reusable if we add weather forecasts later |
| `CameraManager.swift` | Camera + photo library | NewLogView | Complex UIKit bridging, keep out of SwiftUI |

**Why separate services?**

```swift
// ❌ BAD: GPS logic in view
struct NewLogView: View {
    var body: some View {
        Button("Get GPS") {
            let manager = CLLocationManager() // View managing CoreLocation
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            // Who deallocates? How to mock for testing?
        }
    }
}

// ✅ GOOD: Service handles complexity
struct NewLogView: View {
    @StateObject var locationManager = LocationManager() // Service

    var body: some View {
        Text("GPS: \(locationManager.location?.coordinate.latitude ?? 0)")
        // Clean, testable, reusable
    }
}
```

**Benefits:**
- **Testable:** Mock WeatherService returns fake data
- **Reusable:** LocationManager used in NewLogView AND MapView
- **Maintainable:** Switch weather API? Only touch WeatherService.swift

---

### Resources/ - Non-Code Assets

| File | Purpose | Git Committed? |
|------|---------|---------------|
| `Config.xcconfig` | API keys (WEATHER_API_KEY) | ❌ No - add to .gitignore |
| `Assets.xcassets` | Images, icons, colors | ✅ Yes |

**Why Config.xcconfig?**
- API keys out of source code
- Easy to swap dev/prod keys
- Standard iOS pattern

---

## File Responsibilities

### DashboardView.swift
```swift
// Responsibilities:
// - Query all journals from SwiftData
// - Display journal cards (name, entry count, last modified)
// - "Create Journal" button
// - Tap journal → Navigate to JournalTabView(selectedJournal: journal)
//
// Why separate from JournalTabView:
// - DashboardView = choosing which journal
// - JournalTabView = working inside chosen journal
// - Clear separation of concerns
```

### JournalTabView.swift
```swift
// Responsibilities:
// - Bottom TabView with 3 tabs (Logs, New Log, Map)
// - Top navigation bar: "< Journals" back button
// - Pass selectedJournal to all child views
// - Handle back navigation to DashboardView
//
// Why needed:
// - Manages tab state
// - Keeps selectedJournal in scope for all tabs
// - Standard iOS tab container pattern
```

### LogsView.swift (Tab 1)
```swift
// Responsibilities:
// - Query entries for selectedJournal from SwiftData
// - Display chronologically (newest first)
// - Show LogCardView for each entry
// - Tap card → Navigate to LogDetailView
// - Show EmptyStateView if 0 entries
//
// Why "Logs" not "Journal":
// - "Journal" = container (already selected)
// - "Logs" = viewing entries inside journal
// - Matches "New Log" terminology
```

### NewLogView.swift (Tab 2)
```swift
// Responsibilities:
// - Auto-populate on appear:
//   - GPS coordinates (LocationManager)
//   - Altitude (LocationManager)
//   - Weather (WeatherService via GPS)
//   - Timestamp (Date.now)
// - User input:
//   - Photo (CameraManager)
//   - Notes (TextField)
//   - Voice memo (future)
// - Save → Create Entry in SwiftData
// - Clear form after save
// - Show loading state while fetching weather
//
// Why auto-populate:
// - Field use case: gloves, rain, fast entry
// - Reduce user friction
// - Capture accurate GPS at moment of observation
```

### MapView.swift (Tab 3)
```swift
// Responsibilities:
// - Query entries for selectedJournal
// - Filter entries with valid GPS (lat/lon not nil)
// - Display Apple Maps (MapKit)
// - Show pin for each entry
// - Pin annotation shows: photo thumbnail, date, weather icon
// - Tap pin → Show callout preview
// - Tap callout → Navigate to LogDetailView
//
// Why MapView:
// - User requested: "Where did I take that sample?"
// - Spatial context for field observations
// - Easy to spot patterns (all samples in one area)
```

---

## Data Flow

```
User Action                 → Service/Manager        → SwiftData/API      → View Updates
───────────────────────────────────────────────────────────────────────────────────────
Tap "New Log" tab          → (none)                 → (none)             → Show NewLogView
NewLogView appears         → LocationManager        → Get current GPS    → Display GPS coords
                          → WeatherService         → Fetch by GPS       → Display weather
Tap "Capture Photo"        → CameraManager          → Open camera        → Photo added to form
Tap "Save"                 → SwiftData insert       → Entry persisted    → Navigate to LogsView
LogsView appears           → SwiftData query        → Get entries        → Display LogCardViews
Tap log card               → (none)                 → (none)             → Show LogDetailView
Tap "Map" tab              → SwiftData query        → Get entries        → Show pins on map
```

**Why this flow:**
- Views coordinate (when to fetch)
- Services execute (how to fetch)
- SwiftData persists (where to store)
- Clear separation: easier to debug, test, modify

---

## Why This Architecture? (Design Decisions)

### Decision: SwiftData over Core Data

| Aspect | SwiftData | Core Data |
|--------|-----------|-----------|
| Code to create model | 1 line: `@Model` | 50+ lines: NSManagedObject subclass |
| Relationships | Automatic: `var entries: [Entry]` | Manual: NSSet, fetch requests |
| SwiftUI integration | Native @Query | Requires @FetchRequest boilerplate |
| Learning curve | Low (just add @Model) | High (contexts, fetch requests, migrations) |
| iCloud sync | Toggle one switch | Complex NSPersistentCloudKitContainer setup |

**Verdict:** SwiftData = less code, same power, better for learning

---

### Decision: Models/Views/Services over Feature Folders

**Alternative considered:**
```
Entry/
├── EntryView.swift
├── Entry.swift
├── EntryViewModel.swift
```

**Why we chose Models/Views/Services:**
- ✅ Simpler for small project (v1.0 = 14 files total)
- ✅ Clear "what goes where" for beginners
- ✅ Easy to refactor to feature folders later if needed
- ❌ Feature folders better for 50+ files (not there yet)

---

### Decision: Weather as Struct, not @Model

**Alternative:** Separate Weather table
```swift
@Model
class Weather {
    var condition: String
    var temperature: Double
    // ...
}

@Model
class Entry {
    var weather: Weather? // Relationship
}
```

**Why we chose embedded struct:**
- ✅ 1:1 relationship (each entry has exactly one weather snapshot)
- ✅ Weather never queried independently ("show all sunny days" not needed)
- ✅ Simpler: fewer tables, fewer relationships
- ✅ Codable struct = easy API → storage

---

## Quick Reference

### What Goes Where

| I need to... | Put it in... | Example |
|-------------|--------------|---------|
| Define data structure | `Models/` | `Journal.swift`, `Entry.swift` |
| Create a screen | `Views/` | `DashboardView.swift` |
| Reuse a UI component | `Views/` | `LogCardView.swift` |
| Call an API | `Services/` | `WeatherService.swift` |
| Access device features | `Services/` | `LocationManager.swift`, `CameraManager.swift` |
| Store API keys | `Resources/Config.xcconfig` | `WEATHER_API_KEY = abc123` |

### File Naming Convention

| Pattern | Example | Why |
|---------|---------|-----|
| Noun + "View" | `DashboardView.swift` | SwiftUI views always end in View |
| Noun + "Manager" | `LocationManager.swift` | Manages device feature (GPS) |
| Noun + "Service" | `WeatherService.swift` | External service integration |
| Plain noun | `Journal.swift` | Data model |

---

## Project Structure (Complete)

```
fieldnote/                              ← Git repo root
├── fieldnote.xcodeproj/                ← Xcode project file
├── fieldnote/                          ← Source code (visible in Xcode)
│   ├── fieldnoteApp.swift             ← App entry point, SwiftData container
│   ├── ContentView.swift               ← Generated (replace with DashboardView)
│   ├── Item.swift                      ← Generated (can delete)
│   ├── Models/
│   │   ├── Journal.swift              ← @Model, one-to-many with Entry
│   │   ├── Entry.swift                ← @Model, belongs to Journal
│   │   └── Weather.swift              ← Codable struct (not @Model)
│   ├── Views/
│   │   ├── DashboardView.swift        ← Journal selection
│   │   ├── JournalTabView.swift       ← Tab container
│   │   ├── LogsView.swift             ← Tab 1: View entries
│   │   ├── LogCardView.swift          ← Reusable entry preview
│   │   ├── LogDetailView.swift        ← Full entry view
│   │   ├── NewLogView.swift           ← Tab 2: Create entry
│   │   ├── MapView.swift              ← Tab 3: Map view
│   │   └── EmptyStateView.swift       ← No entries state
│   ├── Services/
│   │   ├── LocationManager.swift      ← CoreLocation wrapper
│   │   ├── WeatherService.swift       ← API client
│   │   └── CameraManager.swift        ← Camera integration
│   └── Resources/
│       ├── Assets.xcassets            ← Images, icons
│       └── Config.xcconfig            ← API keys (not committed)
├── docs/                               ← Documentation (NOT in Xcode)
│   ├── planning/
│   │   ├── implementation-plan.md      ← Detailed roadmap
│   │   └── architecture.md             ← This file
│   └── learning/
│       └── ai-assisted-dev.md          ← Learnings, conventions
├── README.md                           ← Quick overview
└── .gitignore                          ← Exclude Config.xcconfig
```

---

## Implementation Order

### Week 1-2: Foundation
1. `Models/Journal.swift` - Define data structure
2. `Models/Entry.swift` - Define log entry structure
3. `Models/Weather.swift` - Define weather struct
4. `Views/DashboardView.swift` - Journal selection UI
5. `Views/JournalTabView.swift` - Tab container

**Goal:** Navigate from dashboard to tabs

---

### Week 3-4: Core Features
6. `Services/LocationManager.swift` - GPS integration
7. `Services/WeatherService.swift` - Weather API
8. `Services/CameraManager.swift` - Photo capture
9. `Views/NewLogView.swift` - Create log form

**Goal:** Can create logs with GPS + weather

---

### Week 5-6: Polish
10. `Views/LogsView.swift` - View entries list
11. `Views/LogCardView.swift` - Entry preview card
12. `Views/LogDetailView.swift` - Full entry view
13. `Views/MapView.swift` - Map with pins
14. `Views/EmptyStateView.swift` - Empty state

**Goal:** MVP ready for field testing

---

**Last Updated:** 2026-05-05
**Status:** Architecture finalized, ready to implement
