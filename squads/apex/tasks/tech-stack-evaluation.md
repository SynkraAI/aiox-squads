# Task: tech-stack-evaluation

```yaml
id: tech-stack-evaluation
version: "1.0.0"
title: "Tech Stack Evaluation"
description: >
  Evaluate a technology, library, or framework against the project's
  stack criteria. Produces a structured scoring matrix covering bundle
  size, tree-shaking, edge compatibility, TypeScript quality, maintenance
  health, and performance benchmarks.
elicit: false
owner: frontend-arch
executor: frontend-arch
outputs:
  - Evaluation report with scoring matrix
  - Benchmark comparison against alternatives
  - GO / NO-GO recommendation
```

---

## When This Task Runs

This task runs when:
- A new dependency is being proposed for the project
- An existing dependency is being reconsidered or has a potential replacement
- A Tier 3+ agent requests a library for their domain (e.g., animation library)
- The team encounters limitations with a current technology
- A periodic review of the tech stack is scheduled

This task does NOT run when:
- The library is already an approved part of the stack
- The evaluation is about design tokens or visual patterns (route to `@design-sys-eng`)
- The question is about CSS-only solutions (route to `@css-eng`)

---

## Execution Steps

### Step 1: Bundle Size Check

Analyze the production bundle cost:

1. Look up gzipped size on bundlephobia.com or run local analysis
2. Check the cost of the full package vs. individual imports
3. Compare against the project JS budget (< 80KB first-load)
4. Calculate the percentage of the total budget this library would consume
5. Flag if the library exceeds 10KB gzipped without justification

### Step 2: Tree-Shaking Support

Verify the library supports dead code elimination:

1. Check `package.json` for `"sideEffects": false` or explicit sideEffects array
2. Verify ESM exports are available (module or exports field)
3. Test actual tree-shaking with a minimal import in the project bundler
4. Check if named imports result in proportional bundle reduction
5. Score: Full (5), Partial (3), None (1)

### Step 3: Edge Runtime Compatibility

Validate the library works in edge environments:

1. Check for Node.js-only APIs (`fs`, `path`, `crypto` node module, `Buffer`)
2. Test import in Next.js Edge Runtime context
3. Verify no use of `eval()`, `new Function()`, or dynamic requires
4. Check for WebAssembly dependencies (may have edge limitations)
5. Score: Full edge support (5), Partial with workarounds (3), Incompatible (1)

### Step 4: TypeScript Quality

Assess the TypeScript developer experience:

1. Check if types are built-in or via `@types/` package
2. Evaluate type coverage (are generics used properly, are overloads complete?)
3. Test IntelliSense/autocomplete quality in VS Code
4. Check for `any` escape hatches in the public API
5. Verify generic inference works without manual type annotations
6. Score: Excellent (5), Good (4), Adequate (3), Poor (2), None (1)

### Step 5: Maintenance Health

Evaluate the library's long-term viability:

1. Check last publish date (flag if > 6 months for active libraries)
2. Review open issues count and response time
3. Check number of active maintainers (bus factor)
4. Verify funding model (sponsored, corporate-backed, volunteer)
5. Review breaking change history (major version frequency)
6. Check download trends (npm trends) for trajectory
7. Score: Thriving (5), Healthy (4), Stable (3), Declining (2), Abandoned (1)

### Step 6: Benchmark vs Alternatives

Compare against competing libraries:

1. Identify 2-3 direct alternatives serving the same purpose
2. Run performance benchmarks relevant to the use case
3. Compare API ergonomics and learning curve
4. Compare community ecosystem (plugins, examples, documentation)
5. Document migration cost if switching from current solution
6. Create a comparison table with all criteria

### Step 7: Scoring Matrix

Produce the final scoring matrix:

| Criterion | Weight | Score (1-5) | Weighted |
|-----------|--------|-------------|----------|
| Bundle size (gzipped) | 20% | — | — |
| Tree-shaking support | 15% | — | — |
| Edge runtime compatibility | 20% | — | — |
| TypeScript quality | 15% | — | — |
| Maintenance health | 15% | — | — |
| Benchmark performance | 15% | — | — |

**Thresholds:**
- **GO:** Weighted score >= 3.5
- **CONDITIONAL:** Weighted score 2.5-3.4 (requires ADR with justification)
- **NO-GO:** Weighted score < 2.5

---

## Output Format

```markdown
# Tech Stack Evaluation: {library-name}

**Date:** {YYYY-MM-DD}
**Evaluator:** @frontend-arch
**Version evaluated:** {version}

## Scoring Matrix
{table from Step 7}

## Verdict: {GO | CONDITIONAL | NO-GO}

## Details
{Findings from Steps 1-6}

## Recommendation
{If GO: integration path. If CONDITIONAL: what ADR is needed. If NO-GO: suggested alternatives.}
```

---

*Apex Squad — Tech Stack Evaluation Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-tech-stack-evaluation
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (GO/CONDITIONAL/NO-GO)"
    - "Scoring matrix must cover all 6 criteria with weighted scores"
    - "Benchmark comparison must include at least 2 alternatives"
    - "Report must contain at least one actionable recommendation or explicit all-clear"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Evaluation report with scoring matrix, benchmark comparison against alternatives, and GO/CONDITIONAL/NO-GO recommendation |
| Next action | If GO, integrate into project. If CONDITIONAL, route to `architecture-decision` for ADR. If NO-GO, evaluate recommended alternatives |
