# Docker in Production Assignment

This repository contains the Docker in Production assignment. It demonstrates multi-stage builds, GitHub Actions CI/CD, container security scanning, multi-service orchestration with Docker Compose, and Prometheus/Grafana monitoring of a Flask application.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technologies Used](#technologies-used)
3. [GHCR Image URL](#ghcr-image-url)
4. [Image Size Comparison](#image-size-comparison)
5. [Trivy Scan Findings](#trivy-scan-findings)
6. [Start the Full Stack](#start-the-full-stack)
7. [Screenshots](#screenshots)
8. [Reflection](#reflection)

---

## Project Overview

A full-stack Flask application containerized with Docker, orchestrated with Docker Compose across 5 services (Flask, Redis, PostgreSQL, Prometheus, Grafana). GitHub Actions automates building and pushing images to GHCR on every push to main.

---

## Technologies Used

- Docker (multi-stage builds)
- Docker Compose
- Flask (Python)
- Redis
- PostgreSQL
- GitHub Actions (CI/CD)
- Prometheus (metrics + alerting)
- Grafana (dashboards)
- Trivy (container security scanning)
- GHCR (GitHub Container Registry)

---

## GHCR Image URL

The image is automatically built and pushed by the GitHub Actions pipeline:

```
ghcr.io/mhariogh/docker-production:latest
```

Pipeline file: `.github/workflows/docker-publish.yml`

---

## Image Size Comparison

Multi-stage builds significantly reduced the final image size by separating the build environment from the runtime environment:

| Version | Base Image | Size |
|---------|-----------|------|
| Assignment 1 (single-stage) | `python:3.11` | ~1.0GB |
| Assignment 2 v2.0 (multi-stage) | `python:3.11-slim` | 234MB |
| Assignment 2 v2.1 (optimised) | `python:3.11-alpine` | ~105MB |

**Reduction: ~77% smaller** compared to the original single-stage image.

---

## Trivy Scan Findings

### v2.0 Scan Results
- **Total: 5** (HIGH: 5, CRITICAL: 0)
- All vulnerabilities were in Python packages

### Fix Applied
- Updated base image: `python:3.11-slim` → `python:3.11-slim-bookworm`
- Added `apt-get upgrade` to apply OS-level patches
- Added `pip install --upgrade pip wheel` in the builder stage

### v2.1 Scan Results
- **Total: 9** (HIGH: 7, CRITICAL: 2)
- Python CVEs in `jaraco.context` and `wheel` persist because they are vendored inside `setuptools` and cannot be upgraded independently via pip
- OS-level CVEs (libc, sqlite, zlib) have no upstream fix available — status shown as `affected` or `will_not_fix` by Debian

### Why Remaining Vulnerabilities Are Acceptable
The remaining vulnerabilities are not fixable at this time because:
1. Debian has not yet released patches for these OS-level CVEs
2. Vendored packages inside setuptools cannot be independently upgraded
3. This is a known limitation documented by the Trivy project

In a real production environment, these would be tracked in a vulnerability register and patched as soon as upstream fixes become available.

---

## Start the Full Stack

Start all 5 services (Flask, Redis, PostgreSQL, Prometheus, Grafana):

```bash
make run
```

or

```bash
docker compose up --build -d
```

Stop the stack:

```bash
docker compose down
```

Services exposed:
| Service | URL |
|---------|-----|
| Flask app | http://localhost:5000 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |

Default Grafana login: `admin` / `admin`

---

## Screenshots

All screenshots are in the `screenshots/` folder:

| File | Description |
|------|-------------|
| `part1-multistage.png` | Multi-stage Dockerfile build output showing reduced image size |
| `part2-actions.png` | GitHub Actions workflow running successfully |
| `part2-ghcr.png` | Image pushed and visible in GitHub Container Registry |
| `part3-scan-before.png` | Trivy scan results before fixes |
| `part4-compose.png` | All 5 services running via `docker compose up` |
| `part4-gitignore.png` | `.gitignore` showing `.env` is excluded |
| `part5-stack.png` | Prometheus targets showing Flask app being scraped |
| `part5-grafana.png` | Grafana dashboard displaying Flask metrics |
| `bonus-alert.png` | Prometheus Alerts UI showing `FlaskAppDown` alert FIRING |

---

## Bonus Features

### Bonus C — Prometheus Alerting
An alerting rule was added to `prometheus.yml` that fires when the Flask app has been unreachable for more than 30 seconds:

```yaml
- alert: FlaskAppDown
  expr: up{job="flask_app"} == 0
  for: 30s
  labels:
    severity: critical
  annotations:
    summary: "Flask application is down"
    description: "The Flask app has been unreachable for more than 30 seconds."
```

See `bonus-alert.png` for the alert firing in the Prometheus UI.

### Bonus D — .dockerignore
A `.dockerignore` file excludes unnecessary files from the build context, reducing build time and preventing sensitive files from being included in the image.

| Pattern | Reason |
|---------|--------|
| `__pycache__/`, `*.pyc` | Auto-generated Python cache files |
| `venv/`, `env/` | Virtual environments — deps installed via `requirements.txt` |
| `.git`, `.gitignore` | Version control files not needed in container |
| `.env` | May contain sensitive secrets |
| `*.swp`, `.vscode/`, `.idea/` | IDE/editor files not needed in production |

---

## Reflection

**Hardest part:** The most challenging part was getting the Prometheus alerting rules to load correctly. The rule file was mounted under a different filename than what `prometheus.yml` referenced, causing "No rules found" to appear in the Alerts UI. Debugging required exec-ing into the container to inspect the actual mounted files and cross-referencing the `rule_files:` path. Additionally, switching from Docker Swarm (`overlay` network) to regular Docker Compose (`bridge` network) caused port conflicts that required identifying and removing lingering Swarm services.

**What I learned:**
- Multi-stage Docker builds can reduce image sizes by over 75%
- GitHub Actions makes CI/CD straightforward once secrets are configured correctly
- Trivy helps identify vulnerabilities but some CVEs are unfixable due to upstream dependencies
- Prometheus uses the built-in `up` metric to detect scrape failures, making it simple to alert on service downtime
- Docker Swarm and Docker Compose use incompatible network drivers and cannot share ports on the same host