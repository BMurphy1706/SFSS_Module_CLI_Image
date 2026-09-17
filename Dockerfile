# Force x86_64 architecture for 1:1 GNU/GCC parity
FROM --platform=linux/amd64 ubuntu:24.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install compilation, debugging, and emulation utilities
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    gdb \
    qemu-user \
    make \
    file \
    strace \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Create helper scripts for simplified workflow
RUN echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-build <file.c> [output_binary]"; exit 1; fi\nSRC=$1\nOUT=${2:-"${1\%.*}"}\ngcc -g -no-pie -fno-stack-protector -z execstack "$SRC" -o "$OUT"\necho "Built $OUT successfully."' > /usr/local/bin/dbg-build && \
    echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-server <binary>"; exit 1; fi\nqemu-x86_64 -g 1234 "$1"' > /usr/local/bin/dbg-server && \
    echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-client <binary>"; exit 1; fi\ngdb "$1" -ex "set disassembly-flavor intel" -ex "target remote :1234"' > /usr/local/bin/dbg-client && \
    chmod +x /usr/local/bin/dbg-build /usr/local/bin/dbg-server /usr/local/bin/dbg-client

WORKDIR /root/code

CMD ["bash"]
