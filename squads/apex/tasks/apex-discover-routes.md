# Task: apex-discover-routes

```yaml
id: apex-discover-routes
version: "1.0.0"
title: "Apex Discover Routes"
description: >
  Maps ALL routes/pages in the project. Detects orphan routes (no nav pointing),
  missing layouts, SEO gaps, dead routes, and route hierarchy. Produces a complete
  route inventory that feeds apex-entry routing and apex-audit.
elicit: false
owner: apex-lead
executor: frontend-arch
dependencies:
  - tasks/apex-scan.md
  - tasks/apex-discover-components.md
outputs:
  - Route inventory with component mapping
  - Orphan route list
  - SEO gap report
  - Route health score
```

---

## Command

### `*discover-routes`

Maps all routes in the project. Auto-detects routing strategy.

---

## How It Works

### Step 1: Detect Routing Strategy

```yaml
detection:
  strategies:
    - react_router:
        files: ["src/App.tsx", "src/routes.tsx", "src/router.tsx"]
        patterns: ["<Route", "<Routes", "createBrowserRouter", "createHashRouter"]
    - next_pages:
        files: ["pages/**/*.tsx", "pages/**/*.jsx"]
        patterns: ["export default"]
    - next_app:
        files: ["app/**/page.tsx", "app/**/page.jsx"]
        patterns: ["export default"]
    - expo_router:
        files: ["app/**/*.tsx", "app/_layout.tsx"]
        patterns: ["export default", "Stack", "Tabs"]
    - tanstack_router:
        files: ["src/routes/**/*.tsx"]
        patterns: ["createFileRoute", "createRootRoute"]

  result:
    strategy: "{detected strategy}"
    version: "{router version from package.json}"
    entry_point: "{main router file}"
```

### Step 2: Build Route Inventory

```yaml
inventory:
  per_route:
    path: "/example/:id"
    component: "ExamplePage"
    component_path: "src/pages/ExamplePage.tsx"
    layout: "MainLayout | null"
    params: ["id"]
    guards: ["AuthGuard | null"]
    lazy: true | false
    has_loading_state: true | false
    has_error_boundary: true | false
    linked_from: ["Nav.tsx:12", "Sidebar.tsx:45"]
    meta:
      title: "present | missing"
      description: "present | missing"
      og_image: "present | missing"

  aggregation:
    total_routes: N
    with_layout: N
    without_layout: N
    lazy_loaded: N
    not_lazy: N
    with_error_boundary: N
    without_error_boundary: N
```

### Step 3: Detect Issues

```yaml
issues:

  orphan_routes:
    description: "Routes defined but no navigation element points to them"
    detection: "Route exists in router config but path not found in any <Link>, <NavLink>, navigate(), router.push()"
    severity: MEDIUM

  dead_routes:
    description: "Routes that reference components that don't exist"
    detection: "Route component import resolves to missing file"
    severity: HIGH

  missing_layouts:
    description: "Pages rendered without a layout wrapper"
    detection: "Route has no parent layout route or wrapper component"
    severity: MEDIUM

  seo_gaps:
    description: "Pages missing essential meta tags"
    detection: "No <title>, <meta description>, or og:image in page or Head/Metadata"
    checks:
      - title: "Page has <title> or document.title or Metadata.title"
      - description: "Page has <meta name='description'>"
      - og_image: "Page has <meta property='og:image'>"
      - canonical: "Page has <link rel='canonical'>"
    severity: MEDIUM

  missing_error_boundary:
    description: "Route without error boundary (crash = white screen)"
    detection: "No ErrorBoundary wrapper in route tree"
    severity: HIGH

  missing_loading:
    description: "Lazy route without loading/suspense fallback"
    detection: "React.lazy() or dynamic import without <Suspense> wrapper"
    severity: MEDIUM

  duplicate_paths:
    description: "Two routes with same path (conflict)"
    detection: "Path string appears more than once in router config"
    severity: CRITICAL
```

### Step 4: Calculate Route Health Score

```yaml
health_score:
  formula: "100 - (penalties)"
  penalties:
    orphan_route: -3 each
    dead_route: -10 each
    missing_layout: -2 each
    missing_title: -2 each
    missing_description: -1 each
    missing_error_boundary: -5 each
    missing_loading_state: -3 each
    duplicate_path: -15 each
    not_lazy_loaded: -1 each (pages only)

  classification:
    90-100: "solid — routing well-structured"
    70-89: "good — minor gaps to address"
    50-69: "needs_work — significant routing issues"
    0-49: "critical — routing infrastructure broken"
```

### Step 5: Output

```yaml
output_format: |
  ## Route Discovery

  **Strategy:** {strategy} ({version})
  **Total Routes:** {total}
  **Route Health Score:** {score}/100 ({classification})

  ### Route Map
  | Path | Component | Layout | Lazy | SEO | Issues |
  |------|-----------|--------|------|-----|--------|
  | / | HomePage | MainLayout | No | OK | not lazy |
  | /about | AboutPage | MainLayout | Yes | OK | — |
  | /settings | SettingsPage | null | No | Missing title | no layout, not lazy |

  ### Issues Found
  | Issue | Count | Severity |
  |-------|-------|----------|
  | Orphan routes | {n} | MEDIUM |
  | Dead routes | {n} | HIGH |
  | Missing layouts | {n} | MEDIUM |
  | SEO gaps | {n} | MEDIUM |

  ### Options
  1. Corrigir issues HIGH ({high_count})
  2. Adicionar SEO meta tags faltando
  3. Adicionar lazy loading nas rotas restantes
  4. So quero o inventario
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-DR-001
    condition: "Dead route detected (component does not exist)"
    action: "VETO — Dead routes cause runtime crashes. Fix or remove."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK
```

---

## Cache

```yaml
cache:
  location: ".aios/apex-context/route-cache.yaml"
  ttl: "Until router config or pages/ directory changes"
  invalidate_on:
    - "Router config file modified"
    - "Any page component created or deleted"
    - "User runs *discover-routes explicitly"
```

---

*Apex Squad — Discover Routes Task v1.0.0*
