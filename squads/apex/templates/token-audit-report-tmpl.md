# Token Audit Report

**Audit Date:** {YYYY-MM-DD}
**Auditor:** @design-sys-eng (Diana)
**Reviewed By:** @apex-lead (Emil)
**Status:** Clean | Action Required | Critical

## Scope

| Parameter | Value |
|-----------|-------|
| Packages audited | {packages/ui, packages/tokens, apps/web, etc.} |
| Files scanned | {number of files} |
| Token source of truth | {Figma file URL or token JSON path} |
| Previous audit | {date of last audit or "Initial audit"} |

## Summary

| Metric | Count | Status |
|--------|:-----:|:------:|
| Total design tokens | {N} | -- |
| Hardcoded values found | {N} | {OK if 0, WARN if < 5, CRITICAL if >= 5} |
| Token drift detected | {N} | {OK if 0, WARN if < 3, CRITICAL if >= 3} |
| Unused tokens | {N} | {OK if 0, WARN if < 10, INFO if >= 10} |
| Missing tokens (used but undefined) | {N} | {OK if 0, CRITICAL if > 0} |

### Verdict: {CLEAN | ACTION REQUIRED | CRITICAL}

{One sentence summary: "N hardcoded values and N token drifts require correction before next release."}

## Hardcoded Values

Values found in code that should reference design tokens instead.

| # | File | Line | Hardcoded Value | Type | Suggested Token |
|:-:|------|:----:|----------------|------|-----------------|
| 1 | {src/components/Card/Card.css.ts} | {42} | {#3b82f6} | color | `var(--color-accent-primary)` |
| 2 | {src/components/Modal/Modal.css.ts} | {18} | {16px} | spacing | `var(--spacing-4)` |
| 3 | {src/components/Button/Button.css.ts} | {27} | {0.875rem} | font-size | `var(--text-sm)` |
| {N} | {file path} | {line} | {value} | {color/spacing/font/shadow/radius} | {token reference} |

### Severity Breakdown
- **Critical** (color, brand): {N} items
- **High** (spacing, typography): {N} items
- **Medium** (shadow, radius, opacity): {N} items

## Token Drift

Tokens where the code value differs from the Figma source of truth.

| # | Token Name | Figma Value | Code Value | Delta | Severity |
|:-:|------------|:-----------:|:----------:|:-----:|:--------:|
| 1 | {--color-accent-primary} | {#2563eb} | {#3b82f6} | {different hue} | {HIGH} |
| 2 | {--spacing-4} | {16px} | {15px} | {1px} | {LOW} |
| 3 | {--text-base} | {1rem} | {0.9375rem} | {1px equivalent} | {MEDIUM} |
| {N} | {token name} | {figma value} | {code value} | {description} | {LOW/MEDIUM/HIGH} |

### Drift Resolution
| Resolution | Action |
|-----------|--------|
| Update code to match Figma | {list token names} |
| Update Figma to match code (intentional deviation) | {list token names} |
| Investigate — unclear which is correct | {list token names} |

## Unused Tokens

Tokens defined in `packages/tokens/` but not referenced in any component or application code.

| # | Token Name | Defined In | Last Used |
|:-:|------------|-----------|-----------|
| 1 | {--color-legacy-blue} | {tokens/color.json} | {Never / Removed in PR #123} |
| 2 | {--spacing-18} | {tokens/spacing.json} | {Unknown} |
| {N} | {token name} | {file} | {date or "Never"} |

### Cleanup Recommendation
- **Safe to remove:** {list token names with no references anywhere}
- **Verify before removing:** {list token names that might be used dynamically}
- **Keep (intentional reserve):** {list token names kept for future use}

## Missing Tokens

Semantic values used in code that have no corresponding token definition.

| # | File | Line | Value Used | Suggested Token Name |
|:-:|------|:----:|-----------|---------------------|
| 1 | {file path} | {line} | {value} | {--suggested-token-name} |

## Recommendations

### Immediate Actions (before next release)
1. {Fix N critical hardcoded color values — see Hardcoded Values table}
2. {Resolve N high-severity token drifts — see Token Drift table}
3. {Define N missing tokens — see Missing Tokens table}

### Short-term (next sprint)
1. {Remove N confirmed unused tokens — see Unused Tokens table}
2. {Add lint rule to prevent hardcoded {type} values}
3. {Update Figma variables to resolve drift}

### Long-term (next quarter)
1. {Implement automated token sync pipeline (Figma API to code)}
2. {Add CI check for hardcoded values in PR pipeline}
3. {Establish monthly audit cadence}

## Next Audit Date

**Scheduled:** {YYYY-MM-DD}
**Trigger:** {Monthly cadence / Before major release / After design system update}

## Appendix: Audit Methodology

| Step | Tool / Command | Purpose |
|------|---------------|---------|
| 1 | `grep -rn '#[0-9a-fA-F]{3,8}' packages/ui/` | Find hardcoded hex colors |
| 2 | `grep -rn '[0-9]+px' packages/ui/` | Find hardcoded pixel values |
| 3 | Token diff script against Figma API export | Detect token drift |
| 4 | Cross-reference token definitions vs usage | Find unused tokens |
| 5 | Manual review of flagged items | Verify false positives |
