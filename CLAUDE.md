# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository contains Docker images for C++ development, primarily used to build the MiaRec recorder in GitHub Actions workflows. Images include CMake, G++, Ninja Build, and vcpkg.

## Build Commands

Build an image locally:
```bash
docker build -t ghcr.io/miarec/<image>:local <folder>
# Example:
docker build -t ghcr.io/miarec/rockylinux9-cpp:local rockylinux9-cpp
```

Run a built image:
```bash
docker run --rm -v "$PWD":/data -it ghcr.io/miarec/<image>:local /bin/bash
```

Troubleshoot build layers (see step-level image IDs):
```bash
DOCKER_BUILDKIT=0 docker build -t test <folder>
```

## Redis TLS Container

Generate certificates before building:
```bash
./redis-tls/generate_certificates.sh
```

Build and run:
```bash
docker build -t ghcr.io/miarec/redis-tls:local redis-tls
docker run --rm -p 6379:6379 -v "$(pwd)/redis-tls/certs:/tls" ghcr.io/miarec/redis-tls:local
```

Generate client certificates:
```bash
./redis-tls/generate_client_certs.sh --name app --output-dir ./redis-tls/certs
```

## Architecture

- **Distro folders** (`rockylinux8-cpp`, `rockylinux9-cpp`, `ubuntu20.04-cpp`, `ubuntu22.04-cpp`, `ubuntu24.04-cpp`): Each contains a single Dockerfile for that base image
- **redis-tls/**: Redis with TLS enabled for testing secure connections
- **centos7-cpp/**: Deprecated, not supported on GitHub Actions runners

All C++ images follow the same structure:
1. Base OS setup and package manager configuration
2. Development tools installation (gcc, make, git, etc.)
3. CMake and Ninja installation from GitHub releases (versions pinned via ARGs)
4. vcpkg installation to `/opt/vcpkg` with `VCPKG_ROOT` and `VCPKG_INSTALLATION_ROOT` environment variables set

## CI/CD

GitHub Actions workflow (`.github/workflows/build-docker-images.yml`) automatically builds all images on push to master and publishes to GitHub Container Registry at `ghcr.io/miarec/<image>:latest`.

## Dockerfile Conventions

- Group instructions by phase (package installs, tooling, cleanup)
- Use uppercase for `ARG`/`ENV` names
- Clean package manager caches at end of install blocks (`dnf -y clean all`, `apt-get clean`)
- Include `org.opencontainers.image.source` label pointing to the GitHub repo
- Keep tool versions consistent across images when possible

## Testing Changes

Before submitting changes:
1. Build the image locally
2. Verify it starts with `/bin/bash` and mounts `/data`
3. Smoke-test key tools: `cmake --version`, `ninja --version`, `git --version`, `vcpkg version`
