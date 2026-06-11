# Graph Impact Analysis - wo-httpiecli-1781196732-httpie-is-completely-broken-for-https-si

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: SSL/TLS verification logic in HTTP client code, likely tied to `requests` library usage.

**Likely edit targets**: `httpie/__main__.py`, `httpie/manager/__main__.py` (both contain `main()` and are central to CLI entry points).

**Hidden coupling / risk**: Shared SSL context configuration between CLI modules (edges show cross-imports). Changes may affect both entry points.

**Keep read-only**: `extras/packaging/linux/scripts/http_cli.py`, `extras/packaging/linux/scripts/httpie_cli.py` (packaging scripts, not core logic). Graph data lacks deeper dependency details-verify actual SSL code paths.
