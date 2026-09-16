# sfss_headless_cli

A minimal Ubuntu 24.04 headless development environment for C/C++ development through Docker.

The container is configured to run as **x86-64 (`linux/amd64`)**.

This is intentional because the module labs require an x86 environment. The development machine may be running on ARM64 hardware, such as an Apple Silicon Mac, but Docker runs the container as x86-64.

## Included

* **GCC / G++** — C and C++ compiler
* **GDB** — debugger
* **Clang / Clangd** — Clang compiler and C/C++ Language Server (LSP)
* **Neovim** — terminal-based editor
* **Git** — version control
* **Build tools** — basic C/C++ build environment
* **Tree-sitter CLI** — syntax parsing
* **ripgrep** — fast text searching
* **fd** — fast file searching
* **Docker CLI** — Docker command-line client

## Directory Structure

```text
sfss_headless_cli/
├── Dockerfile
├── README.md
└── nvim/
    └── init.lua
```

## Architecture

The container uses:

```text
linux/amd64
```

This provides an x86-64 Linux environment even when running Docker on an ARM64 machine.

For example, on an Apple Silicon Mac:

```text
Apple Silicon Mac
       │
       ▼
Docker Desktop
       │
       ▼
Ubuntu 24.04 x86-64
       │
       ├── GCC
       ├── GDB
       ├── Clang
       ├── Clangd
       └── Neovim
```

Docker Desktop provides the necessary emulation to run the x86-64 container.

## Dockerfile

The `Dockerfile` creates the Ubuntu 24.04 environment and installs the required development tools.

The main development packages are installed with:

```bash
apt-get install -y \
    gcc \
    g++ \
    build-essential \
    gdb \
    clang \
    clangd
```

## Neovim

Neovim is installed directly from the official Neovim release rather than Ubuntu's package repository.

The configuration is copied into:

```text
/root/.config/nvim/init.lua
```

The configuration uses Neovim's native `vim.pack` system to install its plugins.

## Clangd LSP

`clangd` provides C and C++ language-server functionality for Neovim.

The Neovim configuration enables only `clangd`:

```lua
vim.lsp.enable({
    "clangd",
})
```

This provides features such as:

* Code completion
* Diagnostics
* Go to definition
* Find references
* Symbol information
* Code formatting

No additional language servers or Mason are required.

## Building

Because the module labs require x86-64, explicitly build the image for `linux/amd64`.

From the directory containing the `Dockerfile`:

```bash
docker build --platform linux/amd64 -t sfss_headless_cli .
```

## Running

Run the container using the same x86-64 platform:

```bash
docker run --platform linux/amd64 -it --name sfss_headless_cli sfss_headless_cli
```

The container starts in:

```text
/workspace
```

Check the architecture with:

```bash
uname -m
```

It should output:

```text
x86_64
```

Neovim can then be launched with:

```bash
nvim
```

## Reopening the Container

After exiting the container:

```bash
docker start -ai sfss_headless_cli
```

The platform does not need to be specified when restarting an existing container.

## Rebuilding

If the `Dockerfile` or Neovim configuration changes, rebuild the image:

```bash
docker build --platform linux/amd64 -t sfss_headless_cli .
```

If a container with the same name already exists, remove it first:

```bash
docker rm -f sfss_headless_cli
```

Then create a new container:

```bash
docker run --platform linux/amd64 -it --name sfss_headless_cli sfss_headless_cli
```

