# Offline-First Architecture

**Core Principle:** Eco Journal is designed to work 100% offline. Internet connectivity is optional and only enhances the experience.

---

## TL;DR: What Works Offline?

### ✅ 100% Offline (No Internet Required)

| Feature | How It Works Offline |
|---------|---------------------|
| **GPS Tracking** | CoreLocation uses GPS satellites (not internet) |
| **Altitude** | Barometer + GPS (device hardware) |
| **Photos** | Device camera, saved to local storage |
| **Videos** | Device camera, saved to local storage |
| **Audio Recording** | Device microphone, saved to local storage |
| **Audio Transcription** | Speech framework (after initial language pack download) |
| **Notes/Text Input** | All local, no network |
| **SwiftData Storage** | SQLite database on device |
| **Map View** | MapKit uses cached tiles (downloads when online) |
| **All Navigation** | 100% local SwiftUI navigation |
| **Timestamps** | Device clock (always available) |

### ⚠️ Optional Internet Features (Graceful Degradation)

| Feature | Requires Internet | Fallback Behavior |
|---------|------------------|-------------------|
| **Weather Data** | ✅ Yes (API call) | Shows error banner + Retry button, log still saves |
| **Air Quality (AQI)** | ✅ Yes (API call) | Shows error banner + Retry button, log still saves |
| **Map Tiles** | First time only | Uses cached tiles from previous sessions |
| **Speech Language Pack** | First time only | One-time download, then 100% offline |

---

## Detailed Offline Capabilities

### GPS & Location Services (100% Offline)

**How it works:**
- CoreLocation talks directly to GPS satellites
- No internet connection needed
- Works in airplane mode
- Works in remote areas with zero cell service

**Technical Details:**
```swift
// GPS works via satellite positioning, not internet
let locationManager = CLLocationManager()
locationManager.startUpdatingLocation()  // Uses GPS satellites only

// Device provides:
// - Latitude/Longitude (from GPS satellites)
// - Altitude (from barometer + GPS)
// - Heading (from magnetometer)
// - Speed (from GPS)
```

**Field Testing Notes:**
- GPS accuracy may be lower without [A-GPS](https://en.wikipedia.org/wiki/Assisted_GPS) (internet-assisted)
- Initial GPS lock takes 30-60s without internet (vs. 5-10s with internet)
- Once locked, accuracy is identical online/offline

**Common Misconception:**
❌ "GPS requires internet" - **FALSE**
✅ GPS uses satellites, internet only speeds up initial lock via A-GPS

---

### Weather & Air Quality Data (Optional Internet)

**Design Philosophy:** Weather is a **bonus feature**, never blocking

**Offline Behavior:**
1. App attempts to fetch weather (10-second timeout)
2. If fails → Shows error banner: "⚠️ Weather unavailable - Retry?"
3. Log saves successfully WITHOUT weather data (includes original GPS coordinates)
4. User can retry when back online
5. **CRITICAL:** Retry uses **log's stored coordinates**, NOT current location
6. Weather error stored in `log.weatherError` for debugging

**Implementation:**
```swift
// Weather fetch with graceful failure
Task {
    do {
        let weather = try await weatherService.fetchWeather(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        log.weather = weather
        log.weatherError = nil
    } catch {
        // GRACEFUL DEGRADATION - log still saves
        log.weatherError = error.localizedDescription
        showBanner("⚠️ Weather unavailable - Check connection")
    }
}

// CRITICAL: Log saves regardless of weather success/failure
guard log.isValid else { return }  // Only checks notes, not weather
modelContext.insert(log)

// Retry Implementation (MUST use log's coordinates, NOT current location)
func retryWeatherFetch(for log: Log) {
    guard let lat = log.latitude, let lon = log.longitude else {
        showError("Cannot retry: No GPS coordinates")
        return
    }

    Task {
        do {
            // CRITICAL: Use log's stored coordinates, NOT current location
            let weather = try await weatherService.fetchWeather(
                latitude: lat,   // From log, not locationManager.location
                longitude: lon   // From log, not locationManager.location
            )
            log.weather = weather
            log.weatherError = nil
            try modelContext.save()
        } catch {
            log.weatherError = error.localizedDescription
            showError("Weather retry failed")
        }
    }
}
```

**Why This Matters:**
- ✅ Weather data matches the log's location and time
- ✅ User may have moved to different location when retrying
- ✅ Historical accuracy for research data
- ❌ Using current location would give incorrect/misleading weather data

**User Experience:**
- ✅ Log creation never blocked by weather failure
- ✅ User sees clear error message
- ✅ Retry button available when back online
- ✅ Weather data is **enrichment**, not requirement

---

### Audio Transcription (Mostly Offline)

**Internet Required:**
- ✅ **First time only** - Download language pack (20-50 MB)
- ✅ After download - **100% offline** transcription

**How it works:**
```swift
// Speech framework uses on-device ML models
let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
let request = SFSpeechURLRecognitionRequest(url: audioURL)

// Transcription happens on-device (Neural Engine)
let result = try await recognizer.recognitionTask(with: request).result
```

**Offline Behavior:**
- If language pack not downloaded → Shows "Download language pack" prompt
- Once downloaded → Transcription works 100% offline
- No cloud API calls
- Uses device Neural Engine (A12+) or CPU

**Graceful Degradation:**
- If transcription fails → Audio file still saved and playable
- Transcription is bonus feature, not required for log validity

---

### Map View (Cached Tiles)

**How MapKit handles offline:**
- iOS caches map tiles automatically
- If tile not cached → Shows gray/blank area until online
- Previously viewed areas → Work 100% offline
- Pins and annotations → Always work (local data)

**Best Practice for Field Use:**
1. Before field trip: Open app, zoom to area, pan around
2. iOS caches those tiles for ~2 weeks
3. In field (offline): Cached tiles display perfectly

**What works offline:**
- ✅ Display cached map tiles
- ✅ Show log pins (uses local SwiftData)
- ✅ Pin selection and callouts
- ✅ Navigate to log details
- ✅ Center map button (uses cached coordinates)

**What doesn't work offline:**
- ❌ Download new map tiles (shows gray)
- ❌ Satellite imagery updates

---

## Data Flow: Online vs. Offline

### Creating a Log Entry (Typical Field Use)

**Online Connection:**
```
1. User opens New Log screen
2. GPS lock (5-10s with A-GPS) ✅ Offline: 30-60s
3. Fetch Weather (2-5s API call) ✅ Offline: Fails gracefully
4. Fetch AQI (2-5s API call) ✅ Offline: Fails gracefully
5. User takes photo ✅ Offline: Works
6. User records audio ✅ Offline: Works
7. Transcribe audio (2-10s on-device) ✅ Offline: Works
8. User types notes ✅ Offline: Works
9. Save to SwiftData ✅ Offline: Works
10. Display on Logs List ✅ Offline: Works
11. Show on Map View ✅ Offline: Works
```

**Offline (Airplane Mode):**
```
1. User opens New Log screen
2. GPS lock (30-60s satellite-only) ✅ Works
3. Fetch Weather → FAILS → Show error ✅ Non-blocking
4. Fetch AQI → FAILS → Show error ✅ Non-blocking
5. User takes photo ✅ Works
6. User records audio ✅ Works
7. Transcribe audio (2-10s on-device) ✅ Works (if language pack downloaded)
8. User types notes ✅ Works
9. Save to SwiftData ✅ Works
10. Display on Logs List ✅ Works
11. Show on Map View ✅ Works (with cached tiles)
```

**Result:** App is 100% functional offline, just missing weather enrichment data

---

## Storage & Sync Strategy

### v1.0: Offline-Only (No Sync)

**Current Architecture:**
- All data stored locally in SwiftData (SQLite)
- No cloud storage
- No sync between devices
- No backup (user must backup via iTunes/Finder)

**Benefits:**
- ✅ Zero network dependency
- ✅ Privacy (data never leaves device)
- ✅ Fast (no API calls)
- ✅ Works in remote locations
- ✅ No cloud storage costs

**Limitations:**
- ❌ Single device only
- ❌ No automatic backup
- ❌ Data lost if phone breaks
- ❌ Can't share logs with colleagues

### v2.0: Cloud Sync (Future)

**Planned Architecture:**
- Offline-first (same as v1.0)
- Background sync when online
- Conflict resolution for offline edits
- CloudKit or Firebase backend

**Offline-First Sync Pattern:**
```
1. User creates log offline → Saves locally ✅
2. User creates 10 more logs offline → All save locally ✅
3. User gets cell service → Background sync uploads all logs ✅
4. Another device → Downloads synced logs ✅
5. Conflict (same log edited on 2 devices) → User resolves ✅
```

**Benefits of Offline-First Sync:**
- ✅ Never blocks user workflow
- ✅ Multiple device support
- ✅ Automatic backup
- ✅ Team collaboration
- ✅ Still works 100% offline (queues sync for later)

---

## Field Testing Scenarios

### Scenario 1: Deep Forest (Zero Cell Service)

**Connectivity:**
- ❌ No cellular data
- ❌ No WiFi
- ✅ GPS satellites visible

**Expected Behavior:**
- ✅ GPS tracking works (satellite-based)
- ✅ Photos/videos work (local storage)
- ✅ Audio + transcription work (on-device)
- ✅ Notes work (local storage)
- ✅ Map view works (cached tiles)
- ❌ Weather data fails (shows retry button)
- ❌ AQI fails (shows retry button)
- ✅ **Log saves successfully**

**Post-Field (Back Online):**
- User taps "Retry" on weather banner → Fetches weather for saved log
- Weather data backfills for existing logs

---

### Scenario 2: Airplane Mode (Simulated Offline)

**Connectivity:**
- ❌ All radios disabled

**Expected Behavior:**
- ✅ GPS works (satellites only, no A-GPS)
- ✅ All capture features work
- ❌ Weather/AQI fail gracefully
- ✅ **App is 100% functional**

**Testing Notes:**
- GPS lock takes longer (30-60s vs. 5-10s)
- First-time speech recognition language pack → Needs internet
- Map tiles → Only cached areas show

---

### Scenario 3: Weak Signal (1-2 Bars)

**Connectivity:**
- ✅ GPS works (A-GPS available)
- ⚠️ Internet slow/unreliable

**Expected Behavior:**
- ✅ GPS lock fast (5-10s)
- ⚠️ Weather API may timeout (10s limit)
- ⚠️ AQI may timeout (10s limit)
- ✅ **User never waits > 10s for API**
- ✅ **Log always saves**

**Design Decision: 10-Second Timeout**
```swift
// Never block user workflow for >10s
let weatherData = try await weatherService.fetchWeather(
    latitude: lat,
    longitude: lon
)
.timeout(10)  // Give up after 10s, show error, allow log save
```

---

## Network Dependency Summary

| Feature | Internet? | GPS Satellites? | Notes |
|---------|-----------|----------------|-------|
| GPS Coordinates | ❌ No | ✅ Yes | Satellites only |
| Altitude | ❌ No | ✅ Yes | Barometer + GPS |
| Photos/Videos | ❌ No | ❌ No | Device camera |
| Audio Recording | ❌ No | ❌ No | Device mic |
| Audio Transcription | First time* | ❌ No | On-device ML |
| Notes/Text | ❌ No | ❌ No | Local input |
| SwiftData Storage | ❌ No | ❌ No | SQLite |
| Weather Data | ✅ Yes | ❌ No | API call |
| AQI Data | ✅ Yes | ❌ No | API call |
| Map Tiles | Cached** | ❌ No | iOS caching |

\* Speech recognition needs internet to download language pack once (20-50 MB), then 100% offline
\** Map tiles cached by iOS, previously viewed areas work offline

---

## Why This Matters for Field Research

### Real-World Field Conditions:

**Typical Field Site:**
- 🏔️ Remote location (no cell towers)
- 🌲 Forest canopy (weak GPS initially)
- ☁️ Weather changes rapidly
- 📱 Limited battery life
- 🧤 Wet/cold/gloved hands
- ⚡ No power for charging

**Offline-First Design Benefits:**
1. **Never blocks workflow** - Log creation always succeeds
2. **No waiting** - API timeouts don't delay field work
3. **Battery efficient** - No constant network polling
4. **Privacy** - Data never leaves device (optional sync later)
5. **Reliable** - Works in 100% of locations, not just where there's service

### Competitive Advantage:

**Other Field Apps (Typical):**
- ❌ Require internet for save (blocks workflow)
- ❌ No offline mode (can't use in remote areas)
- ❌ Cloud-only storage (no internet = no data)

**Eco Journal:**
- ✅ 100% offline-capable
- ✅ Internet enhances but never required
- ✅ Graceful degradation for optional features
- ✅ Data always saved locally first

---

## Testing Offline Functionality

### Simulator Testing:
```bash
# Simulate offline conditions
Settings → Developer → Network Link Conditioner
→ Profile: 100% Loss

# Or via Xcode
Debug → Simulate Location → Custom Location (offline)
```

### Device Testing:
```bash
# Full offline test
1. Enable Airplane Mode
2. Open Eco Journal app
3. Create new log
4. Verify: GPS works (may take 30-60s)
5. Verify: Weather shows error (graceful)
6. Verify: Photos/audio work
7. Verify: Log saves successfully
8. Disable Airplane Mode
9. Tap "Retry" on weather → Backfills data
```

### API Timeout Testing:
```bash
# Test slow network
Settings → Developer → Network Link Conditioner
→ Profile: Very Bad Network (500ms delay, 20% packet loss)

# Verify:
- GPS still works
- Weather times out after 10s
- Log still saves
- User sees clear error message
```

---

## Future: Offline Improvements (v1.1+)

### Planned Enhancements:

1. **Offline Weather Cache**
   - Cache last weather reading per location
   - Show "Last known weather (2 hours ago)" when offline
   - Better than blank/error state

2. **Weather Backfill on Sync**
   - When back online, automatically fetch weather for offline logs
   - Update `log.weather` with historical data (if available)

3. **Progressive Web App (PWA) Export**
   - Export logs as offline-viewable HTML
   - Share via AirDrop, email, or USB
   - Colleagues can view without app installed

4. **Offline Map Tile Pre-Download**
   - Settings → Download Map Area for Offline Use
   - Pre-cache map tiles before field trip
   - Ensures full map availability

---

## Key Takeaways

1. **Eco Journal is offline-first by design**
2. **GPS works 100% offline** (satellites, not internet)
3. **Weather is optional enrichment**, never blocking
4. **All core features work offline** (photos, audio, notes, storage)
5. **Speech transcription works offline** (after initial language pack download)
6. **Internet only enhances the experience**, never required

**Design Philosophy:**
> "The app should work in the middle of a rainforest with zero cell service. Internet is a bonus, not a requirement."

---

**Last Updated:** 2026-05-13
**Document Owner:** David Contreras
