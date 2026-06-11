# Graph Impact Analysis - wo-httpiecli-1781163174-httpie-is-completely-broken-for-https-si

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: SSL/TLS verification in HTTPS requests via the `requests` library dependency.

**Likely edit targets**: No specific files identified in graph data.

**Hidden coupling / risk**: None detected in provided graph.

**Keep read-only**: `docs/README.md`, `extras/packaging/linux/scripts/http_cli.py`, `httpie/__main__.py` (contextual but not modified per graph).
