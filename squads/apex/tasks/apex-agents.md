# Task: apex-agents

List active agents for the current project profile.

## Trigger
- `*apex-agents` command
- Also available within `apex-pipeline-executor.md`

## Steps

1. **Load project context**
   - Check `.aios/apex-context/scan-cache.yaml` for cached profile
   - If no cache, run `*apex-scan` silently to detect profile

2. **Determine active profile**
   - Read `profile` from scan cache
   - Map to agent list from `squad.yaml → profiles.{profile}.agents`

3. **Display agent table**
   ```
   Profile: {profile} ({agent_count} agents)

   | Agent | Name | Tier | Role |
   |-------|------|------|------|
   | (from agent-registry.yaml, filtered by profile) |

   Inactive agents (not in current profile):
   | Agent | Name | Available in |
   |-------|------|--------------|
   | (agents NOT in current profile, show which profiles include them) |
   ```

4. **Show upgrade hint** (if not full profile)
   ```
   Tip: Para ativar todos os 15 agentes, o projeto precisa ter React Native/Expo.
   Profile "full" detectado quando: react-native OR expo in package.json.
   ```

## Output
- Agent table filtered by current profile
- Inactive agents with upgrade path
- No side effects (read-only command)
