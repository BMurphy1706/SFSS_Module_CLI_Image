FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ==================================================
# Base development tools
# ==================================================

RUN apt-get update && apt-get install -y \
    bash \
    bash-completion \
    ca-certificates \
    curl \
    wget \
    git \
    unzip \
    zip \
    build-essential \
    gcc \
    g++ \
    make \
    gdb \
    clang \
    clangd \
    ripgrep \
    fd-find \
    tree \
    file \
    less \
    sudo \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*


# ==================================================
# Docker CLI
# ==================================================

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*


# ==================================================
# Neovim
# ==================================================

RUN cd /tmp && \
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar xzf nvim-linux-x86_64.tar.gz && \
    cp -r nvim-linux-x86_64/* /usr/local/ && \
    rm -rf nvim-linux-x86_64*


# ==================================================
# Tree-sitter CLI
# ==================================================

RUN cd /tmp && \
    curl -LO https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz && \
    gunzip tree-sitter-linux-x64.gz && \
    chmod +x tree-sitter-linux-x64 && \
    mv tree-sitter-linux-x64 /usr/local/bin/tree-sitter && \
    rm -f /tmp/tree-sitter-linux-x64


# ==================================================
# Shell configuration
# ==================================================

RUN echo 'export PATH="/usr/local/bin:$PATH"' >> /root/.bashrc && \
    echo "PS1='\\u@\\h:\\w \\$ '" >> /root/.bashrc && \
    echo 'alias ll="ls -lah"' >> /root/.bashrc && \
    echo 'alias la="ls -A"' >> /root/.bashrc && \
    echo 'alias l="ls -CF"' >> /root/.bashrc


# ==================================================
# Neovim configuration
# ==================================================

RUN mkdir -p /root/.config/nvim

COPY nvim/init.lua /root/.config/nvim/init.lua


# ==================================================
# Workspace
# ==================================================

WORKDIR /workspace


# ==================================================
# Start shell
# ==================================================

CMD ["/bin/bash"]
