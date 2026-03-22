# Task: performance-audit

```yaml
id: performance-audit
version: "1.0.0"
title: "Full Performance Audit"
description: >
  Performs a comprehensive web performance audit covering Lighthouse
  scores, Core Web Vitals (LCP, INP, CLS), bundle analysis, network
  waterfall inspection, and runtime profiling. Identifies optimization
  opportunities and generates a prioritized report with specific
  recommendations and expected impact.
elicit: false
owner: perf-eng
executor: perf-eng
outputs:
  - Lighthouse results (mobile + desktop)
  - Core Web Vitals measurements (LCP, INP, CLS)
  - Bundle composition analysis
  - Network waterfall analysis
  - Runtime performance profile
  - Prioritized optimization report
```

---

## When This Task Runs

This task runs when:
- A page or feature is slow and needs diagnosis
- Before a launch, to establish a performance baseline
- Core Web Vitals are failing in Google Search Console
- A new feature has been shipped and its performance impact is unknown
- `*perf-audit` or `*performance-audit` is invoked

This task does NOT run when:
- Only bundle size optimization is needed (use `bundle-optimization`)
- Only image optimization is needed (use `image-optimization`)
- Only performance budgets need setup (use `perf-budget-setup`)
- The performance issue is 3D rendering specific (delegate to `@spatial-eng`)

---

## Execution Steps

### Step 1: Run Lighthouse (Mobile + Desktop)

Execute Lighthouse audits to get baseline scores and identify high-level issues.

**Run both profiles:**
```bash
# Desktop
npx lighthouse https://target-url --output=json --output=html \
  --preset=desktop --chrome-flags="--headless"

# Mobile (default — simulates 4x CPU slowdown + slow 4G)
npx lighthouse https://target-url --output=json --output=html \
  --chrome-flags="--headless"
```

**Key scores to capture:**

| Category | Target Score | Red Flag |
|----------|-------------|----------|
| Performance | >= 90 | < 50 |
| Accessibility | >= 90 | < 70 |
| Best Practices | >= 90 | < 80 |
| SEO | >= 90 | < 80 |

**From Performance details, extract:**
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Total Blocking Time (TBT) — correlates with INP
- Cumulative Layout Shift (CLS)
- Speed Index
- Time to Interactive (TTI)

**Lighthouse opportunities section** — list the top 5 by estimated savings:
1. {Opportunity}: estimated savings {X}s
2. {Opportunity}: estimated savings {X}s
3. ...

**Note:** Lighthouse is a lab test (simulated conditions). Field data from CrUX/RUM is needed for real-user performance in Step 2.

**Output:** Lighthouse HTML reports for both mobile and desktop.

### Step 2: Measure Core Web Vitals (LCP, INP, CLS)

Measure the three Core Web Vitals with both lab and field data.

**Largest Contentful Paint (LCP):**
Target: < 2.5 seconds

Measurement:
```javascript
new PerformanceObserver((list) => {
  const entries = list.getEntries();
  const lastEntry = entries[entries.length - 1];
  console.log('LCP:', lastEntry.startTime, 'Element:', lastEntry.element);
}).observe({ type: 'largest-contentful-paint', buffered: true });
```

Common LCP issues:
- Large hero image not optimized (wrong format, not preloaded)
- Server response time too slow (TTFB > 800ms)
- Render-blocking resources (CSS, synchronous JS in head)
- Client-side rendering delays (no SSR, JS-dependent content)

**Interaction to Next Paint (INP):**
Target: < 200ms

Measurement:
```javascript
// Use web-vitals library
import { onINP } from 'web-vitals';
onINP((metric) => {
  console.log('INP:', metric.value, 'Interaction:', metric.entries);
});
```

Common INP issues:
- Heavy JavaScript execution during interaction
- Long tasks blocking the main thread (> 50ms)
- Hydration cost in SSR frameworks
- Third-party scripts interfering

**Cumulative Layout Shift (CLS):**
Target: < 0.1

Measurement:
```javascript
new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (!entry.hadRecentInput) {
      console.log('CLS contribution:', entry.value, 'Sources:', entry.sources);
    }
  }
}).observe({ type: 'layout-shift', buffered: true });
```

Common CLS issues:
- Images without width/height dimensions
- Ads or embeds loading without reserved space
- Fonts causing text reflow (FOIT/FOUT)
- Dynamic content injected above viewport

**Output:** Core Web Vitals measurements with element-level attribution.

### Step 3: Analyze Bundle with webpack-bundle-analyzer

Inspect the JavaScript bundle composition to identify heavy dependencies and optimization opportunities.

**Analysis tools:**
```bash
# Next.js
ANALYZE=true next build

# Generic webpack
npx webpack-bundle-analyzer dist/stats.json

# Vite
npx vite-bundle-visualizer
```

**What to capture:**

| Metric | Target | How to Measure |
|--------|--------|---------------|
| Total JS (gzipped) | < 200KB initial | Build output |
| Largest chunk | < 100KB gzipped | Bundle analyzer |
| Duplicate dependencies | 0 | Bundle analyzer treemap |
| Unused exports | Minimal | Tree-shaking report |

**Analysis checklist:**
- [ ] Identify the top 5 largest dependencies by size
- [ ] Check for duplicate packages (different versions of the same lib)
- [ ] Identify libraries imported for a single function (lodash, moment.js)
- [ ] Check that tree-shaking is working (no unused exports in bundle)
- [ ] Verify code splitting is effective (route-based chunks exist)
- [ ] Check for source maps accidentally included in production

**Output:** Bundle composition report with treemap visualization.

### Step 4: Check Network Waterfall

Analyze the network loading sequence to identify bottlenecks.

**Tools:**
- Chrome DevTools → Network tab (with throttling to Slow 3G or Fast 4G)
- WebPageTest (waterfall view with connection types)

**What to analyze:**
- **Critical path:** What resources must load before the page is usable?
- **Request chains:** Are resources loaded serially that could be parallel?
- **Resource priorities:** Are critical resources prioritized correctly?
- **Caching:** Do returning visitors get cache hits?

**Network optimization checklist:**

| Check | Pass Criteria |
|-------|--------------|
| TTFB (Time to First Byte) | < 800ms (< 200ms ideal) |
| Critical CSS inlined | Above-the-fold CSS in `<head>` |
| JS deferred/async | Non-critical JS uses `defer` or `async` |
| Preload hints | LCP image and critical fonts use `<link rel="preload">` |
| DNS prefetch | Third-party domains use `<link rel="dns-prefetch">` |
| Compression | All text resources served with Brotli or gzip |
| HTTP/2 or HTTP/3 | Multiplexing enabled |
| CDN usage | Static assets served from CDN edge nodes |
| Cache headers | Immutable assets have long `max-age`, dynamic have `stale-while-revalidate` |

**Identify resource waste:**
- Third-party scripts loaded eagerly but not used above-the-fold
- Analytics/tracking scripts blocking render
- Font files loaded for characters not on the page
- CSS files containing unused rules

**Output:** Network waterfall analysis with optimization opportunities.

### Step 5: Profile Runtime Performance

Use Chrome DevTools Performance panel to profile runtime behavior during user interaction.

**Recording protocol:**
1. Open DevTools → Performance tab
2. Enable CPU throttling (4x slowdown for mobile simulation)
3. Start recording
4. Perform the key user interaction (page load, scroll, click, form submit)
5. Stop recording
6. Analyze the flame chart

**What to look for:**

| Issue | How to Identify | Impact |
|-------|----------------|--------|
| Long tasks | Red bars in Main thread (> 50ms) | Blocks interaction, causes INP |
| Layout thrashing | Purple "Layout" blocks repeating | Forced synchronous layout |
| Excessive re-renders | React Profiler showing unnecessary renders | Wasted CPU cycles |
| Garbage collection | Frequent GC pauses | Jank during animation |
| Paint storms | Green "Paint" blocks covering large areas | Compositing overhead |

**React-specific profiling:**
```bash
# Enable React DevTools Profiler
# Record a session → Identify:
# - Components that render too often
# - Components with expensive render functions
# - Wasted renders (output did not change)
```

**Common runtime optimizations:**
- Memoize expensive computations (`useMemo`)
- Memoize callbacks passed to children (`useCallback`)
- Virtualize long lists (`react-window`, `react-virtuoso`)
- Debounce rapid-fire events (scroll, resize, input)
- Use `startTransition` for non-urgent state updates
- Use Web Workers for CPU-intensive tasks

**Output:** Runtime profile with identified bottlenecks and optimization suggestions.

### Step 6: Identify Optimization Opportunities

Compile all findings into a prioritized list of optimizations.

**Prioritization framework:**

| Priority | Impact | Effort | Examples |
|----------|--------|--------|---------|
| P0 — Critical | High impact, low effort | Quick wins | Add image dimensions, preload LCP image |
| P1 — High | High impact, medium effort | Sprint work | Code splitting, bundle optimization |
| P2 — Medium | Medium impact, medium effort | Planned work | Image format conversion, font subsetting |
| P3 — Low | Low impact or high effort | Backlog | Full CSS purge, architecture changes |

**Output format:**
```markdown
## Optimization Opportunities

### P0 — Quick Wins (< 1 day each)
1. Add width/height to hero image → fixes CLS (estimated: CLS -0.05)
2. Preload LCP image → reduces LCP by ~500ms
3. Defer analytics scripts → reduces TBT by ~200ms

### P1 — Sprint Work (1-3 days each)
4. Replace moment.js with date-fns → saves 65KB gzipped
5. Implement code splitting for /settings route → saves 45KB initial

### P2 — Planned Work (3-5 days each)
6. Convert all images to WebP/AVIF → saves ~40% image weight
7. Implement service worker for offline caching
```

**Output:** Prioritized optimization report with estimated impact.

### Step 7: Generate Performance Report

Compile the complete audit into a final report.

```markdown
## Performance Audit Report — [Scope]

### Executive Summary
- Lighthouse Performance: {score}/100
- LCP: {value}s (target: < 2.5s) — {PASS/FAIL}
- INP: {value}ms (target: < 200ms) — {PASS/FAIL}
- CLS: {value} (target: < 0.1) — {PASS/FAIL}
- Total JS: {size}KB gzipped
- Total page weight: {size}KB

### Detailed Findings
[Steps 1-5 results]

### Optimizations
[Step 6 prioritized list]

### Estimated Impact
If all P0+P1 optimizations are implemented:
- LCP: {current} → {projected}
- INP: {current} → {projected}
- JS size: {current} → {projected}
```

**Output:** Complete performance audit report.

---

## Quality Criteria

- Lighthouse must run on both mobile and desktop profiles
- Core Web Vitals must be measured with element-level attribution
- Bundle analysis must identify the top 5 heaviest dependencies
- Network analysis must check all items in the optimization checklist
- All optimization recommendations must include estimated impact
- The report must be actionable — no vague "improve performance" recommendations

---

*Squad Apex — Full Performance Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-performance-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Lighthouse must run on both mobile and desktop profiles"
    - "Core Web Vitals must be measured with element-level attribution"
    - "Bundle analysis must identify the top 5 heaviest dependencies"
    - "Report must contain at least one actionable finding or explicit all-clear"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Complete performance audit report with Lighthouse results, CWV measurements, bundle analysis, and prioritized optimizations |
| Next action | Route P0/P1 optimizations to `@perf-eng` for execution and to `@frontend-arch` for `performance-budget-review` |
