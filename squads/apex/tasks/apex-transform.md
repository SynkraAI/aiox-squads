# Task: apex-transform

Apply a complete design style to the project with a single command.

## Trigger
- `*apex-transform --style {preset_id}` — apply specific style
- `*apex-transform --style {preset_id} --scope {page|component|global}` — limit scope
- `*apex-transform` (no args) — interactive: show catalog, user picks

## Prerequisites
- `*apex-scan` completed (or auto-run)
- Project has React components (`.tsx`/`.jsx`)
- CSS system detected (Tailwind, CSS Modules, CSS-in-JS, or inline)

## Steps

### Phase 1: Analyze Current State
1. **Load project context** from scan cache
2. **Run `*discover-design`** if not cached — need current token inventory
3. **Load target preset** from `data/design-presets.yaml`
4. **Generate diff report:**
   ```
   Transform: {current_design_language} → {target_preset.name}

   Changes required:
   - Colors: {N} tokens to update, {M} hardcoded to replace
   - Typography: font-family change {old} → {new}, {N} scale adjustments
   - Spacing: base unit {old} → {new}
   - Radius: {changes}
   - Shadows: {changes}
   - Motion: {spring config changes}
   - Effects: {new effects to add}

   Files affected: ~{estimated_count}
   Risk: {LOW|MEDIUM|HIGH} (based on scope of changes)
   ```

### Phase 2: Present Plan
```
Transform Plan: {current} → {preset.name}

Phase 2a — Token Foundation:
  - Update CSS variables / Tailwind config / theme
  - Replace {N} color tokens
  - Update typography stack
  - Adjust spacing scale and radius

Phase 2b — Component Adaptation:
  - Update {N} components to match {preset} patterns
  - Apply new shadow system
  - Add/update motion configs
  - Apply {preset} effects (blur, gradients, etc.)

Phase 2c — Polish:
  - Verify dark mode consistency
  - Check responsive behavior
  - Validate contrast (WCAG AA minimum)
  - Run typecheck

Estimated scope: {file_count} files
Confirm? (sim/nao/ajustar)
```

### Phase 3: Execute Transform
Route to agents based on changes needed:

1. **@design-sys-eng (Diana)** — Token foundation
   - Update CSS custom properties / Tailwind theme / theme object
   - Set color palette (light + dark from preset)
   - Set typography (font-family, scale, weights)
   - Set spacing, radius, shadows

2. **@css-eng (Josh)** — CSS architecture
   - Replace hardcoded values with new tokens
   - Apply new effect classes (backdrop-blur, gradients, etc.)
   - Update responsive breakpoint behavior if needed
   - Apply component_patterns from preset

3. **@motion-eng (Matt)** — Motion system
   - Update spring configs to match preset
   - Apply preset motion patterns (hover, press, enter/exit)
   - Ensure reduced-motion fallbacks

4. **@a11y-eng (Sara)** — Accessibility check
   - Verify color contrast meets WCAG AA (or AAA if preset requires)
   - Check focus visibility with new colors
   - Validate reduced-motion handling

5. **@react-eng (Kent)** — Component updates (if structural changes needed)
   - Update component props for new patterns
   - Add/remove wrapper elements for effects

### Phase 4: Verify
1. Run typecheck (`npm run typecheck`)
2. Run lint (`npm run lint`)
3. Run `*apex-suggest` on modified files
4. Present before/after summary

### Phase 5: Intent Chaining
```
Transform completo: {old_style} → {preset.name}
{files_modified} arquivos modificados. typecheck PASS.

Proximo passo:
  1. Rodar suggestions nos arquivos modificados
  2. Ajustar detalhes (fine-tune cores, spacing)
  3. Aplicar em outra pagina/componente
  4. Reverter (git checkout)
  5. Done

O que prefere?
```

## Scope Options
- `--scope global` (default) — Apply to entire project (CSS vars + all components)
- `--scope page {path}` — Apply only to specific page and its components
- `--scope component {name}` — Apply only to specific component

## Preset Override
User can override specific tokens from a preset:
```
*apex-transform --style stripe --primary "#FF0000" --font "Poppins"
```
This uses stripe preset as base but overrides primary color and font.

## Rollback
All changes are made via standard file edits. User can revert with:
- `git checkout .` (discard all changes)
- `git diff` (review before committing)
- NEVER auto-commits

## Veto Conditions
- VC-TRANSFORM-001: Preset ID must exist in design-presets.yaml
- VC-TRANSFORM-002: Project must have CSS system detected (not raw HTML)
- VC-TRANSFORM-003: Contrast ratio must meet WCAG AA after transform
- VC-TRANSFORM-004: typecheck must PASS after transform

## Output
- Updated token system (CSS vars / Tailwind / theme)
- Updated components matching new style
- Before/after summary
- Feeds into intent chaining for polish
