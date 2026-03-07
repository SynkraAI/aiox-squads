# Squad Overview Quality Checklist

**Checklist ID:** squad-overview-checklist
**Purpose:** Validate SQUAD-OVERVIEW.md completeness and quality
**Used By:** `*squad-overview` task, manual review
**Scoring:** 100 points total, minimum 80 to pass

---

## Scoring Summary

| Category | Points | Weight |
|----------|--------|--------|
| Structure Completeness | 30 | 30% |
| Content Quality | 35 | 35% |
| Technical Accuracy | 20 | 20% |
| Visual & Formatting | 15 | 15% |
| **Total** | **100** | **100%** |

---

## Category 1: Structure Completeness (30 points)

### 1.1 Required Sections (20 points)

- [ ] **VISAO GERAL present** (2 pts)
  - Has squad name box/banner
  - Has attributes table

- [ ] **TIME DE ESPECIALISTAS present** (3 pts)
  - Has tier architecture diagram OR agent list
  - Has agent details table

- [ ] **ESTRUTURA DO SQUAD present** (3 pts)
  - Has directory tree
  - Shows all component folders

- [ ] **FRAMEWORKS INTEGRADOS present** (2 pts)
  - Lists frameworks by expert/source
  - Shows application context

- [ ] **COMANDOS DISPONIVEIS present** (3 pts)
  - Has leader commands table
  - Has specialist commands (if applicable)

- [ ] **FLUXO DE TRABALHO present** (3 pts)
  - Has workflow diagram (ASCII or description)
  - Shows phase sequence

- [ ] **COMO USAR present** (2 pts)
  - Has activation command
  - Has usage examples

- [ ] **METRICAS present** (2 pts)
  - Shows component counts
  - Shows creation statistics

### 1.2 Conditional Sections (10 points)

*Score only applicable sections*

- [ ] **SOBRE OS ESPECIALISTAS** (3 pts) — *If expert-based squad*
  - Each expert has biography
  - Credentials listed
  - Focus area defined

- [ ] **DNA EXTRAIDO** (3 pts) — *If mind cloning was used*
  - Directory structure shown
  - Files listed per expert
  - Fidelity scores included

- [ ] **COMPLIANCE** (2 pts) — *If legal/regulatory requirements*
  - Requirements listed
  - Standards referenced

- [ ] **INTEGRACOES** (2 pts) — *If squad integrates with others*
  - Input sources listed
  - Output destinations listed

---

## Category 2: Content Quality (35 points)

### 2.1 Vision & Context (10 points)

- [ ] **Clear purpose statement** (3 pts)
  - Tagline is memorable and specific
  - Not generic ("helps with X")

- [ ] **Domain coverage explicit** (2 pts)
  - What the squad does is clear
  - What it doesn't do is implied or stated

- [ ] **Value proposition clear** (3 pts)
  - Why use this squad vs. alternatives?
  - Unique capabilities highlighted

- [ ] **Target user identified** (2 pts)
  - Who should use this squad?
  - Use cases mentioned

### 2.2 Team Documentation (15 points)

- [ ] **All agents listed** (3 pts)
  - Every agent in agents/ folder is documented
  - No missing agents

- [ ] **Tier organization explained** (3 pts)
  - Tier 0/1/2/3 structure clear (if applicable)
  - Role of each tier explained

- [ ] **Handoff flow documented** (3 pts)
  - Who passes to whom
  - When handoffs occur

- [ ] **Commands are actionable** (3 pts)
  - Each command has clear description
  - Delegation targets specified

- [ ] **Line counts accurate** (3 pts)
  - Agent sizes reflect actual files
  - Totals are correct

### 2.3 Framework Documentation (10 points)

- [ ] **Frameworks traceable to source** (4 pts)
  - Framework name matches expert/methodology
  - Not invented or generic

- [ ] **Application context provided** (3 pts)
  - Each framework shows when/how to use
  - Not just a name list

- [ ] **Heuristics documented** (3 pts) — *If squad has decision rules*
  - Key heuristics listed
  - IF/THEN format used

---

## Category 3: Technical Accuracy (20 points)

### 3.1 Structure Accuracy (10 points)

- [ ] **Directory tree matches reality** (4 pts)
  - All folders shown exist
  - No phantom folders listed

- [ ] **Component counts correct** (3 pts)
  - Agent count matches agents/ folder
  - Task count matches tasks/ folder
  - Workflow count matches workflows/ folder

- [ ] **File sizes accurate** (3 pts)
  - KB/MB measurements are real
  - Line counts are actual

### 3.2 Command Accuracy (5 points)

- [ ] **Commands exist in agents** (3 pts)
  - Every command listed actually exists
  - No invented commands

- [ ] **Command descriptions match** (2 pts)
  - Descriptions align with actual behavior
  - Delegation targets are correct

### 3.3 Cross-Reference Accuracy (5 points)

- [ ] **Handoff targets exist** (2 pts)
  - All @mentions are real agents
  - No broken references

- [ ] **Framework names match** (2 pts)
  - Framework names in table match agent files
  - Spellings consistent

- [ ] **Paths are correct** (1 pt)
  - squads/{name}/ path is accurate
  - .aiox/squad-runtime/minds/ paths exist (if mentioned)

---

## Category 4: Visual & Formatting (15 points)

### 4.1 Tables (5 points)

- [ ] **Tables are well-formed** (2 pts)
  - Consistent column widths
  - Headers present

- [ ] **Tables have useful content** (2 pts)
  - No empty cells (or N/A where appropriate)
  - Data is meaningful

- [ ] **Tables are readable** (1 pt)
  - Not too wide for terminal
  - Logical column order

### 4.2 Diagrams (5 points)

- [ ] **Tier diagram present** (2 pts)
  - Shows hierarchy visually
  - ASCII or box format

- [ ] **Workflow diagram present** (2 pts)
  - Shows flow direction
  - Phases are labeled

- [ ] **Diagrams are readable** (1 pt)
  - Not broken by line wrapping
  - Symbols consistent

### 4.3 Formatting Consistency (5 points)

- [ ] **Section headers consistent** (2 pts)
  - Same style throughout (##, ---, etc.)
  - Hierarchy clear

- [ ] **Code blocks used appropriately** (2 pts)
  - Commands in code blocks
  - Paths in backticks

- [ ] **No rendering issues** (1 pt)
  - No broken markdown
  - Tables render correctly

---

## Automatic Fails (Veto Conditions)

These issues cause automatic failure regardless of score:

| ID | Condition | Reason |
|----|-----------|--------|
| VF-1 | File doesn't exist | Task didn't complete |
| VF-2 | < 100 lines | Insufficient content |
| VF-3 | No VISAO GERAL section | Missing core section |
| VF-4 | No commands section | Squad is unusable |
| VF-5 | Agent count = 0 | Empty squad |
| VF-6 | Contains {PLACEHOLDER} text | Unfinished generation |
| VF-7 | Wrong squad name in content | Wrong target |

---

## Scoring Guide

| Score Range | Result | Action |
|-------------|--------|--------|
| 90-100 | **EXCELLENT** | Ready for production |
| 80-89 | **PASS** | Acceptable, minor improvements optional |
| 70-79 | **CONDITIONAL** | Needs specific fixes before use |
| 60-69 | **NEEDS WORK** | Significant gaps, regenerate |
| < 60 | **FAIL** | Major issues, start over |

---

## Quick Validation Script

```bash
# Run these checks before scoring manually

SQUAD_NAME="franchise"
OVERVIEW_FILE="squads/${SQUAD_NAME}/SQUAD-OVERVIEW.md"

# Check 1: File exists
if [ ! -f "$OVERVIEW_FILE" ]; then
  echo "FAIL: File does not exist"
  exit 1
fi

# Check 2: Minimum lines
LINE_COUNT=$(wc -l < "$OVERVIEW_FILE")
if [ "$LINE_COUNT" -lt 100 ]; then
  echo "FAIL: Only $LINE_COUNT lines (minimum 100)"
  exit 1
fi

# Check 3: Required sections
for SECTION in "VISAO GERAL" "TIME DE ESPECIALISTAS" "ESTRUTURA" "COMANDOS" "COMO USAR"; do
  if ! grep -q "$SECTION" "$OVERVIEW_FILE"; then
    echo "FAIL: Missing section: $SECTION"
    exit 1
  fi
done

# Check 4: No placeholders
if grep -q "{[A-Z_]*}" "$OVERVIEW_FILE"; then
  echo "FAIL: Contains unfilled placeholders"
  exit 1
fi

# Check 5: Correct squad name
if ! grep -q "$SQUAD_NAME" "$OVERVIEW_FILE"; then
  echo "FAIL: Squad name not found in document"
  exit 1
fi

echo "PASS: Basic validation passed"
echo "Lines: $LINE_COUNT"
```

---

## Review Template

```yaml
# SQUAD-OVERVIEW Quality Review

squad: "{squad_name}"
reviewer: "@squad-chief"
date: "{date}"
file: "squads/{squad_name}/SQUAD-OVERVIEW.md"

scores:
  structure_completeness: __/30
  content_quality: __/35
  technical_accuracy: __/20
  visual_formatting: __/15
  total: __/100

veto_triggered: false  # or veto ID

issues:
  critical: []
  high: []
  medium: []
  low: []

recommendations:
  - "{recommendation_1}"
  - "{recommendation_2}"

verdict: "PASS | CONDITIONAL | FAIL"

next_action: "Ready for use | Fix issues and re-run | Regenerate"
```

---

## Usage

### During *squad-overview execution

```bash
# Task automatically applies checklist
*squad-overview franchise

# Output includes quality score
# ✅ SQUAD-OVERVIEW.md created (Score: 87/100 - PASS)
```

### Manual review

```bash
# Review existing overview
@squad-chief
*validate-overview franchise

# Or use checklist manually
# Read squads/franchise/SQUAD-OVERVIEW.md
# Apply checklist items
# Calculate score
```

---

## Related

| Checklist | Purpose |
|-----------|---------|
| `squad-checklist.md` | Full squad validation |
| `agent-quality-gate.md` | Individual agent quality |
| `task-anatomy-checklist.md` | Task structure validation |

| Task | Purpose |
|------|---------|
| `squad-overview.md` | Generate the document |
| `validate-squad.md` | Validate entire squad |

---

