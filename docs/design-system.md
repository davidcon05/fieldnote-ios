# EcoJournal Design System

## Color Palette

### Primary Colors
```swift
Primary: #4A7C59      // Forest green - main brand color
Secondary: #6B6358    // Warm brown - earth tones
Tertiary: #C4A66A     // Warm gold - accent
Neutral: #4A4E4A      // Dark gray - text/UI elements
```

### Surface Colors
```swift
Background: #FAF6F0           // Warm off-white
Surface: #FAF6F0              // Same as background
Surface Bright: #FAF6F0       // Lightest surface
Surface Dim: #DBD7CF          // Slightly darker
Surface Container: #F0ECE4    // Card backgrounds
Surface Container Low: #F5F1EA
Surface Container High: #EAE6DE
Surface Container Highest: #E4E0D8
Surface Container Lowest: #FFFFFF
```

### Semantic Colors
```swift
Error: #B83230
Error Container: #FFDAD8
On Error: #FFFFFF
On Error Container: #690005
```

### On Colors (text on colored backgrounds)
```swift
On Primary: #FFFFFF
On Secondary: #FFFFFF
On Tertiary: #FFFFFF
On Surface: #2E3230
On Background: #2E3230
On Surface Variant: #4A4E4A
```

### Additional Colors
```swift
Outline: #74796E
Outline Variant: #C4C8BC
Inverse Surface: #2E3230
Inverse On Surface: #F5F0E8
Inverse Primary: #8ECF9E
Surface Tint: #4A7C59
```

## Typography

### Fonts
- **Headline/Display:** Literata (serif)
- **Body:** Nunito Sans (sans-serif)
- **Label:** Nunito Sans (sans-serif)

### iOS Font Mapping
```swift
// Headline sizes
.largeTitle  // 34pt - Page titles
.title       // 28pt - Section headers
.title2      // 22pt - Card titles
.title3      // 20pt - Subsection headers

// Body sizes
.body        // 17pt - Main content
.callout     // 16pt - Secondary content
.subheadline // 15pt - Tertiary content
.footnote    // 13pt - Captions
.caption     // 12pt - Smallest text
.caption2    // 11pt - Metadata

// Label sizes (use same as body but with different semantic meaning)
```

## Spacing

### From Web Prototype
```
Container Padding: 24px (6 in Tailwind = 1.5rem)
Card Gap: 32px (8 in Tailwind = 2rem)
Header Height: 80px (h-20)
Button Padding: 16px horizontal, 8px vertical
```

### iOS Spacing System
```swift
4pt   // Tight
8pt   // Default spacing
12pt  // Comfortable
16pt  // Relaxed
24pt  // Loose
32pt  // Section gaps
```

## Border Radius

```swift
Default: 8pt (0.5rem)
Large: 16pt (1rem)
XLarge: 24pt (1.5rem)
Full: 9999px (pill/circular)
```

## Component Specs

### Journal Card
- **Aspect Ratio:** 4:5 (portrait)
- **Corner Radius:** 12pt (rounded-xl)
- **Shadow:** Light shadow, increases on hover
- **Image:** Scales 1.05x on hover
- **Overlay:** Black gradient from bottom (40% opacity) on hover

### Grid Layout
- **Mobile (< 640px):** 1 column
- **Small (640-1024px):** 2 columns
- **Large (> 1024px):** 3 columns

### Buttons
- **Primary:** Filled with primary color, white text
- **Secondary:** Outlined with primary color
- **Floating Action Button:** Circular, bottom-right, primary color
- **Corner Radius:** Full (pill shape)

## Placeholder Images

### Downloaded Assets
- **Nature Photos:** 2 PNGs (with transparency if needed)
- **Field Photos:** 2 JPGs (realistic photos)

### SF Symbols Fallbacks
```swift
"leaf.fill"        // Botanical/nature theme
"drop.fill"        // Water/soil theme
"mountain.2.fill"  // Terrain/geology theme
"tree.fill"        // Forest theme
"flame.fill"       // Energy/warmth theme
"snowflake"        // Alpine/cold theme
```

### Icon + Color Pairings
```swift
("leaf.fill", Color(hex: "#4A7C59"))       // Green
("drop.fill", Color(hex: "#6B6358"))       // Brown
("mountain.2.fill", Color(hex: "#C4A66A"))  // Gold
("tree.fill", Color(hex: "#4A7C59"))       // Green
("eco", Color(hex: "#4A7C59"))             // Eco icon
```

## Animation

### Transitions
- **Duration:** 300ms (0.3s) - Standard
- **Duration (Slow):** 500-700ms - Image scaling
- **Easing:** ease-out (natural deceleration)

### Hover Effects
- **Scale:** 1.05x for images
- **Shadow:** Increase elevation
- **Opacity:** Fade overlays 0 → 100%

## Accessibility

### Minimum Touch Targets
- **Buttons:** 44x44pt minimum
- **List Items:** 44pt minimum height

### Contrast Ratios
- **Primary on White:** 4.5:1+ (WCAG AA)
- **Text on Surface:** 7:1+ (AAA)

---

**Last Updated:** 2026-05-08
**Status:** Design system documented for iOS implementation
