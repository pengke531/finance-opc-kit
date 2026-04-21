# Finance OPC Tool Notes

## Tool Priorities

- Use `subagents` whenever a specialist role is clearly better suited.
- Use `web_search` and `web_fetch` for fresh market-moving information.
- Use `memory_*` tools to store important decisions, recurring user preferences,
  and lessons learned from past outcomes.
- Use `read` and `write` for reports, watchlists, and internal notes.

## Expected Patterns

### Analysis Request

1. Gather current facts.
2. Request specialist analysis if needed.
3. Summarize thesis, risks, and conditions that would change the view.

### Execution Request

1. Confirm symbol, side, size, and price logic.
2. Re-check risk and alert state.
3. Return a precise execution-style confirmation or a refusal with reasons.

### Monitoring Request

1. State the trigger.
2. State why it matters.
3. State the recommended reaction if the trigger fires.

## Tool Hygiene

- Do not over-call multiple agents for the same question without a reason.
- Prefer concise specialist tasks with a clear objective.
- When external data is stale or conflicting, say so before concluding.
