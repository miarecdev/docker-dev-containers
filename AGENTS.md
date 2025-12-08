# Repository Guidelines

## Project Structure & Module Organization
- Each distro folder (`rockylinux8-cpp`, `rockylinux9-cpp`, `ubuntu20.04-cpp`, `ubuntu22.04-cpp`, `ubuntu24.04-cpp`) contains a single `Dockerfile` for that base image. Keep tooling aligned across images unless a distro requires special handling.
- `README.md` documents usage and registry locations. Add platform-specific notes near the relevant distro folder and update the README when behavior changes.
- Keep shared patterns (labels, env vars, installed tools) consistent between Dockerfiles to minimize divergence.

## Build, Test, and Development Commands
- Build an image locally: `docker build -t ghcr.io/miarec/<image>:local <folder>` (e.g., `docker build -t ghcr.io/miarec/rockylinux9-cpp:local rockylinux9-cpp`).
- Run a built image: `docker run --rm -v "$PWD":/data -it ghcr.io/miarec/<image>:local /bin/bash`.
- Troubleshoot layers: `DOCKER_BUILDKIT=0 docker build -t test <folder>` to see step-level image IDs.
- Publish (if needed): `docker push ghcr.io/miarec/<image>:tag`; verify tags match the folder name and base distro.

## Coding Style & Naming Conventions
- Dockerfiles: keep instructions grouped (package installs, tooling installs, cleanup). Use uppercase for `ARG`/`ENV` names and lowercase image tags matching folder names.
- Prefer one `RUN` block per logical phase with cleanup (`dnf/yum/apt clean`, remove caches) to keep images lean.
- Add labels (`org.opencontainers.image.source`) and environment variables (`VCPKG_ROOT`, `VCPKG_INSTALLATION_ROOT`) consistently across images.

## Testing Guidelines
- Build locally before proposing changes; ensure the image starts with `/bin/bash` and mounts `/data`.
- Smoke-test key tools inside the container, e.g., `cmake --version`, `ninja --version`, `git --version`, and `vcpkg version`.
- For dependency bumps, note tested versions and any distro-specific quirks in the PR description.

## Commit & Pull Request Guidelines
- Commit messages follow short, imperative-style sentences (see history: “Install all perl packages…”, “Add Ubuntu 24.04”). Scope the subject to one change.
- PRs should include: summary of changes, target distro folders, build/test commands run with outcomes, and any registry tags affected. Link related issues or workflows when applicable.
- When adding a new image variant, mirror structure from the closest existing distro and document usage in `README.md`.

## Security & Configuration Tips
- Avoid embedding secrets or credentials in Dockerfiles; rely on runtime configuration or secrets in CI.
- Use official mirrors and pinned versions (`ARG CMAKE_VERSION`, `ARG NINJA_VERSION`) where possible; update all images together to keep parity.
