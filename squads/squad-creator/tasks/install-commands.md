# Task: Install Commands

**Task ID:** install-commands
**Execution Type:** `Worker` (100% deterministic file operations)
**Worker Script:** `scripts/sync-ide-command.py` (use: `python3 scripts/sync-ide-command.py squad {name}`)
**Purpose:** Convert squad agents into IDE commands and install them across all detected IDEs
**Orchestrator:** @squad-chief
**Mode:** Detect IDEs > Convert Agents > Install Per-IDE > Validate
**Model:** N/A (Worker -- no LLM needed)
**Haiku Eligible:** N/A (Worker task)

## Veto Conditions

```yaml
veto_conditions:
  - id: "VETO-INSTALL-001"
    condition: "Destination file already exists and overwrite not explicitly authorized"
    trigger: "Before writing command files in any IDE destination path"
    block_behavior: "BLOCK overwrite; require explicit confirmation or --force flag"

  - id: "VETO-INSTALL-002"
    condition: "Squad source structure validation failed"
    trigger: "Before conversion/sync phase starts"
    block_behavior: "BLOCK install; require fixing source structure and rerun"
```

When this command is used, execute the following task:

---

## PRO DETECTION

> This command has no dedicated pro override file.
> If pro mode is active -- run this base task and surface pro-only enhancements when relevant.
> If pro mode is not active -- continue with this base version.
>
> Pro mode check: `squads/squad-creator-pro/config.yaml` exists -- pro_mode=true

---

# Install Squad Commands (Multi-IDE)

## Purpose

Convert squad agents into IDE-specific command formats and install them across all supported IDEs,
making squad agents accessible via the `@{squad}:{agent}` syntax (or IDE-equivalent) in every
detected IDE environment.

**Supported IDEs:**

| # | IDE | Command Directory | Format |
|---|-----|-------------------|--------|
| 1 | **Claude Code** | `.claude/commands/{slashPrefix}/` | `.md` with YAML activation block |
| 2 | **Codex** | `.codex/skills/{slashPrefix}/` | `SKILL.md` format (simplified agent) |
| 3 | **Gemini** | `.gemini/commands/{slashPrefix}/` | `.md` format (similar to Claude Code) |
| 4 | **Antigravity** | `.antigravity/commands/{slashPrefix}/` | `.md` format (similar to Claude Code) |
| 5 | **Cursor** | `.cursor/commands/{slashPrefix}/` | `.md` format with `.cursorrules` reference |

> Pro mode adds sync of both base and pro assets to all IDEs.

## Inputs

- Squad name (from user or discovery)
- Squad path: `squads/{squad_name}/`
- Existing squad structure:
  - `config.yaml` -- Squad metadata
  - `agents/` -- Agent definitions (markdown)
  - `tasks/` -- Task workflows (markdown)
  - `templates/` -- Output templates

---

## PHASE 0: IDE DETECTION

**Duration:** < 10 seconds
**Mode:** Autonomous (Worker)

### Step 0.1: Detect Installed IDEs

Scan the project root and user environment for IDE configuration directories.

```yaml
ide_detection:
  checks:
    claude_code:
      detect: "Directory .claude/ exists at project root"
      config_file: ".claude/settings.json OR .claude/settings.local.json"
      command_dir: ".claude/commands/"
      status: "detected | not_found"

    codex:
      detect: "Directory .codex/ exists at project root"
      config_file: ".codex/config.yaml OR .codex/settings.json"
      command_dir: ".codex/skills/"
      status: "detected | not_found"

    gemini:
      detect: "Directory .gemini/ exists at project root"
      config_file: ".gemini/settings.json"
      command_dir: ".gemini/commands/"
      status: "detected | not_found"

    antigravity:
      detect: "Directory .antigravity/ exists at project root"
      config_file: ".antigravity/config.yaml"
      command_dir: ".antigravity/commands/"
      status: "detected | not_found"

    cursor:
      detect: "Directory .cursor/ exists at project root OR .cursorrules file exists"
      config_file: ".cursorrules"
      command_dir: ".cursor/commands/"
      status: "detected | not_found"

  output:
    detected_ides: ["claude_code", "gemini"]  # Example
    total_detected: 2
    primary_ide: "claude_code"  # First detected, used as reference
```

**Detection Output:**
```
IDE DETECTION RESULTS

  [detected] Claude Code  - .claude/commands/
  [not_found] Codex       - .codex/skills/
  [detected] Gemini       - .gemini/commands/
  [not_found] Antigravity - .antigravity/commands/
  [not_found] Cursor      - .cursor/commands/

IDEs detected: 2 of 5
Primary IDE: Claude Code
```

### Step 0.2: IDE Detection Fallback

```yaml
detection_fallback:
  if_no_ides_detected:
    action: |
      No IDE configuration directories found.
      Options:
      1. Install for Claude Code (create .claude/commands/)
      2. Install for specific IDE (specify which)
      3. Install for all IDEs (create all directories)
      4. Cancel

  if_only_one_detected:
    action: "Proceed with detected IDE only"

  always_include:
    - "claude_code"  # Always install for Claude Code as baseline
```

---

## PHASE 1: VALIDATE SQUAD

**Duration:** < 30 seconds
**Mode:** Autonomous (Worker)

### Step 1.1: Validate Squad Exists

**Ask user for squad name if not provided:**
```
Which squad would you like to install?
Available squads: [list directories in squads/]
```

**Check squad structure:**
- Verify `squads/{squad_name}/config.yaml` exists
- Verify `squads/{squad_name}/agents/` directory exists
- Load `config.yaml` to get:
  - `name` -- Squad identifier
  - `slashPrefix` -- Command prefix (e.g., "legalAssistant")
  - `version` -- Squad version

**Validation output:**
```
[pass] Found squad: {name} v{version}
   Slash prefix: @{slashPrefix}:
   Agents found: {count}
   Tasks found: {count}
```

**If validation fails:**
- Report missing components
- Ask user if they want to create the squad first using `*create-squad`
- STOP execution

---

## PHASE 2: CREATE DIRECTORY STRUCTURES

**Duration:** < 10 seconds
**Mode:** Autonomous (Worker)

### Step 2.1: Create Per-IDE Directory Structures

For each detected IDE, create the command directory structure:

```yaml
directory_creation:
  claude_code:
    directories:
      - ".claude/commands/{slashPrefix}/"
      - ".claude/commands/{slashPrefix}/agents/"
      - ".claude/commands/{slashPrefix}/tasks/"

  codex:
    directories:
      - ".codex/skills/{slashPrefix}/"
      - ".codex/skills/{slashPrefix}/agents/"
      - ".codex/skills/{slashPrefix}/tasks/"

  gemini:
    directories:
      - ".gemini/commands/{slashPrefix}/"
      - ".gemini/commands/{slashPrefix}/agents/"
      - ".gemini/commands/{slashPrefix}/tasks/"

  antigravity:
    directories:
      - ".antigravity/commands/{slashPrefix}/"
      - ".antigravity/commands/{slashPrefix}/agents/"
      - ".antigravity/commands/{slashPrefix}/tasks/"

  cursor:
    directories:
      - ".cursor/commands/{slashPrefix}/"
      - ".cursor/commands/{slashPrefix}/agents/"
      - ".cursor/commands/{slashPrefix}/tasks/"
```

**Execution:**
- For each detected IDE: create directories using `mkdir -p`
- Skip IDEs that were not detected (unless user chose "install for all")

**Confirmation:**
```
[pass] Created directory structures for {N} IDEs:
  - Claude Code: .claude/commands/{slashPrefix}/
  - Gemini: .gemini/commands/{slashPrefix}/
```

---

## PHASE 3: CONVERT AGENTS TO IDE FORMAT

**Duration:** 1-3 minutes (depends on agent count)
**Mode:** Autonomous (Worker)

### Step 3.1: Read Source Agent Files

For each file in `squads/{squad_name}/agents/*.md`:

- Parse agent metadata (lines 1-6):
  - Extract: name (# header)
  - Extract: role (from **Role**:)
  - Extract: squad reference
- Parse sections:
  - ## Persona (extract all subsections)
  - ## Commands (extract command list)
  - ## Tasks (extract task references)
  - ## Templates (extract template references)
  - ## Activation (extract activation command)

### Step 3.2: Format Conversion Per IDE

Each IDE has a specific output format. The source agent is converted differently for each IDE.

```yaml
format_conversion:
  # FORMAT 1: Claude Code (.md with YAML activation block)
  claude_code:
    file_extension: ".md"
    output_dir: ".claude/commands/{slashPrefix}/agents/"
    template: |
      # /{slashPrefix}:{agent-id} Command

      When this command is used, adopt the following agent persona:

      # {agent-id}

      ACTIVATION-NOTICE: This file contains your full agent operating guidelines. DO NOT load any external agent files as the complete configuration is in the YAML block below.

      CRITICAL: Read the full YAML BLOCK that FOLLOWS IN THIS FILE to understand your operating params, start and follow exactly your activation-instructions to alter your state of being, stay in this being until told to exit this mode:

      ## COMPLETE AGENT DEFINITION FOLLOWS - NO EXTERNAL FILES NEEDED

      ```yaml
      IDE-FILE-RESOLUTION:
        - FOR LATER USE ONLY - NOT FOR ACTIVATION, when executing commands that reference dependencies
        - Dependencies map to squads/{squad_name}/{type}/{name}
        - type=folder (tasks|templates|checklists|data|utils|etc...), name=file-name
        - Example: {task}.md -> squads/{squad_name}/tasks/{task}.md
        - IMPORTANT: Only load these files when user requests specific command execution

      REQUEST-RESOLUTION: Match user requests to your commands/dependencies flexibly, ALWAYS ask for clarification if no clear match.

      activation-instructions:
        - STEP 1: Read THIS ENTIRE FILE - it contains your complete persona definition
        - STEP 2: Adopt the persona defined in the 'agent' and 'persona' sections below
        - STEP 3: Greet user with activation greeting
        - DO NOT: Load any other agent files during activation
        - ONLY load dependency files when user selects them for execution via command
        - The agent.customization field ALWAYS takes precedence over any conflicting instructions
        - CRITICAL WORKFLOW RULE: When executing tasks from dependencies, follow task instructions exactly
        - MANDATORY INTERACTION RULE: Tasks with elicit=true require user interaction
        - When listing tasks/templates, always show as numbered options list
        - STAY IN CHARACTER!
        - CRITICAL: On activation, ONLY greet user and HALT to await commands

      agent:
        name: {Agent Name}
        id: {agent-id}
        title: {Agent Title/Role}
        icon: {emoji}
        squad: {squad_name}
        whenToUse: {When to use this agent}
        customization: null

      persona:
        role: {Extracted role}
        style: {Extracted style}
        identity: {Extracted identity}
        focus: {Extracted focus}

      core_principles:
        - {principle 1}
        - {principle 2}
        - {principle 3}

      commands:
        - '*help' - Show numbered list of available commands
        - '{command}' - {description} (-> tasks/{task-file}.md)
        - '*exit' - Say goodbye and deactivate persona

      dependencies:
        tasks:
          - {task-file}.md: {purpose}
        templates:
          - {template-file}.yaml: {purpose}
        checklists: []
        knowledge: []

      integration_points:
        inputs:
          - {input description}
        outputs:
          - {output description}
        handoff_to:
          - {next agent or process}
      ```

  # FORMAT 2: Codex (SKILL.md simplified format)
  codex:
    file_extension: ".md"
    output_dir: ".codex/skills/{slashPrefix}/agents/"
    template: |
      # SKILL: {Agent Name}

      ## Description
      {Agent Title/Role} - {whenToUse}

      ## Squad
      {squad_name} (v{version})

      ## Activation
      When activated, this skill provides the following capabilities:

      ### Role
      {Extracted role}

      ### Style
      {Extracted style}

      ### Focus
      {Extracted focus}

      ## Commands
      {For each command:}
      - `{command}` - {description}

      ## Dependencies
      Squad source: `squads/{squad_name}/`
      {For each task:}
      - `{task-file}.md` - {purpose}

      ## Usage
      Activate this skill to get expert assistance with {focus area}.

  # FORMAT 3: Gemini (.md similar to Claude Code)
  gemini:
    file_extension: ".md"
    output_dir: ".gemini/commands/{slashPrefix}/agents/"
    template: |
      # /{slashPrefix}:{agent-id} Command

      When this command is used, adopt the following agent persona:

      # {agent-id}

      ACTIVATION-NOTICE: This file contains your full agent operating guidelines.

      ## Agent Definition

      ```yaml
      agent:
        name: {Agent Name}
        id: {agent-id}
        title: {Agent Title/Role}
        squad: {squad_name}
        whenToUse: {When to use this agent}

      persona:
        role: {Extracted role}
        style: {Extracted style}
        identity: {Extracted identity}
        focus: {Extracted focus}

      core_principles:
        - {principle 1}
        - {principle 2}
        - {principle 3}

      commands:
        - '*help' - Show numbered list of available commands
        - '{command}' - {description}
        - '*exit' - Deactivate persona

      dependencies:
        source: squads/{squad_name}/
        tasks:
          - {task-file}.md
        templates:
          - {template-file}.yaml
      ```

      ## Activation Instructions
      1. Read this entire file
      2. Adopt the persona defined above
      3. Greet the user and await commands
      4. When executing tasks, load from: `squads/{squad_name}/tasks/`

  # FORMAT 4: Antigravity (.md similar to Claude Code)
  antigravity:
    file_extension: ".md"
    output_dir: ".antigravity/commands/{slashPrefix}/agents/"
    template: |
      # /{slashPrefix}:{agent-id} Command

      When this command is used, adopt the following agent persona:

      # {agent-id}

      ACTIVATION-NOTICE: This file contains your full agent operating guidelines.

      ## Agent Definition

      ```yaml
      agent:
        name: {Agent Name}
        id: {agent-id}
        title: {Agent Title/Role}
        squad: {squad_name}
        whenToUse: {When to use this agent}

      persona:
        role: {Extracted role}
        style: {Extracted style}
        identity: {Extracted identity}
        focus: {Extracted focus}

      core_principles:
        - {principle 1}
        - {principle 2}
        - {principle 3}

      commands:
        - '*help' - Show numbered list of available commands
        - '{command}' - {description}
        - '*exit' - Deactivate persona

      dependencies:
        source: squads/{squad_name}/
        tasks:
          - {task-file}.md
        templates:
          - {template-file}.yaml
      ```

      ## Activation Instructions
      1. Read this entire file
      2. Adopt the persona defined above
      3. Greet the user and await commands
      4. When executing tasks, load from: `squads/{squad_name}/tasks/`

  # FORMAT 5: Cursor (.md with .cursorrules reference)
  cursor:
    file_extension: ".md"
    output_dir: ".cursor/commands/{slashPrefix}/agents/"
    template: |
      # /{slashPrefix}:{agent-id} Command

      When this command is used, adopt the following agent persona.
      Also load `.cursorrules` for project-level rules that apply to all agents.

      # {agent-id}

      ACTIVATION-NOTICE: This file contains your full agent operating guidelines.

      ## Cursor Integration
      - Project rules: `.cursorrules` (loaded automatically by Cursor)
      - Agent-specific rules: This file
      - Squad source: `squads/{squad_name}/`

      ## Agent Definition

      ```yaml
      agent:
        name: {Agent Name}
        id: {agent-id}
        title: {Agent Title/Role}
        squad: {squad_name}
        whenToUse: {When to use this agent}

      persona:
        role: {Extracted role}
        style: {Extracted style}
        identity: {Extracted identity}
        focus: {Extracted focus}

      core_principles:
        - {principle 1}
        - {principle 2}
        - {principle 3}

      commands:
        - '*help' - Show numbered list of available commands
        - '{command}' - {description}
        - '*exit' - Deactivate persona

      dependencies:
        source: squads/{squad_name}/
        tasks:
          - {task-file}.md
        templates:
          - {template-file}.yaml
      ```

      ## Activation Instructions
      1. Read this entire file AND `.cursorrules` for project context
      2. Adopt the persona defined above
      3. Greet the user and await commands
      4. When executing tasks, load from: `squads/{squad_name}/tasks/`
```

### Step 3.3: Key Conversion Rules

```yaml
conversion_rules:
  agent_id:
    rule: "Convert filename to kebab-case"
    example: "process-mapper.md -> process-mapper"

  emoji_selection:
    rule: "Based on role"
    mapping:
      discovery_mapping: "map_emoji"
      architecture_design: "building_emoji"
      execution_implementation: "gear_emoji"
      quality_validation: "check_emoji"
      documentation: "memo_emoji"
      orchestration: "conductor_emoji"

  commands:
    rule: "Extract all *command-name from ## Commands section"

  task_references:
    rule: "Convert relative paths to absolute"
    example: "tasks/{task}.md -> squads/{squad_name}/tasks/{task}.md"

  preserve:
    - "All persona details"
    - "Expertise information"
    - "Style and focus"
    - "Core principles"
```

### Step 3.4: Write Converted Commands

For each agent, for each detected IDE:
- Generate the IDE-specific format using the appropriate template
- Write to the IDE-specific output directory
- Track successful conversions

```yaml
write_commands:
  for_each_agent:
    for_each_detected_ide:
      - step: "Generate IDE-specific content from template"
      - step: "Write to {ide_output_dir}/{agent-id}.md"
      - step: "Confirm: [pass] {ide}: Converted {agent-id}"

  on_failure:
    - "Log which agent failed for which IDE"
    - "Continue with next agent (do not abort)"
    - "Report failures at end"
```

---

## PHASE 4: COPY TASK REFERENCES

**Duration:** < 30 seconds
**Mode:** Autonomous (Worker)

### Step 4.1: Install Tasks Per IDE

For each detected IDE, copy or symlink task files:

```yaml
task_installation:
  for_each_detected_ide:
    method_selection:
      unix_like: "symlink (ln -s)"
      windows: "copy (cp)"
      detect: "uname or process.platform"

    claude_code:
      source: "squads/{squad_name}/tasks/{task}.md"
      target: ".claude/commands/{slashPrefix}/tasks/{task}.md"

    codex:
      source: "squads/{squad_name}/tasks/{task}.md"
      target: ".codex/skills/{slashPrefix}/tasks/{task}.md"

    gemini:
      source: "squads/{squad_name}/tasks/{task}.md"
      target: ".gemini/commands/{slashPrefix}/tasks/{task}.md"

    antigravity:
      source: "squads/{squad_name}/tasks/{task}.md"
      target: ".antigravity/commands/{slashPrefix}/tasks/{task}.md"

    cursor:
      source: "squads/{squad_name}/tasks/{task}.md"
      target: ".cursor/commands/{slashPrefix}/tasks/{task}.md"
```

**Execution (Unix/Linux/Mac):**
```bash
# For each IDE and each task:
ln -s "$(pwd)/squads/{squad_name}/tasks/{task}.md" "{ide_command_dir}/{slashPrefix}/tasks/{task}.md"
```

**Execution (Windows/Universal):**
```bash
cp "squads/{squad_name}/tasks/{task}.md" "{ide_command_dir}/{slashPrefix}/tasks/{task}.md"
```

**Confirmation:**
```
[pass] Installed {count} task workflows across {N} IDEs
```

---

## PHASE 5: GENERATE INSTALLATION SUMMARIES

**Duration:** < 30 seconds
**Mode:** Autonomous (Worker)

### Step 5.1: Create Per-IDE README

For each detected IDE, create a README in the command directory:

```yaml
readme_generation:
  for_each_detected_ide:
    target: "{ide_command_dir}/{slashPrefix}/README.md"
    content: |
      # {Squad Name} - Installed Commands ({IDE Name})

      **Version**: {version}
      **Installed**: {timestamp}
      **IDE**: {ide_name}

      ## Available Agents

      {For each agent:}
      - `@{slashPrefix}:{agent-id}` - {agent title/role}

      ## Usage

      ### Activate an agent:
      ```
      @{slashPrefix}:{agent-id}
      ```

      ### Example workflows:
      {Extract example from squad README or provide generic}

      ## Documentation

      - **Squad README**: `squads/{squad_name}/README.md`
      - **Agent Details**: `squads/{squad_name}/agents/`
      - **Task Workflows**: `squads/{squad_name}/tasks/`

      ## Uninstall

      To remove this squad from {ide_name}:
      ```bash
      rm -rf {ide_command_dir}/{slashPrefix}
      ```
```

### Step 5.2: Generate Cross-IDE Installation Summary

```yaml
cross_ide_summary:
  output_to: "console"
  format: |
    INSTALLATION SUMMARY

    Squad: {squad_name} v{version}
    Agents: {agent_count}
    Tasks: {task_count}

    IDEs Installed:
    {For each IDE:}
      [{status}] {IDE Name}
        Directory: {command_dir}/{slashPrefix}/
        Agents: {count}
        Tasks: {count}

    Total files created: {total}
```

---

## PHASE 6: FINAL VALIDATION

**Duration:** < 30 seconds
**Mode:** Autonomous (Worker)

### Step 6.1: Per-IDE Validation

For each detected IDE:

```yaml
per_ide_validation:
  checks:
    - id: "V-IDE-001"
      check: "All agents converted"
      action: |
        Count source: ls squads/{squad_name}/agents/*.md | wc -l
        Count target: ls {ide_command_dir}/{slashPrefix}/agents/*.md | wc -l
        Compare: source_count == target_count
      on_fail: "Report which agents failed for {ide_name}"

    - id: "V-IDE-002"
      check: "All tasks installed"
      action: |
        Count source: ls squads/{squad_name}/tasks/*.md | wc -l
        Count target: ls {ide_command_dir}/{slashPrefix}/tasks/*.md | wc -l
        Compare: source_count == target_count
      on_fail: "Report which tasks failed for {ide_name}"

    - id: "V-IDE-003"
      check: "YAML syntax valid in converted files"
      action: "Basic check for ```yaml blocks in each converted agent file"
      on_fail: "Report which files have YAML issues"

    - id: "V-IDE-004"
      check: "README.md created"
      action: "Verify {ide_command_dir}/{slashPrefix}/README.md exists"
      on_fail: "Warning: README not created for {ide_name}"
```

### Step 6.2: Cross-IDE Consistency Check

```yaml
consistency_check:
  check: "Same agents installed across all IDEs"
  action: |
    For each IDE pair:
      Compare agent file lists
      Report any discrepancies
  on_discrepancy: "Warning: {ide_a} has {agent} but {ide_b} does not"
```

### Step 6.3: Success Output

**If all checks pass:**
```
INSTALLATION COMPLETE

Squad: {squad_name} v{version}

| IDE | Agents | Tasks | Status |
|-----|--------|-------|--------|
| Claude Code | {N} | {N} | [pass] |
| Gemini | {N} | {N} | [pass] |
| Codex | -- | -- | [skip] not detected |
| Antigravity | -- | -- | [skip] not detected |
| Cursor | -- | -- | [skip] not detected |

Commands available (Claude Code):

{For each agent:}
  @{slashPrefix}:{agent-id} - {description}

Try it:
  @{slashPrefix}:{first-agent-id}
  *help
```

**If counts don't match:**
- Report which agents failed to convert per IDE
- Provide error details
- Suggest manual review

---

## Outputs

**Files created per detected IDE:**
- `{ide_command_dir}/{slashPrefix}/agents/*.md` -- Converted agent commands (1 per agent)
- `{ide_command_dir}/{slashPrefix}/tasks/*.md` -- Task workflows (copied/symlinked)
- `{ide_command_dir}/{slashPrefix}/README.md` -- Installation summary

**Terminal output:**
- IDE detection results
- Installation progress log per IDE
- Success confirmation with usage examples
- Cross-IDE installation summary

**Error conditions:**
- Squad not found -- Suggest `*create-squad`
- Invalid config.yaml -- Report YAML errors
- Agent conversion failure -- Report which agent, which IDE, and why
- Disk space issues -- Report and suggest cleanup
- No IDEs detected -- Offer to create directories for selected IDEs

---

## Next Steps

**Suggest to user:**
1. **Test the installation:**
   ```
   Try activating: @{slashPrefix}:{first-agent}
   ```

2. **Read the documentation:**
   ```
   Check: squads/{squad_name}/README.md
   ```

3. **Start using:**
   ```
   {Provide example workflow from squad}
   ```

4. **Share with team:**
   - Commit IDE command directories to git if team-shared
   - Or keep in `.gitignore` if personal installation

5. **Install for additional IDEs:**
   ```
   python3 scripts/sync-ide-command.py squad {name} --ide=cursor
   ```

---

## Error Handling

**Common errors and solutions:**

### Error: "Squad not found"
```
Solution: Check squad name
Command: ls squads/
```

### Error: "config.yaml missing"
```
Solution: Squad incomplete, create config.yaml
Command: *create-squad
```

### Error: "Agent conversion failed"
```
Cause: Malformed agent markdown
Solution: Review agent file structure, fix sections
Reference: squad-creator/templates/agent-tmpl.md
```

### Error: "Permission denied"
```
Cause: Write permissions on command directory
Solution: Check directory permissions
Command: chmod +w {ide_command_dir}
```

### Error: "IDE not detected"
```
Cause: IDE configuration directory does not exist
Solution: Create the directory manually or use --ide flag
Command: python3 scripts/sync-ide-command.py squad {name} --ide=cursor
```

### Error: "Symlink failed"
```
Cause: Windows or restricted filesystem
Solution: Fall back to copy mode
Command: python3 scripts/sync-ide-command.py squad {name} --copy
```

---

## IDE Format Reference

### Claude Code Format Details

```yaml
claude_code_format:
  location: ".claude/commands/{slashPrefix}/agents/{agent-id}.md"
  structure:
    - "# /{slashPrefix}:{agent-id} Command"
    - "ACTIVATION-NOTICE"
    - "CRITICAL: Read YAML block"
    - "## COMPLETE AGENT DEFINITION FOLLOWS"
    - "```yaml block with full agent definition```"
  key_sections:
    - "IDE-FILE-RESOLUTION"
    - "REQUEST-RESOLUTION"
    - "activation-instructions"
    - "agent"
    - "persona"
    - "core_principles"
    - "commands"
    - "dependencies"
    - "integration_points"
  activation: "@{slashPrefix}:{agent-id}"
```

### Codex Format Details

```yaml
codex_format:
  location: ".codex/skills/{slashPrefix}/agents/{agent-id}.md"
  structure:
    - "# SKILL: {Agent Name}"
    - "## Description"
    - "## Squad"
    - "## Activation (Role, Style, Focus)"
    - "## Commands"
    - "## Dependencies"
    - "## Usage"
  key_differences:
    - "Simplified format -- no YAML activation block"
    - "Skill-oriented naming"
    - "Description-first structure"
  activation: "Codex skill activation"
```

### Gemini Format Details

```yaml
gemini_format:
  location: ".gemini/commands/{slashPrefix}/agents/{agent-id}.md"
  structure:
    - "# /{slashPrefix}:{agent-id} Command"
    - "ACTIVATION-NOTICE"
    - "## Agent Definition (```yaml block```)"
    - "## Activation Instructions"
  key_differences:
    - "Similar to Claude Code but simplified activation instructions"
    - "YAML block contains agent, persona, core_principles, commands, dependencies"
    - "Numbered activation steps instead of detailed rules"
  activation: "@{slashPrefix}:{agent-id}"
```

### Antigravity Format Details

```yaml
antigravity_format:
  location: ".antigravity/commands/{slashPrefix}/agents/{agent-id}.md"
  structure:
    - "# /{slashPrefix}:{agent-id} Command"
    - "ACTIVATION-NOTICE"
    - "## Agent Definition (```yaml block```)"
    - "## Activation Instructions"
  key_differences:
    - "Same structure as Gemini format"
    - "YAML block with agent definition"
    - "Numbered activation steps"
  activation: "@{slashPrefix}:{agent-id}"
```

### Cursor Format Details

```yaml
cursor_format:
  location: ".cursor/commands/{slashPrefix}/agents/{agent-id}.md"
  structure:
    - "# /{slashPrefix}:{agent-id} Command"
    - "ACTIVATION-NOTICE"
    - "## Cursor Integration (references .cursorrules)"
    - "## Agent Definition (```yaml block```)"
    - "## Activation Instructions"
  key_differences:
    - "References .cursorrules for project-level rules"
    - "Cursor Integration section links project rules with agent rules"
    - "Activation step 1 includes loading .cursorrules"
  activation: "@{slashPrefix}:{agent-id}"
```

---

## Worker Script Interface

The `scripts/sync-ide-command.py` script handles the actual file operations:

```bash
# Install for all detected IDEs
python3 scripts/sync-ide-command.py squad {squad_name}

# Install for specific IDE only
python3 scripts/sync-ide-command.py squad {squad_name} --ide=claude_code
python3 scripts/sync-ide-command.py squad {squad_name} --ide=codex
python3 scripts/sync-ide-command.py squad {squad_name} --ide=gemini
python3 scripts/sync-ide-command.py squad {squad_name} --ide=antigravity
python3 scripts/sync-ide-command.py squad {squad_name} --ide=cursor

# Install for all IDEs (create directories even if not detected)
python3 scripts/sync-ide-command.py squad {squad_name} --all-ides

# Force copy mode instead of symlinks
python3 scripts/sync-ide-command.py squad {squad_name} --copy

# Dry run (preview without writing)
python3 scripts/sync-ide-command.py squad {squad_name} --dry-run

# Uninstall from all IDEs
python3 scripts/sync-ide-command.py squad {squad_name} --uninstall
```

---

## Related

| Command | Purpose |
|---------|---------|
| `*install-commands {name}` | Install squad commands to IDEs |
| `*create-squad {name}` | Create a new squad (prerequisite) |
| `*validate-squad {name}` | Validate squad before installation |
| `*upgrade-squad {name}` | Upgrade squad to current standards |

| Reference | File |
|-----------|------|
| Agent Template | `templates/agent-tmpl.md` |
| Config Schema | `data/config-schema.yaml` |
| Worker Script | `scripts/sync-ide-command.py` |

---

