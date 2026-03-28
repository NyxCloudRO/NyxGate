# NyxGate

## Overview

NyxGate is a Unified Security & Endpoint Management platform designed to give operators centralized control, visibility, and automated threat response across managed systems.

It is positioned as:

- a centralized security control plane
- an endpoint visibility platform
- an automated threat prevention system

NyxGate brings host awareness, threat detection, prevention policy, and operator response into a single operational surface. Instead of splitting endpoint visibility, security actions, and platform access across multiple disconnected tools, NyxGate gives teams one place to monitor managed systems, detect hostile activity, and take immediate action with confidence.

---

## Core Capabilities

### Endpoint Visibility

NyxGate provides centralized monitoring across managed hosts so operators can work from a unified, current view of their environment.

The platform is built to surface:

- centralized monitoring of hosts
- system-level visibility
- real-time host context such as CPU, memory, and active system activity

This allows teams to move quickly from high-level fleet awareness to host-specific understanding without losing operational continuity.

---

### Threat Detection

NyxGate continuously helps identify common and high-impact threat behaviors across managed systems.

Detection coverage includes:

- SSH brute force detection
- port scan detection
- reverse shell detection
- crypto miner detection
- suspicious DNS activity
- threat intelligence matching

This detection model is designed for practical security operations: focusing attention on hostile patterns that matter, reducing investigative delay, and improving operator response speed.

---

### Automated Response

NyxGate supports immediate security action when conditions require active enforcement.

Available response actions include:

- Block IP
- Kill process
- Block domain

The platform is designed around:

- automated enforcement
- real-time response
- severity-based actions

This helps teams shift from passive visibility to active protection, with actions aligned to the seriousness of the detected event and the prevention rules configured by the operator.

---

### Prevention Rules Engine

NyxGate includes a Prevention Rules engine that allows operators to define, manage, and tune enforcement behavior with clarity.

The engine is built around:

- a rule-based system
- thresholds and triggers
- severity levels
- templates
- per-rule enable, disable, and edit controls

This gives security teams a consistent way to express how the platform should react to specific conditions, while keeping rule management understandable and operationally practical.

---

### Security & Access Control

NyxGate starts from a secure bootstrap model so platform access is controlled from the first interaction.

The platform includes:

- enforced MFA at setup
- backup codes system
- secure bootstrap process
- controlled access to platform

This creates a safer operational baseline and helps ensure the management layer itself is protected before routine usage begins.

---

### Unified Control Interface

NyxGate is designed as a single interface for both security operations and endpoint management.

The user experience emphasizes:

- a unified interface for security and endpoint management
- a clean and operator-focused UI
- fast navigation and clarity

The result is an environment where teams can investigate, respond, and manage systems from one place without unnecessary tool switching or fragmented workflows.

---

## First Install

```bash
curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/install.sh | bash
```

---

## Access

```text
https://<server-ip>:8443
```

---

## Initial Setup

On first access, NyxGate redirects the operator to `/setup`.

The initial setup flow includes:

- admin account creation
- mandatory MFA activation
- generation of 8 backup codes

The platform remains locked until setup is fully completed. This ensures the management environment is secured before normal platform access is available.

---

## Data Persistence

NyxGate stores persistent platform data in:

```text
/opt/nyxgate/data
```

This data survives restart, upgrade, and rebuild.

Persistent platform data includes:

- users
- MFA data
- backup codes
- Prevention Rules
- platform settings

This model allows the platform to be upgraded and maintained without losing operational continuity or core security state.

---

## Upgrade

```bash
curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/upgrade.sh | bash
```

---

## System Requirements

- 2 CPU minimum
- 4GB RAM recommended
- Docker required

---

## Deployment Model

NyxGate is deployed in Docker as a production-ready runtime with persistent storage attached to the platform data path.

The deployment model is built around:

- Docker-based runtime delivery
- an isolated runtime environment
- persistent storage for long-lived platform state
- production-ready deployment practices

This keeps installation straightforward while supporting repeatable operations, controlled upgrades, and stable data retention.

---

## Production Image

```text
nyxmael/nyxgate:1.0.0
```

---

## Philosophy

NyxGate is built around a simple operational belief: security platforms should help teams see clearly, act decisively, and manage systems without unnecessary friction.

Its philosophy centers on:

- clarity over complexity
- operator-first design
- a unified security approach
- reducing noise and increasing visibility
- practical security for real environments

NyxGate aims to support real operators in real conditions by combining visibility, prevention, and control into a platform that stays focused on usefulness, speed, and confidence.
