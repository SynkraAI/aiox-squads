# Apex Demo App

A minimal React + Vite app with **intentional frontend issues** designed to showcase what Apex Squad detects and fixes.

## Intentional Issues (27 total)

| Category | Count | Examples |
|----------|-------|---------|
| **Accessibility** | 12 | Divs as buttons, missing labels, low contrast, no keyboard nav |
| **CSS** | 7 | Hardcoded colors/spacing, no responsive handling, inline styles |
| **Motion** | 4 | CSS transitions instead of springs, no entrance animations |
| **Performance** | 2 | Eager image loading, inline style objects re-created per render |
| **React** | 2 | Missing Error Boundary, form not using React 19 patterns |

## How to Test with Apex

```bash
# 1. Install dependencies
cd examples/demo-app
npm install

# 2. Activate Apex Squad in your AIOS project
@apex

# 3. Run discoveries — Apex finds all 27 issues
@apex "audita esse projeto"

# 4. Fix specific issues
@apex "fix the header for mobile"
@apex "fix accessibility on the contact form"
@apex "add entrance animations to the hero"

# 5. Transform the entire style
@apex "transforma pro estilo Stripe"
```

## Component Map

```
App.tsx
├── Header.tsx      (a11y: 4 issues, css: 2 issues, motion: 1 issue)
├── HeroSection.tsx (a11y: 2 issues, css: 1 issue, motion: 1 issue, perf: 1 issue)
├── FeatureCards.tsx (a11y: 2 issues, css: 2 issues, motion: 1 issue, perf: 1 issue, react: 1 issue)
├── ContactForm.tsx (a11y: 3 issues, css: 1 issue, react: 1 issue)
└── Footer.tsx      (a11y: 2 issues, css: 1 issue)
```

## Expected Apex Discovery Results

Running `*discover-a11y` should find:
- 7x interactive `<div>` without keyboard support (Header nav, CTA, Hero buttons, Cards, Form submit, Footer links)
- 3x inputs without `<label>` (ContactForm)
- 2x low contrast text (#94a3b8 on white/light bg)

Running `*discover-motion` should find:
- 4x CSS `transition` that should be springs (Header nav, Header CTA, Card hover, Form submit)
- 1x missing entrance animation (HeroSection)
- 1x missing `prefers-reduced-motion` handling

Running `*discover-performance` should find:
- 1x image without `loading="lazy"` (HeroSection)
- 5x inline style objects re-created every render

Running `*discover-design` should find:
- CSS variables defined in `:root` but not used by components (all hardcoded)
- DS Score: ~20/100 (adhoc)
