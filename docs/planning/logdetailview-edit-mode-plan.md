# LogDetailView Edit Mode Implementation Plan

**Date:** May 20, 2026
**Goal:** Convert LogDetailView from read-only to include inline edit mode, eliminating the need for EditLogView

---

## Executive Summary

Currently, EcoJournal has two separate views:
- **LogDetailView** - Read-only display with "Edit" button that navigates to EditLogView
- **EditLogView** - Full editing interface with all edit capabilities

**New Approach:**
- **LogDetailView only** - Toggle between view mode and edit mode with an `@State var isEditing` flag
- **Remove EditLogView** - Consolidate all functionality into one view
- **Fix audio playback** - Replace placeholder audio component with functional player

---

## Current Issues

1. **Audio Playback Broken:** LogDetailView uses `AudioMemoDisplayCard` with placeholder (TODO comment) play button
2. **Dual View Confusion:** Users navigate to separate view for editing instead of inline editing
3. **Code Duplication:** EditLogView duplicates much of LogDetailView's layout

---

## Implementation Strategy

### Phase 1: Add Edit Mode Toggle
Add `@State var isEditing = false` and modify "Edit Eco Journal" button to toggle this instead of navigating to EditLogView.

### Phase 2: Add State Management
Add all @State variables from EditLogView to manage edited content.

### Phase 3: Make Components Conditionally Editable
Replace static display components with conditional rendering based on `isEditing` flag.

### Phase 4: Add Audio Playback
Replace `AudioMemoDisplayCard` with `MultiAudioMemoView` (same component used in NewLogView and EditLogView).

### Phase 5: Add Services & Actions
Add required services (WeatherService, AirQualityService, LocationManager) and action methods.

### Phase 6: Remove EditLogView
Delete EditLogView.swift and update all navigation references.

---

## Detailed Changes Required

### 1. State Variables to Add

**Editable Content:**
```swift
@State private var editedTitle: String
@State private var editedNotes: String
@State private var editedPhotoURLs: [URL]
@State private var editedTimestamp: Date
@State private var editedLatitude: Double?
@State private var editedLongitude: Double?
@State private var editedAltitude: Double?
```

**UI State:**
```swift
@State private var isEditing = false  // NEW: Edit mode toggle
@State private var showingGPSRefreshAlert = false
@State private var showingWeatherRefreshAlert = false
@State private var isRefreshingGPS = false
@State private var isRefreshingWeather = false
@State private var weatherRefreshError: String?
```

**Existing (keep):**
```swift
@State private var showingDeleteConfirmation = false
@State private var deleteConfirmationText = ""
@State private var selectedPhotoIndex: Int = 0
```

**Remove:**
```swift
@State private var showingEditView = false  // DELETE: No longer navigating to EditLogView
```

---

### 2. Service Dependencies to Add

**Add @StateObject:**
```swift
@StateObject private var locationManager = LocationManager()
```

**Add Service Instances:**
```swift
private let weatherService: WeatherService
private let airQualityService: AirQualityService
```

**Update init:**
```swift
init(log: Log, journal: Journal) {
    self.log = log
    self.journal = journal

    // Initialize services
    let apiKey = "e4fe2848d6d479aa409cdcf5937e7e7c"
    self.weatherService = WeatherService(apiKey: apiKey)
    self.airQualityService = AirQualityService(apiKey: apiKey)

    // Pre-populate editable fields with current log values
    _editedTitle = State(initialValue: log.title)
    _editedNotes = State(initialValue: log.notes)
    _editedPhotoURLs = State(initialValue: log.mediaURLs)
    _editedTimestamp = State(initialValue: log.timestamp)
    _editedLatitude = State(initialValue: log.latitude)
    _editedLongitude = State(initialValue: log.longitude)
    _editedAltitude = State(initialValue: log.altitude)
}
```

---

### 3. Component Changes by Section

#### A. Title Section (Lines 296-309)

**Current (View Mode):**
```swift
Text(log.title)
    .font(.display(28, weight: .black))
    .foregroundColor(.onBackground)
```

**New (Conditional):**
```swift
if isEditing {
    VStack(alignment: .leading, spacing: 8) {
        Text("TITLE")
            .font(.label(11, weight: .bold))
            .foregroundColor(.tertiary)
            .tracking(1.5)

        TextField("Enter log title...", text: $editedTitle)
            .font(.body(16, weight: .semibold))
            .textFieldStyle(.plain)
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(editedTitle.isEmpty ? Color.error.opacity(0.5) : Color.outlineVariant, lineWidth: 1)
            )
    }
} else {
    Text(log.title)
        .font(.display(28, weight: .black))
        .foregroundColor(.onBackground)
}
```

---

#### B. Timestamp Section (New - Add above title in edit mode)

**Add in Edit Mode Only:**
```swift
if isEditing {
    VStack(alignment: .leading, spacing: 8) {
        Text("TIMESTAMP")
            .font(.label(11, weight: .bold))
            .foregroundColor(.tertiary)
            .tracking(1.5)

        DatePicker("", selection: $editedTimestamp, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.outlineVariant, lineWidth: 1)
            )
    }
    .padding(.horizontal, 24)
}
```

---

#### C. Photo Gallery (Lines 117-292 - Hero Section)

**Current:** Display-only hero image with thumbnails
**New:** Keep same display in view mode, use `PhotoGalleryView` in edit mode

**Modification:**
```swift
private var heroSection: some View {
    if isEditing {
        // Edit mode: Editable photo gallery
        VStack(alignment: .leading, spacing: 8) {
            Text("PHOTOS")
                .font(.label(11, weight: .bold))
                .foregroundColor(.tertiary)
                .tracking(1.5)
                .padding(.horizontal, 24)

            PhotoGalleryView(photoURLs: $editedPhotoURLs)
        }
    } else {
        // View mode: Immersive hero display (existing code)
        if !log.mediaURLs.isEmpty {
            // ... existing hero section code (lines 117-292)
        }
    }
}
```

---

#### D. Eco Journals Section (Lines 313-330)

**Current (View Mode):**
```swift
Text(log.notes)
    .font(.body(16))
    .foregroundColor(.onSurface)
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.surfaceContainerLow)
    .cornerRadius(16)
```

**New (Conditional):**
```swift
if isEditing {
    VStack(alignment: .leading, spacing: 8) {
        Text("FIELD NOTES")
            .font(.label(11, weight: .bold))
            .foregroundColor(.tertiary)
            .tracking(1.5)

        TextField("Enter your observations...", text: $editedNotes, axis: .vertical)
            .font(.body(15))
            .lineLimit(6...10)
            .textFieldStyle(.plain)
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.outlineVariant, lineWidth: 1)
            )
    }
} else {
    VStack(alignment: .leading, spacing: 12) {
        sectionHeader(icon: "note.text", title: "Eco Journals")

        Text(log.notes)
            .font(.body(16))
            .foregroundColor(.onSurface)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceContainerLow)
            .cornerRadius(16)
    }
}
```

---

#### E. Audio Memos Section (Lines 333-344) **CRITICAL FIX**

**Current (Broken Playback):**
```swift
ForEach(Array(log.audioMemos.enumerated()), id: \.element.id) { index, memo in
    AudioMemoDisplayCard(memo: memo, index: index + 1)
    // ↑ Placeholder component with TODO comment on play button
}
```

**New (Functional Playback in Both Modes):**
```swift
private var fieldObservationsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        sectionHeader(icon: "waveform", title: "Field Observations")

        if isEditing {
            // Edit mode: Full recording/playback/delete capabilities
            MultiAudioMemoView(audioMemos: audioMemosBinding)
        } else {
            // View mode: Playback-only (no recording/delete)
            if !log.audioMemos.isEmpty {
                MultiAudioMemoView(audioMemos: audioMemosBinding)
                    .disabled(true) // Disable recording/delete in view mode
                // OR: Create read-only variant that only shows play controls
            }
        }
    }
}

private var audioMemosBinding: Binding<[AudioMemo]> {
    Binding(
        get: { isEditing ? log.audioMemos : log.audioMemos },
        set: { if isEditing { log.audioMemos = $0 } }
    )
}
```

**Alternative Approach (Cleaner):**
Use `MultiAudioMemoView` in both modes but pass a `readOnly` parameter:

```swift
// Modify MultiAudioMemoView to accept readOnly flag
MultiAudioMemoView(
    audioMemos: audioMemosBinding,
    readOnly: !isEditing  // Hide record/delete buttons in view mode
)
```

---

#### F. GPS/Location Section (Lines 386-435)

**Current (View Mode):** Map display with metadata overlay

**New (Edit Mode):** Use `GPSTelemetryCard` with refresh capability

```swift
if isEditing {
    VStack(alignment: .leading, spacing: 8) {
        Text("GPS COORDINATES")
            .font(.label(11, weight: .bold))
            .foregroundColor(.tertiary)
            .tracking(1.5)

        GPSTelemetryCard(
            location: currentLocation,
            isLoading: isRefreshingGPS,
            error: nil,
            onRefresh: {
                showingGPSRefreshAlert = true
            }
        )
    }
} else {
    // View mode: Existing map display (lines 386-435)
    VStack(alignment: .leading, spacing: 12) {
        sectionHeader(icon: "location.fill", title: "Location")
        // ... existing map code
    }
}

private var currentLocation: CLLocation? {
    guard let lat = editedLatitude ?? log.latitude,
          let lon = editedLongitude ?? log.longitude else { return nil }
    return CLLocation(latitude: lat, longitude: lon)
}
```

---

#### G. Weather Section (Lines 348-382)

**Current (View Mode):** Telemetry cards in grid

**New (Edit Mode):** Use `WeatherDataCard` with refresh capability

```swift
if isEditing {
    VStack(alignment: .leading, spacing: 8) {
        Text("WEATHER DATA")
            .font(.label(11, weight: .bold))
            .foregroundColor(.tertiary)
            .tracking(1.5)

        WeatherDataCard(
            weather: log.weather,
            location: currentLocation,
            isLoading: isRefreshingWeather,
            error: weatherRefreshError,
            onRefresh: {
                showingWeatherRefreshAlert = true
            }
        )

        if log.weather != nil {
            Text("CAPTURED AT \(log.timestamp.formatted(date: .abbreviated, time: .shortened))")
                .font(.label(10, weight: .bold))
                .foregroundColor(.tertiary)
        }
    }
} else {
    // View mode: Existing telemetry grid (lines 348-382)
    VStack(alignment: .leading, spacing: 12) {
        sectionHeader(icon: "cloud.sun.fill", title: "Telemetry Data")
        // ... existing telemetry cards
    }
}
```

---

### 4. Action Buttons Section (Lines 439-480)

**Current:**
- "Edit Eco Journal" button → navigates to EditLogView
- "Delete Log Entry" button

**New:**
```swift
private var actionButtons: some View {
    VStack(spacing: 16) {
        if isEditing {
            // Save Changes Button
            Button(action: saveChanges) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text("Save Changes")
                        .font(.display(18, weight: .bold))
                }
                .foregroundColor(.onPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(isValid ? Color.primaryColor : Color.outlineVariant)
                .cornerRadius(12)
                .shadow(color: Color.primaryColor.opacity(isValid ? 0.2 : 0), radius: 8, x: 0, y: 4)
            }
            .disabled(!isValid)
            .scaleEffect(isValid ? 1.0 : 0.98)
            .animation(.easeInOut(duration: 0.2), value: isValid)

            // Cancel Button
            Button(action: {
                cancelEditing()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                    Text("Cancel")
                        .font(.body(16, weight: .bold))
                }
                .foregroundColor(.onSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.surfaceContainerHigh)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.outlineVariant.opacity(0.5), lineWidth: 1)
                )
            }
        } else {
            // Edit Button (View Mode)
            Button(action: {
                isEditing = true  // Toggle edit mode instead of navigating
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18))
                    Text("Edit Eco Journal")
                        .font(.body(16, weight: .bold))
                }
                .foregroundColor(.onSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.surfaceContainerHigh)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.outlineVariant.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
        }

        // Delete Button (Always visible)
        Button(action: {
            showingDeleteConfirmation = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 16))
                Text("Delete Log Entry")
                    .font(.body(15, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red)
            .cornerRadius(24)
        }
    }
}
```

---

### 5. New Methods to Add

#### Save Changes
```swift
private func saveChanges() {
    // Validate
    guard isValid else { return }

    // Apply edits to log
    log.title = editedTitle
    log.notes = editedNotes
    log.mediaURLs = editedPhotoURLs
    log.timestamp = editedTimestamp
    log.latitude = editedLatitude
    log.longitude = editedLongitude
    log.altitude = editedAltitude
    // Audio memos edited directly through binding

    // Exit edit mode
    isEditing = false
}
```

#### Cancel Editing
```swift
private func cancelEditing() {
    // Reset all edited fields to original values
    editedTitle = log.title
    editedNotes = log.notes
    editedPhotoURLs = log.mediaURLs
    editedTimestamp = log.timestamp
    editedLatitude = log.latitude
    editedLongitude = log.longitude
    editedAltitude = log.altitude

    // Exit edit mode
    isEditing = false
}
```

#### Form Validation
```swift
private var isValid: Bool {
    !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}
```

#### Refresh GPS (from EditLogView)
```swift
private func refreshGPSCoordinates() {
    isRefreshingGPS = true
    locationManager.startUpdatingLocation()

    Task {
        var attempts = 0
        while attempts < 20 { // 10 seconds max
            try? await Task.sleep(nanoseconds: 500_000_000)

            if let location = locationManager.location {
                await MainActor.run {
                    editedLatitude = location.coordinate.latitude
                    editedLongitude = location.coordinate.longitude
                    editedAltitude = location.altitude
                    isRefreshingGPS = false
                }
                return
            }
            attempts += 1
        }

        await MainActor.run {
            isRefreshingGPS = false
        }
    }
}
```

#### Refresh Weather (from EditLogView)
```swift
private func refreshWeatherData() {
    guard let lat = editedLatitude, let lon = editedLongitude else { return }

    isRefreshingWeather = true
    weatherRefreshError = nil

    Task {
        do {
            let location = CLLocation(latitude: lat, longitude: lon)

            // Fetch weather and air quality with timeout
            let (weather, airQuality) = try await withTimeout(seconds: 10) {
                async let weatherData = weatherService.fetchWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )

                async let airQualityData = airQualityService.fetchAirQuality(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )

                return try await (weatherData, airQualityData)
            }

            // Combine data
            let combinedWeather = Weather(
                condition: weather.condition,
                temperature: weather.temperature,
                humidity: weather.humidity,
                windSpeed: weather.windSpeed,
                icon: weather.icon,
                aqi: airQuality.aqi,
                pm25: airQuality.pm25,
                pm10: airQuality.pm10
            )

            await MainActor.run {
                log.weather = combinedWeather
                isRefreshingWeather = false
            }
        } catch {
            await MainActor.run {
                weatherRefreshError = error.localizedDescription
                isRefreshingWeather = false
            }
        }
    }
}

// Timeout helper (from EditLogView)
private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw NSError(domain: "Timeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
        }

        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
```

---

### 6. Alert Dialogs to Add

**GPS Refresh Alert:**
```swift
.alert("Refresh GPS Coordinates?", isPresented: $showingGPSRefreshAlert) {
    Button("Cancel", role: .cancel) { }
    Button("Refresh") {
        refreshGPSCoordinates()
    }
} message: {
    Text("This will update GPS coordinates with your current location.")
}
```

**Weather Refresh Alert:**
```swift
.alert("Refresh Weather Data?", isPresented: $showingWeatherRefreshAlert) {
    Button("Cancel", role: .cancel) { }
    Button("Refresh") {
        refreshWeatherData()
    }
} message: {
    Text("This will replace weather from \(log.timestamp.formatted(date: .abbreviated, time: .shortened)) with current conditions at this location.")
}
```

---

### 7. Navigation Changes to Remove

**Delete from LogDetailView:**
```swift
// Lines 96-98 - DELETE THIS
.navigationDestination(isPresented: $showingEditView) {
    EditLogView(log: log, journal: journal)
}
```

**Update MapView.swift:**
```swift
// Line 289 - Already fixed to use LogDetailView (done earlier)
NavigationLink(destination: LogDetailView(log: log, journal: journal)) {
    // ... button content
}
```

**Update LogsListView.swift:**
```swift
// Line 109-111 - Already correct, uses LogDetailView
.navigationDestination(item: $selectedLog) { log in
    LogDetailView(log: log, journal: journal)
}
```

---

## Phase-by-Phase Implementation

### Phase 1: Setup (30 min)
- [ ] Add `@State var isEditing = false`
- [ ] Add all @State variables for edited fields
- [ ] Add @StateObject locationManager
- [ ] Add service instances (weatherService, airQualityService)
- [ ] Update init to pre-populate edited fields
- [ ] Remove `@State var showingEditView`
- [ ] Remove `.navigationDestination` for EditLogView

**Estimated Time:** 30 minutes

---

### Phase 2: Action Buttons (15 min)
- [ ] Update "Edit Eco Journal" button to set `isEditing = true`
- [ ] Add conditional rendering (edit mode shows Save/Cancel, view mode shows Edit/Delete)
- [ ] Add `saveChanges()` method
- [ ] Add `cancelEditing()` method
- [ ] Add `isValid` computed property

**Estimated Time:** 15 minutes

---

### Phase 3: Title & Timestamp (20 min)
- [ ] Make title section conditional (TextField in edit mode, Text in view mode)
- [ ] Add timestamp DatePicker section (edit mode only)
- [ ] Test validation feedback on empty title

**Estimated Time:** 20 minutes

---

### Phase 4: Eco Journals (15 min)
- [ ] Make notes section conditional (TextField in edit mode, Text in view mode)
- [ ] Configure multi-line TextField with 6-10 line limit

**Estimated Time:** 15 minutes

---

### Phase 5: Photos (30 min)
- [ ] Make hero section conditional
- [ ] In edit mode: use `PhotoGalleryView(photoURLs: $editedPhotoURLs)`
- [ ] In view mode: keep existing hero image display
- [ ] Test camera/library integration
- [ ] Test photo deletion

**Estimated Time:** 30 minutes

---

### Phase 6: Audio Memos (CRITICAL - 45 min)
- [ ] Replace `AudioMemoDisplayCard` with `MultiAudioMemoView`
- [ ] Add `audioMemosBinding` computed property
- [ ] Option A: Use `MultiAudioMemoView` in both modes with conditional features
- [ ] Option B: Modify `MultiAudioMemoView` to accept `readOnly: Bool` parameter
- [ ] Test audio playback in view mode
- [ ] Test audio recording in edit mode
- [ ] Test audio deletion in edit mode
- [ ] Verify transcription works

**Estimated Time:** 45 minutes

---

### Phase 7: GPS & Location (30 min)
- [ ] Make location section conditional
- [ ] In edit mode: use `GPSTelemetryCard` with refresh button
- [ ] In view mode: keep existing map display
- [ ] Add `currentLocation` computed property
- [ ] Add `refreshGPSCoordinates()` method
- [ ] Add GPS refresh alert
- [ ] Test GPS refresh functionality

**Estimated Time:** 30 minutes

---

### Phase 8: Weather (30 min)
- [ ] Make weather section conditional
- [ ] In edit mode: use `WeatherDataCard` with refresh button
- [ ] In view mode: keep existing telemetry grid
- [ ] Add `refreshWeatherData()` method
- [ ] Add `withTimeout()` helper function
- [ ] Add weather refresh alert
- [ ] Test weather refresh functionality
- [ ] Test timeout handling

**Estimated Time:** 30 minutes

---

### Phase 9: Testing & Polish (1 hour)
- [ ] Test full edit workflow (view → edit → save)
- [ ] Test cancel workflow (view → edit → cancel → verify no changes)
- [ ] Test validation (empty title prevents save)
- [ ] Test all refresh buttons (GPS, weather)
- [ ] Test photo add/delete
- [ ] Test audio record/play/delete
- [ ] Test delete log entry
- [ ] Test on device (not just simulator)
- [ ] Verify SwiftData persistence
- [ ] Check for memory leaks
- [ ] Verify UI performance

**Estimated Time:** 1 hour

---

### Phase 10: Remove EditLogView (15 min)
- [ ] Delete `EditLogView.swift` file
- [ ] Search codebase for any remaining references to EditLogView
- [ ] Verify no build errors
- [ ] Update any documentation mentioning EditLogView

**Estimated Time:** 15 minutes

---

## Total Estimated Time

| Phase | Time |
|-------|------|
| 1. Setup | 30 min |
| 2. Action Buttons | 15 min |
| 3. Title & Timestamp | 20 min |
| 4. Eco Journals | 15 min |
| 5. Photos | 30 min |
| 6. Audio Memos | 45 min |
| 7. GPS & Location | 30 min |
| 8. Weather | 30 min |
| 9. Testing & Polish | 60 min |
| 10. Remove EditLogView | 15 min |
| **Total** | **~4.5 hours** |

---

## Key Risks & Mitigations

### Risk 1: Audio Playback Still Broken
**Mitigation:** Use exact same `MultiAudioMemoView` component that works in NewLogView and EditLogView. No custom implementation.

### Risk 2: State Management Complexity
**Mitigation:** Follow exact pattern from EditLogView. Pre-populate all @State variables in init(), use bindings for audio memos.

### Risk 3: SwiftData Update Conflicts
**Mitigation:** Only update log properties in `saveChanges()`, not incrementally. Cancel editing restores original values.

### Risk 4: UI Performance with Conditional Rendering
**Mitigation:** Keep conditional checks at section level, not per-component. Use `@ViewBuilder` for clarity.

---

## Success Criteria

**✅ Feature Complete When:**
1. LogDetailView has functioning "Edit Eco Journal" button that toggles edit mode
2. All 7 fields are editable in edit mode (title, timestamp, notes, photos, audio, GPS, weather)
3. Audio playback works in both view and edit modes
4. Save Changes applies all edits to log
5. Cancel discards all edits and returns to view mode
6. Form validation prevents saving with empty title
7. GPS and weather refresh buttons work
8. EditLogView.swift is deleted with no references remaining
9. All navigation flows through LogDetailView only

---

## Files to Modify

1. **LogDetailView.swift** - Main implementation (~500 lines of changes)
2. **MapView.swift** - Already updated (confirmed navigation to LogDetailView)
3. **LogsListView.swift** - Already correct (uses LogDetailView)

## Files to Delete

1. **EditLogView.swift** - Remove entire file after LogDetailView is complete

---

## Post-Implementation Documentation Updates

- [ ] Update README.md to reflect single-view architecture
- [ ] Update architecture.md to document edit mode toggle pattern
- [ ] Remove references to EditLogView from all docs
- [ ] Add screenshot of edit mode in action

---

**Status:** Planning Complete
**Ready for Implementation:** Yes
**Estimated Completion:** 4-5 hours of development + testing

**Last Updated:** May 20, 2026
