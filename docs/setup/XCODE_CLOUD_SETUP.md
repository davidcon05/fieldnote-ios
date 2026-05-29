# Xcode Cloud Setup Guide

This guide walks you through setting up Xcode Cloud for automated TestFlight distribution of EcoJournal.

## Prerequisites

- ✅ Apple Developer Program membership (approved)
- ✅ App created in App Store Connect
- ✅ GitHub repository connected

## Step 1: Enable Xcode Cloud in Xcode

1. Open `EcoJournal.xcodeproj` in Xcode
2. Go to **Product → Xcode Cloud → Create Workflow**
3. Select your GitHub repository: `davidcon05/ecojournal-ios`
4. Choose **"Archive - iOS"** workflow type
5. Click **Next**

## Step 2: Configure Workflow

### Basic Settings:
- **Name**: TestFlight Distribution
- **Description**: Build and distribute to TestFlight on push to main
- **Branch**: `main`
- **Trigger**: On every push

### Build Configuration:
- **Platform**: iOS
- **Scheme**: EcoJournal
- **Build Configuration**: Release
- **Xcode Version**: Latest Release

### Post-Actions:
- ✅ **Enable "Distribute to TestFlight"**
- ✅ **Enable "Auto-submit for Review"** (optional but recommended)

## Step 3: Configure Environment Variables (CRITICAL)

Xcode Cloud needs the Weather API key to build successfully.

1. In Xcode Cloud workflow settings, go to **Environment** tab
2. Click **+ Add Environment Variable**
3. Configure:
   - **Name**: `WEATHER_API_KEY`
   - **Value**: `b2953cc5ac87031e76a9ce55badaa685` (your OpenWeather API key)
   - **Secret**: ✅ **Mark as Secret** (encrypts value, hides in logs)

Alternatively, set it in App Store Connect:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Xcode Cloud → Settings**
3. Select **Environment Variables**
4. Click **+** to add:
   - Variable Name: `WEATHER_API_KEY`
   - Value: Your API key
   - ✅ Mark as Secret

## Step 4: Grant GitHub Access

When prompted:

1. Authorize Xcode Cloud to access your GitHub account
2. Grant access to the `ecojournal-ios` repository
3. Xcode Cloud will create a webhook for automatic builds

## Step 5: First Build

### Option A: Trigger via Push
```bash
git add .
git commit -m "Enable Xcode Cloud workflows"
git push origin main
```

Xcode Cloud will automatically:
1. Clone your repo
2. Build the app
3. Archive the release
4. Upload to TestFlight
5. Email you when complete (~15-30 mins)

### Option B: Manual Trigger
1. In Xcode: **Product → Xcode Cloud → Start Build**
2. Select **TestFlight Distribution** workflow
3. Click **Start Build**

## Step 6: Monitor Build Progress

### In Xcode:
- **Report Navigator** (Cmd+9) → **Cloud** tab
- View real-time logs, build status, and errors

### In App Store Connect:
- Go to **App → Xcode Cloud → Builds**
- View detailed logs and build artifacts

## Step 7: Access TestFlight Build

Once the build completes:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select **EcoJournal** → **TestFlight** tab
3. Your build will appear under **iOS Builds**
4. Wait for "Processing" to complete (~15 mins)
5. Add testers under **Internal Testing** or **External Testing**

## How It Works

### Local Development:
- API key read from `Config.xcconfig` (gitignored)
- `Info.plist` contains `$(WEATHER_API_KEY)` placeholder
- Xcode substitutes value from `Config.xcconfig`

### Xcode Cloud Build:
- `Config.xcconfig` doesn't exist (gitignored)
- `Info.plist` contains `$(WEATHER_API_KEY)` placeholder
- Xcode Cloud substitutes value from environment variable
- Secret never appears in git or build logs

## Troubleshooting

### Build Fails: "Weather API key missing"
- Check environment variable is set in Xcode Cloud settings
- Verify variable name is exactly `WEATHER_API_KEY`
- Ensure it's marked as **Secret**

### Build Succeeds but App Crashes
- API key might be empty or invalid
- Check App Store Connect → TestFlight → Crash logs

### Changes Not Triggering Build
- Verify webhook is active in GitHub repo settings
- Check Xcode Cloud → Workflow → Triggers
- Ensure you're pushing to `main` branch

### Provisioning Profile Errors
- Xcode Cloud auto-generates profiles
- Wait a few minutes and retry
- Check certificate validity in Apple Developer portal

## Free Tier Limits

Apple provides **25 compute hours/month FREE** for Xcode Cloud:
- Typical build: 10-15 minutes
- Estimate: ~100-150 builds/month free

Monitor usage: App Store Connect → Xcode Cloud → Usage

## Next Steps

- ✅ Set up internal testers in TestFlight
- ✅ Configure external beta testing (requires app review)
- ✅ Add more workflows (PR validation, nightly builds, etc.)
- ✅ Integrate with Slack/email notifications

## Resources

- [Xcode Cloud Documentation](https://developer.apple.com/xcode-cloud/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Managing Environment Variables](https://developer.apple.com/documentation/xcode/environment-variable-reference)
