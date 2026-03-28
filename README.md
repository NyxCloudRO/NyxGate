# NyxGate

NyxGate is a centralized firewall orchestration and threat response platform for real-time SOC operations.

## Product Overview

NyxGate gives security teams a single control surface for visibility, prevention, and response across managed hosts. It is designed for operators who need fast decision-making, clear host context, and dependable security controls in one interface.

## Key Features

- Real-time threat detection
- Prevention Rules engine for threats such as SSH brute force, port scan, reverse shell, crypto miner, and related hostile activity
- Automated response actions including block IP, kill process, and block domain
- Centralized visibility across hosts
- Security-first architecture
- Clean, operator-focused UI

## First Install

```bash
curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/install.sh | bash
```

## Access After Install

After installation, open:

```text
https://<server-ip>:8443
```

## First Setup Flow

On first access, NyxGate redirects to `/setup` and guides you through the initial security bootstrap:

- Create the administrator account
- Activate MFA
- Save the 8 generated backup codes

Until setup is completed, the main application is not accessible.

## System Requirements

- 2 CPU minimum
- 4 GB RAM recommended
- Docker required

## Data Persistence

NyxGate stores persistent runtime data in:

```text
/opt/nyxgate/data
```

This includes:

- Users
- MFA data and backup codes
- Prevention Rules
- Platform settings

## Upgrade

```bash
curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/upgrade.sh | bash
```

The upgrade process preserves persistent data and recreates the container with the latest production image.

## Repository Contents

- `install/install.sh` for first-time production installation
- `install/upgrade.sh` for safe in-place upgrades
- `CHANGELOG.md` for public release history

## Production Image

NyxGate v1.0.0 is published as:

```text
nyxmael/nyxgate:1.0.0
```
