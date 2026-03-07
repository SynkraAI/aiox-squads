# Task: Operational Test (E2E Validation - Generic Template)

**Task ID:** operational-test
**Execution Type:** Hybrid (Autonomous execution + Human validation)
**Purpose:** Execute real E2E test to validate squad is fully operational
**Orchestrator:** @squad-chief (delegates to squad's chief agent)
**Mode:** Triggered after setup-runtime OR manual invocation
**Model:** `Sonnet` (E2E diagnosis and remediation guidance across runtime failures)
**Haiku Eligible:** NO -- failure interpretation and escalation logic require reasoning

**Philosophy:**
```
"Squad is only operational after producing REAL output.
 Structural validation is not enough - we need proof of execution."
```

---

## Overview

This task executes a REAL end-to-end workflow with actual data from connected APIs.
It validates that:
1. API connections work in practice (not just in isolation)
2. Core skills execute correctly
3. Outputs are generated and stored
4. The full skill chain operates without errors

**Critical Distinction:**
- `qa-after-creation.md` → Validates STRUCTURE (files exist, YAML valid)
- `operational-test.md` → Validates EXECUTION (real data, real actions, real output)

---

## Inputs

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `squad_name` | string | Yes | Squad to test |
| `test_mode` | enum | No | `live` (real account) or `sandbox` (mock data) |
| `test_scope` | enum | No | `minimal` (1 workflow), `standard` (3 workflows), `full` (all skills) |
| `target_id` | string | No | Specific target to test (campaign_id, form_id, etc.) |

---

## Prerequisites

- [ ] `setup-runtime` completed successfully
- [ ] runtime-baseline.yaml exists with all connections validated
- [ ] At least one valid target for testing (campaign, form, spreadsheet, etc.)
- [ ] Sufficient API quota for test calls

---

## PHASE 1: PRE-FLIGHT CHECK

**Duration:** 30 seconds
**Mode:** Autonomous

### Step 1.1: Verify Runtime Configuration

```yaml
preflight_checks:
  - check: "Runtime baseline exists"
    path: "squads/{squad_name}/data/runtime-baseline.yaml"
    on_fail: "ABORT - Run *setup-runtime first"

  - check: "All critical APIs connected"
    source: "runtime-baseline.yaml"
    verify: "all critical APIs have status == CONNECTED"
    on_fail: "ABORT - API {api_name} not connected. Run *setup-runtime --api={api_name}"

  - check: "API tokens not expired"
    for_each_api:
      action: "Test connection with lightweight call"
    on_fail: "ABORT - Token expired. Run *setup-runtime --refresh {api_name}"

  - check: "Valid test target exists"
    action: "Verify at least one entity for testing"
    on_fail: "ABORT - No valid target found. Create one first or specify --target-id"
```

### Step 1.2: Select Test Target

```yaml
target_selection:
  strategy: "auto"  # or "manual" if target_id provided

  auto_selection_criteria:
    # Criteria depends on squad domain
    ad_campaigns:
      - "effective_status == ACTIVE"
      - "daily_budget > 0"
      - "has_recent_data (last 24h)"

    forms:
      - "status == published"
      - "has_responses > 0 OR is_test_form"

    spreadsheets:
      - "has_write_access"
      - "has_test_sheet OR create_test_sheet"

    crm_records:
      - "has_test_contacts OR use_sandbox"

  prefer:
    - "Targets with most data (better test coverage)"
    - "Targets with varied states (test multiple rules)"
    - "Test/sandbox targets over production when available"

  output:
    selected_target:
      type: "{target_type}"
      id: "{target_id}"
      name: "{target_name}"
      details: "{relevant_details}"
```

---

## PHASE 2: EXECUTE SMOKE WORKFLOW

**Duration:** 2-5 minutes
**Mode:** Autonomous

### Step 2.1: Test Flow Template

Each operational squad defines its own test flow. The general pattern:

```yaml
test_flow_template:
  # T1: Data Fetch Test
  t1_fetch:
    name: "T1 - Fetch Data"
    purpose: "Verify read operations work"
    skill_tested: "{data_skill}"

    action:
      type: "api_call"
      operation: "READ"
      target: "{selected_target}"

    validation:
      - "response.status == 200"
      - "response.data exists and not empty"

    on_success:
      log: "T1 PASS - Fetched {count} records"
      store:
        path: ".aiox/squad-runtime/operational-test/{squad_name}/t1-data.json"

    on_failure:
      log: "T1 FAIL - {error.message}"
      abort: true

  # T2: Processing Test
  t2_process:
    name: "T2 - Process Data"
    purpose: "Verify core logic executes"
    skill_tested: "{processing_skill}"

    action:
      type: "run_skill"
      skill: "{core_skill}"
      input: "{data_from_t1}"
      mode: "dry_run"  # Don't actually execute actions

    validation:
      - "output exists"
      - "output.has_expected_structure"

    on_success:
      log: "T2 PASS - {processing_summary}"
      store:
        path: ".aiox/squad-runtime/operational-test/{squad_name}/t2-processed.json"

  # T3: Output Generation Test
  t3_output:
    name: "T3 - Generate Output"
    purpose: "Verify artifacts are created"
    skill_tested: "{output_skill}"

    action:
      type: "generate_artifact"
      template: "{output_template}"
      data: "{processed_data}"

    validation:
      - "artifact_file_created"
      - "artifact_has_expected_sections"
      - "artifact_size > minimum_threshold"

    on_success:
      log: "T3 PASS - Output generated ({size} chars)"
      store:
        path: ".aiox/squad-runtime/operational-test/{squad_name}/t3-output.md"

  # T4: Notification Test (if configured)
  t4_notify:
    name: "T4 - Send Notification"
    purpose: "Verify alerts work"
    condition: "slack_configured == true"

    action:
      type: "send_notification"
      channel: "slack"
      message:
        text: |
          🧪 *OPERATIONAL TEST - {Squad_Name}*

          Teste E2E concluido com sucesso!

          *Target testado:* {target.name}
          *Dados coletados:* {data_count}
          *Output gerado:* Sim

          Este e um teste automatico. O squad esta operacional.

    validation:
      - "notification_sent == true"

    on_success:
      log: "T4 PASS - Notification sent"

    on_failure:
      log: "T4 WARN - Notification failed (non-blocking)"
      severity: "warning"
```

---

## DOMAIN-SPECIFIC TEST FLOWS

### Traffic/Ads Squads

```yaml
traffic_test_flow:
  t1: "Fetch campaign metrics from ad platform"
  t2: "Apply decision rules (dry run)"
  t3: "Generate performance report"
  t4: "Send test alert to Slack"

  specific_validations:
    - "metrics.impressions >= 0"
    - "decisions.length >= 0 (0 is ok if campaign healthy)"
    - "report.sections includes [summary, metrics, recommendations]"
```

### Form/Lead Squads

```yaml
form_test_flow:
  t1: "Fetch form schema and recent responses"
  t2: "Calculate scores from responses (if applicable)"
  t3: "Generate lead report or sync to sheet"
  t4: "Send notification with test lead data"

  specific_validations:
    - "form.fields.length > 0"
    - "scoring.applied == true (if scoring enabled)"
    - "sync.status == success (if sync enabled)"
```

### CRM Squads

```yaml
crm_test_flow:
  t1: "Fetch contacts/deals from CRM"
  t2: "Apply segmentation rules"
  t3: "Generate segment report"
  t4: "Send alert with segment summary"

  specific_validations:
    - "contacts.count > 0"
    - "segments.created >= 1"
    - "report.includes segment_breakdown"
```

### Image Generation Squads

```yaml
image_test_flow:
  t1: "Verify ComfyUI/API connection"
  t2: "Run minimal test generation (low steps)"
  t3: "Validate output image exists"
  t4: "Log generation metrics"

  specific_validations:
    - "comfyui.system_stats.gpu_available"
    - "generated_image.exists"
    - "generated_image.size > minimum_bytes"
```

---

## PHASE 3: BASELINE REGISTRATION

**Duration:** 30 seconds
**Mode:** Autonomous

### Step 3.1: Create Operational Baseline

```yaml
baseline_registration:
  purpose: "Record known-good state for future comparison"

  create_file:
    path: "squads/{squad_name}/data/operational-baseline.yaml"
    content:
      version: "1.0"
      test_date: "{timestamp}"
      test_mode: "{test_mode}"
      squad_name: "{squad_name}"

      target_tested:
        type: "{target.type}"
        id: "{target.id}"
        name: "{target.name}"

      validation_results:
        t1_fetch:
          status: "PASS|FAIL"
          records_fetched: "{count}"
          latency_ms: "{latency}"

        t2_process:
          status: "PASS|FAIL"
          processing_summary: "{summary}"

        t3_output:
          status: "PASS|FAIL"
          artifact_size: "{size}"
          sections_present: ["{sections}"]

        t4_notify:
          status: "PASS|SKIP|WARN"
          channel: "{channel}"

      overall:
        status: "OPERATIONAL|PARTIAL|FAILED"
        tests_passed: "{passed}/{total}"
        score: "{percentage}%"
        ready_for_production: "{boolean}"

      artifacts_generated:
        - ".aiox/squad-runtime/operational-test/{squad_name}/t1-data.json"
        - ".aiox/squad-runtime/operational-test/{squad_name}/t2-processed.json"
        - ".aiox/squad-runtime/operational-test/{squad_name}/t3-output.md"

      next_validation:
        recommended: "{timestamp + 7 days}"
        reason: "Weekly validation recommended"
```

---

## PHASE 4: RESULT PRESENTATION

**Duration:** 10 seconds
**Mode:** Interactive

### Step 4.1: Present Test Results

```
═══════════════════════════════════════════════════════════════════════════════
✅ OPERATIONAL TEST COMPLETE - {SQUAD_NAME}
═══════════════════════════════════════════════════════════════════════════════

TARGET TESTADO: {target.name} ({target.type}: {target.id})

RESULTADOS:
┌─────────────────────────────────────────────────────────────────────────────┐
│ Teste                    │ Status │ Detalhes                               │
├──────────────────────────┼────────┼────────────────────────────────────────┤
│ T1 - Fetch Data          │ ✅ PASS │ {t1_details}                           │
│ T2 - Process Data        │ ✅ PASS │ {t2_details}                           │
│ T3 - Generate Output     │ ✅ PASS │ {t3_details}                           │
│ T4 - Send Notification   │ ✅ PASS │ {t4_details}                           │
└─────────────────────────────────────────────────────────────────────────────┘

SCORE: {passed}/{total} ({percentage}%) - SQUAD OPERACIONAL

ARTEFATOS GERADOS:
- .aiox/squad-runtime/operational-test/{squad_name}/t1-data.json
- .aiox/squad-runtime/operational-test/{squad_name}/t2-processed.json
- .aiox/squad-runtime/operational-test/{squad_name}/t3-output.md
- squads/{squad_name}/data/operational-baseline.yaml

PROXIMO PASSO:
O squad esta pronto para uso em producao!

Para ativar (se aplicavel):
  *activate-monitoring

Para rodar este teste novamente:
  *operational-test

═══════════════════════════════════════════════════════════════════════════════
```

### Step 4.2: Handle Partial Failures

```yaml
partial_failure_handling:
  if_some_tests_fail:
    presentation: |
      ═══════════════════════════════════════════════════════════════════════════
      ⚠️ OPERATIONAL TEST PARTIAL - {SQUAD_NAME}
      ═══════════════════════════════════════════════════════════════════════════

      RESULTADOS:
      ┌───────────────────────────────────────────────────────────────────────────┐
      │ T1 - Fetch Data          │ ✅ PASS │                                     │
      │ T2 - Process Data        │ ❌ FAIL │ {failure_reason}                    │
      │ T3 - Generate Output     │ ✅ PASS │                                     │
      │ T4 - Send Notification   │ ⏭️ SKIP │ Slack not configured                │
      └───────────────────────────────────────────────────────────────────────────┘

      SCORE: {passed}/{total} ({percentage}%) - SQUAD PARCIALMENTE OPERACIONAL

      PROBLEMA DETECTADO:
      - {problem_description}
        Causa provavel: {probable_cause}
        Acao: {recommended_action}

      RECOMENDACAO:
      - {specific_recommendation}

      ═══════════════════════════════════════════════════════════════════════════

    decision_tree:
      if_t1_fails: "ABORT - API connection issue. Run *setup-runtime --validate"
      if_t2_fails:
        if_no_processing: "WARN - Expected if data is minimal"
        if_error: "ABORT - Core skill broken. Check skill configuration"
      if_t3_fails: "WARN - Output template issue. Squad still usable"
      if_t4_fails: "WARN - Notifications disabled. Squad still usable"
```

---

## Outputs

| Output | Location | Description |
|--------|----------|-------------|
| Raw Data | `.aiox/squad-runtime/operational-test/{squad_name}/t1-data.json` | Raw API response |
| Processed Data | `.aiox/squad-runtime/operational-test/{squad_name}/t2-processed.json` | Core skill output |
| Generated Output | `.aiox/squad-runtime/operational-test/{squad_name}/t3-output.md` | Final artifact |
| Operational Baseline | `data/operational-baseline.yaml` | Known-good state |

---

## Commands

```yaml
commands:
  standard:
    command: "*operational-test"
    description: "Run standard E2E test"

  full:
    command: "*operational-test --scope=full"
    description: "Test all skills"

  specific_target:
    command: "*operational-test --target={id}"
    description: "Test with specific target"

  sandbox:
    command: "*operational-test --mode=sandbox"
    description: "Use mock data instead of live API"

  verbose:
    command: "*operational-test --verbose"
    description: "Show detailed output for each step"
```

---

## Related Tasks

| Task | Purpose |
|------|---------|
| `setup-runtime.md` | Must run before this task |
| `auto-heal.md` | Triggered if test reveals fixable issues |
| `qa-after-creation.md` | Structural validation (different from this) |

---

## Veto Conditions

```yaml
veto_conditions:
  - id: "VETO-OPS-001"
    condition: "Operational test never run"
    blocks: "Autonomous operations"
    message: "Run *operational-test first to validate setup"

  - id: "VETO-OPS-002"
    condition: "Last operational test failed"
    blocks: "Autonomous actions"
    message: "Last test failed. Fix issues and re-run *operational-test"

  - id: "VETO-OPS-003"
    condition: "Operational baseline > 30 days old"
    blocks: "Autonomous actions without warning"
    message: "Baseline outdated. Recommend re-running *operational-test"
```

---

_Task Version: 1.0.0_
_Last Updated: 2026-02-26_
_Philosophy: "A squad is only operational when it produces REAL output."_
