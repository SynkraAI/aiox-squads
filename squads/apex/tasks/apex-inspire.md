# Task: apex-inspire

Browse and explore design styles for inspiration before applying.

## Trigger
- `*apex-inspire` — show all categories
- `*apex-inspire --category {category}` — filter by category
- `*apex-inspire --style {preset_id}` — deep dive into specific style

## Steps

### 1. Load preset catalog
- Read `data/design-presets.yaml`
- Group by category

### 2. Display catalog (no category filter)
```
Design Presets Catalog — {total_presets} styles available

Apple Ecosystem:
  1. apple-liquid-glass — Apple Liquid Glass (iOS 26, macOS Tahoe)
  2. apple-hig-classic — Apple HIG Classic (iOS 17)
  3. apple-visionos — visionOS Spatial (immersive glass)

Google Ecosystem:
  4. material-3 — Material Design 3 (Dynamic Color)
  5. material-you — Material You (personalized palettes)

Tech Companies:
  6. linear-style — Linear (aurora glow, keyboard-first)
  7. vercel-style — Vercel (black & white precision)
  8. stripe-style — Stripe (elegant gradients)
  9. notion-style — Notion (content-first minimal)
  10. github-style — GitHub (developer pragmatism)
  11. spotify-style — Spotify (dark immersive)
  12. discord-style — Discord (playful community)

Design Movements:
  13. glassmorphism — Frosted glass effect
  14. neumorphism — Soft extruded surfaces
  15. brutalist — Raw, unpolished, anti-design
  16. minimalist — Ultra Minimalist (Dieter Rams)
  17. retro-y2k — Y2K nostalgia (chrome, neon)
  18. claymorphism — 3D clay inflated elements
  19. aurora-gradient — Mesh gradients (Northern Lights)

Industry-Specific:
  20. healthcare-clean — Clinical trust (WCAG AAA)
  21. fintech-pro — Trading dashboard (data-dense)
  22. saas-dashboard — Modern B2B (card metrics)
  23. ecommerce-modern — Product-focused shopping
  24. education-friendly — Gamified learning

Dark Themes:
  25. dark-elegant — Luxurious dark (gold accents, serif)
  26. oled-dark — True black OLED
  27. nord-theme — Arctic-inspired calm

Experimental:
  28. neubrutalism — Bold outlines + color (Gumroad)
  29. cyberpunk — Neon glows, glitch effects
  30. organic-nature — Earth-toned organic shapes
  31. swiss-grid — Mathematical typography grid

Pick a number to see details, or:
  *apex-transform --style {id} — apply directly
  *apex-inspire --category {name} — filter category
```

### 3. Display style detail (when user picks one)
```
{name}
{description}

References: {reference list}

Color Palette:
  Light: {color swatches summary}
  Dark: {color swatches summary}

Typography: {font_family}, scale {min}-{max}px
Spacing: {base}px base, {scale summary}
Radius: {radius summary}
Motion: {spring description}
Effects: {key effects}

Component Patterns:
  Card: {pattern}
  Button: {pattern}
  Input: {pattern}

Ready to apply? → *apex-transform --style {id}
```

### 4. Intent chaining
After showing a style detail:
```
1. Aplicar este estilo → *apex-transform --style {id}
2. Ver outro estilo
3. Comparar 2 estilos lado a lado
4. Done
```

## Output
- Catalog browsing (read-only)
- No files modified
- Feeds into *apex-transform when user decides
