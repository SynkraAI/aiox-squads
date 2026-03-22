# Multi-Mode Support Checklist — Apex Squad

> Reviewer: design-sys-eng
> Purpose: Validate that all components render correctly across light, dark, and high-contrast modes.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Light Mode

- [ ] All colors render correctly with light mode token values
- [ ] Contrast ratios meet WCAG AA (4.5:1 text, 3:1 UI components)
- [ ] Subtle elements (borders, dividers, disabled states) are visible
- [ ] Shadows and elevation provide appropriate depth perception
- [ ] Interactive states (hover, active, focus) are visually distinct
- [ ] No washed-out or invisible elements

---

## 2. Dark Mode

- [ ] Dark mode is not just inverted light mode — intentionally designed
- [ ] Elevated surfaces are differentiated (higher = lighter in dark mode)
- [ ] No pure white (#fff) text on dark backgrounds — uses slightly muted white
- [ ] Shadows are adjusted for dark backgrounds (darker, more diffuse, or removed)
- [ ] Images and illustrations have dark-mode variants or adjusted opacity
- [ ] Code blocks and syntax highlighting adapted for dark backgrounds
- [ ] Charts and data visualizations use dark-mode color palette

---

## 3. High Contrast

- [ ] Maximum distinction between foreground and background elements
- [ ] Borders are thick and clearly visible (minimum 2px)
- [ ] No subtle grays — replaced with solid black/white in high-contrast mode
- [ ] Pure black and white used for primary text and backgrounds
- [ ] Focus indicators are extra prominent (3px+ solid borders)
- [ ] Icons have high contrast strokes or fills
- [ ] `forced-colors: active` media query handled where applicable

---

## 4. Mode Switching

- [ ] Mode switches instantly — no perceptible delay
- [ ] No flash of wrong theme (FOIT/FOUT equivalent for themes)
- [ ] No layout shift when switching between modes
- [ ] Scrollbar appearance adapts to the current mode
- [ ] Custom UI controls (toggles, sliders) update appearance on mode switch
- [ ] User preference persisted across sessions

---

## 5. Completeness

- [ ] Every semantic token has values defined for ALL modes (light, dark, high-contrast)
- [ ] New tokens introduced in this change include all mode values from day one
- [ ] No token gaps — no `undefined` or fallback values in any mode
- [ ] Token values reviewed visually in each mode (not just assumed correct)
- [ ] Component Storybook stories include mode-switching controls
- [ ] Automated visual regression tests cover all modes

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
