# Core Web Vitals Specific Checklist — Apex Squad

> Reviewer: perf-eng
> Purpose: Deep-dive validation of each Core Web Vital metric with specific optimization checks.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. LCP (Largest Contentful Paint)

- [ ] Largest element on the page identified (image, heading, or block of text)
- [ ] LCP resource is preloaded (`<link rel="preload">` or `fetchpriority="high"`)
- [ ] No render-blocking CSS or JavaScript delays the LCP element
- [ ] Server-side rendered (SSR) or statically generated for immediate content availability
- [ ] LCP image uses modern format (WebP/AVIF) and is properly sized
- [ ] Font used in LCP text is preloaded with `font-display: swap` or `optional`
- [ ] No client-side redirects before LCP element renders
- [ ] TTFB optimized — server response time does not delay LCP
- [ ] CDN serving the LCP resource from edge location
- [ ] Target: LCP < 1.2s on 4G connection

---

## 2. INP (Interaction to Next Paint)

- [ ] Event handlers complete in < 200ms (measured with Performance API or DevTools)
- [ ] No long tasks (> 50ms) blocking the main thread during user interactions
- [ ] Heavy computation offloaded to Web Workers or deferred with `requestIdleCallback`
- [ ] Input handling deferred to idle periods where visual feedback is provided immediately
- [ ] `startTransition` used for non-urgent state updates in React
- [ ] No synchronous DOM reads followed by writes in event handlers (layout thrashing)
- [ ] Third-party scripts do not block interaction responsiveness
- [ ] Debounce/throttle applied to high-frequency events (scroll, resize, input)
- [ ] Target: INP < 200ms for p75 interactions

---

## 3. CLS (Cumulative Layout Shift)

- [ ] Explicit `width` and `height` attributes on all images and video elements
- [ ] No dynamically injected content above the fold without reserved space
- [ ] Font loading does not cause text reflow (FOIT/FOUT handled)
- [ ] Skeleton screens or placeholder elements match final content dimensions
- [ ] Ads and embeds have reserved space with fixed dimensions
- [ ] No late-loading CSS that shifts layout
- [ ] `aspect-ratio` CSS property used for media containers
- [ ] Lazy-loaded content below fold does not cause above-fold shifts
- [ ] Dynamic banners, toasts, or notifications do not push content down
- [ ] Target: CLS < 0.1 cumulative score

---

## 4. Measurement

- [ ] Core Web Vitals measured in lab (Lighthouse, DevTools)
- [ ] Core Web Vitals measured in field (CrUX, RUM, Web Vitals library)
- [ ] P75 values tracked — not just average or median
- [ ] Regression alerts configured for metric degradation
- [ ] Slow device simulation tested (CPU 4x slowdown, slow 3G network)
- [ ] Metrics measured on the most common user device/connection profile

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| LCP (lab) | |
| INP (lab) | |
| CLS (lab) | |
| Device Profile | |
| Result | APPROVED / BLOCKED |
| Notes | |
