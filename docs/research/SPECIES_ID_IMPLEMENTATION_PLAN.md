# Species Identification Implementation Plan

**Feature:** AI-powered species identification using iNaturalist Computer Vision API
**Target Version:** v2.0
**Estimated Effort:** 2-3 weeks (server-side), 4-6 weeks (with on-device model)
**Status:** Research complete, ready for implementation

---

## 🎯 Strategy: Phased Rollout

### Phase 1: Server-Side CV API (v2.0) ⭐ **START HERE**
### Phase 2: Data Layer Enrichment (v2.1)
### Phase 3: Hybrid On-Device Model (v2.5) - Optional

---

## Phase 1: Server-Side CV API (v2.0)

### Why Start Server-Side?

**Advantages:**
- ✅ Full 80,000+ taxa coverage from day one
- ✅ Zero app bundle bloat (model stays server-side)
- ✅ Automatic model updates (no app resubmission)
- ✅ Faster time to market (2-3 weeks)
- ✅ Perfect fit for offline-first: capture offline → identify when signal returns

**Disadvantages:**
- ❌ Requires network connectivity (acceptable for EcoJournal's use case)
- ❌ API rate limits (1000 requests/day typical for free tier)
- ❌ Slight latency (1-2 seconds vs instant on-device)

**Decision:** Start here. Most field scientists have signal at end of day (back at camp/vehicle). The "capture offline, identify later" pattern is natural.

---

### Architecture

```
User Flow:
1. User takes photo in log entry (offline OK)
2. Photo saved locally to device
3. "Identify Species" button appears on photo
4. User taps button when they have signal
5. App uploads photo to iNaturalist CV API
6. API returns top 5 species matches with confidence scores
7. User selects correct species → Auto-adds tag to log
8. Tag is searchable across all journals
```

**Key Design Decisions:**
- **Capture-then-query pattern** (not live video inference)
- **Explicit user action** ("Identify" button, not automatic)
- **Offline-tolerant** (defer identification until connectivity)
- **Multiple results** (show top 5 with confidence scores)
- **User validation** (AI suggests, human confirms)

---

### Technical Implementation

#### 1. Data Models

```swift
// SpeciesIdentification.swift
struct SpeciesMatch: Codable, Identifiable {
    let id: Int // taxon ID
    let name: String // scientific name
    let commonName: String?
    let confidence: Double // 0.0 to 1.0
    let thumbnailURL: URL?
    let wikiURL: URL?
    let rank: String // "species", "genus", etc.
}

struct CVResponse: Codable {
    let results: [CVResult]
}

struct CVResult: Codable {
    let taxon: Taxon
    let score: Double // confidence
}

struct Taxon: Codable {
    let id: Int
    let name: String // scientific
    let preferredCommonName: String?
    let defaultPhoto: Photo?
    let rank: String
    let wikipediaSummary: String?
}

struct Photo: Codable {
    let squareURL: URL?
    let mediumURL: URL?
}
```

#### 2. Service Layer

```swift
// PhotoIdentificationService.swift
import Foundation
import UIKit

enum IdentificationError: Error {
    case invalidImage
    case networkError
    case noResults
    case apiRateLimited
}

class PhotoIdentificationService {
    private let baseURL = "https://api.inaturalist.org/v2"

    /// Identify species from a photo
    func identifySpecies(image: UIImage, location: CLLocation? = nil) async throws -> [SpeciesMatch] {
        // 1. Compress image (max 2MB for API)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw IdentificationError.invalidImage
        }

        // 2. Build multipart form request
        let url = URL(string: "\(baseURL)/computervision/score_image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // Add location (improves accuracy)
        if let location = location {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"lat\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(location.coordinate.latitude)\r\n".data(using: .utf8)!)

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"lng\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(location.coordinate.longitude)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // 3. Send request
        let (data, response) = try await URLSession.shared.data(for: request)

        // 4. Handle response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw IdentificationError.networkError
        }

        if httpResponse.statusCode == 429 {
            throw IdentificationError.apiRateLimited
        }

        guard httpResponse.statusCode == 200 else {
            throw IdentificationError.networkError
        }

        // 5. Parse results
        let cvResponse = try JSONDecoder().decode(CVResponse.self, from: data)

        guard !cvResponse.results.isEmpty else {
            throw IdentificationError.noResults
        }

        // 6. Convert to SpeciesMatch
        return cvResponse.results.prefix(5).map { result in
            SpeciesMatch(
                id: result.taxon.id,
                name: result.taxon.name,
                commonName: result.taxon.preferredCommonName,
                confidence: result.score,
                thumbnailURL: result.taxon.defaultPhoto?.squareURL,
                wikiURL: nil, // Will fetch in Phase 2
                rank: result.taxon.rank
            )
        }
    }

    /// Cache results to avoid redundant API calls
    func cachedIdentification(for photoURL: URL) -> [SpeciesMatch]? {
        // Check UserDefaults for cached results (24hr TTL)
        // Return nil if expired or not found
        // TODO: Implement caching
        return nil
    }
}
```

#### 3. ViewModel Integration

```swift
// LogDetailViewModel.swift (or EditLogViewModel.swift)
@Observable
class LogDetailViewModel {
    var log: Log
    var isIdentifying = false
    var identificationResults: [SpeciesMatch] = []
    var identificationError: String?

    private let identificationService = PhotoIdentificationService()

    func identifySpeciesInPhoto(_ photoURL: URL) async {
        isIdentifying = true
        identificationError = nil

        do {
            // Load image from local storage
            guard let image = UIImage(contentsOfFile: photoURL.path) else {
                throw IdentificationError.invalidImage
            }

            // Use log's GPS (not current location!)
            let location = log.latitude.flatMap { lat in
                log.longitude.map { lng in
                    CLLocation(latitude: lat, longitude: lng)
                }
            }

            // Call API
            let results = try await identificationService.identifySpecies(
                image: image,
                location: location
            )

            identificationResults = results

        } catch IdentificationError.apiRateLimited {
            identificationError = "Rate limit reached. Try again in an hour."
        } catch IdentificationError.noResults {
            identificationError = "Could not identify species. Try a clearer photo."
        } catch {
            identificationError = "Network error. Check your connection."
        }

        isIdentifying = false
    }

    func addSpeciesTag(_ match: SpeciesMatch) {
        // Add to log's tags array
        let tag = match.commonName ?? match.name
        if !log.tags.contains(tag) {
            log.tags.append(tag)
        }

        // Clear results
        identificationResults = []
    }
}
```

#### 4. UI Components

```swift
// SpeciesIdentificationSheet.swift
struct SpeciesIdentificationSheet: View {
    let photoURL: URL
    @Bindable var viewModel: LogDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Photo preview
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } placeholder: {
                    ProgressView()
                }
                .background(Color.surfaceContainerHigh)

                // Results or loading state
                if viewModel.isIdentifying {
                    loadingView
                } else if let error = viewModel.identificationError {
                    errorView(error)
                } else if !viewModel.identificationResults.isEmpty {
                    resultsList
                } else {
                    promptView
                }
            }
            .navigationTitle("Identify Species")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            // Auto-identify on appear if not already done
            if viewModel.identificationResults.isEmpty && !viewModel.isIdentifying {
                Task {
                    await viewModel.identifySpeciesInPhoto(photoURL)
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Analyzing photo...")
                .font(.body(16))
                .foregroundColor(.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.error)

            Text(message)
                .font(.body(16))
                .foregroundColor(.onSurface)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Try Again") {
                Task {
                    await viewModel.identifySpeciesInPhoto(photoURL)
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.identificationResults) { match in
                    SpeciesMatchCard(match: match) {
                        viewModel.addSpeciesTag(match)
                        dismiss()
                    }
                }
            }
            .padding(16)
        }
    }

    private var promptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(.primary)

            Text("Tap 'Identify' to analyze this photo")
                .font(.body(16))
                .foregroundColor(.onSurfaceVariant)

            Button("Identify Species") {
                Task {
                    await viewModel.identifySpeciesInPhoto(photoURL)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// SpeciesMatchCard.swift
struct SpeciesMatchCard: View {
    let match: SpeciesMatch
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Thumbnail
                AsyncImage(url: match.thumbnailURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.surfaceContainerHigh
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.commonName ?? match.name)
                        .font(.body(16, weight: .semibold))
                        .foregroundColor(.onSurface)

                    Text(match.name)
                        .font(.body(14))
                        .foregroundColor(.onSurfaceVariant)
                        .italic()

                    // Confidence bar
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.surfaceContainerHighest)
                                    .frame(height: 4)

                                // Fill
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(confidenceColor)
                                    .frame(width: geometry.size.width * match.confidence, height: 4)
                            }
                        }
                        .frame(height: 4)

                        Text("\(Int(match.confidence * 100))%")
                            .font(.label(12))
                            .foregroundColor(.onSurfaceVariant)
                            .frame(width: 40, alignment: .trailing)
                    }
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }
            .padding(12)
            .background(Color.surfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.outlineVariant, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var confidenceColor: Color {
        if match.confidence > 0.7 {
            return .green
        } else if match.confidence > 0.4 {
            return .orange
        } else {
            return .red
        }
    }
}
```

#### 5. Integration into LogDetailView

```swift
// LogDetailView.swift (or EditLogView.swift)
struct LogDetailView: View {
    @State private var showIdentificationSheet = false
    @State private var selectedPhotoForID: URL?

    var body: some View {
        // ... existing layout

        // Add "Identify" button to each photo in gallery
        ForEach(log.photoURLs, id: \.self) { photoURL in
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: photoURL) { image in
                    image.resizable().scaledToFill()
                }

                // Identify button overlay
                Button {
                    selectedPhotoForID = photoURL
                    showIdentificationSheet = true
                } label: {
                    Label("Identify", systemImage: "sparkles")
                        .font(.label(12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Capsule())
                }
                .padding(8)
            }
        }
        .sheet(isPresented: $showIdentificationSheet) {
            if let photoURL = selectedPhotoForID {
                SpeciesIdentificationSheet(photoURL: photoURL, viewModel: viewModel)
            }
        }
    }
}
```

---

### API Rate Limits & Caching

**iNaturalist API Limits:**
- Free tier: ~1000 requests/day (typical)
- No official public documentation on hard limits
- Best practice: Implement caching

**Caching Strategy:**
```swift
// Cache results for 24 hours
func cacheIdentification(photoURL: URL, results: [SpeciesMatch]) {
    let cacheKey = "id_\(photoURL.lastPathComponent)"
    let cacheData = try? JSONEncoder().encode(results)
    UserDefaults.standard.set(cacheData, forKey: cacheKey)
    UserDefaults.standard.set(Date(), forKey: "\(cacheKey)_timestamp")
}

func getCachedIdentification(photoURL: URL) -> [SpeciesMatch]? {
    let cacheKey = "id_\(photoURL.lastPathComponent)"

    // Check if cached
    guard let cacheData = UserDefaults.standard.data(forKey: cacheKey),
          let timestamp = UserDefaults.standard.object(forKey: "\(cacheKey)_timestamp") as? Date else {
        return nil
    }

    // Check if expired (24 hours)
    let age = Date().timeIntervalSince(timestamp)
    guard age < 86400 else { // 24 hours in seconds
        return nil
    }

    // Return cached results
    return try? JSONDecoder().decode([SpeciesMatch].self, from: cacheData)
}
```

---

### Testing Checklist

**Unit Tests:**
- [ ] PhotoIdentificationService.identifySpecies() returns valid results
- [ ] Handles network errors gracefully
- [ ] Handles rate limiting (429 response)
- [ ] Handles no results case
- [ ] Image compression works (max 2MB)

**Integration Tests:**
- [ ] Full flow: tap "Identify" → see results → add tag
- [ ] Works offline (defers until connectivity)
- [ ] GPS coordinates from log (not current location) sent to API
- [ ] Multiple photos in one log can each be identified
- [ ] Results cached for 24 hours

**Manual Testing:**
- [ ] Test with clear bird photo (high confidence expected)
- [ ] Test with blurry photo (low confidence or no results)
- [ ] Test with non-nature photo (should return low confidence)
- [ ] Test in airplane mode (graceful error)
- [ ] Test with location vs. without (compare accuracy)

---

## Phase 2: Data Layer Enrichment (v2.1)

**Goal:** Add context to AI predictions to build user trust

### Features to Add

#### 1. Nearby Observations Count
```swift
// After CV identification
func getNearbyObservationCount(taxonID: Int, location: CLLocation, radius: Int = 50) async throws -> Int {
    let url = URL(string: "https://api.inaturalist.org/v2/observations?taxon_id=\(taxonID)&lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&radius=\(radius)&per_page=1")!

    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(ObservationsResponse.self, from: data)

    return response.totalResults
}
```

**UI Update:**
```swift
Text("📍 \(nearbyCount) observations within 50km")
    .font(.body(14))
    .foregroundColor(.green)
```

#### 2. Similar Species (Disambiguation)
```swift
func getSimilarSpecies(taxonID: Int) async throws -> [SpeciesMatch] {
    let url = URL(string: "https://api.inaturalist.org/v2/identifications/similar_species?taxon_id=\(taxonID)")!

    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(SimilarSpeciesResponse.self, from: data)

    return response.results.map { /* convert to SpeciesMatch */ }
}
```

**UI Update:**
```swift
if !similarSpecies.isEmpty {
    Text("⚠️ Often confused with:")
        .font(.label(12))
        .foregroundColor(.onSurfaceVariant)

    ForEach(similarSpecies.prefix(3)) { species in
        Text("• \(species.commonName ?? species.name)")
            .font(.body(12))
            .foregroundColor(.onSurfaceVariant)
    }
}
```

#### 3. Taxon Details (Wikipedia Summary)
```swift
func getTaxonDetails(taxonID: Int) async throws -> TaxonDetails {
    let url = URL(string: "https://api.inaturalist.org/v2/taxa/\(taxonID)")!

    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(TaxonResponse.self, from: data)

    return TaxonDetails(
        name: response.results.first?.name ?? "",
        commonName: response.results.first?.preferredCommonName,
        wikipediaSummary: response.results.first?.wikipediaSummary,
        wikipediaURL: response.results.first?.wikipediaURL,
        conservationStatus: response.results.first?.conservationStatus
    )
}
```

**UI Update:**
```swift
if let summary = taxonDetails.wikipediaSummary {
    VStack(alignment: .leading, spacing: 8) {
        Text("About This Species")
            .font(.headline(16))
            .foregroundColor(.onSurface)

        Text(summary)
            .font(.body(14))
            .foregroundColor(.onSurfaceVariant)
            .lineLimit(3)

        if let url = taxonDetails.wikipediaURL {
            Link("Read more on Wikipedia →", destination: url)
                .font(.body(14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}
```

---

## Phase 3: Hybrid On-Device Model (v2.5 - Optional)

**Only pursue this if:**
- Users frequently in zero-signal areas for multiple days
- Server API rate limits become a bottleneck
- Want instant identification (no loading delay)

### Trade-offs

**Pros:**
- ✅ Works 100% offline for common species
- ✅ Instant results (no API latency)
- ✅ No rate limits

**Cons:**
- ❌ App bundle size +50-100MB
- ❌ Model updates require app updates (or on-demand download infrastructure)
- ❌ Limited taxa coverage (500-1000 vs 80,000+ on server)
- ❌ 2-3 weeks additional development time

### Implementation Strategy

**1. Download Small Model on First Launch**
```swift
func downloadCoreModel() async throws {
    // Download compressed .mlmodel file from CDN
    let url = URL(string: "https://your-cdn.com/inat_500taxa_v1.mlmodel")!
    let (localURL, _) = try await URLSession.shared.download(from: url)

    // Move to documents directory
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let destinationURL = documentsPath.appendingPathComponent("inat_model.mlmodel")

    try FileManager.default.moveItem(at: localURL, to: destinationURL)
}
```

**2. Hybrid Fallback Pattern (Seek's Approach)**
```swift
func identifySpecies(image: UIImage, location: CLLocation?) async throws -> [SpeciesMatch] {
    // Try on-device first
    if let localResults = try? identifyLocally(image: image),
       localResults.first?.confidence ?? 0 > 0.7 {
        return localResults // High confidence, use local result
    }

    // Fallback to server for edge cases
    return try await identifyViaAPI(image: image, location: location)
}

private func identifyLocally(image: UIImage) throws -> [SpeciesMatch] {
    // Load CoreML model
    let modelURL = /* ... */
    let model = try MLModel(contentsOf: modelURL)

    // Preprocess image using Vision framework
    let request = VNCoreMLRequest(model: try VNCoreMLModel(for: model))
    let handler = VNImageRequestHandler(cgImage: image.cgImage!)
    try handler.perform([request])

    // Parse results
    guard let results = request.results as? [VNClassificationObservation] else {
        throw IdentificationError.noResults
    }

    return results.prefix(5).map { observation in
        SpeciesMatch(
            id: 0, // No taxon ID for local model
            name: observation.identifier,
            commonName: nil,
            confidence: Double(observation.confidence),
            thumbnailURL: nil,
            wikiURL: nil,
            rank: "species"
        )
    }
}
```

**3. Model Update Strategy**
```swift
// Check for model updates on app launch
func checkForModelUpdates() async {
    let currentVersion = UserDefaults.standard.integer(forKey: "model_version")
    let latestVersion = try? await getLatestModelVersion()

    if let latestVersion = latestVersion, latestVersion > currentVersion {
        // Prompt user to download updated model
        showModelUpdateAlert = true
    }
}
```

---

## 🎯 Recommendation

**Start with Phase 1 (Server-Side CV) for v2.0**

**Rationale:**
1. **Faster time to market** - 2-3 weeks vs 4-6 weeks
2. **Full taxa coverage** - 80,000+ species vs 500-1000
3. **Zero bundle bloat** - No 50-100MB model file
4. **Natural offline pattern** - "Identify later" fits field scientist workflow
5. **Proven user feedback** - Launch, gather usage data, THEN decide if on-device is needed

**When to add Phase 3 (On-Device):**
- After 3-6 months of real-world usage
- If users report API rate limiting issues
- If "identify offline" becomes top feature request
- If you have budget for 2-3 weeks of additional dev time

---

## 📊 Success Metrics

### Phase 1 Success Criteria
- [ ] 90%+ identification success rate (user confirms result)
- [ ] <3 seconds average API response time
- [ ] Zero app crashes during identification flow
- [ ] Users identify 5+ species per week on average
- [ ] Positive feedback: "This is incredibly useful"

### Phase 2 Success Criteria
- [ ] Nearby observations data builds user trust (measured via surveys)
- [ ] Similar species warnings reduce misidentifications
- [ ] Wikipedia summaries lead to external clicks (engagement metric)

### Phase 3 Success Criteria (if pursued)
- [ ] On-device model handles 80%+ of identifications (vs API fallback)
- [ ] <1 second identification time (instant results)
- [ ] App bundle size <150MB total

---

## 📚 Resources

### API Documentation
- **iNaturalist CV API:** https://api.inaturalist.org/v2/docs/
- **Computer Vision Endpoint:** `/v2/computervision/score_image`
- **Observations API:** `/v2/observations`
- **Taxa API:** `/v2/taxa/{id}`
- **Similar Species:** `/v2/identifications/similar_species`

### Code References
- **Seek App (React Native):** https://github.com/inaturalist/SeekReactNative
- **Vision Camera Plugin:** https://github.com/inaturalist/vision-camera-plugin-inatvision
- **Apple Vision Framework:** https://developer.apple.com/documentation/vision
- **CoreML:** https://developer.apple.com/documentation/coreml

### Model Files
- **Small Public Model (500 taxa):** Contact iNaturalist for access
- **Full Model (80,000+ taxa):** Server-side only (CV API)
- **Community Models:** HuggingFace, Kaggle (search "iNaturalist classifier")

---

**Status:** ✅ Ready to implement
**Recommendation:** Start Phase 1 (Server-Side CV) in v2.0
**Estimated Timeline:** 2-3 weeks for Phase 1, +1 week for Phase 2
**Next Action:** API integration → SpeciesMatch UI → Cache layer → Testing

**Last Updated:** May 26, 2026
**Document Owner:** David Contreras
