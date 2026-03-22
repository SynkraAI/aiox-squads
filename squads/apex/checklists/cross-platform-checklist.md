# Cross-Platform Parity Checklist — Apex Squad

> Reviewer: cross-plat-eng
> Purpose: Validate consistent behavior and appearance across all target platforms.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Visual Parity

- [ ] Same design tokens applied across all platforms (web, iOS, Android)
- [ ] Spacing and typography consistent — using shared token definitions
- [ ] Platform-appropriate interactions maintained (e.g., back gesture on iOS, back button on Android)
- [ ] Colors render consistently across platform color spaces
- [ ] Icons are consistent in size, weight, and style across platforms
- [ ] Component dimensions and proportions match across platforms
- [ ] Screenshots compared side-by-side for key screens

---

## 2. Behavioral Parity

- [ ] Same user flows available on all target platforms
- [ ] Same error handling and error messages across platforms
- [ ] Same data flow and state management patterns
- [ ] Form validation behavior consistent
- [ ] Navigation patterns follow platform conventions while maintaining consistency
- [ ] Push notifications behave equivalently across platforms
- [ ] Offline behavior consistent (if applicable)

---

## 3. Code Sharing

- [ ] Shared packages used for business logic and utilities
- [ ] Platform-specific code isolated in dedicated files (`.web.ts`, `.native.ts`, `.ios.ts`, `.android.ts`)
- [ ] No web-only patterns leaked into shared code (`window`, `document`, DOM APIs)
- [ ] No native-only patterns leaked into shared code
- [ ] Shared types and interfaces used across platforms
- [ ] API client code shared — not duplicated per platform
- [ ] Configuration and constants shared from single source of truth

---

## 4. Testing

- [ ] Tested on all target platforms (web, iOS, Android)
- [ ] Platform-specific edge cases identified and covered
- [ ] Shared code has platform-agnostic unit tests
- [ ] Platform-specific code has targeted integration tests
- [ ] E2E tests run on each platform (Detox, Playwright, etc.)
- [ ] Performance benchmarks compared across platforms
- [ ] Accessibility tested on each platform (VoiceOver, TalkBack, screen readers)

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Platforms Tested | |
| Result | APPROVED / BLOCKED |
| Notes | |
