# Task: token-architecture

```yaml
id: token-architecture
version: "1.0.0"
title: "Token Architecture"
description: >
  Create or audit the design token architecture. Defines three token layers
  (primitive, semantic, component), ensures all mode values are specified
  (light, dark, high-contrast), validates naming conventions, and generates
  code artifacts for consumption by the codebase.
elicit: false
owner: design-sys-eng
executor: design-sys-eng
outputs:
  - Token architecture document
  - Primitive token definitions
  - Semantic token definitions
  - Component token definitions
  - Generated code artifacts (CSS custom properties / JS tokens)
```

---

## When This Task Runs

This task runs when:
- A new color, spacing, or typography scale is being introduced
- The design system is being initialized for the first time
- A token audit reveals missing mode values or inconsistencies
- A rebranding requires updating the token hierarchy
- A new mode (e.g., dark-high-contrast) needs to be added

This task does NOT run when:
- The task is about using existing tokens in a component (route to `@css-eng`)
- The task is about layout or responsive behavior (route to `@interaction-dsgn`)
- The task is about animation timing (route to `@motion-eng`)

---

## Token Layer Model

```
┌─────────────────────────────────────────────┐
│  Component Tokens    (scoped to component)  │
│  e.g., button.bg.primary                    │
├─────────────────────────────────────────────┤
│  Semantic Tokens     (purpose-driven)       │
│  e.g., color.bg.accent                      │
├─────────────────────────────────────────────┤
│  Primitive Tokens    (raw values)           │
│  e.g., blue.500 = #3B82F6                   │
└─────────────────────────────────────────────┘
```

Consumers reference semantic or component tokens. Primitive tokens are NEVER used directly in application code.

---

## Execution Steps

### Step 1: Define Primitive Tokens

Create the raw value palette:

1. **Colors:**
   - Define color scales: `gray`, `blue`, `green`, `red`, `yellow`, `purple` (50-950)
   - Include pure values: `white`, `black`, `transparent`
   - Use consistent hue and saturation progression
   - Document the color space (sRGB, P3, oklch)
2. **Spacing:**
   - Define a spacing scale: `0`, `1` (4px), `2` (8px), `3` (12px), `4` (16px), etc.
   - Base unit: 4px grid
   - Include negative values if needed for offsets
3. **Typography:**
   - Font families: `sans`, `serif`, `mono`
   - Font sizes: scale from `xs` (12px) to `4xl` (36px)
   - Font weights: `regular` (400), `medium` (500), `semibold` (600), `bold` (700)
   - Line heights: `tight` (1.25), `normal` (1.5), `relaxed` (1.75)
4. **Sizing:**
   - Border radius: `none`, `sm`, `md`, `lg`, `full`
   - Border width: `thin` (1px), `medium` (2px), `thick` (4px)
   - Shadows: `sm`, `md`, `lg`, `xl`
5. **Motion:**
   - Duration: `fast` (100ms), `normal` (200ms), `slow` (300ms), `slower` (500ms)
   - Easing: `ease-out`, `ease-in-out`, `spring`

### Step 2: Create Semantic Tokens

Map primitive values to purpose-driven names:

1. **Color semantics:**
   - `color.bg.default` — main background
   - `color.bg.subtle` — secondary background
   - `color.bg.accent` — brand accent background
   - `color.text.default` — primary text
   - `color.text.muted` — secondary text
   - `color.text.inverse` — text on dark backgrounds
   - `color.border.default` — standard borders
   - `color.border.focus` — focus ring color
   - `color.status.success`, `.warning`, `.error`, `.info`
2. **Spacing semantics:**
   - `space.inline.sm`, `.md`, `.lg` — horizontal spacing
   - `space.stack.sm`, `.md`, `.lg` — vertical spacing
   - `space.inset.sm`, `.md`, `.lg` — padding
3. **Typography semantics:**
   - `text.heading.lg`, `.md`, `.sm` — heading styles
   - `text.body.lg`, `.md`, `.sm` — body text styles
   - `text.label.md`, `.sm` — form labels and captions
4. Verify every semantic token maps to a primitive token (no raw values)

### Step 3: Create Component Tokens

Define tokens scoped to specific components:

1. For each design system component, create scoped tokens:
   ```
   button.bg.primary → color.bg.accent
   button.bg.primary.hover → color.bg.accent (darkened)
   button.text.primary → color.text.inverse
   button.border.primary → transparent
   button.radius → radius.md
   ```
2. Component tokens reference semantic tokens (not primitives)
3. Include all interactive states: default, hover, active, focus, disabled
4. Keep the token count per component minimal (< 20 tokens)
5. Document which semantic token each component token maps to

### Step 4: Define Values for ALL Modes

Ensure every semantic and component token has values for every mode:

1. **Light mode** (default) — the primary mode values
2. **Dark mode** — inverted or adjusted for dark backgrounds
3. **High-contrast mode** — enhanced contrast for accessibility
4. **Dark high-contrast** — dark mode with enhanced contrast

For each mode, verify:
- Text-on-background contrast meets WCAG AA (4.5:1 for normal text, 3:1 for large text)
- Focus indicators are visible against the background
- Status colors remain distinguishable
- Interactive states have sufficient visual differentiation

Create a mode comparison matrix:

| Token | Light | Dark | High Contrast | Dark HC |
|-------|-------|------|--------------|---------|
| color.bg.default | white | gray.900 | white | black |
| color.text.default | gray.900 | gray.100 | black | white |

### Step 5: Validate Naming Conventions

Ensure all tokens follow the naming standard:

1. Format: `{category}.{property}.{variant}.{state}`
   - `color.bg.accent.hover`
   - `text.body.md`
   - `space.stack.lg`
2. Names describe PURPOSE, not VALUE:
   - `color.bg.accent` (purpose) not `color.bg.blue` (value)
   - `color.text.muted` (purpose) not `color.text.gray` (value)
3. **Rebrand test:** Could you change the brand color from blue to green without renaming any semantic or component tokens? If not, the naming is wrong.
4. No abbreviations except established ones (`bg`, `sm`, `md`, `lg`)
5. Consistent ordering: category → property → variant → state

### Step 6: Generate Code Artifacts

Produce the token files for the codebase:

1. **CSS Custom Properties:**
   ```css
   :root {
     --color-bg-default: #ffffff;
     --color-text-default: #111827;
   }
   [data-theme="dark"] {
     --color-bg-default: #111827;
     --color-text-default: #f3f4f6;
   }
   ```
2. **TypeScript constants** (for programmatic access):
   ```typescript
   export const tokens = {
     color: { bg: { default: 'var(--color-bg-default)' } }
   } as const;
   ```
3. **Style Dictionary config** (if using Style Dictionary for transforms)
4. Verify generated artifacts match the token definitions
5. Add generated files to the build pipeline

---

## Quality Checklist

- [ ] All three token layers defined (primitive, semantic, component)
- [ ] All modes have values (light, dark, high-contrast, dark-high-contrast)
- [ ] Naming follows {category}.{property}.{variant}.{state} format
- [ ] Passes rebrand test (no value-based names in semantic/component layers)
- [ ] Contrast ratios verified for all modes (WCAG AA minimum)
- [ ] Code artifacts generated and build-integrated

---

*Apex Squad — Token Architecture Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-token-architecture
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "All three token layers must be defined (primitive, semantic, component)"
    - "All modes must have values (light, dark, high-contrast, dark-high-contrast)"
    - "Naming must follow {category}.{property}.{variant}.{state} format and pass rebrand test"
    - "Code artifacts must be generated and build-integrated"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Token architecture document, primitive/semantic/component token definitions, and generated code artifacts (CSS custom properties / JS tokens) |
| Next action | Route to `@css-eng` for integration into stylesheets and to `@qa-visual` for `theme-visual-testing` validation |
