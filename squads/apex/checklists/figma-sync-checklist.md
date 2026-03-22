# Figma-Code Sync Validation Checklist — Apex Squad

> Reviewer: design-sys-eng
> Purpose: Ensure design tokens in Figma and code remain synchronized with zero drift.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Naming Match

- [ ] Figma Variable names match code token names exactly (case-sensitive)
- [ ] Token hierarchy in Figma matches code hierarchy (group/collection structure)
- [ ] Variable modes in Figma match code mode names (light, dark, high-contrast)
- [ ] No abbreviated names in one system that are spelled out in the other
- [ ] Figma component names match code component names
- [ ] Naming convention documented and agreed upon by design and engineering

---

## 2. Value Match

- [ ] Primitive token values are identical between Figma and code
- [ ] Semantic token mappings are identical (same primitive references)
- [ ] Mode-specific values match across all modes (light, dark, high-contrast)
- [ ] Alias/reference chains resolve to the same final value
- [ ] Typography values match (size, weight, line-height, letter-spacing)
- [ ] Spacing values match the same scale
- [ ] Border radius values match

---

## 3. Pipeline

- [ ] Style Dictionary (or equivalent) configured and running
- [ ] CI pipeline runs token sync validation on push
- [ ] Drift detection active — alerts on Figma/code mismatch
- [ ] Token export format matches the expected input (JSON, YAML, etc.)
- [ ] Build step generates platform-specific outputs (CSS, JS, iOS, Android)
- [ ] Pipeline tested end-to-end after token changes

---

## 4. Completeness

- [ ] All Figma Variables have corresponding code tokens
- [ ] All code tokens have corresponding Figma Variables
- [ ] No orphan tokens in either system (unused or unmatched)
- [ ] New tokens added in this change exist in both Figma and code
- [ ] Deprecated tokens marked in both Figma and code
- [ ] Token inventory report generated and reviewed

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Figma File Link | |
| Result | APPROVED / BLOCKED |
| Notes | |
