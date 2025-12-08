FROM ubuntu:20.04
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.29.0
ARG NINJA_VERSION=1.12.1

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
   apt-get install -y \
   curl zip unzip tar \
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

# Install vcpkg
RUN mkdir -p /opt \
    && git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg \ 
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

ENV VCPKG_INSTALLATION_ROOT=/opt/vcpkg
ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH="${PATH}:/opt/vcpkg"


# Fix issue "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

WORKDIR /data
CMD ["/bin/bash"]