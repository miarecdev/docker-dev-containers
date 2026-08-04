FROM ubuntu:22.04
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.29.0
ARG NINJA_VERSION=1.12.1
ARG LLVM_VERSION=21
ARG VCPKG_COMMIT=29ff5b8131d0c6c8fcb8fbaef35992f0d507cd7c

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
   apt-get install -y \
   curl zip unzip tar \
   gnupg \
   make automake autoconf libtool pkg-config \
   bison flex \
   gcc g++ \
   git \
   libpcap-dev \
   && \
  #
  # cleanup
  #
  rm -rf /var/lib/apt/lists/*

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


# Install clang-tidy (pinned LLVM major from apt.llvm.org) for the clang-tidy
# quality gate in the CI lint steps. run-clang-tidy ships in the same package;
# expose both without the version suffix.
RUN . /etc/os-release && \
  curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/${VERSION_CODENAME}/ llvm-toolchain-${VERSION_CODENAME}-${LLVM_VERSION} main" > /etc/apt/sources.list.d/llvm.list && \
  apt-get update -y && \
  apt-get install -y --no-install-recommends clang-tidy-${LLVM_VERSION} && \
  ln -s /usr/bin/clang-tidy-${LLVM_VERSION} /usr/local/bin/clang-tidy && \
  ln -s /usr/bin/run-clang-tidy-${LLVM_VERSION} /usr/local/bin/run-clang-tidy && \
  rm -rf /var/lib/apt/lists/*

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