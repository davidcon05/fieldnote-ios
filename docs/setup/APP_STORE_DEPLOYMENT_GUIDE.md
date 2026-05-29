# App Store Deployment Guide: TestFlight vs. Global Release

**TL;DR:** You need the **$99/year Apple Developer Program** for both TestFlight AND App Store. Once you pay, you get access to free CI/CD tools (Xcode Cloud, GitHub Actions integration).

---

## Quick Comparison: TestFlight vs. App Store

| Feature | TestFlight (Beta) | App Store (Global) |
|---------|-------------------|-------------------|
| **Cost** | $99/year (dev account) | $99/year (same account) |
| **Max Users** | 10,000 | Unlimited |
| **App Review** | Yes (24-48 hrs per build) | Yes (1-3 days first time, faster updates) |
| **Distribution** | Invite-only | Public or unlisted |
| **Updates** | Unlimited builds | Unlimited updates |
| **Build Expiration** | 90 days | Never expires |
| **User Feedback** | Built-in TestFlight app | App Store reviews |
| **Analytics** | Basic (crashes, usage) | Full App Analytics |
| **Monetization** | No (free only) | In-app purchases, subscriptions, paid app |
| **Discoverability** | None (private links) | App Store search, featured, categories |

---

## Apple Developer Account: What You Get for $99/year

### ✅ Included (Free Once You Pay $99)

**Distribution:**
- ✅ TestFlight beta distribution (up to 10,000 testers)
- ✅ App Store global release (unlimited users)
- ✅ App Store Connect access (app management, analytics)
- ✅ Certificate and provisioning profile management

**CI/CD & Automation:**
- ✅ **Xcode Cloud** - 25 compute hours/month FREE (worth ~$15/month)
- ✅ **GitHub Actions integration** - Unlimited (uses GitHub's free tier)
- ✅ **App Store Connect API** - Automate uploads, metadata, screenshots
- ✅ **Crash reports & analytics** - Automatic crash reporting
- ✅ **TestFlight API** - Automate tester management

**Development:**
- ✅ Push notifications (APNs)
- ✅ CloudKit (up to 1 PB storage free tier)
- ✅ MapKit (unlimited map requests)
- ✅ Sign in with Apple
- ✅ Beta access to new iOS/Xcode releases

### ❌ NOT Included (Extra Cost or Third-Party)

- ❌ CI/CD beyond Xcode Cloud free tier (can use GitHub Actions for free)
- ❌ Backend hosting (need Firebase, AWS, etc.)
- ❌ Advanced analytics (can integrate free tools like Firebase)
- ❌ Customer support platform (need Zendesk, etc.)

---

## Deployment Path: TestFlight → App Store

### Option 1: Private Beta (TestFlight Only)
**Use case:** Internal tool, wife + colleagues only, never public

**Workflow:**
1. Pay $99 for Apple Developer account
2. Upload builds to TestFlight (internal or external testing)
3. Invite testers (email or public link)
4. Stay in beta indefinitely (no App Store submission required)
5. Upload new builds every 90 days to avoid expiration

**Pros:**
- ✅ Never need App Review for public release
- ✅ Tester feedback built-in
- ✅ Can keep app private forever
- ✅ Easy to iterate and push updates

**Cons:**
- ❌ 90-day build expiration (must reupload)
- ❌ Max 10,000 testers
- ❌ No App Store discoverability
- ❌ Still need App Review for external testers (not internal team)

---

### Option 2: Public Release (App Store)
**Use case:** Share with world, make it discoverable, build portfolio

**Workflow:**
1. Pay $99 for Apple Developer account
2. Beta test via TestFlight (1-4 weeks)
3. Submit to App Store for review
4. App Review (1-3 days first time)
5. Released globally on App Store
6. Update anytime (faster review for updates)

**Pros:**
- ✅ Global distribution (175+ countries)
- ✅ App Store search & featured placement
- ✅ Portfolio piece (great for resume)
- ✅ No build expiration
- ✅ Unlimited users
- ✅ Can monetize (paid, in-app purchases, ads)

**Cons:**
- ❌ App Review required (must meet guidelines)
- ❌ Public scrutiny (reviews, ratings)
- ❌ Ongoing maintenance expectations
- ❌ Must respond to user support

---

## Free CI/CD Tools with Apple Developer Account

### 1. Xcode Cloud (Apple's Official CI/CD)

**What is it:** Apple's built-in CI/CD service, integrated with Xcode and GitHub

**Free Tier:**
- 25 compute hours/month FREE (includes build + test time)
- After 25 hours: $0.008/minute (~$14.95 for 50 hours)

**What it does:**
- ✅ Automated builds on every Git push
- ✅ Run unit tests automatically
- ✅ Upload to TestFlight automatically
- ✅ Send notifications (email, Slack)
- ✅ Build for multiple iOS versions
- ✅ Archive and code signing (automatic)

**Setup (5 minutes):**
1. Xcode → Product → Xcode Cloud → Create Workflow
2. Connect GitHub repo (authorize once)
3. Choose workflow triggers (push, pull request, tag)
4. Select build scheme (EcoJournal)
5. Enable TestFlight upload (automatic)
6. Done! ✅

**Example Workflow:**
```yaml
# Xcode Cloud workflow (configured in Xcode UI, no YAML)
Trigger: Push to main branch
Actions:
  1. Build app (iOS 17+)
  2. Run unit tests (43 tests)
  3. Archive build
  4. Upload to TestFlight (automatic)
  5. Notify Slack: "Build 123 uploaded to TestFlight"
```

**Cost Estimate:**
- 10 builds/month × 5 min each = 50 minutes
- 50 minutes ÷ 60 = 0.83 hours
- **FREE** (well under 25 hour limit)

**When to use:**
- ✅ Easiest setup (integrated with Xcode)
- ✅ No external YAML configuration
- ✅ Automatic code signing (no manual certs)
- ✅ Official Apple support

---

### 2. GitHub Actions (Free Unlimited)

**What is it:** GitHub's CI/CD service, runs on GitHub's infrastructure

**Free Tier:**
- ✅ **Unlimited minutes** for public repos
- ✅ 2,000 minutes/month for private repos (enough for ~400 builds)
- ✅ After 2,000 minutes: $0.008/minute (same as Xcode Cloud)

**What it does:**
- ✅ Automated builds on every Git push
- ✅ Run tests (unit, UI, integration)
- ✅ Upload to TestFlight via fastlane or App Store Connect API
- ✅ Code quality checks (SwiftLint, formatting)
- ✅ Deploy to App Store (fully automated releases)
- ✅ Create release notes automatically

**Setup (15-30 minutes):**

**Step 1: Create workflow file**
```yaml
# .github/workflows/build-and-test.yml
name: Build and Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-14  # Free macOS runner

    steps:
    - uses: actions/checkout@v4

    - name: Select Xcode version
      run: sudo xcode-select -s /Applications/Xcode_15.2.app

    - name: Build
      run: xcodebuild -scheme EcoJournal -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

    - name: Run tests
      run: xcodebuild -scheme EcoJournal -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test
```

**Step 2: Add TestFlight upload (optional)**
```yaml
# .github/workflows/deploy-testflight.yml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'  # Trigger on version tags (v1.0.0, v1.0.1, etc.)

jobs:
  deploy:
    runs-on: macos-14

    steps:
    - uses: actions/checkout@v4

    - name: Install fastlane
      run: gem install fastlane

    - name: Build and upload to TestFlight
      env:
        APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
      run: |
        fastlane build_and_upload_testflight
```

**When to use:**
- ✅ More control than Xcode Cloud
- ✅ Custom workflows (code linting, SwiftLint, etc.)
- ✅ Multi-platform (if you add Android later)
- ✅ Free for public repos
- ✅ Faster for private repos (2,000 min vs. 25 hours Xcode Cloud)

---

### 3. Fastlane (Free Open Source Tool)

**What is it:** Command-line tool to automate iOS deployment

**Cost:** FREE (open source)

**What it does:**
- ✅ Automate screenshots for App Store
- ✅ Manage certificates and provisioning profiles
- ✅ Upload builds to TestFlight
- ✅ Submit to App Store review
- ✅ Increment build numbers
- ✅ Generate release notes

**Setup:**
```bash
# Install fastlane
sudo gem install fastlane

# Initialize in project
cd /path/to/EcoJournal
fastlane init

# Create lanes (workflows)
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "EcoJournal.xcodeproj")
    build_app(scheme: "EcoJournal")
    upload_to_testflight
  end

  desc "Submit to App Store"
  lane :release do
    increment_version_number
    build_app(scheme: "EcoJournal")
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: true
    )
  end
end
```

**Usage:**
```bash
# Upload to TestFlight
fastlane beta

# Submit to App Store
fastlane release
```

**When to use:**
- ✅ Local automation (no CI/CD setup)
- ✅ Works with Xcode Cloud or GitHub Actions
- ✅ Powerful screenshot automation
- ✅ Industry standard tool

---

## Recommended Setup for Eco Journal

### Phase 1: Manual Deployment (v1.0 Beta)
**Complexity:** Low
**Cost:** $99/year (Apple Developer account only)

**Workflow:**
1. Develop in Xcode
2. Manually archive (Product → Archive)
3. Manually upload to TestFlight
4. Invite wife as tester
5. She tests, gives feedback
6. Repeat

**Time per deployment:** 5-10 minutes
**Good for:** Initial beta testing (1-4 weeks)

---

### Phase 2: Xcode Cloud (v1.0 → v1.5)
**Complexity:** Low-Medium
**Cost:** FREE (25 hours/month included)

**Workflow:**
1. Push code to GitHub
2. Xcode Cloud builds automatically
3. Uploads to TestFlight automatically
4. Wife gets notification of new build
5. She tests, gives feedback
6. Repeat

**Setup time:** 5 minutes (one-time)
**Time per deployment:** 0 minutes (automatic)
**Good for:** Active beta testing (1-6 months)

---

### Phase 3: GitHub Actions + Fastlane (v2.0+)
**Complexity:** Medium-High
**Cost:** FREE (unlimited public repo, 2,000 min/month private)

**Workflow:**
1. Push code to GitHub (main branch or tag)
2. GitHub Actions runs tests automatically
3. If tests pass → Build + upload to TestFlight
4. Create release notes from Git commits
5. Tag version (v1.0.0) → Deploys to App Store
6. Fully automated releases

**Setup time:** 30-60 minutes (one-time)
**Time per deployment:** 0 minutes (automatic)
**Good for:** Production releases, team collaboration

---

## App Store Connect API (Free with Dev Account)

**What is it:** REST API to automate App Store Connect tasks

**What you can automate:**
- ✅ Upload builds (ipa files)
- ✅ Manage app metadata (description, keywords, screenshots)
- ✅ Add/remove testers
- ✅ Submit for review
- ✅ Fetch analytics data
- ✅ Manage pricing and availability

**Example (using App Store Connect API):**
```bash
# Generate API key in App Store Connect
# Store as GitHub secret

# Upload build via API (no Xcode needed)
curl -X POST "https://api.appstoreconnect.apple.com/v1/builds" \
  -H "Authorization: Bearer $API_KEY" \
  -d @build.json
```

**Benefits:**
- ✅ No Mac required for uploads (can use Linux CI)
- ✅ Fully scriptable
- ✅ Integrate with any CI/CD tool

---

## GitHub Integration Setup (Step-by-Step)

### Option A: Xcode Cloud + GitHub (Easiest)

**Prerequisites:**
- ✅ GitHub repo (public or private)
- ✅ Apple Developer account ($99/year)
- ✅ Xcode 15+

**Steps:**
1. **Connect GitHub to Xcode:**
   - Xcode → Preferences → Accounts
   - Add GitHub account (sign in)
   - Authorize Xcode Cloud

2. **Create Xcode Cloud Workflow:**
   - Xcode → Product → Xcode Cloud → Create Workflow
   - Select GitHub repo
   - Choose branch (main)
   - Select actions:
     - ✅ Build
     - ✅ Test
     - ✅ Archive
     - ✅ Upload to TestFlight
   - Click "Start Building"

3. **Done!** Every push to `main` now:
   - Builds app
   - Runs tests
   - Uploads to TestFlight (if tests pass)

**Time:** 5 minutes

---

### Option B: GitHub Actions + Fastlane (More Control)

**Prerequisites:**
- ✅ GitHub repo
- ✅ Apple Developer account
- ✅ App Store Connect API key

**Steps:**

**1. Create App Store Connect API Key:**
   - Go to App Store Connect → Users and Access → Keys
   - Click "+" to create new key
   - Download `.p8` file (save securely, can't redownload)
   - Note: Key ID, Issuer ID

**2. Add secrets to GitHub:**
   - GitHub repo → Settings → Secrets and variables → Actions
   - Add secrets:
     - `APP_STORE_CONNECT_API_KEY` (paste .p8 file contents)
     - `APP_STORE_CONNECT_API_KEY_ID` (Key ID from step 1)
     - `APP_STORE_CONNECT_ISSUER_ID` (Issuer ID from step 1)

**3. Create workflow file:**
```yaml
# .github/workflows/testflight.yml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-14
    steps:
    - uses: actions/checkout@v4

    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.2

    - name: Install Fastlane
      run: gem install fastlane

    - name: Build and Upload
      env:
        APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
        APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
        APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
      run: |
        echo "$APP_STORE_CONNECT_API_KEY_CONTENT" > AuthKey.p8
        fastlane beta
```

**4. Create Fastfile:**
```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  lane :beta do
    api_key = app_store_connect_api_key(
      key_id: ENV['APP_STORE_CONNECT_API_KEY_ID'],
      issuer_id: ENV['APP_STORE_CONNECT_ISSUER_ID'],
      key_content: ENV['APP_STORE_CONNECT_API_KEY_CONTENT']
    )

    increment_build_number(xcodeproj: "EcoJournal.xcodeproj")

    build_app(
      scheme: "EcoJournal",
      export_method: "app-store"
    )

    upload_to_testflight(
      api_key: api_key,
      skip_waiting_for_build_processing: true
    )
  end
end
```

**5. Deploy:**
```bash
# Tag and push
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions automatically:
# 1. Builds app
# 2. Uploads to TestFlight
# 3. Notifies testers
```

**Time:** 30-60 minutes (one-time setup)

---

## Cost Breakdown

### Minimum Cost (TestFlight or App Store)
| Item | Cost | Required? |
|------|------|-----------|
| Apple Developer Program | $99/year | ✅ Yes |
| **Total** | **$99/year** | |

### Optional Costs
| Item | Cost | Required? |
|------|------|-----------|
| Xcode Cloud (beyond 25 hrs/month) | $14.99/month (~50 hrs) | ❌ Optional (free tier enough) |
| GitHub Pro (beyond 2,000 min) | $4/month | ❌ Optional (free tier enough) |
| Backend hosting (Firebase/Supabase) | FREE tier sufficient | ❌ Optional (v2.0 feature) |

**Realistic Total:** $99/year (no extra costs for v1.0)

---

## Recommendation for Eco Journal

### Your Use Case: Wife + Small Group (5-10 testers)

**Phase 1: Manual TestFlight (Weeks 1-4)**
```
Cost: $99/year
Setup: 1 hour (enroll in developer program)
Deploy: 5 minutes per build (manual)
Good for: Initial beta testing
```

**Phase 2: Xcode Cloud (Months 1-6)**
```
Cost: $99/year (FREE tier sufficient)
Setup: 5 minutes (connect GitHub)
Deploy: Automatic on push
Good for: Active development, frequent updates
```

**Phase 3: App Store Release (v1.0 Stable)**
```
Cost: $99/year (same account)
Review time: 1-3 days
Distribution: Global (unlimited users)
Good for: Public release, portfolio piece
```

---

## Decision Tree

### Should I use TestFlight or App Store?

```
Do you want the app to be public?
├─ NO → TestFlight only
│   ├─ < 10 testers → Internal testing (no review)
│   └─ > 10 testers → External testing (review required)
│
└─ YES → App Store
    ├─ Want to monetize? → App Store (in-app purchases)
    ├─ Portfolio piece? → App Store (discoverable)
    ├─ Open source? → App Store + GitHub
    └─ Private tool later public? → TestFlight first, then App Store
```

### Should I use Xcode Cloud or GitHub Actions?

```
Do you want simplicity or control?
├─ Simplicity → Xcode Cloud
│   ✅ 5-minute setup
│   ✅ No YAML configuration
│   ✅ Automatic code signing
│   ❌ Limited customization
│
└─ Control → GitHub Actions
    ✅ Full customization
    ✅ Code linting, SwiftLint
    ✅ Multi-platform (Android later)
    ❌ 30-minute setup
```

---

## Prerequisites: When This Becomes Relevant

**⚠️ YOU ARE BLOCKED UNTIL:**
1. ✅ You complete remaining v1.0 features:
   - Log Editing (EditLogView implementation)
   - Camera Integration (take + upload photos)
   - Audio Recording + Transcription
2. ✅ You have access to physical iPhone (wife's phone)
3. ✅ Device testing passes critical path tests
4. ✅ App works in real field conditions

**THEN** you can deploy via TestFlight or App Store.

**Current Status:** ~80% complete, 3 features remaining before deployment phase

---

## Next Steps

### Phase 1: Complete Development (Simulator)
**Timeline:** 2-4 weeks
**Blocker Status:** ⚠️ Currently blocked without physical device for full testing

1. ☐ **Implement Log Editing** - Reuse NewLogView components, pre-populate data
2. ☐ **Implement Camera Integration** - Take photos + upload from library (collaboration use case)
3. ☐ **Implement Audio Recording + Transcription** - AVAudioRecorder + Speech framework
4. ☐ Test all features in simulator (95% coverage achievable)

### Phase 2: Physical Device Testing
**Timeline:** 1-2 weeks
**Blocker Status:** ⚠️ Requires physical iPhone (wife's phone)

1. ☐ Borrow wife's iPhone for testing
2. ☐ Install via Xcode direct install (FREE, no dev account needed yet)
3. ☐ Run device test plan (docs/testing/device-test-plan.md)
4. ☐ Test critical path: GPS, camera, audio, battery, outdoor conditions
5. ☐ Fix any device-specific issues
6. ☐ Validate app works in real field conditions

### Phase 3: TestFlight Deployment (Optional)
**Timeline:** 1 day setup, then ongoing
**Cost:** $99/year Apple Developer Program

1. ☐ Enroll in Apple Developer Program ($99)
2. ☐ Wait 24-48 hours for approval
3. ☐ Create App Store Connect record
4. ☐ Archive and upload first build
5. ☐ Invite wife as internal tester (no review needed)
6. ☐ She installs via TestFlight app
7. ☐ (Optional) Setup Xcode Cloud for automation (5 min)

### Phase 4: App Store Deployment (Optional)
**Timeline:** 1-3 days review, then live
**Cost:** Same $99/year (no extra charge)

1. ☐ Complete TestFlight testing (1-4 weeks)
2. ☐ Gather wife's feedback and iterate
3. ☐ Polish UI based on real device testing
4. ☐ Create App Store screenshots (fastlane snapshot)
5. ☐ Write app description and keywords
6. ☐ Submit for App Review
7. ☐ Wait 1-3 days for approval
8. ☐ Release globally! 🎉

---

## Deployment Decision Based on Current Status

**Right Now (No Physical Device):**
```
✅ CAN DO: Finish simulator development
✅ CAN DO: Implement remaining features (editing, camera, audio)
✅ CAN DO: Write tests, refactor code
❌ CANNOT DO: Device testing (blocked)
❌ CANNOT DO: TestFlight deployment (no point until device tested)
❌ CANNOT DO: App Store submission (premature)
```

**Recommendation:** Focus on completing v1.0 features in simulator, then borrow wife's phone for device testing before considering Apple Developer enrollment.

---

**Last Updated:** 2026-05-13
**Document Owner:** David Contreras
