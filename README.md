# Kiro Factory Template

Multi-agent AI team built on [Kiro CLI](https://github.com/amazon/kiro-cli) for personal life & work management. 5 specialized agents + 1 orchestrator, backed by a file-based LLM Wiki.

Inspired by [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## What You Get

```
.kiro/                          # Agent system (→ ~/.kiro/)
├── agents/                     # 1 orchestrator + 5 specialist agents
│   ├── kiro-factory.json       # Main orchestrator (DAG delegation)
│   ├── factory-rnd.json        # R&D Director (research, tech radar, web browsing)
│   ├── factory-finance.json    # Wealth Strategist (Thai finance, tax, investments)
│   ├── factory-career.json     # Career Strategist (Thai tech market, negotiation)
│   ├── factory-km-life.json    # Life Architect (habits, energy, productivity)
│   └── factory-general.json    # Strategy Director (synthesis, trade-offs)
├── prompts/                    # Orchestrator system prompt
├── evals/                      # LLM-as-Judge quality scoring per agent
├── hooks/                      # Logging, cost tracking, trace viewer
├── steering/                   # Global behavior rules
├── settings/                   # CLI + MCP config
└── docs/                       # Agent onboarding runbook

wiki/                           # Knowledge base (→ ~/wiki/)
├── KIRO.md                     # Schema — how agents operate on the wiki
├── templates/                  # 8 page templates (incident, runbook, cert, etc.)
├── raw/                        # Your source documents (immutable)
└── wiki/                       # LLM-maintained pages
    ├── me.md                   # Your profile
    ├── index.md                # Master page index
    ├── log.md                  # Activity timeline
    ├── work/                   # Incidents, runbooks, architecture
    ├── learning/               # Certs, topics, study notes
    ├── career/                 # Roadmap, skills, market research
    ├── finance/                # Budget, goals, tracking
    ├── projects/               # Side projects
    └── life/                   # Health, habits, travel
```

## Agent Team

| Agent | Role | Special |
|-------|------|---------|
| `kiro-factory` | Orchestrator | DAG delegation, LLM-as-Judge eval, log enforcement |
| `factory-rnd` | Senior R&D Director | 🌐 Web browsing (Playwright MCP), first-principles analysis |
| `factory-finance` | Senior Wealth Strategist | Thai tax/finance, behavioral bias detection |
| `factory-career` | Senior Career Strategist | Thai tech market salary data, negotiation playbooks |
| `factory-km-life` | Life Architect | Systems thinking, energy management, habit engineering |
| `factory-general` | Strategy Director | McKinsey-style synthesis, cross-domain trade-offs |

## Key Features

- **Plan-and-Execute**: Complex requests get explicit plan → execute → check → revise
- **Parallel DAG**: Independent agents run simultaneously
- **LLM-as-Judge**: 5 criteria × 5 agents quality scoring
- **Reflection**: Agents self-review before responding
- **Output Validation**: Mandatory sections enforced per domain
- **Semantic Search**: Agents search wiki by meaning via `knowledge` tool
- **Cost Tracking**: Model-aware pricing with THB conversion
- **Trace Viewer**: OTel-style trace_id + span_id per request
- **Log Enforcement**: Orchestrator verifies log.md updated after every delegation
- **Security**: Path restrictions, no secrets in logs, permission scoping

## Quick Start

### 1. Install Kiro CLI

```bash
npm install -g @anthropic/kiro-cli
```

### 2. Clone and setup

```bash
git clone https://github.com/fonthap/kiro-factory-template.git
cd kiro-factory-template
bash setup.sh
```

The setup script will:
- Ask for your name, role, company, etc.
- Replace all `{{PLACEHOLDERS}}` with your values
- Copy `.kiro/` to `~/.kiro/` and `wiki/` to `~/wiki/`
- Install Playwright for web browsing

### 3. Start

```bash
kiro-cli chat
```

The orchestrator (`kiro-factory`) loads automatically. Try:

```
"research the top 3 Kubernetes monitoring tools and compare them"
"create a monthly budget plan for 50K THB salary"
"plan my career path from mid to senior engineer"
"design a weekly routine that balances work, learning, and health"
```

## Manual Setup (without setup.sh)

1. Copy configs:
```bash
cp -r .kiro/ ~/.kiro/
cp -r wiki/ ~/wiki/
```

2. Edit placeholders in these files:
```
~/.kiro/agents/kiro-factory.json    → replace {{HOME}} with your home path
~/.kiro/steering/factory-rules.md   → fill in your details
~/wiki/wiki/me.md                   → fill in your profile
~/wiki/wiki/log.md                  → replace {{DATE}}
~/wiki/wiki/index.md                → replace {{DATE}}
~/wiki/wiki/*/_overview.md          → replace {{PLACEHOLDERS}}
```

3. Install Playwright (for web browsing):
```bash
npx playwright install chromium
```

## Customization

### Change default model
Edit `.kiro/settings/cli.json`:
```json
"chat.defaultModel": "claude-sonnet-4-20250514"
```
Agent models are set individually in each agent JSON (`"model"` field).

### Add a new agent
See [docs/agent-onboarding.md](.kiro/docs/agent-onboarding.md).

### Add MCP servers
Edit `.kiro/settings/mcp.json` to add Notion, draw.io, or other MCP servers.

### Adjust steering rules
Edit `.kiro/steering/factory-rules.md` for global behavior preferences.

## Tools

```bash
# Cost report (today / last 7 days / whole month)
~/.kiro/hooks/factory-cost.sh
~/.kiro/hooks/factory-cost.sh 7d
~/.kiro/hooks/factory-cost.sh 2026-04

# Trace viewer
~/.kiro/hooks/factory-trace.sh          # last trace
~/.kiro/hooks/factory-trace.sh all      # all traces today

# Log viewer
~/.kiro/hooks/factory-logs.sh summary
~/.kiro/hooks/factory-logs.sh stats

# Cleanup old logs (>30 days)
~/.kiro/hooks/factory-cleanup.sh --dry-run
```

## How It Works

1. You send a prompt to `kiro-factory` (orchestrator)
2. It reads your wiki (`index.md`, `me.md`) for context
3. It plans which agents to dispatch (parallel or pipeline)
4. Sub-agents research, analyze, and write results to wiki pages
5. Orchestrator evaluates quality, synthesizes, and updates the log
6. Knowledge compounds over time — agents reference past decisions

## License

MIT
