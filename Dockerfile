# Force x86_64 architecture for 1:1 GNU/GCC parity
FROM --platform=linux/amd64 ubuntu:24.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install compilation, debugging, emulation utilities, git, python, and 32-bit multilib support
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    gdb \
    git \
    python3 \
    python3-pip \
    libc6-dev-i386 \
    gcc-multilib \
    g++-multilib \
    qemu-user \
    make \
    file \
    strace \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create helper scripts (Python-backed for null-byte / raw-byte payload support)
# ----------------------------------------------------------------------
# 32-Bit Toolchain Commands
RUN echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-build32 <file.c> [output_binary]"; exit 1; fi\nSRC=$1\nOUT=${2:-"${1\%.*}"}\ngcc -m32 -g -no-pie -fno-stack-protector -z execstack "$SRC" -o "$OUT"\necho "Built 32-bit $OUT successfully."' > /usr/local/bin/dbg-build32 && \
    echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-server32 <binary> [payload_args...]"; exit 1; fi\npkill -9 qemu-i386 2>/dev/null\nBIN="$1"\nshift\nif [ $# -gt 0 ]; then\n  python3 -c "import subprocess, sys; subprocess.run([\"qemu-i386\", \"-g\", \"1234\", \"$BIN\"] + [arg.encode(\"latin1\") for arg in sys.argv[1:]])" "$@"\nelse\n  qemu-i386 -g 1234 "$BIN"\nfi' > /usr/local/bin/dbg-server32 && \
    echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-client32 <binary>"; exit 1; fi\ngdb "$1" -ex "set disassembly-flavor intel" -ex "target remote :1234"' > /usr/local/bin/dbg-client32 && \
# 64-Bit Toolchain Commands
    echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-build64 <file.c> [output_binary]"; exit 1; fi\nSRC=$1\nOUT=${2:-"${1\%.*}"}\ngcc -m64 -g -no-pie -fno-stack-protector -z execstack "$SRC" -o "$OUT"\necho "Built 64-bit $OUT successfully."' > /usr/local/bin/dbg-build64 && \
    echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-server64 <binary> [payload_args...]"; exit 1; fi\npkill -9 qemu-x86_64 2>/dev/null\nBIN="$1"\nshift\nif [ $# -gt 0 ]; then\n  python3 -c "import subprocess, sys; subprocess.run([\"qemu-x86_64\", \"-g\", \"1234\", \"$BIN\"] + [arg.encode(\"latin1\") for arg in sys.argv[1:]])" "$@"\nelse\n  qemu-x86_64 -g 1234 "$BIN"\nfi' > /usr/local/bin/dbg-server64 && \
    echo '#!/bin/bash\nif [ -z "$1" ]; then echo "Usage: dbg-client64 <binary>"; exit 1; fi\ngdb "$1" -ex "set disassembly-flavor intel" -ex "target remote :1234"' > /usr/local/bin/dbg-client64 && \
# Backward Compatibility Aliases (Defaulting to 32-bit)
    echo '#!/bin/bash\ndbg-build32 "$@"' > /usr/local/bin/dbg-build && \
    echo '#!/bin/bash\ndbg-server32 "$@"' > /usr/local/bin/dbg-server && \
    echo '#!/bin/bash\ndbg-client32 "$@"' > /usr/local/bin/dbg-client && \
    chmod +x /usr/local/bin/dbg-*

# Code directory (mounted via volume in compose)
WORKDIR /root/code

CMD ["tail", "-f", "/dev/null"]
