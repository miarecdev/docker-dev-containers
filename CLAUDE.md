This file provides guidance to coding agent when working with code in this repository.

## Repository Purpose

This repository contains Docker images for:
- **C++ development**: Used to build the MiaRec recorder in GitHub Actions workflows. Images include CMake, G++, Ninja Build, and vcpkg.
- **Testing**: TLS-enabled containers (Redis, PostgreSQL) for local testing of secure connections.

## Build Commands

Build an image locally:
```bash
docker build -t ghcr.io/miarecdev/<image>:local <folder>
# Example:
docker build -t ghcr.io/miarecdev/rockylinux9-cpp:local rockylinux9-cpp
```

Run a built image:
```bash
docker run --rm -v "$PWD":/data -it ghcr.io/miarecdev/<image>:local /bin/bash
```

Troubleshoot build layers (see step-level image IDs):
```bash
DOCKER_BUILDKIT=0 docker build -t test <folder>
```

## Redis TLS Container

Uses a Makefile for certificate generation and container management:

```bash
cd redis-tls

# Generate certs, build, run, and test
make test

# Interactive redis-cli session
make cli

# Stop container
make stop
```

See [redis-tls/README.md](redis-tls/README.md) for all make targets and configuration options.

## PostgreSQL TLS Container

Uses a Makefile similar to redis-tls:

```bash
cd postgres-tls

# Generate certs, build, run, and test
make test

# Interactive psql session with SSL
make psql

# Stop container
make stop
```

See [postgres-tls/README.md](postgres-tls/README.md) for SSL modes and configuration options.

## Architecture

- **Distro folders** (`rockylinux8-cpp`, `rockylinux9-cpp`, `ubuntu20.04-cpp`, `ubuntu22.04-cpp`, `ubuntu24.04-cpp`): Each contains a single Dockerfile for that base image
- **redis-tls/**: Redis with TLS enabled for testing secure connections (Makefile-driven)
- **postgres-tls/**: PostgreSQL with TLS enabled for testing secure connections (Makefile-driven)
- **centos7-cpp/**: Deprecated, not supported on GitHub Actions runners

All C++ images follow the same structure:
1. Base OS setup and package manager configuration
2. Development tools installation (gcc, make, git, etc.)
3. CMake and Ninja installation from GitHub releases (versions pinned via ARGs)
4. vcpkg installation to `/opt/vcpkg` with `VCPKG_ROOT` and `VCPKG_INSTALLATION_ROOT` environment variables set

## CI/CD

GitHub Actions workflow (`.github/workflows/build-docker-images.yml`) automatically builds all C++ images on push to master:
- Builds for both **amd64** and **arm64** architectures
- Publishes architecture-specific tags (`ghcr.io/miarecdev/<image>:amd64`, `ghcr.io/miarecdev/<image>:arm64`)
- Creates multi-arch manifest at `ghcr.io/miarecdev/<image>:latest`

Note: TLS test containers (redis-tls, postgres-tls) are not built by CI; they are meant for local testing.

## Dockerfile Conventions

- Group instructions by phase (package installs, tooling, cleanup)
- Use uppercase for `ARG`/`ENV` names
- Clean package manager caches at end of install blocks (`dnf -y clean all`, `apt-get clean`)
- Include `org.opencontainers.image.source` label pointing to the GitHub repo
- Keep tool versions consistent across images when possible

## Testing Changes

**C++ images**: Before submitting changes:
1. Build the image locally
2. Verify it starts with `/bin/bash` and mounts `/data`
3. Smoke-test key tools: `cmake --version`, `ninja --version`, `git --version`, `vcpkg version`

**TLS test containers**: Use `make test` in the respective directory (redis-tls or postgres-tls) to verify the container works correctly.
