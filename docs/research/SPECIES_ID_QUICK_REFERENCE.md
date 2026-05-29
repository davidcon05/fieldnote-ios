# Species Identification - Quick Reference

**Last Updated:** May 26, 2026
**Status:** Ready to implement in v2.0
**Estimated Effort:** 2-3 weeks

---

## TL;DR - Key Decisions

### ✅ What We're Building (v2.0)
**Server-side identification using iNaturalist Computer Vision API**

- User taps "Identify Species" button on photo
- Photo uploaded to iNaturalist CV API
- Returns top 5 species matches with confidence scores
- User selects correct species → Auto-adds tag to log
- Works offline-first: capture photo offline, identify later when signal returns

### ❌ What We're NOT Building (Yet)
**On-device CoreML model** - Deferred to v2.5+ (optional)

**Why not on-device?**
- Adds 50-100MB to app bundle
- Only covers 500-1000 taxa (vs 80,000+ on server)
- Requires 2-3 extra weeks of development
- Model updates require app updates or complex download infrastructure

**Decision:** Build server-side first, gather real usage data, THEN decide if on-device is worth it.

---

## Architecture Comparison

### Server-Side CV API (v2.0) ⭐ **CHOSEN**

```
User Flow:
1. Take photo (offline OK)
2. Photo saved locally
3. Tap "Identify Species" button (when signal available)
4. Upload to iNaturalist API
5. Receive results (1-2 seconds)
6. Select species → Add tag
```

**Pros:**
- ✅ 80,000+ species coverage
- ✅ Zero app bundle bloat
- ✅ Automatic model updates
- ✅ 2-3 weeks to build
- ✅ Perfect for offline-first workflow

**Cons:**
- ❌ Requires network (acceptable - users have signal at end of day)
- ❌ API rate limits (~1000 req/day free tier - mitigated by caching)
- ❌ 1-2 second latency (acceptable vs instant)

---

### On-Device CoreML (v2.5+) - OPTIONAL

```
User Flow:
1. Take photo
2. Instant on-device inference (<1 second)
3. If high confidence (>70%) → Use local result
4. Else → Fallback to server API
```

**Pros:**
- ✅ Instant results
- ✅ Works 100% offline
- ✅ No rate limits

**Cons:**
- ❌ +50-100MB app bundle
- ❌ 500-1000 species only
- ❌ Model updates = app updates
- ❌ 4-6 weeks to build

**When to build:** After 3-6 months of v2.0 usage, IF users demand offline identification frequently.

---

## Technical Stack

### APIs Used

**Primary: iNaturalist Computer Vision API**
```
Endpoint: POST /v2/computervision/score_image
Input: JPEG image + GPS coordinates (optional)
Output: Top N species matches with confidence scores
Rate Limit: ~1000 requests/day (free tier)
Cost: Free for non-commercial use
```

**Secondary: iNaturalist Data Layer API**
```
/v2/taxa/{id} - Species info, Wikipedia summary
/v2/observations?taxon_id=X&lat=Y&lng=Z - Nearby sightings
/v2/identifications/similar_species?taxon_id=X - Commonly confused species
```

### iOS Frameworks

**Server-Side (v2.0):**
- URLSession (API requests)
- SwiftUI (UI components)
- Combine (reactive bindings)

**On-Device (v2.5+ - Optional):**
- CoreML (inference engine)
- Vision (camera preprocessing)
- URLSession (API fallback)

---

## Implementation Checklist

### Phase 1: Server-Side CV (v2.0) - 2-3 weeks

**Week 1: Core API Integration**
- [ ] Create `PhotoIdentificationService.swift`
- [ ] Implement multipart form request builder
- [ ] Parse CV API response JSON
- [ ] Handle errors (network, rate limit, no results)
- [ ] Implement 24-hour caching (UserDefaults)
- [ ] Write unit tests (5-7 tests)

**Week 2: UI Components**
- [ ] Create `SpeciesMatch` data model
- [ ] Build `SpeciesMatchCard` component
- [ ] Build `SpeciesIdentificationSheet` view
- [ ] Add "Identify" button to photo gallery
- [ ] Integrate into `LogDetailView` / `EditLogView`
- [ ] Loading states & error handling
- [ ] Animation polish

**Week 3: Testing & Polish**
- [ ] Manual testing (10+ species, various conditions)
- [ ] Test offline behavior (deferred identification)
- [ ] Test rate limiting (cache effectiveness)
- [ ] Performance profiling (no UI blocking)
- [ ] Bug fixes
- [ ] Documentation

### Phase 2: Data Enrichment (v2.1) - 1 week

- [ ] Fetch nearby observations count
- [ ] Display "47 sightings within 50km"
- [ ] Fetch similar species
- [ ] Display "Often confused with X"
- [ ] Fetch Wikipedia summary
- [ ] Expandable summary section

### Phase 3: On-Device Model (v2.5+) - OPTIONAL

Only if Phase 1 data shows:
- Users frequently offline for >24 hours
- API rate limits are a problem
- "Instant identification" is top feature request

---

## UX Mockup (v2.0)

```
┌─────────────────────────────────────┐
│  [X]    Identify Species            │
├─────────────────────────────────────┤
│                                      │
│   [Photo Preview - 200px tall]       │
│                                      │
├─────────────────────────────────────┤
│  🌿 Species Suggestions              │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ [📷] Douglas Fir               87%││
│  │      Pseudotsuga menziesii       ││
│  │      [████████████░░] (Confidence)││
│  │      📍 47 observations in 50km  ││
│  │                          [+Add]  ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ [📷] Western Hemlock           11%││
│  │      Tsuga heterophylla          ││
│  │      [███░░░░░░░░░]              ││
│  │                          [+Add]  ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │ [📷] Noble Fir                  2%││
│  │      Abies procera               ││
│  │      [█░░░░░░░░░░░]              ││
│  │                          [+Add]  ││
│  └─────────────────────────────────┘│
│                                      │
│             [Try Again]              │
└─────────────────────────────────────┘
```

**Loading State:**
```
┌─────────────────────────────────────┐
│                                      │
│         [Spinner Animation]          │
│                                      │
│      Analyzing photo...              │
│                                      │
└─────────────────────────────────────┘
```

**Error State:**
```
┌─────────────────────────────────────┐
│                                      │
│      ⚠️                              │
│                                      │
│  Rate limit reached.                 │
│  Try again in an hour.               │
│                                      │
│         [Try Again]                  │
│                                      │
└─────────────────────────────────────┘
```

---

## Key Design Decisions Explained

### 1. Why "Capture-Then-Query" (Not Live Video)?

**Decision:** User taps "Identify" button AFTER taking photo

**Why:**
- Server-side API requires uploading photo (can't stream video)
- Battery-friendly (live video inference drains battery)
- Better UX (user controls when to identify, not anxiously waiting for lock)
- Fits offline-first workflow (capture offline, identify later)

**Alternative rejected:** Live viewfinder identification (only works on-device, requires CoreML)

---

### 2. Why Use Log's GPS (Not Current Location)?

**Decision:** Send log's stored GPS coordinates to API, NOT current location

**Why:**
- User may edit log days later (current location ≠ where photo was taken)
- Species distribution is location-specific (Douglas Fir in Pacific NW, not Florida)
- API uses GPS to filter plausible species (improves accuracy)

**Critical:** Prevent bug where user edits log at home, API thinks photo was taken at home

---

### 3. Why Cache Results for 24 Hours?

**Decision:** Store identification results in UserDefaults for 24 hours

**Why:**
- Avoid redundant API calls for same photo
- Mitigates rate limit issues (1000 req/day free tier)
- Faster UX (instant results on re-open)

**Implementation:**
```swift
// Cache key: "id_<photoFilename>"
// Cache timestamp: "id_<photoFilename>_timestamp"
// TTL: 86400 seconds (24 hours)
```

---

### 4. Why Show Top 5 Matches (Not Just #1)?

**Decision:** Display top 5 species with confidence scores

**Why:**
- AI is not 100% accurate (especially for visually similar species)
- User validation is critical (human confirms AI suggestion)
- Educational (user learns similar species)
- Trust-building (transparency about confidence)

**Example:** Douglas Fir (87%), Western Hemlock (11%), Noble Fir (2%)

User may know it's actually Western Hemlock based on needle arrangement, even if AI is 87% confident it's Douglas Fir.

---

## Success Metrics (How We'll Know This Feature Works)

### Technical Metrics
- **API Success Rate:** >95% of requests return results
- **Response Time:** <3 seconds average (API latency)
- **Cache Hit Rate:** >40% of identifications served from cache
- **Error Rate:** <5% (network, rate limit, no results)

### User Metrics
- **Identification Accuracy:** >80% of users select top result (AI was correct)
- **Usage Frequency:** Users identify 5+ species per week
- **Tag Creation:** 50%+ of identifications result in added tags
- **Repeat Usage:** Users identify multiple photos in same session

### Qualitative Feedback
- Users report: "This is incredibly useful"
- Feature request: "Can this work offline?" (indicates success, consider v2.5)
- No complaints about: "AI is always wrong" (would indicate accuracy issues)

---

## FAQ

### Q: Does this work offline?
**A:** Partially. You can capture photos offline, then identify them later when you have signal. Full offline identification requires the on-device model (v2.5+).

### Q: How accurate is it?
**A:** iNaturalist's CV model is trained on millions of observations. Accuracy varies by species:
- Common species with many training photos: 80-95% accurate
- Rare species or visually similar species: 50-70% accurate
- User validation is critical (AI suggests, human confirms)

### Q: What if the API is wrong?
**A:** User can:
- Select a different result from top 5
- Manually type species name
- Skip identification entirely

AI is assistive, not authoritative.

### Q: Will this cost money?
**A:** Free tier: ~1000 requests/day (more than enough for individual users).
If you hit rate limits, you can:
- Wait 24 hours (resets daily)
- Rely on cached results
- Request higher API limits from iNaturalist (for research use)

### Q: What about privacy?
**A:** Photos are uploaded to iNaturalist's servers for analysis. User must explicitly tap "Identify" button (no automatic uploads). iNaturalist's privacy policy: https://www.inaturalist.org/pages/privacy

### Q: Can I identify plants, insects, birds, mammals?
**A:** Yes! iNaturalist's model covers 80,000+ taxa across:
- Plants
- Birds
- Insects
- Mammals
- Reptiles
- Amphibians
- Fungi
- More

It's not bird-specific (unlike Merlin).

### Q: What if I want to identify bird calls (audio)?
**A:** That's v3.0 using Merlin API. Not in scope for v2.0.

---

## Next Steps

1. **Review this doc** - Confirm architecture decision (server-side first)
2. **Review full implementation plan** - `SPECIES_ID_IMPLEMENTATION_PLAN.md`
3. **Schedule v2.0 development** - 2-3 weeks after v1.0 launch
4. **Gather v1.0 feedback** - Does your wife want species ID? What other users say?
5. **Build Phase 1** - Server-side CV API integration

---

**Questions?** Review `SPECIES_ID_IMPLEMENTATION_PLAN.md` for code examples and detailed architecture.

**Ready to code?** All design decisions made. Just needs implementation.
