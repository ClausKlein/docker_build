#### Base Image
FROM ubuntu:20.04 as setup-cpp-ubuntu

RUN apt-get update -qq && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends git wget gnupg ca-certificates && \
    # install setup-cpp
    wget --quiet "https://github.com/aminya/setup-cpp/releases/download/v0.35.6/setup-cpp-x64-linux" && \
    chmod +x setup-cpp-x64-linux && \
    # install the minmal compiler and tools set for build
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
    # install the C++ runtime libraries
    && mkdir -p stagedir/lib \
    && cp -f \
      /lib/x86_64-linux-gnu/libm.so* \
      /lib/x86_64-linux-gnu/libc.so* \
      /lib/x86_64-linux-gnu/libgcc_s.so* \
      /lib/x86_64-linux-gnu/libstdc++.so* \
    /home/app/stagedir/lib'

ENTRYPOINT ["/bin/bash"]

#### Running environment
# use a fresh image as the runner
FROM ubuntu:20.04 as runner

# copy the built binaries and their runtime dependencies
COPY --from=builder /home/app/*.tar.gz /home/app/
WORKDIR /home/app/
COPY --from=builder /home/app/stagedir stagedir
RUN bash -c 'tar -xzvf *.gz --strip-components 1'
ENV LD_LIBRARY_PATH /home/app/stagedir/lib

# Running (example):
ENTRYPOINT ["bin/Hello"]

# TODO: for (docker run -ti):
# XXX ENTRYPOINT ["/bin/bash"]

# root@b6fef6ed1368:/home/app# ldd bin/Hello
# 	linux-vdso.so.1 (0x00007ffdd6fed000)
# 	libfmt.so.10 => /home/app/stagedir/lib/libfmt.so.10 (0x00007f0084aea000)
# 	libc.so.6 => /home/app/stagedir/lib/libc.so.6 (0x00007f00848f8000)
# 	libstdc++.so.6 => /home/app/stagedir/lib/libstdc++.so.6 (0x00007f008468a000)
# 	libgcc_s.so.1 => /home/app/stagedir/lib/libgcc_s.so.1 (0x00007f0084665000)
# 	/lib64/ld-linux-x86-64.so.2 (0x00007f0084b1b000)
# 	libm.so.6 => /home/app/stagedir/lib/libm.so.6 (0x00007f0084516000)
# root@b6fef6ed1368:/home/app#
# root@b6fef6ed1368:/home/app# bin/Hello
# Hello, world!
# root@b6fef6ed1368:/home/app#
