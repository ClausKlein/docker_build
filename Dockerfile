#### Base Image
FROM ubuntu:22.04 as setup-cpp-ubuntu

RUN apt-get update -qq && \
    # install nodejs
    apt-get install -y --no-install-recommends git nodejs npm && \
    # install setup-cpp
    npm install -g setup-cpp@v0.35.4 && \
    # install the compiler and tools
    setup-cpp \
        --nala true \
        --compiler gcc \
        --cmake true \
        --ninja true \
        --python true \
        --make true \
        --gcovr true \
        --doxygen true \
        --ccache true && \
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
    && cmake --workflow --preset Release --fresh \
    && mkdir -p stagedir/lib \
    && cp \
      /lib/x86_64-linux-gnu/libm.so* \
      /lib/x86_64-linux-gnu/libc.so* \
      /lib/x86_64-linux-gnu/libgcc_s.so* \
      /lib/x86_64-linux-gnu/libstdc++.so* \
    /home/app/stagedir/lib'

ENTRYPOINT ["/bin/bash"]

#### Running environment
# use a fresh image as the runner
FROM ubuntu:22.04 as runner

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

# root@106b5efb0b5e:/home/app# ldd bin/Hello
# 	linux-vdso.so.1 (0x00007ffc9d3a6000)
# 	libfmt.so.10 => /home/app/stagedir/lib/libfmt.so.10 (0x00007f902a1f4000)
# 	libc.so.6 => /home/app/stagedir/lib/libc.so.6 (0x00007f9029fcc000)
# 	libstdc++.so.6 => /home/app/stagedir/lib/libstdc++.so.6 (0x00007f9029d5f000)
# 	libgcc_s.so.1 => /home/app/stagedir/lib/libgcc_s.so.1 (0x00007f9029d3b000)
# 	/lib64/ld-linux-x86-64.so.2 (0x00007f902a225000)
# 	libm.so.6 => /home/app/stagedir/lib/libm.so.6 (0x00007f9029c54000)
# root@106b5efb0b5e:/home/app# bin/Hello
# Hello, world!
# root@106b5efb0b5e:/home/app#
