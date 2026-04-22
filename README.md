# NyxGate

NyxGate is a unified security and endpoint management platform that combines host visibility, threat detection, prevention, firewall control, patching, risk review, and audited remote terminal access in a single control plane.

## Release

Current platform release: `1.0.3`

Published fresh-install image:

```text
nyxmael/nyxgate:1.0.3
```

## What NyxGate Includes

NyxGate is organized around operator-facing workspaces:

- `Overview` for live posture, immediate attention items, and current operational priorities
- `Network` for topology, grouped relationships, and controller-to-host visibility
- `Agents` for inventory, enrollment, upgrade, restart, revoke, uninstall, isolation, and removal actions
- `Threats` for detections, prevention rules, blocked entities, attack sessions, and host isolation
- `Traffic` for grouped traffic review across hosts, processes, destinations, and exceptions
- `Monitoring` for host telemetry, throughput, operational drift, and anomaly review
- `Risk` for ranked host prioritization with recommended actions
- `Insights` for grouped plain-language threat narratives
- `Firewall` for exposure review, host posture, and reusable policy operations
- `Patching` for patch inventory, execution, reboot requirements, and package deltas
- `Terminal` for audited remote shell access to online hosts
- `Settings` for users, roles, MFA policy, retention, storage, and audit review

## Core Capabilities

### Fleet and Host Visibility

Across the platform, operators can review:

- host inventory with hostname, IP address, operating system, uptime, version, and last-seen state
- online, degraded, isolated, and upgrade-available host states
- CPU, memory, active connection, and throughput telemetry
- grouped network flows and observed listening services
- process-linked traffic and recent security events
- host-specific patch, firewall, and risk context

### Threat Detection and Response

NyxGate includes concrete detection and prevention coverage for:

- SSH brute force
- exposed service brute force
- port scanning
- reverse shell behavior
- crypto miner behavior
- suspicious DNS activity
- threat intelligence matches

Available response actions include:

- block IP
- block domain
- kill process
- isolate host
- restore host access
- unblock managed blocks
- extend active block duration

### Firewall and Exposure Operations

The firewall workspace is built around real host posture, not just intended policy:

- exposed services and listening ports are shown separately from allow rules
- reusable firewall policies can be created, edited, assigned, and removed
- host-level actions, including isolation and restore, stay available in context
- overview exposure pivots now land in `Firewall`, which matches the operator workflow better than `Risk`

### Patch Management

NyxGate keeps patching in the same operational surface as investigation and response:

- fleet patch overview
- host patch status and reboot-needed visibility
- package delta review
- scan, apply-all, apply-security-only, selected-package, and reboot actions

### Audited Remote Terminal

NyxGate includes browser-based audited shell access for online hosts:

- live terminal session over the control plane
- transcript copy and download
- operator-scoped session ownership
- recent terminal fixes for `sudo` compatibility and lower-latency command rendering

## 1.0.3 Highlights

Release `1.0.3` adds a faster route from the NyxGate sidebar into the public support community while keeping the operator shell and workspace flow intact:

- A new `Community` shortcut now sits under `Support NyxGate` in the sidebar footer
- The `Community` entry opens `https://community.nyxcloud.ro/` directly in a new browser tab
- The new support-community action uses a green visual treatment so it stays distinct from the in-product support action
- The release keeps the recent `Firewall` routing, host restore fix, and terminal reliability improvements from `1.0.2`

See [CHANGELOG.md](/CHANGELOG.md) for the tracked platform release notes.

## Access Control and Bootstrap

On first access, NyxGate uses a locked setup flow:

1. the user is redirected to `/setup`
2. the first administrator account is created
3. recovery keys are generated and must be acknowledged
4. MFA setup is required before platform access is granted
5. backup codes are generated during MFA activation

After bootstrap, NyxGate supports:

- login by email or nickname
- MFA challenge on sign-in
- recovery-key-based password reset
- profile-level MFA setup, disable, and backup code regeneration
- role-aware access across the application

## Persistence Model

NyxGate preserves persistent state across:

```text
/opt/nyxgate/data
/opt/nyxgate/config
/opt/nyxgate/certs
/opt/nyxgate/secrets
docker volume: nyxgate-postgres-data
docker volume: nyxgate-redis-data
```

This covers platform data such as:

- users, roles, MFA state, and recovery material
- prevention rules and templates
- blocked entities and host isolation history
- firewall policies and assignments
- patch status and inventory
- audit logs
- retained telemetry and grouped operational context

## Fresh Install

The supported fresh-install path pulls the latest published NyxGate release from Docker Hub and provisions the runtime under `/opt/nyxgate`.

```bash
curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/install.sh | bash
```

The installer:

- installs Docker if needed
- creates the `/opt/nyxgate` layout
- creates persistent PostgreSQL and Redis Docker volumes
- writes the compose file for the published release image
- pulls the latest published tag from `nyxmael/nyxgate`
- starts NyxGate on `https://<server-ip>:8443`

If you want the image directly:

```bash
docker pull nyxmael/nyxgate:1.0.3
```

## Upgrade

```bash
curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/upgrade.sh | bash
```

The upgrade script:

- checks the latest published Docker Hub release
- compares it with the installed release marker
- preserves existing `/opt/nyxgate` data, config, certs, and secrets
- preserves the PostgreSQL and Redis volumes
- upgrades only when a newer published release exists

## Docker Deployment Model

NyxGate has two Docker-oriented deployment paths in this repository:

- fresh install / published runtime:
  uses the single-image runtime built from [Production/Dockerfile](/Production/Dockerfile) and published as `nyxmael/nyxgate:<release-tag>`
- local development:
  uses the split-stack compose topology in [deploy/docker-compose.yml](/deploy/docker-compose.yml)

For published releases, the runtime model is:

- HTTPS on port `8443`
- persistent platform files under `/opt/nyxgate`
- PostgreSQL data in `nyxgate-postgres-data`
- Redis data in `nyxgate-redis-data`

## Production Hotfix Workflow

When working from local code changes against an installed production stack, keep the runtime aligned with `/opt/nyxgate` and the official production compose layout.

Use:

```text
deploy/official-hotfix-deploy.sh
```

That workflow rebuilds the app image safely, recreates only the intended service, verifies health, and preserves live data.

## Supported Operating Systems

Fresh install currently supports:

- Ubuntu
- Debian

NyxGate agents and workflows have also been exercised on additional Linux targets, but the automated install script is explicitly written for Ubuntu and Debian.

## System Requirements

- 2 CPU minimum
- 4 GB RAM recommended
- Docker with Compose support
- outbound internet access for install and upgrade workflows

## Philosophy

NyxGate is designed around practical operator workflows:

- keep the fleet visible
- reduce disconnected investigation steps
- expose action where the evidence already is
- treat endpoint state, firewall posture, patching, and response as connected workflows
- make the system usable quickly under pressure

## Repository

GitHub:

```text
https://github.com/NyxCloudRO/NyxGate
```
