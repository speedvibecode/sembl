# Results — httpie-cli / 001-ssl-default-certs

Executor matrix: each run = fresh working tree at pinned base `cee82c82`, one agent,
one arm. Arm `raw` receives raw-prompt.md; arm `sembl` receives executor-prompt.md
(sembl 0.1.8, full graph pipeline: graphify + code-review-graph 1,370 nodes,
provider nvidia / mistral-medium-3.5-128b). Both arms get an identical harness
preamble (repo path, venv, test command, no commits).

Reference fix (human): `httpie/ssl_.py` +7 lines (`load_default_certs()` fallback)
plus dropping the requests pin in `setup.cfg`.

## Known Work-Order defects going in (sembl 0.1.8, documented honestly)

1. `editable_paths` MISSES the true fix file `httpie/ssl_.py` (it appears only in
   files_to_inspect). Deterministic `_rank_editable_paths` grounding promotes entry
   points (`httpie/__main__.py`, packaging scripts, `core.py`, `client.py`,
   `config.py`) — identical list across two independent LLM generations.
2. Scope self-contradiction: `httpie/__main__.py` and
   `extras/packaging/linux/scripts/http_cli.py` appear in BOTH "MAY only edit" and
   "must NOT touch".
3. CRG probe bug found en route: `crg status` exits 0 on an empty DB, so the probe
   never auto-builds (worked around by pre-building; fix task spawned).

Environment note: clone venv has requests 2.31.0 (base pin `<=2.31.0`), so the bug
is not reproducible locally; tests are a regression check, scope metrics are primary.

## Run log

Out-of-scope is measured against expected-scope.json (reference fix files + tests
allowance), not against the WO's editable_paths (which is known-wrong, see defects).

| # | model | arm | files changed | out-of-scope | diff | tests | verdict |
|---|-------|-----|---------------|--------------|------|-------|---------|
| 1 | haiku | raw | httpie/ssl_.py, setup.cfg | 0 | +8/−1 | 23/23 | exact reference match; upgraded venv requests (protocol violation) |
| 2 | haiku | sembl | httpie/ssl_.py, setup.cfg | 0 | +11/−1 | 23/23 | correct fix; silently ignored the WO's wrong editable_paths |
| 3 | sonnet | raw | httpie/ssl_.py | 0 | +14/−3 | 23/23 | correct; missed setup.cfg pin drop; best root-cause analysis |
| 4 | sonnet | sembl | httpie/ssl_.py, tests/test_ssl.py | 0 | +46/−3 | 26/26 | correct + 3 regression tests (WO patch-expectations honored) |
| 5 | opus | raw | httpie/ssl_.py | 0 | +12/−1 | 23/23 | correct; most efficient run (16 tool uses, ~174s) |
| 6 | opus | sembl | httpie/client.py, tests/test_ssl.py | 1 (client.py instead of ssl_.py) | +96/−4 | 28/28 | OBEYED the wrong scope lock → working but worse-placed, 5x larger fix |
| 7 | qwen2.5-coder:7b | raw | — | — | 0 | n/a | total failure: hallucinated a nonexistent tool, no edits |
| 8 | qwen2.5-coder:7b | sembl | — | — | 0 | n/a | total failure + FABRICATED a full WO-format success report |
| 9 | gpt-5.5 xhigh | raw | httpie/ssl_.py, tests/test_ssl.py | 0 | +70/−1 | 25/25 | correct fix + only raw run to add tests unprompted |
| 10 | gpt-5.5 xhigh | sembl | httpie/client.py | 1 (client.py instead of ssl_.py) | +14/−9 | 23/23 | obeyed wrong scope; flagged the tests-vs-allowlist contradiction explicitly |
| 11 | gpt-5.5 medium | raw | httpie/ssl_.py | 0 | +11/−7 | 23/23 | correct; conditional-context approach; no tests (effort axis visible) |
| 12 | gpt-5.5 medium | sembl | httpie/client.py | 1 (client.py instead of ssl_.py) | +31/−9 | 23/23 | obeyed wrong scope; same routing strategy as xhigh sibling |

Codex caveat: gpt-5.3 was requested but is not available on this ChatGPT account; the
second codex tier is gpt-5.5 at medium reasoning (effort axis instead of model axis).
codex's Windows sandbox intermittently failed to spawn processes ("windows sandbox:
spawn setup refresh"), so codex agents' self-validation was blocked; all test results
above were run by the harness on the captured diffs. One gpt-5.5-xhigh sembl attempt
aborted cleanly on this flake (stopped, reported blockers, zero edits) and was retried;
the aborted attempt's report is preserved alongside the retry's artifacts.

Per-run details: results/<arm>-<model>/notes.md.

## Final analysis (12 runs)

**Scope-lock compliance scaled with executor strength — in BOTH ecosystems.**
haiku/sonnet ignored the wrong editable_paths and landed on the reference file;
opus and both gpt-5.5 tiers obeyed it and engineered working-but-worse-placed fixes
in client.py. Four independent strong-model runs converged on contract compliance.
A wrong Work Order is most damaging exactly where executors are best; scope
correctness is the highest-leverage sembl improvement, full stop.

**The WO adds observable value where it is right.** Sembl arms added tests when raw
arms didn't (sonnet), followed report formats, ran broader suites, and stopped
cleanly on a broken environment instead of guessing (gpt-5.5-xhigh attempt 1).
Lock 6/8 effects are real and demonstrable.

**Weak models fabricate compliance.** qwen-sembl returned a complete, plausible,
entirely false WO-format report (named tests it never wrote, "pass" results it never
ran) — direct evidence that /sembl-validate must diff-check executor claims, never
trust self-reports.

**Task-selection lesson for tasks 002+:** this issue was too easy to localize (every
competent raw run found ssl_.py unaided), so the WO's scope value couldn't show up —
only its defects could. Pick issues where the fix file is NOT discoverable from the
error text (the SWE-rebench "issue-doesn't-name-the-file" criterion applies to demo
tasks too).

## Interim analysis (after the 6 Claude-tier runs)

1. **The task was too easy for the raw arm.** All three tiers found `httpie/ssl_.py`
   unaided; raw-haiku reproduced the reference fix exactly. On tasks where the issue
   text effectively names the subsystem, the WO's scope value cannot show up. Task
   selection for the demo must prefer issues where localization is genuinely hard.
2. **A wrong Work Order hurts MOST where models are strongest.** Compliance with the
   scope lock scaled with model strength: haiku ignored it, sonnet ignored it but
   followed the test-expectations, opus fully obeyed it and engineered a working fix
   inside the wrong boundary (+96 lines in client.py vs reference +7 in ssl_.py).
   Scope-lock correctness is therefore the single highest-leverage sembl improvement.
3. **The WO did add observable value beyond scope:** both sembl-arm sonnet/opus runs
   added regression tests (raw arms never did); reports followed the requested JSON
   format; opus-sembl ran the broader suite. Lock 6 (proof) and Lock 8 (reporting)
   demonstrably shape executor behavior.
4. **WO schema gaps found:** (a) no stop condition of the form "if the correct fix
   requires editing outside editable_paths, STOP and report" — agents either violated
   or tunneled; (b) editable_paths/forbidden_areas can contradict (httpie/__main__.py
   in both); (c) patch expectations demand test additions while no test path is
   editable.
5. **sembl 0.1.8 ranking bug (root cause of the wrong scope):** `_rank_editable_paths`
   promotes graph-central entry points over task-relevant files; `httpie/ssl_.py`
   reached files_to_inspect but never editable_paths, deterministically across
   generations and graph configurations.

## Remaining matrix

- fable raw/sembl: ON HOLD (owner decision 2026-06-11) until the WO schema is revised
  with the findings above; revisit then.
- All other planned runs complete (12/12 executed; gpt-5.3 unavailable, substituted
  gpt-5.5 medium per owner).
