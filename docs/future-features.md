# Future Features - Organized by Theme

**Current Version:** v1.0 MVP (100% Complete)
**Last Updated:** 2026-05-29

---

## 📋 Table of Contents

1. [✅ Completed Features (v1.0)](#completed-features-v10)
2. [🔍 Search & Discovery](#search--discovery)
3. [📸 Media & Photo Intelligence](#media--photo-intelligence)
4. [🤖 AI & Machine Learning](#ai--machine-learning)
5. [🤝 Sharing & Collaboration](#sharing--collaboration)
6. [☁️ Cloud Sync & Multi-User](#cloud-sync--multi-user)
7. [🔬 Advanced Research Tools](#advanced-research-tools)

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

## 📸 Media & Photo Intelligence

### 2. Photo Metadata Extraction
**Priority:** ⭐⭐⭐ Very High (v1.1)
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

### 3. Advanced Photo Features
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

### 4. Speech-to-Text Transcription
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

### 5. AI Species Identification
**Priority:** ⭐⭐ Medium (v2.0+)
**Effort:** 2-3 weeks
**Status:** 🔄 **API Access In Progress** (wife working on iNaturalist approval)

Automatic species identification from photos using computer vision and machine learning.

#### Problem
Users manually tag species ("Northern Flicker"), but this requires expertise. Beginners struggle to identify species correctly.

#### Solution
AI-powered photo analysis that suggests species names with confidence scores using iNaturalist Computer Vision API.

#### Current Status
- ✅ Research complete
- ✅ API documentation reviewed
- 🔄 **Wife is working on getting iNaturalist API access**
- ⏳ Waiting for approval (timeline: 2-4 weeks)
- ⏳ Implementation ready to start once API access granted

#### Selected API: iNaturalist CV (Option A)
- **Why chosen:**
  - 55,000+ taxa in CV model (birds, plants, insects, mammals, fungi, etc.)
  - Community-verified data (millions of observations)
  - Free for non-commercial use
  - High accuracy (same engine as iNaturalist app)
  - Geographic context (uses GPS for better predictions)
- **Requirements:**
  - Requires internet connection
  - Rate limits apply (~1000 requests/day on free tier)
  - API access requires approval (in progress)
- **Documentation:** https://github.com/inaturalist/inatVisionAPI

#### Alternative Options (If iNaturalist Not Approved)

**Option B: Merlin Bird ID API**
- Cornell Lab of Ornithology (highly trusted)
- Birds only (not plants, insects, etc.)
- May require partnership/licensing

**Option C: Custom CoreML Model**
- 100% offline (no API needed)
- Limited taxa (500-1000 common species)
- Requires training custom model
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

### 6. Photo Analysis & Auto-Categorization (Future)
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

## 🤝 Sharing & Collaboration

### 7. Single-Entry Sharing (Export)
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
        logShareService.exportAsEcoJournalFile(log),
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
- **v2.0:** Cloud URL sharing (requires CloudKit backend)

---

## ☁️ Cloud Sync & Multi-User

### 8. Cloud Backup & Sync
**Priority:** ⭐⭐⭐ High (v2.0)
**Effort:** 3-4 weeks
**Status:** Planned (architecture decided: CloudKit)

**Problem:** Data loss if device breaks. Can't access journals from multiple devices.

**Solution:** Cloud sync with Apple CloudKit (native iOS integration).

#### Architecture
- **Backend:** CloudKit (Apple's cloud database service)
- **Sync Model:** Offline-first (local primary, cloud backup)
- **Auth:** User's Apple ID (already signed into iCloud)
- **Storage:** Uses user's iCloud storage (1GB free tier per user)
- **Cost:** $0 for developer (users pay for their own iCloud if needed)
- **Conflict Resolution:** CloudKit handles automatically

#### Features
- Automatic cloud backup (photos, audio, logs)
- Multi-device sync (iPhone + iPad with same Apple ID)
- Data recovery if device lost
- Offline-first (works without internet, syncs when available)
- Native iOS integration (zero third-party dependencies)

#### Security
- End-to-end encryption for sensitive fields
- Password-protected journals: encrypt notes before uploading to CloudKit
- Only user (and invited collaborators) can access data

#### Why CloudKit (Not Supabase)
- ✅ iOS-only app (no Android needed)
- ✅ Zero backend cost/maintenance
- ✅ 99% of iPhone users already signed into iCloud
- ✅ Built-in sharing UI (familiar to users from Notes app)
- ✅ Real-time sync handled by Apple
- ✅ Automatic conflict resolution
- ❌ Locked to Apple ecosystem (migration to Supabase possible in v3.0+ if Android needed)

#### Real-Time Collaboration Details
**What You Get:**
- **Near real-time sync:** Changes appear within **30 seconds to 2 minutes**
- **CloudKit Subscriptions:** App receives push notifications when data changes
- **Background sync:** Updates download automatically without user action
- **Offline support:** Changes sync when internet returns

**What You DON'T Get:**
- ❌ Instant character-by-character typing (like Google Docs)
- ❌ Live cursor presence ("Alice is editing...")
- ❌ Operational transforms
- ⚠️ Last-write-wins conflict resolution (if both edit same log offline)

**User Experience (Same as Apple Notes):**
```
You (iPhone):
- Add log "Found Douglas Fir" at 9:00 AM
- Syncs to CloudKit

Your wife (iPad, 2 miles away):
- Gets push notification at 9:01 AM
- Her app auto-refreshes
- She sees your new log within 1-2 minutes
```

**Is This Good Enough?**
**YES** for field research because:
- Field work is asynchronous (not typing at same time)
- Offline-first is more important than instant sync
- 30-second latency is fine for adding log entries
- Unlikely two people edit same log simultaneously

#### Implementation Phases
- **Phase 1 (Week 1):** Enable CloudKit, basic backup (single device)
- **Phase 2 (Week 2):** Multi-device sync (iPhone + iPad)
- **Phase 3 (Week 3):** CloudKit sharing (collaborate on journals)
- **Phase 4 (Week 4):** Security audit, encryption for password-protected journals

#### Code Example
```swift
// Enable CloudKit in Xcode:
// Target → Signing & Capabilities → + Capability → iCloud
// Check: CloudKit, iCloud Documents

import CloudKit

class CloudSyncService {
    let container = CKContainer.default()
    let privateDB = CKContainer.default().privateCloudDatabase

    // Backup journal to user's iCloud
    func backupJournal(_ journal: Journal) async throws {
        let record = CKRecord(recordType: "Journal")
        record["name"] = journal.name
        record["isPasswordProtected"] = journal.isPasswordProtected

        // Encrypt sensitive data for password-protected journals
        if journal.isPasswordProtected {
            let encrypted = encrypt(journal.logs, key: journal.password)
            record["encryptedData"] = encrypted
        } else {
            record["logs"] = journal.logs
        }

        try await privateDB.save(record)
    }

    // Set up real-time sync subscriptions
    func setupSubscriptions() async throws {
        let subscription = CKQuerySubscription(
            recordType: "Journal",
            predicate: NSPredicate(value: true),
            options: .firesOnRecordUpdate
        )

        subscription.notificationInfo = CKSubscription.NotificationInfo()
        subscription.notificationInfo?.shouldSendContentAvailable = true

        try await privateDB.save(subscription)
    }
}
```

**Timeline:** 3-4 weeks total

**Full Documentation:** `docs/research/CLOUDKIT_IMPLEMENTATION_PLAN.md` (to be created)

---

### 9. Multi-User Journals (Team Collaboration)
**Priority:** ⭐⭐ Medium (v2.1)
**Effort:** 2-3 weeks
**Status:** Planned (using CloudKit Sharing)

**Problem:** Research teams can't collaborate on shared journals.

**Solution:** CloudKit native sharing (same UI as Apple Notes).

#### How It Works
1. User creates journal
2. User taps "Share Journal" → Native iOS share sheet appears
3. User selects contact (Messages, Email, AirDrop)
4. Recipient taps link → "Accept invitation to Birds Journal?"
5. Recipient accepts → Journal appears in their app automatically
6. Both users see changes in real-time (CloudKit sync)

#### Authentication
- Uses recipient's Apple ID (already signed into iCloud)
- No separate account creation needed
- No email verification needed

#### Permissions (CloudKit Built-in)
- **Owner:** Can edit + delete + invite others + revoke access
- **Read-Write:** Can add/edit logs, cannot delete journal
- **Read-Only:** Can view but not edit

#### Features
- Native iOS sharing UI (users already understand it)
- Real-time collaboration (changes sync within 30 sec - 2 min)
- Revoke access anytime
- Works offline → Syncs when internet returns
- Activity indicators ("Alice is editing...")

#### Code Example
```swift
import CloudKit

Button("Share Journal") {
    presentCloudKitShare(for: journal)
}

func presentCloudKitShare(for journal: Journal) {
    let share = CKShare(rootRecord: journal.cloudKitRecord)
    share[CKShare.SystemFieldKey.title] = journal.name

    let controller = UICloudSharingController(share: share, container: .default())
    controller.availablePermissions = [.allowReadWrite, .allowReadOnly]
    present(controller, animated: true)
}
```

#### Security
- Only invited users can access
- Invitation requires Apple ID authentication
- Owner can revoke access anytime
- Password-protected journals: Password NOT synced (stays local)

**Timeline:** 2-3 weeks (after CloudKit backup is implemented)

**Full Documentation:** `docs/research/CLOUDKIT_IMPLEMENTATION_PLAN.md` (to be created)

---

## 🔬 Advanced Research Tools

### 10. Weather Data Refresh During Edits
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

### 11. Offline Map Tiles
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

## 🎯 Quick Reference: Feature Summary

### High Priority (v1.1-v1.5)
1. **Global search** - Search across all journals (2-3 days)
2. **Photo metadata extraction** - Auto-populate from EXIF (3-4 days)
3. **Single-entry sharing** - Export logs via Messages/AirDrop (3-5 days)

### Major Features (v2.0+)
4. **Cloud backup & sync** - CloudKit, multi-device support (3-4 weeks)
5. **AI species identification** - iNaturalist API (2-3 weeks) - Wife working on access
6. **Multi-user collaboration** - CloudKit Sharing (2-3 weeks)

### Medium Priority
7. **Advanced photo features** - Full-screen viewer, annotations (1-2 weeks)
8. **Photo AI categorization** - Auto-detect types, quality (3-4 weeks)

### Low Priority
9. **Weather refresh** - Update weather during edits (2-3 days)
10. **Offline map tiles** - Download for offline use (1 week)

---

**Last Updated:** 2026-05-29
**Document Owner:** David Contreras

**Next Actions:**
1. ✅ v1.0 Complete - Ready for TestFlight
2. ⏳ Waiting for Apple Developer approval
3. 🔄 Wife working on iNaturalist API access
4. 📋 Prioritize v1.1 features based on beta feedback
