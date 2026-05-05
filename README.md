# FieldNote

iOS field journal app for environmental science fieldwork. Built as an AI-assisted learning project.

## Quick Overview

| Aspect | Details |
|--------|---------|
| **Purpose** | GPS-tagged field observations with photos, notes, and auto-weather logging |
| **User** | Environmental scientist working outdoors |
| **Platform** | iOS 17+ (iPhone only) |
| **Tech Stack** | SwiftUI, SwiftData, CoreLocation, OpenWeatherMap API |

## Current Status

**v1.0 MVP - Week 1: Project Setup**

| Feature | Status |
|---------|--------|
| Project structure | ✅ Complete |
| Documentation | ✅ Complete |
| SwiftData models | 🔲 Not Started |
| Dashboard screen | 🔲 Not Started |

## Quick Start

```bash
# Clone the repo
git clone <repo-url>
cd fieldnote

# Open in Xcode
open fieldnote.xcodeproj

# Build and run
⌘R
```

### Weather API Setup (Later)
1. Sign up at [OpenWeatherMap](https://openweathermap.org/api)
2. Create `fieldnote/Resources/Config.xcconfig`
3. Add: `WEATHER_API_KEY = your_key_here`
4. **Never commit** (already in .gitignore)

## Documentation

| Doc | Purpose |
|-----|---------|
| [architecture.md](docs/planning/architecture.md) | File structure, tab names, design decisions |
| [implementation-plan.md](docs/planning/implementation-plan.md) | Detailed roadmap, API specs, code examples |
| [ai-assisted-dev.md](docs/learning/ai-assisted-dev.md) | Learnings, Xcode conventions, mistakes made |

## Tech Stack

- **UI:** SwiftUI
- **Data:** SwiftData (offline-first)
- **Location:** CoreLocation
- **Weather:** OpenWeatherMap API
- **Maps:** MapKit

## Key Conventions

- **Journal** = Top-level container (e.g., "Soil Samples 2026")
- **Log/Entry** = Individual field observation
- **Tabs:** Logs, New Log, Map
- **Always create files in Xcode** (not Finder)

## Roadmap

| Version | Focus | Timeline |
|---------|-------|----------|
| **v1.0** | GPS, weather, photos, notes, offline | 4-6 weeks |
| **v2.0** | Enhanced camera, photo overlays | 3-4 weeks |
| **v3.0** | ARKit measurements, CoreML species ID | 4-6 weeks |

## License

Personal learning project - not for commercial use.

---

**Last Updated:** 2026-05-05
**Next Milestone:** SwiftData models + Dashboard screen
