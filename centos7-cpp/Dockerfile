FROM centos:7
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.29.0
ARG NINJA_VERSION=1.13.2


# Point to yum to vault.centos.org because mirror.centos.org is not available anymore (EOL)
RUN sed -i 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
   sed -i 's|^#\s*baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Update system packages
RUN yum update -y && \
   yum install -y \
   centos-release-scl && \
  #
  # cleanup
  #
  yum -y clean all && rm -rf /var/cache/yum

# Fix base url for CentOS-SCLo-scl-rh.repo and CentOS-SCLo-scl.repo (after installing centos-release-scl package)
RUN ARCH=$(uname -m) && \
   sed -i 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-SCLo-* && \
   sed -i 's|^#\s*baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-SCLo-* && \
   if [ "$ARCH" = "aarch64" ]; then \
      sed -i 's|vault.centos.org/centos/7/sclo|vault.centos.org/altarch/7/sclo|g' /etc/yum.repos.d/CentOS-SCLo-*; \
   fi

# CAUTION! Do not use devtoolset-8 because it causes weird segmentation fault with -O2 is enabled

RUN yum install -y \
   curl zip unzip tar \
   devtoolset-7-gcc-c++ \
   devtoolset-7-gdb \
   devtoolset-7-valgrind \
   glibc-common \
   make automake libtool \
   flex bison \
   rh-git227-git \
   libpcap-devel \
   # Kernel headers (required for building openssl)
   kernel-headers \
   # perl packages are required for OpenSSL
   perl-IPC-Cmd \
   && \
  localedef -i en_US -f UTF-8 en_US.UTF-8 && \
  #
  # cleanup
  #
  yum -y clean all && rm -rf /var/cache/yum

# Enable SCL toolsets for all shells
# SRC: https://github.com/sclorg/devtoolset-container
RUN printf 'source /opt/rh/devtoolset-7/enable\nsource /opt/rh/rh-git227/enable\n' > /etc/profile.d/scl_enable.sh
ENV BASH_ENV=/etc/profile.d/scl_enable.sh
ENV ENV=/etc/profile.d/scl_enable.sh
ENV PROMPT_COMMAND=". /etc/profile.d/scl_enable.sh"

SHELL ["/bin/bash", "-lc"]

# Install cmake (detect architecture)
RUN ARCH=$(uname -m) && \
  curl -LO https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-${ARCH}.tar.gz \
  && tar -xzf cmake-${CMAKE_VERSION}-linux-${ARCH}.tar.gz -C /usr/local --strip-components=1 \
  && rm cmake-${CMAKE_VERSION}-linux-${ARCH}.tar.gz

# Install ninja build from source to avoid libstdc++ ABI issues on CentOS 7
RUN curl -LO https://github.com/ninja-build/ninja/archive/refs/tags/v${NINJA_VERSION}.tar.gz \
  && tar -xzf v${NINJA_VERSION}.tar.gz \
  && cmake -S ninja-${NINJA_VERSION} -B ninja-build -DCMAKE_BUILD_TYPE=Release \
  && cmake --build ninja-build -- -j"$(nproc)" \
  && install -m 0755 ninja-build/ninja /usr/local/bin/ninja \
  && rm -rf ninja-build ninja-${NINJA_VERSION} v${NINJA_VERSION}.tar.gz

# Install vcpkg
RUN mkdir -p /opt \
    && git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg \ 
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

ENV VCPKG_INSTALLATION_ROOT=/opt/vcpkg
ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH="${PATH}:/opt/vcpkg"
ENV VCPKG_FORCE_SYSTEM_BINARIES=1
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8


# Fix issue "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

WORKDIR /data
CMD ["/bin/bash"]
