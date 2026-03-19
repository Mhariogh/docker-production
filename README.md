# Docker Mastery Assignment

This repository contains the Docker project for the Docker Mastery Assignment. The project demonstrates building, running, and deploying a Flask application using Docker, Docker Compose, and multiple container registries (DockerHub, GHCR, AWS ECR, and Azure ACR).

---

## Table of Contents
1. Project Overview
2. Technologies Used
3. Docker Images
4. Running the Project Locally
5. Challenges and Solutions
6. Screenshots


---

## Project Overview

This project is a **full-stack Flask application** that interacts with Redis and PostgreSQL. Docker was used to containerize each component to simplify deployment. GitHub Actions was configured to automatically build and push Docker images to GitHub Container Registry (GHCR).

---

## Technologies Used

- Docker  
- Docker Compose  
- Flask (Python)  
- Redis  
- PostgreSQL  
- GitHub Actions  
- AWS ECR  
- Azure Container Registry (Bonus)

---

## Docker Images

### 1. DockerHub Image
https://hub.docker.com/r/cwamie/flask-app

### 2. GHCR Image
ghcr.io/Mhariogh/flask-app:latest

### 3. AWS ECR Repository URI
901481721710.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest

### 4. Azure Container Registry (Bonus)
stephendockerassign.azurecr.io/flask-app:v1.0

---

## Running the Project Locally

To start the project locally, use Docker Compose
' docker compose up --build -d  '

This will:
Build all images
Start the Flask app, Redis, and PostgreSQL containers

Run in detached mode
To stop the project:
'docker compose down '


Challenges and Solutions

1. GitHub Actions Workflow Errors

Issue: Workflow failed to push images to GHCR due to incorrect repository naming.

Solution: Used ${{ github.repository_owner }} instead of hardcoding my username.

2. Docker Image Push Issues

Issue: Authentication errors while pushing to DockerHub.

Solution: Logged in using docker login with correct credentials.

3. AWS ECR Authentication

Issue: Docker could not authenticate to ECR.

Solution: Ran aws ecr get-login-password and piped it to docker login.

4. ACR Push Formatting Issues

Issue: Docker tag command formatting caused errors.

Solution: Ensured the full registry path was on a single line.
## Bonus D: .dockerignore
A `.dockerignore` file was created to exclude unnecessary files from the Docker build context. This reduces build time, decreases image size, and prevents sensitive files from being included.

| Pattern | Description | Reason for Exclusion |
|--------|-------------|----------------------|
| `__pycache__/`, `*.pyc`, `*.pyo` | Python cache files | Automatically generated and not required to run the application. |
| `venv/`, `env/` | Virtual environments | Dependencies will be installed using `requirements.txt`. |
| `.git`, `.gitignore` | Git repository files | Version control files not needed in the container. |
| `.dockerignore`, `Dockerfile` | Docker configuration files | Only needed during build, not inside the final image. |
| `*.swp`, `*.swo`, `.vscode/`, `.idea/` | IDE/editor files | Development environment files not required in production. |
| `.env` | Environment variables file | May contain sensitive data such as API keys or secrets. |

# part1
# Step 1.3 — Build and Compare
## Docker Image Size Comparison

| Version | Base Image         | Size   |
|---------|--------------------|--------|
| v2.0    | python:3.11-slim | 234MB  |
| v1.0    | python:3.11-alpine   |~105MB|



# part 3
# step 3.3
## Security Scanning

### v2.0 Scan Results
- Total: 5 (HIGH: 5, CRITICAL: 0)
- All vulnerabilities were in Python packages

### Fix Applied
- Updated base image: `python:3.11-slim` → `python:3.11-slim-bookworm`
- Added `apt-get upgrade` to apply OS patches
- Added `pip install --upgrade pip wheel` in builder stage

### v2.1 Scan Results
- Total: 9 (HIGH: 7, CRITICAL: 2)
- Python CVEs in `jaraco.context` and `wheel` persist because
  they are **vendored inside setuptools** and cannot be upgraded via pip
- OS CVEs (libc, sqlite, zlib) have **no upstream fix available yet**
  — status shown as "affected" or "will_not_fix" by Debian

### Why This Is Still Valid
The remaining vulnerabilities are **not fixable at this time** because:
1. Debian has not yet released patches for these OS-level CVEs
2. The vendored packages inside setuptools cannot be independently upgraded
3. This is a known limitation documented by the Trivy project

In a real production environment, these would be tracked and patched
as soon as upstream fixes become available.