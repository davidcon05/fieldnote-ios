# FieldJournal Launch Checklist

**App Name (Final):** FieldJournal *(subject to availability check)*
**Target Launch Date:** TBD (7-8 weeks from developer account enrollment)
**Current Status:** v1.0 MVP Complete (100%)

---

## Phase 1: Developer Account Setup (Week 1)

### Day 1: Apple Developer Program Enrollment
- [ ] Go to [developer.apple.com](https://developer.apple.com)
- [ ] Enroll in Apple Developer Program ($99/year)
- [ ] Complete enrollment form (requires Apple ID)
- [ ] Wait for approval email (~24-48 hours)
- [ ] **Blocker:** Cannot proceed until approved

---

### Day 2: Naming & Branding Decision

#### App Name Decision
- [ ] **Final name chosen:** _________________ (Options: FieldJournal, Chronicle, Daybook, Observation)
- [ ] Search App Store to confirm name is available
- [ ] Search Google to check domain availability (for future website)
- [ ] Decide if keeping "fieldnote" or rebranding entirely

#### If Rebranding from "fieldnote":
- [ ] Update Xcode project name (Project Settings → Info → Display Name)
- [ ] Update bundle identifier: `com.davidcontreras.[newname]`
- [ ] Find/replace "fieldnote" in code comments and strings
- [ ] Update README.md and documentation
- [ ] Update `.xcodeproj` file name (optional, cosmetic)

**Estimated Time:** 2-3 hours (if decisive)

---

### Day 3: Xcode Configuration

#### Add Apple Developer Account to Xcode
- [ ] Xcode → Settings (Cmd+,) → Accounts tab
- [ ] Click "+" → Add Apple ID
- [ ] Sign in with developer account
- [ ] Verify "Apple Developer Program" role appears

#### Create App ID in App Store Connect
- [ ] Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- [ ] Apps → "+" → New App
- [ ] **Platforms:** iOS
- [ ] **Name:** [Your chosen app name]
- [ ] **Primary Language:** English (U.S.)
- [ ] **Bundle ID:** Register new Bundle ID
  - [ ] Format: `com.davidcontreras.[appname]`
  - [ ] Description: "FieldJournal App"
  - [ ] Explicit App ID (not wildcard)
- [ ] **SKU:** Use bundle ID (e.g., `com.davidcontreras.fieldjournal`)
- [ ] **User Access:** Full Access

#### Enable App Capabilities
In App Store Connect → Your App → App Information → Capabilities:
- [ ] **Location (When In Use)** - For GPS tagging
- [ ] **Camera** - For photo capture
- [ ] **Microphone** - For audio memos
- [ ] **Photo Library** - For saving/loading photos
- [ ] **Face ID / Touch ID** - For journal password protection
- [ ] **Background Modes (optional, for v1.5 navigation):**
  - [ ] Location updates
  - [ ] Audio (for background audio memos)

#### Configure Signing in Xcode
- [ ] Open project in Xcode
- [ ] Select project in navigator → Target: fieldnote
- [ ] **Signing & Capabilities** tab
- [ ] **Team:** Select your Apple Developer account
- [ ] **Signing:** ✅ Automatically manage signing
- [ ] **Bundle Identifier:** Match what you created in App Store Connect
- [ ] Verify "Signing Certificate" shows "Apple Development" (for testing)
- [ ] Build project (Cmd+B) to generate provisioning profile

**Estimated Time:** 1-2 hours

---

### Day 4: Xcode Cloud Setup

#### Option A: Xcode Cloud (Recommended)
- [ ] Xcode → Product → Xcode Cloud → Create Workflow
- [ ] Authorize Xcode Cloud to access your GitHub repo
- [ ] Choose workflow template: **"TestFlight Distribution"**
- [ ] Configure workflow:
  ```
  Name: TestFlight Deployment
  Trigger: On push to 'main' branch
  Actions:
    ☑ Run Unit Tests (fieldnoteTests)
    ☐ Run UI Tests (skip to save compute time)
    ☑ Archive
    ☑ Upload to TestFlight (Internal Testing)
  ```
- [ ] Save workflow
- [ ] Push a commit to `main` to trigger first build
- [ ] Monitor build in Xcode Cloud dashboard
- [ ] Verify build appears in App Store Connect → TestFlight

**Compute estimate:** ~10 min per build, 25 hrs/month free tier

#### Option B: GitHub Actions (Alternative)
<details>
<summary>Expand if choosing GitHub Actions over Xcode Cloud</summary>

- [ ] Install Fastlane: `brew install fastlane`
- [ ] Initialize Fastlane: `cd [project] && fastlane init`
- [ ] Create `.github/workflows/testflight.yml`
- [ ] Configure Fastlane Match for code signing
- [ ] Add secrets to GitHub repo settings:
  - `APPLE_ID`
  - `APPLE_APP_SPECIFIC_PASSWORD`
  - `MATCH_PASSWORD`
  - `FASTLANE_SESSION`
- [ ] Test workflow: Push to `main`

**Warning:** Requires manual certificate management and debugging. Only choose if you need GitHub Actions for other CI/CD tasks.
</details>

**Decision:** Using Xcode Cloud ☐ or GitHub Actions ☐

**Estimated Time:**
- Xcode Cloud: 1-2 hours
- GitHub Actions: 4-8 hours (first time)

---

### Day 5: First TestFlight Build & Device Test

#### Trigger First Build
- [ ] Commit a small change (e.g., update version to `1.0.0`)
- [ ] Push to `main` branch
- [ ] Monitor Xcode Cloud (or GitHub Actions) build progress
- [ ] Wait for build to complete (~15-20 min first time)
- [ ] Check App Store Connect → TestFlight → iOS builds
- [ ] Verify build status: "Ready to Test"

#### Install TestFlight & Test on Device
- [ ] Install **TestFlight** app from App Store on iPhone
- [ ] App Store Connect → TestFlight → Internal Testing
- [ ] Add yourself as internal tester (your Apple ID email)
- [ ] Check email for TestFlight invite
- [ ] Open invite → Install app via TestFlight
- [ ] Launch app on device for first time

#### Quick Smoke Test
- [ ] App launches without crashing
- [ ] Dashboard loads
- [ ] Create a test journal
- [ ] Create a test log with GPS/weather
- [ ] Take a photo (camera opens)
- [ ] Record audio memo
- [ ] Check map view
- [ ] Test password protection + Face ID

**If any of these fail:** Debug locally, fix, rebuild via CI/CD

**Estimated Time:** 2-3 hours (including wait time for build)

---

## Phase 2: Device Testing & Bug Fixes (Week 2)

### Critical Path Testing (Must Pass)

Use `docs/testing/device-test-plan.md` as your guide. Focus on:

#### Test Category 1: Log Creation Flow
- [ ] Create log with GPS (compare accuracy with Apple Maps)
- [ ] Create log without GPS (airplane mode, verify graceful degradation)
- [ ] Weather data fetch (verify matches Weather app)
- [ ] Weather retry uses log's coordinates (NOT current location) ⚠️ CRITICAL
- [ ] Air quality data (if available in your area)

#### Test Category 2: Password Protection & Biometrics
- [ ] Enable password on journal
- [ ] Unlock with Face ID/Touch ID
- [ ] Password fallback (cover Face ID sensor)
- [ ] Brute force lockout (5 wrong attempts → 5-minute lockout)
- [ ] Test in direct sunlight (Face ID can fail)

#### Test Category 3: Camera & Photos
- [ ] Take photo with device camera
- [ ] Multiple photos (add 5+ to one log)
- [ ] Photo gallery slider (swipe between photos)
- [ ] Delete photo (confirm deletion)
- [ ] Photo library import (select existing photos)
- [ ] Photo with gloves on (critical for field use)

#### Test Category 4: Audio Recording
- [ ] Record audio memo (30 seconds)
- [ ] Playback audio
- [ ] Speech-to-text transcription (automatic)
- [ ] Transcription accuracy (speak clearly)
- [ ] Transcription in noisy environment (degrades gracefully?)
- [ ] Multiple audio memos per log
- [ ] Delete audio memo

#### Test Category 5: Map View
- [ ] Pins show for all logs with GPS
- [ ] Tap pin → Callout appears
- [ ] Navigate from map to log detail
- [ ] Live metrics panel (expand/collapse)
- [ ] Center button (zoom to fit all pins)

#### Test Category 6: Search & Filter
- [ ] Search journals by name (Dashboard)
- [ ] Search logs by notes (Logs List)
- [ ] Search logs by audio transcription
- [ ] Sort options (Most Recent, Oldest, A-Z, Z-A)
- [ ] Clear search

#### Test Category 7: Battery Life
- [ ] Use app for 1 hour with GPS enabled
- [ ] Note starting battery %: _____
- [ ] Note ending battery %: _____
- [ ] Calculate drain: _____ % per hour
- [ ] **Target:** <10% drain per hour (passive GPS tracking)

#### Test Category 8: Offline Mode
- [ ] Enable Airplane Mode
- [ ] Create log (GPS should work, weather should fail gracefully)
- [ ] Save log offline
- [ ] Re-enable connectivity
- [ ] Verify log persisted correctly

### Bug Tracking

For each bug found, document in `docs/bug-fixes-and-implementations.md`:

```markdown
### Bug #X: [Bug Title]
**Date:** 2026-MM-DD
**Status:** 🔴 Open / 🟡 In Progress / ✅ Resolved

**Problem:**
- [What went wrong]

**Root Cause:**
- [Why it happened]

**Solution:**
- [How you fixed it]

**Files Changed:**
- [List of files modified]
```

**Estimated Time:** 5-7 days (including fix iterations)

---

## Phase 3: App Store Preparation (Week 3)

### App Metadata & Content

#### Privacy Policy (Required)
- [ ] Write privacy policy (see template below)
- [ ] Host on:
  - [ ] GitHub Pages (free)
  - [ ] Notion public page (easy)
  - [ ] Personal website
- [ ] Test URL is publicly accessible
- [ ] Add URL to App Store Connect → App Privacy → Privacy Policy URL

<details>
<summary>Privacy Policy Template</summary>

```markdown
# Privacy Policy for FieldJournal

**Last Updated:** [DATE]

## Data Collection
FieldJournal does NOT collect, transmit, or store any user data on external servers.

## Local Storage
All journals, logs, photos, and audio recordings are stored locally on your device using Apple's SwiftData framework. Your data never leaves your device.

## Location Data
GPS coordinates are captured for field observations and stored locally on your device. Location data is never transmitted to external servers.

## Camera & Microphone
Photos and audio memos are stored locally on your device. We do not access your photo library or microphone without explicit permission.

## Third-Party Services
FieldJournal uses the following third-party services to enhance functionality:

- **OpenWeatherMap API** - Fetches weather data based on GPS coordinates
  - Privacy Policy: https://openweathermap.org/privacy-policy
  - Data sent: GPS coordinates only

- **OpenAQ API** - Fetches air quality data based on GPS coordinates
  - Privacy Policy: https://openaq.org/privacy
  - Data sent: GPS coordinates only

No personal information is transmitted to these services.

## Data Deletion
You can delete all data by deleting the app from your device. No data is stored externally or in cloud backups unless you explicitly enable iCloud backup for app data in iOS Settings.

## Children's Privacy
FieldJournal does not knowingly collect any data from children under 13. The app is designed for scientific research and journaling.

## Contact
For questions or concerns, email: [YOUR-EMAIL]

## Changes to This Policy
We may update this privacy policy from time to time. Updates will be posted at this URL with a new "Last Updated" date.
```
</details>

**Estimated Time:** 1 hour to write, 30 min to publish

---

#### App Store Permissions Justification

In Xcode → Info.plist, verify these descriptions are **specific and justified**:

```xml
<!-- Current descriptions need to be MORE SPECIFIC -->

<key>NSLocationWhenInUseUsageDescription</key>
<string>FieldJournal uses your location to automatically tag field observations with GPS coordinates and altitude for research documentation and personal journaling.</string>

<key>NSCameraUsageDescription</key>
<string>FieldJournal needs camera access to capture photos of specimens, field conditions, and moments you want to document in your journals.</string>

<key>NSMicrophoneUsageDescription</key>
<string>FieldJournal records audio memos for field notes and automatically transcribes them into searchable text.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>FieldJournal uses speech recognition to automatically transcribe your audio memos into searchable text notes, making it easier to find observations later.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>FieldJournal needs access to your photo library to save and retrieve photos attached to your journal entries.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>FieldJournal saves photos you capture to your device for safekeeping and easy access in your journals.</string>

<key>NSFaceIDUsageDescription</key>
<string>FieldJournal uses Face ID to securely unlock password-protected journals, keeping your private notes safe.</string>
```

- [ ] Update Info.plist with detailed descriptions
- [ ] Build app and test that permission prompts show correct text
- [ ] Screenshot permission prompts for App Review (if needed)

**Estimated Time:** 30 minutes

---

#### App Screenshots & Media

**Required screenshots:**
- **6.7" Display (iPhone 15 Pro Max)** - 3-5 screenshots (REQUIRED)
- **6.5" Display (iPhone 14 Plus)** - 3-5 screenshots (REQUIRED)
- **5.5" Display (iPhone 8 Plus)** - 3-5 screenshots (Optional, for older devices)

**Optional but recommended:**
- **App Preview Video** - 15-30 second video showing app in action

#### How to Capture Screenshots:
1. **Use Simulator:**
   - Xcode → Open Simulator → iPhone 15 Pro Max
   - Run app (Cmd+R)
   - Navigate to key screens
   - Screenshot: Cmd+S (saves to Desktop)

2. **OR Use Real Device:**
   - Take screenshots on device (Power + Volume Up)
   - AirDrop to Mac
   - Resize to exact App Store dimensions

#### Which Screens to Screenshot:
- [ ] **Screenshot 1:** Dashboard with multiple journals (hero shot)
- [ ] **Screenshot 2:** Map view with pins and metrics panel
- [ ] **Screenshot 3:** Log detail view with photo, weather, GPS
- [ ] **Screenshot 4:** New log entry screen (Bento layout)
- [ ] **Screenshot 5:** Photo gallery slider (swipe between photos)

**Pro tip:** Add text overlays highlighting features (use Figma, Canva, or Keynote)

#### App Icon (1024x1024)
- [ ] Verify you have `AppIcon` in Assets.xcassets
- [ ] Export 1024x1024 version for App Store Connect
- [ ] Test icon looks good at small sizes (home screen)

**Estimated Time:** 4-6 hours (DIY), or hire designer ($50-200)

---

#### App Store Connect Metadata

Log in to [App Store Connect](https://appstoreconnect.apple.com) → Your App → App Information

##### Basic Info
- [ ] **App Name:** _________________________________ (30 char limit)
- [ ] **Subtitle:** _________________________________ (30 char limit)
  - Suggested: "Field research companion" or "GPS-tagged journals"
- [ ] **Primary Language:** English (U.S.)

##### Category
- [ ] **Primary Category:** Productivity (or Education if research-focused)
- [ ] **Secondary Category:** Lifestyle (or Utilities)

##### Description (4000 char limit)
<details>
<summary>Description Template</summary>

```
FieldJournal is a powerful GPS-tagged journaling app designed for field researchers, environmental scientists, and anyone who wants to document their experiences with precision.

🌍 AUTOMATIC LOCATION TAGGING
Every entry captures GPS coordinates, altitude, and compass direction automatically. Perfect for field research, hiking, travel, or simply remembering where life's moments happened.

📸 PHOTO-RICH JOURNALS
Add multiple photos to each entry with our beautiful swipe gallery. Photos are stored locally on your device—your memories, your control.

🎤 AUDIO MEMOS WITH TRANSCRIPTION
Record voice notes and let FieldJournal automatically transcribe them into searchable text. Find past observations by simply searching what you said.

☁️ WEATHER & AIR QUALITY
Each entry automatically logs weather conditions and air quality at the moment of capture. Track environmental patterns over time.

🗺️ INTERACTIVE MAP VIEW
Visualize all your entries on a map. See where you've been, discover patterns, and navigate back to important locations.

🔒 PRIVACY FIRST
Password-protect journals with Face ID or Touch ID. All data stored locally—no cloud account required. Your journals, your privacy.

🔍 POWERFUL SEARCH
Search across all journals by text, location, date, or even transcribed audio. Find anything instantly.

📱 WORKS OFFLINE
Capture observations even without internet. Perfect for remote field sites, backpacking trips, or anywhere off the grid.

PERFECT FOR:
• Environmental scientists & ecologists
• Field researchers & surveyors
• Hikers & outdoor enthusiasts
• Travel journaling
• Photography logs
• Bird watching & wildlife tracking
• Garden & plant observations
• Personal memory keeping

100% local storage. No ads. No tracking. No subscription.

Download FieldJournal and start documenting your world with precision.
```
</details>

- [ ] Write or adapt description above
- [ ] Verify character count <4000
- [ ] Paste into App Store Connect

##### Keywords (100 char limit, comma-separated)
```
field notes,gps,journal,research,logger,observations,wildlife,ecology,outdoor,science,diary,travel,hiking,map,location
```

- [ ] Customize keywords for your app
- [ ] Verify total length <100 characters
- [ ] Avoid spaces after commas (counts as characters)

##### Support & Marketing URLs
- [ ] **Support URL:** (Required)
  - Your email: `mailto:your-email@example.com`
  - OR GitHub issues: `https://github.com/yourusername/fieldjournal/issues`
  - OR personal site: `https://yourwebsite.com/support`

- [ ] **Marketing URL:** (Optional)
  - Landing page for the app (can build later)

##### Copyright
- [ ] Format: `2026 [Your Name]`

##### Age Rating
- [ ] Complete age rating questionnaire
- [ ] Expected rating: **4+ (No Objectionable Content)**

##### App Review Information
- [ ] **First Name:** [Your first name]
- [ ] **Last Name:** [Your last name]
- [ ] **Phone Number:** [Your phone number]
- [ ] **Email:** [Your email]
- [ ] **Demo Account:** Not required (no sign-in needed)
- [ ] **Notes:**
  ```
  This app uses GPS for field observations and does not require an account.
  Sample data is pre-loaded for review. No special configuration needed.
  ```

##### Version Information (1.0)
- [ ] **Version Number:** 1.0
- [ ] **Copyright:** 2026 [Your Name]
- [ ] **What's New in This Version:** (Skip for first version)

**Estimated Time:** 2-3 hours

---

#### App Privacy Details (Required as of iOS 14)

App Store Connect → App Privacy → Get Started

Answer these questions about data collection:

**Data Collection: NO**
- [ ] ✅ We do not collect data from this app

**Data Types:**
- [ ] Location: Used for functionality, not collected
- [ ] Photos/Videos: Stored locally, not collected
- [ ] Audio Data: Stored locally, not collected
- [ ] User Content: Stored locally, not collected

**Third-Party Data:**
- [ ] OpenWeatherMap: Collects GPS coordinates for weather lookup (disclosed)
- [ ] OpenAQ: Collects GPS coordinates for air quality lookup (disclosed)

**Privacy Policy URL:**
- [ ] Add URL to hosted privacy policy

**Estimated Time:** 30 minutes

---

#### Export Compliance

**Question:** Does your app use encryption?

**Answer:** **No** (for your use case)

**Why:** Your app uses:
- ✅ Keychain for password storage (Apple's built-in, exempt)
- ✅ HTTPS for API calls (standard, exempt)
- ✅ No custom encryption algorithms

**When submitting:** Select **"No"** for encryption usage → Automatic approval

---

### Pre-Submission Checklist

Before hitting "Submit for Review":

- [ ] App tested on **real device** (not just simulator)
- [ ] All critical bugs fixed
- [ ] Privacy policy URL publicly accessible
- [ ] Screenshots uploaded (6.7" and 6.5" required)
- [ ] App icon 1024x1024 uploaded
- [ ] Description, keywords, categories filled
- [ ] Info.plist permission descriptions detailed and specific
- [ ] Age rating completed (4+)
- [ ] Export compliance answered (No encryption)
- [ ] Test build uploaded to TestFlight
- [ ] App launches without crashing on TestFlight
- [ ] Contact info (email, phone) accurate

**Estimated Time for Phase 3 Total:** 5 days

---

## Phase 4: TestFlight Beta Testing (Weeks 4-5)

### Internal Testing (You + Wife)

#### Add Internal Testers
- [ ] App Store Connect → TestFlight → Internal Testing → "+" → Add Tester
- [ ] Add email addresses:
  - [ ] Your Apple ID email
  - [ ] Wife's Apple ID email
- [ ] Both receive TestFlight invite emails
- [ ] Install TestFlight app from App Store
- [ ] Open invite → Install app

#### Beta Testing Protocol

**Week 1 (Your Testing):**
- [ ] Use app daily for 3-5 days
- [ ] Create 10+ journals (mix of research and personal)
- [ ] Add 50+ logs across journals
- [ ] Test all features systematically
- [ ] Document any bugs/crashes in `bug-fixes-and-implementations.md`
- [ ] Monitor battery usage (Settings → Battery → Show Activity)
- [ ] Test offline mode (airplane mode for 1 hour)

**Week 2 (Wife's Field Testing):**
- [ ] Wife installs app via TestFlight
- [ ] Brief tutorial/walkthrough (10 minutes)
- [ ] Wife uses app for real fieldwork (1-2 weeks)
- [ ] Collect feedback:
  - [ ] Crashes or bugs
  - [ ] Confusing UI/UX
  - [ ] Missing features
  - [ ] Battery life concerns
  - [ ] Performance issues
- [ ] Iterate based on feedback:
  - [ ] Fix bugs locally
  - [ ] Push to main → Xcode Cloud builds → TestFlight updates
  - [ ] Wife tests fixes
  - [ ] Repeat until stable

#### Exit Criteria (Ready for Public Release)
- [ ] Zero crashes in 1 week of daily use
- [ ] No data loss incidents
- [ ] Battery drain acceptable (<10-15% per hour active use)
- [ ] All critical bugs fixed
- [ ] Wife confirms she would use this over stock iOS apps
- [ ] All v1.0 features working as designed

**Estimated Time:** 10-14 days

---

### External Testing (Optional - Skip for v1.0)

If you want to test with more users (not required for v1.0):

- [ ] App Store Connect → TestFlight → External Testing
- [ ] Submit build for Beta App Review (Apple reviews TestFlight builds)
- [ ] Wait 24-48 hours for approval
- [ ] Add external testers (up to 10,000 emails)
- [ ] Distribute invite links
- [ ] Collect feedback via TestFlight feedback mechanism

**When to do this:** After wife's testing validates the app works, and you want wider feedback before public launch.

---

## Phase 5: Final Polish & Iteration (Week 6)

### Based on Beta Feedback

- [ ] Prioritize bugs by severity:
  - [ ] **Critical:** Crashes, data loss, broken core features
  - [ ] **High:** Annoying UX, performance issues, battery drain
  - [ ] **Medium:** Minor UI polish, missing nice-to-haves
  - [ ] **Low:** Future enhancements

- [ ] Fix critical and high-priority bugs
- [ ] Test fixes on device
- [ ] Push updates to TestFlight
- [ ] Wife validates fixes in field

### Performance Optimization (If Needed)

- [ ] Profile app with Instruments (Xcode → Product → Profile)
- [ ] Check memory usage (Target: <100 MB)
- [ ] Check battery impact (Target: <10% per hour active)
- [ ] Optimize image loading (compress photos before saving)
- [ ] Reduce GPS poll frequency if draining battery

### UX Polish (Nice-to-Haves)

- [ ] Add loading indicators where missing
- [ ] Improve error messages (make user-friendly)
- [ ] Add haptic feedback (subtle vibrations on actions)
- [ ] Animation polish (smooth transitions)
- [ ] Empty state improvements (better messaging)

**Estimated Time:** 5-7 days

---

## Phase 6: App Store Submission (Week 7)

### Final Pre-Submission Checks

- [ ] Version number incremented to `1.0` in Xcode
- [ ] Build number incremented (e.g., `1` for first public build)
- [ ] Archive build: Xcode → Product → Archive
- [ ] Upload to App Store Connect (NOT TestFlight internal)
- [ ] Wait for build to process (~15 minutes)
- [ ] Build status: "Ready for Review"

### Submit for Review

- [ ] App Store Connect → Your App → "+" version → 1.0
- [ ] Select build to submit
- [ ] Answer questionnaire:
  - [ ] Advertising Identifier: No
  - [ ] Content Rights: I own the rights
  - [ ] Export Compliance: No encryption
- [ ] Add version release notes:
  ```
  Initial release of FieldJournal

  • GPS-tagged journal entries
  • Automatic weather & air quality logging
  • Multi-photo galleries
  • Audio memos with transcription
  • Interactive map view
  • Password protection with Face ID
  • Offline-first design
  • Powerful search across all journals
  ```
- [ ] **Release Options:**
  - [ ] ✅ Automatic release (goes live immediately after approval)
  - [ ] OR Manual release (you control when it goes live)
- [ ] Click **"Submit for Review"**

### App Review Process

**Timeline:**
- Submission → Review: 1-3 days (average 24-48 hours)
- Review → Approval: Usually same day (if no issues)
- Approval → Live: Immediate (if automatic release)

**Possible Outcomes:**

1. **✅ Approved** - App goes live on App Store
2. **❌ Rejected** - Apple provides reasons, you fix and resubmit
3. **⚠️ Metadata Rejected** - Fix description/screenshots, no new build needed

**Common rejection reasons:**
- Incomplete metadata (missing screenshots, description)
- Permission descriptions too vague
- Crashes on reviewer's device (make sure it's stable!)
- Privacy policy missing or inaccessible
- App doesn't do what description says

### If Rejected

- [ ] Read rejection message carefully
- [ ] Fix issues locally
- [ ] Upload new build (if code changes needed)
- [ ] OR fix metadata only (if just description/screenshots)
- [ ] Reply to App Review via Resolution Center
- [ ] Resubmit for review
- [ ] Wait another 1-3 days

**Estimated Time:** 1-2 days (submission), then 2-5 days (review + iteration if needed)

---

## Phase 7: Launch & Post-Launch (Week 8+)

### App Goes Live 🎉

- [ ] Verify app is live on App Store (search for your app name)
- [ ] Download from App Store (not TestFlight) to test public version
- [ ] Share with friends/family
- [ ] Post on social media (Twitter, LinkedIn, Reddit, etc.)
- [ ] Submit to app directories:
  - [ ] Product Hunt (for tech audience)
  - [ ] Indie Hackers (for indie dev community)
  - [ ] AlternativeTo (for "alternative to [X]" searches)

### Monitor Reviews & Crashes

- [ ] Set up App Store Connect notifications (email alerts for reviews)
- [ ] Check App Store Connect → Analytics daily for first week
- [ ] Monitor crash reports (App Store Connect → TestFlight → Crashes)
- [ ] Respond to reviews (thank positive ones, address negative ones)

### Iterate Based on User Feedback

- [ ] Collect feature requests (GitHub issues, email, reviews)
- [ ] Prioritize by user impact
- [ ] Plan v1.1 features (see `docs/future-features.md`)

---

## Timeline Summary

| Phase | Duration | Key Milestone |
|-------|----------|---------------|
| **Week 1** | 5 days | Developer account → Xcode Cloud → First TestFlight build |
| **Week 2** | 5 days | Device testing → Bug fixes |
| **Week 3** | 5 days | App Store metadata → Privacy policy → Screenshots |
| **Week 4-5** | 10-14 days | Beta testing with wife → Iterations |
| **Week 6** | 5-7 days | Final polish & optimization |
| **Week 7** | 2-5 days | App Store submission → Review → Approval |
| **Week 8+** | Ongoing | Public launch → User feedback → v1.1 planning |

**Total Time to Launch:** 7-8 weeks

**Bottlenecks:**
- ⏰ Apple Developer approval (24-48 hrs)
- ⏰ App Store review (1-3 days)
- ⏰ Wife's field testing schedule (depends on her availability)

---

## Success Criteria

### v1.0 Launch is Successful If:
- [ ] App approved by App Store (no rejections)
- [ ] Zero crashes reported in first week
- [ ] No data loss incidents
- [ ] Wife uses app regularly (replaces stock iOS apps)
- [ ] Battery life acceptable for field use (4+ hours active)
- [ ] 5+ downloads from friends/family (validation)
- [ ] At least 1 positive review on App Store

### Metrics to Track (Post-Launch)
- **Downloads:** Target 50 in first month (friends/family)
- **Crashes:** Target <1% crash rate
- **Reviews:** Target 4+ stars average
- **Retention:** Wife still using after 1 month
- **Feature requests:** Track most-requested features for v1.1

---

## Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **App Store rejection** | Medium | High | Follow checklist, test thoroughly, detailed metadata |
| **Device testing reveals critical bugs** | High | High | Allocate 2 weeks for bug fixes, prioritize critical path |
| **Wife doesn't like UX** | Low | High | Involve her early, iterate based on feedback |
| **Battery drain too high** | Medium | Medium | Profile with Instruments, optimize GPS polling |
| **Name already taken** | Medium | Low | Check App Store early, have backup names ready |
| **App Store review takes >1 week** | Low | Low | Submit on Tuesday (faster reviews mid-week) |
| **Naming conflict discovered late** | Low | High | **Resolve naming NOW before App Store Connect setup** |

---

## Emergency Contacts & Resources

### If You Get Stuck:

**Apple Developer Support:**
- Forum: https://developer.apple.com/forums/
- Email: developer-support@apple.com (login required)
- Phone: 1-800-633-2152 (US) - For account/membership issues

**App Store Review:**
- Resolution Center: App Store Connect → Contact Us
- Appeal rejections: https://developer.apple.com/app-store/review/

**Xcode Cloud Issues:**
- Documentation: https://developer.apple.com/xcode-cloud/
- Feedback Assistant: https://feedbackassistant.apple.com/

**Useful Resources:**
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/
- App Store Connect Help: https://help.apple.com/app-store-connect/

---

## Post-Launch: v1.1 Planning

After successful launch, plan next features based on:
1. User feedback (reviews, emails)
2. Wife's feature requests
3. Your vision (see `docs/future-features.md`)

**Top candidates for v1.1:**
- Global search across all journals (not just current journal)
- Photo metadata extraction (GPS from photos)
- Species tagging (for bird journals)
- Land navigation (GPS-guided return to locations)
- Export/sharing single entries

See `docs/future-features.md` for full roadmap.

---

**Last Updated:** 2026-05-25
**Document Owner:** David Contreras
**Current Status:** Pre-Launch (v1.0 MVP Complete)

**Next Action:** Enroll in Apple Developer Program ($99) → Start Week 1
