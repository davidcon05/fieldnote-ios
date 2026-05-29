# Seek App Contribution Strategy - Building Credibility with iNaturalist

**Goal:** Strengthen EcoJournal's CV API access request by demonstrating commitment to iNaturalist ecosystem
**Repository:** https://github.com/inaturalist/SeekReactNative
**License:** MIT (open source, freely usable)
**Status:** Actively maintained (v2.17.1 released April 2025)

---

## ✅ Why Contributing to Seek Could Help Your Case

### Direct Benefits
1. **Establishes credibility** - Shows genuine interest in iNaturalist's mission, not just extracting value
2. **Demonstrates technical competence** - Proves you can build quality code aligned with iNaturalist standards
3. **Builds relationships** - Get on the radar of iNaturalist maintainers (including Carrie)
4. **Signals long-term commitment** - Not a one-off extraction, but partnership mindset
5. **Improves goodwill** - Contributing before asking for access = better optics

### Indirect Benefits
- Learn iNaturalist's codebase patterns
- Understand their CV model integration (Seek uses on-device + server hybrid)
- Network with other contributors (potential allies/references)
- Add credibility to your resume/portfolio

---

## 📊 Seek Repository Overview

### Tech Stack
- **Framework:** React Native (TypeScript 86%, JavaScript 12%)
- **Database:** Realm (local storage)
- **Testing:** Jest, Detox (E2E)
- **CI/CD:** Fastlane, GitHub Actions
- **Platforms:** iOS + Android

### Activity Level (As of May 2026)
- ✅ **Actively maintained** (6,010 commits, 106 releases)
- ✅ **Recent release:** v2.17.1 (April 16, 2025)
- ✅ **Open issues:** 58
- ✅ **Open PRs:** 1

**Conclusion:** This is a healthy, active project worth contributing to.

---

## 🎯 Contribution Strategy

### Phase 1: Low-Effort, High-Impact Contributions (1-2 weeks)
**Goal:** Get your name in the contributor list with minimal time investment

**Option A: Translation Contributions**
- **Platform:** https://crowdin.com/project/seek
- **Effort:** 2-4 hours
- **Impact:** High (iNaturalist explicitly says "one of the most impactful ways to contribute")
- **Languages:** Spanish? Portuguese? (if your wife is bilingual, she could help)
- **Why:** Shows cultural sensitivity and global reach

**Option B: Documentation Improvements**
- **Target:** README.md, CONTRIBUTING.md, setup guides
- **Effort:** 2-3 hours
- **Impact:** Medium (always appreciated, low-risk PRs)
- **Examples:**
  - Clarify Android NDK setup steps
  - Add troubleshooting section for common Node version errors
  - Update outdated dependency versions in instructions

**Option C: Bug Fixes (Small Issues)**
- **Target:** Browse 58 open issues, find "good first issue" or simple bugs
- **Effort:** 4-8 hours
- **Impact:** Very High (demonstrates technical competence)
- **Strategy:** Look for UI tweaks, typos in code comments, minor refactors

**Recommendation:** Do Option A (translation) + Option B (docs) = 4-6 hours total, gets you in contributor list quickly.

---

### Phase 2: Medium-Effort Contributions (Optional, 1-2 weeks)
**Goal:** Demonstrate deeper technical ability (only if time permits)

**Option D: Feature Implementation**
- **Target:** Find feature request issues in "Feature Requests" forum tagged `Seek`
- **Effort:** 1-2 weeks
- **Impact:** Very High (shows initiative and skill)
- **Warning:** Must claim issue first, coordinate with maintainers

**Option E: Test Coverage Improvements**
- **Target:** Add unit tests for untested components
- **Effort:** 1 week
- **Impact:** High (always valuable, low-risk)

**Recommendation:** Only pursue if you have 1-2 weeks to spare AND want to learn React Native.

---

## 📋 Step-by-Step Contribution Process

### Step 1: Setup Development Environment (1-2 hours)
```bash
# Clone the repo
git clone https://github.com/inaturalist/SeekReactNative.git
cd SeekReactNative

# Install dependencies
npm install

# Setup iOS (Mac only)
cd ios && pod install && cd ..

# Run on iOS simulator
npx react-native run-ios

# Run on Android emulator
npx react-native run-android
```

**Note:** You'll need:
- Node.js (specific version - check their requirements)
- Xcode (for iOS development)
- Android Studio + NDK (for Android development)
- Realm-compatible Node version

### Step 2: Choose a Contribution (30 minutes)
**Translation (Easiest):**
1. Go to https://crowdin.com/project/seek
2. Create account
3. Select language (Spanish, Portuguese, French, etc.)
4. Translate 20-50 strings
5. Submit via Crowdin (no GitHub PR needed)

**Documentation (Easy):**
1. Browse README.md and CONTRIBUTING.md
2. Identify unclear sections or outdated info
3. Fork repo, make changes
4. Submit PR with clear description

**Bug Fix (Medium):**
1. Browse https://github.com/inaturalist/SeekReactNative/issues
2. Look for bugs without assignees
3. Comment: "I'd like to work on this"
4. Wait for maintainer response (1-3 days)
5. Fork repo, create branch `<issue-number>-description`
6. Fix bug, write tests
7. Submit PR within 1-2 weeks

### Step 3: Submit Contribution
**For Translation:**
- Submit via Crowdin (automatic integration)

**For Code/Docs:**
```bash
# Fork repo on GitHub
# Clone your fork
git clone https://github.com/YOUR-USERNAME/SeekReactNative.git

# Create branch
git checkout -b 1234-fix-setup-docs

# Make changes
# ... edit files ...

# Commit with clear message
git commit -m "Docs: Clarify Android NDK setup steps

Fixes #1234

Added troubleshooting section for common CMake errors"

# Push to your fork
git push origin 1234-fix-setup-docs

# Open PR on GitHub
# Fill out description with:
# - What changed
# - Why it's needed
# - Screenshots (if UI changes)
# - Testing done
```

### Step 4: Respond to Review Feedback
- Check GitHub notifications daily
- Address reviewer comments within 24-48 hours
- Be polite, professional, and receptive to feedback

---

## 🎤 Mentioning Contributions in CV API Request

### In Your Email to Carrie Seltzer

**DO Mention:**
```
"To demonstrate our commitment to the iNaturalist community, I've contributed to
the Seek open-source project:
- Translated 50+ UI strings to Spanish (via Crowdin)
- Improved setup documentation for Android developers
- [Link to PR: https://github.com/inaturalist/SeekReactNative/pull/XXX]

We see EcoJournal as a companion app that extends iNaturalist's reach to
field scientists working in remote locations, not as a competitor."
```

**DON'T Mention:**
- "I contributed to get CV API access" (too transactional)
- "I deserve access because I contributed" (entitled tone)
- Contributions that weren't merged yet (wait for PR approval)

---

## ⏱️ Time Investment vs. ROI

| Strategy | Time | ROI | Recommendation |
|----------|------|-----|----------------|
| **Translation (Crowdin)** | 2-4 hrs | High | ✅ Do it (easy win) |
| **Documentation PR** | 2-3 hrs | Medium | ✅ Do it (low risk) |
| **Small bug fix** | 4-8 hrs | High | ✅ If you have time |
| **Feature implementation** | 1-2 weeks | Very High | ⚠️ Only if passionate about React Native |
| **Test coverage** | 1 week | Medium | ⚠️ Lower priority |

**Recommended Investment:** 4-8 hours total (Translation + Docs PR)

**Expected Impact:** 10-20% increase in CV API approval likelihood

---

## 🚫 Contribution Pitfalls to Avoid

### ❌ DON'T:
1. **File GitHub issues for feature requests** - Use iNaturalist Forum instead
2. **Submit PRs without claiming issues first** - Comment on issue before working
3. **Fork Seek for EcoJournal** - iNaturalist discourages forking their apps
4. **Expect fast PR reviews** - Small team, slow review process (weeks, not days)
5. **Argue with maintainers** - They have final say on code acceptance
6. **Mention CV API access in PR description** - Keep it separate

### ✅ DO:
1. **Use iNaturalist Forum for bug reports** - Tag with `Seek`
2. **Claim issues before working** - Comment: "I'd like to work on this"
3. **Follow their workflow** - Branch naming: `<issue-number>-description`
4. **Be patient with reviews** - Small team, many PRs
5. **Accept rejection gracefully** - Not all PRs merge
6. **Contribute for the right reasons** - Genuine interest, not just CV API access

---

## 📧 Email Template for Your Wife

**Subject:** EcoJournal App - Computer Vision API Access Request

**To:** carrie@inaturalist.org

**Body:**
```
Hi Carrie,

My name is [Wife's Name], and I'm reaching out on behalf of my husband David,
who is developing EcoJournal, an offline-first GPS-tagged field journal app
for iOS designed for environmental scientists like myself.

[NOTE: Adjust if your wife is NOT an environmental scientist - use her actual
background/credentials here. If she's a field scientist, this is GOLD.]

**About EcoJournal:**
EcoJournal helps field researchers document observations in remote locations
where cell service is unreliable. The app captures GPS coordinates, weather
conditions, photos, and audio memos—all stored locally on the device.

**Why We're Requesting CV API Access:**
We'd like to add AI-powered species identification using iNaturalist's
Computer Vision API. This feature would help researchers (like me) quickly
identify species in the field without needing extensive taxonomic expertise.

**Our Commitment to iNaturalist:**
To show we're serious about being a positive member of the iNaturalist
community, David has already contributed to the Seek open-source project:
- [Specific contribution #1]
- [Specific contribution #2]
- [Link to PR if merged]

We see EcoJournal as a companion app that extends iNaturalist's reach, not
a competitor. Our users are field scientists working in places where even
the iNaturalist app struggles (no cell service for days).

**Estimated API Usage:**
- Conservative: 5,000-50,000 requests/month
- We'll implement 24-hour caching to minimize redundant calls
- Offline-first: Users capture photos offline, identify later when signal returns

**Use Case:**
I personally would use this app for [specific field work your wife does].
Right now I use [current app/method], but EcoJournal would be better because
[specific reason related to offline capability or GPS tagging].

**Questions:**
1. Is CV API access available for apps like EcoJournal?
2. What is the approval process and timeline?
3. Are there usage fees? What is the pricing structure?
4. Are there restrictions on use cases or user types?

We're happy to provide additional details, mockups, or technical
documentation. Thank you for considering our request.

Best regards,
[Wife's Name]
[Email: your-wife-email@example.com]
David Contreras (Developer): david.b.contreras@gmail.com

GitHub: https://github.com/davidcon05
```

**Why Your Wife Should Send It:**
1. **Field scientist credibility** - If she's an environmental scientist, that's huge
2. **Non-technical language** - Carrie may appreciate less jargon
3. **User perspective** - Shows real user demand, not just developer interest
4. **Partnership tone** - Less "I want access" and more "we want to help your mission"

---

## 🎯 Alternative: Direct Outreach to Seek Maintainers

### GitHub Contributors to Connect With
Check recent commits to Seek for active maintainers:
- Look for @inaturalist.org email addresses
- Check PR reviewers/approvers
- Engage politely in issue discussions

### iNaturalist Forum Strategy
1. Create iNaturalist account
2. Post in "Feature Requests" category
3. Title: "Seek-like Species ID for Field Journal Apps"
4. Content: Describe EcoJournal, ask about CV API access, mention contributions
5. Tag relevant maintainers if you know their forum handles

**Why:** Public visibility might pressure/incentivize approval OR surface alternative solutions.

---

## 📊 Success Metrics

### Contribution Success
- [ ] 1+ merged PR or translation contribution
- [ ] GitHub profile shows "Contributor" badge on Seek repo
- [ ] Positive interaction with iNaturalist maintainers

### CV API Request Success (After Contributing)
- [ ] Email sent to carrie@inaturalist.org mentioning contributions
- [ ] Response received within 2 weeks
- [ ] Access granted OR clear alternative path provided

---

## ⚠️ Realistic Expectations

**Best Case (20% likelihood):**
- Contributions impress Carrie
- CV API access granted
- EcoJournal launches with full 80,000+ taxa identification

**Moderate Case (50% likelihood):**
- Contributions acknowledged but don't significantly impact decision
- Access granted based on app merits alone (or denied)
- Contributions improve relationship for future requests

**Worst Case (30% likelihood):**
- Contributions ignored or not valued
- CV API access denied
- Time spent on Seek contributions = sunk cost

**Mitigation:** Keep contribution time low (4-8 hours) to minimize risk.

---

## 🎬 Action Plan

### Before v1.0 Launch (This Weekend - Next 2 Weeks)
- [ ] Fork Seek repo
- [ ] Set up development environment
- [ ] Make 1-2 small contributions (translation + docs)
- [ ] Submit PRs, wait for review

### Week 2-4 After v1.0 Launch
- [ ] Contributions merged (hopefully)
- [ ] Wife emails carrie@inaturalist.org mentioning contributions
- [ ] Wait for response (1-2 weeks)

### Week 4-6 After v1.0 Launch
- [ ] If approved: Start v2.0 development (CV API integration)
- [ ] If denied: Pivot to on-device small model or PlantNet API

---

## 💡 Final Recommendation

**YES, contribute to Seek** - but keep it low-effort (4-8 hours max).

**Priority:**
1. **Translation** (2-4 hours) - Easiest, high impact
2. **Documentation PR** (2-3 hours) - Low risk, shows care
3. **Small bug fix** (optional, 4-8 hours) - If you want to impress

**DON'T:**
- Spend 1-2 weeks on feature development (ROI too low)
- Expect contributions to guarantee CV API access (helps, but not decisive)
- Mention CV API in contribution communications (keep separate)

**Timeline:**
- Contribute this week or next (before emailing Carrie)
- Wait for PRs to merge (1-2 weeks)
- Then email Carrie mentioning contributions as evidence of commitment

---

**Status:** Ready to execute
**Estimated Time Investment:** 4-8 hours
**Expected ROI:** 10-20% increase in CV API approval likelihood
**Risk:** Low (minimal time investment, genuine learning experience)

**Next Steps:**
1. Fork Seek repo: https://github.com/inaturalist/SeekReactNative
2. Choose contribution: Translation (Crowdin) + Documentation PR
3. Submit contributions this week
4. Wait for merge (1-2 weeks)
5. Email Carrie with contributions as credentials

**Last Updated:** May 26, 2026
**Document Owner:** David Contreras
