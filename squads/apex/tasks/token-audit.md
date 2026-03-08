# Task: token-audit

```yaml
id: token-audit
version: "1.0.0"
title: "Token Audit"
description: >
  Audit the codebase for hardcoded values and token drift. Scans for
  hardcoded colors and spacing, compares Figma Variables with code tokens,
  identifies unused tokens, checks that all tokens have mode values for
  every supported mode, and generates a comprehensive audit report.
elicit: false
owner: design-sys-eng
executor: design-sys-eng
outputs:
  - Hardcoded values report (colors, spacing)
  - Figma-to-code comparison matrix
  - Unused token list
  - Missing mode values report
  - Audit summary with severity ratings
```

---

## When This Task Runs

This task runs when:
- A periodic token health check is scheduled
- A PR introduces suspected hardcoded values
- New components are added without verified token usage
- Post-rebranding to verify all old values are replaced
- Before a major release to ensure token hygiene

This task does NOT run when:
- The task is about creating new tokens (use `token-architecture`)
- The task is about Figma export configuration (use `figma-sync-setup`)
- The task is about naming convention enforcement only (use `naming-convention`)

---

## Execution Steps

### Step 1: Scan for Hardcoded Color Values

Find all color values that should be tokens:

1. **Hex colors:**
   - Search for: `#[0-9a-fA-F]{3,8}` in stylesheets, components, and inline styles
   - Exclude: token definition files, config files, SVG files with design-intent colors
2. **RGB/HSL colors:**
   - Search for: `rgb(`, `rgba(`, `hsl(`, `hsla(`, `oklch(`
   - Exclude: token definition files
3. **Named colors:**
   - Search for CSS named colors: `white`, `black`, `red`, `blue`, `transparent`
   - `transparent` is often acceptable — flag but do not auto-fail
4. **Tailwind/utility hardcoded classes:**
   - Search for Tailwind classes with color values: `bg-blue-500`, `text-gray-900`
   - These should reference design token classes or CSS variables
5. Classify each finding:
   - **VIOLATION** — must be replaced with a token
   - **EXCEPTION** — justified hardcoded value (document reason)
   - **FALSE POSITIVE** — in a token file or non-UI code

Output:
| File | Line | Value | Type | Severity | Suggested Token |
|------|------|-------|------|----------|----------------|
| card.tsx | 15 | #f3f4f6 | Hex | VIOLATION | color.bg.subtle |
| logo.svg | 3 | #1E40AF | Hex | EXCEPTION | Brand asset |

### Step 2: Scan for Hardcoded Spacing Values

Find spacing values that should use tokens:

1. Search for pixel values in styles:
   - `margin`, `padding`, `gap`, `top`, `left`, `right`, `bottom`
   - `width`, `height` (when used for spacing, not sizing)
2. Identify values that match the spacing scale:
   - `4px`, `8px`, `12px`, `16px`, `24px`, `32px`, `48px`, `64px`
   - These almost certainly should be spacing tokens
3. Identify values NOT on the scale:
   - `5px`, `7px`, `13px`, `15px` — these suggest missing tokens or bugs
4. Exclude:
   - `0`, `1px` (borders), `100%`, `auto` — these are valid raw values
   - Token definition files
   - Calculated values (`calc()`, `clamp()`)
5. Classify and report with the same format as Step 1

### Step 3: Compare Figma Variables with Code Tokens

Detect drift between design and code:

1. Fetch the latest token values from Figma (or from the last Figma export JSON)
2. Load the committed token files from the codebase
3. Compare for each token:
   - **Name match** — does the token exist in both Figma and code?
   - **Value match** — is the value the same in both?
   - **Mode match** — are all mode values present and equal?
4. Categorize differences:
   - **Figma-only** — token defined in Figma but missing in code
   - **Code-only** — token defined in code but missing in Figma
   - **Value mismatch** — same name but different values
   - **In sync** — token matches exactly

Output:
| Token | Status | Figma Value | Code Value | Modes Affected |
|-------|--------|-------------|------------|----------------|
| color.bg.accent | MISMATCH | #6366F1 | #3B82F6 | light, dark |
| color.status.info | FIGMA-ONLY | #3B82F6 | — | — |
| space.inline.xs | CODE-ONLY | — | 4px | — |

### Step 4: Identify Unused Tokens

Find tokens that are defined but never referenced:

1. List all defined tokens from token source files
2. Search the codebase for each token reference:
   - CSS: `var(--{token-name})`
   - JS/TS: `tokens.{token.path}` or string reference
   - Tailwind: mapped utility class
3. Mark tokens with zero references as UNUSED
4. Distinguish between:
   - **Truly unused** — no consumer anywhere, candidate for removal
   - **Transitively used** — referenced by other tokens but not directly by components
   - **Recently added** — may not have consumers yet (within 2 weeks of creation)
5. Recommend action:
   - Remove truly unused tokens older than 30 days
   - Verify transitively-used tokens have a valid chain
   - Keep recently added tokens but flag for follow-up

### Step 5: Check All Tokens Have All Mode Values

Verify completeness of mode coverage:

1. For each token, check that values exist for:
   - Light mode
   - Dark mode
   - High-contrast mode
   - Dark high-contrast mode
2. Flag tokens with missing mode values:
   - **CRITICAL** — semantic token missing a mode (user-facing, visible issue)
   - **WARNING** — component token missing a mode (scoped impact)
   - **INFO** — primitive token missing a mode (may be intentional)
3. For each missing mode value, suggest the value based on:
   - The other mode values (interpolate contrast)
   - Similar tokens that have the mode defined
   - WCAG contrast requirements for the mode

### Step 6: Generate Audit Report

Compile the full audit report:

```markdown
# Token Audit Report

**Date:** {YYYY-MM-DD}
**Auditor:** @design-sys-eng

## Summary
| Category | Count | Severity |
|----------|-------|----------|
| Hardcoded colors | {N} | {CRITICAL/WARNING} |
| Hardcoded spacing | {N} | {WARNING} |
| Figma drift | {N} | {CRITICAL} |
| Unused tokens | {N} | {INFO} |
| Missing mode values | {N} | {CRITICAL/WARNING} |

## Detailed Findings
{Tables from Steps 1-5}

## Recommended Actions
1. {Priority action 1}
2. {Priority action 2}
...

## Verdict: {CLEAN | NEEDS ATTENTION | CRITICAL ISSUES}
```

---

## Automation

Consider automating recurring checks:

- **Pre-commit hook** — scan staged files for hardcoded colors/spacing
- **CI check** — run full audit on PRs that touch style files
- **Scheduled job** — weekly Figma drift comparison
- **Lint rule** — custom ESLint/Stylelint rule for hardcoded values

---

*Apex Squad — Token Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-token-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Every hardcoded color and spacing value must be classified (VIOLATION/EXCEPTION/FALSE POSITIVE)"
    - "Figma-to-code comparison must identify all drift (mismatches, Figma-only, code-only)"
    - "All tokens must be checked for mode value completeness across all supported modes"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Hardcoded values report, Figma-to-code comparison matrix, unused token list, missing mode values report, and audit summary with severity ratings |
| Next action | Route violations to `@css-eng` for token migration, Figma drift to `@design-sys-eng` for `figma-sync-setup`, and missing modes to `@design-sys-eng` for `token-architecture` |
