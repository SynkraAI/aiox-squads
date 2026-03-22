# Task: bundle-optimization

```yaml
id: bundle-optimization
version: "1.0.0"
title: "JavaScript Bundle Optimization"
description: >
  Optimizes the JavaScript bundle size through dependency analysis,
  tree-shaking improvements, code splitting, and lighter library
  replacements. Measures before and after sizes, and verifies
  compliance with the performance budget.
elicit: false
owner: perf-eng
executor: perf-eng
outputs:
  - Current bundle analysis (size, composition)
  - Heavy dependency identification
  - Tree-shaking improvement plan
  - Code splitting implementation
  - Library replacement recommendations
  - Before/after size comparison
  - Budget compliance verification
```

---

## When This Task Runs

This task runs when:
- Initial JavaScript payload exceeds the performance budget
- Bundle analysis reveals heavy or duplicate dependencies
- New dependencies have been added and their bundle impact is unknown
- Lighthouse flags "Reduce unused JavaScript" or "Minimize main-thread work"
- `*bundle-opt` or `*optimize-bundle` is invoked

This task does NOT run when:
- A full performance audit is needed (use `performance-audit`)
- Image optimization is needed (use `image-optimization`)
- The issue is runtime performance, not download size

---

## Execution Steps

### Step 1: Analyze Current Bundle

Generate a detailed breakdown of the current bundle size and composition.

**Measurement:**
```bash
# Next.js
ANALYZE=true npm run build
# Produces .next/analyze/client.html and .next/analyze/server.html

# Vite
npx vite-bundle-visualizer

# Generic webpack
npx webpack --profile --json > stats.json
npx webpack-bundle-analyzer stats.json
```

**Capture baseline metrics:**
| Metric | Value | Budget |
|--------|-------|--------|
| Total JS (uncompressed) | KB | |
| Total JS (gzipped) | KB | < 200KB |
| Total JS (Brotli) | KB | < 170KB |
| Initial chunk (gzipped) | KB | < 100KB |
| Largest route chunk | KB | < 50KB |
| Number of chunks | | |

**Composition breakdown:**
```
Total: 450KB gzipped
├── Framework (React, ReactDOM): 45KB (10%)
├── UI library (component lib): 85KB (19%)
├── State management: 15KB (3%)
├── Utilities (lodash, date-fns): 35KB (8%)
├── Third-party (analytics, SDKs): 120KB (27%)
└── Application code: 150KB (33%)
```

**Output:** Bundle composition report with treemap.

### Step 2: Identify Heavy Dependencies

Find the dependencies that contribute the most to bundle size.

**Sort all dependencies by their contribution:**
| Rank | Package | Size (gzipped) | % of Total | Used Features |
|------|---------|---------------|------------|---------------|
| 1 | moment.js | 67KB | 15% | Date formatting only |
| 2 | lodash | 25KB | 6% | 3 functions used |
| 3 | chart-library | 45KB | 10% | 1 chart type used |

**For each heavy dependency, assess:**
- How many features of this library are actually used?
- Does the library support tree-shaking? (ESM exports)
- Is there a lighter alternative?
- Could the needed functionality be implemented with native APIs?
- Is the library used on all routes or only specific ones?

**Common heavy dependencies and lighter alternatives:**

| Heavy | Size | Alternative | Size | Savings |
|-------|------|------------|------|---------|
| moment.js | 67KB | date-fns | 12KB (tree-shaken) | 55KB |
| lodash (full) | 25KB | lodash-es (tree-shaken) | 3KB | 22KB |
| numeral.js | 15KB | Intl.NumberFormat (native) | 0KB | 15KB |
| classnames | 1KB | clsx | 0.5KB | 0.5KB |
| uuid | 3KB | crypto.randomUUID() (native) | 0KB | 3KB |

**Output:** Heavy dependency inventory with alternatives.

### Step 3: Apply Tree-Shaking Improvements

Ensure the bundler can effectively tree-shake unused code.

**Tree-shaking requirements:**
1. Dependencies must use ESM exports (`export { }`) not CommonJS (`module.exports`)
2. Package.json `"sideEffects"` field must be set correctly
3. Imports must be specific, not barrel imports

**Fix barrel import problem:**
```typescript
// BAD: imports the entire barrel, may prevent tree-shaking
import { Button, Input } from '@ui/components';

// GOOD: direct imports, guaranteed tree-shaking
import { Button } from '@ui/components/Button';
import { Input } from '@ui/components/Input';
```

**Configure bundler for optimal tree-shaking:**

```javascript
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: [
      '@ui/components',
      'lodash-es',
      'date-fns',
      '@icons/react',
    ],
  },
};
```

**Verify tree-shaking effectiveness:**
- Check if unused exports appear in the bundle (search for known unused function names)
- Compare bundle size before and after converting from CommonJS to ESM imports
- Use `why-is-node-running` or `depcheck` to find unused dependencies

**Output:** Tree-shaking improvements applied with size impact.

### Step 4: Implement Code Splitting

Split the bundle into smaller chunks that load on demand.

**Route-based splitting (automatic in Next.js/Remix):**
```
/               → home.chunk.js     (30KB)
/dashboard      → dashboard.chunk.js (45KB)
/settings       → settings.chunk.js  (20KB)
/admin          → admin.chunk.js     (60KB)
```

**Component-based splitting:**
```tsx
// Heavy component loaded on demand
const ChartDashboard = dynamic(() => import('./ChartDashboard'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // Skip SSR for client-only components
});

// React.lazy for client components
const HeavyModal = React.lazy(() => import('./HeavyModal'));
```

**When to code-split:**
- Component is below the fold (not visible on initial load)
- Component is behind an interaction (modal, dropdown, tab panel)
- Component is route-specific (not shared across routes)
- Component has heavy dependencies (chart libraries, editors, maps)
- Component is conditionally rendered (admin-only features)

**When NOT to code-split:**
- Component is above the fold (splitting would hurt LCP)
- Component is tiny (< 5KB) — the chunk overhead is not worth it
- Component is used on every page (it should be in the shared chunk)

**Verify splitting:**
```bash
# Check chunk sizes after build
next build  # Shows route-by-route chunk sizes
```

**Output:** Code splitting implementation with chunk inventory.

### Step 5: Replace Heavy Libraries with Lighter Alternatives

Execute the replacements identified in Step 2.

**Replacement process:**
1. Install the lighter alternative
2. Update all imports across the codebase
3. Verify functionality with existing tests
4. Remove the heavy dependency
5. Rebuild and measure size difference

**Example replacement: moment.js → date-fns**
```typescript
// Before (moment.js)
import moment from 'moment';
const formatted = moment(date).format('MMMM Do, YYYY');
const relative = moment(date).fromNow();

// After (date-fns, tree-shakeable)
import { format, formatDistanceToNow } from 'date-fns';
const formatted = format(date, 'MMMM do, yyyy');
const relative = formatDistanceToNow(date, { addSuffix: true });
```

**Example replacement: lodash → native**
```typescript
// Before
import { debounce, cloneDeep, groupBy } from 'lodash';

// After — debounce (custom, 10 lines)
function debounce(fn: Function, ms: number) {
  let timer: NodeJS.Timeout;
  return (...args: any[]) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), ms);
  };
}

// After — cloneDeep
const clone = structuredClone(original); // Native API

// After — groupBy
const grouped = Object.groupBy(items, (item) => item.category); // Native API (2024)
```

**Output:** Applied replacements with before/after sizes per replacement.

### Step 6: Measure Before/After

Compare bundle sizes before and after all optimizations.

| Metric | Before | After | Savings | % Reduced |
|--------|--------|-------|---------|-----------|
| Total JS (gzipped) | KB | KB | KB | % |
| Initial chunk | KB | KB | KB | % |
| Largest route chunk | KB | KB | KB | % |
| Number of chunks | | | | |

**Per-optimization impact:**
| Optimization | Savings (gzipped) |
|-------------|-------------------|
| Replaced moment.js with date-fns | 55KB |
| Tree-shaking barrel imports | 12KB |
| Code-split chart dashboard | 45KB (moved to async) |
| Removed unused lodash | 22KB |
| **Total** | **134KB** |

**Output:** Before/after comparison table.

### Step 7: Verify Budget Compliance

Check that the optimized bundle meets the performance budget.

| Budget Metric | Budget | Actual | Status |
|--------------|--------|--------|--------|
| Initial JS (gzipped) | < 100KB | KB | PASS/FAIL |
| Total JS (gzipped) | < 200KB | KB | PASS/FAIL |
| Largest chunk | < 50KB | KB | PASS/FAIL |
| LCP impact | < 2.5s | s | PASS/FAIL |

If budget is not met, identify the remaining largest contributors and plan the next round of optimizations.

**Output:** Budget compliance report.

---

## Quality Criteria

- All measurements must include gzipped sizes (not just uncompressed)
- Every heavy dependency must have an assessed alternative
- Code splitting must not negatively impact above-the-fold content
- Library replacements must pass all existing tests
- Before/after comparison must be provided for every optimization
- Budget compliance must be verified after all optimizations

---

*Squad Apex — JavaScript Bundle Optimization Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-bundle-optimization
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Before/after bundle size comparison must show measurable improvement"
    - "Tree-shaking plan must identify dead code with estimated size reduction"
    - "Code splitting strategy must define at least route-level split points"
    - "Final bundle must meet the defined performance budget"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Bundle optimization report with before/after comparison and budget compliance status |
| Next action | Route to `@frontend-arch` for `performance-budget-review` if budget thresholds changed, or mark optimization complete |
