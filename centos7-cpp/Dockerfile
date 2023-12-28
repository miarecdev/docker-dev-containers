FROM centos:7

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.27.1
ARG NINJA_VERSION=1.11.1

RUN yum update -y && \
   yum install -y \
   centos-release-scl && \
  #
  # cleanup
  #
  yum -y clean all && rm -rf /var/cache/yum

# CAUTION! Do not use devtoolset-8 because it causes weird segmentation fault with -O2 is enabled

RUN yum install -y \
   curl zip unzip tar \
   devtoolset-7-gcc-c++ \
   devtoolset-7-gdb \
   devtoolset-7-valgrind \
   gcc-debuginfo \
   make automake libtool \
   flex bison \
   rh-git227-git \
   libpcap-devel \
   && \
  #
  # cleanup
  #
  yum -y clean all && rm -rf /var/cache/yum

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
    && source /opt/rh/rh-git227/enable \
    && git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg \ 
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH="${PATH}:/opt/vcpkg"

# Fix issue "detected dubious ownership in repository"
RUN source /opt/rh/rh-git227/enable \
    && git config --global --add safe.directory '*'

# Enable git 2.x from RH software collections for both login and non-login shells
# Some magic to fix the following issue with git:
#   /opt/rh/rh-git227/root/usr/libexec/git-core/git-remote-https: error while loading shared libraries: libcurl-httpd24.so.4: cannot open shared object file: No such file or directory
# SRC: https://github.com/apple/swift-docker/pull/306
RUN ln -s /opt/rh/rh-git227/enable /etc/profile.d/git.sh
ENV ENV=/etc/profile.d/git.sh
ENV BASH_ENV=$ENV

WORKDIR /data
CMD /bin/scl enable devtoolset-7 /bin/bash