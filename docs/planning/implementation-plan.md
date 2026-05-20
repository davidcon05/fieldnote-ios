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
- **UI:** Grid of journal cards (clean, modern card style)
  - Card shows: theme gradient/photo, journal name, last modified date, log count, settings icon
  - **Lock badge:** Shows lock icon in top-right corner if password protected (privacy indicator)
  - **Settings icon:** Ellipsis.circle in top-right of card content → Opens JournalSettingsSheet
  - **Navigation chevron:** Bottom-right indicates card is tappable
- **Actions:**
  - Create journal (FAB button) → Opens CreateJournalSheet
  - **Tap journal card** → Navigate to JournalTabView
  - **Tap settings icon** → Opens JournalSettingsSheet
    - Change journal name
    - Change theme (icon + color)
    - Change cover photo
    - Toggle password protection
    - **Delete journal** (with confirmation alert)
- **Navigation:** Tap card → Shows JournalTabView with bottom nav tabs

**Journal Settings Sheet:**
- Accessible from settings icon on dashboard card
- **Delete Confirmation:** "Delete [Journal Name]? This will permanently delete all logs in this journal."
  - Primary action: "Delete" (destructive red)
  - Secondary action: "Cancel"

**Design Notes:**
- **Lock badge:** Only visible on password-protected journals
- **Settings on card:** Direct access to journal settings from dashboard
- Delete requires opening settings sheet + confirmation (prevents accidental deletion)

### 3. Journal Tab (Entry List)
- **Purpose:** View all entries for selected journal
- **UI:** Chronological list of entry cards
  - Entry card shows: photo thumbnail, date/time, GPS preview, weather icon, first line of notes
- **Actions:** Tap entry → Entry detail, Pull to refresh
- **Note:** Journal settings are accessible from the Dashboard card (settings icon)

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

    // Theme (always assigned - serves as fallback and privacy layer)
    var themeIcon: String
    var themeColorHex: String

    // Privacy
    var isPasswordProtected: Bool

    var logs: [Log]
}
```

**Journal Card Background Priority:**
1. **Password protected** → Always show theme (privacy - hides content)
2. **Custom cover photo** → Show coverPhotoURL if set
3. **Recent log media** → Show first log's photo if available
4. **Empty journal** → Show theme (fallback)

**Theme System:**
- Every journal is assigned a random theme on creation (icon + color)
- Theme serves dual purpose: aesthetic fallback AND privacy layer
- 6 available themes: leaf (green), drop (brown), mountain (gold), tree (dark green), flame (red), snowflake (teal)
- User can change theme in Journal Settings

### Log
```swift
@Model
class Log {
    var id: UUID
    var title: String = "Untitled Entry"  // REQUIRED field
    var timestamp: Date         // Device time (always available)

    // Auto-populated (optional - graceful degradation)
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var locationError: String?  // Error message if GPS failed

    var weather: Weather?       // Auto-fetched from API
    var weatherError: String?   // Error message if weather fetch failed

    // User input
    var notes: String           // Optional field notes
    var mediaURLs: [URL]        // Photos AND videos

    // Audio memos (multiple per log)
    @Relationship(deleteRule: .cascade, inverse: \AudioMemo.log)
    var audioMemos: [AudioMemo] = []

    var journal: Journal?

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasLocationData: Bool {
        latitude != nil && longitude != nil
    }

    var hasWeatherData: Bool {
        weather != nil
    }
}
```

### AudioMemo
```swift
@Model
class AudioMemo {
    var id: UUID
    var title: String           // e.g., "Soil Moisture", "Ambient Acoustics"
    var audioURL: URL
    var transcription: String?  // Speech-to-text transcription
    var timestamp: Date
    var duration: TimeInterval
    var log: Log?               // Relationship to parent log
}
```

### Weather (Auto-populated)
```swift
struct Weather: Codable {
    let condition: String       // "Sunny", "Rainy", "Cloudy"
    let temperature: Double     // Celsius
    let humidity: Int           // Percentage
    let windSpeed: Double       // m/s
    let icon: String            // Weather icon code
}
```

### Validation Rules
- **REQUIRED:** Title (non-empty, non-whitespace) - Only field required to save a log
- **OPTIONAL:** Notes, photos/videos (supports multiple via `mediaURLs`)
- **OPTIONAL:** Audio memos (supports multiple AudioMemo objects)
- **OPTIONAL:** GPS coordinates, altitude (graceful degradation if unavailable)
- **OPTIONAL:** Weather data (depends on GPS availability)
- **AUTO-GENERATED:** ID (UUID), timestamp (device time)

### Error Tracking
- **Location errors:** Stored in `locationError` (e.g., "Location services disabled")
- **Weather errors:** Stored in `weatherError` (e.g., "Network unavailable")
- **UI behavior:** Show error banner with "Retry" button, but allow saving without data
- **Benefit:** Preserves debugging info, user knows what went wrong, can retry or proceed

**Weather API:** Use free tier of [OpenWeatherMap API](https://openweathermap.org/api) or [WeatherAPI.com](https://www.weatherapi.com/)
- Auto-fetch when log is created (using GPS coordinates)
- Cache for offline use
- Display weather icon + temp on log card

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
**Focus:** Core data capture + offline storage + basic editing

### Core Features (Must-Have for Launch)

#### ✅ Completed Features
1. **Dashboard (Journal Management)**
   - Grid of journal cards with modern design
   - Create new journals (FAB button)
   - Delete journals with confirmation
   - Password protection with biometric auth (Face ID/Touch ID)
   - Brute force protection (5 attempts, 5-minute lockout)
   - Journal settings (name, theme, cover photo)
   - SwiftData persistence
   - MVVM architecture with 43 unit tests

2. **Data Models & Persistence**
   - Journal model with themes and password protection
   - Log model with GPS, weather, air quality, media
   - Weather model with AQI, PM2.5, PM10
   - SwiftData offline storage (persistent, not in-memory)
   - Seed data with 6 Olympic National Park sample logs

3. **New Log Entry (Capture Portal)**
   - Bento-style asymmetric layout
   - GPS tracking with CoreLocation
   - Weather API integration (OpenWeatherMap)
   - Air Quality API integration (AQI, PM2.5, PM10)
   - Capture Photo button (placeholder for camera)
   - Record Memo card (placeholder for audio)
   - GPS Telemetry card with loading states
   - Weather Data card with environment metrics
   - Field Notes text editor
   - 10-second timeout for all API calls
   - Proper task lifecycle management (no infinite loops)
   - Temperature in Fahrenheit

4. **Logs List View**
   - Two card variants:
     - **Featured cards** (first 3): Sample images, weather badge, expandable details
     - **Compact cards** (remaining): Weather icon, title, date
   - Sorted by recency (newest first)
   - Tappable cards for editing
   - Sample images: forest_moss, alpine_meadow, tide_pools

5. **Bottom Navigation**
   - Tab bar with Logs, New Log, Map (placeholder), Settings tabs
   - Navigation between journal contexts

#### 🔲 Required for v1.0 Launch (ALL MUST-HAVE)

**Priority Order for Implementation:**

**6. Log Editing** ✅ COMPLETED (2026-05-19)
   - **Status:** EditLogView.swift fully implemented
   - **Completed Features:**
     - ✅ Edit log title (required field with validation)
     - ✅ Edit log notes (optional field)
     - ✅ Update timestamp (DatePicker with date + time)
     - ✅ GPS refresh (confirmation alert, updates to current location)
     - ✅ Weather refresh (confirmation alert, uses log's stored coordinates)
     - ✅ View stored weather data (read-only historical snapshot with "CAPTURED AT" label)
     - ✅ Delete log with confirmation (requires typing "DELETE")
     - ✅ Save changes button (disabled until valid)
     - ✅ Form validation (title required)
     - ✅ Edit audio memos (MultiAudioMemoView integrated)
   - **Blocked on:**
     - 🔲 Add/remove photos (PhotoGalleryView placeholder - camera integration needed)
   - **Technical:**
     - ✅ NavigationLink push from LogsListView working
     - ✅ Weather NOT re-fetched (uses stored data)
     - ✅ GPS refreshable with confirmation
     - ✅ Computed binding for audio memos editing
     - ✅ "Save Changes" button implemented
     - ✅ Red "Delete Log" button at bottom

**7. Camera Integration** ✅ COMPLETED (2026-05-13)
   - **Status:** Fully implemented in NewLogView and EditLogView
   - **Components:**
     - ✅ CameraPickerRepresentable (UIImagePickerController wrapper)
     - ✅ PhotoPickerRepresentable (PHPickerViewController wrapper, up to 10 images)
     - ✅ PhotoStorageService (save/load/delete photos from disk)
     - ✅ PhotoGalleryView (complete UI with TabView slider)
   - **Features Implemented:**
     - ✅ Camera capture mode (device camera)
     - ✅ Photo library import mode (select up to 10 photos)
     - ✅ Multi-photo gallery with TabView slider + page indicators
     - ✅ Swipe between photos horizontally
     - ✅ Add/delete individual photos with confirmation
     - ✅ First photo shown in list card thumbnails
     - ✅ Empty state with "Add Photos" button
     - ✅ Photo count display
     - ✅ "Add More" button when photos exist
   - **Technical:**
     - Uses UIImagePickerController for camera
     - Uses PHPickerViewController for photo library
     - JPEG compression at 0.8 quality
     - Photos stored in Documents/LogPhotos directory
     - Cascade deletion when log is deleted
   - **Permissions:** NSCameraUsageDescription, NSPhotoLibraryUsageDescription
   - **Simulator Testable:** Photo library import works in simulator

**8. Audio Memo Recording + Transcription** ✅ COMPLETED (2026-05-19)
   - **Status:** Fully implemented in NewLogView and EditLogView
   - **Components:**
     - ✅ AudioMemo model with SwiftData relationships
     - ✅ MultiAudioMemoView component for managing multiple memos
     - ✅ AudioRecorderService with AVAudioRecorder integration
     - ✅ AudioTranscriptionService with Apple Speech framework
   - **Features Implemented:**
     - ✅ Record multiple audio memos per log entry
     - ✅ Animated recording UI with live timer
     - ✅ Title prompting after recording stops
     - ✅ Automatic speech-to-text transcription
     - ✅ Individual playback controls for each memo
     - ✅ Delete memos with confirmation
     - ✅ Transcriptions displayed in memo cards
     - ✅ Searchable transcriptions in LogsListView
     - ✅ Display in LogDetailView
   - **Technical:**
     - Uses Apple Speech framework (SFSpeechRecognizer)
     - Offline capable after initial language pack download
     - Cascade deletion when log is deleted
     - Proper SwiftData relationship management
   - **Permissions:** NSMicrophoneUsageDescription, NSSpeechRecognitionUsageDescription
   - **Device Required:** Audio recording requires physical device (simulator limited)

**9. Map View (Basic)** ✅ COMPLETED (2026-05-13)
   - ✅ Apple Maps integration with MapKit (hybrid style)
   - ✅ Display all logs as pins (using latitude/longitude)
   - ✅ Custom pin colors (blue/green/purple/red, orange when selected)
   - ✅ Pin tap shows custom callout (image, notes, date, Details button)
   - ✅ Navigate to EditLogView from Details button
   - ✅ Live metrics panel (collapsible, shows avg elevation/humidity/temp)
   - ✅ Center map button (orange, bottom-right)
   - ✅ Filter to show only logs with GPS data
   - ✅ Empty state for journals without GPS logs
   - **See:** `docs/planning/mapview-implementation-plan.md` for full details

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

#### 3. Set up Log Model
**File:** `Models/Log.swift`
```swift
import SwiftData

@Model
class Log {
    var id: UUID
    var timestamp: Date
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var weatherCondition: String?
    var temperature: Double?
    var notes: String
    var mediaURLs: [URL]

    init() {
        self.id = UUID()
        self.timestamp = Date()
        self.notes = ""
        self.mediaURLs = []
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
        .modelContainer(for: [Journal.self, Log.self])
    }
}
```

#### 5. Build Dashboard Screen
**File:** `Views/DashboardView.swift`
- ✅ Create journal list UI (Scooters card style)
- ✅ Add "Create Journal" FAB button
- ✅ DashboardViewModel with MVVM pattern
- ✅ Add navigation to JournalTabView on card tap
- ✅ Add delete journal with confirmation
- ✅ **Password Protection Feature** (v1.5 enhancement)
  - ✅ KeychainManager with SHA256 password hashing + salt
  - ✅ Biometric authentication (Face ID/Touch ID) with password fallback
  - ✅ Brute force protection (5 attempts, 5-minute lockout)
  - ✅ Password-protected journal settings flow
  - ✅ Protocol-based dependency injection (testable architecture)
  - ✅ Comprehensive test coverage (43 unit tests across DashboardViewModel + KeychainManager)

**Implementation Notes:**

**Navigation to JournalTabView:**
```swift
// In DashboardView
NavigationStack {
    ScrollView {
        ForEach(viewModel.journals) { journal in
            JournalCardScootersStyle(journal: journal)
                .onTapGesture {
                    // Navigate to JournalTabView(journal: journal)
                }
        }
    }
}
```

**Delete with Context Menu:**
```swift
// In JournalCardScootersStyle
.contextMenu {
    Button(role: .destructive) {
        showDeleteConfirmation = true
    } label: {
        Label("Delete Journal", systemImage: "trash")
    }
}
.alert("Delete \(journal.name)?", isPresented: $showDeleteConfirmation) {
    Button("Cancel", role: .cancel) { }
    Button("Delete", role: .destructive) {
        viewModel.deleteJournal(journal)
    }
} message: {
    Text("This will permanently delete all logs in this journal.")
}
```

**DashboardViewModel delete function:**
```swift
func deleteJournal(_ journal: Journal) {
    modelContext.delete(journal)
    do {
        try modelContext.save()
        loadJournals()
    } catch {
        errorMessage = "Failed to delete journal: \(error.localizedDescription)"
    }
}
```

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

<key>NSCameraUsageDescription</key>
<string>We need access to your camera to capture photos for field observations.</string>

<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record audio memos for field notes.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>We need access to speech recognition to automatically transcribe your audio memos into searchable text.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to save and view field observation photos.</string>
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

#### 12. Save Log with Auto-populated Data
```swift
func createLog() {
    let log = Log()

    // Auto-populate GPS
    Task {
        do {
            let location = try await locationManager.getCurrentLocation()
            log.latitude = location.coordinate.latitude
            log.longitude = location.coordinate.longitude
            log.altitude = location.altitude
            log.locationError = nil

            // Auto-fetch weather
            do {
                let weather = try await weatherService.fetchWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                log.weather = weather
                log.weatherError = nil
            } catch {
                log.weatherError = error.localizedDescription
                // Show banner: "⚠️ Weather unavailable - Retry?"
            }
        } catch {
            log.locationError = error.localizedDescription
            // Show banner: "⚠️ Location unavailable - Retry?"
        }
    }

    log.notes = notes
    log.mediaURLs = mediaURLs

    // Validate before saving
    guard log.isValid else {
        showAlert("Please add notes before saving")
        return
    }

    modelContext.insert(log)
}

// Retry function
func retryLocation() {
    // Attempt to get location again and update log
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

#### 3. Fetch Weather on Log Creation
```swift
func createLog() async {
    let log = Log()

    if let location = locationManager.location {
        log.latitude = location.coordinate.latitude
        log.longitude = location.coordinate.longitude

        // Auto-fetch weather
        do {
            let weather = try await weatherService.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            log.weatherCondition = weather.condition
            log.temperature = weather.temperature
            log.humidity = weather.humidity
        } catch {
            print("Weather fetch failed: \(error)")
            // Continue without weather data
        }
    }

    // Validate before saving
    guard log.isValid else { return }

    modelContext.insert(log)
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

#### 5. Display Weather on Log Card
```swift
HStack {
    Image(systemName: log.weatherIcon)
        .font(.title2)
    Text("\(Int(log.temperature ?? 0))°C")
        .font(.headline)
    Text(log.weatherCondition ?? "N/A")
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

## Code Quality & Architecture Standards

### SwiftUI Architecture Review Process

After completing any UI screen or major component, run the SwiftUI architecture skills review to ensure code quality:

**Skills Location:** `/Users/davidcontreras/claude-skills/swiftui-architecture-patterns/`

**Review Checklist:**
- [ ] Run SwiftUI architecture patterns skill review
- [ ] Verify MVVM pattern compliance (@MainActor, @Published state)
- [ ] Check state management (@State, @StateObject, @ObservedObject)
- [ ] Validate navigation patterns (NavigationStack for iOS 16+)
- [ ] Ensure async/await patterns for data operations
- [ ] Confirm dependency injection patterns
- [ ] Review error handling implementation

**When to Run:**
- After building any new View or ViewModel
- Before committing UI changes
- During code review process
- When refactoring existing screens

**Reference Implementation:**
- Primary: Credit One Bank iOS (pure SwiftUI, iOS 16+)
- Secondary: Scooters Coffee iOS (hybrid SwiftUI/UIKit)
- Patterns: `~/.claude/skills/swiftui-architecture-patterns/swiftui-architecture-patterns.md`

---

## Next Steps

### Before Building
1. ✅ Review designs in Stitch with wife
2. ✅ Validate workflow with Phase 1 (stock iOS tools)
3. ✅ Test Phase 2 (low-code tools)
4. ✅ Sign up for weather API

### Start Building (v1.0)
1. ✅ Create Xcode project (Step 1)
2. ✅ Set up SwiftData models (Steps 2-4)
3. ✅ Build Dashboard screen (Step 5) - **MVVM refactored with password protection**
4. ✅ Add Dashboard interactions:
   - ✅ Tap gesture to JournalCard → Navigate to JournalTabView
   - ✅ Settings icon on card → Journal settings sheet
   - ✅ Delete confirmation alert
   - ✅ Password protection with biometric authentication
   - ✅ Brute force protection (lockout mechanism)
   - ✅ 43 unit tests (DashboardViewModel + KeychainManager)
5. 🔲 Integrate location services (Steps 7-8)
6. 🔲 **Integrate weather API (Step 9)**
7. 🔲 Build Entry screen (Steps 10-12)
8. 🔲 Build bottom navigation (Steps 13-16)
9. 🔲 Test offline + field conditions (Steps 18-20)

### Current Status (Updated 2026-05-19)

**Completed (v1.0 MVP Progress: 100% - Ready for Device Testing! 🚀):**
- ✅ Dashboard UI with modern card design
- ✅ Journal creation and management
- ✅ Repository pattern with SwiftData backend
- ✅ Password protection with Keychain integration
- ✅ Biometric authentication (Face ID/Touch ID)
- ✅ Comprehensive security (brute force protection, password hashing)
- ✅ Production-grade architecture (MVVM, DI, protocol-based testing)
- ✅ Test coverage: 43 unit tests across ViewModels and Services
- ✅ CoreLocation integration with GPS tracking
- ✅ Weather API integration (OpenWeatherMap)
- ✅ Air Quality API integration (AQI, PM2.5, PM10)
- ✅ New Log Entry screen (bento-style layout)
- ✅ Logs List View with featured and compact card variants
- ✅ **MapView with custom pins and callouts** (completed 2026-05-13)
- ✅ Bottom tab navigation
- ✅ SwiftData persistent storage with 6 sample logs
- ✅ 10-second API timeout pattern
- ✅ Proper async/await lifecycle management
- ✅ **Log Editing** with title/notes/timestamp/GPS/weather refresh (completed 2026-05-19)
- ✅ **Camera Integration** (completed 2026-05-13)
  - ✅ CameraPickerRepresentable and PhotoPickerRepresentable
  - ✅ PhotoStorageService for disk storage
  - ✅ PhotoGalleryView with TabView slider
  - ✅ Multiple photo support (up to 10 per selection)
  - ✅ Camera capture and photo library import
  - ✅ Add/delete photos with confirmation
- ✅ **Audio Memo Recording + Transcription** (completed 2026-05-19)
  - ✅ AudioMemo model with SwiftData relationships
  - ✅ MultiAudioMemoView component
  - ✅ Multiple memos per log with titles
  - ✅ Automatic speech-to-text transcription
  - ✅ Playback and deletion controls
  - ✅ Integrated in NewLogView and EditLogView

**Critical Blockers for v1.0 Launch: ✅ NONE - ALL FEATURES COMPLETE!**

**All v1.0 Features Implemented:**
1. ✅ **Log Editing** (completed 2026-05-19)
2. ✅ **Camera Integration** (completed 2026-05-13)
3. ✅ **Audio Memo Recording + Transcription** (completed 2026-05-19)

See **"Required for v1.0 Launch"** section above for detailed specs.

**Completed Post-Launch Features:**
1. ✅ **Search and Filter** (v1.x) - COMPLETED 2026-05-13
   - Dashboard: Search journals by name, sort by Most Recent/Oldest/A-Z/Z-A
   - Logs List: Search by notes/transcription, dynamic header, same sort options
   - Reusable components: SearchBar, FilterButton, FilterSheet, SortOption

**Post-Launch Features (Priority Order):**
1. 🔬 **Species Identification** (v1.1+) - ML-powered species recognition
2. 📤 **Export Functionality** (v1.2) - Share logs, CSV export, PDF reports
3. ☁️ **Cloud Sync** (v2.0) - Multi-device sync, team collaboration
4. 🌤️ **Update Weather Data During Edits** (v1.5) - Refresh weather snapshots
5. 📸 **Advanced Photo Gallery** (v1.x) - Full-screen viewer, annotations

**Ready for physical device testing! All v1.0 features complete! 🚀**
**Next Steps:** Device testing → TestFlight beta → v1.0 launch
