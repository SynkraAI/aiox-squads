#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# VALIDATE-SQUAD.SH - Hybrid Squad Validation Script
# ═══════════════════════════════════════════════════════════════════════════════
# Version: 3.0.0 - Production Validation
# Compatibility: bash 3.2+ (macOS compatible)
# Purpose: Hybrid validation - bash for deterministic, Claude for qualitative
# Usage: ./validate-squad.sh <squad-name> [--verbose] [--quick] [--json]
#
# HYBRID APPROACH:
#   BASH (deterministic):
#     - File/directory existence
#     - Security scan (grep patterns)
#     - Cross-reference validation
#     - Metrics collection (counts, ratios)
#
#   CLAUDE CLI (qualitative):
#     - Prompt quality analysis
#     - Pipeline coherence evaluation
#     - Voice consistency check
#     - Overall assessment & recommendations
#
# Exit codes:
#   0 = PASS (score >= 7.0, no blocking issues)
#   1 = FAIL (score < 7.0 or blocking issues)
#   2 = ERROR (script error, invalid input)
# ═══════════════════════════════════════════════════════════════════════════════

set -uo pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQUAD_CREATOR_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SQUADS_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)/squads"
RUNTIME_STATE_HELPER="$SCRIPT_DIR/lib/validate-runtime-state.cjs"

# Model configuration
MODEL_DEFAULT="opus"    # Best quality (default)
MODEL_FAST="haiku"      # Quick & cheap
MODEL_QUALITY="$MODEL_DEFAULT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Counters
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Results arrays
BLOCKING_ISSUES=""
WARNINGS=""

# Metrics (simple variables for bash 3.x compatibility)
M_AGENT_COUNT=0
M_TASK_COUNT=0
M_CHECKLIST_COUNT=0
M_TEMPLATE_COUNT=0
M_DATA_COUNT=0
M_TOTAL_LINES=0
M_SECURITY_ISSUES=0
M_XREF_ISSUES=0
M_SQUAD_TYPE="unknown"
M_TYPE_CONFIDENCE=0
M_PROMPT_QUALITY=0
M_STRUCTURE_COHERENCE=0
M_COVERAGE_SCORE=0
M_DOCUMENTATION=0
M_QUALITY_SCORE="N/A"
M_IMPROVEMENTS=""
M_PROD_SCORE=0
M_WORKFLOW_CONTRACT_FILES=0
M_WORKFLOW_CONTRACT_ERRORS=0
M_WORKFLOW_CONTRACT_WARNINGS=0

# Phase results
TIER1_FAIL=0
SEC_FAIL=0
XREF_FAIL=0
WF_CONTRACT_FAIL=0
PROD_SCORE=0
PROD_MAX=5
FINAL_SCORE=0
ENTRY_AGENT=""
VALIDATION_RESULT="FAIL"
EXIT_CODE=1
CURRENT_PHASE="init"

# ═══════════════════════════════════════════════════════════════════════════════
# ARGUMENT PARSING
# ═══════════════════════════════════════════════════════════════════════════════

show_help() {
  cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║       🔍 VALIDATE-SQUAD v2.0 - Hybrid Validation Tool        ║
╚══════════════════════════════════════════════════════════════╝

Usage: ./validate-squad.sh <squad-name> [options]

Arguments:
  squad-name    Name of squad to validate (e.g., "my-squad", "new-squad")

Options:
  --verbose     Show all checks and Claude analysis details
  --quick       Skip Claude analysis (deterministic only)
  --fast        Use Haiku instead of Opus (cheaper, faster)
  --json        Output results as JSON
  --help        Show this help message

Examples:
  ./validate-squad.sh {squad-name}              # Full validation with Opus
  ./validate-squad.sh {squad-name} --verbose    # Verbose output
  ./validate-squad.sh {squad-name} --quick      # Deterministic only (no Claude)
  ./validate-squad.sh {squad-name} --fast       # Quick validation with Haiku

Exit Codes:
  0  PASS     Score >= 7.0, no blocking issues
  1  FAIL     Score < 7.0 or blocking issues found
  2  ERROR    Invalid input or script error

EOF
  exit 0
}

SQUAD_NAME=""
VERBOSE=false
QUICK_MODE=false
JSON_OUTPUT=false
FAST_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      show_help
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --quick|-q)
      QUICK_MODE=true
      shift
      ;;
    --fast|-f)
      FAST_MODE=true
      MODEL_QUALITY="$MODEL_FAST"
      shift
      ;;
    --json|-j)
      JSON_OUTPUT=true
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      exit 2
      ;;
    *)
      SQUAD_NAME="$1"
      shift
      ;;
  esac
done

if [[ -z "$SQUAD_NAME" ]]; then
  echo "Error: Squad name required"
  echo "Usage: ./validate-squad.sh <squad-name>"
  exit 2
fi

SQUAD_DIR="$SQUADS_DIR/$SQUAD_NAME"

if [[ ! -d "$SQUAD_DIR" ]]; then
  echo "Error: Squad not found: $SQUAD_DIR"
  exit 2
fi

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING HELPERS
# ═══════════════════════════════════════════════════════════════════════════════

log_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  if [[ "$VERBOSE" == "true" ]]; then
    echo -e "  ${GREEN}✓${NC} $1"
  fi
}

log_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  echo -e "  ${RED}✗${NC} $1"
  BLOCKING_ISSUES="${BLOCKING_ISSUES}${1}\n"
}

log_warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  echo -e "  ${YELLOW}⚠${NC} $1"
  WARNINGS="${WARNINGS}${1}\n"
}

log_info() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo -e "  ${CYAN}ℹ${NC} $1"
  fi
}

log_section() {
  echo ""
  echo -e "${BOLD}${BLUE}═══ $1 ═══${NC}"
}

log_subsection() {
  echo -e "${CYAN}--- $1 ---${NC}"
}

# Runtime state helper (best-effort, non-blocking)
runtime_state_call() {
  if [[ ! -f "$RUNTIME_STATE_HELPER" ]]; then
    return 0
  fi

  if ! node "$RUNTIME_STATE_HELPER" "$@" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Runtime state update failed (${*})${NC}" >&2
    return 1
  fi

  return 0
}

runtime_state_start() {
  local mode="hybrid"
  if [[ "$QUICK_MODE" == "true" ]]; then
    mode="quick"
  fi

  runtime_state_call start \
    --squad "$SQUAD_NAME" \
    --mode "$mode" \
    --model "$MODEL_QUALITY" \
    --quick "$QUICK_MODE" \
    --verbose "$VERBOSE" \
    --json "$JSON_OUTPUT"
}

runtime_state_phase_start() {
  local phase="$1"
  CURRENT_PHASE="$phase"
  runtime_state_call phase --squad "$SQUAD_NAME" --phase "$phase" --status in_progress
}

runtime_state_phase_complete() {
  local phase="$1"
  local status="${2:-completed}"
  runtime_state_call phase --squad "$SQUAD_NAME" --phase "$phase" --status "$status"
}

runtime_state_complete() {
  local status="$1"
  runtime_state_call complete \
    --squad "$SQUAD_NAME" \
    --status "$status" \
    --result "$VALIDATION_RESULT" \
    --final-score "$FINAL_SCORE" \
    --exit-code "$EXIT_CODE" \
    --warnings "$WARN_COUNT" \
    --tier1-fail "$TIER1_FAIL" \
    --security-fail "$SEC_FAIL" \
    --workflow-contract-fail "$WF_CONTRACT_FAIL" \
    --xref-fail "$XREF_FAIL" \
    --phase "$CURRENT_PHASE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SCORING/JSON HELPERS
# ═══════════════════════════════════════════════════════════════════════════════

is_numeric_score() {
  [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

clamp_score_0_10() {
  awk -v n="$1" 'BEGIN { if (n < 0) n = 0; if (n > 10) n = 10; printf "%.2f", n }'
}

round_score_0_10_int() {
  awk -v n="$1" 'BEGIN { if (n < 0) n = 0; if (n > 10) n = 10; printf "%d", int(n + 0.5) }'
}

extract_first_json_object() {
  python3 - <<'PY'
import json
import re
import sys

text = sys.stdin.read()
text = re.sub(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])', '', text)
text = text.replace("```json", "```").replace("```JSON", "```")

decoder = json.JSONDecoder()
for index, char in enumerate(text):
    if char != "{":
        continue
    try:
        obj, _ = decoder.raw_decode(text[index:])
    except Exception:
        continue
    if isinstance(obj, dict):
        print(json.dumps(obj, ensure_ascii=False))
        sys.exit(0)

print("{}")
PY
}

parse_claude_metrics() {
  python3 - <<'PY'
import json
import sys

raw = sys.stdin.read().strip()
try:
    data = json.loads(raw) if raw else {}
except Exception:
    data = {}

def clamp_score(value):
    try:
        number = float(value)
    except Exception:
        return None
    if number < 0:
        number = 0.0
    if number > 10:
        number = 10.0
    return number

def format_score(value):
    number = clamp_score(value)
    if number is None:
        return "0"
    return f"{number:.2f}".rstrip("0").rstrip(".") or "0"

quality = clamp_score(data.get("overall_score"))
quality_value = "N/A" if quality is None else (f"{quality:.2f}".rstrip("0").rstrip(".") or "0")

improvements = data.get("improvements", "")
if isinstance(improvements, list):
    improvements = "; ".join(str(item).strip() for item in improvements if str(item).strip())
elif improvements is None:
    improvements = ""
else:
    improvements = str(improvements).strip()

improvements = improvements.replace("\n", " ").replace("\t", " ").strip()

fields = {
    "prompt_quality": format_score(data.get("prompt_quality", 0)),
    "structure_coherence": format_score(data.get("structure_coherence", 0)),
    "coverage": format_score(data.get("coverage", 0)),
    "documentation": format_score(data.get("documentation", 0)),
    "quality_score": quality_value,
    "improvements": improvements,
}

for key, value in fields.items():
    print(f"{key}\t{value}")
PY
}

parse_workflow_contract_totals() {
  node -e '
const fs = require("fs");
const raw = fs.readFileSync(0, "utf8").trim();
const ansiStripped = raw.replace(/\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])/g, "");

function extractFirstJsonObject(text) {
  for (let start = 0; start < text.length; start += 1) {
    if (text[start] !== "{") continue;
    let depth = 0;
    let inString = false;
    let escaped = false;
    for (let i = start; i < text.length; i += 1) {
      const ch = text[i];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (ch === "\\\\") {
          escaped = true;
        } else if (ch === "\"") {
          inString = false;
        }
        continue;
      }
      if (ch === "\"") {
        inString = true;
        continue;
      }
      if (ch === "{") depth += 1;
      if (ch === "}") {
        depth -= 1;
        if (depth === 0) return text.slice(start, i + 1);
      }
    }
  }
  return "{}";
}

let data = {};
const firstObject = extractFirstJsonObject(ansiStripped);
try {
  data = firstObject ? JSON.parse(firstObject) : {};
} catch {
  data = {};
}
const totals = data.totals || {};
const fields = {
  files_checked: Number(totals.files_checked) || 0,
  errors: Number(totals.errors) || 0,
  warnings: Number(totals.warnings) || 0,
  invalid_files: Number(totals.invalid_files) || 0,
};
for (const [key, value] of Object.entries(fields)) {
  console.log(`${key}\t${value}`);
}
'
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 1: STRUCTURE (Deterministic - Bash)
# ═══════════════════════════════════════════════════════════════════════════════

check_structure() {
  log_section "PHASE 1: Structure Validation (Bash)"
  local tier1_fail=0

  # 1.1 Config file
  log_subsection "1.1 Configuration"
  if [[ -f "$SQUAD_DIR/config.yaml" ]]; then
    log_pass "config.yaml exists"

    # Check for name (top-level or under squad:/pack:)
    if grep -qE "^name:|^[[:space:]]+name:" "$SQUAD_DIR/config.yaml" 2>/dev/null; then
      log_pass "config.yaml has 'name' field"
    else
      log_fail "config.yaml missing 'name' field"
      tier1_fail=$((tier1_fail + 1))
    fi

    # Check for version (top-level or under squad:/pack:)
    if grep -qE "^version:|^[[:space:]]+version:" "$SQUAD_DIR/config.yaml" 2>/dev/null; then
      log_pass "config.yaml has 'version' field"
    else
      log_fail "config.yaml missing 'version' field"
      tier1_fail=$((tier1_fail + 1))
    fi

    # Check for entry_agent (top-level, under squad:/pack:, or in agents list)
    if grep -q "entry_agent:" "$SQUAD_DIR/config.yaml" 2>/dev/null; then
      log_pass "config.yaml has 'entry_agent' field"
      ENTRY_AGENT=$(grep "entry_agent:" "$SQUAD_DIR/config.yaml" | head -1 | sed 's/.*entry_agent:[[:space:]]*//' | tr -d '"' | tr -d "'" | xargs)
    elif grep -qE "^[[:space:]]+- id:" "$SQUAD_DIR/config.yaml" 2>/dev/null; then
      # Has agents list, extract first agent as entry point
      ENTRY_AGENT=$(grep -E "^[[:space:]]+- id:" "$SQUAD_DIR/config.yaml" | head -1 | sed 's/.*- id:[[:space:]]*//' | tr -d '"' | tr -d "'" | xargs)
      log_warn "No entry_agent defined, using first agent: $ENTRY_AGENT"
    else
      log_warn "config.yaml missing 'entry_agent' field (non-blocking)"
    fi
  else
    log_fail "config.yaml not found"
    tier1_fail=$((tier1_fail + 1))
  fi

  # 1.2 Entry agent
  log_subsection "1.2 Entry Point"
  if [[ -n "${ENTRY_AGENT:-}" ]]; then
    if [[ -f "$SQUAD_DIR/agents/${ENTRY_AGENT}.md" ]]; then
      log_pass "Entry agent exists: agents/${ENTRY_AGENT}.md"
    else
      log_fail "Entry agent not found: agents/${ENTRY_AGENT}.md"
      tier1_fail=$((tier1_fail + 1))
    fi
  fi

  # 1.3 Workspace integration governance
  log_subsection "1.3 Workspace Integration Governance"
  local workspace_level=""
  workspace_level=$(awk '
    BEGIN { in_ws=0 }
    /^workspace_integration_level:[[:space:]]*/ {
      gsub(/^workspace_integration_level:[[:space:]]*/, "", $0);
      gsub(/["'\'']/, "", $0);
      gsub(/[[:space:]]/, "", $0);
      print $0;
      exit;
    }
    /^workspace_integration:[[:space:]]*$/ { in_ws=1; next }
    in_ws && /^[^[:space:]]/ { in_ws=0 }
    in_ws && /^[[:space:]]*level:[[:space:]]*/ {
      gsub(/^[[:space:]]*level:[[:space:]]*/, "", $0);
      gsub(/["'\'']/, "", $0);
      gsub(/[[:space:]]/, "", $0);
      print $0;
      exit;
    }
  ' "$SQUAD_DIR/config.yaml" 2>/dev/null || true)

  case "$workspace_level" in
    none|read_only|read_write|workspace_first)
      log_pass "workspace integration level declared: $workspace_level"
      ;;
    "")
      log_fail "config.yaml missing workspace integration level (workspace_integration.level)"
      tier1_fail=$((tier1_fail + 1))
      ;;
    *)
      log_fail "invalid workspace integration level: '$workspace_level'"
      tier1_fail=$((tier1_fail + 1))
      ;;
  esac

  if [[ -n "$workspace_level" && "$workspace_level" != "none" ]]; then
    if rg -n "workspace/" "$SQUAD_DIR/agents" "$SQUAD_DIR/tasks" "$SQUAD_DIR/workflows" "$SQUAD_DIR/config.yaml" >/dev/null 2>&1; then
      log_pass "workspace references found for integration level '$workspace_level'"
    else
      log_fail "workspace integration level '$workspace_level' declared but no workspace paths found"
      tier1_fail=$((tier1_fail + 1))
    fi
  fi

  if [[ "$workspace_level" == "workspace_first" ]]; then
    local bootstrap_count=0
    local essentials_count=0
    bootstrap_count=$(find "$SQUAD_DIR/scripts" -maxdepth 1 -type f -name "bootstrap-*-workspace.sh" 2>/dev/null | wc -l | tr -d ' ')
    essentials_count=$(find "$SQUAD_DIR/scripts" -maxdepth 1 -type f -name "validate-*-essentials.sh" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$bootstrap_count" -gt 0 ]]; then
      log_pass "workspace_first has bootstrap script"
    else
      log_fail "workspace_first requires scripts/bootstrap-*-workspace.sh"
      tier1_fail=$((tier1_fail + 1))
    fi
    if [[ "$essentials_count" -gt 0 ]]; then
      log_pass "workspace_first has essentials validator script"
    else
      log_fail "workspace_first requires scripts/validate-*-essentials.sh"
      tier1_fail=$((tier1_fail + 1))
    fi
  fi

  # 1.4 Directory structure
  log_subsection "1.4 Directory Structure"
  local found_dirs=0
  for dir in agents tasks checklists templates data; do
    if [[ -d "$SQUAD_DIR/$dir" ]]; then
      local count=$(find "$SQUAD_DIR/$dir" -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | wc -l | tr -d ' ')
      log_pass "$dir/ exists ($count files)"
      found_dirs=$((found_dirs + 1))
    else
      log_info "$dir/ not found (optional)"
    fi
  done

  # 1.5 Collect metrics
  log_subsection "1.5 Metrics Collection"
  M_AGENT_COUNT=$(find "$SQUAD_DIR/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  M_TASK_COUNT=$(find "$SQUAD_DIR/tasks" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  M_CHECKLIST_COUNT=$(find "$SQUAD_DIR/checklists" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  M_TEMPLATE_COUNT=$(find "$SQUAD_DIR/templates" -type f 2>/dev/null | wc -l | tr -d ' ')
  M_DATA_COUNT=$(find "$SQUAD_DIR/data" -type f 2>/dev/null | wc -l | tr -d ' ')
  M_TOTAL_LINES=$(find "$SQUAD_DIR" -type f \( -name "*.md" -o -name "*.yaml" \) -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')

  log_info "Agents: $M_AGENT_COUNT, Tasks: $M_TASK_COUNT, Checklists: $M_CHECKLIST_COUNT"
  log_info "Total lines: $M_TOTAL_LINES"

  TIER1_FAIL=$tier1_fail
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 2: SECURITY SCAN (Deterministic - Bash)
# ═══════════════════════════════════════════════════════════════════════════════

check_security() {
  log_section "PHASE 2: Security Scan (Bash)"
  local sec_fail=0
  local security_excludes=(
    --exclude-dir=.git
    --exclude-dir=__pycache__
    --exclude-dir=node_modules
  )

  log_subsection "2.1 API Keys & Tokens"

  # API Keys (excluding placeholders, examples, documentation, fake values)
  local api_keys=$(grep -rE "${security_excludes[@]}" "(api[_-]?key|apikey)[[:space:]]*[:=][[:space:]]*['\"][^'\"\$\{]{8,}" "$SQUAD_DIR" 2>/dev/null | grep -vE "(\{\{|\\\$\{|process\.env|[Ee]xample|placeholder|grep|pattern|EXAMPLE|sk-1234|your-key|#.*api)" || true)
  if [[ -n "$api_keys" ]]; then
    log_fail "SEC-001: Potential API keys found"
    sec_fail=$((sec_fail + 1))
  else
    log_pass "SEC-001: No hardcoded API keys"
  fi

  # Secrets (excluding examples, documentation, fake values, obvious test secrets)
  local secrets=$(grep -rE "${security_excludes[@]}" "(secret|password)[[:space:]]*[:=][[:space:]]*['\"][^'\"\$\{]{8,}" "$SQUAD_DIR" 2>/dev/null | grep -vE "(\{\{|\\\$\{|process\.env|[Ee]xample|placeholder|grep|pattern|EXAMPLE|secret_key|your-secret|#.*secret|#.*password|mySecret|super-secret|-secret-|-here)" || true)
  if [[ -n "$secrets" ]]; then
    log_fail "SEC-002: Potential secrets found"
    sec_fail=$((sec_fail + 1))
  else
    log_pass "SEC-002: No hardcoded secrets"
  fi

  log_subsection "2.2 Cloud Credentials"

  # AWS Access Key (excluding examples, grep patterns, documentation)
  local aws_access=$(grep -rE "${security_excludes[@]}" "AKIA[A-Z0-9]{16}" "$SQUAD_DIR" 2>/dev/null | grep -vE "(EXAMPLE|grep|pattern|\.sh:|\.md:.*grep)" || true)
  if [[ -n "$aws_access" ]]; then
    log_fail "SEC-003: AWS Access Key found"
    sec_fail=$((sec_fail + 1))
  else
    log_pass "SEC-003: No AWS Access Keys"
  fi

  # GCP Service Account
  local gcp_key=$(grep -rE "${security_excludes[@]}" '"type"[[:space:]]*:[[:space:]]*"service_account"' "$SQUAD_DIR" 2>/dev/null || true)
  if [[ -n "$gcp_key" ]]; then
    log_fail "SEC-004: GCP Service Account found"
    sec_fail=$((sec_fail + 1))
  else
    log_pass "SEC-004: No GCP Service Accounts"
  fi

  log_subsection "2.3 Private Keys"

  local priv_key=$(grep -rE "${security_excludes[@]}" "-----BEGIN.*(PRIVATE|RSA|DSA|EC).*KEY-----" "$SQUAD_DIR" 2>/dev/null || true)
  if [[ -n "$priv_key" ]]; then
    log_fail "SEC-005: Private key content found"
    sec_fail=$((sec_fail + 1))
  else
    log_pass "SEC-005: No private key content"
  fi

  local key_files=$(find "$SQUAD_DIR" -name "*.pem" -o -name "*.key" -o -name "id_rsa*" 2>/dev/null || true)
  if [[ -n "$key_files" ]]; then
    log_fail "SEC-006: Private key files found"
    sec_fail=$((sec_fail + 1))
  else
    log_pass "SEC-006: No private key files"
  fi

  log_subsection "2.4 Database & Sensitive Files"

  # Exclude: placeholders, examples, documentation, localhost, generic passwords
  local db_urls=$(grep -rE "${security_excludes[@]}" "(postgres|mysql|mongodb|redis)://[^:]+:[^@]+@" "$SQUAD_DIR" 2>/dev/null | grep -vE "(\{\{|\[PASSWORD\]|[Ee]xample|localhost|user:pass|:password@|:secret@|grep|pattern)" || true)
  if [[ -n "$db_urls" ]]; then
    log_fail "SEC-007: Database URL with password found"
    sec_fail=$((sec_fail + 1))
  else
    log_pass "SEC-007: No database URLs with passwords"
  fi

  local env_files=$(find "$SQUAD_DIR" -name ".env*" -o -name "*.env" 2>/dev/null || true)
  if [[ -n "$env_files" ]]; then
    log_fail "SEC-008: .env files found"
    sec_fail=$((sec_fail + 1))
  else
    log_pass "SEC-008: No .env files"
  fi

  SEC_FAIL=$sec_fail
  M_SECURITY_ISSUES=$sec_fail

  if [[ $sec_fail -gt 0 ]]; then
    echo -e "\n${RED}⚠️  SECURITY: $sec_fail HIGH severity issues${NC}"
  else
    echo -e "\n${GREEN}✓ Security scan passed${NC}"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 3: CROSS-REFERENCE (Deterministic - Bash)
# ═══════════════════════════════════════════════════════════════════════════════

check_cross_references() {
  log_section "PHASE 3: Cross-Reference Validation (Bash)"
  local xref_fail=0

  log_subsection "3.1 Handoff Targets"

  if [[ -d "$SQUAD_DIR/agents" ]]; then
    for agent_file in "$SQUAD_DIR/agents"/*.md; do
      [[ -f "$agent_file" ]] || continue
      local handoffs=$(grep -oE "handoff_to:[[:space:]]*@?[a-z0-9_-]+" "$agent_file" 2>/dev/null | sed 's/handoff_to:[[:space:]]*@*//' || true)
      for handoff in $handoffs; do
        if [[ ! -f "$SQUAD_DIR/agents/${handoff}.md" ]]; then
          log_fail "XREF-001: Handoff target not found: $handoff (in $(basename "$agent_file"))"
          xref_fail=$((xref_fail + 1))
        else
          log_pass "XREF-001: Handoff valid: $handoff"
        fi
      done
    done
  fi

  log_subsection "3.2 Task References"
  # Check if tasks referenced in agents exist
  if [[ -d "$SQUAD_DIR/agents" ]]; then
    for agent_file in "$SQUAD_DIR/agents"/*.md; do
      [[ -f "$agent_file" ]] || continue
      local task_refs=$(grep -oE "\*[a-z0-9_-]+" "$agent_file" 2>/dev/null | sed 's/\*//' || true)
      for task_ref in $task_refs; do
        if [[ -f "$SQUAD_DIR/tasks/${task_ref}.md" ]]; then
          log_pass "XREF-002: Task exists: $task_ref"
        fi
      done
    done
  fi

  XREF_FAIL=$xref_fail
  M_XREF_ISSUES=$xref_fail

  if [[ $xref_fail -gt 0 ]]; then
    echo -e "\n${RED}⚠️  CROSS-REF: $xref_fail broken references${NC}"
  else
    echo -e "\n${GREEN}✓ Cross-references valid${NC}"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 3.5: WORKFLOW CONTRACTS (Deterministic - CI parity)
# ═══════════════════════════════════════════════════════════════════════════════

check_workflow_contracts() {
  log_section "PHASE 3.5: Workflow Contract Validation (CI parity)"
  local workflow_fail=0

  if [[ ! -d "$SQUAD_DIR/workflows" ]]; then
    log_info "No workflows/ directory, skipping workflow contract validation"
    WF_CONTRACT_FAIL=0
    M_WORKFLOW_CONTRACT_FILES=0
    M_WORKFLOW_CONTRACT_ERRORS=0
    M_WORKFLOW_CONTRACT_WARNINGS=0
    return 0
  fi

  local workflow_files=0
  workflow_files=$(find "$SQUAD_DIR/workflows" -maxdepth 1 -type f \( -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$workflow_files" -eq 0 ]]; then
    log_info "No workflow files found in workflows/, skipping workflow contract validation"
    WF_CONTRACT_FAIL=0
    M_WORKFLOW_CONTRACT_FILES=0
    M_WORKFLOW_CONTRACT_ERRORS=0
    M_WORKFLOW_CONTRACT_WARNINGS=0
    return 0
  fi

  local contract_output=""
  if contract_output=$(npm run -s validate:workflow-contracts:strict -- --squads "$SQUAD_NAME" --json 2>&1); then
    :
  else
    workflow_fail=1
  fi

  local files_checked=0
  local errors_count=0
  local warnings_count=0
  local invalid_files_count=0
  while IFS=$'\t' read -r key value; do
    case "$key" in
      files_checked) files_checked="$value" ;;
      errors) errors_count="$value" ;;
      warnings) warnings_count="$value" ;;
      invalid_files) invalid_files_count="$value" ;;
    esac
  done < <(printf "%s" "$contract_output" | parse_workflow_contract_totals)

  M_WORKFLOW_CONTRACT_FILES="$files_checked"
  M_WORKFLOW_CONTRACT_ERRORS="$errors_count"
  M_WORKFLOW_CONTRACT_WARNINGS="$warnings_count"

  if [[ "$workflow_fail" -eq 0 ]]; then
    log_pass "WF-001: Workflow contracts valid (files=$files_checked, errors=$errors_count, warnings=$warnings_count)"
  else
    log_fail "WF-001: Workflow contract validation failed (files=$files_checked, errors=$errors_count, warnings=$warnings_count, invalid=$invalid_files_count)"
    if [[ "$VERBOSE" == "true" ]]; then
      echo "$contract_output"
    fi
  fi

  WF_CONTRACT_FAIL="$workflow_fail"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 4: SQUAD TYPE DETECTION (Deterministic - Bash)
# ═══════════════════════════════════════════════════════════════════════════════

detect_squad_type() {
  log_section "PHASE 4: Squad Type Detection (Bash)"

  local type="general"
  local confidence=5

  # Check for Expert indicators
  local has_voice_dna=$(find "$SQUAD_DIR" -name "*voice*" -o -name "*dna*" 2>/dev/null | wc -l | tr -d ' ')
  local has_clone=$(grep -ril "clone\|emulat\|mind\|persona" "$SQUAD_DIR/agents" 2>/dev/null | wc -l | tr -d ' ')

  # Check for Pipeline indicators
  local has_workflow=$(find "$SQUAD_DIR" -path "*/workflows/*.yaml" 2>/dev/null | wc -l | tr -d ' ')
  local has_phases=$(grep -ril "phase\|stage\|step" "$SQUAD_DIR/tasks" 2>/dev/null | wc -l | tr -d ' ')

  # Calculate task ratio
  local agent_count=${M_AGENT_COUNT:-1}
  [[ $agent_count -eq 0 ]] && agent_count=1
  local task_ratio=$((M_TASK_COUNT / agent_count))

  # Check for Hybrid indicators
  local has_human_exec=$(grep -ril "human\|manual\|executor" "$SQUAD_DIR" 2>/dev/null | wc -l | tr -d ' ')

  # Scoring
  local expert_score=0
  local pipeline_score=0
  local hybrid_score=0

  [[ $has_voice_dna -gt 0 ]] && expert_score=$((expert_score + 3))
  [[ $has_clone -gt 2 ]] && expert_score=$((expert_score + 2))

  [[ $has_workflow -gt 0 ]] && pipeline_score=$((pipeline_score + 3))
  [[ $has_phases -gt 3 ]] && pipeline_score=$((pipeline_score + 2))
  [[ $task_ratio -gt 3 ]] && pipeline_score=$((pipeline_score + 2))

  [[ $has_human_exec -gt 2 ]] && hybrid_score=$((hybrid_score + 3))

  # Determine type
  if [[ $expert_score -ge 4 ]]; then
    type="expert"
    confidence=$expert_score
  elif [[ $pipeline_score -ge 4 ]]; then
    type="pipeline"
    confidence=$pipeline_score
  elif [[ $hybrid_score -ge 3 ]]; then
    type="hybrid"
    confidence=$hybrid_score
  fi

  M_SQUAD_TYPE="$type"
  M_TYPE_CONFIDENCE="$confidence"

  log_info "Detected type: $type (confidence: $confidence)"
  log_info "Expert signals: voice_dna=$has_voice_dna, clone_refs=$has_clone"
  log_info "Pipeline signals: workflows=$has_workflow, phases=$has_phases, task_ratio=$task_ratio"
  log_info "Hybrid signals: human_exec=$has_human_exec"

  echo -e "\n${CYAN}Squad Type: ${BOLD}$type${NC} (confidence: $confidence/7)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 5: PRODUCTION VALIDATION (Deterministic - Bash)
# ═══════════════════════════════════════════════════════════════════════════════

check_production() {
  log_section "PHASE 5: Production Validation (Bash)"
  local prod_score=0

  log_subsection "5.1 Outputs Directory"
  # Canonical runtime evidence must live in .aiox/squad-runtime
  local has_outputs=false
  local runtime_root="${AIOX_RUNTIME_ROOT:-./.aiox/squad-runtime}"
  if [ -d "$runtime_root" ]; then
    local squad_runtime_dir
    squad_runtime_dir=$(find "$runtime_root" -maxdepth 3 -type d -name "$SQUAD_NAME" 2>/dev/null | head -1)
    if [ -n "$squad_runtime_dir" ] && [ -d "$squad_runtime_dir" ]; then
      local output_count
      output_count=$(find "$squad_runtime_dir" -type f 2>/dev/null | wc -l | tr -d ' ')
      if [ "$output_count" -gt 0 ]; then
        log_pass "Found runtime evidence in .aiox/squad-runtime ($output_count files)"
        has_outputs=true
        prod_score=$((prod_score + 2))
      else
        log_warn "Runtime directory exists but has no files: $squad_runtime_dir"
      fi
    fi
  fi

  if [ "$has_outputs" = false ]; then
    log_warn "No runtime evidence found in .aiox/squad-runtime for squad '$SQUAD_NAME'"
  fi

  log_subsection "5.2 Tested Flag"
  # Check for tested: true in config.yaml
  if grep -qE "^tested:[[:space:]]*(true|yes)" "$SQUAD_DIR/config.yaml" 2>/dev/null; then
    log_pass "config.yaml has tested: true"
    prod_score=$((prod_score + 1))
  else
    log_warn "config.yaml missing 'tested: true' flag"
  fi

  log_subsection "5.3 Usage Evidence"
  # YOLO evidence is only required when config declares settings.activation.yolo_required=true.
  local yolo_required=false
  if grep -qE '^[[:space:]]*yolo_required:[[:space:]]*(true|yes|1)[[:space:]]*$' "$SQUAD_DIR/config.yaml" 2>/dev/null; then
    yolo_required=true
  fi

  if [ "$yolo_required" = true ]; then
    local state_files
    state_files=$(find "$SQUAD_DIR" -name "*-state.json" -o -name "progress.txt" -o -name "handoff.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$state_files" -gt 0 ]; then
      # Verify it's real usage, not just template files
      local real_state
      real_state=$(find "$SQUAD_DIR" -name "*-state.json" -exec grep -l '"status"' {} \; 2>/dev/null | wc -l | tr -d ' ')
      if [ "$real_state" -gt 0 ]; then
        log_pass "Found $real_state state files with execution history (YOLO mode required)"
        prod_score=$((prod_score + 1))
      else
        log_warn "YOLO required but state files found appear to be templates"
      fi
    else
      log_warn "YOLO required but no state files found (add *-state.json/progress evidence)"
    fi
  else
    log_info "YOLO mode evidence not required (settings.activation.yolo_required=false)"
  fi

  # Check for user feedback or validation reports
  local feedback_files=$(find "$SQUAD_DIR" -name "*feedback*" -o -name "*validation-report*" -o -name "*qa-report*" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$feedback_files" -gt 0 ]; then
    log_pass "Found $feedback_files feedback/validation files"
    prod_score=$((prod_score + 1))
  fi

  log_subsection "5.4 Sample Outputs"
  # Check for example outputs in docs or templates
  local has_examples=false
  if [ -d "$SQUAD_DIR/examples" ] || [ -d "$SQUAD_DIR/samples" ]; then
    log_pass "examples/ or samples/ directory exists"
    has_examples=true
    prod_score=$((prod_score + 1))
  fi

  # Check for output_examples in agents
  local output_examples=$(grep -rl "output_examples\|example_output\|sample_output" "$SQUAD_DIR/agents" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$output_examples" -gt 0 ]; then
    log_pass "Found output examples in $output_examples agent files"
    if [ "$has_examples" = false ]; then
      prod_score=$((prod_score + 1))
    fi
  fi

  if [ "$has_examples" = false ] && [ "$output_examples" -eq 0 ]; then
    log_warn "No sample outputs or examples found"
  fi

  # Cap at max
  if [ $prod_score -gt $PROD_MAX ]; then
    prod_score=$PROD_MAX
  fi

  PROD_SCORE=$prod_score
  M_PROD_SCORE=$prod_score

  echo ""
  if [ $prod_score -eq 0 ]; then
    echo -e "${RED}⚠️  PRODUCTION: 0/$PROD_MAX - No evidence of real usage${NC}"
    echo -e "${YELLOW}   Max possible score without production evidence: 5/10${NC}"
  elif [ $prod_score -lt 3 ]; then
    echo -e "${YELLOW}⚠️  PRODUCTION: $prod_score/$PROD_MAX - Limited production evidence${NC}"
  else
    echo -e "${GREEN}✓ Production validation: $prod_score/$PROD_MAX${NC}"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 6: QUALITY ANALYSIS (Claude CLI)
# ═══════════════════════════════════════════════════════════════════════════════

analyze_with_claude() {
  log_section "PHASE 6: Quality Analysis (Claude CLI)"

  if [[ "$QUICK_MODE" == "true" ]]; then
    echo -e "${YELLOW}Skipping Claude analysis (--quick mode)${NC}"
    M_QUALITY_SCORE="N/A"
    return 0
  fi

  echo -e "${MAGENTA}Running Claude analysis with $MODEL_QUALITY...${NC}"

  # Collect sample files for analysis
  local sample_agent=$(find "$SQUAD_DIR/agents" -name "*.md" 2>/dev/null | head -1)
  local sample_task=$(find "$SQUAD_DIR/tasks" -name "*.md" 2>/dev/null | head -1)
  local sample_checklist=$(find "$SQUAD_DIR/checklists" -name "*.md" 2>/dev/null | head -1)

  local agent_content=""
  local task_content=""
  local checklist_content=""

  [[ -f "$sample_agent" ]] && agent_content=$(head -100 "$sample_agent" 2>/dev/null || true)
  [[ -f "$sample_task" ]] && task_content=$(head -100 "$sample_task" 2>/dev/null || true)
  [[ -f "$sample_checklist" ]] && checklist_content=$(head -100 "$sample_checklist" 2>/dev/null || true)

  # Build analysis prompt
  local ANALYSIS_PROMPT="You are evaluating the quality of an AIOX squad. Analyze and provide a JSON response.

## Squad: $SQUAD_NAME
Type: $M_SQUAD_TYPE

## Metrics
- Agents: $M_AGENT_COUNT
- Tasks: $M_TASK_COUNT
- Checklists: $M_CHECKLIST_COUNT
- Total lines: $M_TOTAL_LINES

## Sample Agent (first 100 lines):
\`\`\`
$agent_content
\`\`\`

## Sample Task (first 100 lines):
\`\`\`
$task_content
\`\`\`

## Sample Checklist (first 100 lines):
\`\`\`
$checklist_content
\`\`\`

## Evaluation Criteria
1. **Prompt Quality (0-10)**: Are prompts specific, actionable, with examples?
2. **Structure Coherence (0-10)**: Do agents/tasks/checklists follow consistent patterns?
3. **Coverage (0-10)**: Does the squad have appropriate agent:task ratios for its type?
4. **Documentation (0-10)**: Are purposes, inputs, outputs clearly defined?

## Required Response Format (JSON only):
{
  \"prompt_quality\": 8,
  \"structure_coherence\": 7,
  \"coverage\": 9,
  \"documentation\": 6,
  \"overall_score\": 7.5,
  \"strengths\": [\"clear prompts\", \"good task coverage\"],
  \"improvements\": [\"add more examples\", \"document edge cases\"],
  \"recommendation\": \"PASS\"
}

Respond with ONLY the JSON, no other text."

  # Run Claude
  local claude_output
  if claude_output=$(claude -p --model "$MODEL_QUALITY" --dangerously-skip-permissions "$ANALYSIS_PROMPT" 2>&1); then
    # Extract first valid JSON object from multiline/ANSI output.
    local json_result
    json_result=$(printf "%s" "$claude_output" | extract_first_json_object)

    if [[ "$VERBOSE" == "true" ]]; then
      echo -e "\n${CYAN}Claude Analysis Result:${NC}"
      echo "$json_result" | jq '.' 2>/dev/null || echo "$json_result"
    fi

    # Parse metrics deterministically (no regex scraping on raw Claude output).
    while IFS=$'\t' read -r key value; do
      case "$key" in
        prompt_quality) M_PROMPT_QUALITY="$value" ;;
        structure_coherence) M_STRUCTURE_COHERENCE="$value" ;;
        coverage) M_COVERAGE_SCORE="$value" ;;
        documentation) M_DOCUMENTATION="$value" ;;
        quality_score) M_QUALITY_SCORE="$value" ;;
        improvements) M_IMPROVEMENTS="$value" ;;
      esac
    done < <(printf "%s" "$json_result" | parse_claude_metrics)

    if ! is_numeric_score "${M_QUALITY_SCORE:-}"; then
      M_QUALITY_SCORE="N/A"
      echo -e "${YELLOW}⚠️  Claude output sem overall_score parseável; usando fallback determinístico${NC}"
    else
      M_QUALITY_SCORE=$(clamp_score_0_10 "$M_QUALITY_SCORE")
    fi

    echo -e "\n${GREEN}✓ Claude analysis complete${NC}"
    if [[ "$M_QUALITY_SCORE" == "N/A" ]]; then
      echo -e "  Quality Score: ${BOLD}N/A${NC}"
    else
      echo -e "  Quality Score: ${BOLD}${M_QUALITY_SCORE}/10${NC}"
    fi

  else
    echo -e "${YELLOW}⚠️  Claude analysis failed, using deterministic score only${NC}"
    M_QUALITY_SCORE="N/A"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 6: FINAL SCORING & REPORT
# ═══════════════════════════════════════════════════════════════════════════════

calculate_final_score() {
  log_section "PHASE 7: Final Scoring"

  local total_fails=$((TIER1_FAIL + SEC_FAIL + XREF_FAIL + WF_CONTRACT_FAIL))
  local prod_normalized=$((PROD_SCORE * 2))

  # Structure score uses decimal penalties with explicit rounding:
  #   struct = 10 - (fails*1.5) - (warnings*0.3)
  local struct_score
  struct_score=$(awk -v fails="$total_fails" -v warns="$WARN_COUNT" '
    BEGIN {
      score = 10 - (fails * 1.5) - (warns * 0.3);
      if (score < 0) score = 0;
      if (score > 10) score = 10;
      printf "%.4f", score;
    }
  ')

  # SCORING FORMULA (explicit and auditable):
  # - With Claude score: final = 20% structure + 30% quality + 50% production
  # - Without Claude score (quick mode or parse failure): deterministic fallback
  #   final = 40% structure + 60% production (quality weight redistributed)
  local weighted_score
  if is_numeric_score "${M_QUALITY_SCORE:-}"; then
    local quality_score
    quality_score=$(clamp_score_0_10 "$M_QUALITY_SCORE")
    weighted_score=$(awk -v s="$struct_score" -v q="$quality_score" -v p="$prod_normalized" '
      BEGIN { printf "%.4f", (s * 0.20) + (q * 0.30) + (p * 0.50) }
    ')
  else
    weighted_score=$(awk -v s="$struct_score" -v p="$prod_normalized" '
      BEGIN { printf "%.4f", (s * 0.40) + (p * 0.60) }
    ')
  fi

  local capped_score="$weighted_score"

  # CAPS based on production evidence:
  # - No production (0/5): MAX 5/10
  # - Minimal (1-2/5): MAX 7/10
  # - Good (3-4/5): MAX 9/10
  # - Full (5/5): MAX 10/10
  if [ "$PROD_SCORE" -eq 0 ]; then
    if awk -v score="$capped_score" 'BEGIN { exit !(score > 5) }'; then
      capped_score="5"
    fi
  elif [ "$PROD_SCORE" -lt 3 ]; then
    if awk -v score="$capped_score" 'BEGIN { exit !(score > 7) }'; then
      capped_score="7"
    fi
  elif [ "$PROD_SCORE" -lt 5 ]; then
    if awk -v score="$capped_score" 'BEGIN { exit !(score > 9) }'; then
      capped_score="9"
    fi
  fi

  FINAL_SCORE=$(round_score_0_10_int "$capped_score")
}

generate_report() {
  local result="FAIL"
  local result_color=$RED

  if [[ $FINAL_SCORE -ge 7 ]] && [[ -z "$BLOCKING_ISSUES" ]]; then
    result="PASS"
    result_color=$GREEN
  elif [[ $FINAL_SCORE -ge 5 ]]; then
    result="CONDITIONAL"
    result_color=$YELLOW
  fi

  if [[ "$JSON_OUTPUT" == "true" ]]; then
    cat << EOF
{
  "squad": "$SQUAD_NAME",
  "result": "$result",
  "final_score": $FINAL_SCORE,
  "type": "$M_SQUAD_TYPE",
  "metrics": {
    "agents": $M_AGENT_COUNT,
    "tasks": $M_TASK_COUNT,
    "checklists": $M_CHECKLIST_COUNT,
    "total_lines": $M_TOTAL_LINES
  },
  "deterministic": {
    "tier1_fail": $TIER1_FAIL,
    "security_fail": $SEC_FAIL,
    "xref_fail": $XREF_FAIL,
    "workflow_contract_fail": $WF_CONTRACT_FAIL,
    "warnings": $WARN_COUNT
  },
  "workflow_contracts": {
    "files_checked": $M_WORKFLOW_CONTRACT_FILES,
    "errors": $M_WORKFLOW_CONTRACT_ERRORS,
    "warnings": $M_WORKFLOW_CONTRACT_WARNINGS
  },
  "production": {
    "score": $PROD_SCORE,
    "max": $PROD_MAX
  },
  "claude_analysis": {
    "prompt_quality": $M_PROMPT_QUALITY,
    "structure_coherence": $M_STRUCTURE_COHERENCE,
    "coverage": $M_COVERAGE_SCORE,
    "documentation": $M_DOCUMENTATION,
    "quality_score": "$M_QUALITY_SCORE"
  },
  "improvements": "$M_IMPROVEMENTS"
}
EOF
  else
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    if [[ "$result" == "PASS" ]]; then
      echo -e "${BOLD}║${result_color}                    ✅ VALIDATION PASSED                      ${NC}${BOLD}║${NC}"
    elif [[ "$result" == "CONDITIONAL" ]]; then
      echo -e "${BOLD}║${result_color}                   ⚠️  CONDITIONAL PASS                       ${NC}${BOLD}║${NC}"
    else
      echo -e "${BOLD}║${result_color}                    ❌ VALIDATION FAILED                      ${NC}${BOLD}║${NC}"
    fi
    echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Squad: ${BOLD}$SQUAD_NAME${NC}"
    echo -e "  Type: ${CYAN}$M_SQUAD_TYPE${NC}"
    echo -e "  Final Score: ${BOLD}${result_color}$FINAL_SCORE/10${NC}"
    echo ""
    echo "  ┌─────────────────────────────────────────┐"
    echo "  │ Structure & Security (20%)              │"
    printf "  │   Structure failures: %-17s│\n" "$TIER1_FAIL"
    printf "  │   Security issues: %-19s│\n" "$SEC_FAIL"
    printf "  │   Cross-ref broken: %-18s│\n" "$XREF_FAIL"
    printf "  │   Workflow contract: %-14s│\n" "$WF_CONTRACT_FAIL"
    printf "  │   Warnings: %-26s│\n" "$WARN_COUNT"
    echo "  └─────────────────────────────────────────┘"

    echo "  ┌─────────────────────────────────────────┐"
    echo "  │ Production Evidence (50%)               │"
    if [ "$PROD_SCORE" -eq 0 ]; then
      printf "  │   ${RED}Score: %-32s${NC}│\n" "$PROD_SCORE/$PROD_MAX ⚠️  NOT TESTED"
    elif [ "$PROD_SCORE" -lt 3 ]; then
      printf "  │   ${YELLOW}Score: %-32s${NC}│\n" "$PROD_SCORE/$PROD_MAX (limited)"
    else
      printf "  │   ${GREEN}Score: %-32s${NC}│\n" "$PROD_SCORE/$PROD_MAX ✓"
    fi
    echo "  └─────────────────────────────────────────┘"

    if [[ "$M_QUALITY_SCORE" != "N/A" ]]; then
      echo "  ┌─────────────────────────────────────────┐"
      echo "  │ Claude Quality Analysis (30%)          │"
      printf "  │   Prompt Quality: %-20s│\n" "$M_PROMPT_QUALITY/10"
      printf "  │   Structure: %-25s│\n" "$M_STRUCTURE_COHERENCE/10"
      printf "  │   Coverage: %-26s│\n" "$M_COVERAGE_SCORE/10"
      printf "  │   Documentation: %-21s│\n" "$M_DOCUMENTATION/10"
      echo "  └─────────────────────────────────────────┘"
    fi

    if [[ -n "$BLOCKING_ISSUES" ]]; then
      echo ""
      echo -e "  ${RED}Blocking Issues:${NC}"
      echo -e "$BLOCKING_ISSUES" | while read -r issue; do
        [[ -n "$issue" ]] && echo -e "    ${RED}•${NC} $issue"
      done
    fi

    if [[ -n "$M_IMPROVEMENTS" ]]; then
      echo ""
      echo -e "  ${YELLOW}Improvements:${NC}"
      echo "    $M_IMPROVEMENTS"
    fi
    echo ""
  fi

  VALIDATION_RESULT="$result"
  if [[ "$result" == "PASS" ]]; then
    EXIT_CODE=0
  else
    EXIT_CODE=1
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

main() {
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║         🔍 VALIDATE-SQUAD v2.0 - Hybrid Validation           ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  Squad: ${CYAN}$SQUAD_NAME${NC}"
  echo -e "  Path: $SQUAD_DIR"
  if [[ "$QUICK_MODE" == "true" ]]; then
    echo -e "  Mode: quick (no Claude)"
  else
    echo -e "  Mode: hybrid"
  fi
  echo -e "  Model: $MODEL_QUALITY"

  runtime_state_start

  # Phase 1: Structure (Bash)
  runtime_state_phase_start "phase_1_structure"
  check_structure
  runtime_state_phase_complete "phase_1_structure"

  # Phase 2: Security (Bash)
  runtime_state_phase_start "phase_2_security_scan"
  check_security
  runtime_state_phase_complete "phase_2_security_scan"

  # Phase 3: Cross-references (Bash)
  runtime_state_phase_start "phase_3_cross_reference"
  check_cross_references
  runtime_state_phase_complete "phase_3_cross_reference"

  # Phase 3.5: Workflow contracts (same validator as CI)
  runtime_state_phase_start "phase_3_5_workflow_contracts"
  check_workflow_contracts
  runtime_state_phase_complete "phase_3_5_workflow_contracts"

  # Phase 4: Type detection (Bash)
  runtime_state_phase_start "phase_4_type_detection"
  detect_squad_type
  runtime_state_phase_complete "phase_4_type_detection"

  # Phase 5: Production validation (Bash) - NEW
  runtime_state_phase_start "phase_5_production_validation"
  check_production
  runtime_state_phase_complete "phase_5_production_validation"

  # Phase 6: Quality analysis (Claude CLI)
  runtime_state_phase_start "phase_6_quality_analysis"
  analyze_with_claude
  runtime_state_phase_complete "phase_6_quality_analysis"

  # Phase 7: Final scoring
  runtime_state_phase_start "phase_7_final_scoring"
  calculate_final_score

  # Generate report
  generate_report
  runtime_state_phase_complete "phase_7_final_scoring"

  if [[ "$EXIT_CODE" -eq 0 ]]; then
    runtime_state_complete "completed"
  else
    runtime_state_complete "failed"
  fi

  exit "$EXIT_CODE"
}

# Run
main
