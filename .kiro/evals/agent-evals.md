# Kiro Factory — LLM-as-Judge Eval Prompts
# Used by orchestrator to score sub-agent outputs after each run.
# Score 1-5 per criterion. Log total score in JSONL.

## factory-rnd
```
Rate this R&D agent output (1-5 each):
1. COMPARISON: Has comparison table when multiple options exist?
2. EVIDENCE: Cites reasoning, not just conclusions?
3. CONFIDENCE: States confidence level (high/medium/low)?
4. RECOMMENDATIONS: Ends with clear, actionable recommendations?
5. CONCISENESS: Focused on top 5-7 options, not exhaustive list?
Reply ONLY as: RND_SCORE=X/25 (sum of 5 criteria)
```

## factory-finance
```
Rate this Finance agent output (1-5 each):
1. NUMBERS: Uses concrete numbers and THB amounts (not vague)?
2. TABLES: Presents budgets/breakdowns in table format?
3. RISKS: Mentions risks alongside every opportunity?
4. ACTIONS: Has clear action steps with timeline?
5. ACCURACY: Numbers are consistent and add up correctly?
Reply ONLY as: FIN_SCORE=X/25 (sum of 5 criteria)
```

## factory-career
```
Rate this Career agent output (1-5 each):
1. TIMELINE: Has specific timelines and milestones (not vague)?
2. ACTIONS: Action items are concrete and achievable?
3. MARKET: References real market context (Thai tech market)?
4. SKILLS: Considers both technical and soft skills?
5. SALARY: Includes salary benchmarks when relevant?
Reply ONLY as: CAR_SCORE=X/25 (sum of 5 criteria)
```

## factory-km-life
```
Rate this KM/Life agent output (1-5 each):
1. PRACTICAL: Suggests specific tools, methods, templates?
2. SYSTEMS: Advice structured as repeatable systems, not one-off tips?
3. SUSTAINABLE: Realistic for a busy tech professional?
4. TEMPLATES: Includes ready-to-use templates when helpful?
5. IMPLEMENTATION: Has clear implementation steps?
Reply ONLY as: KML_SCORE=X/25 (sum of 5 criteria)
```

## factory-general
```
Rate this General/Synthesis agent output (1-5 each):
1. UNIFIED: Creates unified narrative (not just concatenation)?
2. CONFLICTS: Identifies conflicts between domain recommendations?
3. SYNERGIES: Identifies where plans reinforce each other?
4. PRIORITIES: Top 3-5 actions clearly prioritized?
5. CONCISE: Adds big picture without repeating domain details?
Reply ONLY as: GEN_SCORE=X/25 (sum of 5 criteria)
```
