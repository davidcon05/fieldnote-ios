# Xcode Cloud + TestFlight Setup Guide

Complete guide to setting up automated TestFlight deployments using Xcode Cloud (Apple's official CI/CD).

**Why Xcode Cloud?**
- ✅ Easiest setup (5 minutes, all in Xcode)
- ✅ No manual certificate/provisioning profile management
- ✅ 25 compute hours/month FREE (enough for ~100 builds)
- ✅ Official Apple support
- ✅ Automatic TestFlight uploads
- ✅ No YAML configuration needed

---

## Prerequisites

- ✅ Apple Developer Account ($99/year) - **REQUIRED**
- ✅ Xcode 15+ installed
- ✅ GitHub repository connected to Xcode
- ✅ App created in App Store Connect

---

## Step 1: Enroll in Apple Developer Program

If you haven't already:

1. Go to https://developer.apple.com/programs/enroll/
2. Click **Enroll**
3. Sign in with your Apple ID
4. Choose **Individual** account
5. Pay $99 USD
6. Wait 24-48 hours for approval

**You'll receive email when approved.**

---

## Step 2: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **"+"** → **New App**
3. Fill in:
   - **Platform:** iOS
   - **Name:** Eco Journal
   - **Primary Language:** English (US)
   - **Bundle ID:** Create new → `com.davidcontreras.ecojournal`
   - **SKU:** `ecojournal-2026`
   - **User Access:** Full Access

4. Click **Create**

**Important:** Bundle ID must match your Xcode project exactly.

---

## Step 3: Configure Xcode Project Signing

1. Open `EcoJournal.xcodeproj` in Xcode
2. Select **EcoJournal** project in navigator
3. Select **EcoJournal** target
4. Go to **Signing & Capabilities** tab
5. Configure:
   - ✅ Check **Automatically manage signing**
   - **Team:** Select your Apple Developer team (appears after enrollment)
   - **Bundle Identifier:** `com.davidcontreras.ecojournal`

6. Repeat for test targets:
   - Select **EcoJournalTests** target → Same settings
   - Select **EcoJournalUITests** target → Same settings

**Xcode will automatically:**
- Create distribution certificates
- Generate provisioning profiles
- Handle code signing

---

## Step 4: Connect GitHub to Xcode

1. In Xcode, go to **Settings** → **Accounts** tab
2. Click **"+"** (bottom left) → **GitHub**
3. Sign in to GitHub
4. Authorize Xcode to access your repositories

**Verify:**
- Xcode → **Source Control** → **Repositories**
- You should see `ecojournal-ios` listed

---

## Step 5: Create Xcode Cloud Workflow

1. In Xcode, select **Product** menu → **Xcode Cloud** → **Create Workflow...**

2. **Select Repository:**
   - Choose `ecojournal-ios` from list
   - Click **Next**

3. **Select Product:**
   - Choose **EcoJournal** scheme
   - Click **Next**

4. **Edit Workflow:**
   - **Workflow Name:** "TestFlight Beta Deployment"
   - Click **Next**

5. **Configure Start Conditions:**
   - **Branch Changes:**
     - Click **"+"** → **Branch Changes**
     - **Branch:** `main`
     - **Files and Folders:** Leave empty (trigger on all changes)
   - **Tag Changes:**
     - Click **"+"** → **Tag Changes**
     - **Tag Pattern:** `v*` (triggers on v1.0.0, v1.0.1, etc.)

6. **Configure Actions:**

   **Default actions include:**
   - ✅ **Analyze** (Swift linting, warnings)
   - ✅ **Test** (run unit tests automatically)
   - ✅ **Archive** (create .ipa for distribution)

   **To add TestFlight:**
   - Click **"+"** → **Archive - iOS**
   - **Platform:** iOS
   - **Deployment Preparation:** **TestFlight (Internal Testing)**
   - Click **Add Action**

7. **Environment:**
   - **Xcode Version:** Latest Release (recommended)
   - **macOS Version:** Latest (automatic)

8. **Post-Actions:**
   - Click **"+"** → **Notify**
   - Choose notification preferences:
     - ✅ Email (on success and failure)
     - ✅ Slack (optional, connect later)

9. Click **Create** to save workflow

---

## Step 6: Verify Workflow Configuration

Xcode creates a workflow file in your repository:

**Location:** `.xcode-cloud/workflows/testflight-beta-deployment.yml`

**What it does:**
1. Watches for:
   - Pushes to `main` branch
   - New version tags (v*)
2. When triggered:
   - Analyzes code quality
   - Runs unit tests (EcoJournalTests)
   - Archives app (creates .ipa)
   - Uploads to TestFlight automatically
   - Sends notifications

---

## Step 7: Enable Xcode Cloud (First Time)

1. Push a commit to `main` or create a tag
2. Xcode Cloud will ask for permissions:
   - **Grant access to App Store Connect:** Click **Grant**
   - **Authorize GitHub access:** Click **Authorize**
3. Workflow starts automatically!

**Free Tier:**
- 25 compute hours/month FREE
- Each build uses ~15 minutes
- ~100 builds/month FREE

---

## Usage: Deploy to TestFlight

### Option A: Push to Main (Continuous Deployment)

Every push to `main` automatically builds and uploads to TestFlight:

```bash
git add .
git commit -m "Fix bug in log editing"
git push origin main
```

**Result:**
- Xcode Cloud builds automatically
- If tests pass → Uploads to TestFlight
- If tests fail → No upload, sends notification

---

### Option B: Version Tags (Recommended for Releases)

Create version tags for controlled releases:

```bash
# Beta releases
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1

# Release candidates
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1

# Final releases
git tag v1.0.0
git push origin v1.0.0
```

**Result:**
- Xcode Cloud detects tag
- Builds and uploads to TestFlight
- Build number auto-incremented
- Testers notified automatically

---

## Step 8: Add TestFlight Testers

1. Go to https://appstoreconnect.apple.com
2. **My Apps** → **EcoJournal** → **TestFlight**

**Internal Testing (Recommended):**
- Click **Internal Testing** → **"+"** → **Add Internal Testers**
- Enter email: `wife@example.com`
- Select build
- Click **Add**

**Testers receive:**
- Email invitation
- Instructions to install TestFlight app
- Direct link to install EcoJournal

---

## Step 9: Tester Installation

Your wife (or other testers):

1. Install **TestFlight** app from App Store (free)
2. Open invitation email
3. Click **"View in TestFlight"**
4. TestFlight app opens → Click **Install**
5. App appears on Home Screen

**Updates:**
- TestFlight auto-notifies when new builds available
- Testers can update with one tap
- Builds expire after 90 days (upload new build)

---

## Monitor Builds

**In Xcode:**
1. **Product** → **Xcode Cloud** → **Manage Workflows**
2. See build history, logs, test results

**In App Store Connect:**
1. https://appstoreconnect.apple.com
2. **My Apps** → **EcoJournal** → **TestFlight**
3. See all builds, tester feedback, crash reports

**Notifications:**
- Email on build success/failure
- Slack (if configured)
- GitHub status checks (automatic)

---

## Troubleshooting

### "Xcode Cloud is not available for your account"
- Ensure Apple Developer enrollment is approved
- Wait 24-48 hours after enrollment
- Sign out and back in to Xcode (Settings → Accounts)

### Build fails with signing error
- Go to Xcode → Settings → Accounts → Manage Certificates
- Delete old certificates
- Xcode Cloud will regenerate automatically

### Tests fail in cloud but pass locally
- Check Xcode Cloud logs for specific failures
- May need to update test environment variables
- Ensure tests don't depend on local files

### Build doesn't appear in TestFlight
- Check App Store Connect → Activity tab
- Wait 10-15 minutes for Apple processing
- Check email for "processing failed" messages

---

## Cost Breakdown

| Item | Cost | Included |
|------|------|----------|
| **Apple Developer Program** | $99/year | ✅ Required |
| **Xcode Cloud** | FREE | ✅ 25 hours/month |
| **TestFlight** | FREE | ✅ Unlimited |
| **GitHub (private repo)** | FREE | ✅ Unlimited repos |
| **Total** | **$99/year** | |

**If you exceed 25 hours/month:**
- Additional hours: ~$15/month for 50 hours
- Unlikely unless you're building constantly

---

## Comparison: Xcode Cloud vs GitHub Actions

| Feature | Xcode Cloud | GitHub Actions |
|---------|-------------|----------------|
| **Setup Time** | 5 minutes | 30-60 minutes |
| **Configuration** | GUI in Xcode | YAML files |
| **Certificate Management** | Automatic | Manual |
| **Free Tier** | 25 hours/month | 2,000 minutes/month |
| **macOS Version** | Always latest | Fixed versions |
| **Customization** | Limited | Full control |
| **Best For** | Simplicity | Advanced workflows |

**Recommendation:** Start with Xcode Cloud. Migrate to GitHub Actions later if you need custom workflows.

---

## Advanced: Customize Workflow

After initial setup, you can customize:

1. Xcode → **Product** → **Xcode Cloud** → **Manage Workflows**
2. Select workflow → **Edit**
3. Add custom actions:
   - **Run Script:** Custom build steps
   - **Analyze:** SwiftLint, code formatting
   - **Test:** UI tests, performance tests
   - **Archive:** Multiple platforms (iOS, macOS)

**Example custom script:**
```bash
# ci_scripts/ci_post_clone.sh
#!/bin/bash

# Install dependencies
brew install swiftlint

# Run linting
swiftlint --strict
```

---

## Next Steps

**Today:**
1. ✅ Enroll in Apple Developer Program (if not already)
2. ✅ Create app in App Store Connect
3. ✅ Configure Xcode project signing

**After Enrollment Approval (24-48 hours):**
1. ✅ Create Xcode Cloud workflow (Step 5)
2. ✅ Push commit or tag to trigger build
3. ✅ Add testers in App Store Connect
4. ✅ Testers install via TestFlight

**Ongoing:**
1. ✅ Push to `main` for automatic deployments
2. ✅ Create version tags for releases
3. ✅ Monitor builds in Xcode Cloud
4. ✅ Review tester feedback in App Store Connect

---

## Support Resources

- **Xcode Cloud Documentation:** https://developer.apple.com/documentation/xcode/xcode-cloud
- **TestFlight Guide:** https://developer.apple.com/testflight/
- **App Store Connect:** https://appstoreconnect.apple.com
- **Apple Developer Support:** https://developer.apple.com/support/

---

**Last Updated:** 2026-05-29
**Document Owner:** David Contreras
