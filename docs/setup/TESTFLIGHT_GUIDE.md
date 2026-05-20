# TestFlight Distribution Guide

**Purpose:** Distribute Field Note app to wife's iPhone for beta testing without App Store submission
**Audience:** Single user (wife) or small group (<100 testers)

---

## TL;DR: Do I Need a Paid Developer Account?

### YES - You Need the $99/year Apple Developer Program

**Why:**
- TestFlight requires app to be uploaded to App Store Connect
- App Store Connect access requires paid Apple Developer Program membership ($99/year USD)
- Free Xcode developer account cannot access TestFlight

**What You Get:**
- TestFlight for up to 10,000 beta testers
- 90-day testing period per build
- Unlimited builds
- Crash reports and analytics
- No App Store submission required (can stay in beta forever)

**Cost Breakdown:**
- Apple Developer Program: **$99/year**
- Renewal: Automatic annual renewal (can cancel anytime)
- No per-app fees
- No per-tester fees
- No additional costs

---

## Alternative: Free Distribution (Without TestFlight)

If you don't want to pay $99/year, you have these options:

### Option 1: Direct Install from Xcode (FREE)
**Best for:** Single device testing (wife's iPhone only)

**Pros:**
- ✅ Completely free
- ✅ Install directly from your Mac
- ✅ Immediate updates (just rebuild and install)
- ✅ No Apple Developer Program needed

**Cons:**
- ❌ Must connect iPhone to Mac via cable
- ❌ App expires after 7 days (must reinstall weekly)
- ❌ Max 3 devices per free account
- ❌ No over-the-air (OTA) updates
- ❌ No crash analytics
- ❌ Wife must be physically present to install

**Steps:**
1. Connect wife's iPhone to your Mac
2. In Xcode: Product → Destination → Wife's iPhone
3. Product → Run (or Cmd+R)
4. First time: Trust developer cert on iPhone (Settings → General → VPN & Device Management)
5. App installs and runs
6. Reinstall every 7 days when app expires

**When to use:** Perfect for initial field testing if you're comfortable with weekly reinstalls

---

### Option 2: Ad Hoc Distribution (FREE)
**Best for:** Up to 100 devices without TestFlight

**Pros:**
- ✅ Free (no Apple Developer Program)
- ✅ Up to 100 devices per year
- ✅ 7-day expiration (same as Xcode direct install)
- ✅ Can email .ipa file to testers

**Cons:**
- ❌ App expires after 7 days (must rebuild and resend)
- ❌ Testers must manually install via Finder/iTunes
- ❌ No OTA updates
- ❌ No crash analytics
- ❌ Manual device UUID registration

**Steps:**
1. Get wife's iPhone UDID: Connect to Mac → Finder → iPhone → Click serial number to reveal UDID
2. Xcode → Signing & Capabilities → Add UDID to provisioning profile
3. Product → Archive
4. Distribute App → Ad Hoc → Export .ipa file
5. Send .ipa to wife via AirDrop or email
6. Wife installs via Finder (drag .ipa to iPhone in Finder)

**When to use:** If you want to test on multiple devices but don't want to pay for Apple Developer Program

---

### Option 3: Apple Developer Program ($99/year) + TestFlight
**Best for:** Professional beta testing, future App Store release

**Pros:**
- ✅ 90-day app expiration (no weekly reinstalls)
- ✅ Over-the-air (OTA) updates
- ✅ Up to 10,000 testers
- ✅ Crash reports and analytics
- ✅ TestFlight app provides feedback mechanism
- ✅ Professional testing workflow
- ✅ Can submit to App Store later (same account)
- ✅ Automatic updates when you upload new builds

**Cons:**
- ❌ Costs $99/year
- ❌ Requires App Store Connect setup (more steps)
- ❌ Initial setup time (~1 hour)

**When to use:**
- You plan to release on App Store eventually
- You want professional analytics and crash reports
- You have 5+ testers
- You don't want to deal with 7-day expiration
- Wife travels and can't reconnect to Mac weekly

---

## Recommendation for Your Use Case

### Scenario: Wife's iPhone Only, No App Store Plans Yet

**Start with Option 1 (FREE Xcode Install):**
1. Install directly from Xcode
2. Test for 1-2 weeks
3. Reinstall every 7 days (takes 30 seconds)

**If this works well for 1-2 months:**
- Stick with it! It's free and sufficient for single-user testing.

**Upgrade to TestFlight ($99/year) if:**
- ❌ 7-day expiration becomes annoying
- ❌ Wife travels and can't reconnect to Mac
- ❌ You want crash reports and analytics
- ❌ You plan to add more testers (colleagues, etc.)
- ❌ You're considering App Store release

---

## TestFlight Setup (If You Choose to Pay $99/year)

### Step 1: Join Apple Developer Program

1. Go to https://developer.apple.com/programs/
2. Click "Enroll"
3. Sign in with your Apple ID (use same Apple ID as Xcode)
4. Choose "Individual" (not "Organization")
5. Pay $99 USD
6. Wait 24-48 hours for approval

**What You Need:**
- Apple ID
- Credit card
- Government-issued photo ID (for verification)
- Legal name matching ID

**Timeline:**
- Payment: Immediate
- Approval: 24-48 hours (usually same day)

---

### Step 2: Create App Store Connect Record

1. Go to https://appstoreconnect.apple.com
2. Sign in with Apple Developer account
3. Click "My Apps" → "+" → "New App"
4. Fill in:
   - **Platform:** iOS
   - **Name:** Field Note (or any name, can change later)
   - **Primary Language:** English (US)
   - **Bundle ID:** Create new → `com.yourname.fieldnote`
   - **SKU:** fieldnote-2026 (any unique string)
   - **User Access:** Full Access

5. Click "Create"

**Important:**
- Bundle ID must match Xcode project (Xcode → Signing & Capabilities → Bundle Identifier)
- SKU is internal only (never shown to users)
- App name can be changed later

---

### Step 3: Configure Xcode Project

1. Open project in Xcode
2. Select project in navigator → Select target "fieldnote"
3. **Signing & Capabilities** tab:
   - ✅ Automatically manage signing (checked)
   - Team: Select your Apple Developer team (shows after enrollment)
   - Bundle Identifier: `com.yourname.fieldnote` (must match App Store Connect)

4. **General** tab:
   - Version: `1.0.0`
   - Build: `1`
   - Deployment Target: iOS 16.0+

5. **Info** tab:
   - Check all required permissions are declared:
     - `NSLocationWhenInUseUsageDescription`
     - `NSCameraUsageDescription`
     - `NSMicrophoneUsageDescription`
     - `NSPhotoLibraryUsageDescription`

---

### Step 4: Archive and Upload

1. In Xcode:
   - Product → Destination → **Any iOS Device (arm64)**
   - Product → Archive

2. Wait for archive to complete (1-5 minutes)

3. Organizer window opens:
   - Click **Distribute App**
   - Select **App Store Connect**
   - Click **Upload**
   - Select distribution certificate (auto-created if needed)
   - Click **Upload**

4. Wait for upload (5-15 minutes depending on app size)

5. You'll receive email: "The following build has finished processing"

---

### Step 5: Add Testers in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. My Apps → Field Note → TestFlight
3. Click "Internal Testing" or "External Testing"

**Internal Testing (Recommended for Wife):**
- Up to 100 testers
- Immediate access (no Apple review)
- Testers must have Apple Developer account role
- Best for family/close testers

**External Testing (For Larger Beta):**
- Up to 10,000 testers
- Requires Apple review (24-48 hours per build)
- Testers don't need developer account
- Best for public beta

4. For Internal Testing:
   - Click "+" → Add Internal Testers
   - Enter wife's Apple ID email
   - She'll receive email invite

5. Click on build number → Enable testing for this build

---

### Step 6: Install TestFlight on Wife's iPhone

1. Wife opens App Store on iPhone
2. Search "TestFlight"
3. Install TestFlight app (free, by Apple)
4. Open TestFlight app
5. Sign in with same Apple ID used for invite
6. Field Note app appears → Tap **Install**
7. App installs on Home Screen

**Testing:**
- App expires after 90 days (you'll upload new build)
- Wife can provide feedback via TestFlight app
- Crash reports automatically sent to App Store Connect

---

### Step 7: Upload New Builds (Updates)

When you fix bugs or add features:

1. Xcode → Increment build number (e.g., `1` → `2`)
2. Product → Archive
3. Distribute → Upload to App Store Connect
4. Wife's iPhone auto-updates via TestFlight (or manually checks for updates)

**Important:**
- Keep same version (`1.0.0`) while in beta
- Increment build number each upload (`1`, `2`, `3`, etc.)
- Wife gets notification of new build

---

## Comparison Table

| Feature | Xcode Direct (FREE) | Ad Hoc (FREE) | TestFlight ($99/yr) |
|---------|---------------------|---------------|---------------------|
| Cost | Free | Free | $99/year |
| Max Testers | 3 devices | 100 devices | 10,000 |
| App Expiration | 7 days | 7 days | 90 days |
| OTA Updates | No | No | Yes |
| Crash Reports | Console.app | No | Yes |
| Feedback Mechanism | No | No | Built-in |
| Installation | USB cable | Manual .ipa | TestFlight app |
| Setup Time | 5 minutes | 30 minutes | 1-2 hours |
| Recurring Effort | Reinstall weekly | Reinstall weekly | Upload new build |
| App Store Submission | No | No | Optional (same account) |

---

## Frequently Asked Questions

### Can I use TestFlight without releasing on App Store?
**YES!** You can use TestFlight indefinitely without ever submitting to App Store. Many companies use TestFlight for internal-only apps.

### Can I cancel after 1 year?
**YES!** It's annual subscription, cancel anytime. If you cancel, TestFlight access stops but app remains on testers' devices until it expires.

### Can I add more testers later?
**YES!** Start with wife, add colleagues later (up to 100 internal or 10,000 external).

### What happens if app expires (90 days)?
Upload new build with incremented build number. Testers get update notification.

### Can wife use app offline?
**YES!** TestFlight and app work fully offline. Only initial install and updates require internet.

### Do I need Mac to update app?
**YES!** You need Xcode on Mac to build and upload new versions. Once uploaded, wife gets OTA update.

### Can I test on wife's iPad too?
**YES!** Same TestFlight invite works for all her iOS devices with same Apple ID.

### What if I already have paid developer account?
Great! Skip Step 1, go straight to Step 2.

---

## Recommendations

### For Your Use Case (Wife's iPhone Only)

**Phase 1: Initial Testing (Weeks 1-4)**
- ✅ Use **FREE Xcode Direct Install**
- Install directly via USB
- Reinstall every 7 days
- No cost, immediate feedback

**Phase 2: Extended Testing (Months 1-3)**
- If weekly reinstalls are manageable → **Continue FREE**
- If annoying or wife travels → **Upgrade to TestFlight ($99)**

**Phase 3: Wider Beta (Optional)**
- If wife's colleagues want to try → **TestFlight required**
- Add 5-10 internal testers (colleagues, friends)
- Get diverse feedback from field scientists

**Phase 4: App Store (Future)**
- If app is successful → **Submit to App Store**
- Same Apple Developer account
- TestFlight testers can transition to App Store version

---

## Next Steps

### If Choosing FREE Xcode Install:
1. ✅ Complete remaining v1.0 features
2. ✅ Run device test plan (docs/testing/device-test-plan.md)
3. ✅ Connect wife's iPhone to Mac
4. ✅ Product → Run in Xcode
5. ✅ Set reminder to reinstall every 7 days

### If Choosing TestFlight ($99/year):
1. ✅ Complete remaining v1.0 features
2. ✅ Run device test plan
3. ✅ Enroll in Apple Developer Program
4. ✅ Wait for approval (24-48 hours)
5. ✅ Follow Steps 2-6 above
6. ✅ Wife installs via TestFlight app

---

## Support Resources

- **Apple Developer Program:** https://developer.apple.com/programs/
- **TestFlight Documentation:** https://developer.apple.com/testflight/
- **App Store Connect:** https://appstoreconnect.apple.com
- **Xcode Help:** https://developer.apple.com/documentation/xcode

---

**Last Updated:** 2026-05-13
**Document Owner:** David Contreras
