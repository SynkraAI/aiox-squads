# Discovery Checklist

Checklist for `*discover-components` and `*discover-design` operations.

---

## Pre-Discovery

- [ ] Project scanned (`*apex-scan` completed or cache valid)
- [ ] React component files exist (`.tsx`/`.jsx` in `src/` or `packages/`)
- [ ] Profile detected (full/web-next/web-spa/minimal)

## Component Discovery (`*discover-components`)

- [ ] All `.tsx`/`.jsx` files found via glob
- [ ] Each component classified by type (page/layout/ui/hook)
- [ ] LOC counted per component
- [ ] Import tree built (who imports who)
- [ ] Hub components identified (imported by 5+ others)
- [ ] Orphan components detected (exported but never imported)
- [ ] Untested components flagged (no `.test.` or `.spec.` file)
- [ ] God components flagged (>200 LOC + >5 hooks)
- [ ] Health score calculated (0-100)
- [ ] Summary table rendered
- [ ] Next steps presented (intent chaining)

## Design System Discovery (`*discover-design`)

- [ ] CSS source detected (CSS files, Tailwind config, theme objects, CSS variables)
- [ ] Token inventory built (colors, spacing, typography, radius, z-index)
- [ ] Hardcoded values found (hex colors, pixel spacing outside tokens)
- [ ] Near-duplicate colors detected (<5% HSL distance)
- [ ] Design language classified (glass morphism, material, flat, custom)
- [ ] Token coverage calculated (tokens used vs hardcoded)
- [ ] Violations list generated (feeds QG-AX-001)
- [ ] DS Score calculated (0-100: solid/emerging/adhoc)
- [ ] Summary table rendered
- [ ] Next steps presented (intent chaining)

## Post-Discovery

- [ ] Results cached in `.aios/apex-context/`
- [ ] `*apex-suggest` enriched with discovery data (if applicable)
- [ ] Proactive suggestions appended to report (if issues found)

## Veto Checks

- [ ] VC-DISC-COMP-001: React component files exist (`.tsx`/`.jsx`)
- [ ] VC-DISC-COMP-002: Project size warning (>500 components)
- [ ] VC-DISC-DS-001: CSS/Tailwind/theme files exist (fallback to inline scan)
- [ ] VC-DISC-DS-002: CSS-in-JS adaptation (scan theme objects if no CSS)

---

*Apex Squad — Discovery Checklist v1.0.0*
