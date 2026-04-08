# NyxGate Changelog

## v1.0.1

- Upgrade flow now checks Docker Hub for newer published releases before applying an update
- Upgrade path keeps persistent platform data in place and supports the legacy `1.0.0` migration into PostgreSQL and Redis Docker volumes
- Expanded `Threats` workspace with an IPS console, attack dashboard, editable live rules, blocked entity management, and host isolation controls
- Prevention rules engine improvements with reusable templates, custom saved templates, threshold tuning, grouped-trigger behavior, scope controls, and severity tuning
- Broader operator response coverage including IP blocking, domain blocking, process termination, host isolation, unblock actions, and block-duration extension
- Faster and clearer `Traffic` and `Monitoring` workflows with grouped traffic views, wider history-window support, anomaly tables, and better host pivots
- Improved network graph accuracy, clustering, and summary cards for real host-to-host and internet-facing traffic paths
- New `Risk` and `Insights` workflows for ranked host prioritization, recommended actions, and plain-language investigation stories
- Stronger `Firewall` operations with policy creation, cloning, assignment and unassignment, exposure review, and remediation guidance
- More complete patch-management workflows with fleet patch visibility, package deltas, apply-all and security-only actions, reboot controls, and better diagnostics
- Expanded agent lifecycle controls for token-based enrollment, remote upgrades, restarts, revocation, uninstalls, removals, isolation, and bulk actions
- Audited browser terminal access with live shell sessions plus transcript copy and download support
- Improved setup and access control with enforced MFA bootstrap, recovery-key flows, backup code management, and profile-level MFA actions
- Better storage and retention visibility with cleanup status, tracked usage, growth projections, and retention controls across key data categories
- Polished UI, release workflow, and day-to-day operator experience improvements across the platform

## v1.0.0

- Initial production release
- HTTPS deployment on port 8443
- First install setup flow with MFA and backup codes
- Prevention Rules engine
- Persistent data storage
