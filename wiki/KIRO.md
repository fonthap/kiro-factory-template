# Wiki Schema — Kiro Factory

> Instructions for LLM agents operating on this wiki.
> Read this file before any wiki operation.

## Architecture

```
raw/        → Source documents (immutable, user-owned)
wiki/       → LLM-maintained pages (LLM-owned)
templates/  → Page templates
KIRO.md     → This file (schema)
```

## Directory Map

| Path | Purpose | Naming |
|------|---------|--------|
| `wiki/me.md` | User profile | — |
| `wiki/index.md` | Master index of all pages | — |
| `wiki/log.md` | All activity timeline | — |
| `wiki/work/` | Day job: incidents, runbooks, ADRs, postmortems | `INC-`, `RB-`, `ADR-`, `PM-` |
| `wiki/learning/` | Certs, topics, study notes | `CERT-`, `TOPIC-`, `NOTE-` |
| `wiki/career/` | Career plans, skills, market | — |
| `wiki/finance/` | Budget, goals, monthly tracking | `YYYY-MM.md` |
| `wiki/projects/` | Side projects | `PRJ-name/` |
| `wiki/life/` | Health, habits, goals | — |

Each section has `_overview.md` — a dashboard for that section.

## Page Format

Every wiki page must have YAML frontmatter:

```yaml
---
title: "Page Title"
category: work|learning|career|finance|projects|life|meta
tags: [tag1, tag2]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Body structure: **Summary → Content → Links**

Use `[[page-name]]` for internal wiki links.

## Workflows

### Ingest (new source)
1. User drops file in `raw/`
2. Read the source
3. Create/update relevant wiki pages
4. Update `wiki/index.md`
5. Append to `wiki/log.md`

### Query (user asks a question)
1. Read `wiki/index.md` to find relevant pages
2. Read relevant pages
3. Synthesize answer
4. If answer is valuable, save as new wiki page
5. Append to `wiki/log.md`

### Update (agent modifies wiki)
1. Read existing page
2. Make changes
3. Update `updated` date in frontmatter
4. Update `wiki/index.md` if new page
5. Append to `wiki/log.md`

### Lint (health check)
1. Check for orphan pages (not in index)
2. Check for broken `[[links]]`
3. Check for missing frontmatter
4. Check for stale pages (not updated in 30+ days)
5. Suggest new pages for mentioned-but-missing concepts

## Log Format

`wiki/log.md` — single timeline, reverse-chronological:

```markdown
## [YYYY-MM-DD] type | Title
- What changed
- Decision made (if any)
```

Types: `ingest`, `query`, `decision`, `update`, `lint`, `setup`, `restructure`

## Rules

- Always read `wiki/index.md` first to find relevant pages
- Read `wiki/me.md` when you need user context
- Read `wiki/<section>/_overview.md` for section context
- Never modify files in `raw/` — read only
- Always update `wiki/log.md` after any wiki change
- Always update `wiki/index.md` when creating new pages
- Use templates from `templates/` when creating new pages
  - `page.md` — generic page (default)
  - `project.md` — project documentation
  - `research.md` — research with comparison table + recommendations
  - `overview.md` — section dashboard (`_overview.md`)
  - `cert.md` — certification study plan
  - `runbook.md` — operational runbook
  - `incident.md` — incident report with timeline
  - `monthly-finance.md` — monthly income/expense tracking
- Keep pages concise — prefer tables over prose
- Use THB for currency
- English only
