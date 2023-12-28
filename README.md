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
