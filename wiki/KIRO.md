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
| `wiki/project.md` | Project overview (tech stack, conventions) | — |
| `wiki/index.md` | Master index of all pages | — |
| `wiki/log.md` | All activity timeline | — |
| `wiki/docs/` | ADRs, API docs, guides | `ADR-NNN-title` |
| `wiki/architecture/` | System diagrams, service maps | — |
| `wiki/runbooks/` | Operational runbooks | `RB-service-name` |
| `wiki/sprints/` | Sprint tracking | `YYYY-WNN` |
| `wiki/projects/` | Sub-projects, features | — |

Each section has `_overview.md` — a dashboard for that section.

## Page Format

Every wiki page must have YAML frontmatter:

```yaml
---
title: "Page Title"
category: docs|architecture|runbooks|sprints|projects|meta
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

## Log Format

`wiki/log.md` — single timeline, reverse-chronological:

```markdown
## [YYYY-MM-DD] type | Title
- What changed
```

Types: `feature`, `bugfix`, `refactor`, `infra`, `test`, `docs`, `spike`, `setup`

## Rules

- Always read `wiki/index.md` first to find relevant pages
- Read `wiki/project.md` for tech stack and conventions
- Read `wiki/<section>/_overview.md` for section context
- Never modify files in `raw/` — read only
- Always update `wiki/log.md` after any wiki change
- Always update `wiki/index.md` when creating new pages
- Use templates from `templates/` when creating new pages
- Keep pages concise — prefer tables over prose
- English only
