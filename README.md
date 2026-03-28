# NyxGate

## Overview

NyxGate is a unified security and endpoint management platform built to give operators one control plane for host visibility, threat detection, response, and day-to-day security operations.

In practice, NyxGate combines:

- fleet inventory and host lifecycle management
- live host telemetry and network visibility
- threat detection and prevention controls
- firewall posture and policy operations
- patch visibility and patch execution
- audited remote terminal access

The platform is designed so an operator can move from fleet overview, to a suspicious host, to the exact process, service, connection, or response action without leaving the product.

---

## What NyxGate Covers

NyxGate is organized around a set of operator-facing workspaces:

- `Overview` for posture, attention items, and current operational priorities
- `Network` for topology and grouped network relationships
- `Agents` for endpoint inventory, enrollment, upgrade, restart, revoke, uninstall, isolation, and removal actions
- `Threats` for detections, prevention rules, blocked entities, and host isolation
- `Traffic` for grouped traffic review across hosts, processes, destinations, and exceptions
- `Monitoring` for fleet telemetry and host-level operational visibility
- `Risk` for ranked host prioritization with recommended actions
- `Insights` for plain-language threat narratives built from related activity
- `Firewall` for exposure review, policy management, and host firewall actions
- `Patching` for patch status, package deltas, update execution, and reboot actions
- `Terminal` for audited remote shell access to online hosts
- `Settings` for platform configuration, retention controls, users, roles, and audit review

This means "endpoint management" in NyxGate is not limited to inventory. It includes enrolling hosts, observing their operational state, applying security policy, patching them, isolating them when necessary, and opening a remote shell session when direct investigation is required.

---

## Endpoint Visibility

NyxGate gives operators both fleet-wide and host-specific context.

Across the platform, operators can review:

- host inventory with hostname, IP address, operating system, agent version, uptime, and last-seen status
- online, degraded, isolated, and upgrade-available host states
- host telemetry including CPU usage, memory pressure, active connection counts, and network throughput
- grouped network flows between managed hosts and remote destinations
- observed listening services and exposed ports
- process activity associated with network behavior
- recent alerts, L7 activity, and connection context on an individual host

The host investigation experience is especially detailed. For a selected host, NyxGate presents:

- host identity and current status
- CPU, memory, and network timelines
- risk score and risk breakdown
- active processes tied to observed network activity
- listening services
- grouped outbound and remote connection paths
- recent alerts and L7 activity
- patch status and last patch scan

This lets operators pivot from a fleet-level signal into a host-level evidence view without switching tools.

---

## Threat Detection

NyxGate implements concrete threat detection and prevention coverage rather than a generic alert feed.

The product includes detection support for:

- SSH brute force activity
- exposed service brute force activity
- port scanning
- reverse shell behavior
- crypto miner activity
- suspicious DNS activity
- threat intelligence matches

These detections surface in multiple places depending on workflow:

- the `Threats` workspace for correlated attack sessions and prevention activity
- the `Risk` queue when a host accumulates security, exposure, or patch-driven risk
- the `Insights` workspace when related detections, process activity, and network behavior are grouped into a plain-language story
- the `Monitoring` and `Host Investigation` views when operators need host context around a signal

NyxGate does not only show raw events. It also groups related detections into investigation lanes so operators can work from a higher-signal view of what is happening.

---

## Automated Response

NyxGate supports direct operator response and automated enforcement behaviors tied to prevention logic.

Available response actions in the product include:

- block an IP address
- block a domain
- kill a process
- isolate a host
- restore an isolated host
- unblock blocked entities
- extend block duration

These actions appear in the places where operators need them:

- from the `Threats` workspace while reviewing prevention events and blocked entities
- from the `Firewall` workspace while managing host posture or exposure
- from the `Overview` workspace when attention items suggest immediate action
- from host-focused workflows such as `Agents`, `Risk`, and `Host Investigation`

NyxGate also tracks blocked IPs and blocked domains as managed entities, with views for active blocks, expiration, scope, and cleanup actions.

---

## Prevention Rules Engine

NyxGate includes a real prevention rules engine with editable live rules and reusable templates.

Operators can work with:

- live prevention rules
- built-in rule templates
- custom saved templates
- enabled and disabled rule states
- thresholds
- time windows
- action selection
- severity selection
- scope selection

The rule system supports both single-trigger and grouped-trigger behavior. Operators can tune how a rule behaves by adjusting the trigger set, threshold, action, and severity, then enabling or disabling the rule as needed.

From the `Threats` workspace, operators can:

- review current prevention rules
- open a rule editor to adjust thresholds, templates, actions, severity, and mode
- create custom templates
- update existing templates
- remove templates

The product also exposes a template library around the implemented rule types, so common prevention patterns can be loaded into the rule editor instead of being rebuilt from scratch each time.

---

## Threats Workspace

The `Threats` workspace is where NyxGate brings together detections, prevention state, and containment controls.

Operators can work across:

- an IPS snapshot of prevented attacks, active rules, and current blocks
- an attack dashboard with correlated attack sessions
- a prevention rules view for live rule editing
- blocked entity management for IPs and domains
- host isolation controls for containment

What the operator sees here is action-oriented:

- correlated detections rather than isolated rows
- current block inventory
- rule tuning and template management
- host isolation and restore actions
- threat data cleanup for stored history when needed

This makes `Threats` the main workspace for reviewing what was detected, what was blocked, which rules are active, and what response should happen next.

---

## Traffic and Monitoring

NyxGate separates traffic analysis from general host monitoring so operators can choose the right lens for the task.

### Traffic Explorer

The `Traffic` workspace focuses on grouped traffic visibility and interpretation. Operators can review:

- grouped traffic by host, process, and destination
- throughput over the selected review window
- top destinations and host ownership
- process-driven traffic summaries
- exceptions such as new destinations, unknown destinations, and traffic requiring review

The page is designed to help operators answer practical questions such as:

- which process is generating this traffic
- which hosts are communicating with a destination
- whether a grouped pattern looks expected or unusual

### Monitoring

The `Monitoring` workspace focuses on host telemetry and operational state across time windows. It provides:

- fleet overview signals across the selected window
- sortable host monitoring tables
- CPU, memory, connection, and traffic filters
- grouped traffic intelligence
- anomaly tables
- quick pivots into host investigation

Together, `Traffic` and `Monitoring` give both network-centered and host-centered views of activity.

---

## Host Risk and Insights

NyxGate includes two operator workflows for prioritization and review.

### Host Risk

The `Risk` workspace ranks hosts by a real risk model built from:

- security detections
- exposed services and other exposure signals
- patch posture
- reboot-required state
- unusual outbound activity

For each host, operators can see:

- risk score
- risk level
- tags explaining why the host is ranked
- patch posture summary
- current workflow state
- recommended actions such as patching, firewall review, investigation, or isolation

### Insights

The `Insights` workspace turns related detections, process activity, and network behavior into plain-language stories.

Each story can include:

- affected hosts
- severity
- status such as ongoing or contained
- confidence
- key steps describing what NyxGate saw
- top evidence references
- defensive actions already correlated into the story window

This gives operators a narrative investigation surface for understanding related activity without reading a stream of disconnected events.

---

## Firewall Operations

NyxGate includes a dedicated firewall workspace for host posture, exposure review, and reusable policy management.

The `Firewall` workspace gives operators access to:

- firewall coverage and host posture across the fleet
- controller-wide firewall defaults and IPS posture
- host-level firewall state
- visible listening services reported by agents
- allowed ports and deny rules reported by hosts
- reusable firewall policy creation and editing
- policy assignment and unassignment across hosts
- remediation guidance for hosts with policy gaps or visible services

NyxGate distinguishes between what a firewall allows and what a host is actually listening on. That difference is visible in the interface, which helps operators review true exposure instead of assuming the allow list tells the whole story.

Operators can also run quick firewall actions and host isolation actions directly from this workspace while keeping the relevant host context visible.

---

## Patch Management

NyxGate includes patch visibility and patch execution across managed hosts.

The `Patching` workspace provides:

- fleet patch overview
- host patch status
- outdated and critical update counts
- reboot-required visibility
- last scan timestamps
- detailed package deltas on individual hosts
- patch scan actions
- apply-all update actions
- apply-security-only actions
- selected-package actions
- reboot actions for hosts that require it

For a focused host, operators can review the package list, inspect the latest patch result, and queue the next patch action directly from the same panel.

This makes patching part of the same operational workflow as threat response and host investigation rather than a separate silo.

---

## Agent Lifecycle Management

NyxGate includes a full `Agents` workspace for managed endpoint operations.

From this workspace, operators can:

- search and filter agent inventory
- review status, OS, version, and last-seen information
- generate enrollment tokens and installation commands
- use Linux, Docker, or manual install flows for new agents
- rename hosts
- remotely upgrade agents
- restart agents
- revoke agents
- remotely uninstall agents
- isolate hosts
- remove hosts from inventory
- run bulk actions across selected hosts

The install drawer generates token-based enrollment commands with configurable lifetime and enrollment limits, so onboarding can be controlled from the product interface.

---

## Remote Terminal

NyxGate includes an audited terminal workspace for direct host access over the control plane.

Operators with the right permissions can:

- select an online host
- open a shell session from the browser
- use a live terminal interface
- copy or download the terminal transcript
- close the session from the interface

This is intended for cases where operators need immediate host access while investigating or remediating an issue.

---

## Access Control and Setup

NyxGate uses a locked bootstrap flow before the main application becomes available.

On first access:

1. the platform redirects the user to `/setup`
2. an administrator account is created
3. recovery keys are generated and must be acknowledged
4. MFA setup is required before access is granted
5. exactly 8 backup codes are generated during MFA activation

Until setup is completed, the main application is not accessible.

After the initial bootstrap, the authentication flow supports:

- login by email or nickname
- MFA challenge during sign-in when required
- recovery-key-based password reset
- profile-level MFA setup, disable, and backup code regeneration

NyxGate also includes role-aware access across the platform, with dedicated user and role management inside `Settings`.

---

## Settings, Storage, and Audit

The `Settings` workspace includes the following sections:

- `General`
- `Agent Lifecycle`
- `Security`
- `Storage & Retention`
- `Users & Roles`
- `Audit Logs`

From these sections, operators can manage:

- general platform settings
- agent lifecycle defaults
- MFA policy
- retention settings for telemetry, flow history, alerts, firewall events, audit logs, and topology cache
- storage thresholds and cleanup behavior
- platform users and roles
- password reset and account status actions
- audit log filtering and purge actions

NyxGate also includes storage visibility features such as:

- storage overview
- free space and warning signals
- tracked data usage by category
- growth rate projections
- cleanup status

---

## Data Persistence

NyxGate stores persistent platform state in:

```text
/opt/nyxgate/data
```

This persistent data includes platform state such as:

- users and roles
- MFA data and backup codes
- prevention rules and rule templates
- blocked entities and host isolation state
- firewall policies and assignments
- patch posture and package inventory
- audit history
- platform settings
- retained telemetry and activity context

The product is designed so operational data survives restart, upgrade, and rebuild when the persistent volume is preserved.

---

## First Install

```bash
curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/install.sh | bash
```

After installation, access NyxGate at:

```text
https://<server-ip>:8443
```

---

## Upgrade

```bash
curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/upgrade.sh | bash
```

---

## Deployment Model

NyxGate is delivered as a Docker-based deployment with persistent storage mounted into the application runtime.

The production deployment model is built around:

- an isolated container runtime
- HTTPS access on port `8443`
- persistent application data under `/opt/nyxgate/data`
- repeatable install and upgrade flows

Production image:

```text
nyxmael/nyxgate:1.0.0
```

---

## Supported Distributions

NyxGate has been tested and is supported on the following systems:

### Ubuntu

- Ubuntu 22.04.5 LTS
- Ubuntu 24.04.4 LTS
- Ubuntu 25.04

### Debian

- Debian GNU/Linux 12 (bookworm)
- Debian GNU/Linux 13 (trixie)

### RHEL

- RHEL 10

---

## System Requirements

- 2 CPU minimum
- 4 GB RAM recommended
- Docker required

---

## Philosophy

NyxGate is designed around a practical operations model:

- keep the fleet visible
- reduce noisy, disconnected investigation work
- expose clear operator actions where the evidence already is
- treat security, endpoint state, patching, and response as connected workflows
- give operators a product they can navigate quickly under pressure

The result is a platform focused on clarity, actionability, and operational control rather than raw data volume alone.
