# iNaturalist Computer Vision API - Access Guide

**Last Updated:** May 26, 2026
**Status:** ⚠️ **API is NOT publicly available** - Requires approval
**Contact Required:** Yes - Must request access from iNaturalist team

---

## 🚨 CRITICAL FINDING

**The iNaturalist Computer Vision API is NOT publicly available.**

While the API endpoint exists (`POST /v1/computervision/score_image`), it is:
- ❌ Not openly accessible to external developers
- ❌ Not documented in public API docs
- ✅ Used internally by iNaturalist's website and mobile apps
- ✅ Available to select organizations/researchers via fee-based restricted access program

---

## 📞 Official Contact Information

### Primary Contact for CV API Access
**Carrie Seltzer**
- **Email:** carrie@inaturalist.org
- **Role:** Responsible for granting restricted CV API access
- **Purpose:** Contact for research or citizen science applications

### General iNaturalist Support
**Email:** help@inaturalist.org
- **Use For:** General inquiries, support tickets, non-API questions
- **Note:** Tickets with specific details get priority

### Physical Address
iNaturalist
PO Box 150357
San Rafael, CA 94915, US

### Community Resources
- **Forum:** https://forum.inaturalist.org/
- **GitHub Issues:** https://github.com/inaturalist/iNaturalistAPI/issues
- **Developer Docs:** https://www.inaturalist.org/pages/developers
- **API v2 Docs:** https://api.inaturalist.org/v2/docs/

---

## 🔒 CV API Access Options

### Option 1: Restricted Access Program (Recommended for EcoJournal)
**What It Is:** Fee-based limited access for approved organizations/researchers

**How to Apply:**
1. Email: carrie@inaturalist.org
2. Subject: "EcoJournal iOS App - Computer Vision API Access Request"
3. Include:
   - App description (GPS-tagged field journal)
   - Use case (species identification for field scientists)
   - Target users (environmental scientists, researchers, hobbyists)
   - Estimated API volume (requests/day, requests/month)
   - Non-commercial status (personal learning project or research tool)
   - Why iNaturalist CV is essential (80,000+ taxa, community-verified)

**Expected Response:** Unknown (no public documentation on approval timeline)

**Cost:** Fee-based (exact pricing not publicly documented)

---

### Option 2: Use "Hidden" Unauthenticated Endpoint (Not Recommended)
**What It Is:** The CV API technically exists at `POST /v1/computervision/score_image` and MAY work without explicit approval

**Risks:**
- ⚠️ Not officially supported
- ⚠️ Could be blocked at any time
- ⚠️ No SLA or reliability guarantees
- ⚠️ Violates iNaturalist's intended access model
- ⚠️ Potential legal/ethical issues

**Why This Could Work:**
- iNaturalist's mobile apps use anonymous JWTs for unauthenticated users
- Some developers report successful undocumented usage
- Rate limits may still apply (100 req/min, 10,000 req/day)

**Recommendation:** **Do NOT use this approach.** Contact iNaturalist first for legitimate access.

---

### Option 3: On-Device Small Model (500 Taxa)
**What It Is:** iNaturalist provides "small" models trained on ~500 taxa for on-device use

**How to Get It:**
- Public models available (exact download location unclear)
- Check: https://github.com/inaturalist/inatVisionAPI
- Designed for testing and offline apps (like Seek)

**Pros:**
- ✅ 100% offline
- ✅ No API approval needed
- ✅ Free to use

**Cons:**
- ❌ Only 500 taxa (vs 80,000+ on server)
- ❌ Limited accuracy compared to full model
- ❌ Large app bundle size

**Use Case:** Fallback option if CV API access is denied

---

### Option 4: Alternative AI APIs
If iNaturalist denies access, consider alternatives:

**PlantNet API**
- Specialized in plant identification
- Public API available
- ~30,000 plant species
- Website: https://plantnet.org/

**Google Cloud Vision API - Image Labeling**
- General object/animal detection
- Not species-specific (lower accuracy for wildlife)
- Requires Google Cloud account
- Cost: Pay-per-request

**Custom CoreML Model (Open Source)**
- Train using iNaturalist's open dataset
- HuggingFace or Kaggle community models
- Full control but high maintenance burden

**Recommendation:** Start with iNaturalist request (Option 1). If denied, evaluate PlantNet or custom model.

---

## 📋 iNaturalist API v2 - Rate Limits & Authentication

### Rate Limits (General API, NOT CV-specific)
**Official Limits:**
- **100 requests per minute** (maximum)
- **60 requests per minute** (recommended to avoid throttling)
- **10,000 requests per day** (soft limit)

**Media Download Limits:**
- **5 GB per hour** (media downloads)
- **24 GB per day** (media downloads)
- **Exceeding may result in permanent block**

**Note:** CV API rate limits may differ (not publicly documented).

### Authentication
**For General API (Observations, Taxa, etc.):**
- OAuth2 provider
- JWT tokens (expire after 24 hours)
- Get token: `POST https://www.inaturalist.org/users/api_token` (requires OAuth)

**For CV API:**
- JWT required (even for anonymous requests)
- Mobile apps use anonymous JWTs
- Exact auth flow for third-party apps unclear (must request from iNaturalist)

**Auth Flows Supported:**
- Authorization Code
- Resource Owner Password Credentials
- PKCE (Proof Key for Code Exchange)

---

## 📧 Email Template for CV API Access Request

**Subject:** EcoJournal iOS App - Computer Vision API Access Request

**To:** carrie@inaturalist.org

**Body:**
```
Hi Carrie,

My name is David Contreras, and I'm developing EcoJournal, an offline-first GPS-tagged field journal app for iOS designed for environmental scientists and field researchers.

I'm writing to request access to iNaturalist's Computer Vision API for species identification within the app.

**About EcoJournal:**
- Platform: iOS 17+ (native SwiftUI app)
- Purpose: Help field scientists document observations with GPS, weather, photos, and audio memos
- Target Users: Environmental scientists, ecologists, wildlife researchers, and nature enthusiasts
- Status: v1.0 MVP complete, awaiting App Store launch (7-8 weeks)

**Intended Use of CV API:**
- Feature: AI-powered species identification from photos
- User Flow: User captures photo offline → Taps "Identify Species" button when signal returns → App sends photo to CV API → User selects correct species from top 5 results
- Integration: Results auto-populate log tags, fully searchable across journals
- Offline-First: Photos captured offline, identification deferred until connectivity (perfect for remote fieldwork)

**Why iNaturalist CV is Essential:**
- 80,000+ taxa coverage (far exceeds alternatives)
- Community-verified training data (millions of observations)
- Proven accuracy (same model as iNaturalist mobile apps)
- Aligns with our mission: help field scientists contribute to biodiversity research

**Estimated API Volume:**
- Conservative: 100-500 requests/month per active user
- Target Users (Year 1): 50-100 active users
- Total: 5,000-50,000 requests/month
- We will implement 24-hour caching to minimize redundant calls

**Non-Commercial Status:**
- Personal learning project and research tool
- Free app (no ads, no subscription, no monetization planned)
- May evolve to support research institutions (university field courses)

**Technical Details:**
- API Endpoint: POST /v1/computervision/score_image (or v2 if available)
- Authentication: Will implement OAuth2 + JWT as required
- Rate Limiting: Will respect 60 req/min limit with client-side throttling
- Error Handling: Graceful fallback to manual tagging if API unavailable

**Timeline:**
- v1.0 Launch: 7-8 weeks (June/July 2026)
- v2.0 (Species ID feature): 2-3 weeks post-launch (August 2026)
- Would like to finalize API access before implementing v2.0

**Questions:**
1. Is restricted CV API access available for apps like EcoJournal?
2. What is the application process and timeline?
3. Are there usage fees? If so, what is the pricing structure?
4. Are there any restrictions on use cases or user types?
5. Should I apply through a different channel (RapidAPI, formal partnership)?

I'm happy to provide additional details about the app, technical architecture, or mockups of the species identification feature.

Thank you for considering this request. I greatly appreciate iNaturalist's mission and would love to help extend its impact to field scientists working in remote locations.

Best regards,
David Contreras
Email: david.b.contreras@gmail.com
GitHub: https://github.com/davidcon05
Location: Raleigh, NC
```

---

## ⏱️ Timeline & Next Steps

### Before Contacting iNaturalist
- [ ] Launch v1.0 (establish credibility)
- [ ] Gather user feedback ("Do users want species ID?")
- [ ] Finalize estimated API volume (based on real usage)
- [ ] Decide: Commercial vs. Non-Commercial app (affects approval likelihood)

### Contact Timeline
**Option A: Contact Now (Proactive)**
- **Pros:** Establishes relationship early, may get approval by v2.0 dev time
- **Cons:** No user data to support request, unproven app

**Option B: Contact After v1.0 Launch (Recommended)**
- **Pros:** Proven app with real users, stronger case for approval
- **Cons:** 2-3 week delay for CV API implementation (waiting for approval)

**Recommendation:** Contact 2-4 weeks after v1.0 launch, once you have:
- 20-50 active users
- User feedback requesting species ID
- Download metrics (proof of adoption)

### If Approved
- [ ] Receive API credentials (API key or OAuth client ID)
- [ ] Implement authentication flow
- [ ] Build PhotoIdentificationService (2-3 weeks)
- [ ] Test with production API
- [ ] Launch v2.0 with species identification

### If Denied
- [ ] Evaluate PlantNet API (plants only)
- [ ] Evaluate on-device small model (500 taxa)
- [ ] Consider custom CoreML model (HuggingFace/Kaggle)
- [ ] Build v2.0 with alternative solution

---

## 🛡️ Legal & Ethical Considerations

### Using "Hidden" API Without Permission
**Legal Risk:** Low (no explicit ToS violation documented)
**Ethical Risk:** High (violates iNaturalist's intended access model)
**Technical Risk:** Medium (could be blocked, rate-limited, or deprecated)

**iNaturalist's Perspective:**
- Full CV model kept private due to IP concerns
- All-rights-reserved photos (users retain rights)
- Organizational policy restricts public access

**Recommendation:** Do NOT use without explicit permission. Request access properly.

### If Access is Granted
**Terms to Clarify:**
- [ ] Attribution requirements (must credit iNaturalist?)
- [ ] Data usage restrictions (can we cache results?)
- [ ] Privacy policy requirements (disclose photo uploads?)
- [ ] Rate limit enforcement (hard caps vs soft recommendations?)
- [ ] SLA or uptime guarantees (none expected for free tier)

---

## 📊 Success Criteria for API Access Request

### Strong Application Indicators
- ✅ Non-commercial or research-focused app
- ✅ Aligns with iNaturalist's mission (biodiversity, citizen science)
- ✅ Proven user base (50+ active users)
- ✅ Respectful API usage (caching, rate limiting, error handling)
- ✅ Transparent use case (no hidden commercial motives)

### Weak Application Indicators
- ❌ Commercial app with monetization (ads, subscriptions)
- ❌ Competing directly with iNaturalist
- ❌ Unclear use case or vague description
- ❌ No user base (purely speculative app)
- ❌ High-volume usage without mitigation (millions of requests)

**EcoJournal's Position:** Strong application (non-commercial, research-aligned, offline-first, respectful usage)

---

## 🤔 Alternative Strategies

### Strategy 1: Partnership Approach
**Pitch:** "EcoJournal is an iNaturalist companion app for offline fieldwork"

**Benefits:**
- Frame as extending iNaturalist's reach (not competing)
- Emphasize unique value: offline-first for remote locations
- Offer to integrate iNaturalist account sign-in
- Offer to auto-submit observations to iNaturalist (if user consents)

### Strategy 2: Research Institution Sponsorship
**Pitch:** Partner with a university or research org to apply on behalf of EcoJournal

**Benefits:**
- Institutional credibility
- Academic research use case (stronger than personal project)
- Access to funding for API fees

### Strategy 3: RapidAPI Marketplace
**Endpoint:** https://rapidapi.com/inaturalist-inaturalist-default/api/visionapi/

**Unknown:**
- Is this official?
- What are the costs?
- Does this provide full CV model or small model?

**Action:** Investigate RapidAPI listing before contacting Carrie directly

---

## 📚 Related Documentation

**Internal Docs:**
- `SPECIES_ID_IMPLEMENTATION_PLAN.md` - Full technical architecture (assumes CV API access)
- `SPECIES_ID_QUICK_REFERENCE.md` - Executive summary
- `SPECIES_IDENTIFICATION_API_COMPARISON.md` - API research (original)

**External Resources:**
- iNaturalist API v2 Docs: https://api.inaturalist.org/v2/docs/
- iNaturalist Developers Page: https://www.inaturalist.org/pages/developers
- iNaturalist Community Forum: https://forum.inaturalist.org/
- iNaturalist GitHub (API): https://github.com/inaturalist/iNaturalistAPI
- Vision API GitHub: https://github.com/inaturalist/inatVisionAPI

---

## ✅ Action Items

### Immediate (Before v1.0 Launch)
- [ ] Bookmark this document
- [ ] No action needed yet (wait for v1.0 launch)

### Week 2-4 After v1.0 Launch
- [ ] Gather user feedback ("Would you use species identification?")
- [ ] Calculate actual API volume estimate (based on user behavior)
- [ ] Draft email to Carrie Seltzer (use template above)
- [ ] Send email requesting CV API access
- [ ] Monitor email for response (follow up after 1 week if no reply)

### If Approved
- [ ] Review terms, pricing, restrictions
- [ ] Implement authentication flow
- [ ] Build v2.0 with CV API integration (2-3 weeks)

### If Denied or No Response After 2 Weeks
- [ ] Evaluate Plan B (PlantNet, on-device model, custom CoreML)
- [ ] Post on iNaturalist Forum asking for guidance
- [ ] Consider RapidAPI marketplace option
- [ ] Pivot to manual tagging + autocomplete (no AI) for v2.0

---

**Status:** ⚠️ Awaiting v1.0 launch before contacting iNaturalist
**Next Milestone:** Email carrie@inaturalist.org 2-4 weeks after v1.0 launch
**Confidence Level:** Medium (approval uncertain, but strong case)
**Fallback Plan:** On-device small model (500 taxa) or manual tagging

**Last Updated:** May 26, 2026
**Document Owner:** David Contreras
