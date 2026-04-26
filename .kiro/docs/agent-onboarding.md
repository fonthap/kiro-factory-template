# Kiro Factory — Agent Onboarding / Offboarding

## Add a New Agent

1. Create `~/.kiro/agents/factory-<name>.json`:
```json
{
  "name": "factory-<name>",
  "description": "<Role> — <expertise summary>.",
  "prompt": "You are the <Role> in the Kiro Factory team.\n\nExpertise: ...\n\nWiki: Read ~/wiki/wiki/index.md to find relevant pages. Write results to ~/wiki/wiki/ and update index.md + log.md.\n\nRules: ...\n\nReflection: ...\n\nOutput Validation: ...\n\n- After completing your task, write all file paths you read or wrote (one per line) to ~/.kiro/logs/factory/manifests/<stage-name>.files",
  "tools": ["fs_read", "fs_write", "grep", "glob", "knowledge", "execute_bash"],
  "allowedTools": ["fs_read", "fs_write", "grep", "glob", "knowledge"],
  "model": "claude-sonnet-4-20250514"
}
```

2. Add to `kiro-factory.json` → `toolsSettings.crew.availableAgents`
3. Add to `prompts/kiro-factory.md` → team table
4. Add eval criteria to `evals/agent-evals.md`
5. Validate: `kiro-cli agent validate --path ~/.kiro/agents/factory-<name>.json`

## Remove an Agent

1. Remove from `kiro-factory.json` → `availableAgents`
2. Remove from `prompts/kiro-factory.md` → team table
3. `mv ~/.kiro/agents/factory-<name>.json ~/.kiro/agents/factory-<name>.json.bak`
4. Remove eval section from `evals/agent-evals.md`
5. Validate orchestrator
