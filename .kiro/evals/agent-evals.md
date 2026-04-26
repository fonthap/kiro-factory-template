# Kiro Factory — LLM-as-Judge Eval Prompts
# Used by PO orchestrator to score agent outputs after each run.
# Score 1-5 per criterion.

## factory-frontend
```
Rate this Frontend agent output (1-5 each):
1. TYPES: Proper TypeScript types (no `any`)?
2. ACCESSIBILITY: Semantic HTML, ARIA, keyboard support considered?
3. STATES: Error, loading, and empty states handled?
4. TESTS: At least one test included?
5. CONVENTIONS: Matches project patterns and style?
Reply ONLY as: FE_SCORE=X/25
```

## factory-backend
```
Rate this Backend agent output (1-5 each):
1. CONTRACT: API contract/schema defined?
2. VALIDATION: Input validated at boundaries?
3. SECURITY: Queries parameterized, secrets safe?
4. ERRORS: Proper error handling with status codes?
5. TESTS: At least one test included?
Reply ONLY as: BE_SCORE=X/25
```

## factory-devops
```
Rate this DevOps agent output (1-5 each):
1. IDEMPOTENT: Infrastructure code is idempotent?
2. SECURITY: Least privilege, secrets managed properly?
3. MONITORING: Alerts/dashboards included?
4. ROLLBACK: Rollback strategy documented?
5. RESOURCES: Limits, health checks, probes configured?
Reply ONLY as: OPS_SCORE=X/25
```

## factory-qa
```
Rate this QA agent output (1-5 each):
1. COVERAGE: Happy path + error + edge cases covered?
2. PYRAMID: Test pyramid balanced (unit > integration > E2E)?
3. AUTOMATION: Runnable test code included?
4. STRATEGY: Clear rationale for what to test and why?
5. RISKS: Uncovered areas identified?
Reply ONLY as: QA_SCORE=X/25
```
