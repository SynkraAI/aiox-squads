# Performance Review Checklist — Apex Squad

> Reviewer: perf-eng
> Purpose: Validate performance across Core Web Vitals, bundle size, images, rendering, and network.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Core Web Vitals

- [ ] LCP (Largest Contentful Paint) < 1.2s on representative connection
- [ ] INP (Interaction to Next Paint) < 200ms for all measured interactions
- [ ] CLS (Cumulative Layout Shift) < 0.1 — no unexpected layout shifts
- [ ] TTFB (Time to First Byte) < 200ms from edge
- [ ] FCP (First Contentful Paint) < 1.0s
- [ ] Metrics verified with Lighthouse, Web Vitals extension, or RUM data
- [ ] Performance budget not regressed from previous baseline

---

## 2. Bundle

- [ ] First-load JavaScript < 80KB gzipped
- [ ] No unused dependencies in the bundle (tree-shaking verified)
- [ ] Tree-shaking confirmed — no barrel imports pulling full libraries
- [ ] Route-level code splitting implemented (each route loads only its code)
- [ ] Dynamic imports used for non-critical features (modals, charts, rich editors)
- [ ] Duplicate dependencies eliminated (`npm dedupe` or bundler analysis)
- [ ] Bundle analysis report reviewed (webpack-bundle-analyzer, next/bundle-analyzer)

---

## 3. Images

- [ ] WebP or AVIF format used (with fallback for older browsers)
- [ ] Responsive `srcset` and `sizes` attributes defined
- [ ] Images below the fold are lazy loaded (`loading="lazy"`)
- [ ] Images above the fold are eagerly loaded and preloaded
- [ ] Images properly sized — not serving 2000px images for 400px containers
- [ ] `width` and `height` attributes set to prevent CLS during load
- [ ] Image CDN used with automatic format negotiation and resizing

---

## 4. Rendering

- [ ] No layout thrashing (read-then-write DOM pattern avoided)
- [ ] `will-change` used sparingly and only on elements about to animate
- [ ] `requestAnimationFrame` used for visual updates
- [ ] Expensive DOM operations batched or deferred to idle periods
- [ ] `content-visibility: auto` applied to off-screen sections
- [ ] No forced synchronous layouts in scroll handlers or animation loops
- [ ] React Profiler shows no unnecessary re-renders in hot paths

---

## 5. Network

- [ ] Critical resources preloaded (`<link rel="preload">`)
- [ ] Likely next navigations prefetched (`<link rel="prefetch">`)
- [ ] Service worker caching strategy implemented for static assets
- [ ] API responses cached appropriately (SWR, React Query, HTTP cache headers)
- [ ] No redundant network requests (deduplication in place)
- [ ] Compression enabled (Brotli preferred, gzip fallback)
- [ ] HTTP/2 or HTTP/3 utilized for multiplexing

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| LCP Measured | |
| INP Measured | |
| CLS Measured | |
| Result | APPROVED / BLOCKED |
| Notes | |
