FROM rockylinux:9
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.29.0
ARG NINJA_VERSION=1.12.1


# Enable "Code Ready Builder" (CRB) repository,
# which includes developer tools like "libpcap-devel"

RUN dnf install -y 'dnf-command(config-manager)' && dnf -y clean all
RUN dnf config-manager --enable crb

RUN dnf install -y \
   zip unzip tar \
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