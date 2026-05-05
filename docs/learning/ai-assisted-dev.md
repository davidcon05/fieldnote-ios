# AI-Assisted Development Learnings

This document captures insights, conventions, and "aha!" moments from building FieldNote with Claude Code.

---

## Xcode Conventions

### Always Create Files in Xcode, Not Finder

| Action | Result | Why |
|--------|--------|-----|
| Create file in Xcode | ✅ Added to project.pbxproj automatically | Xcode knows about it, compiles correctly |
| Create file in Finder | ❌ File exists but Xcode doesn't see it | Build fails: "file not found" |
| Drag from Finder to Xcode | ⚠️ Works, but must check "Copy items if needed" | Easy to forget, causes broken references |

**Lesson:** Right-click in Xcode Navigator → New File is the safe path.

---

### Groups vs Folders

| Type | Created How | On Disk | In Xcode | Use When |
|------|------------|---------|----------|----------|
| **Group** (virtual) | New Group | Files at project root | Shows as folder | Quick organization, files stay flat |
| **Folder** (real) | New Group with Folder | Actual directory | Shows as folder | Want disk structure to match |

**What we chose:** Virtual groups (Models/, Views/, Services/)
**Why:** Simpler, Xcode handles references, disk structure doesn't matter for small projects

**Gotcha:** Yellow folders = groups (virtual), Blue folders = real directories

---

### .pbxproj File

**What it is:** Xcode's project file (XML) tracking every file, setting, and reference

**Why it matters:**
- Adding files outside Xcode = .pbxproj not updated = build fails
- Manual edits risky (easy to break)
- Git conflicts in .pbxproj are painful

**Lesson:** Let Xcode manage .pbxproj. Never hand-edit unless desperate.

---

## SwiftData Learnings

### Why SwiftData over Core Data

| Aspect | SwiftData (2023+) | Core Data (2005+) |
|--------|------------------|------------------|
| **Model definition** | `@Model` macro | NSManagedObject subclass |
| **Relationships** | `var entries: [Entry]` | NSSet + custom accessors |
| **SwiftUI integration** | `@Query` | `@FetchRequest` |
| **Boilerplate** | ~5 lines | ~50+ lines |
| **Learning curve** | Shallow | Steep |

```swift
// SwiftData (modern, clean)
@Model
class Journal {
    var name: String
    var entries: [Entry] // Automatic relationship
}

// Core Data (legacy, verbose)
class Journal: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var entries: NSSet?

    var entriesArray: [Entry] {
        let set = entries as? Set<Entry> ?? []
        return set.sorted { $0.timestamp > $1.timestamp }
    }
}
```

**Verdict:** SwiftData = modern Swift, less code, easier to learn.

---

### @Model Macro

**What it does:**
- Marks class as persistent (stored in database)
- Auto-generates SwiftData boilerplate
- Makes properties observable (SwiftUI updates)
- Enables iCloud sync (just toggle one setting)

**When NOT to use:**
- Structs (must be class)
- API response models (use Codable)
- Temporary data (use @Observable or @State)

**Example:**
```swift
// Weather is Codable, not @Model
struct Weather: Codable {
    var temperature: Double
    // Stored as JSON inside Entry, not separate table
}

// Entry IS @Model
@Model
class Entry {
    var weather: Weather? // Embedded struct
}
```

**Why:** Weather is 1:1 with Entry, never queried independently.

---

### SwiftData Relationships

| Relationship | Code | Database |
|--------------|------|----------|
| One-to-many | `var entries: [Entry]` | Journal → many Entries |
| Many-to-one | `var journal: Journal?` | Entry → one Journal |
| Cascade delete | Automatic (delete journal → deletes entries) | Handled by SwiftData |

**No configuration needed:** SwiftData infers relationships from types.

---

## SwiftUI Patterns

### @StateObject vs @ObservedObject

| Modifier | Ownership | Lifecycle | Use When |
|----------|-----------|-----------|----------|
| `@StateObject` | View owns | View creates, manages lifecycle | LocationManager created by NewLogView |
| `@ObservedObject` | View observes | Created elsewhere | Journal passed from DashboardView |

```swift
// NewLogView creates and owns LocationManager
struct NewLogView: View {
    @StateObject var locationManager = LocationManager() // View owns
}

// LogsView receives Journal from parent
struct LogsView: View {
    @ObservedObject var journal: Journal // View observes
}
```

---

### @Query for SwiftData

**What it does:** Automatically fetches from database, updates view when data changes

```swift
struct LogsView: View {
    @Query(sort: \Entry.timestamp, order: .reverse) var entries: [Entry]

    var body: some View {
        List(entries) { entry in
            LogCardView(entry: entry)
        }
    }
    // No manual fetch, no refresh logic - SwiftData handles it
}
```

**Why it's powerful:** Zero boilerplate, automatic updates, type-safe.

---

## Services Pattern

### Why Extract Services?

**Problem:** Views doing too much
```swift
// ❌ BAD: NewLogView managing GPS, weather, camera
struct NewLogView: View {
    var body: some View {
        Button("Save") {
            let locationManager = CLLocationManager()
            locationManager.requestAuthorization() // View managing CoreLocation

            let url = "https://api.weather.com..."
            URLSession.shared.dataTask(with: url) { ... } // View making API calls

            // Too much responsibility, hard to test
        }
    }
}
```

**Solution:** Service layer
```swift
// ✅ GOOD: Services handle complexity
class LocationManager: ObservableObject {
    @Published var location: CLLocation?
    // Handles authorization, updates, errors
}

struct NewLogView: View {
    @StateObject var locationManager = LocationManager()

    var body: some View {
        Text("GPS: \(locationManager.location?.coordinate.latitude ?? 0)")
        // Clean, view just displays data
    }
}
```

**Benefits:**
1. **Testable:** Mock LocationManager returns fake GPS
2. **Reusable:** Use in NewLogView AND MapView
3. **Maintainable:** Change GPS logic? Only touch LocationManager.swift
4. **Clear:** View renders UI, service handles device/API

---

## API Integration

### Weather API Choice

| API | Free Tier | Pros | Cons |
|-----|-----------|------|------|
| OpenWeatherMap | 1000 calls/day | Popular, good docs | Requires API key |
| WeatherAPI.com | 1M calls/month | Generous free tier | Less known |
| OpenMeteo | Unlimited | No API key needed | Limited features |

**Chose:** OpenWeatherMap (good learning resource, enough free tier for field use)

**Key insight:** Store API key in Config.xcconfig, not code:
```swift
// ❌ NEVER commit API keys to Git
let apiKey = "abc123xyz" // Hard-coded

// ✅ Config.xcconfig (in .gitignore)
WEATHER_API_KEY = your_key_here

// Access in code
let apiKey = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String
```

---

## Git Workflow

### What to Commit

| File/Folder | Commit? | Why |
|-------------|---------|-----|
| Source code (.swift) | ✅ Yes | The app |
| Xcode project (.xcodeproj) | ✅ Yes | Build settings |
| Assets (.xcassets) | ✅ Yes | Images, icons |
| Config.xcconfig | ❌ No | Contains API keys |
| .DS_Store | ❌ No | macOS junk |
| xcuserdata/ | ❌ No | Xcode user preferences |

**.gitignore template:**
```
# API keys
Config.xcconfig

# Xcode
xcuserdata/
*.xcworkspace/xcuserdata/

# macOS
.DS_Store

# Build
build/
DerivedData/
```

---

## Mistakes Made & Fixed

### Mistake 1: Not Understanding Groups vs Folders

**What happened:** Created folders in Finder, dragged to Xcode, references broke

**Why:** Xcode didn't know where files were (relative path issue)

**Fix:** Delete files from Xcode, create Groups in Xcode Navigator, move files via Xcode

**Lesson:** Always create in Xcode first

---

### Mistake 2: Trying to Use @Model on Struct

**What happened:** Compiler error: "@Model can only be applied to classes"

**Why:** SwiftData uses reference types (classes) for persistence

**Fix:** Change `struct Entry` to `class Entry`

**Lesson:** @Model = class, Codable = struct or class

---

### Mistake 3: Forgetting Info.plist Permissions

**What happened:** App crashed when requesting GPS

**Why:** iOS requires privacy descriptions in Info.plist

**Fix:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to tag field entries with GPS coordinates.</string>
```

**Lesson:** All device features require Info.plist permission strings

---

## AI-Assisted Workflow

### What Works Well

| Task | How AI Helps | Example |
|------|-------------|---------|
| **Boilerplate code** | Generate entire files | "Create SwiftData model for Journal" |
| **Explaining patterns** | Break down conventions | "Why @StateObject vs @ObservedObject?" |
| **Troubleshooting** | Diagnose errors | "Compiler says: '@Model requires class'" |
| **Architecture decisions** | Compare options | "SwiftData vs Core Data vs UserDefaults" |
| **Documentation** | Generate READMEs, comments | "Document this architecture" |

### What Doesn't Work

| Task | Why AI Struggles | Solution |
|------|-----------------|----------|
| **Xcode UI navigation** | Can't see your screen | Learn Xcode manually, ask "how do I..." |
| **Design decisions** | Needs context about user | You decide, AI explains tradeoffs |
| **Debugging crashes** | No access to logs/memory | Paste error messages, ask for interpretation |

### Best Practices

1. **Start with "why"** - Ask AI to explain reasoning, not just code
2. **Iterate** - Generate code, review, ask for improvements
3. **Capture learnings** - This document is the result
4. **Validate** - AI can be wrong, always test the code

---

## Resources Used

### Documentation
- [SwiftData by Example](https://www.hackingwithswift.com/quick-start/swiftdata)
- [SwiftUI Apple Docs](https://developer.apple.com/documentation/swiftui)
- [CoreLocation Guide](https://developer.apple.com/documentation/corelocation)

### Tools
- **Claude Code** - AI pair programmer
- **Xcode 15+** - IDE
- **Git** - Version control

---

## Next Learnings to Capture

- [ ] How camera integration works (UIImagePickerController bridging)
- [ ] MapKit annotations (custom pins)
- [ ] Offline weather caching strategy
- [ ] SwiftData migrations (when we change models later)
- [ ] Performance optimization (large photo storage)

---

**Started:** 2026-05-05
**Last Updated:** 2026-05-05
**Status:** Active - updated as we build
