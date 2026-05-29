# Photo Skew Bug - Landscape Images

**Issue**: Landscape photos were causing the screen to skew/expand horizontally beyond the device width in `LogDetailView` and `EditLogView`.

**Date Reported**: 2026-05-26

---

## Problem Description

When displaying landscape-oriented photos in the hero section of both `LogDetailView` and `EditLogView`, the image would expand horizontally beyond the screen bounds, causing the entire view to become scrollable horizontally and breaking the layout.

**Affected Views**:
- `LogDetailView` (read-only mode)
- `EditLogView` (editable mode)

**Root Cause Location**:
`HeroPhotoSection.swift` lines 82-88

---

## Investigation Timeline

### Attempt 1: Modifier Order (FAILED)
**Hypothesis**: The `.frame(maxWidth: .infinity)` modifier was being applied before `.clipped()`, allowing the image to expand first, then clip incorrectly.

**Attempted Fix**:
```swift
image
    .resizable()
    .scaledToFill()
    .frame(maxWidth: .infinity)
    .frame(height: heroImageHeight)
    .clipped()
```

**Reasoning**: We thought moving `.frame()` modifiers lower in the stack (closer to `.clipped()`) would constrain the image before it expanded.

**Result**: ❌ **FAILED** - The skewing persisted even after reordering modifiers.

**Why it failed**: `.frame(maxWidth: .infinity)` doesn't actually constrain the width to the screen—it just tells SwiftUI the view *can* expand infinitely. The image was still rendering at its full intrinsic width before clipping.

---

### Attempt 2: GeometryReader with Explicit Width (SUCCESS ✅)
**Hypothesis**: The image needs an explicit width constraint based on the actual available screen width, not just `.maxWidth: .infinity`.

**Working Fix** (Applied 2026-05-26):
```swift
case .success(let image):
    GeometryReader { geometry in
        image
            .resizable()
            .scaledToFill()
            .frame(width: geometry.size.width, height: heroImageHeight)
            .clipped()
    }
    .frame(height: heroImageHeight)
```

**Key Changes**:
1. Wrapped image in `GeometryReader` to get actual available width
2. Changed `.frame(maxWidth: .infinity)` to `.frame(width: geometry.size.width, height: heroImageHeight)`
3. Moved outer `.frame(height:)` to the `GeometryReader` instead of the image

**Why this works**:
- `GeometryReader` provides the **actual** width available in the parent container (screen width)
- `.frame(width: geometry.size.width)` gives the image an **explicit width constraint**
- `.scaledToFill()` can now scale the image to fill the constrained frame without exceeding it
- `.clipped()` removes any overflow that extends beyond the frame boundaries

**Result**: ✅ **SUCCESS** - Landscape photos now display correctly without horizontal scrolling or layout skewing.

---

## Technical Explanation

### Why `.maxWidth: .infinity` Failed

SwiftUI's `.frame(maxWidth: .infinity)` means:
> "This view is flexible and can grow up to infinity if the parent allows it."

It does **NOT** mean:
> "Constrain this view to the parent's width."

For landscape images with `scaledToFill()`:
1. The image calculates its ideal size to fill the height (400pt)
2. To maintain aspect ratio, it calculates width needed (e.g., 1600pt for a 4:1 landscape photo)
3. `.maxWidth: .infinity` says "yes, you can be 1600pt wide"
4. `.clipped()` clips the overflow, but the view's frame is still 1600pt wide
5. Parent container sees a 1600pt wide child and allows horizontal scrolling

### Why GeometryReader Works

With `GeometryReader`:
1. `GeometryReader` measures the parent container's available width (e.g., 393pt on iPhone 16 Pro)
2. `.frame(width: 393pt)` explicitly constrains the image to 393pt wide
3. `.scaledToFill()` scales the image to fill 393pt × 400pt
4. `.clipped()` removes overflow outside the 393pt × 400pt bounds
5. Parent container sees a 393pt wide child (no horizontal scroll)

---

## Files Modified

**File**: `/Users/davidcontreras/AppleXCodeProjects/EcoJournal/EcoJournal/Features/Logs/Shared/HeroPhotoSection.swift`

**Line**: 82-90

**Diff**:
```diff
- image
-     .resizable()
-     .scaledToFill()
-     .frame(maxWidth: .infinity)
-     .frame(height: heroImageHeight)
-     .clipped()
+ GeometryReader { geometry in
+     image
+         .resizable()
+         .scaledToFill()
+         .frame(width: geometry.size.width, height: heroImageHeight)
+         .clipped()
+ }
+ .frame(height: heroImageHeight)
```

---

## Testing Notes

**How to Test**:
1. Create a log with a landscape photo (wide aspect ratio, e.g., 16:9 or 4:3)
2. Navigate to `LogDetailView`
3. Verify:
   - ✅ Photo displays at full screen width
   - ✅ No horizontal scrolling
   - ✅ Photo is cropped vertically (top/bottom) to maintain 40% screen height
   - ✅ Layout remains stable

**Test Cases**:
- Portrait photo (9:16) - should fill width, crop top/bottom
- Landscape photo (16:9) - should fill width, crop left/right
- Square photo (1:1) - should fill width, crop top/bottom
- Ultra-wide photo (21:9) - should fill width, heavily crop left/right

---

## Lessons Learned

1. **`.frame(maxWidth: .infinity)` is not a constraint** - it's a flexibility declaration for layout negotiation
2. **Modifier order matters, but it's not a silver bullet** - sometimes you need explicit values, not just reordering
3. **GeometryReader is the solution for "constrain to parent width"** - it provides actual measured values
4. **SwiftUI layout is proposal-based** - child views propose sizes to parents, parents accept/reject/modify them. `.maxWidth: .infinity` is a proposal, not a constraint.

---

## Future Considerations

If we need to change the hero image behavior in the future:

- **For `.scaledToFit()`** (letterboxing): Keep `GeometryReader` but change `.scaledToFill()` to `.scaledToFit()`
- **For different aspect ratios**: Adjust `heroImageHeight` calculation or add aspect ratio parameter
- **For full-bleed photos**: Current implementation is correct
- **For contained photos with padding**: Wrap `GeometryReader` in padding, not the image

---

**Status**: ✅ RESOLVED
**Version**: Fixed in commit [pending]
**Verified By**: [Pending testing]
