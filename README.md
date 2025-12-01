# A collection of Docker images for development and testing


## Containers for C++ development

These containers include the commonly used C++ development tools such as CMake, G++, Ninja Build and vcpkg.

A primary use case for these containers is to build MiaRec recorder (C++ application) in GitHub Actions workflows.

- [centos7-cpp](centos7-cpp/Dockerfile): Centos 7 (DEPRECATED, not supported anymore because it cannot be run on Github Actions)
- [rockylinux8-cpp](rockylinux8-cpp/Dockerfile): Rocky Linux 8
- [rockylinux9-cpp](rockylinux9-cpp/Dockerfile): Rocky Linux 9
- [ubuntu20.04-cpp](ubuntu20.04-cpp/Dockerfile): Ubuntu 20.04
- [ubuntu22.04-cpp](ubuntu22.04-cpp/Dockerfile): Ubuntu 22.04
- [ubuntu24.04-cpp](ubuntu24.04-cpp/Dockerfile): Ubuntu 24.04


## Containers for testing

- [redis-tls](redis-tls/Dockerfile): Redis with TLS enabled for testing (see [README.md](redis-tls/README.md) for details)


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

Build the container locally with the desired tag:

    docker build -t miarec/rockylinux9-cpp:latest rockylinux9-cpp

Run the locally built container in the interactive mode:

    docker run -v `pwd`:/data -it miarec/rockylinux9-cpp:latest


## Upload to Docker Hub

Note, if you want to use these images from GitHub Actions, they are available from GitHub Container Registry as described above.

If you need these images on Docker Hub, you can push them there as follows.

Login to Docker Hub with your credentials

```bash
docker login
```

Build the container (as described above).

Push container to Docker Hub:

```bash
docker push miarec/centos7-cpp:latest
```

Run container from Docker Hub:

```bash
docker run -v `pwd`:/data -it miarec/centos7-cpp:latest
```

## Troubleshooting docker builds

Run docker build command with `DOCKER_BUILDKIT=0` to see docker image ids.

```bash
DOCKER_BUILDKIT=0 docker build -t miarec/centos7-cpp:latest centos7-cpp
```

You will see the image layer ids, like this:

```bash
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
```

You can now start a new container from any of these layers and investigate the filesystem:

```bash
$ docker run --rm 00f017a8c2a6 cat /tmp/foo.txt
cat: /tmp/foo.txt: No such file or directory
```

Of course you might want to start an interactive shell to explore the filesystem and try out commands:

```bash
$ docker run --rm -it 044e1532c690 sh      
/ # ls -l /tmp
total 4
-rw-r--r--    1 root     root             4 Mar  9 19:09 foo.txt
/ # cat /tmp/foo.txt 
foo
```
