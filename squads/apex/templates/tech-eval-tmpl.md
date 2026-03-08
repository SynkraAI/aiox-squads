# Technology Evaluation: {LIBRARY_NAME}

**Date:** {YYYY-MM-DD}
**Evaluator:** @frontend-arch (Arch)
**Reviewed By:** @apex-lead (Emil)
**Status:** In Progress | Recommended | Not Recommended | Conditional

## Overview

| Field | Value |
|-------|-------|
| Library Name | {library-name} |
| Version Evaluated | {x.y.z} |
| License | {MIT / Apache-2.0 / etc.} |
| Repository | {URL} |
| Purpose | {What problem does this solve?} |
| Replaces | {Existing library or "N/A"} |

## Evaluation Criteria

| Criterion | Score (1-5) | Notes |
|-----------|:-----------:|-------|
| Bundle size (gzipped) | {1-5} | {size in KB, tree-shaken size} |
| Tree-shaking support | {1-5} | {ESM support, side-effect-free?} |
| Edge compatibility | {1-5} | {Vercel Edge, Cloudflare Workers?} |
| TypeScript support | {1-5} | {Built-in types, quality of DX?} |
| Maintenance health | {1-5} | {Release cadence, open issues ratio, bus factor} |
| Community adoption | {1-5} | {npm weekly downloads, GitHub stars, ecosystem} |
| Integration fit | {1-5} | {Compatibility with Next.js, React Native, R3F} |
| Performance benchmarks | {1-5} | {Benchmark results vs alternatives} |
| **Total** | **{sum}/40** | |

### Scoring Guide
- **5:** Excellent — best-in-class, no concerns
- **4:** Good — minor gaps, acceptable trade-offs
- **3:** Adequate — notable trade-offs, workable
- **2:** Weak — significant gaps, risky
- **1:** Unacceptable — blocking issues

## Recommendation

**Verdict:** {Recommended | Not Recommended | Conditional}

{1-2 paragraph justification for the verdict. Reference scores above.}

## Trade-offs

### Advantages
- {Advantage 1}
- {Advantage 2}
- {Advantage 3}

### Disadvantages
- {Disadvantage 1}
- {Disadvantage 2}
- {Disadvantage 3}

## Migration Path

{If replacing an existing library, describe the migration strategy.
If not replacing anything, write "N/A — new addition".}

| Phase | Action | Estimated Effort |
|-------|--------|-----------------|
| 1 | {Install, configure, add to shared packages} | {hours/days} |
| 2 | {Migrate first component as proof-of-concept} | {hours/days} |
| 3 | {Roll out to remaining components} | {hours/days} |
| 4 | {Remove old library, clean up} | {hours/days} |

## Platforms Affected
- [ ] Web (Next.js)
- [ ] Mobile (React Native)
- [ ] Spatial (R3F/WebXR)
- [ ] Shared packages

## Bundle Impact

| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Total bundle (gzipped) | {KB} | {KB} | {+/- KB} |
| First load JS | {KB} | {KB} | {+/- KB} |
| Largest chunk | {KB} | {KB} | {+/- KB} |

## References
- {Link to official docs}
- {Link to benchmark / comparison article}
- {Link to relevant ADR if exists}
