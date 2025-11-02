FROM rockylinux:8
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.29.0
ARG NINJA_VERSION=1.11.1


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
   # perl packages are required for OpenSSL
   perl-IPC-Cmd \
   && \
  #
  # cleanup
  #
  dnf -y clean all && rm -rf /var/cache/yum

# Install cmake
RUN \
  curl -LO https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz \
  && tar -xzf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz -C /usr/local --strip-components=1 \
  && rm cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz 

# Install ninja build
RUN \
  curl -LO https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip \
  && unzip ninja-linux.zip -d /usr/local/bin \
  && rm ninja-linux.zip

# Install vcpkg
RUN mkdir -p /opt \
    && git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg \ 
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

ENV VCPKG_INSTALLATION_ROOT=/opt/vcpkg
ENV PATH="${PATH}:/opt/vcpkg"

# Fix issue "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

WORKDIR /data
CMD  /bin/bash