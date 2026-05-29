# Future Features - Organized by Theme

**Current Version:** v1.0 MVP (100% Complete)
**Last Updated:** 2026-05-25

---

## 📋 Table of Contents

1. [✅ Completed Features (v1.0)](#completed-features-v10)
2. [🔍 Search & Discovery](#search--discovery)
3. [📸 Media & Photo Intelligence](#media--photo-intelligence)
4. [🤖 AI & Machine Learning](#ai--machine-learning)
5. [🗺️ Navigation & Location](#navigation--location)
6. [🤝 Sharing & Collaboration](#sharing--collaboration)
7. [☁️ Cloud Sync & Multi-User](#cloud-sync--multi-user)
8. [🎨 UI/UX Polish](#uiux-polish)
9. [🔬 Advanced Research Tools](#advanced-research-tools)

---

## ✅ Completed Features (v1.0)

### Core Features Shipped
- ✅ Dashboard with journal management
- ✅ Password protection with Face ID/Touch ID
- ✅ GPS-tagged log entries (auto-capture coordinates & altitude)
- ✅ Weather & air quality API integration
- ✅ Camera integration (multi-photo galleries with slider)
- ✅ Audio memos with speech-to-text transcription
- ✅ Map view with custom pins and callouts
- ✅ Search journals by name (Dashboard)
- ✅ Search logs by notes/transcriptions (Logs List)
- ✅ Sort options (Most Recent, Oldest, A-Z, Z-A)
- ✅ SwiftData offline storage
- ✅ Bottom tab navigation

**Status:** Ready for device testing → TestFlight → App Store

---

## 🔍 Search & Discovery

### 1. Global Search Across All Journals
**Priority:** ⭐⭐⭐ High (v1.1)
**Effort:** 2-3 days
**Status:** Planned

**Problem:** Users can only search within current journal. No way to find "that sparrow observation from 6 months ago" across 20 journals.

**Solution:** Enhance Dashboard search to search ALL logs across ALL journals.

#### Implementation
```swift
// DashboardViewModel.swift
var globalSearchResults: [Log] {
    guard !searchText.isEmpty else { return [] }
    return journals.flatMap { $0.logs }.filter { log in
        log.title.contains(searchText) ||
        log.notes.contains(searchText) ||
        log.audioMemos.contains { $0.transcription?.contains(searchText) ?? false }
    }
}
```

#### UI Design
```
┌─────────────────────────────────────────┐
│ 🔍 Results for "sparrow"                │
├─────────────────────────────────────────┤
│ 📖 Journals (0 matches)                 │
├─────────────────────────────────────────┤
│ 📝 Logs (5 matches across 2 journals)   │
│                                          │
│ Birds Journal                            │
│   • Northern Sparrow - May 12, 2026     │
│   • Song Sparrow - May 15, 2026         │
│                                          │
│ Backyard Journal                         │
│   • Sparrow at feeder - May 20, 2026    │
└─────────────────────────────────────────┘
```

#### Benefits
- ✅ Cross-journal discovery
- ✅ Find forgotten notes from months ago
- ✅ Useful for research (find all observations of X)
- ✅ Useful for personal journaling (find that Paris trip)

#### Phases
- **v1.1:** Basic global search (title, notes, transcriptions)
- **v1.2:** Advanced filters (date range, journal selection, GPS radius)
- **v1.3:** Search analytics (recent searches, autocomplete)

---

### 2. Advanced Filtering
**Priority:** ⭐⭐ Medium (v1.2)
**Effort:** 1 week
**Status:** Planned

Expand filter options beyond just sort:

**Dashboard Filters:**
- Filter by password-protected vs. unprotected
- Filter by log count (empty, 1-10, 11-50, 50+)
- Filter by date modified (today, this week, this month)

**Logs List Filters:**
- Filter by date range (custom date picker)
- Filter by weather conditions (clear, rain, clouds, fog)
- Filter by air quality (Good, Moderate, Poor)
- Filter by presence of photos/audio
- Filter by altitude range
- Filter by GPS location/coordinates

#### Benefits
- ✅ Find logs from specific field sessions
- ✅ Compare weather patterns over time
- ✅ Focus on logs with specific content types

---

## 📸 Media & Photo Intelligence

### 3. Photo Metadata Extraction
**Priority:** ⭐⭐⭐ High (v1.1)
**Effort:** 3-4 days
**Status:** Planned

**Problem:** Users import old photos (taken earlier) but app uses current GPS/time, not photo's original metadata.

**Solution:** Extract EXIF metadata from photos and auto-populate log fields.

#### What We Can Extract
- **GPS:** Latitude, longitude, altitude, compass direction
- **DateTime:** Original timestamp (when photo was taken)
- **Camera:** Make, model, lens, f-stop, ISO, shutter speed
- **Orientation:** Portrait/landscape

#### Use Cases

**Use Case 1: Import Historical Photos**
- User selects photo from vacation (taken 2 weeks ago)
- App extracts GPS from photo → Uses photo location, not current location
- App extracts DateTime → Suggests using photo timestamp, not "now"
- Result: Log accurately reflects when/where photo was taken

**Use Case 2: Photography Journal**
- Track camera settings for each photo
- Learn which settings work best (f/1.8 in golden hour = great shots)
- Compare lens performance

**Use Case 3: Travel Journal**
- Photo GPS → Reverse geocoding → Suggest log title ("Eiffel Tower, Paris")

#### Implementation
```swift
// PhotoMetadataService.swift
func extractMetadata(from image: UIImage) -> PhotoMetadata? {
    // Extract EXIF using ImageIO framework
    let gps = extractGPS(from: metadata)
    let dateTime = extractDateTime(from: metadata)
    let camera = extractCameraInfo(from: metadata)
    return PhotoMetadata(gps: gps, dateTime: dateTime, camera: camera)
}
```

#### UI Flow
1. User adds photo to log
2. If photo has GPS BUT log doesn't → Alert: "Use photo location?"
3. User confirms → Log GPS updated with photo's GPS
4. If photo has DateTime → Suggest using photo timestamp

#### Benefits
- ✅ Historical logging (create logs for past events)
- ✅ Accurate timestamps (use photo datetime, not "now")
- ✅ Richer data (camera settings for photography journals)

#### Phases
- **v1.1:** Extract GPS & DateTime, auto-populate log fields
- **v1.2:** Display camera settings in log detail view
- **v1.3:** Reverse geocoding (GPS → Location name)

---

### 4. Species Tagging & Tracking
**Priority:** ⭐⭐ Medium (v1.2)
**Effort:** 5-7 days
**Status:** Planned

**Problem:** Users with "Birds Journal" or "Wildlife Journal" have no way to tag species and track sightings over time.

**Solution:** Add tagging system to logs, leveraging photo metadata.

#### Data Model
```swift
@Model
class Log {
    // ... existing fields
    var tags: [String] = [] // e.g., ["Northern Flicker", "Woodpecker", "Bird"]
}
```

#### UI Flow
1. User adds bird photo to log
2. App prompts: "🐦 Add species tag?"
3. User types "Northern Flicker"
4. Tag saved to log
5. User can search by tag later: "Show all Northern Flicker sightings"

#### Features
- Manual tag input (user knows species name)
- Tag autocomplete (suggest previously used tags)
- Tag search (find all logs with tag X)
- Tag statistics ("You've seen 47 species this year")
- Filter by tag (show logs with specific species)

#### Benefits
- ✅ Track species over time
- ✅ Build personal field guide
- ✅ Discover patterns (migration, seasonal behavior)
- ✅ Share species lists with researchers

#### Phases
- **v1.2:** Manual tagging, tag search, tag filters
- **v1.3:** Tag statistics, tag timeline
- **v2.0+:** AI species identification (see AI & Machine Learning section)

---

### 5. Advanced Photo Features
**Priority:** ⭐ Low (v1.3+)
**Effort:** 1-2 weeks
**Status:** Future

**Full-Screen Photo Viewer:**
- Zoom/pan photos
- Swipe between photos in full-screen
- Photo info overlay (GPS, DateTime, camera settings)

**Photo Annotations:**
- Draw on photos (markup)
- Add text labels
- Highlight areas of interest

**GPS/Weather Overlays:**
- Stamp GPS coordinates on photo
- Stamp weather conditions on photo
- Timestamp overlay

---

## 🤖 AI & Machine Learning

### 6. Speech-to-Text Transcription
**Priority:** ⭐⭐⭐ High (v1.0)
**Effort:** 2 weeks
**Status:** ✅ COMPLETED

Automatic speech-to-text transcription for audio memos using Apple's on-device Speech framework.

#### Features (Shipped in v1.0)
- ✅ Automatic transcription after recording stops
- ✅ On-device processing (offline-capable after initial language pack download)
- ✅ Editable transcriptions (fix recognition errors)
- ✅ Searchable transcription content across journals
- ✅ Background transcription (uses Neural Engine on A12+ devices)

#### Technical Implementation
- **Framework:** Apple Speech (`SFSpeechRecognizer`)
- **Privacy:** Requires `NSSpeechRecognitionUsageDescription` permission
- **Battery Impact:** Minimal (on-device Neural Engine processing)
- **Offline:** 100% offline after initial language pack download (~20-50 MB)

#### Use Cases
- ✅ Voice field notes while hands are busy
- ✅ Quick observations without typing
- ✅ Dictate scientific terms and species names
- ✅ Search audio content by spoken words

**File Reference:** `EcoJournal/Services/AudioTranscriptionService.swift`

---

### 7. AI Species Identification
**Priority:** ⭐⭐ Medium (v2.0+)
**Effort:** 2-3 weeks
**Status:** Planned (research complete)

Automatic species identification from photos using computer vision and machine learning.

#### Problem
Users manually tag species ("Northern Flicker"), but this requires expertise. Beginners struggle to identify species correctly.

#### Solution
AI-powered photo analysis that suggests species names with confidence scores.

#### Proposed APIs

**Option A: iNaturalist API (Recommended)**
- **Pros:**
  - 55,000+ taxa in CV model
  - Community-verified data (millions of observations)
  - Free for non-commercial use
  - High accuracy (same engine as iNaturalist app)
- **Cons:**
  - Requires internet connection
  - Rate limits apply
- **Documentation:** https://github.com/inaturalist/inatVisionAPI

**Option B: Merlin Bird ID API**
- **Pros:**
  - Cornell Lab of Ornithology (highly trusted)
  - Optimized for North American birds
  - Audio identification support (bird calls)
- **Cons:**
  - Birds only (not plants, insects, etc.)
  - May require partnership/licensing

**Option C: Custom CoreML Model**
- **Pros:**
  - 100% offline
  - No API rate limits
  - Uses device Neural Engine (fast, battery-efficient)
- **Cons:**
  - Requires training custom model
  - Limited taxa (compared to cloud APIs)
  - Maintenance burden (model updates)

#### UI Flow
1. User adds photo to log
2. App analyzes photo → Displays results:
   ```
   🐦 Species Suggestions:
   • Northern Flicker (87% confident)
   • Red-bellied Woodpecker (12% confident)
   • Gila Woodpecker (1% confident)
   ```
3. User taps species → Auto-adds tag to log
4. User can manually override if incorrect

#### Integration with Existing Features
- Works with Species Tagging system (v1.2)
- Auto-populates `Log.tags` array
- Search works immediately (find all "Northern Flicker" logs)

#### Technical Considerations
- **Performance:** Run inference on background thread (don't block UI)
- **Caching:** Cache predictions for 24 hours (avoid redundant API calls)
- **Fallback:** If API fails, fallback to manual tagging
- **Privacy:** User controls when photos are sent to API (opt-in)

#### Phases
- **v2.0 Phase 1:** iNaturalist API integration (cloud-based)
- **v2.1 Phase 2:** Confidence threshold settings (only show >50% matches)
- **v2.2 Phase 3:** CoreML model (offline mode for common species)
- **v3.0:** Audio identification (bird calls using Merlin API)

#### Benefits
- ✅ Lower barrier to entry (beginners can identify species)
- ✅ Educational (learn species names from photos)
- ✅ Faster logging (no manual typing)
- ✅ Higher accuracy (AI assists human expertise)

**Full Research:** `docs/research/SPECIES_IDENTIFICATION_API_COMPARISON.md`

---

### 8. Photo Analysis & Auto-Categorization (Future)
**Priority:** ⭐ Low (v3.0+)
**Effort:** 3-4 weeks
**Status:** Concept only

Future AI capabilities for photo intelligence:

**Automatic Categorization:**
- Detect photo type: animal, plant, landscape, macro, close-up
- Suggest journal: "This looks like a bird, add to Birds Journal?"

**Image Quality Analysis:**
- Detect blurry photos → Suggest retaking
- Identify proper lighting → "Photo too dark, enable flash?"

**Content Recognition:**
- Extract visible text (OCR) from photos of field notes
- Detect weather conditions from photos (cloudy, sunny, rain)
- Identify habitat types (forest, desert, wetland, urban)

**Implementation:** Use Apple's Vision framework + CoreML

---

## 🗺️ Navigation & Location

### 9. Land Navigation (GPS-Guided Return)
**Priority:** ⭐⭐⭐ High (v1.5)
**Effort:** 2 days (MVP), 9 days (full feature)
**Status:** Fully planned (spike complete)

**Problem:** Field scientists need to return to previous observation sites 2km into backcountry. Want screen-off navigation to conserve battery.

**Solution:** Navigate to previously logged GPS locations with audio callouts.

#### Core Features (MVP - Phase 1)
- Navigate to any log with GPS coordinates
- Real-time distance tracking ("347 meters away")
- Audio callouts ("500 meters", "100 meters", "Arrived")
- Background GPS (screen off, phone in pocket)
- Large distance counter overlay (glanceable)
- Visual line connecting current position to target
- Battery efficient: 6-10% per hour (vs 20-35% with screen on)

#### Extended Features (Phase 2-3)
- Drop custom waypoint pins (mark parking, camp, sample sites)
- Bearing indicator with compass arrow
- Breadcrumb trail polyline (visual path history)
- Elevation gain/loss display
- Navigation history

#### Battery Analysis
- Screen OFF + GPS: 6-10% per hour ✅ Sustainable for 4+ hours
- Screen ON + GPS: 20-35% per hour ❌ Phone dies in ~3 hours
- **Conclusion:** Background location is essential

#### Implementation
Uses MapKit + CoreLocation with `allowsBackgroundLocationUpdates = true`

#### Phases
- **v1.5 Phase 1:** Core navigation (2 days)
- **v1.5 Phase 2:** Waypoint dropping (2 days)
- **v1.5 Phase 3:** Enhanced UX (bearing, compass, breadcrumbs) (3 days)
- **v1.5 Phase 4:** Polish & settings (2 days)

**Total:** 9 days for full feature

**Full Documentation:** `docs/research/navigation-feature-spike.md`

---

### 10. Reverse Geocoding (GPS → Location Name)
**Priority:** ⭐ Low (v1.3)
**Effort:** 1-2 days
**Status:** Future

Convert GPS coordinates to human-readable location names.

**Use Cases:**
- Log title suggestions: "Observation at Eiffel Tower, Paris"
- Log list display: "Paris, France" instead of "48.8584°N, 2.2945°E"
- Search by location name: "Show all logs in Olympic National Park"

**Implementation:** Use CoreLocation's `CLGeocoder`

---

## 🤝 Sharing & Collaboration

### 11. Single-Entry Sharing (Export)
**Priority:** ⭐⭐⭐ High (v1.5)
**Effort:** 3-5 days
**Status:** Planned

**Problem:** Users want to share individual log entries with colleagues/friends via Messages, Email, AirDrop.

**Solution:** Native iOS share sheet with multiple export formats.

#### Export Formats

**1. Custom .EcoJournal File (For App Users)**
- Bundle log + media into single file
- Recipient with app: Tap → Import to journal
- Recipient without app: Receives text + attachments

**2. Plain Text (Universal)**
```
FIELD OBSERVATION
==================
Date: May 14, 2026 2:34 PM
Location: 47.8597°N, 123.9346°W (182m)

WEATHER
--------
Clear, 18.5°C, 62% humidity

NOTES
-----
Found three specimens of Pseudotsuga menziesii...

Attachments: photo1.jpg, audio.m4a
```

**3. JSON (Developer/Research)**
- Structured data export
- Import into other tools
- API integration

#### Implementation
```swift
Button("Share") {
    showShareSheet = true
}
.sheet(isPresented: $showShareSheet) {
    ShareSheet(items: [
        logShareService.exportAsFieldnoteFile(log),
        logShareService.exportAsText(log),
        log.mediaURLs
    ])
}
```

#### Benefits
- ✅ Zero backend needed (offline-capable)
- ✅ Native iOS UX
- ✅ Works immediately (no account required)
- ✅ User control (data never leaves device without explicit share)

#### Phases
- **v1.5:** Basic sharing (custom file, plain text, JSON)
- **v1.6:** Rich HTML email (optional, for professional presentation)
- **v2.0:** Cloud URL sharing (requires backend)

---

## ☁️ Cloud Sync & Multi-User

### 12. Cloud Backup & Sync
**Priority:** ⭐⭐⭐ High (v2.0)
**Effort:** 3-4 weeks
**Status:** Planned (architecture documented)

**Problem:** Data loss if device breaks. Can't access journals from multiple devices.

**Solution:** Cloud sync with Supabase backend.

#### Architecture
- **Backend:** Supabase (PostgreSQL + Storage + Realtime + Auth)
- **Sync Model:** Offline-first (local primary, cloud backup)
- **Auth:** Anonymous device ID → Optional Apple Sign In upgrade
- **Conflict Resolution:** Last-write-wins

#### Features
- Automatic cloud backup (photos, audio, logs)
- Multi-device sync (iPhone + iPad)
- Data recovery if device lost
- Offline-first (works without internet, syncs when available)

#### Timeline
- **Week 1:** Supabase learning & setup
- **Week 2:** Backend implementation (DB, storage, functions)
- **Week 3:** iOS client sync engine
- **Week 4:** Testing & polish

**Full Documentation:** `docs/future-features.md` (Cloud Sync section)

---

### 13. Multi-User Journals (Team Collaboration)
**Priority:** ⭐⭐ Medium (v2.1)
**Effort:** 2-3 weeks
**Status:** Planned (architecture documented)

**Problem:** Research teams can't collaborate on shared journals.

**Solution:** Invite-based journal sharing (no traditional sign-in required).

#### How It Works
1. User creates journal
2. User taps "Share Journal" → Generates invite link
3. Teammate taps link → Gets access to shared journal
4. Both users see updates via cloud sync
5. Role-based access: Owner, Editor, Viewer

#### Authentication Strategy
- **Default:** Anonymous device ID (works immediately)
- **Optional:** Upgrade to Apple Sign In (for account recovery)
- **Fallback:** Email magic links (cross-platform migration)

#### Features
- Invite links with expiration
- Granular permissions (owner, editor, viewer)
- Activity feed ("Alice added a log 5 minutes ago")
- Revoke access
- Real-time collaboration (see teammates' changes)

#### Cross-Platform Considerations
- **iOS:** Apple Sign In (primary), Email (fallback)
- **Android (future):** Google Sign In (primary), Email (fallback)
- **Account linking:** Same email → Link Apple ID + Google ID

**Full Documentation:** `docs/future-features.md` (Multi-User Collaboration section)

---

## 🎨 UI/UX Polish

### 14. Dashboard Card Variations
**Priority:** ⭐ Low (v1.2)
**Effort:** 2-3 days
**Status:** Exploration needed

Experiment with different card designs:
- Elevation/shadow variations
- Alternative layouts (list view vs grid)
- Animation improvements
- Interaction feedback

**Note:** Current design is solid. Test with real data first before changing.

---

### 15. Dark Mode Optimization
**Priority:** ⭐ Low (v1.2)
**Effort:** 2-3 days
**Status:** System dark mode works, but not optimized

Enhance dark mode experience:
- Optimize colors for OLED (true black backgrounds)
- Adjust photo contrast in dark mode
- Test map view in dark mode (may need different pin colors)

---

### 16. Haptic Feedback
**Priority:** ⭐ Low (v1.3)
**Effort:** 1 day
**Status:** Minimal haptics currently

Add subtle haptic feedback:
- Button taps
- Delete confirmations
- GPS lock acquired
- Weather data fetched
- Log saved

**Implementation:** Use `UIImpactFeedbackGenerator`

---

### 17. Animations & Transitions
**Priority:** ⭐ Low (v1.3)
**Effort:** 2-3 days
**Status:** Basic animations work

Polish animations:
- Smoother card transitions
- Hero animations (photo expands when tapped)
- Loading states (shimmer effects)
- Pull-to-refresh animations

---

### 18. Empty States
**Priority:** ⭐ Low (v1.2)
**Effort:** 1 day
**Status:** Basic empty states exist

Improve empty state messaging:
- More helpful suggestions ("Tap + to create your first journal")
- Contextual tips ("Search requires at least 2 characters")
- Illustrations (optional, if budget allows)

---

## 🔬 Advanced Research Tools

### 19. Data Export (CSV, PDF Reports)
**Priority:** ⭐⭐ Medium (v1.6)
**Effort:** 1 week
**Status:** Future

**Problem:** Researchers need to export data for analysis in Excel, R, Python.

**Solution:** Export logs as CSV or generate PDF reports.

#### Export Formats
- **CSV:** All logs with GPS, weather, notes, timestamps
- **PDF Report:** Professional formatted document with photos
- **GeoJSON:** For GIS software (QGIS, ArcGIS)
- **KML:** For Google Earth

#### Use Cases
- Submit field data to professor
- Import into statistical software
- Share with collaborators (non-app users)
- Archive for publications

---

### 20. Weather Data Refresh During Edits
**Priority:** ⭐ Low (v1.5)
**Effort:** 2-3 days
**Status:** Current behavior: Weather NOT refreshed on edit

**Problem:** User creates log at 9am (weather: Clear, 15°C), returns at 2pm to add photos (weather: Clouds, 22°C). Weather data is outdated.

**Solution:** Add "Refresh Weather" button in EditLogView.

**CRITICAL:** Must use log's stored GPS coordinates, NOT current location (user may have moved).

```swift
Button("Refresh Weather Data") {
    showWeatherRefreshConfirmation = true
}
.alert("Update Weather Data?", ...) {
    Button("Update") {
        // Use log.latitude/longitude, NOT locationManager.location
        let weather = await weatherService.fetchWeather(
            latitude: log.latitude!,
            longitude: log.longitude!
        )
    }
}
```

**Future Enhancement (v2.0):** Per-media weather snapshots (capture weather for each photo).

---

### 21. Active Journal Indicators
**Priority:** ⭐ Low (v2.0 - Requires cloud sync)
**Effort:** 2-3 days
**Status:** Future

Show "ACTIVE" badge on journals with recent activity (last hour).

**Use Cases:**
- Team collaboration: See which journals colleagues are using
- Personal tracking: Quick visual of today's fieldwork

**Requires:** Cloud sync (to detect teammate activity)

---

### 22. Offline Map Tiles
**Priority:** ⭐ Low (v1.6)
**Effort:** 1 week
**Status:** Future

**Problem:** Map view requires internet to load tiles.

**Solution:** Download map tiles for offline use.

**Use Cases:**
- Backcountry field research (no cell service)
- International travel (avoid roaming charges)

**Implementation:** Use MapKit snapshot API or third-party tile cache

---

### 23. LiDAR Measurements (iPhone Pro Only)
**Priority:** ⭐ Low (v3.0)
**Effort:** 2-3 weeks
**Status:** Far future

Use iPhone Pro's LiDAR scanner for measurements:
- Distance measurement (tree height)
- Area measurement (soil patch size)
- 3D scanning (rock formations, tree trunks)

**Requires:** ARKit integration

---

---

## 🎯 Quick Reference: Feature Summary by Category

### 🔍 Search & Discovery
- **Global search** - Find logs across all journals (2-3 days)
- **Advanced filters** - Filter by date, weather, tags, GPS (1 week)

### 📸 Media & Photo Intelligence
- **Photo metadata extraction** - Auto-populate GPS/time from photos (3-4 days)
- **Species tagging** - Manual tag system for tracking species (5-7 days)
- **Advanced photo features** - Full-screen viewer, annotations, overlays (1-2 weeks)

### 🤖 AI & Machine Learning
- ✅ **Speech-to-text** - Already shipped in v1.0!
- **AI species identification** - Auto-identify species from photos (2-3 weeks)
- **Photo AI categorization** - Auto-detect photo types, quality analysis (3-4 weeks)

### 🗺️ Navigation & Location
- **Land navigation** - Navigate back to logged GPS locations (9 days)
- **Reverse geocoding** - GPS → Location names (1-2 days)

### 🤝 Sharing & Collaboration
- **Single-entry sharing** - Export individual logs via Messages/AirDrop (3-5 days)

### ☁️ Cloud Sync & Multi-User
- **Cloud backup & sync** - Multi-device access, automatic backup (3-4 weeks)
- **Multi-user journals** - Invite teammates to collaborate (2-3 weeks)

### 🎨 UI/UX Polish
- **Dark mode optimization** - OLED-friendly dark mode (2-3 days)
- **Haptic feedback** - Tactile button feedback (1 day)
- **Animations & transitions** - Smoother UI interactions (2-3 days)
- **Empty states** - Better messaging for empty screens (1 day)
- **Dashboard card variations** - Experiment with layouts (2-3 days)

### 🔬 Advanced Research Tools
- **CSV/PDF export** - Export data for analysis (1 week)
- **Weather refresh** - Update weather data during edits (2-3 days)
- **Active journal indicators** - See recent activity badges (2-3 days)
- **Offline map tiles** - Download maps for offline use (1 week)
- **LiDAR measurements** - Measure distances with iPhone Pro (2-3 weeks)

---

**Last Updated:** 2026-05-25
**Document Owner:** David Contreras

**Next Actions:**
1. Launch v1.0 (see `docs/LAUNCH_CHECKLIST.md`)
2. **Show categories to your wife** - Let her pick what features interest her most
3. Prioritize implementation based on her feedback
