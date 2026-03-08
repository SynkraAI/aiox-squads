# Task: perf-budget-setup

```yaml
id: perf-budget-setup
version: "1.0.0"
title: "Performance Budget Setup"
description: >
  Sets up performance budget monitoring for the project. Defines
  budgets per metric (LCP, INP, CLS, JS size), configures
  Lighthouse CI for automated checks, sets up bundle size monitoring
  in CI, configures Real User Monitoring (RUM), defines violation
  thresholds, and documents the escalation process.
elicit: false
owner: perf-eng
executor: perf-eng
outputs:
  - Performance budget definitions per metric
  - Lighthouse CI configuration
  - Bundle size CI checks
  - RUM configuration
  - Violation threshold definitions
  - Escalation process documentation
```

---

## When This Task Runs

This task runs when:
- A new project needs performance guardrails from the start
- Performance regressions keep occurring because there are no automated checks
- The team wants to prevent performance degradation as features are added
- A performance audit was completed and budgets need to enforce the improvements
- `*perf-budget` or `*setup-perf-budget` is invoked

This task does NOT run when:
- A performance audit is needed first (use `performance-audit`)
- Specific optimizations need to be made (use `bundle-optimization` or `image-optimization`)
- CI/CD pipeline changes need to be deployed (delegate to `@devops`)

---

## Execution Steps

### Step 1: Define Performance Budgets

Establish quantitative budgets for each key performance metric.

**Core Web Vitals budgets:**

| Metric | Good | Needs Improvement | Poor | Our Budget |
|--------|------|-------------------|------|-----------|
| LCP | < 2.5s | 2.5-4.0s | > 4.0s | < 2.5s |
| INP | < 200ms | 200-500ms | > 500ms | < 200ms |
| CLS | < 0.1 | 0.1-0.25 | > 0.25 | < 0.1 |

**Resource budgets:**

| Resource | Budget | Rationale |
|----------|--------|-----------|
| Total JS (initial, gzipped) | < 100KB | First-load performance |
| Total JS (all, gzipped) | < 250KB | Total JS weight |
| Total CSS (gzipped) | < 50KB | Render-blocking potential |
| Total images (above fold) | < 200KB | LCP and initial load |
| Total page weight | < 1MB | Inclusive of all resources |
| Largest JS chunk | < 60KB | Code splitting effectiveness |
| Third-party JS | < 80KB | External dependency limit |
| Web fonts | < 100KB | Text rendering speed |

**Timing budgets:**

| Metric | Budget | Measurement |
|--------|--------|-------------|
| TTFB | < 600ms | Server response time |
| FCP | < 1.8s | First visual content |
| LCP | < 2.5s | Largest content element |
| TTI | < 3.5s | Full interactivity |
| TBT | < 200ms | Main thread blocking |

**Per-route budgets (for SPAs):**
Different routes may have different budgets:
| Route | JS Budget | LCP Budget | Notes |
|-------|-----------|-----------|-------|
| / (homepage) | 80KB | 2.0s | Most critical route |
| /dashboard | 120KB | 2.5s | Data-heavy, more JS acceptable |
| /settings | 60KB | 2.0s | Simple page |
| /editor | 200KB | 3.0s | Complex, feature-rich |

**Output:** Performance budget document with all metrics defined.

### Step 2: Configure Lighthouse CI

Set up automated Lighthouse checks that run on every PR.

**Lighthouse CI configuration:**
```javascript
// lighthouserc.js
module.exports = {
  ci: {
    collect: {
      url: [
        'http://localhost:3000/',
        'http://localhost:3000/dashboard',
        'http://localhost:3000/settings',
      ],
      startServerCommand: 'npm run start',
      numberOfRuns: 3, // Median of 3 runs for stability
      settings: {
        preset: 'desktop',
        chromeFlags: '--no-sandbox',
      },
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'first-contentful-paint': ['warn', { maxNumericValue: 1800 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['error', { maxNumericValue: 200 }],
        'interactive': ['warn', { maxNumericValue: 3500 }],
      },
    },
    upload: {
      target: 'temporary-public-storage', // Or self-hosted LHCI server
    },
  },
};
```

**CI integration (GitHub Actions):**
```yaml
- name: Lighthouse CI
  run: |
    npm install -g @lhci/cli
    lhci autorun
  env:
    LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

**Assertion levels:**
- `error` — Fails the CI check, blocks merge
- `warn` — Shows warning in PR, does not block

**Output:** Lighthouse CI configuration file and CI integration.

### Step 3: Set Up Bundle Size Checks in CI

Monitor bundle size changes on every pull request.

**Option A: bundlewatch**
```javascript
// package.json
{
  "bundlewatch": {
    "files": [
      { "path": ".next/static/chunks/main-*.js", "maxSize": "100KB" },
      { "path": ".next/static/chunks/pages/_app-*.js", "maxSize": "60KB" },
      { "path": ".next/static/css/*.css", "maxSize": "30KB" }
    ],
    "defaultCompression": "gzip"
  }
}
```

**Option B: size-limit**
```javascript
// .size-limit.js
module.exports = [
  {
    path: '.next/static/chunks/main-*.js',
    limit: '100 KB',
    gzip: true,
  },
  {
    name: 'Initial JS',
    path: '.next/static/chunks/*.js',
    limit: '200 KB',
    gzip: true,
  },
];
```

**CI integration:**
```yaml
- name: Check bundle size
  run: npx size-limit
  # Fails if any budget is exceeded
```

**PR comment bot:**
Configure to post bundle size diff in PR comments:
```
Bundle Size Report

Package          | Current | Change  | Budget  | Status
initial.js       | 95KB    | +3KB    | 100KB   | OK
dashboard.chunk  | 58KB    | +12KB   | 60KB    | WARNING
total            | 185KB   | +15KB   | 250KB   | OK
```

**Output:** Bundle size monitoring configuration with CI integration.

### Step 4: Configure Real User Monitoring (RUM)

Set up field data collection from real users to complement lab data.

**web-vitals library (lightweight RUM):**
```typescript
// lib/analytics.ts
import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';

function sendMetric(metric: { name: string; value: number; id: string }) {
  // Send to your analytics endpoint
  navigator.sendBeacon('/api/vitals', JSON.stringify({
    name: metric.name,
    value: metric.value,
    id: metric.id,
    page: window.location.pathname,
    connection: navigator.connection?.effectiveType,
    deviceMemory: navigator.deviceMemory,
    timestamp: Date.now(),
  }));
}

// Register all Core Web Vitals
onLCP(sendMetric);
onINP(sendMetric);
onCLS(sendMetric);
onFCP(sendMetric);
onTTFB(sendMetric);
```

**Next.js built-in reporting:**
```typescript
// app/layout.tsx
export function reportWebVitals(metric: NextWebVitalsMetric) {
  switch (metric.name) {
    case 'LCP':
    case 'INP':
    case 'CLS':
      sendToAnalytics(metric);
      break;
  }
}
```

**RUM data storage and visualization:**
- Simple: Send to existing analytics (Google Analytics 4 has CWV support)
- Advanced: Send to a dedicated endpoint and visualize with Grafana/Datadog
- Google CrUX: Check CrUX data in Search Console for public metrics

**What to track:**
- All three Core Web Vitals (LCP, INP, CLS)
- Segment by: route, device type, connection speed, geography
- Track p75 (75th percentile — what Google uses for ranking)
- Alert on p75 regressions

**Output:** RUM configuration with data collection and storage setup.

### Step 5: Define Violation Thresholds

Establish clear thresholds for when a performance violation triggers action.

**Threshold levels:**

| Level | Condition | Action | Who |
|-------|-----------|--------|-----|
| **Green** | All metrics within budget | No action needed | Automated |
| **Yellow (Warning)** | Within 10% of budget | Add to tech debt backlog | perf-eng notified |
| **Orange (Approaching)** | Within 5% of budget | Must address this sprint | perf-eng reviews |
| **Red (Violation)** | Exceeds budget | Blocks deployment | perf-eng + team lead |

**Example thresholds for LCP (budget: 2.5s):**
| Level | Range | Trigger |
|-------|-------|---------|
| Green | < 2.25s | |
| Yellow | 2.25s - 2.375s | Backlog item created |
| Orange | 2.375s - 2.5s | Sprint priority |
| Red | > 2.5s | Deploy blocked |

**Example thresholds for JS size (budget: 100KB initial):**
| Level | Range | Trigger |
|-------|-------|---------|
| Green | < 90KB | |
| Yellow | 90-95KB | Backlog item created |
| Orange | 95-100KB | Sprint priority |
| Red | > 100KB | PR blocked by CI |

**Automated alerting:**
- CI failures post to team channel
- RUM threshold violations trigger alerts
- Weekly performance digest email/message

**Output:** Threshold definitions with automated triggers.

### Step 6: Document Escalation Process

Define what happens when a performance budget is violated.

**Escalation flow:**
```
1. CI check fails (Red threshold)
   ↓
2. PR author receives failure notification
   ↓
3. Author reviews Lighthouse CI / bundle size report
   ↓
4. Can the author fix it? → Yes → Fix and re-push
   ↓ No
5. @perf-eng reviews the regression
   ↓
6. @perf-eng determines:
   a. Fix is straightforward → provides fix guidance
   b. Budget needs adjustment → proposes new budget with justification
   c. Architecture issue → escalates to @frontend-arch
   ↓
7. Resolution documented in PR
```

**Budget exception process:**
Sometimes a new feature legitimately needs more JS. The exception process:
1. Author documents why the budget increase is necessary
2. @perf-eng reviews and approves/rejects
3. If approved, budget is increased with a note about what was added
4. A follow-up optimization task is created to bring it back down

**Weekly review:**
- Review RUM p75 trends for each route
- Compare lab data (Lighthouse CI) with field data (RUM)
- Identify routes approaching yellow thresholds
- Plan optimization work before violations occur

**Output:** Escalation process documentation.

---

## Quality Criteria

- Budgets must be defined for all three Core Web Vitals
- Resource budgets must include JS, CSS, images, and total page weight
- Lighthouse CI must run on every PR and block on violations
- Bundle size must be tracked per chunk, not just total
- RUM must collect and segment data by route and device type
- Escalation process must have a clear owner at each step

---

*Squad Apex — Performance Budget Setup Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-perf-budget-setup
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Budgets must be defined for all three Core Web Vitals (LCP, INP, CLS)"
    - "Lighthouse CI must run on every PR and block on violations"
    - "Bundle size must be tracked per chunk, not just total"
    - "RUM must be configured to collect and segment data by route"
    - "Escalation process must have a clear owner at each step"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Performance budget setup with metric definitions, Lighthouse CI config, bundle monitoring, RUM, and escalation process |
| Next action | Coordinate with `@devops` for CI pipeline integration and notify `@frontend-arch` of budget thresholds |
