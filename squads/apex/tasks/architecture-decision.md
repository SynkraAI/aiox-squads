# Task: architecture-decision

```yaml
id: architecture-decision
version: "1.0.0"
title: "Architecture Decision Record"
description: >
  Create or review an Architecture Decision Record (ADR) for frontend
  architecture decisions. Ensures every significant technical choice is
  documented with context, options evaluated, and consequences tracked.
  Covers bundle impact, edge compatibility, and long-term maintainability.
elicit: false
owner: frontend-arch
executor: frontend-arch
outputs:
  - ADR document (docs/architecture/decisions/ADR-{number}.md)
  - Bundle impact analysis summary
  - Edge compatibility assessment
```

---

## When This Task Runs

This task runs when:
- A new technology, library, or architectural pattern is being considered
- A significant structural change to the monorepo or package boundaries is proposed
- An existing ADR needs to be reviewed due to changed circumstances
- A Tier 3+ agent escalates an architectural question to `@frontend-arch`
- The team needs to decide between competing approaches

This task does NOT run when:
- The decision is purely cosmetic or design-token related (route to `@design-sys-eng`)
- The change is a bug fix with no architectural implications
- An existing ADR already covers the decision and circumstances have not changed

---

## Execution Steps

### Step 1: Context Analysis

Gather the full context for the decision:

1. Identify the problem or opportunity driving the decision
2. List the constraints (performance budgets, edge runtime, RSC compatibility)
3. Review related ADRs to check for prior decisions on this topic
4. Identify stakeholders and affected packages/apps in the monorepo
5. Document the current state and why it is insufficient

### Step 2: Options Evaluation

Enumerate and evaluate all viable options:

1. List at least 2-3 realistic options (including "do nothing" when applicable)
2. For each option, document:
   - Description and how it works
   - Pros and cons
   - Migration effort estimate
   - Risk assessment (low / medium / high)
3. Eliminate options that violate hard constraints (e.g., no edge runtime support)

### Step 3: Bundle Impact Analysis

For each remaining option, assess bundle impact:

1. Check the gzipped size of any new dependencies (`bundlephobia.com` or local analysis)
2. Verify tree-shaking support (ESM exports, sideEffects field)
3. Calculate the delta against the current JS budget (< 80KB first-load)
4. Flag any option that would exceed performance budgets
5. Document the expected bundle change per option

### Step 4: Edge Compatibility Check

Validate each option against edge runtime constraints:

1. Check if the library/pattern runs on Edge Runtime (no Node.js-only APIs)
2. Verify compatibility with Next.js middleware and RSC
3. Test for dynamic imports and code-splitting behavior
4. Check for `eval()`, `new Function()`, or other restricted APIs
5. Document edge compatibility status per option (full / partial / none)

### Step 5: Decision Documentation

Write the ADR using the standard template:

```markdown
# ADR-{number}: {Title}

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** {YYYY-MM-DD}
**Deciders:** @frontend-arch, {other stakeholders}

## Context
{Problem statement and constraints from Step 1}

## Options Considered
{From Step 2, with bundle and edge analysis from Steps 3-4}

## Decision
{The chosen option and why}

## Consequences
{From Step 6}
```

### Step 6: Consequences Documentation

Document the positive and negative consequences of the decision:

1. **Positive consequences** — what improves, what becomes easier
2. **Negative consequences** — what trade-offs are accepted
3. **Risks** — what could go wrong and mitigation strategies
4. **Migration steps** — if replacing an existing pattern, outline the path
5. **Review date** — when this decision should be re-evaluated

---

## ADR Numbering

ADRs are numbered sequentially within the project:
- Check `docs/architecture/decisions/` for the latest number
- Increment by 1 for the new ADR
- Format: `ADR-{number}-{kebab-case-title}.md`

---

## Quality Checklist

Before finalizing the ADR, verify:

- [ ] Context clearly states the problem and constraints
- [ ] At least 2 options were evaluated with pros/cons
- [ ] Bundle impact is quantified (KB gzipped)
- [ ] Edge compatibility is verified
- [ ] Decision rationale is clear and traceable
- [ ] Consequences include both positive and negative outcomes
- [ ] Related ADRs are cross-referenced

---

*Apex Squad — Architecture Decision Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-architecture-decision
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "ADR document must follow the standard template (Context, Decision, Consequences)"
    - "Bundle impact analysis must include before/after size estimates in KB gzipped"
    - "Edge compatibility assessment must cover target runtime environments"
    - "Decision must have explicit GO/NO-GO recommendation"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | ADR document with bundle impact analysis and edge compatibility assessment |
| Next action | Route to appropriate Tier 2/3 agents for implementation based on the architectural decision |
