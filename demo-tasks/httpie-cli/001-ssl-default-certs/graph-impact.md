# Graph Impact Analysis - wo-httpiecli-1781186027-httpie-is-completely-broken-for-https-si

_LLM synthesis over code-review-graph structural output. Grounds the Work Order's scope, read-only context, and risk._

---

**Blast radius**: SSL/TLS verification logic in HTTP client code, likely tied to `requests` library usage.

**Likely edit targets**: `httpie/__main__.py` (entry point), `httpie/manager/__main__.py` (CLI manager). These contain `main()` functions and may initialize HTTP clients or SSL contexts.

**Hidden coupling / risk**: Shared SSL context configuration between CLI components. `requests` 2.32.3 changes may break implicit system cert trust; any custom SSL context setup in these files could conflict.

**Keep read-only**: `extras/packaging/linux/scripts/http_cli.py`, `httpie_cli.py` (packaging scripts, not core logic). Docs (`docs/README.md`) are context only.
