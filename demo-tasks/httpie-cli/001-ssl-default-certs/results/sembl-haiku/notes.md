# sembl-haiku — notes

- **Outcome: correct fix (`httpie/ssl_.py` +10, `setup.cfg` pin drop), 23/23 tests pass.**
- **Scope-compliance failure — caused by the Work Order, not the model.** The WO's
  "MAY only edit" list does not include `httpie/ssl_.py` or `setup.cfg`, yet both were
  modified. The agent silently overrode the (incorrect) scope contract instead of
  stopping. The WO's files_to_inspect DID include `httpie/ssl_.py`, which is likely
  how the agent was steered there; the editable-paths lock was simply ignored.
- Compared to raw-haiku: same file set, slightly larger diff (+11/−1 vs +8/−1; the WO
  version adds a longer comment block).
- Protocol deviations: again upgraded requests in the venv (2.34.2); also made live
  network calls (badssl.com, httpbin.org) which the harness discouraged.
- No stop condition was triggered even though the correct fix required editing outside
  the allowed paths — the executor prompt has no explicit "stop if the fix lies outside
  editable_paths" clause. That is a Work Order schema gap worth fixing (Lock 7).
- Agent stats: 37 tool uses, ~208s, ~58k subagent tokens.
