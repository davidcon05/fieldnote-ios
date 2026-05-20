# Species Identification API Comparison for Field Note App

**Use Case:** Personal field note app for wife - needs reliable, unlimited (or generous) usage without hitting rate limits

**Last Updated:** May 10, 2026

---

## Executive Summary

For a personal app with a single user, **Naturalis NIA API** is the recommended choice due to:
- Direct image-to-species identification (no observation creation required)
- More generous free tier and easier path to full access
- Clean API designed specifically for third-party integration
- No complex OAuth requirements for basic usage

**iNaturalist API** is better suited for community-driven apps where you want to leverage crowd-sourced identifications and contribute back to the biodiversity community.

---

## Detailed Comparison

### 1. Naturalis NIA (Nature Identification API)

#### Overview
AI-based species identification service developed by Observation International, Naturalis, and Intel Corp. Powers 6 European biodiversity portals and performs 30-50 million identifications annually.

#### API Access & Documentation
- **Main Documentation:** https://multi-source.docs.biodiversityanalysis.eu/
- **Public Endpoint:** https://multi-source.identify.biodiversityanalysis.eu/v2/observation/identify
- **API Version:** v2 (current), v1 (legacy)

#### Coverage
- Plants and animals
- Strong focus on European species
- Hierarchical taxonomic identification (from kingdom to species level)
- High accuracy AI models using deep learning

#### Pricing & Limits

**Free Tier (Public Endpoint):**
- 10 identifications per day per user
- No registration required for testing
- Perfect for initial development and prototyping

**Full Access (Token-based):**
- Request access via email: info@observation.org
- Contact for pricing/limits: Naturalis colleague Ni Yan
- Designed for production apps with higher volume needs

#### How It Works
```
1. Send image via HTTP POST
2. Receive JSON response with:
   - Species identification
   - Confidence score
   - Taxonomic hierarchy
   - Bounding boxes (if applicable)
```

#### Integration Complexity
- **Low** - Simple REST API
- No OAuth required for basic usage
- Well-documented endpoints
- Example code available in curl and Python
- Third-party request collections available on GitHub

#### Pros
✅ Direct image → species ID (no observation creation)
✅ Clean, purpose-built API for third-party apps
✅ Generous free tier for testing (10/day)
✅ Easy to request full production access
✅ No complex authentication for basic use
✅ High performance (30-50M identifications/year)
✅ Supports both identification and localization (bounding boxes)
✅ Good for European biodiversity

#### Cons
❌ Smaller community compared to iNaturalist
❌ Less comprehensive global species coverage
❌ Fewer ancillary features (no range maps, field guides, etc.)
❌ Limited ecosystem (primarily European portals)

#### Best For
- Personal apps with low-to-medium volume
- Direct image recognition without social features
- European species focus
- Apps that need clean separation from observation platforms

---

### 2. iNaturalist API

#### Overview
World's largest community science biodiversity platform. Leverages millions of community-identified observations to power computer vision models. Used by iNaturalist.org, mobile apps, and Seek app.

#### API Access & Documentation
- **Main API:** https://api.inaturalist.org/
- **API Docs (Swagger):** https://api.inaturalist.org/docs
- **Developer Page:** https://www.inaturalist.org/pages/developers
- **Recommended Practices:** https://www.inaturalist.org/pages/api+recommended+practices
- **GitHub (API):** https://github.com/inaturalist/iNaturalistAPI
- **GitHub (Vision Models):** https://github.com/inaturalist/inatVisionAPI

#### Coverage
- **Comprehensive** - Entire tree of life (all animals, plants, insects, fungi)
- 55,000+ taxa in latest computer vision model
- Global species coverage
- Continuously updated with community contributions

#### Pricing & Limits

**General API (Free):**
- **Rate Limit:** 100 requests/minute (recommended: 60/min)
- **Daily Limit:** ~10,000 API requests/day
- **Bandwidth Limit:**
  - 5 GB media/hour
  - 24 GB media/day
- OAuth2 authentication required for some features

**Computer Vision API (Restricted):**
- **Free tier:** 200 CV requests/month (after approval)
- Must request access separately
- Not fully public - primarily for internal use
- "Hidden" API with limited documentation

**Important Notes:**
- API is for app development, NOT data scraping
- For bulk data needs, use datasets (17 GB GBIF DarwinCore Archive)
- Permanent blocks possible for excessive media downloads

#### How It Works
```
OPTION 1: Create Observation (Recommended)
1. Upload image as observation
2. Get computer vision suggestions automatically
3. Community members provide additional IDs
4. Observations become research-grade with multiple IDs

OPTION 2: Computer Vision API (Limited)
1. Request CV API access
2. Send image to CV endpoint
3. Receive species suggestions with confidence scores
4. Limited to 200 requests/month
```

#### Integration Complexity
- **Medium to High**
- OAuth2 authentication (Authorization Code, PKCE, or Resource Owner flows)
- More complex if using CV API directly
- Simpler if creating observations
- Multiple client libraries available:
  - Python: pyinaturalist (https://github.com/pyinat/pyinaturalist)
  - R: rinat (https://docs.ropensci.org/rinat/)
  - Node.js: Official API code available

#### Pros
✅ Most comprehensive species coverage (55,000+ taxa)
✅ Global biodiversity data
✅ Community validation of identifications
✅ Rich ecosystem (range maps, field guides, similar observations)
✅ Continuously improving via community contributions
✅ Large, active developer community
✅ Well-maintained client libraries
✅ Educational value (contribute to citizen science)
✅ Generous API limits for general usage (10k/day)

#### Cons
❌ Computer Vision API is restricted (200/month free)
❌ Must create observations to get CV suggestions (can't just send image)
❌ More complex OAuth authentication
❌ Rate limits may be restrictive for heavy image processing
❌ Designed for community platform, not standalone image recognition
❌ Privacy concerns (observations are public by default)
❌ Bandwidth limits on media downloads

#### Best For
- Apps with community/social features
- Contributing to citizen science
- Apps needing comprehensive global species data
- Educational apps
- Research projects
- Apps with moderate usage that fit within rate limits

---

## Side-by-Side Quick Reference

| Feature | Naturalis NIA | iNaturalist |
|---------|---------------|-------------|
| **Species Coverage** | Plants & Animals | All life (55k+ taxa) |
| **Geographic Focus** | European-focused | Global |
| **Free Tier** | 10 IDs/day (public) | 10k requests/day (general API) |
| **CV API Access** | Public + token-based | Restricted (200/month) |
| **Authentication** | None (public), Simple token | OAuth2 required |
| **Integration Complexity** | Low | Medium-High |
| **Direct Image → ID** | ✅ Yes | ❌ No (must create observation) |
| **Community Features** | ❌ No | ✅ Yes |
| **Production Access** | Email request | Built-in (with limits) |
| **Client Libraries** | Limited | Python, R, Node.js |
| **Best for Personal App** | ✅ Excellent | ⚠️ Good (with caveats) |

---

## Recommendation for Your Use Case

### Primary Choice: **Naturalis NIA API** ⭐

**Why:**
1. **Perfect for single-user app** - 10 IDs/day should be plenty for casual field note usage
2. **Simple integration** - No OAuth complexity for getting started
3. **Direct image recognition** - Send image, get species ID immediately
4. **Easy scaling** - If wife uses it more heavily, simply email to request full access
5. **No privacy concerns** - Not creating public observations
6. **Clean separation** - API built specifically for this use case

**Implementation Plan:**
1. Start with public endpoint (10/day) during development
2. Monitor actual daily usage
3. If approaching limit, request token-based access (likely free or very low cost for personal use)
4. Email info@observation.org with your use case

### Fallback: **iNaturalist API**

**When to consider:**
- If Naturalis NIA doesn't have good coverage for your wife's region (non-European)
- If you want community validation of identifications
- If field notes should become observations for citizen science
- If 10k API requests/day is appealing (though most are non-CV endpoints)

**Caveat:**
- Direct CV access is limited to 200/month
- Would need to create observations (public by default) to get unlimited CV suggestions
- More complex to implement

---

## Implementation Examples

### Naturalis NIA - Basic Usage

```python
import requests
import json

# Public endpoint (10/day limit)
url = "https://multi-source.identify.biodiversityanalysis.eu/v2/observation/identify"

# Send image for identification
with open("animal_photo.jpg", "rb") as image_file:
    files = {"image": image_file}
    response = requests.post(url, files=files)

# Parse results
if response.status_code == 200:
    results = response.json()
    print(f"Species: {results['species']}")
    print(f"Confidence: {results['confidence']}")
    print(f"Taxonomy: {results['taxonomy']}")
else:
    print(f"Error: {response.status_code}")
```

### iNaturalist - Creating Observation (Unlimited CV suggestions)

```python
from pyinaturalist import create_observation

# Requires OAuth token
observation = create_observation(
    species_guess="Unknown bird",
    photos=["bird_photo.jpg"],
    latitude=40.7128,
    longitude=-74.0060,
    observed_on="2026-05-10"
)

# Computer vision suggestions are automatically added
cv_suggestions = observation['taxon_suggestions']
for suggestion in cv_suggestions:
    print(f"{suggestion['taxon']['name']}: {suggestion['vision']}")
```

---

## Additional Resources

### Naturalis NIA
- Documentation: https://multi-source.docs.biodiversityanalysis.eu/
- Public Endpoint Guide: https://multi-source.docs.biodiversityanalysis.eu/examples/public_endpoint/
- Contact: info@observation.org
- GitHub Examples: https://github.com/EibSReM/RequestCollectionComputerVisionAPIs

### iNaturalist
- API Docs: https://api.inaturalist.org/docs
- Developer Guide: https://www.inaturalist.org/pages/developers
- Forum: https://forum.inaturalist.org/
- Python Client: https://github.com/pyinat/pyinaturalist
- CV Model Info: https://www.inaturalist.org/pages/computer_vision_demo
- Small Models (500 taxa): https://github.com/inaturalist/inatVisionAPI

### Alternative Options
- **PlantNet API:** https://plantnet.org/ (plants only, 100M+ IDs performed)
- **Kindwise Insect.id:** https://www.kindwise.com/insect-id (insects only, 1 credit/ID, 100 free for testing)
- **Train Your Own:** iNaturalist data on Amazon Open Data Program

---

## Next Steps

1. **Start with Naturalis NIA public endpoint** (10/day free)
2. **Build basic image upload → species ID flow** in your iOS app
3. **Track daily usage** for a week to see if 10/day is sufficient
4. **Request production access** if needed (email info@observation.org)
5. **Consider iNaturalist** as fallback if species coverage is insufficient

## Questions to Consider

- What region does your wife primarily observe wildlife? (affects species coverage)
- How many identifications per day is realistic? (1-2 or 10+?)
- Does she want to contribute to citizen science? (iNaturalist benefit)
- Privacy preference: private notes vs. public observations?

---

**Document maintained for Field Note app development**
**Project:** `/Users/davidcontreras/AppleXCodeProjects/fieldnote/`
