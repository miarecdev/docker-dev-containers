FROM rockylinux:8
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.29.0
ARG NINJA_VERSION=1.12.1
ARG VCPKG_COMMIT=29ff5b8131d0c6c8fcb8fbaef35992f0d507cd7c


# Enable "Powertools" repository,
# which includes developer tools like "libpcap-devel"

RUN dnf install -y 'dnf-command(config-manager)' && dnf -y clean all
RUN dnf config-manager --enable powertools

RUN dnf install -y \
   curl zip unzip tar \
   gcc gcc-c++ \
   gdb \
   valgrind \
   make automake libtool \
   flex bison \
   git \
   libpcap-devel \
   # Kernel headers (required for building openssl)
   kernel-headers \
   # Install perl with all its packages (required for OpenSSL compilation)
   perl \
   && \
  #
  # cleanup
  #
  dnf -y clean all && rm -rf /var/cache/yum

# Install cmake (detect architecture)
RUN ARCH=$(uname -m) && \
  curl -LO https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-${ARCH}.tar.gz \
  && tar -xzf cmake-${CMAKE_VERSION}-linux-${ARCH}.tar.gz -C /usr/local --strip-components=1 \
  && rm cmake-${CMAKE_VERSION}-linux-${ARCH}.tar.gz

# Install ninja build (detect architecture)
RUN ARCH=$(uname -m) && \
  if [ "$ARCH" = "x86_64" ]; then NINJA_ARCH="linux"; else NINJA_ARCH="linux-aarch64"; fi && \
  curl -LO https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-${NINJA_ARCH}.zip \
  && unzip ninja-${NINJA_ARCH}.zip -d /usr/local/bin \
  && rm ninja-${NINJA_ARCH}.zip


# Install clang-tidy for the clang-tidy quality gate in the CI lint steps
# (clang-tools-extra provides both clang-tidy and run-clang-tidy). The distro
# version is not pinned; the quality gate that enforces findings runs on the
# ubuntu-24.04 image, where the LLVM major is pinned.
RUN dnf install -y clang-tools-extra && dnf -y clean all

# Install vcpkg pinned to a known-good commit so a routine image rebuild cannot
# silently pick up incompatible vcpkg changes. The pin must be at or newer than
# the builtin baseline in the consuming project's vcpkg-configuration.json.
RUN mkdir -p /opt \
    && git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg \
    && cd /opt/vcpkg \
    && git checkout ${VCPKG_COMMIT} \
    && ./bootstrap-vcpkg.sh -disableMetrics

ENV VCPKG_INSTALLATION_ROOT=/opt/vcpkg
ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH="${PATH}:/opt/vcpkg"

# Fix issue "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

WORKDIR /data
CMD ["/bin/bash"]