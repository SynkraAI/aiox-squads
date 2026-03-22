# Task: apex-discover-performance

```yaml
id: apex-discover-performance
version: "1.0.0"
title: "Apex Discover Performance"
description: >
  Static performance analysis across all components. Detects heavy components,
  lazy loading gaps, image optimization opportunities, re-render risks, and
  third-party script costs. Code-level analysis that feeds performance-audit,
  bundle-optimization, and veto QG-AX-007.
elicit: false
owner: apex-lead
executor: perf-eng
dependencies:
  - tasks/apex-scan.md
  - tasks/performance-audit.md
  - tasks/bundle-optimization.md
  - tasks/image-optimization.md
  - data/performance-budgets.yaml
outputs:
  - Performance issue inventory
  - Component weight ranking
  - Optimization opportunity list
  - Performance health score
```

---

## Command

### `*discover-performance`

Static performance scan — no browser, no Lighthouse, just code analysis.

---

## How It Works

### Step 1: Analyze Component Weight

```yaml
component_analysis:
  per_component:
    name: "{component}"
    file: "{path}"
    loc: N
    import_count: N
    imports_total_weight: "estimated KB"
    hooks_count: N
    state_variables: N
    effects_count: N
    renders_children: true | false
    memoized: "React.memo | useMemo | none"
    lazy_loaded: true | false

  ranking: "Sort by estimated weight (LOC * import_weight)"
  flag_threshold: "Top 10% heaviest components"
```

### Step 2: Detect Issues

```yaml
checks:

  lazy_loading_gaps:
    description: "Pages/routes not lazy loaded"
    detection:
      - "Route components imported with regular import (not React.lazy or dynamic)"
      - "Heavy components (>200 LOC) imported eagerly in main bundle"
      - "Below-the-fold components loaded above-the-fold"
    severity: HIGH
    impact: "Increases initial bundle size, slows First Load JS"

  image_issues:
    description: "Images not optimized"
    patterns:
      - "<img without loading='lazy' (below fold)"
      - "<img without width/height (causes CLS)"
      - "<img src='.png' or '.jpg' (should be .webp/.avif)"
      - "<img without srcSet (no responsive images)"
      - "Large static imports of images (import img from './hero.png')"
      - "No next/image or optimized image component used"
    severity: MEDIUM
    impact: "LCP degradation, CLS shifts, bandwidth waste"

  rerender_risks:
    description: "Components likely to re-render unnecessarily"
    patterns:
      - "Object/array literal in JSX props: prop={{key: value}} or prop={[1,2,3]}"
      - "Inline function in JSX: onClick={() => handleClick(id)}"
      - "Context provider with value={{}} (new object every render)"
      - "Missing key prop in lists"
      - "Component subscribes to large context but uses small slice"
      - "useEffect without dependency array (runs every render)"
      - "useState initializer with expensive computation (no lazy init)"
    severity: MEDIUM
    impact: "Unnecessary re-renders, INP degradation"

  bundle_risks:
    description: "Patterns that bloat the bundle"
    patterns:
      - "import * as lib from 'library' (imports everything, blocks tree-shaking)"
      - "Dynamic require() in ESM code"
      - "Barrel file re-exports (index.ts that exports *)"
      - "Large JSON imports (> 50KB) not chunked"
      - "Moment.js locale imports (all locales by default)"
      - "CSS-in-JS with runtime styling (styled-components, emotion runtime)"
    severity: HIGH
    impact: "Bundle size exceeds budget"

  third_party:
    description: "Third-party scripts and their cost"
    detection:
      - "External <script> tags"
      - "Analytics libraries (GA, Mixpanel, Segment, Hotjar)"
      - "Chat widgets (Intercom, Drift, Zendesk)"
      - "Ad scripts"
      - "Font loading (multiple font files, no font-display)"
    estimate: "Approximate KB + main thread time per script"
    severity: MEDIUM

  core_web_vitals_risks:
    description: "Patterns that likely degrade CWV"
    patterns:
      lcp_risks:
        - "Hero image not preloaded"
        - "Largest image loaded lazily (should be eager)"
        - "Web font blocking render (no font-display: swap)"
        - "Server-side rendering not used for above-fold content"
      inp_risks:
        - "Heavy onClick handlers (>50ms estimated)"
        - "Synchronous state updates in event handlers"
        - "No transition API for expensive updates"
      cls_risks:
        - "Images without explicit dimensions"
        - "Dynamic content injected above fold without reserved space"
        - "Font swap causing layout shift"
        - "Ads or embeds without aspect-ratio container"
    severity: HIGH
```

### Step 3: Calculate Performance Health Score

```yaml
health_score:
  formula: "100 - (penalties)"
  penalties:
    page_not_lazy: -5 each
    image_no_lazy_load: -2 each
    image_no_dimensions: -3 each
    image_wrong_format: -1 each
    rerender_risk_high: -3 each
    barrel_import_star: -2 each
    heavy_third_party: -5 each
    lcp_risk: -5 each
    inp_risk: -3 each
    cls_risk: -4 each

  classification:
    90-100: "fast — performance-first codebase"
    70-89: "good — minor optimizations available"
    50-69: "slow — significant performance debt"
    0-49: "critical — performance overhaul needed"
```

### Step 4: Output

```yaml
output_format: |
  ## Performance Discovery

  **Components Scanned:** {total}
  **Performance Health Score:** {score}/100 ({classification})
  **Budget Status:** {within_budget | over_budget}

  ### Core Web Vitals Risks
  | Metric | Risks Found | Severity |
  |--------|-------------|----------|
  | LCP | {n} | {sev} |
  | INP | {n} | {sev} |
  | CLS | {n} | {sev} |

  ### Issues by Category
  | Category | Count | Severity | Est. Impact |
  |----------|-------|----------|-------------|
  | Lazy loading gaps | {n} | HIGH | -{kb}KB initial |
  | Image optimization | {n} | MEDIUM | -{kb}KB bandwidth |
  | Re-render risks | {n} | MEDIUM | +{ms}ms INP |
  | Bundle risks | {n} | HIGH | +{kb}KB bundle |
  | Third-party cost | {n} | MEDIUM | +{ms}ms blocking |

  ### Heaviest Components (Top 5)
  | Component | LOC | Imports | Est. Weight | Lazy? |
  |-----------|-----|---------|-------------|-------|
  | {name} | {loc} | {n} | ~{kb}KB | {y/n} |

  ### Options
  1. Otimizar lazy loading ({lazy_gaps} componentes)
  2. Otimizar imagens ({image_issues} issues)
  3. Corrigir re-render risks ({rerender_count})
  4. Bundle analysis detalhado
  5. So quero o relatorio
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-DP-001
    condition: "First Load JS exceeds budget (>80KB gzipped)"
    action: "WARN — Feeds QG-AX-007. Optimize bundle before shipping."
    available_check: "command:npm run build"
    on_unavailable: MANUAL_CHECK

  - id: VC-DP-002
    condition: "Above-fold image loaded lazily (degrades LCP)"
    action: "WARN — Hero/above-fold images must load eagerly with priority."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK
```

---

## Cache

```yaml
cache:
  location: ".aios/apex-context/performance-cache.yaml"
  ttl: "Until src/ files or package.json change"
  invalidate_on:
    - "Any .tsx/.jsx file modified"
    - "package.json modified (dependency changes)"
    - "Build config modified (vite.config, next.config)"
    - "User runs *discover-performance explicitly"
```

---

*Apex Squad — Discover Performance Task v1.0.0*
