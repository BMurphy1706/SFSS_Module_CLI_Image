FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install core dev tools
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    gdb \
    clang \
    clangd \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Neovim (x86_64 build)
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && rm nvim-linux-x86_64.tar.gz \
    && ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# Optional: install tree-sitter CLI, ripgrep, fd if you have binaries or packages
# For now, keeping it minimal; add more installs here if needed.

# Neovim config
WORKDIR /workspace
COPY nvim /root/.config/nvim

# Code directory (mounted via volume in compose)
WORKDIR /root/code

# Default: start an interactive shell so the container stays alive.
# You can then compile/run/debug your program manually:
#   gcc -g test.c -o sfss_headless_cli
#   gdb ./sfss_headless_cli
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
