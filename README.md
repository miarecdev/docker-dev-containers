# A collection of Docker images for development


# Containers for C++ development

- [centos7-cpp](centos7-cpp/Dockerfile): includes CMake, G++, Ninja Build and vcpkg


# Build and run locally

Build the container locally:

    docker build -t miarec/centos7-cpp:latest centos7-cpp

Run the locally built container:

    docker run -v `pwd`:/data -it miarec/centos7-cpp:latest


# Upload to Docker Hub


Login to Docker Hub with your credentials

    docker login

Build the container (as described above).

Push container to Docker Hub:

    docker push miarec/centos7-cpp:latest

Run container from Docker Hub:

    docker run -v `pwd`:/data -it miarec/centos7-cpp:latest

# Troubleshooting docker builds

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