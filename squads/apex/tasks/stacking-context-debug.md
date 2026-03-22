# Task: stacking-context-debug

```yaml
id: stacking-context-debug
version: "1.0.0"
title: "Stacking Context Debug"
description: >
  Debugs and resolves stacking context issues where elements appear
  above or below other elements unexpectedly. Uses a systematic
  approach: map the stacking context tree, identify unintentional
  context creation, trace z-index resolution chains, and fix at
  the context level rather than inflating z-index values.
elicit: false
owner: css-eng
executor: css-eng
outputs:
  - Root cause identification of stacking issue
  - Stacking context tree for affected area
  - Fix applied at context level (not value level)
  - Verification that fix does not introduce regressions
```

---

## When This Task Runs

This task runs when:
- An element appears behind another element unexpectedly (modal behind overlay, dropdown behind sibling)
- Z-index values are being increased but the problem persists
- A CSS change in one area unexpectedly affects layering in another area
- The team is experiencing "z-index wars" (escalating values like 999, 9999)
- `*debug-stacking` or `*z-index-fix` is invoked

This task does NOT run when:
- A full CSS architecture audit is needed (use `css-architecture-audit`)
- The issue is purely a layout problem (not z-axis related)
- The issue is JavaScript-based visibility toggling, not CSS stacking

---

## Execution Steps

### Step 1: Map the Stacking Context Tree

Build a visual map of the stacking context hierarchy for the affected area of the DOM.

- Start from the root stacking context (`<html>`)
- Walk down the DOM tree, identifying every element that creates a new stacking context
- A new stacking context is created by ANY of these properties:
  - `position: absolute/relative/fixed/sticky` WITH `z-index` set (not `auto`)
  - `opacity` less than 1
  - `transform` (any value other than `none`)
  - `filter` (any value other than `none`)
  - `backdrop-filter`
  - `perspective` (any value other than `none`)
  - `clip-path` (any value other than `none`)
  - `mask` / `mask-image`
  - `mix-blend-mode` (any value other than `normal`)
  - `isolation: isolate`
  - `will-change` specifying any property that would create a context
  - `contain: layout` or `contain: paint`
  - Flex/Grid children with `z-index` set (not `auto`)
- Record each context with its z-index value and parent context

**Output:** Stacking context tree showing the hierarchy from root to the affected elements.

### Step 2: Identify Unintentional Context Creation

Review the stacking context tree for contexts that were created as side effects, not intentionally.

Common culprits:
- `opacity: 0.99` or transitions that pass through opacity < 1
- `transform: translateZ(0)` or `translate3d(0,0,0)` used as "GPU acceleration hacks"
- `will-change: transform` left on elements permanently instead of applied on hover/focus
- `filter: drop-shadow(...)` on a parent element that now isolates its children
- CSS animations that set `transform` in keyframes, creating contexts only during animation
- Libraries or frameworks that inject `transform`, `opacity`, or `filter` (e.g., animation libraries, lazy loading)

For each unintentional context, assess:
- Why was this property set? Is it needed?
- Can it be removed without breaking other behavior?
- If it must stay, can `isolation: isolate` be used to contain its effects?

**Output:** List of unintentional stacking contexts with recommended actions.

### Step 3: Trace Z-Index Resolution Chain

For the specific elements that are stacking incorrectly, trace the full z-index resolution path.

Key insight: **z-index only competes within the same stacking context.** An element with `z-index: 999999` will STILL appear behind an element with `z-index: 1` if the first element's stacking context parent has a lower z-index than the second element's stacking context parent.

- Identify the stacking context that contains the "behind" element
- Identify the stacking context that contains the "in front" element
- Find their common ancestor stacking context
- Compare the z-index values of the immediate children of that common ancestor
- The problem is almost always at the ancestor level, not the element level

**Output:** Resolution chain showing exactly where the z-index comparison fails.

### Step 4: Fix at the Context Level, Not the Value Level

Apply the fix by restructuring stacking contexts, not by increasing z-index values.

Preferred fix strategies (in order):
1. **Remove the unintentional context** — If a parent has `transform` or `opacity` creating an unwanted context, remove or restructure
2. **Use `isolation: isolate`** — Create an intentional context boundary to contain the problem
3. **Restructure DOM order** — Elements later in the DOM stack higher within the same context (no z-index needed)
4. **Set z-index on the correct ancestor** — Adjust the parent context's z-index, not the deeply nested child
5. **Last resort: z-index with intention** — If z-index must be used, define it in a centralized token system with clear documentation

Never do:
- Increase z-index to "a bigger number" without understanding the context tree
- Add `position: relative; z-index: N` to fight through an opaque context boundary
- Use values above 100 without documenting why in a z-index scale

**Output:** Applied fix with explanation of which stacking context was modified and why.

### Step 5: Verify Fix

Confirm the fix resolves the issue and does not introduce new stacking problems.

- Verify the originally broken interaction works correctly
- Check adjacent elements that share stacking contexts with the fixed elements
- Test with modals, dropdowns, tooltips, and other overlay elements that commonly compete for z-axis space
- Check across different viewport sizes (stacking issues can be viewport-dependent if layout changes create/destroy contexts)
- Verify no visual regressions in the surrounding area

**Output:** Verification confirmation with list of tested scenarios.

---

## Quality Criteria

- The root cause must be identified as a stacking context issue, not just "wrong z-index"
- The fix must not use z-index values above 100 unless justified and documented
- No `!important` should be used on z-index
- The stacking context tree must be documented for the fixed area
- The fix must not introduce new unintentional stacking contexts

---

*Squad Apex — Stacking Context Debug Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-stacking-context-debug
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Root cause must be identified as a stacking context issue, not just 'wrong z-index'"
    - "Fix must not use z-index values above 100 unless justified and documented"
    - "Fix must not introduce new unintentional stacking contexts"
    - "Verification must confirm no visual regressions in surrounding area"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` or `@qa-visual` |
| Artifact | Root cause identification, stacking context tree, applied fix at context level, and regression verification results |
| Next action | Route to `@qa-visual` for `visual-regression-audit` to confirm no regressions, or close if verified |
