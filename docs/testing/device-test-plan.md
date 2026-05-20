# Physical Device Test Plan

**Target Device:** Wife's iPhone (Primary Test Device)
**Purpose:** Validate features that work in simulator but may fail on physical device
**Timeline:** Before TestFlight distribution or v1.0 launch

---

## Why Device Testing Matters

Many features work perfectly in simulator but fail on real devices:
- **GPS/Location Services:** Simulator uses mock locations
- **Camera/Photos:** Simulator uses limited test images
- **Audio Recording:** Simulator audio may not match device quality
- **Battery Drain:** Simulator doesn't reflect real power consumption
- **Network Conditions:** Simulator has perfect connectivity
- **Touch/Gesture Issues:** Simulator mouse != finger on glass
- **Performance:** Simulator runs on Mac CPU/GPU (much faster)
- **Biometric Auth:** Face ID/Touch ID require actual device
- **Outdoor Conditions:** Screen brightness, glare, rain, gloves

---

## Test Categories

### 🎯 Critical Path (Must Pass)

These are blocking issues for v1.0 launch. If any of these fail, we cannot ship.

#### 1. Log Creation Flow
**Why it matters:** Core user workflow

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Create new log with GPS | 1. Open New Log<br/>2. Wait for GPS lock<br/>3. Add notes<br/>4. Save | GPS coordinates captured accurately | ☐ | Compare with Apple Maps location |
| Create log without GPS | 1. Disable Location Services<br/>2. Create log<br/>3. Check error state | Graceful degradation, log still saves | ☐ | Should show "GPS unavailable" |
| Weather data fetch | 1. Create log with GPS<br/>2. Check weather card | Weather matches current conditions | ☐ | Compare with Weather app |
| Weather fetch failure | 1. Enable Airplane Mode<br/>2. Create log | Shows "Weather unavailable", allows saving | ☐ | Offline mode |
| **Weather retry uses log coordinates** | 1. Create log at location A (offline)<br/>2. Move to location B<br/>3. Go online<br/>4. Tap "Retry" weather | Weather data matches location A, NOT location B | ☐ | **CRITICAL: Must use log's stored coordinates** |
| Air quality data | 1. Create log in area with AQI data<br/>2. Check AQI values | AQI, PM2.5, PM10 displayed | ☐ | May not be available in all locations |

#### 2. Password Protection & Biometric Auth
**Why it matters:** Security features require hardware

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Enable password on journal | 1. Create journal<br/>2. Settings → Enable password | Password set successfully | ☐ | Test strong/weak passwords |
| Unlock with Face ID/Touch ID | 1. Lock journal<br/>2. Tap to open<br/>3. Authenticate with biometric | Unlocks immediately | ☐ | Test in different lighting |
| Fallback to password | 1. Cover Face ID<br/>2. Enter password | Password fallback works | ☐ | Test wrong password attempts |
| Brute force lockout | 1. Enter wrong password 5 times<br/>2. Wait 5 minutes | Locked out, then unlocks | ☐ | Time the 5-minute window |
| Biometric in sunlight | 1. Go outside<br/>2. Try Face ID unlock | Works in bright sunlight | ☐ | iPhone X+ feature |

#### 3. Map View
**Why it matters:** GPS accuracy is critical for field research

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Pin accuracy | 1. Create log at known location<br/>2. View on map<br/>3. Compare with Apple Maps | Pin within 5-10 meters of actual location | ☐ | Test in open area |
| Multiple pins | 1. Create 10+ logs in different locations<br/>2. View map | All pins show correctly | ☐ | Check for clustering |
| Pin selection | 1. Tap pins<br/>2. View callouts<br/>3. Navigate to details | All interactions smooth | ☐ | Test callout dismissal |
| Live metrics | 1. Expand/collapse metrics panel<br/>2. Check averages | Calculations correct | ☐ | Verify Fahrenheit conversion |
| Center button | 1. Zoom map manually<br/>2. Tap center button | Map centers on all logs | ☐ | Test with 1 log vs many |

#### 4. Camera Integration (Once Implemented)
**Why it matters:** Simulator camera is limited

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Take photo | 1. Tap Capture Photo<br/>2. Take picture<br/>3. Accept | Photo saved to log | ☐ | Check quality/orientation |
| Multiple photos | 1. Add 5+ photos to one log<br/>2. View gallery | All photos display | ☐ | Test slider/gallery |
| Photo permissions | 1. First use → Permission prompt<br/>2. Deny → Retry | Permission flow works | ☐ | Test Settings redirect |
| Photo in low light | 1. Take photo indoors/evening<br/>2. Check quality | Photo is usable | ☐ | Night mode on newer iPhones |
| Photo with gloves | 1. Wear field gloves<br/>2. Take photo | Camera button responsive | ☐ | Critical for field use |

#### 5. Audio Recording (Once Implemented)
**Why it matters:** Audio quality varies by device

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Record audio memo | 1. Tap Record<br/>2. Speak for 30s<br/>3. Stop<br/>4. Playback | Audio clear and saved | ☐ | Test in quiet/noisy environments |
| Audio permissions | 1. First use → Permission prompt<br/>2. Deny → Retry | Permission flow works | ☐ | Test Settings redirect |
| Speech recognition permission | 1. First transcription → Permission prompt<br/>2. Deny → Retry | Permission flow works | ☐ | Separate from microphone permission |
| Automatic transcription | 1. Record 30s speech<br/>2. Stop recording<br/>3. Wait for transcription | Text appears accurately | ☐ | Test clear speech |
| Transcription accuracy | 1. Record scientific terms<br/>2. Check transcription | Reasonable accuracy for common terms | ☐ | May misrecognize rare species names |
| Edit transcription | 1. Tap Edit on transcription<br/>2. Fix errors<br/>3. Save | Changes persist | ☐ | Manual correction workflow |
| Transcription in noise | 1. Record with background noise<br/>2. Check transcription | Degrades gracefully, still usable | ☐ | Test in field conditions |
| Offline transcription | 1. Enable Airplane Mode<br/>2. Record and transcribe | Works after initial language pack download | ☐ | First-time needs internet |
| Background audio | 1. Start recording<br/>2. Lock screen<br/>3. Unlock<br/>4. Stop | Recording continues | ☐ | Check iOS audio session config |
| Audio with wind | 1. Record outdoors<br/>2. Check playback | Wind noise minimal | ☐ | May need wind filter |
| Long recording | 1. Record 5+ minutes<br/>2. Check file size<br/>3. Check transcription | File size reasonable, transcription completes | ☐ | Test storage limits |
| Search transcribed audio | 1. Create logs with transcriptions<br/>2. Search for word from audio<br/>3. Verify results | Finds logs by audio content | ☐ | Test searchability |

---

### ⚠️ High Priority (Should Pass)

These are important for field usability but not blocking for initial TestFlight.

#### 6. Battery Life
**Why it matters:** Field sessions can be 4-8 hours

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| GPS drain (passive) | 1. Open app<br/>2. Use for 1 hour<br/>3. Check battery | <10% drain per hour | ☐ | With GPS tracking |
| GPS drain (active) | 1. Create 10 logs in 1 hour<br/>2. Check battery | <15% drain per hour | ☐ | With photo capture |
| Background battery | 1. Open app<br/>2. Lock phone for 1 hour<br/>3. Check battery | <2% drain | ☐ | App should suspend |
| Low Power Mode | 1. Enable Low Power Mode<br/>2. Use app normally | All features work | ☐ | May limit background refresh |

#### 7. Network Conditions
**Why it matters:** Field sites have poor/no connectivity

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Airplane mode | 1. Enable Airplane Mode<br/>2. Create log<br/>3. Save | GPS works, weather fails gracefully | ☐ | Critical offline test |
| Poor signal (1-2 bars) | 1. Find weak signal area<br/>2. Create log | Weather times out after 10s, saves log | ☐ | Test timeout handling |
| WiFi only (no cellular) | 1. Disable cellular<br/>2. Use WiFi<br/>3. Create log | Weather works if WiFi available | ☐ | Test fallback |
| Data reconnection | 1. Create logs offline<br/>2. Reconnect<br/>3. Open app | No data loss, no sync needed | ☐ | Offline-first architecture |

#### 8. Outdoor Usability
**Why it matters:** Field research happens outdoors

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Screen brightness (sunlight) | 1. Go outside on sunny day<br/>2. Use app | Text readable, buttons visible | ☐ | Test at noon |
| Touch with wet hands | 1. Wet hands slightly<br/>2. Use app | Touch targets responsive | ☐ | Simulate rain/sweaty hands |
| Touch with gloves | 1. Wear field gloves<br/>2. Navigate app | Buttons still tappable | ☐ | May need larger tap targets |
| Temperature (cold) | 1. Use phone in <0°C<br/>2. Create logs | Phone/app responsive | ☐ | Battery drains faster in cold |
| Temperature (hot) | 1. Use phone in >35°C<br/>2. Create logs | No overheating warnings | ☐ | Direct sunlight test |

#### 9. Performance
**Why it matters:** Simulator is much faster than device

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Logs list scroll (100+ logs) | 1. Create/import 100 logs<br/>2. Scroll quickly | Smooth 60fps scrolling | ☐ | Test card rendering |
| Map with 100+ pins | 1. View map with 100+ logs<br/>2. Zoom/pan | No lag or stuttering | ☐ | Test clustering |
| Photo gallery (50+ photos) | 1. Add 50 photos to one log<br/>2. Swipe through gallery | Fast image loading | ☐ | Test image caching |
| Journal with 500+ logs | 1. Import large dataset<br/>2. Navigate app | No noticeable slowdown | ☐ | Stress test |
| App launch time | 1. Kill app<br/>2. Relaunch<br/>3. Time to usable | <2 seconds | ☐ | Test SwiftData loading |

---

### 📊 Nice to Have (Optional)

These are enhancements but not critical for v1.0.

#### 10. Edge Cases
**Why it matters:** User reports often come from edge cases

| Test Case | Steps | Expected Result | Pass/Fail | Notes |
|-----------|-------|----------------|-----------|-------|
| Delete journal with 100+ logs | 1. Delete large journal<br/>2. Confirm | Deletes quickly | ☐ | Test cascade delete |
| Multiple journals (20+) | 1. Create 20 journals<br/>2. Navigate dashboard | Scrolling smooth | ☐ | Test with mix of protected/unprotected |
| Very long notes (10,000 chars) | 1. Paste large text<br/>2. Save log | No truncation or crash | ☐ | Test text field limits |
| Special characters in notes | 1. Use emojis, Chinese, Arabic<br/>2. Save | Text displays correctly | ☐ | Unicode handling |
| Date edge cases | 1. Create log at midnight<br/>2. Check timestamp | Date/time correct | ☐ | Test timezone handling |

---

## Test Execution Workflow

### Pre-Test Setup
1. ✅ Install latest build from Xcode to wife's iPhone
2. ✅ Grant all permissions (Location, Camera, Microphone)
3. ✅ Create 3-5 sample journals with test data
4. ✅ Note device model and iOS version
5. ✅ Charge device to 100%

### During Testing
1. **Follow test cases in order** (Critical → High Priority → Nice to Have)
2. **Mark Pass/Fail** for each test case
3. **Take screenshots** of any failures
4. **Note crash logs** (Settings → Privacy & Security → Analytics & Improvements)
5. **Record battery %** at start and end of each session

### Post-Test Review
1. **Triage failures:**
   - Critical failures → Block v1.0 launch
   - High priority failures → Fix before TestFlight
   - Nice to have failures → Add to backlog
2. **Create bug reports** for each failure
3. **Retest** after fixes
4. **Update this document** with findings

---

## TestFlight Beta Testing Plan

After initial device testing passes:

### Phase 1: Single User (Wife Only)
**Duration:** 1-2 weeks
**Goal:** Validate core workflow in real field conditions

**Test Scenarios:**
- Use app for daily fieldwork
- Create 20+ real logs in various conditions
- Test in different weather (sun, rain, cold)
- Report any crashes or confusing UX
- Identify missing features or pain points

**Success Criteria:**
- Zero data loss
- No critical crashes
- Can complete all field tasks
- No GPS accuracy issues
- Battery lasts full field day (8 hours)

### Phase 2: Extended Beta (Optional)
**Duration:** 2-4 weeks
**Goal:** Validate with 5-10 environmental scientists

**Recruitment:**
- Wife's colleagues
- Local university researchers
- iNaturalist community members

**Feedback Collection:**
- Weekly survey (Google Forms)
- Crash analytics (Firebase/Sentry)
- Usage metrics (anonymous)

---

## Bug Tracking Template

For each failure, document:

```markdown
### Bug #[NUMBER]

**Test Case:** [Name of test case]
**Severity:** Critical / High / Medium / Low
**Status:** Open / In Progress / Fixed / Won't Fix

**Description:**
[What went wrong]

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Environment:**
- Device: [e.g., iPhone 14 Pro]
- iOS Version: [e.g., 17.4]
- App Version: [e.g., 1.0.0 (123)]

**Screenshots/Logs:**
[Attach images or paste crash logs]

**Fix Priority:**
- [ ] Must fix before v1.0
- [ ] Must fix before TestFlight
- [ ] Can defer to v1.1
```

---

## Known Simulator vs. Device Differences

### Simulator Limitations (Won't Work on Simulator)
- ❌ Face ID / Touch ID (shows alert, auto-succeeds)
- ❌ True GPS coordinates (uses mock locations)
- ❌ Camera capture (limited to test images)
- ❌ Microphone recording (uses Mac mic)
- ❌ Battery monitoring (always shows 100%)
- ❌ True network conditions (simulated with Network Link Conditioner)
- ❌ Outdoor conditions (glare, rain, temperature)
- ❌ Touch pressure (mouse != finger)

### Features That Work on Both
- ✅ SwiftUI layout and rendering
- ✅ SwiftData persistence
- ✅ API calls (weather, AQI)
- ✅ MapKit rendering
- ✅ Navigation and state management
- ✅ Text input and validation
- ✅ Animations and transitions

---

## Device Requirements

### Minimum Requirements (v1.0)
- **iPhone:** iPhone 8 or newer
- **iOS:** iOS 16.0+
- **Storage:** 100 MB minimum
- **Features:** GPS, Camera, Microphone

### Recommended for Testing
- **iPhone:** iPhone 12 or newer (better GPS, camera, battery)
- **iOS:** iOS 17+ (latest MapKit features)
- **Storage:** 500 MB for testing (photos, audio)

### Wife's Device (Primary Test Device)
- **Model:** [To be documented]
- **iOS Version:** [To be documented]
- **Storage Available:** [To be documented]

---

## Next Steps

1. ☐ Complete remaining v1.0 features:
   - Log editing
   - Camera integration
   - Audio recording
   - Multi-image gallery with slider
2. ☐ Run this device test plan on wife's iPhone
3. ☐ Fix any critical failures
4. ☐ Build TestFlight beta
5. ☐ Distribute to wife for Phase 1 testing
6. ☐ Iterate based on feedback
7. ☐ Consider Phase 2 beta (optional)

---

**Last Updated:** 2026-05-13
**Document Owner:** David Contreras
**Test Coordinator:** Wife (primary field tester)
