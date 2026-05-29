# Renaming iOS App: "EcoJournal" → "Eco Journal"

**Date:** May 26, 2026
**Estimated Time:** 2-4 hours (depending on thoroughness)
**Difficulty:** Medium (mostly manual find/replace + Xcode configuration)
**Risk Level:** Low-Medium (can break build if not careful)

---

## 🎯 What Needs to Change

### 1. **Display Name** (What Users See)
- App name on home screen: "Eco Journal"
- App Store listing: "Eco Journal"
- Settings app: "Eco Journal"

### 2. **Technical Names** (Internal References)
- Xcode project name: `EcoJournal.xcodeproj` → `EcoJournal.xcodeproj` (OPTIONAL)
- Xcode scheme name: `EcoJournal` → `EcoJournal`
- Bundle identifier: `com.davidcontreras.EcoJournal` → `com.davidcontreras.ecojournal`
- Target name: `EcoJournal` → `EcoJournal`
- Test target names: `EcoJournalTests`, `EcoJournalUITests`

### 3. **Code References**
- String literals mentioning "EcoJournal" or "EcoJournal"
- Comments referencing the old name
- File headers (copyright notices)
- Documentation

---

## ⚠️ CRITICAL DECISIONS FIRST

### Decision 1: Keep or Rename the Xcode Project File?

**Option A: Keep `EcoJournal.xcodeproj` (RECOMMENDED)**
- **Pros:**
  - ✅ Least risky (no file system changes)
  - ✅ Faster (30 minutes vs 2-3 hours)
  - ✅ Git history stays clean
  - ✅ No build breakage risk
- **Cons:**
  - ❌ Internal project file name doesn't match display name (cosmetic only)

**Option B: Rename to `EcoJournal.xcodeproj` (THOROUGH)**
- **Pros:**
  - ✅ Everything matches (consistency)
  - ✅ Professional appearance
- **Cons:**
  - ❌ Risky (can break Xcode project structure)
  - ❌ Time-consuming (2-3 hours)
  - ❌ Git history gets messy (file renames)
  - ❌ Must update CI/CD configs, fastlane, scripts

**Recommendation:** **Option A** - Keep `EcoJournal.xcodeproj`, just change display name and bundle ID.

---

### Decision 2: Bundle Identifier Change

**Current:** `com.davidcontreras.EcoJournal`
**New Options:**
- `com.davidcontreras.ecojournal` (lowercase, no spaces)
- `com.davidcontreras.eco-journal` (with hyphen)

**CRITICAL:** Once you register this with Apple Developer and publish to App Store, **you cannot change it later** without creating a new app.

**Recommendation:** `com.davidcontreras.ecojournal` (no hyphen, cleaner)

---

## 📋 Step-by-Step Guide (Recommended Approach)

### Phase 1: Display Name Only (30 minutes - SAFEST)

**What Changes:**
- ✅ App name on home screen: "Eco Journal"
- ✅ App Store listing: "Eco Journal"
- ❌ Xcode project file: Still `EcoJournal.xcodeproj` (internal only)
- ❌ Bundle ID: Still `com.davidcontreras.EcoJournal` (can change later)

**Steps:**

#### Step 1: Update Display Name (5 minutes)
```bash
# Open Xcode
open /Users/davidcontreras/AppleXCodeProjects/EcoJournal/EcoJournal.xcodeproj

# In Xcode:
# 1. Select project "EcoJournal" in navigator (top-left)
# 2. Select target "EcoJournal" in main pane
# 3. General tab → Identity section
# 4. Change "Display Name" from "EcoJournal" to "Eco Journal"
```

**Result:** App will now show "Eco Journal" on home screen.

#### Step 2: Verify Info.plist (5 minutes)
```bash
# Open Info.plist
# Verify or add:
<key>CFBundleDisplayName</key>
<string>Eco Journal</string>
```

#### Step 3: Test Build (5 minutes)
```bash
# Clean build folder
Product → Clean Build Folder (Shift+Cmd+K)

# Build and run
Product → Run (Cmd+R)

# Verify:
# - App builds successfully
# - Home screen shows "Eco Journal"
# - App launches without errors
```

**Done!** If you only care about user-facing name, stop here.

---

### Phase 2: Bundle Identifier Change (OPTIONAL - 1 hour)

**Only do this if:**
- You want a clean start with App Store Connect
- You haven't published to App Store yet (no users to migrate)
- You want `com.davidcontreras.ecojournal` permanently

**Steps:**

#### Step 1: Change Bundle Identifier in Xcode (10 minutes)
```bash
# In Xcode:
# 1. Select project "EcoJournal" → target "EcoJournal"
# 2. General tab → Identity section
# 3. Change "Bundle Identifier" from:
#    com.davidcontreras.EcoJournal
#    to:
#    com.davidcontreras.ecojournal
```

#### Step 2: Update All Targets (10 minutes)
Change bundle IDs for ALL targets:
- **Main app:** `com.davidcontreras.ecojournal`
- **Unit tests:** `com.davidcontreras.ecojournalTests`
- **UI tests:** `com.davidcontreras.ecojournalUITests`

#### Step 3: Update Signing & Capabilities (15 minutes)
```bash
# In Xcode:
# 1. Select target → Signing & Capabilities tab
# 2. Team: Select your Apple Developer account
# 3. Signing: ✅ Automatically manage signing
# 4. Xcode will generate new provisioning profile
```

**If you see errors:**
- "No profiles for bundle ID" → Click "Download Manual Profiles"
- "Identifier already registered" → Use App Store Connect to delete old ID (if unused)

#### Step 4: Update App Store Connect (10 minutes)
```bash
# If you already created app in App Store Connect:
# 1. Go to https://appstoreconnect.apple.com
# 2. Delete old app entry (if not published yet)
# 3. Create new app with bundle ID: com.davidcontreras.ecojournal

# If you haven't created app yet:
# - Just use new bundle ID when you create it
```

#### Step 5: Test Clean Build (10 minutes)
```bash
# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean build folder in Xcode
Product → Clean Build Folder (Shift+Cmd+K)

# Build and run
Product → Run (Cmd+R)

# Verify:
# - App builds successfully
# - No signing errors
# - App installs on simulator/device
```

---

### Phase 3: Full Rename (THOROUGH - 2-3 hours)

**Only do this if:**
- You're a perfectionist
- You want everything to match
- You have 2-3 hours to spare
- You're comfortable with git file renames

**What Changes:**
- ✅ Xcode project file: `EcoJournal.xcodeproj`
- ✅ Xcode schemes: `EcoJournal`, `EcoJournalTests`, `EcoJournalUITests`
- ✅ Target names: `EcoJournal`
- ✅ Folder structure: `EcoJournal/` → `EcoJournal/`
- ✅ All code references: `EcoJournal` → `EcoJournal`

**I'll provide detailed steps if you choose this path** (not recommended unless necessary).

---

## 🔍 Find All References to "EcoJournal"

### Search Codebase (10 minutes)
```bash
cd /Users/davidcontreras/AppleXCodeProjects/EcoJournal

# Find all files containing "EcoJournal" (case-insensitive)
grep -ri "EcoJournal" . --exclude-dir=.git --exclude-dir=DerivedData

# Find specific patterns:
grep -r "EcoJournal" *.swift
grep -r "EcoJournal" *.swift
```

### Common Places to Update:
- [ ] `Info.plist` - Display name, bundle ID
- [ ] File headers (copyright notices) - Low priority
- [ ] Comments - Low priority
- [ ] String literals - Only if user-facing
- [ ] SwiftData model names - **DON'T CHANGE** (will break existing data)
- [ ] Keychain keys - **DON'T CHANGE** (will break password storage)

---

## ⚠️ What NOT to Change

### 1. **SwiftData Model Names**
```swift
// DON'T change these:
@Model class Journal { }
@Model class Log { }
@Model class Weather { }
@Model class AudioMemo { }

// Reason: Changing model names breaks existing user data (data loss!)
```

### 2. **Keychain Service Names**
```swift
// DON'T change:
let service = "com.EcoJournal.password"

// Reason: Existing users will lose saved passwords
```

### 3. **UserDefaults Keys**
```swift
// DON'T change:
UserDefaults.standard.set(value, forKey: "EcoJournal_firstLaunch")

// Reason: Breaks existing user preferences
```

### 4. **Git Repository Name**
```bash
# Git remote URL stays the same:
# https://github.com/davidcon05/EcoJournal

# Reason: Changing GitHub repo name is optional (can do later)
```

---

## 📝 Checklist for Safe Rename

### Before Starting
- [ ] Commit all current changes to git
- [ ] Create backup: `zip -r EcoJournal_backup.zip EcoJournal/`
- [ ] Note current bundle ID: `com.davidcontreras.EcoJournal`
- [ ] Close Xcode completely

### Minimal Rename (30 minutes - Recommended)
- [ ] Open Xcode
- [ ] Change Display Name to "Eco Journal"
- [ ] Verify Info.plist has `CFBundleDisplayName`
- [ ] Clean build folder
- [ ] Build and run → Verify app shows "Eco Journal"
- [ ] Commit changes: `git commit -m "Rename app display name to Eco Journal"`

### Medium Rename (1 hour - Optional)
- [ ] Change bundle ID to `com.davidcontreras.ecojournal`
- [ ] Update all targets (app, tests, UI tests)
- [ ] Regenerate provisioning profiles
- [ ] Update App Store Connect (if applicable)
- [ ] Clean build, test thoroughly
- [ ] Commit changes: `git commit -m "Change bundle ID to com.davidcontreras.ecojournal"`

### Full Rename (2-3 hours - Perfectionist Only)
- [ ] Rename Xcode project file
- [ ] Rename schemes
- [ ] Rename targets
- [ ] Update folder structure
- [ ] Find/replace all code references
- [ ] Update documentation
- [ ] Test EVERYTHING
- [ ] Commit changes: `git commit -m "Full app rename to Eco Journal"`

---

## 🐛 Common Issues & Fixes

### Issue 1: "No provisioning profile matches bundle ID"
**Fix:**
```bash
# In Xcode:
# 1. Signing & Capabilities tab
# 2. Uncheck "Automatically manage signing"
# 3. Re-check "Automatically manage signing"
# 4. Xcode will regenerate profiles
```

### Issue 2: "App builds but crashes on launch"
**Fix:**
```bash
# Delete app from simulator/device
# Clean derived data:
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean build folder in Xcode
# Rebuild and reinstall
```

### Issue 3: "Git shows renamed files as deleted + new"
**Fix:**
```bash
# Use git mv for renames (preserves history)
git mv EcoJournal.xcodeproj EcoJournal.xcodeproj
git commit -m "Rename project file"
```

### Issue 4: "Tests fail after rename"
**Fix:**
```bash
# Update test target bundle IDs
# Update test scheme to match new app name
# Clean and rebuild tests
```

---

## 📊 Recommendation Based on Your Status

### **Current Status:**
- v1.0 MVP complete
- NOT published to App Store yet
- No existing users
- Waiting for Apple Developer account

### **Recommended Approach:**

**Option A: Minimal Rename NOW (30 minutes) ⭐ RECOMMENDED**
- Change display name to "Eco Journal"
- Keep bundle ID as `com.davidcontreras.EcoJournal` for now
- Keep Xcode project file as `EcoJournal.xcodeproj`
- **Why:** Fastest, lowest risk, can change bundle ID later when setting up App Store Connect

**Option B: Medium Rename BEFORE Developer Account (1 hour)**
- Change display name to "Eco Journal"
- Change bundle ID to `com.davidcontreras.ecojournal`
- Keep Xcode project file as `EcoJournal.xcodeproj`
- **Why:** Clean start with App Store Connect, still low risk

**Option C: Full Rename AFTER v1.0 Launch (2-3 hours)**
- Wait until after TestFlight testing
- Do full rename (project file, everything)
- **Why:** Avoid introducing bugs right before launch

**My Recommendation:** **Option A or B** - Do display name now (or display name + bundle ID), save full project rename for later if needed.

---

## 🎬 Quick Start (30 minutes)

```bash
# 1. Backup
cd /Users/davidcontreras/AppleXCodeProjects
zip -r EcoJournal_backup.zip EcoJournal/

# 2. Open Xcode
open EcoJournal/EcoJournal.xcodeproj

# 3. In Xcode: Select project → target → General
#    - Display Name: "Eco Journal"
#    - Bundle Identifier: (keep or change to com.davidcontreras.ecojournal)

# 4. Clean build
# Product → Clean Build Folder (Shift+Cmd+K)

# 5. Build and run
# Product → Run (Cmd+R)

# 6. Verify home screen shows "Eco Journal"

# 7. Commit
cd EcoJournal
git add .
git commit -m "Rename app display name to Eco Journal"
```

---

## 📚 App Store Connect Considerations

### When Creating App (Week 1 of Developer Account)
- **App Name:** Eco Journal (what users search for)
- **Subtitle:** GPS-Tagged Field Journal (30 char limit)
- **Bundle ID:** `com.davidcontreras.ecojournal` (permanent, can't change)
- **Primary Language:** English (U.S.)

### If Name is Already Taken
Check App Store for "Eco Journal":
```
# Search: https://apps.apple.com/us/search?term=eco%20journal

# If taken, alternatives:
- "Eco Field Journal"
- "EcoJournal: Eco Journals"
- "Field Eco Journal"
- "Eco Log Journal"
```

---

## ⏱️ Timeline

| Task | Time | When to Do |
|------|------|------------|
| Display name only | 30 min | **This weekend** (before developer account) |
| + Bundle ID | +30 min | **This weekend** OR Week 1 of developer account |
| + Full project rename | +2 hrs | **After v1.0 launch** (optional, cosmetic) |

---

## ✅ Final Recommendation

**For This Weekend:**
1. ✅ Change display name to "Eco Journal" (30 minutes)
2. ✅ Change bundle ID to `com.davidcontreras.ecojournal` (optional, +30 min)
3. ❌ DON'T do full project rename (not worth time investment)

**Result:**
- Users see "Eco Journal" on home screen ✅
- App Store listing shows "Eco Journal" ✅
- Internal project still called "EcoJournal" (doesn't matter)

**Total Time:** 30-60 minutes
**Risk:** Low
**Impact:** High (user-facing name is what matters)

---

**Status:** Ready to rename
**Recommended Path:** Display name + bundle ID change (1 hour total)
**Next Step:** Open Xcode, change display name, test build

**Last Updated:** May 26, 2026
**Document Owner:** David Contreras
