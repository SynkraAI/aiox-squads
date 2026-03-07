# Task: Detect Operational Mode

**Task ID:** detect-operational-mode
**Execution Type:** Autonomous
**Purpose:** Analyze squad briefing to determine if squad requires operational mode (external API connections) or textual mode (recommendations only)
**Orchestrator:** @squad-chief
**Mode:** Triggered during squad creation (Phase 2)
**Model:** `Haiku` (signal classification over explicit verbs/systems/outputs)
**Haiku Eligible:** YES -- deterministic heuristics dominate this classification task

**Philosophy:**
```
"A squad that recommends is useful. A squad that executes is powerful.
 Detect intent early to build the right infrastructure."
```

---

## Overview

This task analyzes the squad briefing to classify the squad into one of two modes:

| Mode | Description | Infrastructure |
|------|-------------|----------------|
| **OPERATIONAL** | Squad produces REAL outputs via external systems | API connections, setup wizard, E2E tests, auto-heal |
| **TEXTUAL** | Squad produces recommendations, analysis, strategies | Documentation, templates, checklists |

**Key Insight:** The difference is in the VERBS used in the briefing:
- OPERATIONAL verbs: "create", "send", "post", "update", "delete", "execute", "monitor", "sync"
- TEXTUAL verbs: "recommend", "analyze", "suggest", "review", "evaluate", "assess"

---

## Inputs

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `briefing` | string | Yes | Raw briefing text from user |
| `outputs_defined` | list | Yes | List of expected outputs from briefing analysis |
| `skills_detected` | list | No | Skills already identified for the squad |

## Veto Conditions

```yaml
veto_conditions:
  - id: "VETO-OPMODE-001"
    condition: "Insufficient classification signals (no actionable verbs and no outputs_defined)"
    trigger: "Before PHASE 2 mode determination"
    block_behavior: "BLOCK final classification; require additional briefing detail"

  - id: "VETO-OPMODE-002"
    condition: "Operational score derived from ambiguous or conflicting evidence only"
    trigger: "When operational_score is near threshold and confidence is low"
    block_behavior: "BLOCK automatic mode assignment; require explicit user confirmation"
```

---

## PHASE 1: BRIEFING ANALYSIS

**Duration:** 30 seconds
**Mode:** Autonomous

### Step 1.1: Extract Action Verbs

```yaml
verb_extraction:
  scan_briefing_for:
    operational_verbs:
      - create: "Create forms, create campaigns, create posts"
      - send: "Send emails, send notifications, send reports"
      - post: "Post to social media, post updates"
      - update: "Update records, update status, update campaigns"
      - delete: "Delete entries, delete campaigns"
      - execute: "Execute trades, execute actions"
      - monitor: "Monitor campaigns, monitor metrics"
      - sync: "Sync data, sync contacts"
      - publish: "Publish content, publish pages"
      - schedule: "Schedule posts, schedule campaigns"
      - pause: "Pause campaigns, pause automations"
      - scale: "Scale budget, scale campaigns"
      - trigger: "Trigger webhooks, trigger workflows"
      - generate: "Generate images, generate videos" # When output is file, not text
      - upload: "Upload files, upload media"
      - download: "Download reports, download data"

    textual_verbs:
      - recommend: "Recommend strategies, recommend changes"
      - analyze: "Analyze data, analyze competitors"
      - suggest: "Suggest improvements, suggest copy"
      - review: "Review campaigns, review content"
      - evaluate: "Evaluate performance, evaluate options"
      - assess: "Assess risk, assess quality"
      - diagnose: "Diagnose problems, diagnose performance"
      - audit: "Audit accounts, audit processes"
      - plan: "Plan campaigns, plan strategy"
      - draft: "Draft copy, draft proposals"
      - outline: "Outline strategy, outline approach"
      - brainstorm: "Brainstorm ideas, brainstorm angles"

  output:
    operational_verb_count: "{count}"
    textual_verb_count: "{count}"
    primary_mode_signal: "OPERATIONAL|TEXTUAL"
```

### Step 1.2: Detect External System References

```yaml
system_detection:
  scan_briefing_for:
    ad_platforms:
      patterns: ["Meta Ads", "Facebook Ads", "Google Ads", "TikTok Ads", "LinkedIn Ads"]
      implies: "OPERATIONAL (requires API connection)"

    form_builders:
      patterns: ["Typeform", "Google Forms", "Tally", "JotForm", "Formstack"]
      implies: "OPERATIONAL (requires API connection)"

    crm_systems:
      patterns: ["HubSpot", "Salesforce", "Pipedrive", "ActiveCampaign", "Zoho"]
      implies: "OPERATIONAL (requires API connection)"

    spreadsheets:
      patterns: ["Google Sheets", "Airtable", "Notion database", "Excel Online"]
      implies: "OPERATIONAL (requires API connection)"

    messaging:
      patterns: ["Slack", "Discord", "Telegram", "WhatsApp Business", "email automation"]
      implies: "OPERATIONAL (requires API connection)"

    social_media:
      patterns: ["Instagram", "Twitter/X", "LinkedIn posts", "YouTube", "TikTok"]
      implies: "OPERATIONAL (requires API connection)"

    payment:
      patterns: ["Stripe", "PayPal", "payment processing", "checkout"]
      implies: "OPERATIONAL (requires API connection)"

    automation:
      patterns: ["Zapier", "Make", "n8n", "workflow automation"]
      implies: "OPERATIONAL (may need webhook/API)"

    ai_generation:
      patterns: ["generate images", "generate videos", "ComfyUI", "Midjourney", "DALL-E"]
      implies: "OPERATIONAL (requires API/local service)"

    no_external_system:
      patterns: ["strategy", "playbook", "framework", "methodology", "best practices"]
      implies: "TEXTUAL (documentation only)"

  output:
    systems_detected: ["{list}"]
    api_connections_required: ["{list}"]
    mode_from_systems: "OPERATIONAL|TEXTUAL"
```

### Step 1.3: Analyze Output Expectations

```yaml
output_analysis:
  classify_each_output:
    operational_outputs:
      - "Forms created in {platform}"
      - "Campaigns created/modified"
      - "Leads registered in {CRM}"
      - "Notifications sent via {channel}"
      - "Reports synced to {spreadsheet}"
      - "Images/videos generated"
      - "Posts published to {platform}"
      - "Emails sent automatically"
      - "Data synced between systems"
      - "Webhooks triggered"

    textual_outputs:
      - "Strategy document"
      - "Recommendation report"
      - "Analysis summary"
      - "Copy suggestions"
      - "Audit checklist"
      - "Best practices guide"
      - "Template collection"
      - "Framework documentation"
      - "Research findings"
      - "Competitive analysis"

  decision_matrix:
    if_all_outputs_textual: "MODE = TEXTUAL"
    if_any_output_operational: "MODE = OPERATIONAL"
    if_mixed: "MODE = OPERATIONAL (operational outputs require infrastructure)"

  output:
    operational_outputs_count: "{count}"
    textual_outputs_count: "{count}"
    mode_from_outputs: "OPERATIONAL|TEXTUAL"
```

---

## PHASE 2: MODE DETERMINATION

**Duration:** 10 seconds
**Mode:** Autonomous

### Step 2.1: Calculate Mode Score

```yaml
mode_scoring:
  weights:
    verb_analysis: 0.3
    system_detection: 0.4
    output_analysis: 0.3

  calculation:
    operational_score: |
      (operational_verbs / total_verbs) * 0.3 +
      (systems_detected > 0 ? 1 : 0) * 0.4 +
      (operational_outputs / total_outputs) * 0.3

    textual_score: 1 - operational_score

  thresholds:
    operational: ">= 0.3"  # Low threshold - any operational intent triggers full infrastructure
    textual: "< 0.3"

  final_mode:
    if: "operational_score >= 0.3"
    then: "OPERATIONAL"
    else: "TEXTUAL"
```

### Step 2.2: Generate Mode Report

```yaml
mode_report:
  structure:
    mode_detected: "OPERATIONAL|TEXTUAL"
    confidence: "HIGH|MEDIUM|LOW"

    evidence:
      verbs:
        operational: ["{list}"]
        textual: ["{list}"]

      systems:
        detected: ["{list}"]
        apis_required: ["{list}"]

      outputs:
        operational: ["{list}"]
        textual: ["{list}"]

    scores:
      operational: "{percentage}"
      textual: "{percentage}"

    infrastructure_required:
      if_operational:
        - "setup-runtime.md (API connection wizard)"
        - "operational-test.md (E2E validation)"
        - "auto-heal.md (self-correction)"
        - "monitoring configuration"
      if_textual:
        - "Standard QA only"
        - "No API connections"
        - "No monitoring"

  example_operational:
    mode_detected: "OPERATIONAL"
    confidence: "HIGH"
    evidence:
      verbs:
        operational: ["create forms", "register leads", "send notifications", "sync data"]
        textual: []
      systems:
        detected: ["Typeform", "Google Sheets", "Slack"]
        apis_required: ["TYPEFORM_API_KEY", "GOOGLE_SHEETS_CREDENTIALS", "SLACK_WEBHOOK_URL"]
      outputs:
        operational: ["Forms created in Typeform", "Leads in Google Sheets", "Slack notifications"]
        textual: []
    scores:
      operational: "95%"
      textual: "5%"
    infrastructure_required:
      - "setup-runtime.md"
      - "operational-test.md"
      - "auto-heal.md"

  example_textual:
    mode_detected: "TEXTUAL"
    confidence: "HIGH"
    evidence:
      verbs:
        operational: []
        textual: ["analyze", "recommend", "evaluate", "suggest"]
      systems:
        detected: []
        apis_required: []
      outputs:
        operational: []
        textual: ["Strategy document", "Recommendation report", "Best practices"]
    scores:
      operational: "0%"
      textual: "100%"
    infrastructure_required:
      - "Standard QA only"
```

---

## PHASE 3: INFRASTRUCTURE MAPPING

**Duration:** 30 seconds
**Mode:** Autonomous (only if OPERATIONAL)

### Step 3.1: Map Required APIs

```yaml
api_mapping:
  condition: "mode == OPERATIONAL"

  for_each_system_detected:
    typeform:
      api_name: "Typeform API"
      env_vars:
        - "TYPEFORM_API_KEY"
        - "TYPEFORM_WORKSPACE_ID"
      docs_url: "https://developer.typeform.com/"
      validation_endpoint: "GET /me"

    google_sheets:
      api_name: "Google Sheets API"
      env_vars:
        - "GOOGLE_SHEETS_CREDENTIALS_JSON"
        - "GOOGLE_SHEETS_SPREADSHEET_ID"
      docs_url: "https://developers.google.com/sheets/api"
      validation_endpoint: "GET /spreadsheets/{id}"

    meta_ads:
      api_name: "Meta Ads API"
      env_vars:
        - "META_ADS_ACCESS_TOKEN"
        - "META_ADS_APP_ID"
        - "META_ADS_APP_SECRET"
        - "META_ADS_ACCOUNT_ID"
      docs_url: "https://developers.facebook.com/docs/marketing-apis"
      validation_endpoint: "GET /me"

    google_ads:
      api_name: "Google Ads API"
      env_vars:
        - "GOOGLE_ADS_DEVELOPER_TOKEN"
        - "GOOGLE_ADS_CLIENT_ID"
        - "GOOGLE_ADS_CLIENT_SECRET"
        - "GOOGLE_ADS_REFRESH_TOKEN"
        - "GOOGLE_ADS_CUSTOMER_ID"
      docs_url: "https://developers.google.com/google-ads/api"
      validation_endpoint: "customers/{id}"

    slack:
      api_name: "Slack Webhook"
      env_vars:
        - "SLACK_WEBHOOK_URL"
        - "SLACK_CHANNEL_ALERTS"
      docs_url: "https://api.slack.com/messaging/webhooks"
      validation_endpoint: "POST webhook"

    hubspot:
      api_name: "HubSpot API"
      env_vars:
        - "HUBSPOT_API_KEY"
        - "HUBSPOT_PORTAL_ID"
      docs_url: "https://developers.hubspot.com/"
      validation_endpoint: "GET /crm/v3/objects/contacts"

    stripe:
      api_name: "Stripe API"
      env_vars:
        - "STRIPE_SECRET_KEY"
        - "STRIPE_PUBLISHABLE_KEY"
      docs_url: "https://stripe.com/docs/api"
      validation_endpoint: "GET /v1/balance"

    comfyui:
      api_name: "ComfyUI Local"
      env_vars:
        - "COMFYUI_PATH"
        - "COMFYUI_PORT"
      docs_url: "https://github.com/comfyanonymous/ComfyUI"
      validation_endpoint: "GET /system_stats"

  output:
    required_apis: ["{list}"]
    env_vars_template: "{yaml}"
    setup_instructions: ["{per_api}"]
```

### Step 3.2: Generate Operational Infrastructure

```yaml
infrastructure_generation:
  condition: "mode == OPERATIONAL"

  generate_files:
    - template: "setup-runtime-template.md"
      output: "squads/{squad_name}/tasks/setup-runtime.md"
      customize:
        - "Required APIs from mapping"
        - "Environment variables"
        - "Validation endpoints"

    - template: "operational-test-template.md"
      output: "squads/{squad_name}/tasks/operational-test.md"
      customize:
        - "Test cases per API"
        - "Expected outputs"
        - "Success criteria"

    - template: "auto-heal-template.md"
      output: "squads/{squad_name}/tasks/auto-heal.md"
      customize:
        - "Error patterns per API"
        - "Fix strategies"
        - "Escalation rules"

  update_workflow:
    file: "squads/{squad_name}/workflows/wf-operationalize.yaml"
    add_phases:
      - "Phase 6: Setup Runtime"
      - "Phase 7: Operational Test"
      - "Phase 8: Activate & Handoff"
```

---

## Outputs

| Output | Location | Description |
|--------|----------|-------------|
| Mode Report | `squads/{squad_name}/data/mode-detection.yaml` | Full analysis results |
| API Requirements | `squads/{squad_name}/data/api-requirements.yaml` | Required APIs and env vars |
| Infrastructure Files | `squads/{squad_name}/tasks/` | Generated operational tasks |

---

## Decision Tree

```
                    ┌─────────────────────────────────┐
                    │        BRIEFING ANALYSIS        │
                    └─────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
              ┌─────▼─────┐   ┌─────▼─────┐   ┌─────▼─────┐
              │   VERBS   │   │  SYSTEMS  │   │  OUTPUTS  │
              │ Analysis  │   │ Detection │   │ Analysis  │
              └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
                    │               │               │
                    └───────────────┼───────────────┘
                                    │
                         ┌──────────▼──────────┐
                         │   MODE CALCULATION  │
                         │  (weighted scores)  │
                         └──────────┬──────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
            ┌───────▼───────┐               ┌───────▼───────┐
            │  OPERATIONAL  │               │    TEXTUAL    │
            │   (>= 30%)    │               │    (< 30%)    │
            └───────┬───────┘               └───────┬───────┘
                    │                               │
        ┌───────────┴───────────┐                   │
        │                       │                   │
   ┌────▼────┐            ┌─────▼─────┐       ┌─────▼─────┐
   │ Map APIs│            │ Generate  │       │ Standard  │
   │         │            │ Infra     │       │ QA Only   │
   └────┬────┘            └─────┬─────┘       └───────────┘
        │                       │
        └───────────┬───────────┘
                    │
         ┌──────────▼──────────┐
         │  PROCEED TO SETUP   │
         │  (wf-create-squad   │
         │   Phase 6+)         │
         └─────────────────────┘
```

---

## Integration with wf-create-squad.yaml

```yaml
workflow_integration:
  trigger_point: "After Phase 2 (Briefing Analysis)"

  inject_into_workflow:
    after_phase_2:
      - task: "detect-operational-mode.md"
        input: "{briefing, outputs_defined}"

    conditional_phases:
      if_operational:
        - "Phase 6: Setup Runtime (setup-runtime.md)"
        - "Phase 7: Operational Test (operational-test.md)"
        - "Phase 8: Activate & Handoff"
      if_textual:
        - "Skip directly to Phase 5 (QA)"
        - "Standard handoff"

  workflow_branching:
    decision_point: "mode_detection.result"
    branches:
      OPERATIONAL: "Full operational flow with API setup"
      TEXTUAL: "Standard squad creation flow"
```

---

## Commands

```yaml
commands:
  auto:
    command: "*detect-mode"
    description: "Auto-detect mode from briefing (used internally)"

  force_operational:
    command: "*detect-mode --force=operational"
    description: "Force operational mode regardless of briefing"

  force_textual:
    command: "*detect-mode --force=textual"
    description: "Force textual mode regardless of briefing"

  debug:
    command: "*detect-mode --debug"
    description: "Show full analysis breakdown"
```

---

_Task Version: 1.0.0_
_Last Updated: 2026-02-26_
_Philosophy: "Detect intent early to build the right infrastructure."_
