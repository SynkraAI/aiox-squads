# Performance Budget: {FEATURE/PAGE}

**Owner:** @perf-eng (Addy)
**Date:** {YYYY-MM-DD}
**Target Device:** Moto G4 (baseline) + MacBook Pro (upper)

## Core Web Vitals Budget
| Metric | Budget | Current | Status |
|--------|--------|---------|--------|
| LCP | < 1.2s | | ⬜ |
| INP | < 200ms | | ⬜ |
| CLS | < 0.1 | | ⬜ |
| FCP | < 0.8s | | ⬜ |
| TTFB | < 0.6s | | ⬜ |

## Bundle Budget
| Asset | Budget | Current | Status |
|-------|--------|---------|--------|
| First Load JS | < 80KB gz | | ⬜ |
| Page JS | < 30KB gz | | ⬜ |
| CSS | < 15KB gz | | ⬜ |
| Images (above fold) | < 200KB | | ⬜ |
| Fonts | < 50KB (subset) | | ⬜ |
| Total | < 375KB | | ⬜ |

## Runtime Budget
| Metric | Budget | Current | Status |
|--------|--------|---------|--------|
| Main thread blocking | < 50ms | | ⬜ |
| Animation FPS | >= 60 | | ⬜ |
| Memory (mobile) | < 50MB | | ⬜ |

## Lighthouse Score
| Category | Budget | Current | Status |
|----------|--------|---------|--------|
| Performance | >= 95 | | ⬜ |
| Accessibility | 100 | | ⬜ |
| Best Practices | >= 95 | | ⬜ |
| SEO | >= 95 | | ⬜ |

## Test Devices
- Moto G4 (low-end baseline)
- Pixel 7a (mid-range)
- iPhone 15 (high-end)
- MacBook Pro M3 (desktop)

## Actions Required
{What needs to be done to meet budget}
