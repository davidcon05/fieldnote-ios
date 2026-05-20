# Future Features & Polish Items

## v1.0 MVP - Launch Blockers

### Camera Integration & Multi-Media Gallery
**Status:** Not implemented - BLOCKING LAUNCH
**Priority:** Critical (v1.0 - MUST COMPLETE)

**Goal:** Replace placeholder CapturePhotoButton with functional camera that supports multiple photos/videos per log

#### Camera Capture
- Native camera interface using AVFoundation or UIImagePickerController
- Support both photos and videos
- Save media to `Log.mediaURLs` array (supports multiple items)
- Photo/video permissions (NSCameraUsageDescription, NSPhotoLibraryUsageDescription)

#### Multi-Media Gallery with Slider
- **Approach:** Low-effort horizontal slider with page indicator
- Display all photos/videos for a log entry
- Swipe to navigate between media items
- Page indicator dots showing current position (e.g., "2 of 5")
- Tap to view full-screen
- Delete option for each media item

**Implementation:**
```swift
// In NewLogView and EditLogView
TabView {
    ForEach(log.mediaURLs, id: \.self) { mediaURL in
        AsyncImage(url: mediaURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }
        .clipped()
    }
}
.tabViewStyle(.page(indexDisplayMode: .always))
.frame(height: 200)
```

**Features:**
- Horizontal scroll/swipe between photos
- Page indicator dots at bottom
- "Add Photo" button at end of slider
- Delete button overlay on each image
- Video playback with play button overlay
- First image shown in list view card thumbnails

**Future Enhancements (v1.1+):**
- Full-screen viewer with zoom/pan
- Image annotations/markup
- GPS overlay stamp on photos
- Weather overlay stamp on photos
- Video trimming
- Export all media for log

**Milestone:** v1.0 (launch blocker - must complete before field testing)

---

### Audio Memo Recording
**Status:** Not implemented - BLOCKING LAUNCH
**Priority:** Critical (v1.0 - MUST COMPLETE)

**Goal:** Replace RecordMemoCard placeholder with functional audio recording + automatic transcription

#### Audio Recording
- Record/pause/stop controls using AVAudioRecorder
- Save audio to `Log.audioMemoURL`
- Waveform visualization during recording
- Playback controls in edit mode
- Delete audio option
- Audio permissions (NSMicrophoneUsageDescription, NSSpeechRecognitionUsageDescription)

#### Speech-to-Text Transcription (v1.0)
- **Automatic transcription** after recording stops
- Uses Apple's Speech framework (built-in, offline capable)
- Display transcribed text in expandable text box
- Allow user to edit transcription (fix recognition errors)
- Save transcription to `Log.audioTranscription` field
- Searchable text (can search logs by audio content)

**Implementation:**
```swift
// Add to Log model
@Model
class Log {
    // ... existing fields
    var audioMemoURL: URL?
    var audioTranscription: String?  // NEW: Transcribed audio text
}

// In RecordMemoCard
RecordMemoCard(
    audioURL: $log.audioMemoURL,
    transcription: $log.audioTranscription,
    isRecording: $isRecording,
    onRecord: startRecording,
    onStop: { audioURL in
        stopRecording(audioURL)
        // Automatically transcribe after recording
        Task {
            await transcribeAudio(audioURL)
        }
    },
    onPlay: playAudio,
    onDelete: deleteAudio
)

// Transcription service
class AudioTranscriptionService {
    func transcribe(audioURL: URL) async throws -> String {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        let request = SFSpeechURLRecognitionRequest(url: audioURL)

        let result = try await recognizer.recognitionTask(with: request).result
        return result.bestTranscription.formattedString
    }
}
```

**UI Design:**
```
┌─────────────────────────────────────┐
│ 🎤 Audio Memo                       │
├─────────────────────────────────────┤
│ ⏺️ 00:42 ─────●──── 02:15          │
│ [▶️ Play]  [🗑️ Delete]              │
├─────────────────────────────────────┤
│ 📝 Transcription                    │
│ ┌─────────────────────────────────┐ │
│ │ Found three specimens of        │ │
│ │ Pseudotsuga menziesii near      │ │
│ │ the creek at approximately      │ │
│ │ 600 meters elevation. Bark      │ │
│ │ samples collected for analysis. │ │
│ │ [Edit ✏️]                        │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Features:**
- Visual recording indicator (pulsing red dot)
- Recording duration timer
- Playback with progress slider
- File size indicator
- Audio quality settings (low/medium/high)
- **Automatic transcription on recording stop**
- **Editable transcription text box** (fix errors)
- **Expandable/collapsible transcription view**
- **Loading indicator during transcription** ("Transcribing audio...")
- **Offline transcription** (after initial language pack download)

**Technical Requirements:**
- AVAudioRecorder for recording
- AVAudioPlayer for playback
- Background audio session (continue recording if screen locks)
- File compression (AAC format)
- **Speech framework** (SFSpeechRecognizer) for transcription
- **Permission:** NSSpeechRecognitionUsageDescription in Info.plist

**Error Handling:**
- If transcription fails → Show "Transcription unavailable" + Retry button
- If speech recognition denied → Show alert to enable in Settings
- If no internet for first-time language pack → Queue transcription for later
- Always keep audio file (transcription is bonus feature)

**Benefits:**
- Searchable audio content (search logs by what was said)
- Read notes without playing audio (quiet environments)
- Backup if audio file corrupts
- Accessibility for hearing-impaired users
- Copy/paste transcription to other apps

**Future Enhancements (v1.1+):**
- Multiple language support (Spanish, French, etc.)
- Speaker identification (if multiple people recorded)
- Timestamps in transcription (map text to audio position)
- Audio trimming
- Export audio + transcription together
- Multiple audio memos per log
- Real-time transcription (show text as speaking)

**Milestone:** v1.0 (launch blocker - must complete before field testing)

---

### Log Editing
**Status:** ~90% Complete - Media Integration Needed
**Priority:** Critical (v1.0 - MUST COMPLETE)

**Design Approach:**
- Tapping a log card **pushes** a full-screen edit view (NOT a bottom sheet)
- Edit view reuses the NewLogView layout/components but populated with existing log data
- Weather data is **NOT** re-fetched on edit (use stored weather from log creation)

**Current Implementation:**
- ✅ Cards are tappable buttons (LogsListView)
- ✅ NavigationLink triggers full-screen push
- ✅ **EditLogView implemented** (516 lines, 6 preview states)
- ✅ Edit log notes (pre-populated TextField)
- ✅ Update timestamp (DatePicker with date + time)
- ✅ Modify GPS coordinates (refresh button with confirmation alert)
- ✅ Weather refresh (with confirmation, uses log's stored coordinates ✅)
- ✅ Delete log with confirmation dialog (requires typing "DELETE")
- ✅ Save changes button (disabled until valid)
- ✅ Form validation (notes required)

**Still Missing - Media Integration:**
- 🔲 Add/remove photos (CapturePhotoButton is placeholder stub)
- 🔲 Multi-photo gallery UI (TabView slider with page indicators)
- 🔲 Import from photo library (collaboration use case)
- 🔲 Add/remove audio memos (RecordMemoCard is placeholder stub)
- 🔲 Audio playback controls
- 🔲 Audio transcription display/editing

**Technical Status:**
1. ✅ `EditLogView` created and mirrors `NewLogView` layout
2. ✅ All fields pre-populated from existing `Log` object
3. ✅ Weather data displayed as read-only historical snapshot
4. ✅ GPS can be refreshed (with confirmation alert)
5. ✅ NavigationLink push from LogsListView working
6. 🔲 **Blocked on:** Camera integration and audio recording implementation

**Implementation Details:**
EditLogView.swift (516 lines) includes:
- Bento grid layout matching NewLogView
- Timestamp editor with DatePicker
- GPS refresh with confirmation alert ("This will update GPS coordinates with your current location")
- Weather refresh with confirmation alert (uses log's stored coordinates ✅)
- 10-second timeout for weather API calls
- Delete confirmation requiring typing "DELETE"
- 6 comprehensive preview states (complete log, minimal, photos only, audio only, GPS only, weather only)

**Next Steps:**
1. Replace `CapturePhotoButton` placeholder with functional camera integration
2. Add multi-photo gallery TabView slider
3. Replace `RecordMemoCard` placeholder with audio recording + transcription
4. Both features needed in EditLogView AND NewLogView

**UI Differences from NewLogView:**
- CapturePhotoButton → Shows existing photos with add/remove capability
- RecordMemoCard → Shows existing audio with play/delete capability
- GPSTelemetryCard → Shows stored GPS with "Edit Manually" button
- WeatherDataCard → Shows stored weather with "CAPTURED AT [time]" label (read-only)
- Field Notes → Pre-filled with existing notes
- "Finalize Entry" button → "Save Changes" button
- Add "Delete Log" button at bottom (red, destructive)

**Milestone:** v1.0 (launch blocker - must complete before field testing)

---

## ✅ Completed Features

### Dashboard & Logs List Search & Filter
**Status:** ✅ Completed (2026-05-13)
**Implementation:** v1.x

Implemented search and filtering capabilities for both Dashboard (journal list) and LogsList views.

**Completed Features:**

**Dashboard (Journal List):**
- ✅ Search bar with "Search Journals..." placeholder
- ✅ Search by journal name (live filtering)
- ✅ Sort options: Most Recent (default), Oldest First, A→Z, Z→A
- ✅ Filter button with secondary color indicator when active
- ✅ Bottom sheet with sort options
- ✅ Clear button in search bar

**Logs List (Inside Journal):**
- ✅ Search bar with "Search logs..." placeholder
- ✅ Search by log notes content (live filtering)
- ✅ Search by audio transcription content (when available)
- ✅ Sort options: Most Recent (default), Oldest First, A→Z, Z→A
- ✅ Dynamic header: "Recent Logs" → "Search Results" with count
- ✅ Filter button with secondary color indicator when active
- ✅ Bottom sheet with sort options
- ✅ Clear button in search bar

**Implementation Details:**
- **Reusable Components:** SearchBar, FilterButton, FilterSheet, SortOption (shared by both screens)
- **Search:** Live filtering with case-insensitive substring matching
- **Sort:** Most Recent (default), Oldest First, A→Z, Z→A
- **UI:** White backgrounds with subtle shadows, pill-shaped search bar, circular filter button
- **No auto-capitalization or auto-correction** in search fields
- **Filter button color:** Changes to secondary color when non-default sort is active

**Components Created:**
- `Shared/Components/SearchBar.swift` - Reusable search bar with magnifying glass icon
- `Shared/Components/FilterButton.swift` - Circular filter button
- `Shared/Components/FilterSheet.swift` - Bottom sheet with sort options
- `Shared/Models/SortOption.swift` - Sort enum with 4 options

**Files Modified:**
- `Features/Dashboard/DashboardView.swift` - Added search & filter UI
- `Features/Dashboard/DashboardViewModel.swift` - Added filteredJournals computed property
- `Features/Logs/List/LogsListView.swift` - Added search & filter UI with dynamic header

**Benefits:**
- ✅ Find specific journals/logs quickly
- ✅ Multiple sort options for different workflows
- ✅ Live feedback as you type
- ✅ Clean, iOS-standard UI patterns
- ✅ Reusable components reduce code duplication

**Future Enhancements (Not Yet Implemented):**
- Filter by date range (today, this week, this month, custom range)
- Filter by weather conditions (clear, rain, clouds, etc.)
- Filter by air quality levels (Good, Fair, Moderate, Poor, Very Poor)
- Filter by presence of photos/audio
- Filter by altitude range
- Filter by GPS location/coordinates
- Filter by password-protected journals
- Filter by log count (empty, <10, 10-50, 50+)
- Multiple active filters at once
- Filter badge showing count of active filters
- "Clear All Filters" button

---

## v1.x Polish (Post-Launch)

---

### Dashboard Card Variations
**Status:** Prototype exploration needed
**Priority:** Medium

Explore different card design treatments:
- Card elevation/shadow variations
- Hover states refinement
- Alternative layouts (list view vs grid)
- Animation improvements
- Interaction feedback

**Notes:**
- Current design is solid foundation
- Test with real data/usage first
- A/B test with wife's feedback

---

### Weather Data Refresh & Media Snapshots
**Status:** Post-launch enhancement
**Priority:** Medium-High (v1.5+)

**Goal:** Provide weather updates for long field sessions and tie weather to each media capture

**Two Approaches:**

#### Option 1: Manual Weather Refresh
Allow users to update weather data during log editing session:

**Use Case:**
- User creates log at 9am (weather: Clear, 15°C)
- Returns to same location at 2pm to add photos
- Weather has changed (Clouds, 22°C)
- User wants current conditions for new photos

**Implementation:**
- Add "Refresh Weather" button in EditLogView
- Shows confirmation: "Update weather from [old time] to [new time]?"
- Fetches fresh weather data from API
- Updates log.weather with new snapshot
- Preserves original capture time vs. weather update time

```swift
// In EditLogView
Button("Refresh Weather Data") {
    showWeatherRefreshConfirmation = true
}
.alert("Update Weather Data?", isPresented: $showWeatherRefreshConfirmation) {
    Button("Cancel", role: .cancel) { }
    Button("Update") {
        Task {
            await refreshWeatherData()
        }
    }
} message: {
    Text("This will replace weather from \(log.timestamp.formatted()) with current conditions.")
}
```

**Benefits:**
- User controls when weather updates
- Simple implementation
- No automatic API calls (preserves rate limits)

**Drawbacks:**
- User must remember to refresh
- Single weather snapshot per log

---

#### Option 2: Per-Media Weather Snapshots (Future - v2.0+)
Automatically capture weather for each photo/audio memo:

**Use Case:**
- User creates log with multiple observations over 3 hours
- Each photo captured at different times with different weather
- Log has timeline of weather changes

**Data Model Changes:**
```swift
@Model
class MediaItem {
    var id: UUID
    var url: URL
    var captureDate: Date
    var weather: Weather?  // Weather at time of media capture
    var location: CLLocation?  // GPS at time of media capture

    var log: Log?
}

@Model
class Log {
    // ... existing fields
    var mediaItems: [MediaItem]  // Replace mediaURLs: [URL]

    // Initial weather at log creation
    var initialWeather: Weather?
}
```

**Implementation:**
- When user captures photo → Fetch weather + GPS → Create MediaItem
- When user records audio → Fetch weather + GPS → Create MediaItem
- Log displays weather timeline in edit mode
- Each media item shows its own weather badge

**Benefits:**
- Accurate weather for each observation
- Rich timeline data for research
- Automatic (no user action needed)

**Drawbacks:**
- More complex data model
- More API calls (rate limit concerns)
- Breaking change from v1.0 schema

**CRITICAL IMPLEMENTATION NOTE:**
When retrying weather fetch (whether manual or automatic), **ALWAYS use the log's stored GPS coordinates**, NOT the current location. User may have moved to a different location when retrying.

```swift
// ✅ CORRECT: Use log's coordinates
let weather = try await weatherService.fetchWeather(
    latitude: log.latitude!,   // From log entry
    longitude: log.longitude!  // From log entry
)

// ❌ WRONG: Don't use current location
let weather = try await weatherService.fetchWeather(
    latitude: locationManager.location.latitude,   // Current location (WRONG!)
    longitude: locationManager.location.longitude  // Current location (WRONG!)
)
```

**Recommendation:** Start with Option 1 (manual refresh) for v1.5, evaluate Option 2 for v2.0 after field testing validates the need.

---

## v2.0+ Features

### Single-Entry Sharing (Export & Import)
**Status:** Future feature
**Priority:** High (v1.5)

**Goal:** Share individual log entries with others via Messages, Email, AirDrop, etc.

#### Phase 1: Native Share Sheet (v1.5)

**User Flow:**
1. User taps "Share" button on log entry
2. iOS share sheet appears with destinations (Messages, Email, AirDrop, Files, Copy)
3. Recipient receives shareable content based on destination

**Export Formats:**

**1. Custom .fieldnote File (For App Users)**
```swift
// Bundle log data + media into single file
struct FieldnoteExport: Codable {
    let version: String = "1.0"
    let log: LogExportData
    let mediaData: [MediaData]  // Base64-encoded images/audio
}

// Register app to handle .fieldnote files
// Info.plist: CFBundleDocumentTypes for "com.yourcompany.fieldnote"
```

**User Experience:**
- Recipient WITH app: Tap .fieldnote → "Import to Fieldnote" → Choose journal
- Recipient WITHOUT app: Receives text + attachments (fallback)

**2. Plain Text Export (Universal)**
```
FIELD OBSERVATION
==================
Date: May 14, 2026 2:34 PM
Location: 47.8597°N, 123.9346°W (182m)

WEATHER
--------
Clear, 18.5°C, 62% humidity
Wind: 3.2 m/s
Air Quality: Good (AQI 1)

NOTES
-----
Found three specimens of Pseudotsuga menziesii...

AUDIO TRANSCRIPTION
-------------------
[Full transcribed text]

---
Captured with Fieldnote

Attachments: photo1.jpg, photo2.jpg, audio.m4a
```

**3. JSON Export (Developer/Research)**
```json
{
  "version": "1.0",
  "timestamp": "2026-05-14T14:34:00Z",
  "notes": "...",
  "location": { "lat": 47.8597, "lon": -123.9346, "alt": 182.0 },
  "weather": { ... },
  "mediaURLs": [...],
  "audioTranscription": "..."
}
```

**Implementation:**
```swift
// LogShareService.swift
class LogShareService {
    func exportAsFieldnoteFile(log: Log) -> URL { ... }
    func exportAsText(log: Log) -> String { ... }
    func exportAsJSON(log: Log) -> Data { ... }
}

// In LogDetailView/EditLogView:
Button("Share") {
    showShareSheet = true
}
.sheet(isPresented: $showShareSheet) {
    ShareSheet(items: [
        logShareService.exportAsFieldnoteFile(log),
        logShareService.exportAsText(log),
        log.mediaURLs,
        log.audioMemoURL
    ])
}
```

**Share Destinations & Recipient Experience:**

| Destination | With App | Without App |
|-------------|----------|-------------|
| **Messages** | .fieldnote → Import | Text + inline photos/audio |
| **Email (share sheet)** | .fieldnote attachment | Plain text + attachments |
| **AirDrop** | .fieldnote → Import | Folder with files |
| **Files** | Save .fieldnote | Save text + media |

**Benefits:**
- ✅ Zero backend needed
- ✅ Works offline (field research use case)
- ✅ Native iOS UX (familiar to users)
- ✅ User control (data never leaves device without explicit share)
- ✅ Quick and lightweight

**Limitations:**
- ❌ Recipient must manually import (if they have app)
- ❌ Large media files sent directly (bandwidth concern)
- ❌ No tracking (can't see who viewed it)
- ❌ No expiration (shared data exists forever)

---

#### Phase 2: Rich HTML Email (v1.6 - Optional)

**For professional presentation to non-app users:**

```swift
import MessageUI

Button("Email") {
    showMailComposer = true
}
.sheet(isPresented: $showMailComposer) {
    MailComposeView(log: log)  // Rich HTML email with embedded images
}
```

**User Experience:**
- Separate "Email" button (different from general Share)
- In-app mail composer with pre-filled HTML template
- Professional formatting with embedded photos
- Requires user has email configured on device

**Benefits:**
- ✅ Beautiful presentation for recipients without app
- ✅ Embedded images (no separate attachments)
- ✅ Professional for submitting observations to professors/colleagues

**Limitations:**
- ❌ Email-only (can't use for Messages/AirDrop)
- ❌ More complex implementation

---

#### Phase 3: Cloud URL Sharing (v2.0+ - Requires Backend)

**For small link sharing with expiration:**

**User Flow:**
1. User taps "Share Link"
2. App uploads log + media to cloud storage
3. Generates shareable URL: `fieldnote.app/log/abc123`
4. Copy link or share via iOS share sheet
5. Recipient opens URL → Web viewer or app import

**Backend Requirements:**
- Cloud storage (Firebase Storage / Supabase Storage)
- Database for shared log metadata
- Web viewer for recipients without app
- Expiration logic (auto-delete after 30 days)

**Benefits:**
- ✅ Small link (not full data)
- ✅ Track views/downloads
- ✅ Expire links after X days
- ✅ View in browser (no app required)

**Limitations:**
- ❌ Requires backend setup
- ❌ Requires internet connection
- ❌ Storage costs
- ❌ Privacy concerns (data uploaded to cloud)

**Decision:** Defer to v2.0+ when cloud sync is implemented

---

### Multi-User Collaboration & Cloud Architecture
**Status:** Future feature - Major architectural change
**Priority:** High (v2.0+)

**Goal:** Enable team collaboration on shared journals without traditional sign-in

#### The Challenge: No User Accounts, But Need Sharing

**Current State (v1.0):**
- ✅ No sign-in required (privacy-first)
- ✅ All data local (SwiftData)
- ✅ Works offline
- ❌ Can't share journals with team
- ❌ Can't sync across devices
- ❌ No collaboration features

**Future State (v2.0+):**
- ✅ Still works without sign-in (optional account)
- ✅ Can share journals via invite links
- ✅ Multi-device sync (same user)
- ✅ Team collaboration (multiple users)
- ✅ Offline-first (local primary, cloud backup)

---

#### Authentication Strategy: Invite-Based Without Traditional Sign-In

**Option 1: Device-Based Anonymous Auth + Invite Links (Recommended)**

**How it works:**
```
1. App launches → Anonymous device ID created (stored in Keychain)
2. User creates local journals (works offline, no account needed)
3. User taps "Share Journal" → Generates invite link
4. Invite link uploaded to cloud with journal ID
5. Recipient taps link → Claims access to shared journal
6. Cloud syncs shared journal to recipient's device
7. Both users see updates via cloud sync
```

**Implementation:**
```swift
// Firebase/Supabase Anonymous Auth
let deviceID = UUID().uuidString  // Stored in Keychain
let authResult = try await Auth.auth().signInAnonymously()

// User stays anonymous, but has cloud identity for sync
// Later, can optionally "upgrade" to Apple Sign In to preserve data
```

**Invite Link Structure:**
```
fieldnote.app/invite/abc123xyz?journal=journal-uuid&sender=device-id
```

**Backend Schema (Supabase Example):**
```sql
-- Device identities (anonymous, no email required)
CREATE TABLE devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  last_seen timestamptz,
  device_name text,  -- "iPhone 14 Pro" (user can set)
  platform text      -- "iOS 17.4"
);

-- Journal access control
CREATE TABLE journal_access (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_id uuid REFERENCES journals(id),
  device_id uuid REFERENCES devices(id),
  role text,  -- "owner", "editor", "viewer"
  invited_by uuid REFERENCES devices(id),
  invited_at timestamptz DEFAULT now(),
  UNIQUE(journal_id, device_id)
);

-- Invite links
CREATE TABLE invite_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE,  -- Short code: "abc123"
  journal_id uuid REFERENCES journals(id),
  created_by uuid REFERENCES devices(id),
  expires_at timestamptz,
  max_uses int,
  use_count int DEFAULT 0
);
```

**Benefits:**
- ✅ No email/password required
- ✅ Works immediately (anonymous auth)
- ✅ Privacy-preserving (no personal info)
- ✅ Simple invite flow
- ✅ Can optionally upgrade to Apple Sign In later

**Drawbacks:**
- ⚠️ If user loses device + didn't upgrade to Apple Sign In → Data lost
- ⚠️ No way to revoke device access after invite (unless they add email)

---

**Option 2: Apple Sign In (Optional Upgrade)**

**How it works:**
```
1. User starts anonymous (like Option 1)
2. When they want to share or sync devices:
   → Prompt: "Sign in with Apple to enable sharing"
3. User authenticates with Apple Sign In
4. Anonymous device ID upgraded to Apple ID
5. Can now revoke access, sync multiple devices, recover data
```

**Benefits:**
- ✅ Secure identity (Apple's auth)
- ✅ Can revoke access by device
- ✅ Multi-device sync (same Apple ID)
- ✅ Data recovery if device lost
- ✅ Privacy-preserving (Apple doesn't share email unless user allows)

**Drawbacks:**
- ❌ Requires Apple account (barrier for some users)
- ⚠️ **Cross-platform limitation:** Apple Sign In works on Android via web OAuth, but UX is degraded (see Cross-Platform Considerations below)

---

**Option 3: Email-Based Magic Links (No Password)**

**How it works:**
```
1. User enters email → Receives magic link
2. Taps link → Authenticated (no password)
3. Can share journals via email invite
4. Recipients also authenticate via magic link
```

**Benefits:**
- ✅ No password to remember
- ✅ Cross-platform (works on Android later)
- ✅ Can revoke access by email
- ✅ Familiar pattern (Slack, Notion use this)

**Drawbacks:**
- ❌ Requires email (less private than anonymous)
- ❌ Spam risk (email could be blocked)

---

#### Cross-Platform Authentication Considerations

**IMPORTANT:** If planning Android port, authentication strategy must support cross-platform migration.

##### Apple Sign In: Cross-Platform Reality

**iOS/macOS (Native):**
- ✅ Seamless native SDK with Face ID/Touch ID
- ✅ Best UX, users trust it
- ✅ Privacy-preserving (Apple doesn't share email unless user allows)

**Android/Web (OAuth - Web Flow):**
- ⚠️ Web-based OAuth flow (not native SDK)
- ⚠️ Opens browser window for authentication
- ⚠️ Clunky UX compared to native (no biometric, requires password entry)
- ⚠️ Second-class citizen experience

**Conclusion:** Apple Sign In works technically on Android, but UX is degraded. Don't force it as the only option.

---

##### Migration Scenario: iOS → Android

**Problem:**
User starts on iPhone with Apple Sign In, then switches to Android. How do they access their data?

**Solution 1: Apple Sign In on Android (Poor UX)**
```
1. Opens Fieldnote Android app
2. Taps "Sign in with Apple"
3. Redirected to web browser (not native)
4. Enters Apple ID + password (no biometric)
5. Completes 2FA
6. Redirected back to app
7. Account linked

User reaction: 😕 "Why can't I use my fingerprint like on iPhone?"
```

**Solution 2: Account Linking via Email (Better UX)**
```
1. Opens Fieldnote Android app
2. Taps "Link Existing Account"
3. Enters email associated with Apple ID
4. Receives magic link
5. Taps link → Authenticated
6. Same account, different auth method

User reaction: 😊 "Oh, I just enter my email and tap a link. Easy."
```

**Recommendation:** Always support email magic links as universal fallback for cross-platform migration.

---

##### Multi-Platform Auth Strategy

**Don't force one auth method - offer what's native to each platform:**

**iOS Users See:**
```
┌─────────────────────────────────┐
│ 🔐 Secure Your Account          │
├─────────────────────────────────┤
│ [🍎 Sign in with Apple]         │  ← Native, primary
│ [📧 Use Email Instead]          │  ← Universal fallback
└─────────────────────────────────┘
```

**Android Users See:**
```
┌─────────────────────────────────┐
│ 🔐 Secure Your Account          │
├─────────────────────────────────┤
│ [🔵 Sign in with Google]        │  ← Native, primary
│ [📧 Use Email Instead]          │  ← Universal fallback
│ [🍎 Sign in with Apple]         │  ← Available but secondary
└─────────────────────────────────┘
```

**Web Users See:**
```
┌─────────────────────────────────┐
│ 🔐 Secure Your Account          │
├─────────────────────────────────┤
│ [📧 Continue with Email]        │  ← Primary (universal)
│ [🔵 Sign in with Google]        │  ← Secondary
│ [🍎 Sign in with Apple]         │  ← Tertiary
└─────────────────────────────────┘
```

---

##### Account Linking (Cross-Platform Identity)

**Backend schema supports multiple auth providers per user:**

```sql
-- Supabase Auth handles this natively
CREATE TABLE auth.identities (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id),
  provider text,  -- 'apple', 'google', 'email'
  provider_user_id text,
  linked_at timestamptz DEFAULT now(),
  UNIQUE(provider, provider_user_id)
);

-- Same user can have multiple identities
-- Example:
-- user_id: 123
--   ├─ apple: john.doe@icloud.com
--   ├─ google: john.doe@gmail.com
--   └─ email: john.doe@fieldnote.com
```

**User flow for linking accounts:**
```
1. User authenticated with Apple on iOS
2. Gets Android device
3. Signs in with Google on Android
4. App detects same email: "Link to existing account?"
5. Sends verification to email
6. User confirms → Both auth methods access same data
```

**Key Principle:** Email becomes the universal identifier, auth provider is just the authentication method.

---

##### Migration Examples

**Example 1: iOS User → Android (Email Link)**
```
User: Jane (iOS with Apple Sign In)
Email: jane@icloud.com

1. Gets Android phone
2. Opens Fieldnote Android
3. Taps "Link Existing Account"
4. Enters: jane@icloud.com
5. Receives magic link email
6. Taps link → Authenticated
7. Backend links:
   - Apple ID (jane@icloud.com) ↔ Device ID (android-xyz)
8. Jane's journals sync to Android

Result: ✅ Seamless migration without Apple Sign In on Android
```

**Example 2: iOS User → Android (Native Google Auth)**
```
User: John (iOS with Apple Sign In)
Apple ID: john@icloud.com
Gmail: john@gmail.com (different email!)

1. Gets Android phone
2. Signs in with Google (john@gmail.com)
3. App asks: "Do you have an existing account?"
4. John taps "Yes, link it"
5. Enters: john@icloud.com
6. Receives verification email
7. Confirms → Accounts linked
8. Backend links:
   - Apple ID (john@icloud.com) ↔ Google ID (john@gmail.com)
9. John's journals accessible via either sign-in

Result: ✅ Can use native Google Sign In on Android, still linked to iOS data
```

**Example 3: Cross-Device with Email Universal**
```
User: Sarah (wants to use iOS + Android + Web)

1. iOS: Starts anonymous → Upgrades to Email (sarah@gmail.com)
2. Android: Signs in with Email (sarah@gmail.com) → Same account
3. Web: Signs in with Email (sarah@gmail.com) → Same account

Result: ✅ Universal email auth works everywhere, no platform-specific dependencies
```

---

##### Implementation: Platform-Agnostic Auth Layer

```swift
// AuthService.swift (iOS)
protocol AuthProvider {
    func signIn() async throws -> User
    func linkAccount(existingUser: User) async throws
}

class AppleAuthProvider: AuthProvider {
    func signIn() async throws -> User {
        // Native Apple Sign In SDK
    }
}

class EmailAuthProvider: AuthProvider {
    func signIn() async throws -> User {
        // Magic link via Supabase
    }
}

// iOS Configuration:
let authService = AuthService(
    providers: [
        AppleAuthProvider(),  // Primary (native)
        EmailAuthProvider()   // Fallback (universal)
    ]
)

// Android Configuration (Kotlin):
val authService = AuthService(
    providers = listOf(
        GoogleAuthProvider(), // Primary (native)
        EmailAuthProvider()   // Fallback (universal)
    )
)
```

**Backend:** Supabase Auth supports Apple, Google, and Email natively - no custom implementation needed.

---

##### Key Decisions for Multi-Platform

**✅ DO:**
- Always support email magic links (universal fallback)
- Offer native auth per platform (Apple on iOS, Google on Android)
- Design backend to support multiple auth providers per user
- Implement account linking for cross-platform migration
- Use email as the universal identifier

**❌ DON'T:**
- Force Apple Sign In as the only upgrade path (locks out Android UX)
- Make Android users use Apple Sign In web OAuth flow (poor experience)
- Lock users into one auth provider forever (prevents migration)
- Skip email fallback (creates platform dependency)

---

##### Validation Assumptions

**Before implementing v2.0 multi-user features, validate:**

1. **User base platform distribution:**
   - Are users primarily iOS? (Apple Sign In sufficient for v2.0)
   - Do users have mixed devices? (Need account linking from day 1)
   - Is Android launch confirmed? (Affects architecture choices)

2. **Migration scenarios:**
   - How often do users switch platforms? (Informs priority of account linking)
   - Do users share journals cross-platform? (e.g., iOS researcher + Android field tech)

3. **Privacy preferences:**
   - Do users prefer anonymous vs email? (Anonymous = more private, Email = more portable)
   - Is Apple Sign In trusted? (Some users distrust "Sign in with..." patterns)

4. **Backend readiness:**
   - Is Supabase confirmed as backend? (Supports all auth methods natively)
   - Is self-hosting a requirement? (Supabase can be self-hosted)

**Recommendation:** For v1.5 iOS-only single-entry sharing, auth not needed yet. For v2.0 multi-user + cloud sync, validate these assumptions before committing to auth strategy.

---

#### Recommended Architecture: Hybrid Approach

**v1.0 (Current):**
- Local-only, no accounts

**v1.5 (Single-Entry Sharing):**
- Add native share sheet (no backend)
- Export as .fieldnote files
- No accounts needed

**v2.0 (Multi-User + Cloud Sync - iOS Only):**
- **Default:** Anonymous device-based auth (works immediately)
- **Optional:** Upgrade to Apple Sign In (primary) OR Email (fallback)
- **Invite-based sharing:** Generate invite links for journals
- **Offline-first sync:** Local primary, cloud backup
- **Note:** Include email fallback even if iOS-only to prepare for future Android port

**v2.1 (Android Launch - If Planned):**
- **iOS:** Apple Sign In (primary), Email (fallback)
- **Android:** Google Sign In (primary), Email (fallback)
- **Account linking:** Detect same email, allow linking across providers
- **Cross-platform sync:** Journals accessible from both iOS and Android

**v2.5+ (Advanced Collaboration):**
- Granular permissions (owner, editor, viewer)
- Activity feed (who added what)
- Conflict resolution UI
- Multi-device management (view/revoke devices)

---

#### Cloud Backend Layers (Beyond Just Supabase)

The user is right - **there are many layers beyond just Supabase:**

**Layer 1: Authentication**
- **Options:** Firebase Auth, Supabase Auth, Clerk, Auth0
- **Recommendation:** Supabase Auth (built-in, works with Supabase DB)
- **Why:** Anonymous auth + Apple Sign In upgrade path built-in

**Layer 2: Database**
- **Options:** Supabase (PostgreSQL), Firebase Firestore, Realm/MongoDB
- **Recommendation:** Supabase PostgreSQL
- **Why:**
  - Structured data (journals, logs, locations)
  - PostGIS for geospatial queries (find logs near coordinates)
  - Row Level Security (RLS) for multi-user access control
  - Real-time subscriptions

**Layer 3: File Storage**
- **Options:** Supabase Storage, Firebase Storage, AWS S3, CloudFlare R2
- **Recommendation:** Supabase Storage
- **Why:**
  - Integrates with auth (RLS on files)
  - CDN for fast media delivery
  - Automatic image transformations
  - Cost-effective

**Layer 4: Real-Time Sync**
- **Options:** Supabase Realtime, Firebase Realtime, WebSockets, MQTT
- **Recommendation:** Supabase Realtime
- **Why:**
  - Built-in with Supabase
  - PostgreSQL change data capture (CDC)
  - Push updates when teammate adds log
  - Battery-efficient

**Layer 5: Offline-First Sync Engine**
- **Options:**
  - Custom sync logic (SwiftData ↔ Supabase)
  - WatermelonDB (React Native)
  - Realm Sync (MongoDB)
  - Custom CRDT implementation
- **Recommendation:** Custom SwiftData sync with conflict resolution
- **Why:**
  - Full control over sync logic
  - SwiftData is Apple's native solution (v1.0 already uses it)
  - Can implement last-write-wins or operational transforms

**Layer 6: Media Optimization**
- **Options:** Cloudinary, Imgix, Supabase Image Transformations
- **Recommendation:** Supabase Image Transformations
- **Why:**
  - Auto-generate thumbnails
  - Compress images for mobile (save bandwidth)
  - WebP conversion for smaller sizes

**Layer 7: Search & Analytics**
- **Options:** Algolia, Typesense, Supabase Full-Text Search, Elastic
- **Recommendation:** Supabase Full-Text Search (PostgreSQL)
- **Why:**
  - Already using PostgreSQL
  - Search logs by transcription content
  - No extra service needed

**Layer 8: Error Tracking & Monitoring**
- **Options:** Firebase Crashlytics, Sentry, Datadog
- **Recommendation:** Firebase Crashlytics (discussed earlier)
- **Why:**
  - Free tier generous
  - Automatic crash reporting
  - Non-fatal error tracking

**Layer 9: Analytics & Usage**
- **Options:** Firebase Analytics, Mixpanel, Amplitude, PostHog
- **Recommendation:** PostHog (self-hosted or cloud)
- **Why:**
  - Privacy-friendly
  - Can self-host (GDPR compliant)
  - Feature flags built-in

**Layer 10: Push Notifications**
- **Options:** Firebase Cloud Messaging, OneSignal, APNs directly
- **Recommendation:** Firebase Cloud Messaging
- **Why:**
  - Notify when teammate adds log
  - Cross-platform (when Android comes)

---

#### Recommended Tech Stack for v2.0

**Primary Backend: Supabase**
- Authentication (anonymous + Apple Sign In)
- PostgreSQL database (journals, logs, access control)
- Storage (photos, audio)
- Realtime (live updates)
- Edge Functions (server-side logic)

**Supplementary Services:**
- **Crashlytics:** Firebase Crashlytics (error tracking)
- **Analytics:** PostHog (usage analytics)
- **Push Notifications:** Firebase Cloud Messaging
- **CDN:** Cloudflare (if Supabase CDN not enough)

**Why Supabase Over Firebase:**
- ✅ PostgreSQL (better for structured field research data)
- ✅ PostGIS (geospatial queries - find logs near location)
- ✅ Row Level Security (fine-grained access control)
- ✅ Self-hostable (can move to own server if needed)
- ✅ SQL (easier to reason about than Firestore queries)
- ✅ RESTful API (simpler than Firebase SDK)
- ❌ Smaller ecosystem than Firebase (tradeoff)

**When to Use Firebase:**
- If real-time collaboration is critical (Firebase has better latency)
- If need Crashlytics (already using it for errors)
- If scaling to millions of users (Firebase auto-scales better)

---

#### Implementation Phases & Timeline Estimates

**v1.5: Single-Entry Sharing (No Backend)**
**Estimated Time: 3-5 days**

- Day 1-2: Export functionality
  - LogShareService implementation
  - .fieldnote file format (JSON + base64 media)
  - Plain text export
  - JSON export
- Day 2-3: Native share sheet integration
  - ShareSheet SwiftUI wrapper
  - Multi-format sharing
  - Test on simulator
- Day 3-4: Import flow for recipients
  - CFBundleDocumentTypes registration
  - Import handler
  - Journal selection UI
- Day 4-5: Testing & polish
  - Test all share destinations (Messages, AirDrop, Email, Files)
  - Edge cases (large files, corrupted imports)
  - UX polish

**Dependencies:** None (works offline, no backend)

---

**v2.0: Cloud Sync + Invite-Based Sharing**
**Estimated Time: 3-4 weeks**

**Week 1: Supabase Learning & Setup (5-7 days)**
- Days 1-2: Supabase fundamentals
  - Documentation deep-dive
  - Create test project
  - Understand Row Level Security (RLS)
  - PostgreSQL refresher
  - Edge Functions basics
- Days 3-4: Authentication exploration
  - Anonymous auth flow
  - Apple Sign In integration
  - Email magic links
  - Account linking patterns
- Days 5-6: Storage & Realtime
  - File storage setup
  - Image transformations
  - Realtime subscriptions
  - Change Data Capture (CDC)
- Day 7: Schema design
  - Database schema for journals, logs, access control
  - RLS policies
  - Test queries

**Week 2: Backend Implementation (5-7 days)**
- Days 1-2: Database setup
  - Create tables (journals, logs, devices, journal_access, invite_links)
  - Write RLS policies
  - Test with Supabase client
  - Seed test data
- Days 3-4: Storage setup
  - Configure storage buckets (photos, audio)
  - Set up RLS on storage
  - Test file uploads
  - Configure image transformations (thumbnails)
- Days 5-6: Edge Functions (if needed)
  - Invite link generation
  - Expiration logic
  - Webhook handlers
- Day 7: API integration testing
  - End-to-end flow testing
  - Performance testing
  - Error handling validation

**Week 3: iOS Client Implementation (5-7 days)**
- Days 1-2: Sync engine foundation
  - SwiftData ↔ Supabase sync service
  - Offline-first architecture
  - Conflict resolution (last-write-wins)
  - Network reachability
- Days 3-4: Authentication UI
  - Anonymous auth on first launch
  - Upgrade flow (Apple Sign In + Email)
  - Account linking UI
  - Settings screen (sign out, account management)
- Days 5-6: Invite link sharing
  - Generate invite link UI
  - Share sheet integration
  - Deep link handling (open invite links)
  - Journal access management
- Day 7: Realtime sync
  - Subscribe to journal changes
  - Push updates from cloud
  - UI refresh on remote changes

**Week 4: Testing & Polish (5-7 days)**
- Days 1-2: Integration testing
  - Multi-device sync testing (need 2+ devices)
  - Invite flow testing
  - Offline → online sync testing
  - Edge cases (simultaneous edits, network interruptions)
- Days 3-4: Performance optimization
  - Reduce API calls
  - Batch uploads
  - Background sync
  - Battery impact testing
- Days 5-6: Error handling & UX
  - Network error states
  - Sync conflict UI
  - Loading indicators
  - User feedback (success/failure messages)
- Day 7: Final QA
  - Device testing (iPhone, iPad)
  - Beta testing with wife/friends
  - Bug fixes

**Dependencies:**
- Supabase account (free tier sufficient for testing)
- Multiple devices for multi-user testing
- TestFlight for beta distribution

---

**v2.1: Apple Sign In Upgrade (If iOS-Only)**
**Estimated Time: 1 week**

- Days 1-2: Apple Sign In SDK integration
  - Configure Apple Developer account
  - Add Sign in with Apple capability
  - Implement AuthenticationServices framework
  - Test on device (requires real Apple ID)
- Days 3-4: Account upgrade flow
  - Anonymous → Apple ID linking
  - Supabase auth integration
  - Multi-device sync testing
- Days 5-6: Settings & account management
  - View linked devices
  - Sign out flow
  - Account deletion (GDPR compliance)
- Day 7: Testing & edge cases
  - Test upgrade flow
  - Test sign out → sign in
  - Test device sync after upgrade

**Dependencies:**
- Apple Developer Program membership ($99/year)
- Physical device (Apple Sign In requires real device, not simulator)

---

**v2.1: Android Launch (If Going Cross-Platform)**
**Estimated Time: 6-8 weeks**

**Note:** This assumes Android port of entire app, not just auth.

- Weeks 1-2: Android app foundation
  - Kotlin project setup
  - UI framework (Jetpack Compose)
  - SwiftUI → Compose translation
  - Navigation architecture
- Weeks 3-4: Feature parity
  - Journal list, log creation, editing
  - Camera, audio recording
  - Map view
  - Search & filter
- Weeks 5-6: Cloud sync integration
  - Supabase SDK for Android
  - Google Sign In integration
  - Email magic links
  - Sync engine (same logic as iOS)
- Weeks 7-8: Testing & polish
  - Device testing (multiple Android versions)
  - Cross-platform sync testing (iOS ↔ Android)
  - Beta testing
  - Bug fixes

**Dependencies:**
- Android Studio setup
- Android device(s) for testing
- Google Play Developer account ($25 one-time)
- Kotlin/Android experience (or time to learn)

---

**v2.2: Advanced Permissions**
**Estimated Time: 1-2 weeks**

- Week 1: Role-based access control
  - Database schema updates (roles)
  - RLS policy updates
  - UI for role assignment (owner, editor, viewer)
  - Permission enforcement in sync engine
- Week 2: Revoke & activity feed
  - Revoke access UI
  - Activity log (who added what)
  - Notifications for changes
  - Testing

---

**v2.5: Real-Time Collaboration**
**Estimated Time: 2-3 weeks**

- Week 1: Real-time infrastructure
  - Supabase Realtime subscriptions
  - Live updates when teammate adds log
  - Conflict detection
  - Operational transforms (if needed)
- Week 2: Push notifications
  - Firebase Cloud Messaging setup
  - APNs certificates
  - Notification delivery
  - User preferences (enable/disable)
- Week 3: Presence & polish
  - Presence indicators ("Alice is viewing...")
  - Typing indicators
  - Real-time cursor positions (advanced)
  - Performance optimization

---

**Total Time Investment Summary:**

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| v1.5 Single-Entry Sharing | 3-5 days | None (offline) |
| v2.0 Cloud Sync (Learning + Impl) | 3-4 weeks | Supabase account, devices |
| v2.1 Apple Sign In | 1 week | Apple Developer ($99) |
| v2.1 Android Port | 6-8 weeks | Android experience |
| v2.2 Advanced Permissions | 1-2 weeks | v2.0 complete |
| v2.5 Real-Time Collab | 2-3 weeks | v2.0 complete |

**Key Assumptions:**
- Solo developer working part-time (~20-30 hrs/week)
- First time using Supabase (includes learning curve)
- Testing time included in estimates
- No major blockers or architectural rewrites

**Risk Factors That Could Extend Timeline:**
- Sync conflicts more complex than expected (add 1-2 weeks)
- RLS policies hard to debug (add 3-5 days)
- Real device testing reveals issues (add 1 week)
- Performance optimization needed (add 1 week)
- Android port if no prior Kotlin experience (add 4-6 weeks)

---

**Milestone:** v1.5 (Single-entry sharing), v2.0+ (Multi-user + cloud)

---

### Cloud Sync with Active Indicators
**Status:** Future feature
**Priority:** High (v2.0)

**Goal:** Enable cloud-backed journal entries with real-time activity indicators

#### Active Badge Logic
- **Show "ACTIVE" badge** when journal has entries from the last hour
- Badge indicates recent field activity (user or team)
- Source of truth: Cloud (Firebase/CloudKit)
- Real-time updates via cloud sync

#### Implementation Notes
```swift
// Future: Check last entry timestamp
var isRecentlyActive: Bool {
    guard let lastEntry = logs.max(by: { $0.timestamp < $1.timestamp }) else {
        return false
    }
    let oneHourAgo = Date().addingTimeInterval(-3600)
    return lastEntry.timestamp > oneHourAgo
}

// In JournalCard view
if journal.isRecentlyActive {
    // Show ACTIVE badge
}
```

#### Benefits
- **Team collaboration:** See which journals colleagues are actively using
- **Personal tracking:** Quick visual of today's fieldwork
- **Cloud sync:** Entries backed up in real-time
- **Offline-first:** Local changes sync when connection available

#### Technical Requirements
- CloudKit or Firebase backend
- Conflict resolution for offline edits
- Real-time listeners for badge updates
- Battery-efficient sync strategy

#### UX Considerations
- Badge appears/disappears based on 1-hour window
- Subtle animation when badge appears
- Tap badge to see recent activity log?
- Settings to adjust "active" time window (30min, 1hr, 3hr)

**Milestone:** After v1.0 field testing validates core workflow

---

## Other Future Considerations

### Multi-User Journals
- Shared team journals
- Activity feed showing who added what
- @mentions for collaboration

### Advanced Sync
- Selective sync (download only journals you need)
- Conflict resolution UI
- Sync status indicators

### Analytics
- Weekly field time summary
- Most active journals
- Entry patterns/insights

---

**Last Updated:** 2026-05-14
**Next Review:** After v1.0 MVP field testing

**v1.0 Status Update (2026-05-14):**
- ✅ MapView completed (custom pins, callouts, live metrics, collapsible panel)
- ✅ Audio Recording & Transcription completed (manual transcription, retry logic)
- ⏳ Remaining for v1.0: Camera Integration (final blocker)
- 📋 Device test plan created: `docs/testing/device-test-plan.md`
- 🎯 MVP Progress: ~85% complete

**Future Features Documentation (2026-05-14):**
- 📝 Single-entry sharing strategy documented (v1.5)
- 📝 Multi-user collaboration architecture documented (v2.0+)
- 📝 Cross-platform authentication strategy documented (iOS → Android migration)
- 📝 10-layer cloud backend architecture documented (Supabase-based)
- ✅ Ready for validation before v2.0 implementation
