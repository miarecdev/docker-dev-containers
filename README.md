# A collection of Docker images for development

## Containers for C++ development

These containers include commonly used C++ development tools such as CMake, G++, Ninja Build and vcpkg.

A primary use case for these containers is to build MiaRec recorder (C++ application) in GitHub Actions workflows.

- [centos7-cpp](centos7-cpp/Dockerfile): Centos 7 (DEPRECATED, not supported anymore because it cannot be run on Github Actions)
- [rockylinux8-cpp](rockylinux8-cpp/Dockerfile): Rocky Linux 8
- [rockylinux9-cpp](rockylinux9-cpp/Dockerfile): Rocky Linux 9
- [ubuntu20.04-cpp](ubuntu20.04-cpp/Dockerfile): Ubuntu 20.04
- [ubuntu22.04-cpp](ubuntu22.04-cpp/Dockerfile): Ubuntu 22.04
- [ubuntu24.04-cpp](ubuntu24.04-cpp/Dockerfile): Ubuntu 24.04
- [redis-tls](redis-tls/Dockerfile): Redis with TLS enabled for testing (see redis-tls/README.md)


## Usage via GitHub Container Registry

These docker images are automatically built using GitHub Action of this repo and pushed to GitHub Container Registry under the name `ghcr.io/miarec/{IMAGE_NAME}:latest` (replace `{IMAGE_NAME}` with the desired image name, for example, `ghcr.io/miarec/rockylinux9-cpp:latest`).

You can use these images in your GitHub Actions workflows as described below.

    jobs:
      build:
        runs-on: ubuntu-latest
        container:
          image: ghcr.io/miarec/rockylinux9-cpp:latest
        steps:
          # Your steps here

Example of a matrix build:

    jobs:
    build:
        runs-on: ${{ matrix.runner }}
        container:
        image: ${{ matrix.container || '' }}

        matrix:
            include:
            - name: ubuntu-24.04
                runner: ubuntu-latest
                container: ghcr.io/miarecdev/ubuntu24.04-cpp:latest
                distro: ubuntu
                cmake_preset: linux

            - name: rockylinux-9
                runner: ubuntu-latest
                container: ghcr.io/miarecdev/rockylinux9-cpp:latest
                distro: rocky
                cmake_preset: linux


## Build and run locally

Build the container locally:

    docker build -t miarec/rockylinux9-cpp:latest rockylinux9-cpp

Run the locally built container:

    docker run -v `pwd`:/data -it miarec/rockylinux9-cpp:latest

## Redis TLS test container

The `redis-tls` image bundles Redis configured for TLS so you can test secure connections locally. The image generates self-signed CA/server certificates during build, so you can run it without mounting anything:

    docker build -t ghcr.io/miarec/redis-tls:local redis-tls
    docker run --rm -p 6379:6379 ghcr.io/miarec/redis-tls:local

Mount custom certificates or reuse locally generated ones (for client-auth or verification):

    docker run --rm -p 6379:6379 -v "$(pwd)/redis-tls/certs:/tls" ghcr.io/miarec/redis-tls:local

Control TLS client authentication with `TLS_AUTH_CLIENTS` (defaults to `no`):

    docker run --rm -e TLS_AUTH_CLIENTS=yes -p 6379:6379 ghcr.io/miarec/redis-tls:local

Generate a client certificate signed by the CA (when using custom certs or client auth):

    ./redis-tls/generate_client_certs.sh --name app --output-dir ./redis-tls/certs

See `redis-tls/README.md` for additional usage notes.


## Upload to Docker Hub

Note, if you want to use these images from GitHub Actions, they are available from GitHub Container Registry as described above.

If you need these images on Docker Hub, you can push them there as follows.

Login to Docker Hub with your credentials

    docker login

Build the container (as described above).

Push container to Docker Hub:

    docker push miarec/centos7-cpp:latest

Run container from Docker Hub:

    docker run -v `pwd`:/data -it miarec/centos7-cpp:latest

## Troubleshooting docker builds

Run docker build command with `DOCKER_BUILDKIT=0` to see docker image ids.

    DOCKER_BUILDKIT=0 docker build -t miarec/centos7-cpp:latest centos7-cpp


You will see the image layer ids:

    $ DOCKER_BUILDKIT=0 docker build -t so-26220957 .
    Sending build context to Docker daemon 47.62 kB
    Step 1/3 : FROM busybox
    ---> 00f017a8c2a6
    Step 2/3 : RUN echo 'foo' > /tmp/foo.txt
    ---> Running in 4dbd01ebf27f
    ---> 044e1532c690
    Removing intermediate container 4dbd01ebf27f
    Step 3/3 : RUN echo 'bar' >> /tmp/foo.txt
    ---> Running in 74d81cb9d2b1
    ---> 5bd8172529c1
    Removing intermediate container 74d81cb9d2b1
    Successfully built 5bd8172529c1

You can now start a new container from 00f017a8c2a6, 044e1532c690 and 5bd8172529c1:

    $ docker run --rm 00f017a8c2a6 cat /tmp/foo.txt
    cat: /tmp/foo.txt: No such file or directory


of course you might want to start a shell to explore the filesystem and try out commands:

    $ docker run --rm -it 044e1532c690 sh      
    / # ls -l /tmp
    total 4
    -rw-r--r--    1 root     root             4 Mar  9 19:09 foo.txt
    / # cat /tmp/foo.txt 
    foo
