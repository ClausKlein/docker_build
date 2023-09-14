#### Base Image
FROM ubuntu:20.04 as setup-cpp-ubuntu

RUN apt-get update -qq && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends git wget gnupg ca-certificates \
        libboost-serialization-dev libboost-thread-dev libsnmp-dev snmp snmp-mibs-downloader && \
    # install setup-cpp
    wget --quiet "https://github.com/aminya/setup-cpp/releases/download/v0.35.6/setup-cpp-x64-linux" && \
    chmod +x setup-cpp-x64-linux && \
    # install the minimal compiler and tools set for build
    ./setup-cpp-x64-linux \
        --compiler gcc \
        --cmake true \
        --ninja true \
        --python true && \
    # cleanup
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENTRYPOINT ["/bin/bash"]

#### Building (example)
FROM setup-cpp-ubuntu AS builder

COPY . /home/app
WORKDIR /home/app
RUN bash -c 'source ~/.cpprc \
    # build and install the C++ example
    && cmake --workflow --preset Release --fresh \
    && tar --exclude=cmake --exclude=pkgconfig --exclude="*.a" \
           -czvf stagedir.tar.gz stagedir/lib stagedir/bin'

ENTRYPOINT ["/bin/bash"]

#### Running environment
# use a fresh minimal image as the runner
# XXX FROM linuxmintd/mint20.1-amd64:latest as runner
FROM ubuntu:20.04 as runner

# copy the built binaries and their runtime dependencies
COPY --from=builder /home/app/*.tar.gz /home/app/
WORKDIR /home/app/
RUN bash -c 'tar -xzvf stagedir.tar.gz --strip-components 1'
ENV LD_LIBRARY_PATH /home/app/lib

# Running (example):
ENTRYPOINT ["bin/Hello", "--help"]

# TODO: for (docker run -it):
# XXX ENTRYPOINT ["/bin/bash"]
