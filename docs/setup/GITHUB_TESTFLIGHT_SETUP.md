# GitHub Actions TestFlight Setup Guide

Complete guide to setting up automated TestFlight deployments via GitHub Actions for EcoJournal.

---

## Prerequisites

- ✅ Apple Developer Account ($99/year) - **MUST BE ACTIVE**
- ✅ App created in App Store Connect
- ✅ GitHub repository with push access

---

## Step 1: Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **Users and Access** → **Keys** tab
3. Click **"+"** to create new API Key
4. Fill in:
   - **Name:** "GitHub Actions CI/CD"
   - **Access:** **App Manager** (allows uploading builds)
5. Click **Generate**
6. **IMPORTANT:** Download the `.p8` file immediately (you can't download it again!)
7. Note the following values (you'll need them):
   - **Key ID** (e.g., `AB12CD34EF`)
   - **Issuer ID** (UUID at top of page, e.g., `12345678-1234-1234-1234-123456789012`)

**Save these securely:**
- `.p8` file (this is your private key)
- Key ID
- Issuer ID

---

## Step 2: Create Distribution Certificate and Provisioning Profile

### Option A: Use Xcode (Easiest)

1. Open Xcode → **Settings** → **Accounts**
2. Select your Apple ID → **Manage Certificates**
3. Click **"+"** → **Apple Distribution**
4. Certificate created automatically
5. Export certificate:
   - Right-click certificate → **Export "Apple Distribution..."**
   - Save as `.p12` file
   - Set a password (remember it!)
   - Save `.p12` file securely

6. Create Provisioning Profile:
   - Xcode → Select **EcoJournal** target
   - **Signing & Capabilities** tab
   - Make sure **Automatically manage signing** is **checked**
   - Select **Team**
   - Build once (Cmd+B) to generate profile
   - Profile is at: `~/Library/MobileDevice/Provisioning Profiles/*.mobileprovision`
   - Find the right one: `grep -l "EcoJournal" ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision`

### Option B: Use Apple Developer Portal (Manual)

1. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click **"+"** → **iOS Distribution**
3. Upload CSR (create via Keychain Access if needed)
4. Download certificate → Double-click to install

5. Go to [Provisioning Profiles](https://developer.apple.com/account/resources/profiles/list)
6. Click **"+"** → **App Store**
7. Select your App ID: `com.davidcontreras.ecojournal`
8. Select the certificate you just created
9. Download `.mobileprovision` file

---

## Step 3: Prepare Secrets for GitHub

You need to convert files to base64 for GitHub Secrets:

```bash
# Navigate to where you saved the files
cd ~/Desktop  # or wherever you saved them

# 1. Convert certificate to base64
base64 -i YourCertificate.p12 | pbcopy
# Now paste into GitHub secret: BUILD_CERTIFICATE_BASE64

# 2. Convert provisioning profile to base64
base64 -i YourProfile.mobileprovision | pbcopy
# Now paste into GitHub secret: BUILD_PROVISION_PROFILE_BASE64

# 3. Convert API key to base64
base64 -i AuthKey_AB12CD34EF.p8 | pbcopy
# Now paste into GitHub secret: APP_STORE_CONNECT_API_KEY
```

---

## Step 4: Create ExportOptions.plist

Create a file called `ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.davidcontreras.ecojournal</key>
        <string>YOUR_PROVISIONING_PROFILE_NAME</string>
    </dict>
</dict>
</plist>
```

**Replace:**
- `YOUR_TEAM_ID`: Found in Apple Developer → Membership → Team ID (e.g., `9BUF9JB2Q7`)
- `YOUR_PROVISIONING_PROFILE_NAME`: Name of your provisioning profile (e.g., "EcoJournal Distribution")

**Convert to base64:**
```bash
base64 -i ExportOptions.plist | pbcopy
# Paste into GitHub secret: EXPORT_OPTIONS_PLIST
```

---

## Step 5: Add Secrets to GitHub Repository

1. Go to your GitHub repository: https://github.com/davidcon05/ecojournal-ios
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each:

| Secret Name | Value | How to Get |
|------------|-------|------------|
| `BUILD_CERTIFICATE_BASE64` | Base64 of `.p12` file | Step 3, command 1 |
| `P12_PASSWORD` | Password you set for `.p12` | The password you chose when exporting |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 of `.mobileprovision` | Step 3, command 2 |
| `KEYCHAIN_PASSWORD` | Any strong password | Make one up (e.g., `MyK3ych@in2026!`) |
| `APP_STORE_CONNECT_API_KEY` | Base64 of `.p8` file | Step 3, command 3 |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from Step 1 | e.g., `AB12CD34EF` |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from Step 1 | UUID from App Store Connect |
| `EXPORT_OPTIONS_PLIST` | Base64 of ExportOptions.plist | Step 4 |

---

## Step 6: Test the Workflow

1. Make sure all secrets are added
2. Create a version tag:

```bash
cd /Users/davidcontreras/AppleXCodeProjects/ecojournal-ios

# Commit any pending changes first
git add .
git commit -m "Prepare for TestFlight deployment"

# Create and push a beta tag
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1
```

3. Watch the GitHub Actions run:
   - Go to https://github.com/davidcon05/ecojournal-ios/actions
   - Click on the "Deploy to TestFlight" workflow
   - Monitor progress

4. If successful, check App Store Connect:
   - Go to https://appstoreconnect.apple.com
   - **My Apps** → **EcoJournal** → **TestFlight**
   - Your build should appear within 5-10 minutes

---

## Step 7: Add Testers

1. In App Store Connect → **TestFlight** → **Internal Testing**
2. Click **"+"** → **Add Internal Testers**
3. Enter tester email addresses (your wife's email)
4. Select the build to test
5. Testers receive email invitation
6. They install TestFlight app from App Store
7. Open TestFlight → Accept invitation → Install app

---

## Troubleshooting

### Build fails with "Code signing error"
- Check that `BUILD_CERTIFICATE_BASE64` and `BUILD_PROVISION_PROFILE_BASE64` are correct
- Verify `P12_PASSWORD` matches the password you set
- Make sure provisioning profile matches bundle ID: `com.davidcontreras.ecojournal`

### Upload fails with "Invalid API Key"
- Check `APP_STORE_CONNECT_API_KEY_ID` matches the Key ID from Step 1
- Verify `APP_STORE_CONNECT_ISSUER_ID` is the UUID from App Store Connect
- Ensure `.p8` file was converted correctly to base64

### "No such provisioning profile"
- Update `ExportOptions.plist` with correct Team ID and profile name
- Re-convert to base64 and update GitHub secret

### Build succeeds but doesn't appear in TestFlight
- Check email for "build processing" notification
- Wait 10-15 minutes (Apple processes builds)
- Check App Store Connect → **Activity** tab for errors

---

## Usage After Setup

Once configured, deploying is easy:

```bash
# For beta builds
git tag v1.0.0-beta.2
git push origin v1.0.0-beta.2

# For release candidates
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1

# For final releases
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically:
1. Build the app
2. Sign with your certificate
3. Upload to TestFlight
4. Notify testers

---

## Cost Breakdown

| Item | Cost | Frequency |
|------|------|-----------|
| Apple Developer Program | $99 | Annual |
| GitHub Actions (private repo) | Free | 2,000 min/month |
| TestFlight Distribution | Free | Included with dev account |
| **Total** | **$99/year** | |

**GitHub Actions Usage Estimate:**
- Each TestFlight build: ~15 minutes
- 10 builds/month: 150 minutes (well under 2,000 free minutes)

---

## Alternative: Xcode Cloud

If you prefer Apple's official CI/CD:

1. Xcode → **Product** → **Xcode Cloud** → **Create Workflow**
2. Connect GitHub repository
3. Select triggers (push to main, tags)
4. Enable TestFlight upload
5. Done!

**Benefits:**
- ✅ Easier setup (no manual certificates)
- ✅ 25 compute hours/month FREE
- ✅ Integrated with Xcode

**Drawbacks:**
- ❌ Less customization than GitHub Actions
- ❌ Locked into Apple's platform

---

## Next Steps

1. ✅ Complete Apple Developer enrollment
2. ✅ Follow Steps 1-6 to configure GitHub Actions
3. ✅ Push first beta tag
4. ✅ Invite testers
5. ✅ Start beta testing!

---

**Last Updated:** 2026-05-29
**Document Owner:** David Contreras
