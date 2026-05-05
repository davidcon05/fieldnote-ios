# Field Note App - Implementation Plan

## Project Overview

**Purpose:** iOS field journal app for environmental science fieldwork
**User:** Environmental scientist working outdoors (gloves, rain, remote locations)
**Priority:** Offline-first, GPS-tagged entries, photo capture, auto-weather logging
**Platform:** iOS only (iPhone)

---

## App Navigation Flow

```
Splash Screen (Launch)
    ↓
Dashboard Screen (Journal Selection)
    ↓ (Select Journal)
Bottom Navigation Appears:
    ├── Journal Tab (Entry List)
    ├── Entry Tab (Create/Edit Entry)
    ├── Map Tab (View Entries on Map)
    └── Switch Tab (Back to Dashboard)
```

**Key Behaviors:**
- Bottom nav is **hidden** until user selects a journal from Dashboard
- **Switch tab** returns to Dashboard (prevents wrong journal entries)
- All tabs operate on the **currently selected journal**

---

## Core Screens

### 1. Splash Screen
- App launch animation
- Load journals from SwiftData
- Navigate to Dashboard

### 2. Dashboard Screen
- **Purpose:** Select which journal to work in
- **UI:** List of journals (cards with name, entry count, last modified)
- **Actions:** Create journal, select journal, delete journal
- **Navigation:** Select journal → Shows bottom nav

### 3. Journal Tab (Entry List)
- **Purpose:** View all entries for selected journal
- **UI:** Chronological list of entry cards
  - Entry card shows: photo thumbnail, date/time, GPS preview, weather icon, first line of notes
- **Actions:** Tap entry → Entry detail, Pull to refresh

### 4. Entry Tab (Create/Edit)
- **Purpose:** Capture field observations
- **Auto-populated:**
  - GPS coordinates (CoreLocation)
  - Altitude (CoreLocation)
  - Timestamp (Date)
  - **Weather** (Free API - auto-fetch when entry created)
- **User Input:**
  - Photo capture (camera)
  - Text notes
  - Voice memo (optional)

### 5. Map Tab
- **Purpose:** Visualize entries on map
- **UI:** Apple Maps with entry pins
- **Actions:** Tap pin → Entry preview, Tap preview → Journal tab (entry detail)

### 6. Switch Tab
- **Purpose:** Safety feature - change journal
- **Behavior:** Shows confirmation → Returns to Dashboard

---

## Data Models

### Journal
```swift
@Model
class Journal {
    var id: UUID
    var name: String
    var createdDate: Date
    var lastModified: Date
    var coverPhotoURL: URL?
    var entries: [Entry]
}
```

### Entry
```swift
@Model
class Entry {
    var id: UUID
    var journalID: UUID
    var timestamp: Date

    // Auto-populated
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var weather: Weather?  // Auto-fetched from API

    // User input
    var notes: String
    var photoURLs: [URL]
    var audioMemoURL: URL?
}
```

### Weather (Auto-populated)
```swift
struct Weather: Codable {
    var condition: String       // "Sunny", "Rainy", "Cloudy"
    var temperature: Double     // Celsius
    var humidity: Int           // Percentage
    var windSpeed: Double       // m/s
    var icon: String            // Weather icon code
}
```

**Weather API:** Use free tier of [OpenWeatherMap API](https://openweathermap.org/api) or [WeatherAPI.com](https://www.weatherapi.com/)
- Auto-fetch when entry is created (using GPS coordinates)
- Cache for offline use
- Display weather icon + temp on entry card

---

## Phased Development Plan

### Phase 1: Stock Implementation (Validation - No Code)
**Goal:** Validate which features she actually uses
**Duration:** 2-4 weeks field testing

#### Workflow
1. Use **Photos app** → Info button for GPS
2. Use **Voice Memos** → Audio notes
3. Use **Measure app** → LiDAR measurements
4. Use **Notes app** → Manual data entry

#### Success Metrics
- Does she check GPS coordinates often?
- Voice memos vs typing?
- Uses LiDAR measurements?
- What data fields are consistent?

**Decision:** If she uses all features → Build custom app (Phase 3)

---

### Phase 2: Low-Code Tools (Power User - Minimal Code)
**Goal:** Test existing apps with better integration
**Duration:** 1-2 months

#### Tools
- **QField / Mergin Maps:** GPS + photo + offline (requires QGIS setup)
- **iNaturalist / Seek:** Species ID with Neural Engine
- **Polycam:** LiDAR 3D scanning

**Decision:** If custom workflows needed → Build custom app (Phase 3)

---

### Phase 3: Custom App Development

---

## v1.0: The Logbook (MVP)

**Timeline:** 4-6 weeks
**Focus:** Core data capture + offline storage

### Features
- Dashboard (journal selection)
- Journal tab (entry list)
- Entry tab (GPS + photo + notes + **weather**)
- Bottom nav (4 tabs)
- SwiftData (offline storage)
- CoreLocation (GPS + altitude)
- **Weather API** (auto-fetch on entry creation)

---

## Step-by-Step Implementation (v1.0)

### Week 1-2: Project Setup & Core Structure

#### 1. Create Xcode Project
```bash
- Open Xcode
- Create new iOS App
- Product Name: "FieldNote"
- Interface: SwiftUI
- Storage: SwiftData
- Language: Swift
```

#### 2. Set up SwiftData Models
**File:** `Models/Journal.swift`
```swift
import SwiftData

@Model
class Journal {
    var id: UUID
    var name: String
    var createdDate: Date
    var lastModified: Date
    var entries: [Entry]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdDate = Date()
        self.lastModified = Date()
        self.entries = []
    }
}
```

#### 3. Set up Entry Model
**File:** `Models/Entry.swift`
```swift
import SwiftData

@Model
class Entry {
    var id: UUID
    var timestamp: Date
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var weatherCondition: String?
    var temperature: Double?
    var notes: String
    var photoURLs: [URL]

    init() {
        self.id = UUID()
        self.timestamp = Date()
        self.notes = ""
        self.photoURLs = []
    }
}
```

#### 4. Configure SwiftData Container
**File:** `FieldNoteApp.swift`
```swift
import SwiftUI
import SwiftData

@main
struct FieldNoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Journal.self, Entry.self])
    }
}
```

#### 5. Build Dashboard Screen
**File:** `Views/DashboardView.swift`
- Create journal list UI
- Add "Create Journal" button
- Navigation to bottom tabs on journal selection

#### 6. Build Splash Screen (Optional)
**File:** `Views/SplashView.swift`
- Simple animation
- 2-second delay → Dashboard

---

### Week 3-4: Entry Creation & Location Services

#### 7. Set up Location Manager
**File:** `Services/LocationManager.swift`
```swift
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var heading: CLHeading?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
}
```

#### 8. Add Location Permissions
**File:** `Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to tag field entries with GPS coordinates.</string>
```

#### 9. Set up Weather API Service
**File:** `Services/WeatherService.swift`
```swift
import Foundation

class WeatherService {
    private let apiKey = "YOUR_API_KEY"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"

    func fetchWeather(latitude: Double, longitude: Double) async throws -> Weather {
        let url = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        // Fetch weather data
    }
}
```

**Note:** Sign up for free API key at [OpenWeatherMap](https://openweathermap.org/api)

#### 10. Build Entry Screen UI
**File:** `Views/EntryView.swift`
- GPS coordinates display (auto-populated)
- Altitude display (auto-populated)
- **Weather display (auto-fetched)**
- Camera button
- Text notes field
- Save button

#### 11. Integrate Camera
**File:** `Services/CameraManager.swift`
```swift
import SwiftUI
import PhotosUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
}
```

#### 12. Save Entry with Auto-populated Data
```swift
func createEntry() {
    let entry = Entry()

    // Auto-populate GPS
    if let location = locationManager.location {
        entry.latitude = location.coordinate.latitude
        entry.longitude = location.coordinate.longitude
        entry.altitude = location.altitude

        // Auto-fetch weather
        Task {
            let weather = try await weatherService.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            entry.weatherCondition = weather.condition
            entry.temperature = weather.temperature
        }
    }

    entry.notes = notes
    entry.photoURLs = photoURLs

    modelContext.insert(entry)
}
```

---

### Week 5-6: Navigation & Polish

#### 13. Build Bottom Navigation
**File:** `Views/AppTabView.swift`
```swift
struct AppTabView: View {
    @Binding var selectedJournal: Journal?
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            JournalView()
                .tabItem { Label("Journal", systemImage: "book") }
                .tag(0)

            EntryView()
                .tabItem { Label("Entry", systemImage: "plus.circle") }
                .tag(1)

            MapView()
                .tabItem { Label("Map", systemImage: "map") }
                .tag(2)

            SwitchView()
                .tabItem { Label("Switch", systemImage: "arrow.triangle.2.circlepath") }
                .tag(3)
        }
    }
}
```

#### 14. Build Journal List View
**File:** `Views/JournalView.swift`
- Query entries from SwiftData
- Display entry cards with:
  - Photo thumbnail
  - Date/time
  - GPS preview
  - **Weather icon + temperature**
  - First line of notes

#### 15. Build Entry Detail View
**File:** `Views/EntryDetailView.swift`
- Read-only view of entry
- Show all fields (GPS, weather, photos, notes)
- Edit button → EntryView (pre-filled)

#### 16. Implement Switch Tab with Confirmation
**File:** `Views/SwitchView.swift`
```swift
struct SwitchView: View {
    @Binding var selectedJournal: Journal?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Change Journal?")
            Button("Confirm") {
                selectedJournal = nil
                // Navigate to Dashboard
            }
            Button("Cancel") {
                dismiss()
            }
        }
    }
}
```

#### 17. Add Entry Card Weather Display
```swift
HStack {
    Image(systemName: weatherIcon)  // "sun.max", "cloud.rain"
    Text("\(temperature)°C")
}
```

#### 18. Test Offline Mode
- Disable internet
- Create entry (GPS should work)
- Weather should fail gracefully (show cached or "N/A")
- All data should save locally

#### 19. Polish UI
- Large tap targets (44x44pt minimum)
- High contrast colors (outdoor visibility)
- Auto-save drafts
- Loading indicators

#### 20. Field Testing
- Test in real outdoor conditions
- Verify GPS accuracy
- Test weather API reliability
- Check battery drain

---

## v2.0: The Visual Lab

**Timeline:** 3-4 weeks (after v1.0)

### Week 1-2: Enhanced Camera

#### 21. Replace basic camera with AVFoundation
**File:** `Services/AVCameraManager.swift`

#### 22. Add GPS/Altitude/Heading Overlay on Photos
- Stamp data directly on captured image
- Save overlay data in EXIF metadata

#### 23. Add Weather Overlay on Photos
- Display weather condition + temp on photo

---

### Week 3-4: Map Integration

#### 24. Build Map Screen
**File:** `Views/MapView.swift`
```swift
import MapKit

struct MapView: View {
    @Query var entries: [Entry]

    var body: some View {
        Map {
            ForEach(entries) { entry in
                if let lat = entry.latitude, let lon = entry.longitude {
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                        MapPinView(entry: entry)
                    }
                }
            }
        }
    }
}
```

#### 25. Add Entry Pin Annotations
- Show photo thumbnail
- Weather icon
- Timestamp

#### 26. Implement Pin Tap → Entry Detail
- Tap pin → Preview card
- Tap card → Navigate to JournalView (entry detail)

#### 27. Add Pin Clustering
- Cluster dense pins
- Show count badge

---

## v3.0: Precision Tools

**Timeline:** 4-6 weeks (after v2.0)

### Week 1-2: ARKit Integration

#### 28. Add ARKit SceneReconstruction
**File:** `Services/ARManager.swift`

#### 29. Build Measurement UI
- Distance measurement
- Height measurement (trees)
- Area measurement (soil patches)

---

### Week 3-4: CoreML Integration

#### 30. Train Custom Species Identification Model
- Use Create ML
- Train on common species in her area

#### 31. Integrate Model into App
**File:** `Services/SpeciesIdentifier.swift`

#### 32. Add Offline Inference
- Use Neural Engine
- Show species name + confidence

---

### Week 5-6: 3D Scanning

#### 33. Add RealityKit for 3D Scanning
**File:** `Services/ScanManager.swift`

#### 34. Export 3D Models (.OBJ, .STL)

#### 35. Desktop Viewing Workflow
- Export via AirDrop or Files app

---

## Weather API Integration Details

### Free Weather APIs (Choose One)

| API | Free Tier | Features |
|-----|-----------|----------|
| **OpenWeatherMap** | 1000 calls/day | Current weather, forecast, icons |
| **WeatherAPI.com** | 1M calls/month | Current + forecast, alerts |
| **OpenMeteo** | Unlimited | No API key, open-source |

### Implementation Steps

#### 1. Sign up for API Key
- Go to [OpenWeatherMap](https://openweathermap.org/api)
- Create free account
- Get API key

#### 2. Store API Key Securely
**File:** `Config.xcconfig`
```
WEATHER_API_KEY = your_key_here
```

#### 3. Fetch Weather on Entry Creation
```swift
func createEntry() async {
    let entry = Entry()

    if let location = locationManager.location {
        entry.latitude = location.coordinate.latitude
        entry.longitude = location.coordinate.longitude

        // Auto-fetch weather
        do {
            let weather = try await weatherService.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            entry.weatherCondition = weather.condition
            entry.temperature = weather.temperature
            entry.humidity = weather.humidity
        } catch {
            print("Weather fetch failed: \(error)")
            // Continue without weather data
        }
    }

    modelContext.insert(entry)
}
```

#### 4. Cache Weather Data for Offline Use
```swift
class WeatherCache {
    private var cache: [String: Weather] = [:]

    func cacheWeather(for location: CLLocation, weather: Weather) {
        let key = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        cache[key] = weather
    }

    func getCachedWeather(for location: CLLocation) -> Weather? {
        let key = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        return cache[key]
    }
}
```

#### 5. Display Weather on Entry Card
```swift
HStack {
    Image(systemName: entry.weatherIcon)
        .font(.title2)
    Text("\(Int(entry.temperature ?? 0))°C")
        .font(.headline)
    Text(entry.weatherCondition ?? "N/A")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

---

## Technical Architecture

### Project Structure
```
FieldNote/
├── FieldNoteApp.swift
├── Models/
│   ├── Journal.swift
│   ├── Entry.swift
│   └── Weather.swift
├── Views/
│   ├── SplashView.swift
│   ├── DashboardView.swift
│   ├── AppTabView.swift
│   ├── JournalView.swift
│   ├── EntryView.swift
│   ├── EntryDetailView.swift
│   ├── MapView.swift
│   └── SwitchView.swift
├── Services/
│   ├── LocationManager.swift
│   ├── WeatherService.swift
│   ├── CameraManager.swift
│   └── WeatherCache.swift
└── Config.xcconfig
```

---

## Success Metrics

### v1.0 Launch
- ✅ Wife uses app for 90% of field entries
- ✅ Zero data loss incidents
- ✅ <30 seconds to create entry
- ✅ Works offline 100% of time
- ✅ Weather auto-populated on every entry

### v2.0 Launch
- ✅ Map view used weekly
- ✅ Photo overlays include weather data

### v3.0 Launch
- ✅ LiDAR measurements replace tape measure
- ✅ Species ID accuracy >80%

---

## Next Steps

### Before Building
1. ✅ Review designs in Stitch with wife
2. ✅ Validate workflow with Phase 1 (stock iOS tools)
3. ✅ Test Phase 2 (low-code tools)
4. ✅ Sign up for weather API

### Start Building (v1.0)
1. Create Xcode project (Step 1)
2. Set up SwiftData models (Steps 2-4)
3. Build Dashboard screen (Step 5)
4. Integrate location services (Steps 7-8)
5. **Integrate weather API (Step 9)**
6. Build Entry screen (Steps 10-12)
7. Build bottom navigation (Steps 13-16)
8. Test offline + field conditions (Steps 18-20)

**Ready to build!** Start with v1.0 MVP and iterate based on real field feedback.
