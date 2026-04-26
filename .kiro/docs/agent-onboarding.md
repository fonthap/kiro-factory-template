# Kiro Factory — Agent Onboarding / Offboarding

## Add a New Agent

### Step 1: Create agent config

Copy template to `~/.kiro/agents/factory-<name>.json`:

```json
{
  "name": "factory-<name>",
  "description": "<Domain> specialist — <one-line description of expertise>.",
  "prompt": "You are the <Domain> Specialist in the Kiro Factory AI Team.\n\nExpertise: <list core skills>.\n\nWiki: Read ~/wiki/wiki/me.md for user context. Write results to ~/wiki/wiki/<domain>/ and update index.md + log.md.\n\nRules:\n- <domain-specific rules>\n- Structure: Summary → <domain output sections>\n\nReflection: Before returning your final output, re-read it and check: <quality checks>. Fix any issues before responding.\n\nOutput Validation: Your response MUST include: 1) <mandatory section 1>, 2) <mandatory section 2>. If any are missing, add them before responding.\n\n- After completing your task, write all file paths you read or wrote (one per line) to ~/.kiro/logs/factory/manifests/<stage-name>.files",
  "tools": ["fs_read", "fs_write", "grep", "glob", "knowledge"],
  "allowedTools": ["fs_read", "fs_write", "grep", "glob", "knowledge"],
  "model": "claude-sonnet-4-20250514"
}
```

If the agent needs MCP (e.g. web browsing), add:
```json
  "useLegacyMcpJson": true
```

### Step 2: Register in orchestrator

Edit `~/.kiro/agents/kiro-factory.json` → `toolsSettings.crew.availableAgents`:

```json
"availableAgents": ["factory-rnd", ..., "factory-<name>"]
```

### Step 3: Add to orchestrator prompt

Edit `~/.kiro/prompts/kiro-factory.md` → add row to the team table.

### Step 4: Add eval criteria

Append to `~/.kiro/evals/agent-evals.md`.

### Step 5: Create wiki section (optional)

```bash
mkdir -p ~/wiki/wiki/<domain>
```

Create `~/wiki/wiki/<domain>/_overview.md` and add to `~/wiki/wiki/index.md`.

### Step 6: Validate

```bash
kiro-cli agent validate --path ~/.kiro/agents/factory-<name>.json
kiro-cli agent validate --path ~/.kiro/agents/kiro-factory.json
```

### Step 7: Update docs

- Add agent to `README.md` Agent Team table
- Add changelog entry

---

## Remove an Agent

1. Remove from `kiro-factory.json` → `availableAgents`
2. Remove from `prompts/kiro-factory.md` → team table
3. `mv ~/.kiro/agents/factory-<name>.json ~/.kiro/agents/factory-<name>.json.bak`
4. Remove eval section from `evals/agent-evals.md`
5. Validate orchestrator: `kiro-cli agent validate --path ~/.kiro/agents/kiro-factory.json`
6. Update docs

---

## Checklist

### Onboarding
- [ ] `agents/factory-<name>.json` created
- [ ] `kiro-factory.json` → `availableAgents` updated
- [ ] `prompts/kiro-factory.md` → team table updated
- [ ] `evals/agent-evals.md` → criteria added
- [ ] `~/wiki/wiki/<domain>/` created (if new domain)
- [ ] Both configs validated with `kiro-cli agent validate`
- [ ] Committed and pushed

### Offboarding
- [ ] `kiro-factory.json` → `availableAgents` updated
- [ ] `prompts/kiro-factory.md` → team table updated
- [ ] Agent config moved to `.bak`
- [ ] `evals/agent-evals.md` → section removed
- [ ] Orchestrator validated
- [ ] Committed and pushed
