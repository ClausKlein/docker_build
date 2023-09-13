#### Base Image
FROM ubuntu:22.04 as setup-cpp-ubuntu

RUN apt-get update -qq && \
    # install nodejs
    apt-get install -y --no-install-recommends git nodejs npm && \
    # install setup-cpp
    npm install -g setup-cpp@v0.35.6 && \
    # install the compiler and tools
    setup-cpp \
        --nala true \
        --compiler gcc \
        --cmake true \
        --ninja true \
        --python true \
        --gcovr true && \
    # cleanup
    nala autoremove -y && \
    nala autopurge -y && \
    apt-get clean && \
    nala clean --lists && \
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
    && tar --exclude=cmake --exclude=pkgconfig -czvf stagedir.tar.gz stagedir/lib stagedir/bin'

ENTRYPOINT ["/bin/bash"]

#### Running environment
# use a fresh image as the runner
FROM ubuntu:22.04 as runner

# copy the built binaries and their runtime dependencies
COPY --from=builder /home/app/*.tar.gz /home/app/
WORKDIR /home/app/
RUN bash -c 'tar -xzvf stagedir.tar.gz --strip-components 1'
ENV LD_LIBRARY_PATH /home/app/lib

# Running (example):
ENTRYPOINT ["bin/Hello", "--help"]

# TODO: for (docker run -it):
# XXX ENTRYPOINT ["/bin/bash"]
