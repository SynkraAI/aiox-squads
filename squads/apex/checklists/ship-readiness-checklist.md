# Ship Readiness Checklist — Apex Squad

> Purpose: Final quality gate before any feature ships to production.
> Owner: apex-lead + @qa
> Rule: ALL items must be checked. Any FAIL or BLOCKED item prevents ship.
> Budget Reference: ALL thresholds from `data/performance-budgets.yaml` (SSOT)
> Enforcement: Items marked [AUTO] have automated verification commands.
>              Items marked [MANUAL] require human verification.
>              Automated items MUST be run — manual checkbox alone is not sufficient.

---

## 1. Performance

### Core Web Vitals (Lighthouse CI / CrUX) — ref: data/performance-budgets.yaml
- [ ] [AUTO] LCP (Largest Contentful Paint) <= 1.2s on mobile (Apex ultra-premium)
  - `npm run lighthouse:ci -- --lcp=1200 --exit-code`
- [ ] [AUTO] INP (Interaction to Next Paint) <= 200ms (Good threshold)
  - `npm run lighthouse:ci -- --inp=200 --exit-code`
- [ ] [AUTO] CLS (Cumulative Layout Shift) <= 0.1 (Good threshold)
  - `npm run lighthouse:ci -- --cls=0.1 --exit-code`
- [ ] [AUTO] FCP (First Contentful Paint) <= 1.0s
  - `npm run lighthouse:ci -- --fcp=1000 --exit-code`
- [ ] [AUTO] TTFB (Time to First Byte) <= 600ms
  - `npm run lighthouse:ci -- --ttfb=600 --exit-code`
- [ ] [AUTO] Lighthouse Performance score >= 90 on mobile
  - `npm run lighthouse:ci -- --performance=90 --exit-code`

### Bundle Size
- [ ] [AUTO] JS bundle delta verified — within 50KB gzipped budget
  - `npm run analyze:bundle -- --max-delta=50 --exit-code`
- [ ] [MANUAL] New dependencies audited — no library added without approval from apex-lead
- [ ] [AUTO] Tree-shaking verified — no full-library imports (e.g., `import * from 'lodash'`)
  - `grep -rn "import \* from" packages/ --include='*.ts' --include='*.tsx' | wc -l` (must be 0)
- [ ] [AUTO] Images: next/image used, correct formats (AVIF/WebP), lazy loading applied
  - `grep -rn '<img ' packages/ --include='*.tsx' | grep -v 'next/image' | wc -l` (must be 0)
- [ ] [MANUAL] Fonts: variable fonts used, `font-display: swap` set, subset applied
- [ ] [AUTO] Critical CSS inlined; non-critical CSS deferred
  - `npm run build && grep -c 'render-blocking' .next/analyze/report.html` (must be 0)
- [ ] [AUTO] No unused CSS shipped (purge confirmed in build output)
  - `npm run build -- --analyze`
- [ ] [MANUAL] Code-splitting applied to routes and heavy components (dynamic imports)

---

## 2. Accessibility

### Automated
- [ ] [AUTO] axe-core score: 0 violations (run via `@axe-core/playwright` in CI)
  - `npm run test:a11y -- --exit-code`
- [ ] [MANUAL] WAVE or Deque axe browser extension manual pass on all new screens
- [ ] [AUTO] No ARIA misuse flagged (invalid roles, missing required attributes)
  - `npm run test:a11y -- --rule=aria-* --exit-code`

### Keyboard Navigation
- [ ] [MANUAL] All interactive elements reachable via Tab key
- [ ] [MANUAL] Logical focus order matches visual layout
- [ ] [MANUAL] No focus traps outside of modal/dialog contexts
- [ ] [MANUAL] All modals and dialogs trap focus correctly and release on close
- [ ] [AUTO] Skip-to-content link present and functional on all pages
  - `grep -rn 'skip-to-content\|SkipNav\|skipLink' apps/ --include='*.tsx' | wc -l` (must be > 0)
- [ ] [MANUAL] All custom keyboard shortcuts documented and non-conflicting

### Screen Reader
- [ ] [MANUAL] Tested with VoiceOver (macOS/iOS) — all new content announced correctly
- [ ] [MANUAL] Tested with NVDA or JAWS (Windows) — all new content announced correctly
- [ ] [MANUAL] TalkBack (Android) tested for mobile-specific flows
- [ ] [AUTO] All images have descriptive alt text or `alt=""` if decorative
  - `npm run test:a11y -- --rule=image-alt --exit-code`
- [ ] [AUTO] All form inputs have associated labels (not placeholder-only)
  - `npm run test:a11y -- --rule=label --exit-code`
- [ ] [AUTO] Dynamic content updates use `aria-live` regions appropriately
  - `grep -rn 'aria-live' packages/ui/src/ --include='*.tsx' | wc -l` (verify presence)
- [ ] [AUTO] Error messages associated with inputs via `aria-describedby`
  - `npm run test:a11y -- --rule=aria-input-field-name --exit-code`

---

## 3. Visual Regression

- [ ] [AUTO] Chromatic build passed — zero unexpected visual changes (green baseline)
  - `npm run chromatic -- --exit-zero-on-changes=false --exit-code`
- [ ] [MANUAL] If intentional visual change: Chromatic baseline updated and approved by apex-lead
- [ ] [AUTO] All Storybook stories render without errors in Chromatic
  - `npm run storybook:build -- --exit-code`
- [ ] [AUTO] Dark mode snapshots pass (no regressions in dark mode)
  - `npm run test:visual -- --theme=dark --exit-code`
- [ ] [AUTO] Responsive story snapshots pass at all defined viewports
  - `npm run test:visual -- --viewports=all --exit-code`

---

## 4. Cross-Platform

### iOS
- [ ] [MANUAL] Tested on iPhone 15 Pro (latest) — Safari / WKWebView
- [ ] [MANUAL] Tested on iPhone SE 3rd gen (320px / smallest supported)
- [ ] [MANUAL] Tested on iPad 10th gen — landscape and portrait
- [ ] [MANUAL] No iOS-specific CSS bugs (100vh, fixed positioning, safe-area-inset)
- [ ] [AUTO] Touch targets >= 44pt (per data/performance-budgets.yaml)
  - `npm run test:a11y -- --rule=target-size --exit-code`
- [ ] [MANUAL] Tap highlight disabled where custom styles applied (`-webkit-tap-highlight-color`)

### Android
- [ ] [MANUAL] Tested on Pixel 8 (latest) — Chrome
- [ ] [MANUAL] Tested on Samsung Galaxy S22 — Samsung Internet
- [ ] [MANUAL] No Android-specific layout issues
- [ ] [MANUAL] Tested on a mid-range device (e.g., Pixel 6a) for performance validation

### Apple Vision Pro (where applicable)
- [ ] [MANUAL] Spatial layout reviewed — no elements rely on hover-only interactions
- [ ] [MANUAL] Eye-tracking tap targets >= 60px (per data/performance-budgets.yaml)
- [ ] [MANUAL] Reviewed in visionOS simulator if feature is Vision Pro targeted

---

## 5. Cross-Browser

- [ ] [AUTO] Chrome (latest stable) — macOS and Windows
  - `npm run test:e2e -- --project=Chrome`
- [ ] [AUTO] Safari (latest stable) — macOS and iOS
  - `npm run test:e2e -- --project=Safari`
- [ ] [AUTO] Firefox (latest stable) — macOS and Windows
  - `npm run test:e2e -- --project=Firefox`
- [ ] [MANUAL] Samsung Internet (latest stable) — Android
- [ ] [AUTO] Edge (latest stable) — Windows (Chromium-based, lower priority but confirmed)
  - `npm run test:e2e -- --project=Edge`
- [ ] [AUTO] No vendor-prefix issues (autoprefixer confirmed in build config)
  - `grep -c 'autoprefixer' postcss.config.* 2>/dev/null || echo "MISSING"` (must find autoprefixer)
- [ ] [MANUAL] No experimental CSS features used without fallback

---

## 6. Motion — ref: data/performance-budgets.yaml (motion section)

- [ ] [MANUAL] All animations verified at 60fps (no frame drops in Chrome DevTools Performance tab)
- [ ] [MANUAL] Tested in slow-motion (CPU throttle 6x) — animations degrade gracefully
- [ ] [AUTO] `prefers-reduced-motion: reduce` — all non-essential motion removed or substituted
  - `grep -rL 'prefers-reduced-motion\|useReducedMotion\|shouldReduceMotion' packages/ui/src/components/**/*.motion.ts 2>/dev/null | wc -l` (must be 0)
- [ ] [MANUAL] `prefers-reduced-motion` tested on macOS (System Preferences > Accessibility > Reduce Motion)
- [ ] [MANUAL] `prefers-reduced-motion` tested on iOS (Settings > Accessibility > Motion)
- [ ] [MANUAL] No animation causes layout reflow (confirm composited layers in DevTools)
- [ ] [MANUAL] Rive / GSAP / R3F animations verified for memory leaks (no growing heap over time)
- [ ] [AUTO] Animations cleaned up on component unmount (no dangling RAF / timers)
  - `grep -rn 'requestAnimationFrame\|setInterval\|setTimeout' packages/ui/src/components/ --include='*.tsx' | grep -v 'useEffect\|cleanup\|return' | wc -l` (review any matches)

---

## 7. SEO

- [ ] [AUTO] Page `<title>` tag is descriptive and unique per route
  - `npm run test:seo -- --rule=title --exit-code`
- [ ] [AUTO] Meta description present and between 120-160 characters
  - `npm run test:seo -- --rule=meta-description --exit-code`
- [ ] [AUTO] Open Graph tags: `og:title`, `og:description`, `og:image`, `og:url`
  - `npm run test:seo -- --rule=open-graph --exit-code`
- [ ] [AUTO] Twitter Card tags: `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`
  - `npm run test:seo -- --rule=twitter-card --exit-code`
- [ ] [MANUAL] Canonical URL set correctly (no duplicate content)
- [ ] [MANUAL] Structured data (JSON-LD) present where applicable (Article, Product, BreadcrumbList)
- [ ] [AUTO] Structured data validated via Google Rich Results Test
  - `npm run test:seo -- --rule=structured-data --exit-code`
- [ ] [AUTO] `robots.txt` not blocking new routes unintentionally
  - `npm run test:seo -- --rule=robots --exit-code`
- [ ] [MANUAL] Sitemap updated to include new routes
- [ ] [AUTO] No broken internal links on new pages
  - `npm run test:links -- --exit-code`
- [ ] [AUTO] Heading hierarchy correct (single `h1`, logical `h2`-`h6` tree)
  - `npm run test:a11y -- --rule=heading-order --exit-code`
- [ ] [AUTO] Images have descriptive `alt` attributes (also benefits SEO)
  - `npm run test:a11y -- --rule=image-alt --exit-code`

---

## 8. Documentation

### Storybook
- [ ] [AUTO] Storybook story created for every new component
  - `npm run storybook:build -- --exit-code`
- [ ] [MANUAL] All defined variants covered by stories
- [ ] [MANUAL] Story args use controls (no hardcoded props where controls make sense)
- [ ] [AUTO] Docs page auto-generated and accurate (MDX or autodocs)
  - `npm run storybook:build -- --docs --exit-code`
- [ ] [AUTO] Story renders without console errors or warnings
  - `npm run storybook:build -- --exit-code`

### CHANGELOG
- [ ] [AUTO] `CHANGELOG.md` updated with entry under `[Unreleased]`
  - `grep -c 'Unreleased' packages/ui/CHANGELOG.md` (must be > 0 with new entries)
- [ ] [MANUAL] Entry follows Keep a Changelog format (`Added`, `Changed`, `Fixed`, `Removed`)
- [ ] [MANUAL] Breaking changes called out explicitly with migration notes

### Code Documentation
- [ ] [MANUAL] Public component props documented with JSDoc or TSDoc
- [ ] [MANUAL] Complex logic has inline comments explaining the why, not the what
- [ ] [MANUAL] README updated if CLI usage, env vars, or setup steps changed

---

---

## Enforcement Summary

| Category | Total Items | Auto-Verifiable | Manual Only |
|----------|------------|-----------------|-------------|
| Performance | 14 | 10 | 4 |
| Accessibility | 17 | 8 | 9 |
| Visual Regression | 5 | 4 | 1 |
| Cross-Platform | 13 | 1 | 12 |
| Cross-Browser | 7 | 5 | 2 |
| Motion | 8 | 2 | 6 |
| SEO | 12 | 9 | 3 |
| Documentation | 8 | 4 | 4 |
| **TOTAL** | **84** | **43** | **41** |

> **51% of checklist items are auto-verified.** Manual items are those requiring
> human judgment (visual review, device testing, documentation quality).
> Automated items BLOCK if their verification command fails — no manual override.

---

## Final Sign-Off

| Field | Value |
|-------|-------|
| Story / Feature ID | |
| apex-lead Sign-Off | |
| @qa Sign-Off | |
| Ship Date | |
| Deployment Target | |
| Rollback Plan | |
| Auto Checks Passed | __ / 43 |
| Manual Checks Passed | __ / 41 |
| Result | SHIP / HOLD |
| Veto Conditions Ref | data/veto-conditions.yaml |
| Performance Budget Ref | data/performance-budgets.yaml |
