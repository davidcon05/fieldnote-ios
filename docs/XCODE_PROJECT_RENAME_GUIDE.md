# Complete Xcode Project Rename Guide
## Renaming "EcoJournal" → "EcoJournal"

**Last Updated:** May 27, 2026
**Estimated Time:** 45-60 minutes
**Difficulty:** Medium
**Risk Level:** Medium (requires careful attention, but fully reversible with backup)

---

## ⚠️ PREREQUISITES - DO THESE FIRST

### 1. Commit All Changes to Git
```bash
cd /Users/davidcontreras/AppleXCodeProjects/EcoJournal
git status
# If there are uncommitted changes:
git add .
git commit -m "Pre-rename checkpoint: All features complete"
```

### 2. Create Multiple Backups
```bash
# Backup 1: Copy entire project folder
cd /Users/davidcontreras/AppleXCodeProjects
cp -r EcoJournal EcoJournal_backup_$(date +%Y%m%d_%H%M%S)

# Backup 2: Create a zip archive
zip -r EcoJournal_backup_$(date +%Y%m%d_%H%M%S).zip EcoJournal/

# Verify backups exist
ls -lh EcoJournal_backup* | tail -5
```

### 3. Close Xcode Completely
```bash
# Make sure Xcode is fully closed (not just minimized)
# Check Activity Monitor if needed to ensure Xcode is not running
```

### 4. Note Current State
```bash
cd /Users/davidcontreras/AppleXCodeProjects/EcoJournal

# Record current structure
echo "Current project structure:" > rename_log.txt
ls -la >> rename_log.txt
echo "\n\nCurrent .xcodeproj contents:" >> rename_log.txt
ls -la EcoJournal.xcodeproj/ >> rename_log.txt
```

---

## 📋 PHASE 1: Rename Project in Xcode (15 minutes)

### Step 1: Open Project
```bash
open /Users/davidcontreras/AppleXCodeProjects/EcoJournal/EcoJournal.xcodeproj
```

**Wait for Xcode to fully load** (indexing should complete)

---

### Step 2: Rename the Project

1. **In Xcode Project Navigator (left sidebar):**
   - Look for the **blue icon** at the very top labeled "EcoJournal" (this is the project, not a folder)
   - Click on "EcoJournal" once to select it
   - Wait 1 second
   - Click on the NAME "EcoJournal" again (not the icon, the text)
   - The name should become editable with a blue highlight

2. **Type the new name:**
   - Type: `EcoJournal` (no space, camelCase)
   - Press **Enter** or **Return**

3. **Xcode Rename Dialog appears:**
   - Title: "Rename project content items?"
   - Xcode will show a list of items it wants to rename:
     - ✅ Project: EcoJournal → EcoJournal
     - ✅ Target: EcoJournal → EcoJournal
     - ✅ Scheme: EcoJournal → EcoJournal
     - ✅ Group: EcoJournal → EcoJournal
     - ✅ Build Configuration: EcoJournal → EcoJournal

4. **CRITICAL: Review the list carefully**
   - Make sure it's renaming the RIGHT things
   - Look for any red warnings or conflicts
   - If something looks wrong, click "Cancel" and ask for help

5. **Click "Rename"**
   - Xcode will process for 10-30 seconds
   - You'll see a progress indicator
   - Wait until it completes

6. **Verify in Xcode:**
   - Project navigator should now show "EcoJournal" at the top
   - Scheme dropdown (top toolbar) should show "EcoJournal"

---

### Step 3: Rename Test Targets (5 minutes)

1. **In Project Navigator:**
   - Click on "EcoJournal" project (blue icon)
   - In the main pane, you'll see a list of TARGETS

2. **Rename each test target:**

   **For "EcoJournalTests":**
   - Single-click the name "EcoJournalTests" in the TARGETS list
   - Wait 1 second, click again to make it editable
   - Type: `EcoJournalTests`
   - Press Enter

   **For "EcoJournalUITests":**
   - Single-click "EcoJournalUITests"
   - Wait 1 second, click again
   - Type: `EcoJournalUITests`
   - Press Enter

3. **Xcode may ask to rename schemes:**
   - Click "Rename" for each

---

### Step 4: Update Bundle Identifiers (5 minutes)

1. **Select EcoJournal target** (main app)
   - In TARGETS list, click "EcoJournal"
   - Go to **General** tab
   - **Identity section:**
     - Display Name: `Eco Journal` (with space - this is what users see)
     - Bundle Identifier: `com.davidcontreras.ecojournal`

2. **Select EcoJournalTests target**
   - Bundle Identifier: `com.davidcontreras.ecojournalTests`

3. **Select EcoJournalUITests target**
   - Bundle Identifier: `com.davidcontreras.ecojournalUITests`

---

### Step 5: Save and Close Xcode (2 minutes)

```bash
# In Xcode:
# File → Save (Cmd+S) - save any changes
# Xcode → Quit Xcode (Cmd+Q) - fully close
```

**CHECKPOINT 1:** At this point, Xcode internal references are renamed, but folder/file names are NOT yet changed.

---

## 📋 PHASE 2: Rename Folders and Files (10 minutes)

**IMPORTANT:** These renames must happen with Xcode CLOSED.

### Step 1: Verify Xcode is Closed
```bash
# Check if Xcode is running
ps aux | grep Xcode
# Should return nothing (or just the grep command itself)
```

---

### Step 2: Rename Project File
```bash
cd /Users/davidcontreras/AppleXCodeProjects/EcoJournal

# Rename the .xcodeproj file
mv EcoJournal.xcodeproj EcoJournal.xcodeproj

# Verify
ls -la *.xcodeproj
# Should show: EcoJournal.xcodeproj
```

---

### Step 3: Rename Main App Folder
```bash
# Still in /Users/davidcontreras/AppleXCodeProjects/EcoJournal

# Rename the main source folder
mv EcoJournal EcoJournal

# Verify
ls -la | grep -E "^d" | grep -i eco
# Should show: EcoJournal/
```

---

### Step 4: Rename Test Folders
```bash
# Rename unit tests folder
mv EcoJournalTests EcoJournalTests

# Rename UI tests folder
mv EcoJournalUITests EcoJournalUITests

# Verify
ls -la | grep -i test
# Should show:
# - EcoJournalTests/
# - EcoJournalUITests/
# - EcoJournalUITests.xctestplan (we'll rename this next)
```

---

### Step 5: Rename Test Plan File
```bash
# Rename the UI test plan
mv EcoJournalUITests.xctestplan EcoJournalUITests.xctestplan

# Verify
ls -la *.xctestplan
# Should show: EcoJournalUITests.xctestplan
```

---

### Step 6: Update Config File (if referencing project name)
```bash
# Check if Config.xcconfig mentions "EcoJournal"
grep -i "EcoJournal" Config.xcconfig

# If it does, edit it:
# (Usually this file doesn't reference project name, so might show no results)
```

---

### Step 7: Rename the Project Root Folder (OPTIONAL)
```bash
# This is the folder containing everything
# Currently: /Users/davidcontreras/AppleXCodeProjects/EcoJournal/
# Will become: /Users/davidcontreras/AppleXCodeProjects/EcoJournal/

cd /Users/davidcontreras/AppleXCodeProjects
mv EcoJournal EcoJournal

# Verify
ls -la | grep -i eco
# Should show: EcoJournal/
```

**CHECKPOINT 2:** All folders and files are now renamed. Time to update Xcode's internal references.

---

## 📋 PHASE 3: Fix Xcode File References (15 minutes)

### Step 1: Open Renamed Project
```bash
# Use the NEW path
open /Users/davidcontreras/AppleXCodeProjects/EcoJournal/EcoJournal.xcodeproj
```

**Xcode will likely show errors** - this is expected! We need to relink files.

---

### Step 2: Fix Main App Group Reference

1. **In Project Navigator:**
   - You should see "EcoJournal" project at top
   - Below it, you might see a **red folder** or missing files
   - This is the main source group that needs relinking

2. **Select the EcoJournal group:**
   - Click on the "EcoJournal" folder (below the project icon)
   - In the right panel (File Inspector), you'll see:
     - **Location:** Might show old path "EcoJournal" in red

3. **Relink the folder:**
   - Click the **folder icon** next to Location
   - Navigate to: `/Users/davidcontreras/AppleXCodeProjects/EcoJournal/EcoJournal`
   - Click "Choose"
   - Files should turn from red to white (resolved)

---

### Step 3: Fix Test Group References

**For EcoJournalTests:**
1. Click on "EcoJournalTests" group in navigator
2. If it shows red/missing, click folder icon in File Inspector
3. Navigate to: `/Users/davidcontreras/AppleXCodeProjects/EcoJournal/EcoJournalTests`
4. Click "Choose"

**For EcoJournalUITests:**
1. Click on "EcoJournalUITests" group in navigator
2. If red/missing, click folder icon in File Inspector
3. Navigate to: `/Users/davidcontreras/AppleXCodeProjects/EcoJournal/EcoJournalUITests`
4. Click "Choose"

---

### Step 4: Fix Info.plist Path

1. **Select EcoJournal target** (main app)
2. Go to **Build Settings** tab
3. Search for: `Info.plist`
4. Find: **"Info.plist File"** or **"INFOPLIST_FILE"**
5. Double-click the value
6. Change from: `EcoJournal/Info.plist`
7. To: `EcoJournal/Info.plist`

**Repeat for test targets:**
- EcoJournalTests: `EcoJournalTests/Info.plist`
- EcoJournalUITests: `EcoJournalUITests/Info.plist`

---

### Step 5: Fix Test Plan Reference

1. **Product → Scheme → Edit Scheme** (Cmd+Shift+,)
2. Click **Test** in the left sidebar
3. Look for "Test Plans" section
4. If it shows old name "EcoJournalUITests.xctestplan":
   - Click the "-" button to remove it
   - Click "+" → "Add Test Plan"
   - Select `EcoJournalUITests.xctestplan`
   - Click "Add"
5. Click "Close"

---

### Step 6: Clean Derived Data
```bash
# This forces Xcode to rebuild everything from scratch
rm -rf ~/Library/Developer/Xcode/DerivedData
```

---

## 📋 PHASE 4: Build and Test (10 minutes)

### Step 1: Clean Build Folder
```bash
# In Xcode:
# Product → Clean Build Folder (Shift+Cmd+K)
# Wait for "Clean Finished" message
```

---

### Step 2: Build the Project
```bash
# In Xcode:
# Product → Build (Cmd+B)
#
# Watch the build log for errors
# Expected: 0 errors, 0 warnings (or same warnings as before)
```

**If build FAILS:**
- Check error messages
- Common issues:
  - "No such file or directory" → File reference broken, relink it
  - "Bundle identifier conflict" → Check bundle IDs match new names
  - "Missing Info.plist" → Check Info.plist path in Build Settings

---

### Step 3: Run the App
```bash
# In Xcode:
# Product → Run (Cmd+R)
#
# Verify:
# - App launches without crashing
# - Home screen shows "Eco Journal" (not "EcoJournal")
# - All features work (create journal, add log, photos, audio)
```

---

### Step 4: Run Unit Tests
```bash
# In Xcode:
# Product → Test (Cmd+U)
#
# Expected: All tests pass (43/43 or whatever your count was)
```

**If tests FAIL:**
- Check if test target bundle IDs are correct
- Check if test target Info.plist path is correct
- Re-run tests after fixes

---

### Step 5: Run UI Tests (Optional)
```bash
# In Xcode:
# Select EcoJournalUITests scheme
# Product → Test (Cmd+U)
#
# Expected: UI tests pass (or same results as before rename)
```

---

## 📋 PHASE 5: Git Commit (5 minutes)

### Step 1: Check Git Status
```bash
cd /Users/davidcontreras/AppleXCodeProjects/EcoJournal
git status
```

**Expected output:**
- Many renamed files (shown as deleted + new)
- Modified files (.xcodeproj internals)

---

### Step 2: Use git mv for Renames (Preserves History)
```bash
# Rename folders in git
git mv EcoJournal EcoJournal
git mv EcoJournalTests EcoJournalTests
git mv EcoJournalUITests EcoJournalUITests

# Rename project file
git mv EcoJournal.xcodeproj EcoJournal.xcodeproj

# Rename test plan
git mv EcoJournalUITests.xctestplan EcoJournalUITests.xctestplan
```

**Note:** If you already renamed files manually, git might show them as deleted + new. That's okay, just commit as-is.

---

### Step 3: Stage All Changes
```bash
git add .
```

---

### Step 4: Commit
```bash
git commit -m "Rename project: EcoJournal → EcoJournal

- Renamed Xcode project to EcoJournal.xcodeproj
- Renamed all targets: EcoJournal, EcoJournalTests, EcoJournalUITests
- Renamed source folders: EcoJournal/, EcoJournalTests/, EcoJournalUITests/
- Updated bundle IDs: com.davidcontreras.ecojournal
- Updated display name: Eco Journal
- All tests passing (43/43)
- Build successful, app launches correctly"
```

---

### Step 5: Push to Remote (If Using GitHub)
```bash
# Only if you're using GitHub or other remote
git push origin main
```

---

## 📋 PHASE 6: Post-Rename Verification (5 minutes)

### Checklist - Verify Everything Works

**Xcode:**
- [ ] Project name in navigator: "EcoJournal"
- [ ] Scheme dropdown shows: "EcoJournal"
- [ ] Target names: EcoJournal, EcoJournalTests, EcoJournalUITests
- [ ] Build succeeds (Cmd+B)
- [ ] Tests pass (Cmd+U)

**App Functionality:**
- [ ] App launches on simulator/device
- [ ] Home screen shows "Eco Journal"
- [ ] Can create journals
- [ ] Can create logs with GPS/weather
- [ ] Can add photos
- [ ] Can record audio memos
- [ ] Password protection works
- [ ] Search works

**File System:**
- [ ] Project folder: `/Users/davidcontreras/AppleXCodeProjects/EcoJournal/`
- [ ] Project file: `EcoJournal.xcodeproj`
- [ ] Source folder: `EcoJournal/`
- [ ] Test folders: `EcoJournalTests/`, `EcoJournalUITests/`

**Git:**
- [ ] Changes committed
- [ ] No uncommitted files (except maybe DerivedData)
- [ ] Git history preserved (use `git log --follow` to verify)

---

## 🐛 TROUBLESHOOTING

### Issue 1: "Build failed - No such file or directory"

**Symptom:** Build fails with errors like:
```
error: no such file or directory: '/Users/.../EcoJournal/Info.plist'
```

**Fix:**
1. Select target in Xcode
2. Build Settings → Search "Info.plist"
3. Update path to use new folder name: `EcoJournal/Info.plist`

---

### Issue 2: "App crashes on launch"

**Symptom:** App builds but crashes immediately on launch

**Fix:**
1. Delete app from simulator/device
2. Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Clean build folder in Xcode: Product → Clean Build Folder
4. Rebuild and reinstall

---

### Issue 3: "Tests fail to run"

**Symptom:** Tests won't start or immediately fail

**Fix:**
1. Check test target bundle IDs are correct
2. Product → Scheme → Edit Scheme → Test
3. Verify test plan is correct: `EcoJournalUITests.xctestplan`
4. Re-run tests

---

### Issue 4: "Git shows everything as deleted + new"

**Symptom:** `git status` shows hundreds of deleted/new files

**Fix:**
```bash
# This is okay! Git will track the rename.
# Just commit as-is:
git add .
git commit -m "Rename project to EcoJournal"

# To verify git tracked the rename:
git log --follow --oneline EcoJournal/SomeFile.swift
# Should show history from before rename
```

---

### Issue 5: "Xcode shows red files in navigator"

**Symptom:** Files appear red (missing) in Xcode navigator

**Fix:**
1. Click on the red file/folder
2. In File Inspector (right panel), find "Location" field
3. Click folder icon next to Location
4. Navigate to correct folder
5. Click "Choose"

---

### Issue 6: "Can't open project after rename"

**Symptom:** Double-clicking `EcoJournal.xcodeproj` doesn't open it

**Fix:**
```bash
# Check file permissions
ls -la EcoJournal.xcodeproj

# If needed, fix permissions
chmod -R 755 EcoJournal.xcodeproj

# Try opening via terminal
open EcoJournal.xcodeproj
```

---

## 🔄 ROLLBACK PROCEDURE (If Something Goes Wrong)

### Step 1: Restore from Backup
```bash
cd /Users/davidcontreras/AppleXCodeProjects

# Find your backup
ls -lt | grep EcoJournal_backup

# Remove broken project
rm -rf EcoJournal

# Restore from backup
cp -r EcoJournal_backup_YYYYMMDD_HHMMSS EcoJournal

# OR restore from zip
unzip EcoJournal_backup_YYYYMMDD_HHMMSS.zip
```

### Step 2: Verify Restoration
```bash
open EcoJournal/EcoJournal.xcodeproj
# Should open normally
```

### Step 3: Rollback Git (If Committed)
```bash
cd /Users/davidcontreras/AppleXCodeProjects/EcoJournal

# Find commit before rename
git log --oneline | head -5

# Revert to commit before rename
git reset --hard <commit-hash-before-rename>

# Force push if you already pushed
git push --force origin main
```

---

## 📚 ADDITIONAL NOTES

### About Bundle Identifiers
- **Cannot be changed after App Store submission**
- Format: `com.davidcontreras.ecojournal` (lowercase, no spaces)
- Must be unique across entire App Store

### About Display Names
- **User-facing name** (can include spaces)
- Shows on home screen: "Eco Journal"
- Can be changed anytime (even after App Store submission)

### About Xcode Project Name
- **Internal reference only**
- Users never see this
- Changing it is cosmetic (but nice for consistency)

### About Folder Names
- **File system names** (no spaces in folders is conventional)
- Doesn't affect app functionality
- Matters for git history and developer sanity

---

## ⏱️ ESTIMATED TIME BREAKDOWN

| Phase | Task | Time |
|-------|------|------|
| **Prerequisites** | Backup, commit, close Xcode | 5 min |
| **Phase 1** | Rename in Xcode (project, targets, bundle IDs) | 15 min |
| **Phase 2** | Rename folders and files | 10 min |
| **Phase 3** | Fix Xcode file references | 15 min |
| **Phase 4** | Build, test, verify | 10 min |
| **Phase 5** | Git commit | 5 min |
| **Phase 6** | Final verification | 5 min |
| **TOTAL** | | **60 minutes** |

**Add 15-30 minutes** if troubleshooting is needed.

---

## ✅ SUCCESS CRITERIA

You'll know the rename was successful when:

1. ✅ Xcode project navigator shows "EcoJournal" at top
2. ✅ Build succeeds with zero errors
3. ✅ All tests pass (same count as before)
4. ✅ App launches and shows "Eco Journal" on home screen
5. ✅ All features work (journals, logs, photos, audio, search)
6. ✅ Git commit successful
7. ✅ No red files in Xcode navigator
8. ✅ Bundle IDs updated: `com.davidcontreras.ecojournal`

---

## 📞 WHEN TO ASK FOR HELP

**Stop and ask for help if:**
- ❌ Build fails with errors you don't understand
- ❌ App crashes on launch after rename
- ❌ Many files show red in Xcode navigator (and relinking doesn't work)
- ❌ Tests fail that passed before rename
- ❌ Git shows weird merge conflicts
- ❌ You're unsure about any step

**It's better to ask than to break the project!**

---

## 🎯 FINAL CHECKLIST

Before starting:
- [ ] All changes committed to git
- [ ] Multiple backups created (folder copy + zip)
- [ ] Xcode completely closed
- [ ] Read through entire guide once

After completing:
- [ ] Build succeeds
- [ ] Tests pass
- [ ] App launches correctly
- [ ] Changes committed to git
- [ ] Backup can be deleted (optional, keep for 1 week just in case)

---

**Status:** Ready to use as step-by-step reference
**Recommended Time:** Set aside 90 minutes (60 min + 30 min buffer)
**Best Time:** When you're fresh and can focus (not late at night!)

**Last Updated:** May 27, 2026
**Document Owner:** David Contreras
