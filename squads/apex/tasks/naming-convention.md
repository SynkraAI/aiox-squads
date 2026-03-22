# Task: naming-convention

```yaml
id: naming-convention
version: "1.0.0"
title: "Naming Convention Enforcement"
description: >
  Enforce design token naming conventions across the token architecture.
  Validates the {category}.{property}.{variant}.{state} format, ensures
  names describe purpose rather than values, verifies no color names
  appear in semantic tokens, applies the rebrand test, and documents
  all naming decisions.
elicit: false
owner: design-sys-eng
executor: design-sys-eng
outputs:
  - Naming convention validation report
  - List of naming violations with corrections
  - Rebrand test results
  - Updated naming decision documentation
```

---

## When This Task Runs

This task runs when:
- New tokens are being created and need name validation
- A batch of tokens is being renamed or restructured
- A token audit flags naming inconsistencies
- The team is establishing naming conventions for a new token category
- A rebranding exercise requires validating name independence from values

This task does NOT run when:
- The task is about token values, not names (use `token-architecture`)
- The task is about finding hardcoded values (use `token-audit`)
- The task is about Figma variable naming (use `figma-sync-setup`)

---

## Naming Format

```
{category}.{property}.{variant}.{state}
```

| Segment | Required | Description | Examples |
|---------|----------|-------------|---------|
| category | YES | The token type | `color`, `space`, `text`, `radius`, `shadow`, `motion` |
| property | YES | What it applies to | `bg`, `text`, `border`, `icon`, `inline`, `stack` |
| variant | OPTIONAL | Which variation | `default`, `subtle`, `accent`, `muted`, `inverse` |
| state | OPTIONAL | Interactive state | `hover`, `active`, `focus`, `disabled` |

**Examples:**
- `color.bg.default` — default background color
- `color.text.muted` — secondary/muted text color
- `color.border.focus` — border color for focus state
- `space.inline.md` — medium horizontal spacing
- `text.heading.lg` — large heading text style
- `color.bg.accent.hover` — accent background on hover

---

## Execution Steps

### Step 1: Validate Format

Check every token name against the naming format:

1. Parse each token name into its segments (split by `.`)
2. Validate the category segment:
   - Must be from the allowed list: `color`, `space`, `text`, `radius`, `shadow`, `motion`, `size`, `opacity`, `z-index`
   - Flag unknown categories for review (may need to add to allowed list)
3. Validate the property segment:
   - Must be present (minimum 2 segments required)
   - Must be descriptive of the application target
4. Validate optional segments:
   - Variant must use semantic names (`default`, `subtle`, `accent`), not values
   - State must be from: `hover`, `active`, `focus`, `disabled`, `pressed`, `selected`
5. Check for naming anti-patterns:
   - Too many segments (> 4 is suspicious)
   - Too few segments for a semantic token (< 2)
   - Inconsistent separator (mixing `.` and `-` within a name)

Report:
| Token Name | Valid | Issue |
|-----------|-------|-------|
| color.bg.default | YES | — |
| bg-color-primary | NO | Wrong separator, wrong order |
| color.blue.500 | NO | Value-based name in semantic layer |

### Step 2: Check Names Describe Purpose, Not Value

Verify that semantic and component token names are value-agnostic:

1. Scan for color-value words in token names:
   - **BLOCKED words:** `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`,
     `gray`, `grey`, `black`, `white`, `indigo`, `violet`, `teal`, `cyan`
   - **ALLOWED context:** primitive token layer only (e.g., `blue.500` is valid as a primitive)
2. Scan for size-value words:
   - **BLOCKED:** `4px`, `8px`, `16px`, `small-pixel`, `large-pixel`
   - **ALLOWED:** `sm`, `md`, `lg`, `xl` (abstract size names)
3. Scan for specificity that ties to current implementation:
   - `color.bg.header` — too specific (what if the header changes?)
   - `color.bg.subtle` — purpose-driven (correct)
4. For each violation, propose a purpose-driven alternative

### Step 3: Verify No Color Names in Semantic Tokens

Deep scan for color-value leakage into semantic and component layers:

1. Check the semantic token layer:
   - No token name should contain a color name
   - `color.text.blue` → VIOLATION (should be `color.text.accent` or `color.text.info`)
   - `color.bg.gray` → VIOLATION (should be `color.bg.subtle` or `color.bg.muted`)
2. Check the component token layer:
   - `button.bg.blue` → VIOLATION (should be `button.bg.primary`)
   - `card.border.gray` → VIOLATION (should be `card.border.default`)
3. Check for indirect color references:
   - `color.bg.sky` → VIOLATION (sky implies blue)
   - `color.text.forest` → VIOLATION (forest implies green)
4. Produce a violation list with suggested renames

### Step 4: Apply Rebrand Test

Validate that a rebrand would not require renaming tokens:

1. **The test:** Imagine the brand color changes from blue to green (or any other color).
   Would any semantic or component token name become misleading?
2. Walk through the token list:
   - `color.bg.accent` → Would this name still work with green? YES (passes)
   - `color.bg.brand-blue` → Would this name work with green? NO (fails)
3. Test with a second scenario: the brand adds a warm palette.
   - Do any token names imply a cool palette? (e.g., `cool-surface`, `ice-bg`)
4. For each failure:
   - Propose a value-agnostic rename
   - Estimate the migration cost (how many consumers reference this token)
5. Report the rebrand test results:

| Token | Passes Rebrand Test? | Issue | Proposed Name |
|-------|---------------------|-------|---------------|
| color.bg.accent | YES | — | — |
| color.bg.blue-tint | NO | Color in name | color.bg.accent.subtle |

### Step 5: Document Naming Decisions

Record all naming conventions and decisions:

1. **Naming reference table:**
   - Allowed categories and their meanings
   - Allowed properties per category
   - Standard variant and state names
2. **Decision log:**
   - Why certain names were chosen over alternatives
   - Edge cases and how they were resolved
   - Exceptions and their justification
3. **Migration notes:**
   - Renames applied and the before/after
   - Deprecated names with their replacements
4. Update the documentation in `docs/architecture/token-naming.md`
5. If a lint rule exists, update it with new conventions

---

## Naming Quick Reference

| Instead of | Use |
|-----------|-----|
| `color.blue.500` (semantic) | `color.bg.accent` |
| `color.text.gray` | `color.text.muted` |
| `color.bg.white` | `color.bg.default` |
| `color.bg.dark` | `color.bg.inverse` |
| `button.bg.green` | `button.bg.success` |
| `spacing.16px` | `space.stack.md` |
| `font.large` | `text.body.lg` |

---

## Abbreviation Standards

Only these abbreviations are allowed in token names:

| Abbreviation | Full Form |
|-------------|-----------|
| `bg` | background |
| `sm` | small |
| `md` | medium |
| `lg` | large |
| `xl` | extra large |
| `xxl` | extra extra large |
| `xs` | extra small |
| `a11y` | accessibility |

All other words must be spelled out.

---

*Apex Squad — Naming Convention Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-naming-convention
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Every token name must be validated against the {category}.{property}.{variant}.{state} format"
    - "No color-value words may appear in semantic or component token names"
    - "Rebrand test must pass for all semantic and component tokens"
    - "Violations must include specific correction proposals"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Naming convention validation report with violations, corrections, and rebrand test results |
| Next action | Apply naming corrections across the token architecture and update documentation |
