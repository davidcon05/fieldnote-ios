# Bug Fixes Log

This document tracks bugs fixed in the EcoJournal project to avoid repeating the same solutions.

---

## Bug Fixes

### Bug #1: Photo Deletion Index Out of Range Crash
**Date:** 2026-05-25
**Status:** ✅ RESOLVED

**Problem:**
- App crashed when deleting photos in EditLogView
- Error: `Index out of range` when accessing `editedPhotoURLs[selectedPhotoIndex]`
- Happened after deleting a photo because `selectedPhotoIndex` became invalid

**Root Cause:**
- Index adjustment logic ran BEFORE removing the item from the array
- The check `if selectedPhotoIndex >= editedPhotoURLs.count - 1` used the OLD array size
- After removal, `selectedPhotoIndex` could still point to an invalid index

**WRONG Approach (what we tried first):**
```swift
// This DOESN'T work - adjusting before removal
if selectedPhotoIndex >= editedPhotoURLs.count - 1 {
    selectedPhotoIndex = max(0, editedPhotoURLs.count - 2)
}
editedPhotoURLs.remove(at: index)  // Array changes size, index still wrong!
```

**CORRECT Solution:**
**File:** `EcoJournal/Features/Logs/Edit/EditLogView.swift:489-507`

```swift
private func deletePhoto(at index: Int) {
    guard index < editedPhotoURLs.count else { return }
    let url = editedPhotoURLs[index]

    // 1. Remove from array FIRST
    withAnimation {
        editedPhotoURLs.remove(at: index)
    }

    // 2. THEN adjust selected index based on NEW array state
    if editedPhotoURLs.isEmpty {
        selectedPhotoIndex = 0
    } else if selectedPhotoIndex >= editedPhotoURLs.count {
        selectedPhotoIndex = editedPhotoURLs.count - 1
    }

    // 3. Delete file from disk
    photoStorage.deletePhoto(at: url)
}
```

**Why This Works:**
- Removes item FIRST, so we work with the new array size
- Handles edge cases: empty array, deleting last item
- Index is always valid after adjustment

**UPDATE (2nd investigation):**
The deletion logic above was necessary but NOT sufficient. The REAL crash was happening in the VIEW render:

**File:** `EcoJournal/Features/Logs/Shared/HeroPhotoSection.swift:61`
```swift
// WRONG - crashes during render if index out of bounds
if !photoURLs.isEmpty {
    AsyncImage(url: photoURLs[selectedPhotoIndex])  // CRASH HERE!
}

// CORRECT - bounds check prevents crash
if !photoURLs.isEmpty, selectedPhotoIndex < photoURLs.count {
    AsyncImage(url: photoURLs[selectedPhotoIndex])  // Safe!
}
```

**Root Cause:** SwiftUI renders views asynchronously. Even with correct deletion logic, there's a moment where the view tries to render with the OLD `selectedPhotoIndex` but NEW (smaller) `photoURLs` array.

---

### Bug #2: Hero Photos Inconsistent Sizing
**Date:** 2026-05-25
**Status:** ✅ RESOLVED

**Problem:**
- Some hero photos span full width, others don't
- Inconsistent sizing across different photos
- Images not filling the available space properly

**Root Cause:**
- Frame modifier order matters in SwiftUI
- `.frame(maxWidth: .infinity)` followed by `.frame(height:)` doesn't always expand correctly
- `.aspectRatio(contentMode: .fill)` combined with frame order caused inconsistencies

**Solution:**
**File:** `EcoJournal/Features/Logs/Shared/HeroPhotoSection.swift:75-80`

```swift
// WRONG - inconsistent sizing
image
    .resizable()
    .aspectRatio(contentMode: .fill)
    .frame(maxWidth: .infinity)
    .frame(height: heroImageHeight)
    .clipped()

// CORRECT - consistent full-width sizing
image
    .resizable()
    .scaledToFill()
    .frame(height: heroImageHeight)  // Set height FIRST
    .frame(maxWidth: .infinity)       // Then expand width
    .clipped()
```

**Why This Works:**
- `.scaledToFill()` is more reliable than `.aspectRatio(contentMode: .fill)`
- Setting height first, then width ensures proper expansion
- Order matters: height constraint first establishes the frame, then maxWidth expands it

---

### Bug #3: Dashboard Photos Not Updating After Edit
**Date:** 2026-05-25
**Status:** ✅ RESOLVED

**Problem:**
- Journal cards on Dashboard didn't show updated photos after editing logs
- AsyncImage cached the old image even though `journal.lastModified` changed
- SwiftUI didn't detect that the image needed to reload

**WRONG Approach (what we tried first):**
```swift
// This DOESN'T work - journal.touch() alone
journal.touch()  // Updates lastModified but AsyncImage still shows old image
```

**CORRECT Solution:**
**File:** `EcoJournal/Features/Dashboard/DashboardView.swift:398`

```swift
AsyncImage(url: firstMediaURL) { phase in
    // ... image rendering
}
.id("\(firstMediaURL.absoluteString)-\(journal.lastModified.timeIntervalSince1970)")
```

**Why This Works:**
- `.id()` modifier forces SwiftUI to treat it as a NEW view when the ID changes
- Compound key: `URL + lastModified timestamp`
- When journal is saved after editing, `lastModified` updates → ID changes → AsyncImage reloads
- Handles both URL changes AND timestamp changes

---

### Bug #4: Hero Photos Stretched/No Padding (AsyncImage Caching)
**Date:** 2026-05-25
**Status:** ✅ RESOLVED

**Problem:**
- Some specific log entries show stretched photos with no padding
- Happens on BOTH Detail view AND Edit view for the same log
- Persists across navigation (not just a view state bug)
- Only fixed by deleting the log entry
- Typically camera photos, noticed when revisiting the log

**Root Cause:**
- AsyncImage aggressively caches images by URL
- When an image is first loaded with incorrect layout, iOS caches that rendered version
- Subsequent views use the cached (incorrect) version
- Camera photos often have unusual EXIF metadata or aspect ratios that trigger this
- The cache persists in memory across views and even app sessions

**NOT the cause:**
- `.frame(maxWidth: .infinity)` being "saved" - this is just layout code, not persisted data
- If it were view state, navigating away and back would fix it
- The fact that **only deleting fixes it** confirms it's cached image data

**Solution:**
**File:** `EcoJournal/Features/Logs/Shared/HeroPhotoSection.swift:95`

```swift
AsyncImage(url: photoURLs[selectedPhotoIndex]) { phase in
    // ... image rendering
}
.id("\(photoURLs[selectedPhotoIndex].absoluteString)-\(selectedPhotoIndex)")
```

**Why This Works:**
- Forces AsyncImage to treat each URL+index combination as a unique view
- When the ID changes, SwiftUI creates a NEW AsyncImage instead of reusing cached one
- Breaks the bad cache and forces fresh render with correct layout
- Similar to Dashboard fix, but uses index instead of timestamp

**Alternative Considered:**
Could use file modification timestamp, but Log model doesn't have `lastModified` field currently.

---

## Notes for Future Reference

### ✅ Things That Worked
- **`.id()` modifier with compound keys** - Forces view updates when state changes
- **Adjusting array indices AFTER removal** - Necessary but not sufficient alone
- **Bounds checking in view render** - `selectedPhotoIndex < photoURLs.count` prevents crashes
- **`.scaledToFill()` with correct frame order** - Consistent image sizing
- **Height before width frames** - `.frame(height:)` then `.frame(maxWidth:)` for full-width images

### ❌ Things That Didn't Work
- `journal.touch()` alone - AsyncImage still cached old image
- Pre-adjusting array indices before removal - Causes index out of bounds crashes
- Only checking `!photoURLs.isEmpty` - Doesn't prevent out-of-bounds access
- Deletion logic alone - View still crashes during async render
- `.frame(maxWidth:)` then `.frame(height:)` - Inconsistent sizing
- `.aspectRatio(contentMode: .fill)` - Less reliable than `.scaledToFill()`
- AsyncImage without `.id()` modifier - Aggressively caches, even bad renders
- Navigating away and back - Doesn't clear AsyncImage cache

### Key Lessons
1. **Array mutation + bounds checking** - Both deletion logic AND view bounds check are required
2. **SwiftUI async rendering** - Views can render with stale state during transitions
3. **AsyncImage ALWAYS needs `.id()`** - iOS caches aggressively, even bad renders. Use URL+timestamp or URL+index
4. **AsyncImage caching persists** - Cached across views, navigation, even bad layouts. Only `.id()` breaks it
5. **Frame modifier order matters** - Height first, then width for consistent full-width layouts
6. **Use `.scaledToFill()`** - More reliable than `.aspectRatio(contentMode: .fill)`
7. **Camera photos trigger cache bugs** - EXIF metadata or unusual aspect ratios cause AsyncImage to cache incorrectly

---

Last Updated: 2026-05-25
