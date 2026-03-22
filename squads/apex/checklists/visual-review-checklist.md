# Visual Review Checklist — Apex Squad

> Reviewer: apex-lead
> Purpose: Validate visual fidelity before story moves to QA gate.
> Usage: Check every item. A single unchecked item blocks approval.

> **Scope:** Design fidelity review by **apex-lead** during the design-to-code transition. Focuses on **pixel-perfect Figma matching, 4px grid, token usage, squircle borders, elevation, typography scale**.
> **Use when:** apex-lead is reviewing implemented components against Figma spec (pre-QA gate).
> **Related:** `visual-qa-checklist.md` (automated visual regression by @qa-visual during QA phase).

---

## 1. Pixel-Perfect vs Figma

- [ ] Overlay comparison performed (Figma Dev Mode / PixelSnap / browser plugin)
- [ ] Spacing matches Figma spec within 1px tolerance
- [ ] Element dimensions match Figma exactly or match the nearest token step
- [ ] Component padding and margin align with the 4px grid (no arbitrary offsets)
- [ ] Alignment of text baselines matches Figma
- [ ] Images and icons are not stretched or distorted

---

## 2. 4px Grid Compliance

- [ ] All spacing values are multiples of 4px (4, 8, 12, 16, 20, 24, 32, 40, 48, 64…)
- [ ] No hardcoded non-grid values (e.g., 3px, 5px, 7px, 11px)
- [ ] Component gaps and padding use grid-aligned tokens
- [ ] Layout columns and gutters respect the defined grid
- [ ] Touch targets are minimum 44px (multiple of 4)

---

## 3. Design Token Usage

- [ ] Zero hardcoded color values (no `#hex`, `rgb()`, `hsl()` literals in component code)
- [ ] Zero hardcoded spacing values (no `margin: 12px` — must use `spacing.3`)
- [ ] Zero hardcoded font sizes (must use typography scale tokens)
- [ ] Zero hardcoded border radii (must use `radius.*` tokens or squircle utility)
- [ ] Zero hardcoded shadow values (must use `elevation.*` tokens)
- [ ] Zero hardcoded transition durations (must use `duration.*` and `easing.*` tokens)
- [ ] Token names follow `primitive → semantic → component` hierarchy
- [ ] No token aliases that bypass the semantic layer

---

## 4. Typography Scale Adherence

- [ ] All font sizes use defined type scale steps (no arbitrary sizes)
- [ ] Font weights match the type scale (no arbitrary weight values)
- [ ] Line heights use token values, not arbitrary numbers
- [ ] Letter spacing uses token values where specified
- [ ] No mixed font families outside of the defined stack
- [ ] Heading hierarchy is semantically correct (h1 > h2 > h3)
- [ ] Body text minimum 16px (1rem) on mobile viewports

---

## 5. Color Contrast

- [ ] All text on background passes WCAG 2.2 AA (4.5:1 minimum for normal text)
- [ ] Large text (18px+ regular, 14px+ bold) passes AA (3:1 minimum)
- [ ] Body and label text passes AAA (7:1) where designated in spec
- [ ] Interactive element boundaries (focus rings, input borders) pass AA (3:1 against adjacent colors)
- [ ] Icon-only controls pass AA (3:1) against their background
- [ ] Placeholder text contrast reviewed (not relied on as sole label)
- [ ] Contrast verified with a tool (browser DevTools, Colour Contrast Analyser, or axe)

---

## 6. Dark Mode / Light Mode / High-Contrast

- [ ] Component renders correctly in light mode
- [ ] Component renders correctly in dark mode (`prefers-color-scheme: dark`)
- [ ] No hardcoded colors that invert incorrectly in dark mode
- [ ] High-contrast mode reviewed (`forced-colors: active` / Windows High Contrast)
- [ ] All interactive states (hover, active, focus, disabled) reviewed in all three modes
- [ ] Shadows and elevation visible and appropriate in dark mode
- [ ] Images and illustrations have correct dark-mode variants or appropriate opacity adjustments

---

## 7. Responsive Behavior (320px to 2560px)

- [ ] 320px (iPhone SE / minimum mobile width) — no horizontal overflow, text readable
- [ ] 375px (iPhone 14) — standard mobile layout correct
- [ ] 430px (iPhone 14 Pro Max) — large mobile layout correct
- [ ] 768px (iPad portrait) — tablet breakpoint triggers correctly
- [ ] 1024px (iPad landscape / small laptop) — layout adapts correctly
- [ ] 1280px (standard desktop) — primary desktop layout correct
- [ ] 1440px (large desktop) — max-width containers centered correctly
- [ ] 1920px (FHD) — no unwanted stretching or excessive whitespace
- [ ] 2560px (QHD) — content remains readable and well-proportioned
- [ ] No horizontal scrollbar at any breakpoint
- [ ] Images use responsive sizing (`srcset`, `sizes`, or fluid CSS)
- [ ] Text does not overflow containers at any breakpoint

---

## 8. Squircle Borders

- [ ] Rounded corners use the squircle utility (CSS `corner-shape: squircle` or SVG clip-path), NOT standard `border-radius`
- [ ] Squircle tension/smoothing matches the design spec (default: 0.6)
- [ ] Avatar and icon container squircles match Figma curvature exactly
- [ ] Card and panel squircles match the design token `radius.squircle.*`
- [ ] No component uses `border-radius: 50%` for non-circular elements
- [ ] Squircle renders without anti-aliasing artifacts at all defined sizes

---

## 9. Elevation and Shadow Consistency

- [ ] Shadows use `elevation.*` tokens exclusively
- [ ] Elevation levels are semantically correct (e.g., modal > sheet > card > button)
- [ ] Shadow color uses token (not hardcoded black `rgba`)
- [ ] Shadow direction is consistent across all components (single light source)
- [ ] Elevation in dark mode uses correct dark-mode shadow tokens
- [ ] Box shadows do not bleed outside clip boundaries unintentionally
- [ ] Focus ring elevation is above content shadows

---

## 10. Icon Optical Alignment

- [ ] Icons are optically centered within their containers (not mathematically centered only)
- [ ] Icon size matches the design spec (do not scale icons with arbitrary CSS transforms)
- [ ] Icons use the correct weight/stroke as specified (e.g., 1.5px stroke for 24px icons)
- [ ] Inline icons are vertically aligned with text baseline or midline per spec
- [ ] Icon color uses semantic color token (not hardcoded)
- [ ] Icon-only buttons have visible label for screen readers (aria-label or sr-only span)
- [ ] SVG icons have `aria-hidden="true"` when decorative

---

## 11. Motion Review

- [ ] All animations use spring configs from the `motion.*` token set (no `linear` or `ease-in-out` literals)
- [ ] Spring parameters: stiffness, damping, and mass match the defined motion language
- [ ] Enter animations: correct origin, duration, and spring profile
- [ ] Exit animations: correct fade/scale/translate direction and spring profile
- [ ] Hover/press states: micro-interactions match spec (scale, shadow delta, color delta)
- [ ] Stagger choreography: correct delay increments between list/grid children
- [ ] No janky frames — animation runs at 60fps (verified in DevTools Performance panel)
- [ ] `prefers-reduced-motion: reduce` fully suppresses or substitutes all non-essential motion
- [ ] `prefers-reduced-motion` implementation uses `@media` or runtime check — not skipped
- [ ] No layout-triggering properties animated (avoid animating `width`, `height`, `top`, `left` — prefer `transform` and `opacity`)
- [ ] GSAP / Rive / R3F animations reviewed for GPU composite path

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Figma Link | |
| Result | APPROVED / BLOCKED |
| Notes | |
