# MapView Implementation Plan

## Overview
Build MapKit integration for visualizing log entries on a map with custom pins, clustering, and navigation to log details.

**Goal:** Implement 95% in simulator using programmatic/mock data, swap to real data when ready.

**Status:** ✅ COMPLETED (2026-05-13)

---

## Phase 1: Map Foundation (100% Simulator) ✅ COMPLETED

### 1.1 Basic Map Display
**File:** `Views/Tabs/MapView.swift`

**Implementation:**
```swift
import SwiftUI
import MapKit

struct MapView: View {
    let journal: Journal

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.8597, longitude: -123.9346),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var mapStyle: MapStyle = .standard
    @State private var selectedLog: Log?

    var body: some View {
        // Map implementation
    }
}
```

**Features:**
- [x] Map view with configurable region
- [x] Map style picker (standard, satellite, hybrid)
- [x] Filter logs with GPS data only
- [x] Handle empty state (no logs with GPS)

**Testing:** ✅ Simulator only
- View different map styles
- Test empty state rendering
- Verify region calculations

---

### 1.2 Mock Data Setup
**Strategy:** Use static coordinates for Olympic National Park area

**Mock Logs:**
```swift
extension Log {
    static let mockLogs = [
        Log(notes: "Found rare moss species near creek",
            latitude: 47.8597, longitude: -123.9346, altitude: 182.0),
        Log(notes: "Water quality sample - pH 7.2",
            latitude: 47.8612, longitude: -123.9361, altitude: 156.0),
        Log(notes: "Eagle nest spotted in old growth Douglas fir",
            latitude: 47.8585, longitude: -123.9320, altitude: 210.0),
        Log(notes: "Trail erosion assessment point A",
            latitude: 47.8620, longitude: -123.9380, altitude: 145.0),
        Log(notes: "Invasive plant species documented",
            latitude: 47.8575, longitude: -123.9355, altitude: 175.0),
    ]
}
```

**Testing:** ✅ Simulator only
- Verify pins appear at correct coordinates
- Check spacing/clustering behavior

---

## Phase 2: Custom Annotations (100% Simulator) ✅

### 2.1 Log Annotation Model
**File:** `Models/LogAnnotation.swift`

**Implementation:**
```swift
import MapKit

struct LogAnnotation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let log: Log

    init(log: Log) {
        self.id = log.id
        self.log = log
        self.coordinate = CLLocationCoordinate2D(
            latitude: log.latitude ?? 0,
            longitude: log.longitude ?? 0
        )
    }
}
```

**Features:**
- [x] Conforms to `Identifiable` for SwiftUI
- [x] Wraps Log model for map display
- [x] Provides coordinate for MapKit

**Testing:** ✅ Simulator only
- Unit tests for annotation creation
- Verify coordinate extraction

---

### 2.2 Custom Pin View
**File:** `Views/Components/LogMapPin.swift`

**Implementation:**
```swift
struct LogMapPin: View {
    let log: Log
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Pin icon with log indicator
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)

                Image(systemName: pinIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)

            // Pin stem
            Rectangle()
                .fill(pinColor)
                .frame(width: 2, height: 12)
        }
    }

    private var pinColor: Color {
        // Color based on log properties
        if log.weather != nil {
            return .blue
        } else if log.mediaURLs.isEmpty == false {
            return .green
        } else {
            return .orange
        }
    }

    private var pinIcon: String {
        // Icon based on log content
        if log.audioMemoURL != nil {
            return "mic.fill"
        } else if !log.mediaURLs.isEmpty {
            return "camera.fill"
        } else {
            return "note.text"
        }
    }
}
```

**States to Preview:**
- Log with weather data (blue pin)
- Log with photos (green pin, camera icon)
- Log with audio (any color, mic icon)
- Log with just notes (orange pin)
- Selected vs unselected state

**Testing:** ✅ Simulator only
- All pin color variations
- All icon variations
- Selected state animation

---

### 2.3 Pin Callout/Detail View
**File:** `Views/Components/LogMapCallout.swift`

**Implementation:**
```swift
struct LogMapCallout: View {
    let log: Log
    let onNavigate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Photo thumbnail (if available)
                if let firstPhotoURL = log.mediaURLs.first {
                    AsyncImage(url: firstPhotoURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    // First line of notes
                    Text(log.notes.components(separatedBy: ".").first ?? log.notes)
                        .font(.body(14, weight: .semibold))
                        .lineLimit(2)

                    // Timestamp
                    Text(log.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption(12))
                        .foregroundColor(.secondary)

                    // Weather indicator
                    if let weather = log.weather {
                        HStack(spacing: 4) {
                            Image(systemName: "thermometer.medium")
                                .font(.system(size: 10))
                            Text(String(format: "%.0f°F", (weather.temperature * 9/5) + 32))
                                .font(.caption(12))
                        }
                        .foregroundColor(.blue)
                    }
                }

                Spacer()
            }

            // Navigation button
            Button(action: onNavigate) {
                HStack {
                    Text("View Details")
                    Image(systemName: "arrow.right")
                }
                .font(.caption(12, weight: .medium))
                .foregroundColor(.primaryColor)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(width: 280)
    }
}
```

**States to Preview:**
- Log with photo thumbnail
- Log without photo
- Log with weather data
- Log without weather data
- Long vs short notes

**Testing:** ✅ Simulator only
- All content variations
- Tap "View Details" navigation
- Callout sizing/layout

---

## Phase 3: Map Interactions (100% Simulator) ✅

### 3.1 Pin Selection & Navigation

**Implementation in MapView:**
```swift
struct MapView: View {
    // ... existing state ...
    @State private var selectedLog: Log?

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    LogMapPin(log: annotation.log, isSelected: selectedLog?.id == annotation.log.id)
                        .onTapGesture {
                            withAnimation {
                                selectedLog = annotation.log
                            }
                        }
                }
            }

            // Callout overlay
            if let selectedLog = selectedLog {
                VStack {
                    Spacer()
                    LogMapCallout(log: selectedLog) {
                        navigateToLog(selectedLog)
                    }
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationDestination(item: $navigationLog) { log in
            EditLogView(log: log, journal: journal)
        }
    }

    private func navigateToLog(_ log: Log) {
        navigationLog = log
    }
}
```

**Testing:** ✅ Simulator only
- Tap pin to select
- Tap outside to deselect
- Callout appears/disappears with animation
- Navigate to EditLogView

---

### 3.2 Map Controls

**Implementation:**
```swift
// Overlay controls on map
VStack {
    HStack {
        Spacer()

        VStack(spacing: 12) {
            // Map style picker
            Button(action: cycleMapStyle) {
                Image(systemName: mapStyleIcon)
                    .font(.system(size: 20))
                    .foregroundColor(.primaryColor)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }

            // Center on location
            Button(action: centerOnCurrentLocation) {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.primaryColor)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }

            // Zoom to fit all pins
            Button(action: zoomToFitAllLogs) {
                Image(systemName: "scope")
                    .font(.system(size: 20))
                    .foregroundColor(.primaryColor)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
        }
        .padding(.trailing, 16)
    }
    Spacer()
}
```

**Features:**
- [x] Map style toggle (standard → satellite → hybrid)
- [x] Center on current location (uses mock location in simulator)
- [x] Zoom to fit all pins

**Testing:** ✅ Simulator only
- Cycle through map styles
- Verify zoom calculations
- Test with 1 pin vs many pins

---

## Phase 4: Empty & Error States (100% Simulator) ✅

### 4.1 Empty State
**Scenario:** Journal has logs but none with GPS coordinates

**Implementation:**
```swift
if logsWithGPS.isEmpty {
    VStack(spacing: 16) {
        Image(systemName: "map")
            .font(.system(size: 60))
            .foregroundColor(.tertiary)

        VStack(spacing: 8) {
            Text("No GPS Data")
                .font(.headline(20, weight: .bold))

            Text("Logs will appear on the map once GPS coordinates are captured")
                .font(.body(15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}
```

**Testing:** ✅ Simulator only

---

### 4.2 Loading State
**Scenario:** Fetching logs / calculating map region

**Implementation:**
```swift
if isLoadingLogs {
    VStack(spacing: 16) {
        ProgressView()
            .scaleEffect(1.5)
        Text("Loading map...")
            .font(.body(15))
            .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}
```

**Testing:** ✅ Simulator only

---

## Phase 5: Data Integration (90% Simulator) ✅

### 5.1 Use Real Journal Logs

**Before (Mock Data):**
```swift
private var annotations: [LogAnnotation] {
    Log.mockLogs.map { LogAnnotation(log: $0) }
}
```

**After (Real Data):**
```swift
private var annotations: [LogAnnotation] {
    journal.logs
        .filter { $0.latitude != nil && $0.longitude != nil }
        .map { LogAnnotation(log: $0) }
}
```

**Testing:**
- ✅ Simulator with mock journal data
- ⚠️ Device recommended for real GPS-captured logs

---

### 5.2 Center Map on Logs

**Implementation:**
```swift
private func calculateMapRegion() -> MKCoordinateRegion {
    let logsWithGPS = journal.logs.filter { $0.latitude != nil }

    guard !logsWithGPS.isEmpty else {
        // Default to current location or preset coordinates
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.8597, longitude: -123.9346),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }

    let coordinates = logsWithGPS.compactMap { log -> CLLocationCoordinate2D? in
        guard let lat = log.latitude, let lon = log.longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    // Calculate bounding box
    let minLat = coordinates.map { $0.latitude }.min() ?? 0
    let maxLat = coordinates.map { $0.latitude }.max() ?? 0
    let minLon = coordinates.map { $0.longitude }.min() ?? 0
    let maxLon = coordinates.map { $0.longitude }.max() ?? 0

    let center = CLLocationCoordinate2D(
        latitude: (minLat + maxLat) / 2,
        longitude: (minLon + maxLon) / 2
    )

    let span = MKCoordinateSpan(
        latitudeDelta: (maxLat - minLat) * 1.5, // 1.5x padding
        longitudeDelta: (maxLon - minLon) * 1.5
    )

    return MKCoordinateRegion(center: center, span: span)
}
```

**Testing:** ✅ Simulator only

---

## Phase 6: Polish & Performance (100% Simulator) ✅

### 6.1 Pin Clustering (Optional)
**For:** Dense log areas (20+ logs in small area)

**Implementation:**
```swift
// Use native MapKit clustering
Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
    MapAnnotation(coordinate: annotation.coordinate) {
        LogMapPin(log: annotation.log, isSelected: selectedLog?.id == annotation.log.id)
            .onTapGesture {
                selectedLog = annotation.log
            }
    }
}
.mapStyle(.standard(pointsOfInterest: .excludingAll))
```

**Testing:** ✅ Simulator with 50+ mock logs

---

### 6.2 Smooth Animations

**Features:**
- [x] Pin selection animation (scale up)
- [x] Callout slide-up animation
- [x] Map region changes (animated)

**Testing:** ✅ Simulator only

---

## Preview Requirements

### Component Previews (Must Have)

**LogMapPin Preview:**
```swift
#Preview {
    VStack(spacing: 20) {
        LogMapPin(log: Log(notes: "With weather", weather: mockWeather), isSelected: false)
        LogMapPin(log: Log(notes: "With photo", mediaURLs: [URL(string: "test")!]), isSelected: false)
        LogMapPin(log: Log(notes: "Selected"), isSelected: true)
    }
    .padding()
}
```

**LogMapCallout Preview:**
```swift
#Preview {
    VStack(spacing: 20) {
        LogMapCallout(log: mockLogWithPhoto, onNavigate: {})
        LogMapCallout(log: mockLogWithoutPhoto, onNavigate: {})
        LogMapCallout(log: mockLogLongNotes, onNavigate: {})
    }
    .padding()
}
```

**MapView Previews:**
```swift
#Preview("Empty - No GPS") {
    MapView(journal: Journal(name: "Empty"))
}

#Preview("Single Log") {
    let journal = Journal(name: "Test")
    journal.logs.append(Log.mockLogs[0])
    return MapView(journal: journal)
}

#Preview("Multiple Logs") {
    let journal = Journal(name: "Olympic NP")
    journal.logs.append(contentsOf: Log.mockLogs)
    return MapView(journal: journal)
}

#Preview("Dense Cluster") {
    let journal = Journal(name: "Dense Area")
    journal.logs.append(contentsOf: Log.mockLogsCluster) // 50+ logs
    return MapView(journal: journal)
}
```

---

## Testing Matrix

### Simulator Testing (Can Complete 100%)

| Feature | Test Case | Status |
|---------|-----------|--------|
| Map Display | Standard style | ✅ |
| Map Display | Satellite style | ✅ |
| Map Display | Hybrid style | ✅ |
| Pins | Appear at coordinates | ✅ |
| Pins | Color coding (weather/photo/audio) | ✅ |
| Pins | Selection animation | ✅ |
| Callout | Shows on pin tap | ✅ |
| Callout | Displays log preview | ✅ |
| Callout | Navigation to EditLogView | ✅ |
| Controls | Map style toggle | ✅ |
| Controls | Zoom to fit | ✅ |
| Controls | Center on location (mock) | ✅ |
| Empty State | No logs with GPS | ✅ |
| Edge Cases | 1 log | ✅ |
| Edge Cases | 100+ logs | ✅ |
| Performance | Smooth scrolling | ✅ |
| Performance | Pin clustering | ✅ |

---

### Device Testing (Required for Production)

| Feature | Why Device Needed | Priority |
|---------|------------------|----------|
| GPS Accuracy | Verify pin placement matches field location | HIGH |
| Battery Impact | Location services drain test | MEDIUM |
| Outdoor Performance | Map rendering in sunlight | LOW |
| Real Location Updates | Blue dot movement | LOW |

**Testing Notes:**
- ⚠️ **GPS Accuracy:** Critical for field use - pins must be accurate
- ⚠️ **Battery Impact:** Monitor during multi-hour field sessions
- ℹ️ **Outdoor Performance:** Nice-to-have but not critical
- ℹ️ **Real Location Updates:** Simulated location works fine for MVP

---

## Implementation Timeline

### Week 1: Foundation (100% Simulator)
- Day 1: Map display + styles
- Day 2: Mock data + basic pins
- Day 3: Custom pin design

### Week 2: Interactions (100% Simulator)
- Day 4: Pin selection + callouts
- Day 5: Navigation to EditLogView
- Day 6: Map controls (zoom, center, style)

### Week 3: Polish (100% Simulator)
- Day 7: Empty/loading states
- Day 8: Animations + transitions
- Day 9: Real data integration
- Day 10: Performance testing (100+ pins)

### Week 4: Device Testing (Device Required)
- Day 11-14: Field testing with real GPS logs

---

## Risk Assessment

### Low Risk (Simulator Sufficient)
- ✅ Map rendering
- ✅ Pin placement with coordinates
- ✅ UI interactions (tap, zoom, pan)
- ✅ Callout display
- ✅ Navigation flow
- ✅ Animations

### Medium Risk (Simulator OK, Device Recommended)
- ⚠️ Pin clustering performance with 100+ logs
- ⚠️ Memory usage with large datasets
- ⚠️ Map tile caching

### High Risk (Device Required)
- ❌ GPS accuracy (pins match real location)
- ❌ Battery drain during field use
- ❌ Outdoor visibility (glare, rain)

---

## Success Criteria

### MVP (Can Ship with Simulator Testing)
- [x] Map displays logs as pins
- [x] Pins show log preview on tap
- [x] Navigate to log detail from map
- [x] Empty state when no GPS data
- [x] Zoom/pan/style controls work
- [x] Smooth animations
- [x] All preview states documented

### Production Ready (Device Testing Required)
- [ ] GPS accuracy verified in field
- [ ] Battery impact acceptable (<10% drain/hour)
- [ ] Works in outdoor conditions (tested)

---

## Component Refactoring Opportunities

Based on preview requirements, consider extracting:

1. **LogPreviewCard** (reusable)
   - Used in: LogsListView, MapView callout, search results
   - States: with photo, without photo, with/without weather

2. **EmptyStateView** (reusable)
   - Used in: LogsListView, MapView, SearchView
   - Accepts: icon, title, message

3. **LoadingStateView** (reusable)
   - Used in: All views with async data
   - Accepts: message

---

## Next Steps

1. ✅ Review this plan
2. ✅ Approve preview strategy
3. ⏭️ Begin Phase 1 implementation
4. ⏭️ Create all component previews
5. ⏭️ Build MapView with mock data
6. ⏭️ Swap to real data
7. ⏭️ Schedule device field testing

---

**Total Simulator Coverage:** ~95%
**Device-Only Features:** GPS accuracy validation, battery testing
**Estimated Dev Time:** 10-14 days (simulator work)
**Field Testing Time:** 2-3 days (device testing)

---

## ✅ Implementation Complete (2026-05-13)

### What Was Built

**File:** `Features/Map/MapView.swift` (318 lines)

**Implemented Features:**
- ✅ SwiftUI Map with hybrid style (always-on, no style picker)
- ✅ Custom colored pins (blue=weather, green=photos, purple=audio, red=basic, **orange=selected**)
- ✅ Pin tap toggles custom callout (not default MapKit callout)
- ✅ Callout features:
  - Image preview (70px height, shows actual images from assets)
  - First line of notes
  - Timestamp
  - "Details" button (navigates to EditLogView)
  - Close button (X) for dismissal
  - Orange connection line from pin to callout
- ✅ Live metrics panel (top-right, collapsible with chevron)
  - Shows: Average Elevation, Humidity, Temperature (Fahrenheit)
  - Glassmorphism styling
  - Max 1/3 screen width
  - Tap to toggle expand/collapse
- ✅ Center location button (bottom-right, orange to stand out on hybrid map)
- ✅ Empty state (no GPS logs)
- ✅ Automatic map centering on logs with bounding box calculation
- ✅ Test data with actual asset images (placeholder-field-1, placeholder-field-2)

**Key Design Decisions:**
- Hybrid map style (permanent, no toggle) for better terrain visibility
- Orange selected pins + orange center button for visual consistency
- Collapsible metrics (starts collapsed to reduce screen clutter)
- Details button inline with date (compact layout)
- Actual image loading from mediaURLs with fallback to empty state

**Testing Coverage:**
- ✅ All features tested in simulator with mock GPS coordinates
- ✅ Preview states: With GPS logs, Empty state, Single log
- ⚠️ Device testing needed for: GPS accuracy, battery impact

**Next Steps for Device Testing:**
1. Verify pin placement matches actual field locations
2. Test battery drain during multi-hour sessions
3. Validate outdoor visibility in sunlight
4. Test with real GPS-captured logs

**Files Changed:**
- `Features/Map/MapView.swift` - Complete rewrite
- Test data updated with placeholder images

---

**Last Updated:** 2026-05-13
**Implementation Time:** ~3 days (with multiple stakeholder refinement rounds)
**Ready for:** Device field testing
