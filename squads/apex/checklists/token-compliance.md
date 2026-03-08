# Token Usage Compliance Checklist — Apex Squad

> Reviewer: design-sys-eng
> Purpose: Ensure all visual values reference design tokens and follow the token hierarchy.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Colors

- [ ] Zero hardcoded hex values (`#fff`, `#3b82f6`, etc.) in component code
- [ ] Zero hardcoded `rgb()` or `hsl()` values in component code
- [ ] Semantic tokens used — not primitive tokens directly (e.g., `color.text.primary` not `blue.500`)
- [ ] Correct token hierarchy followed: primitive -> semantic -> component
- [ ] Background/foreground pairs use matched semantic tokens for guaranteed contrast
- [ ] Opacity values use token scale if defined

---

## 2. Spacing

- [ ] All spacing values use the token scale (`spacing.1`, `spacing.2`, etc.)
- [ ] All values align to the 4px grid (4, 8, 12, 16, 20, 24, 32, 40, 48, 64)
- [ ] No magic numbers for padding, margin, or gap
- [ ] Consistent spacing used for similar contexts (card padding, section gaps)
- [ ] Negative spacing avoided — layout restructured if needed
- [ ] Component internal spacing uses component-level tokens where defined

---

## 3. Typography

- [ ] Font sizes reference the type scale tokens (no arbitrary `font-size: 13px`)
- [ ] Line heights use tokenized values matching the type scale
- [ ] Font weights use tokenized values (`font.weight.regular`, `font.weight.bold`)
- [ ] Letter spacing uses token values where specified in the design system
- [ ] Font family references the token stack — no inline font declarations
- [ ] Text styles compose from type scale tokens (e.g., `text.body.md`)

---

## 4. Borders

- [ ] Border radius values reference `radius.*` tokens
- [ ] Border colors use semantic tokens (`border.default`, `border.subtle`, etc.)
- [ ] Box shadows use `elevation.*` tokens — no hardcoded shadow values
- [ ] Border widths use token scale if defined (`border.width.thin`, `border.width.thick`)
- [ ] Outline styles for focus states use tokenized values
- [ ] Divider styles use the designated token

---

## 5. Naming

- [ ] Token names describe purpose, not value (e.g., `color.text.error` not `color.red`)
- [ ] No color names in semantic tokens (`danger` not `red`, `success` not `green`)
- [ ] Consistent dot notation used throughout (`category.property.variant`)
- [ ] Component tokens reference semantic tokens, not primitives
- [ ] Custom tokens follow the established naming convention
- [ ] No duplicate tokens with different names for the same purpose

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
