# Security Policy

## Reporting a vulnerability

Please report suspected vulnerabilities privately via
[GitHub Security Advisories](https://github.com/speedvibecode/sembl/security/advisories/new)
(preferred) or by email to totlasiddharth@gmail.com. Do not open a public issue for
security reports.

You can expect an acknowledgement within a few days. Please include a reproduction
if you can.

## Scope notes

Sembl is a **local-first CLI and MCP server**: it runs on the operator's machine with
the operator's own file access, judging diffs against bounds contracts. There is no
hosted service. The surfaces we care most about:

- **Contract integrity** — the gate must not be circumventable by the diff it judges
  (e.g. a diff that edits the contract file itself is BLOCKed; paths are
  traversal-safe).
- **Deterministic verdicts** — identical inputs must always produce identical
  PASS/WARN/BLOCK results.
- **Release integrity** — PyPI publishing uses Trusted Publishing (OIDC, no stored
  tokens).

Reports in any of these areas are especially appreciated.
