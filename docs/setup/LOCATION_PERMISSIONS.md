# Location Permissions Setup

## Required: Add to Info.plist (Project Settings)

Since modern Xcode projects don't always have a standalone Info.plist file, add these keys via Xcode:

### Steps:
1. Open `fieldnote.xcodeproj` in Xcode
2. Select the `fieldnote` target
3. Go to the **Info** tab
4. Click the `+` button to add new entries

### Required Keys:

**NSLocationWhenInUseUsageDescription**
```
We need your location to tag field observations with GPS coordinates and altitude.
```

**NSLocationAlwaysAndWhenInUseUsageDescription** (optional - if you want background location)
```
We need your location to tag field observations with GPS coordinates and altitude, even when the app is in the background.
```

## Alternative: Add to Info.plist manually

If you have an `Info.plist` file in the project:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to tag field observations with GPS coordinates and altitude.</string>
```

## Testing

After adding permissions:
1. Run the app on a device or simulator
2. Navigate to New Log tab
3. System will show permission alert
4. Grant "Allow While Using App"
5. Location data should populate in the UI

## Common Issues

**Permission denied:**
- Check Settings → Privacy & Security → Location Services → fieldnote
- Reset privacy warnings: Settings → General → Transfer or Reset iPhone → Reset → Reset Location & Privacy

**Location not updating:**
- Make sure device location services are enabled
- For simulator: Features → Location → Custom Location or Apple
