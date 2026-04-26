# Kiro Factory Template

Multi-agent AI software team built on [Kiro CLI](https://github.com/amazon/kiro-cli). A **Product Owner** orchestrator delegates to **Frontend**, **Backend**, **DevOps**, and **QA** agents — backed by a project wiki.

## What You Get

```
.kiro/                          # Agent system (→ ~/.kiro/)
├── agents/                     # PO orchestrator + 5 engineer agents
│   ├── kiro-factory.json       # Product Owner (task breakdown, delegation, review)
│   ├── factory-frontend.json   # Senior Frontend Engineer
│   ├── factory-backend.json    # Senior Backend Engineer
│   ├── factory-devops.json     # Senior DevOps/SRE Engineer
│   └── factory-qa.json         # Senior QA Engineer
│   └── factory-security.json   # Senior Security Engineer
├── prompts/                    # PO system prompt
├── evals/                      # Code review scoring per agent
├── hooks/                      # Logging, cost tracking, trace viewer
├── steering/                   # Global coding standards
├── settings/                   # CLI + MCP config
└── docs/                       # Agent onboarding runbook

wiki/                           # Project wiki (→ ~/wiki/)
├── KIRO.md                     # Schema — how agents use the wiki
├── templates/                  # Page templates (ADR, sprint, runbook, incident, etc.)
└── wiki/                       # Agent-maintained pages
    ├── project.md              # Tech stack, conventions, environments
    ├── index.md                # Master page index
    ├── log.md                  # Activity timeline
    ├── docs/                   # ADRs, API docs, guides
    ├── architecture/           # System diagrams, service maps
    ├── runbooks/               # Operational procedures
    ├── sprints/                # Sprint tracking
    └── projects/               # Sub-projects, features
```

## Agent Team

| Agent | Role | Handles |
|-------|------|---------|
| `kiro-factory` | Product Owner | Task breakdown, delegation, code review, integration |
| `factory-frontend` | Senior Frontend | React/Next.js, TypeScript, UI/UX, accessibility, component tests |
| `factory-backend` | Senior Backend | APIs, databases, auth, business logic, integration tests |
| `factory-devops` | Senior DevOps/SRE | CI/CD, Terraform, Kubernetes, monitoring, runbooks |
| `factory-qa` | Senior QA | Test strategy, E2E automation, performance testing, quality gates |
| `factory-security` | Senior Security | Threat modeling, OWASP, secure code review, dependency scanning |

## Quick Start

```bash
# 1. Install Kiro CLI
npm install -g @anthropic/kiro-cli

# 2. Clone and setup
git clone https://github.com/fonthap/kiro-factory-template.git
cd kiro-factory-template
bash setup.sh

# 3. Start
kiro-cli chat
```

### Example prompts

```
"build a login page with email/password form"
"add a REST API for user CRUD with PostgreSQL"
"set up GitHub Actions CI pipeline with lint, test, build"
"write E2E tests for the checkout flow"
"create an ADR for choosing PostgreSQL over MongoDB"
```

The PO will analyze your request, delegate to the right agents (in parallel when possible), review their output, and return the integrated result.

## Setup Script

`setup.sh` will ask for:
- Project name
- Your GitHub username (for repo URLs in templates)

Then it replaces all `{{PLACEHOLDERS}}`, copies `.kiro/` to `~/.kiro/` and `wiki/` to `~/wiki/`, and installs Playwright for web browsing.

## Manual Setup

```bash
cp -r .kiro/ ~/.kiro/
cp -r wiki/ ~/wiki/

# Replace {{HOME}} in kiro-factory.json with your home path
# Replace {{PROJECT_NAME}} in wiki files with your project name
# Replace {{DATE}} with today's date

npx playwright install chromium
```

## Customization

### Change default model
Edit `.kiro/settings/cli.json` → `chat.defaultModel`. Each agent also has its own `model` field.

### Add/remove agents
See [docs/agent-onboarding.md](.kiro/docs/agent-onboarding.md).

### Add MCP servers
Edit `.kiro/settings/mcp.json` (Playwright pre-configured for web browsing).

## Tools

```bash
# Cost report
~/.kiro/hooks/factory-cost.sh          # today
~/.kiro/hooks/factory-cost.sh 7d       # last 7 days

# Trace viewer
~/.kiro/hooks/factory-trace.sh         # last trace
~/.kiro/hooks/factory-trace.sh all     # all today

# Log viewer
~/.kiro/hooks/factory-logs.sh summary
```

## How It Works

1. You describe a feature or task
2. PO reads project wiki for context (tech stack, conventions, existing code)
3. PO plans which agents to dispatch (parallel or pipeline)
4. Agents write code, tests, infra, and docs
5. PO reviews quality, integrates pieces, updates the wiki
6. Knowledge compounds — agents reference past ADRs, runbooks, and patterns

## License

MIT
