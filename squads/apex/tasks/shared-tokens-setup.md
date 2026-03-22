# Task: shared-tokens-setup

```yaml
id: shared-tokens-setup
version: "1.0.0"
title: "Shared Design Tokens Setup"
description: >
  Sets up a shared design token system that works across web and
  native platforms. Uses Style Dictionary as the single source of
  truth, configured to output CSS custom properties for web and
  React Native StyleSheet-compatible values for native. Includes
  a build pipeline, parity validation, and usage documentation.
elicit: false
owner: cross-plat-eng
executor: cross-plat-eng
outputs:
  - Token source definitions (Style Dictionary)
  - Web output (CSS custom properties)
  - Native output (React Native compatible)
  - Build pipeline configuration
  - Token parity validation report
  - Usage documentation
```

---

## When This Task Runs

This task runs when:
- A cross-platform project needs consistent design values across web and native
- Design tokens exist in Figma but not in code
- Tokens are duplicated between web CSS and native StyleSheet and are drifting apart
- A design system migration requires a single source of truth for tokens
- `*shared-tokens` or `*setup-tokens` is invoked

This task does NOT run when:
- Tokens are web-only (use CSS custom properties directly)
- Tokens are native-only (use a React Native theme directly)
- The task is about component design (use `universal-component-design`)

---

## Execution Steps

### Step 1: Define Token Source (Style Dictionary)

Create the token source files in a platform-agnostic JSON format.

```
packages/tokens/
├── src/
│   ├── color/
│   │   ├── base.json          # Primitive color palette
│   │   ├── semantic.json      # Semantic color mappings
│   │   └── component.json     # Component-specific color tokens
│   ├── spacing/
│   │   └── scale.json         # Spacing scale (4px base)
│   ├── typography/
│   │   ├── font-family.json
│   │   ├── font-size.json
│   │   ├── font-weight.json
│   │   └── line-height.json
│   ├── radius/
│   │   └── scale.json
│   ├── shadow/
│   │   └── elevation.json
│   └── motion/
│       ├── duration.json
│       └── easing.json
├── config.js                  # Style Dictionary config
├── package.json
└── tsconfig.json
```

Token format example:
```json
{
  "color": {
    "primary": {
      "50":  { "value": "#eff6ff", "type": "color" },
      "100": { "value": "#dbeafe", "type": "color" },
      "500": { "value": "#3b82f6", "type": "color" },
      "600": { "value": "#2563eb", "type": "color" },
      "900": { "value": "#1e3a5f", "type": "color" }
    },
    "semantic": {
      "background": { "value": "{color.primary.50}", "type": "color" },
      "foreground": { "value": "{color.primary.900}", "type": "color" },
      "action": { "value": "{color.primary.600}", "type": "color" }
    }
  }
}
```

Token design rules:
- Use three-tier naming: primitive → semantic → component
- Primitives are raw values (color-blue-500)
- Semantics map meaning to primitives (color-action → color-blue-600)
- Components reference semantics (button-bg → color-action)
- All references use Style Dictionary alias syntax (`{path.to.token}`)

**Output:** Token source files in Style Dictionary JSON format.

### Step 2: Configure Web Output (CSS Custom Properties)

Set up Style Dictionary to generate CSS custom properties for web consumption.

```javascript
// Style Dictionary web platform config
{
  platforms: {
    web: {
      transformGroup: 'css',
      buildPath: 'dist/web/',
      files: [
        {
          destination: 'tokens.css',
          format: 'css/variables',
          options: {
            selector: ':root'
          }
        },
        {
          destination: 'tokens.ts',
          format: 'javascript/es6'
        }
      ]
    }
  }
}
```

Generated CSS output:
```css
:root {
  --color-primary-50: #eff6ff;
  --color-primary-500: #3b82f6;
  --color-primary-600: #2563eb;
  --color-semantic-background: var(--color-primary-50);
  --color-semantic-foreground: var(--color-primary-900);
  --color-semantic-action: var(--color-primary-600);
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-4: 1rem;
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;
}
```

Also generate a TypeScript module for type-safe token access in JavaScript:
```typescript
export const colorPrimary500 = '#3b82f6';
export const colorSemanticAction = '#2563eb';
export const spacing4 = '1rem';
```

**Output:** CSS custom properties and TypeScript module for web.

### Step 3: Configure Native Output (React Native StyleSheet)

Set up Style Dictionary to generate React Native compatible token values.

```javascript
// Style Dictionary native platform config
{
  platforms: {
    native: {
      transformGroup: 'react-native',
      buildPath: 'dist/native/',
      files: [
        {
          destination: 'tokens.ts',
          format: 'javascript/es6'
        }
      ],
      transforms: [
        'name/cti/camel',
        'size/pxToNumber',  // Custom: strips 'px' and converts to number
        'color/hex'
      ]
    }
  }
}
```

Key transform differences:
- Web spacing: `'1rem'` (string with unit)
- Native spacing: `16` (number, no unit — React Native uses density-independent pixels)
- Web colors: `#3b82f6` or `rgb()` (string)
- Native colors: `'#3b82f6'` (string — same format works)
- Web shadows: `box-shadow: 0 4px 6px rgba(0,0,0,0.1)`
- Native shadows: `{ shadowOffset: { width: 0, height: 4 }, shadowRadius: 6, shadowOpacity: 0.1, elevation: 4 }`

Custom transform for shadow tokens:
```javascript
StyleDictionary.registerTransform({
  name: 'shadow/native',
  type: 'value',
  matcher: (token) => token.type === 'shadow',
  transformer: (token) => ({
    shadowColor: token.value.color,
    shadowOffset: { width: token.value.x, height: token.value.y },
    shadowOpacity: token.value.opacity,
    shadowRadius: token.value.blur,
    elevation: token.value.elevation,
  })
});
```

**Output:** React Native compatible token module.

### Step 4: Set Up Build Pipeline

Configure the token build process to run as part of the monorepo build.

```json
// packages/tokens/package.json
{
  "name": "@app/tokens",
  "scripts": {
    "build": "style-dictionary build",
    "build:watch": "nodemon --watch src -e json --exec 'style-dictionary build'",
    "clean": "rm -rf dist"
  }
}
```

Turborepo integration:
- Tokens build BEFORE any consuming package (`dependsOn: ["^build"]` in consumers)
- Token changes invalidate all downstream builds
- Dev mode watches token source files and rebuilds on change

Build pipeline:
```
1. Token source JSON (single source of truth)
   ↓
2. Style Dictionary transforms (platform-specific)
   ↓
3. Web output: CSS + TypeScript
   Native output: TypeScript with number values
   ↓
4. Consuming apps import from @app/tokens
```

Add to CI:
- Token build runs before app builds
- Token parity check runs in CI (Step 5)
- Failed parity check blocks the build

**Output:** Build pipeline configuration integrated with Turborepo.

### Step 5: Validate Token Parity

Create a validation script that ensures web and native outputs are in sync.

```typescript
// packages/tokens/scripts/validate-parity.ts
import webTokens from '../dist/web/tokens';
import nativeTokens from '../dist/native/tokens';

function validateParity() {
  const webKeys = Object.keys(webTokens);
  const nativeKeys = Object.keys(nativeTokens);

  // Check every web token has a native equivalent
  const missingInNative = webKeys.filter(k => !nativeKeys.includes(k));
  const missingInWeb = nativeKeys.filter(k => !webKeys.includes(k));

  if (missingInNative.length > 0) {
    console.error('Tokens missing in native:', missingInNative);
  }
  if (missingInWeb.length > 0) {
    console.error('Tokens missing in web:', missingInWeb);
  }

  // Validate color values match (format may differ, value must be same)
  // Validate spacing ratios are equivalent
}
```

Parity checks:
- **Count parity:** Same number of tokens in web and native outputs
- **Name parity:** Every token name exists in both outputs
- **Value parity:** Color values resolve to the same hex, spacing values have correct px↔number mapping
- **Semantic parity:** Semantic tokens reference the same primitives on both platforms

**Output:** Parity validation script and CI integration.

### Step 6: Document Usage

Create usage documentation for consuming tokens across platforms.

**Web usage:**
```tsx
// Import CSS file in layout
import '@app/tokens/dist/web/tokens.css';

// Use in CSS
.button { background: var(--color-semantic-action); }

// Use in JS (type-safe)
import { colorSemanticAction } from '@app/tokens';
```

**Native usage:**
```tsx
import { colorSemanticAction, spacing4 } from '@app/tokens/native';

const styles = StyleSheet.create({
  button: {
    backgroundColor: colorSemanticAction,
    padding: spacing4,
  }
});
```

**NativeWind usage (unified):**
```tsx
// If NativeWind Tailwind config uses tokens, same classes work everywhere
<Button className="bg-action p-4" />
```

Document:
- How to add a new token
- How to modify an existing token
- How to add a new token category
- How to use tokens in each platform
- How to run the build and parity check

**Output:** Token usage documentation.

---

## Quality Criteria

- All tokens must exist in both web and native outputs (100% parity)
- Web and native color values must resolve to the same visual color
- Spacing values must be proportionally equivalent across platforms
- The build pipeline must be automated (no manual token generation)
- Token changes must invalidate downstream builds

---

*Squad Apex — Shared Design Tokens Setup Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-shared-tokens-setup
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "All tokens must exist in both web and native outputs (100% parity)"
    - "Web and native color values must resolve to the same visual color"
    - "Build pipeline must be automated with no manual token generation"
    - "Parity validation script must run in CI and block on failures"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@design-sys-eng` or `@apex-lead` |
| Artifact | Token source definitions (Style Dictionary), web output (CSS custom properties), native output (React Native compatible), build pipeline, parity validation, and usage documentation |
| Next action | Integrate tokens into design system via `@design-sys-eng` and coordinate CI pipeline with `@devops` |
