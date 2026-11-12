## [Unreleased]

## [1.0.6] - 2026-11-04

- Added `nested` query support to the query DSL for fields mapped as the OpenSearch `nested` type
- Fixed config loading on Ruby 3.4+/4.0 (`require 'erb'`), guarded a missing `kaping.yml`, corrected `KAPING_*` environment overrides, and fixed the `logger=`/`log_level` methods
- Applied the configured log level to the default logger and made log-level precedence explicit (`KAPING_LOG_LEVEL` env > YAML > `INFO`)
- Clarified AWS credential errors: unrecognised `credential_type` and unresolved credentials now raise actionable messages
- Memorised the connected search client so credentials are resolved once per process, with optional client injection and `reset_client!`
- Simplified the `exists` query term to take a single field name (legacy two-argument form still accepted); removed unused constants

## [1.0.5] - 2025-11-10

- Fixed AWS credential handling to return proper credentials from assume role
- Added AWS credential chain and SSO documentation to README

## [1.0.4] - 2025-11-10

- Update gems and fixed issue with git actions

## [1.0.3] - 2025-09-03

- Moved runtime dependencies to the gemspec

## [1.0.2] - 2024-11-07

- Initial release

