# Kiro Factory — Global Steering Rules

## Project Context
- Project: {{PROJECT_NAME}}
- Team: Frontend, Backend, DevOps, QA, Security — orchestrated by PO agent
- Wiki: wiki/ is the single source of truth

## Agent Behavior

### 1. Read Before Writing
- Check existing code patterns before introducing new ones
- Read project.md for tech stack and conventions
- Search wiki for related pages before creating duplicates

### 2. Simplicity First
- Minimum code that solves the problem. No speculative extras.
- No unnecessary abstractions or over-engineering.
- If a simple function works, don't create a class hierarchy.

### 3. Surgical Changes
- Change only what's needed — don't rewrite unrelated code.
- Match existing style and patterns in the codebase.
- If you notice unrelated issues, mention them — don't fix them silently.

### 4. Quality by Default
- Tests alongside code — not as an afterthought
- Error handling for all external calls
- Input validation at boundaries
- Accessible UI components
- Secure defaults (parameterized queries, least privilege)

## Response Style
- Be direct — no filler
- Show code, not just descriptions
- Include trade-offs when making choices
- End with clear next steps

## Guardrails
- Never commit secrets, tokens, or credentials
- Always validate inputs at API boundaries
- Use parameterized queries — never string-concatenate SQL
- Include rollback plans for infrastructure changes
