# NyxGate Changelog

## v1.0.2

- Bump the platform release metadata to `1.0.2`
- Update the dashboard footer to display `v1.0.2`
- Route overview exposure pivots into the `Firewall` workspace instead of `Risk`
- Fix host isolation state handling so containment now follows real agent acknowledgements instead of queued intent
- Prevent stale or ignored isolate commands from leaving ghost active isolation records
- Restore remote terminal `sudo` compatibility on hosts that do not have a native `sudo` package installed
- Improve remote terminal responsiveness by tightening the agent-side sudo warning filter and removing client-side terminal scroll delay
- Roll the bundled agent release forward to `0.4.109`

## v1.0.1

- Upgrade flow now checks for a newer published release automatically
- Upgrade path keeps persistent platform data in place
- MFA setup and login flow fixes
- Firewall policy cloning and remediation flow improvements
- Faster Traffic Explorer refresh when switching to wider history windows
- More accurate network graph visibility for real host and internet-facing traffic
- Cleaner network graph controls, clustering, and summary cards
- Storage retention and garbage-collection status improvements
- Better patch diagnostics with automatic recovery for common package permission issues
- Simplified Insights experience with clearer summaries and lighter visual noise
- Small UI and release workflow improvements
