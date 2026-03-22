# Task: apex-scan

```yaml
id: apex-scan
version: "1.0.0"
title: "Apex Dynamic Project Scanner"
description: >
  Scans the current project on activation to dynamically detect stack, structure,
  design patterns, and project conventions. Feeds all other Apex operations with
  real project context — never hardcoded, always detected.
elicit: false
owner: apex-lead
executor: apex-lead
outputs:
  - Project context object (used internally by all Apex commands)
  - Profile selection with confidence level
  - Design system detection (tokens, variables, patterns)
  - Component inventory summary
```

---

## Command

### `*apex-scan`

Scans the current project and outputs a structured context report. Runs automatically on squad activation (silent mode) or explicitly by the user (verbose mode).

---

## Scan Phases

### Phase 1: Package Analysis

Read `package.json` (root and any `apps/*/package.json`, `packages/*/package.json`):

```yaml
extract:
  framework:
    - name: "next"
      detect: "next in dependencies"
      version_from: "dependencies.next"
    - name: "vite"
      detect: "vite in devDependencies"
      version_from: "devDependencies.vite"
    - name: "expo"
      detect: "expo in dependencies"
      version_from: "dependencies.expo"

  ui_library:
    - name: "react"
      detect: "react in dependencies"
      version_from: "dependencies.react"
    - name: "react-native"
      detect: "react-native in dependencies"
      version_from: "dependencies.react-native"

  styling:
    - name: "tailwindcss"
      detect: "tailwindcss in dependencies OR devDependencies"
    - name: "styled-components"
      detect: "styled-components in dependencies"
    - name: "css-modules"
      detect: "*.module.css files exist"
    - name: "sass"
      detect: "sass in devDependencies"

  animation:
    - name: "framer-motion"
      detect: "framer-motion OR motion in dependencies"
    - name: "react-spring"
      detect: "@react-spring/web in dependencies"
    - name: "gsap"
      detect: "gsap in dependencies"

  testing:
    - name: "vitest"
      detect: "vitest in devDependencies"
    - name: "jest"
      detect: "jest in devDependencies"
    - name: "playwright"
      detect: "@playwright/test in devDependencies"
    - name: "testing-library"
      detect: "@testing-library/react in devDependencies"

  icons:
    - name: "lucide"
      detect: "lucide-react in dependencies"
    - name: "heroicons"
      detect: "@heroicons/react in dependencies"
    - name: "phosphor"
      detect: "phosphor-react in dependencies"

  three_d:
    - name: "three"
      detect: "three in dependencies"
    - name: "r3f"
      detect: "@react-three/fiber in dependencies"
```

### Phase 2: Structure Detection

Scan the file system to understand project layout:

```yaml
structure_checks:
  monorepo:
    detect:
      - "apps/ directory exists"
      - "packages/ directory exists"
      - "pnpm-workspace.yaml OR lerna.json OR turbo.json exists"
    result: is_monorepo

  src_layout:
    scan: "src/ OR app/ directory"
    detect:
      components_dir: "src/components/ OR components/"
      pages_dir: "src/pages/ OR app/ (Next.js app router)"
      hooks_dir: "src/hooks/"
      utils_dir: "src/utils/ OR src/lib/"
      styles_dir: "src/styles/ OR src/css/"
      types_dir: "src/types/"

  component_count:
    count: "*.tsx files in components/"
    classify:
      small: "< 10 components"
      medium: "10-30 components"
      large: "> 30 components"

  route_count:
    count: "page.tsx files (Next.js) OR route files (React Router)"
    classify:
      simple: "< 5 routes"
      medium: "5-15 routes"
      complex: "> 15 routes"
```

### Phase 3: Design System Detection

Detect design patterns already in use:

```yaml
design_detection:
  css_variables:
    scan: "src/index.css OR src/globals.css OR styles/variables.css"
    extract:
      - "CSS custom properties (--*)"
      - "Color palette (--color-*)"
      - "Spacing scale (--spacing-*)"
      - "Typography scale (--font-*, --text-*)"
      - "Glass/effect variables (--glass-*, --blur-*)"

  tailwind_config:
    scan: "tailwind.config.js OR tailwind.config.ts"
    extract:
      - "Custom colors"
      - "Custom spacing"
      - "Custom fonts"
      - "Plugins"

  component_patterns:
    scan: "First 5 component files"
    detect:
      - "Glass morphism pattern (backdrop-blur, bg-opacity)"
      - "Spring animations (useSpring, motion.div)"
      - "Responsive pattern (sm: md: lg: or @media)"
      - "A11y pattern (aria-*, role=*, sr-only)"
      - "Dark mode pattern (dark: class or media query)"

  design_language:
    infer_from: "css_variables + component_patterns"
    possible_values:
      - "glass-morphism"
      - "material-design"
      - "flat-minimal"
      - "neomorphism"
      - "custom"
```

### Phase 4: Convention Detection

Detect coding conventions to follow:

```yaml
convention_detection:
  naming:
    components: "PascalCase OR kebab-case (from file names)"
    hooks: "use* pattern detected"
    utils: "camelCase OR snake_case"

  file_organization:
    colocation: "component + style + test in same dir?"
    barrel_exports: "index.ts re-exports?"
    feature_folders: "feature-based or type-based?"

  import_style:
    absolute: "@ aliases configured?"
    relative: "../ depth typical"

  state_management:
    detect:
      - "zustand in dependencies"
      - "jotai in dependencies"
      - "redux in dependencies"
      - "useState/useReducer only (local state)"
      - "React context pattern"
```

---

## Output: Project Context Object

The scan produces a structured context that all other Apex commands consume:

```yaml
project_context:
  name: "{from package.json}"
  path: "{absolute project path}"
  detected_at: "{ISO 8601}"

  stack:
    framework: "{next | vite | expo | cra | none}"
    framework_version: "{version}"
    ui: "{react | react-native}"
    ui_version: "{version}"
    styling: ["{tailwindcss | styled-components | css-modules | sass}"]
    animation: "{framer-motion | react-spring | gsap | none}"
    icons: "{lucide | heroicons | phosphor | none}"
    three_d: "{three+r3f | three | none}"
    testing: ["{vitest | jest | playwright | testing-library}"]
    state: "{zustand | jotai | redux | context | local}"
    typescript: true|false

  structure:
    type: "{monorepo | single-app}"
    components_count: N
    routes_count: N
    has_hooks_dir: true|false
    has_types_dir: true|false

  design:
    language: "{glass-morphism | material | flat | custom}"
    css_variables_count: N
    has_dark_mode: true|false
    has_reduced_motion: true|false
    tailwind_customized: true|false

  conventions:
    component_naming: "{PascalCase | kebab-case}"
    file_organization: "{colocation | type-based | feature-based}"
    import_style: "{absolute | relative}"

  profile: "{full | web-next | web-spa | minimal}"
  profile_confidence: "{high | medium | low}"
  active_agents: ["{agent-ids}"]
  skipped_agents: ["{agent-ids with reason}"]
```

---

## Activation Modes

### Silent Mode (on squad activation)

When Apex auto-activates from a user request:

```
1. Run scan silently (no output to user)
2. Store context internally
3. Use context for routing and profile selection
4. Only show profile if it differs from last scan
```

### Verbose Mode (`*apex-scan`)

When user explicitly runs the command:

```
APEX PROJECT SCAN
==================

Project: {name}
Path: {path}

STACK
-----
Framework: React 19 + Vite 6
Styling: Tailwind CSS 4
Animation: Motion (Framer Motion)
Icons: Lucide React
TypeScript: Yes
Testing: None detected

STRUCTURE
---------
Type: Single app
Components: 12 (medium)
Routes: 3 (simple)

DESIGN LANGUAGE
---------------
Detected: Glass morphism
CSS variables: 24 (colors, glass, spacing)
Dark mode: No
Reduced motion: Yes

CONVENTIONS
-----------
Components: PascalCase
Organization: Type-based (components/, pages/, hooks/)
Imports: Relative

PROFILE
-------
Selected: web-spa (confidence: HIGH)
Active agents: 8/15
Skipped: frontend-arch, design-sys-eng, mobile-eng, cross-plat-eng, spatial-eng, qa-xplatform, qa-visual

==================
```

---

## Cache & Invalidation

```yaml
cache:
  location: ".aios/apex-scan-cache.yaml"
  ttl: "current session"
  invalidate_on:
    - "package.json modified"
    - "New component file created"
    - "User runs *apex-scan explicitly"
    - "Profile override by user"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | Internal (all Apex commands consume this context) |
| Next action | Apex routes request using detected context |

---

*Apex Squad — Dynamic Project Scanner Task v1.0.0*
