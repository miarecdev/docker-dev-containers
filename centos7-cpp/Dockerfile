FROM centos:7
LABEL org.opencontainers.image.source="https://github.com/miarecdev/docker-dev-containers"

LABEL "maintainer"="MiaRec dev@miarec.com"

ARG CMAKE_VERSION=3.29.0
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
   # perl packages are required for OpenSSL
   perl-FindBin perl-IPC-Cmd \
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

ENV VCPKG_INSTALLATION_ROOT=/opt/vcpkg
ENV PATH="${PATH}:/opt/vcpkg"

# Enable rh-git227
# Copy/paste code from /opt/rh/rh-git227/enable
ENV PATH=/opt/rh/rh-git227/root/usr/bin${PATH:+:${PATH}}
ENV MANPATH=/opt/rh/rh-git227/root/usr/share/man:${MANPATH}
ENV PERL5LIB=/opt/rh/rh-git227/root/usr/share/perl5/vendor_perl${PERL5LIB:+:${PERL5LIB}}
ENV LD_LIBRARY_PATH=/opt/rh/httpd24/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Enable devtoolset-7
# Copy/paste code from /opt/rh/devtoolset-7/enable
ENV PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}}
ENV MANPATH=/opt/rh/devtoolset-7/root/usr/share/man:${MANPATH}
ENV INFOPATH=/opt/rh/devtoolset-7/root/usr/share/info${INFOPATH:+:${INFOPATH}}
ENV PCP_DIR=/opt/rh/devtoolset-7/root
# Some perl Ext::MakeMaker versions install things under /usr/lib/perl5
# even though the system otherwise would go to /usr/lib64/perl5.
ENV PERL5LIB=/opt/rh/devtoolset-7/root//usr/lib64/perl5/vendor_perl:/opt/rh/devtoolset-7/root/usr/lib/perl5:/opt/rh/devtoolset-7/root//usr/share/perl5/vendor_perl${PERL5LIB:+:${PERL5LIB}}

ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root$rpmlibdir$rpmlibdir32${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root$rpmlibdir$rpmlibdir32:/opt/rh/devtoolset-7/root$rpmlibdir/dyninst$rpmlibdir32/dyninst${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}       
# duplicate python site.py logic for sitepackages
ENV PYTHONPATH=/opt/rh/devtoolset-7/root/usr/lib64/python2.7/site-packages:/opt/rh/devtoolset-7/root/usr/lib/python2.7/site-packages${PYTHONPATH:+:${PYTHONPATH}}


# Fix issue "detected dubious ownership in repository"
RUN git config --global --add safe.directory '*'

WORKDIR /data
CMD  /bin/bash