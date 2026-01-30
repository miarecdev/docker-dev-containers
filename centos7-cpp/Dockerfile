FROM centos:7
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.29.0
ARG NINJA_VERSION=1.12.1


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
   # perl packages are required for OpenSSL
   perl-IPC-Cmd \
   && \
  localedef -i en_US -f UTF-8 en_US.UTF-8 && \
  #
  # cleanup
  #
  yum -y clean all && rm -rf /var/cache/yum

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
    && source /opt/rh/rh-git227/enable \
    && git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg \ 
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

ENV VCPKG_INSTALLATION_ROOT=/opt/vcpkg
ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH="${PATH}:/opt/vcpkg"
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV MANPATH=
ENV PERL5LIB=
ENV LD_LIBRARY_PATH=
ENV INFOPATH=
ENV PYTHONPATH=
ENV rpmlibdir=/usr/lib64
ENV rpmlibdir32=/usr/lib

# Enable rh-git227
# Copy/paste code from /opt/rh/rh-git227/enable
ENV PATH=/opt/rh/rh-git227/root/usr/bin${PATH:+:${PATH}}
ENV MANPATH=/opt/rh/rh-git227/root/usr/share/man${MANPATH:+:${MANPATH}}
ENV PERL5LIB=/opt/rh/rh-git227/root/usr/share/perl5/vendor_perl${PERL5LIB:+:${PERL5LIB}}
ENV LD_LIBRARY_PATH=/opt/rh/httpd24/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Enable devtoolset-7
# Copy/paste code from /opt/rh/devtoolset-7/enable
ENV PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}}
ENV MANPATH=/opt/rh/devtoolset-7/root/usr/share/man${MANPATH:+:${MANPATH}}
ENV INFOPATH=/opt/rh/devtoolset-7/root/usr/share/info${INFOPATH:+:${INFOPATH}}
ENV PCP_DIR=/opt/rh/devtoolset-7/root
# Some perl Ext::MakeMaker versions install things under /usr/lib/perl5
# even though the system otherwise would go to /usr/lib64/perl5.
ENV PERL5LIB=/opt/rh/devtoolset-7/root//usr/lib64/perl5/vendor_perl:/opt/rh/devtoolset-7/root/usr/lib/perl5:/opt/rh/devtoolset-7/root//usr/share/perl5/vendor_perl${PERL5LIB:+:${PERL5LIB}}

ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root${rpmlibdir}:/opt/rh/devtoolset-7/root${rpmlibdir32}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root${rpmlibdir}:/opt/rh/devtoolset-7/root${rpmlibdir32}:/opt/rh/devtoolset-7/root${rpmlibdir}/dyninst:/opt/rh/devtoolset-7/root${rpmlibdir32}/dyninst${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# duplicate python site.py logic for sitepackages
ENV PYTHONPATH=/opt/rh/devtoolset-7/root/usr/lib64/python2.7/site-packages:/opt/rh/devtoolset-7/root/usr/lib/python2.7/site-packages${PYTHONPATH:+:${PYTHONPATH}}


# Fix issue "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

WORKDIR /data
CMD ["/bin/bash"]
