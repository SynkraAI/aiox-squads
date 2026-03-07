# Task: Validate Final Artifacts

**Task ID:** validate-final-artifacts
**Execution Type:** Hybrid (Deterministic checks + Agent for semantic quality)
**Purpose:** Validate final squad outputs only, not intermediate artifacts
**Orchestrator:** @squad-chief
**Mode:** Blocking quality gate
**Model:** `Sonnet` (final artifact semantic quality assessment)
**Haiku Eligible:** NO -- final quality adjudication requires contextual reasoning

## Cardinal Rule

```
Validate final deliverables, not process traces.
A squad passes only if final artifacts are production-ready.
```

---

## Final Targets

```yaml
required_artifacts:
  - config.yaml
  - agents/*.md
  - tasks/*.md
  - workflows/*.yaml
  - README.md
  - .claude/commands/*/agents/{entry_agent}.md
  - .codex/skills/{entry_agent}/SKILL.md

optional_but_scored:
  - checklists/*.md
  - templates/*
  - data/*
```

---

## Hard Gates

1. `Structure Gate` (blocking)
- All required files exist.
- Entry agent is valid and referenced.
- No broken internal path references.

2. `Execution Gate` (blocking)
- At least one runnable workflow exists.
- Task references resolve to existing files.
- No circular phase dependency in workflows.

3. `Quality Gate` (blocking)
- `validate-squad` score >= 7.0.
- No critical security findings.
- No veto condition triggered.

4. `Chief Activation Gate` (blocking)
- Chief command exists in `.claude/commands/*/agents/{entry_agent}.md`.
- Chief Codex skill exists in `.codex/skills/{entry_agent}/SKILL.md`.

5. `Usability Gate` (warning)
- README includes activation and example commands.
- At least one end-to-end example path.

---

## Output

```yaml
final_artifact_report:
  result: PASS | CONDITIONAL | FAIL
  score: 0-10
  blocking_failures:
    - id: "..."
      reason: "..."
  warnings:
    - "..."
  recommended_fixes:
    - "..."
```

---

## Success Criteria

- All blocking gates pass.
- Report generated at `.aiox/squad-runtime/squad-validation/{squad_name}/final-artifacts.yaml`.
