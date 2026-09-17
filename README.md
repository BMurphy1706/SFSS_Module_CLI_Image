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
├── compose.yml
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

The container’s default command is an interactive shell (`/bin/bash -l`) so the container stays alive and you can compile, run, and debug your programs manually.

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

From the directory containing the `Dockerfile` and `compose.yml`:

```bash
docker compose build
```

This uses the `platforms: [linux/amd64]` setting in `compose.yml`.

## Running

Start the environment with:

```bash
docker compose up
```

This:

- Builds (if needed) and starts the `linux-x86` service.
- Mounts the current directory into `/root/code` in the container.
- Drops you into an interactive shell at `/root/code`.

Inside the container:

```bash
# Check architecture
uname -m
# Expected: x86_64

# Compile your program (example)
gcc -g test.c -o sfss_headless_cli

# Run it
./sfss_headless_cli

# Debug it
gdb ./sfss_headless_cli
```

Neovim can be launched with:

```bash
nvim
```

Your host files are available under `/root/code`.

## Reopening the Container

After exiting the shell, the container remains created. To reattach:

```bash
docker compose start
docker compose exec linux-x86 bash
```

Or in one step:

```bash
docker compose exec linux-x86 bash
```

The platform does not need to be specified when using an existing container.

## Rebuilding

If the `Dockerfile`, `compose.yml`, or Neovim configuration changes, rebuild the image:

```bash
docker compose up --build
```

If you ever need to fully recreate the container:

```bash
docker compose down
docker compose up --build --force-recreate
```

## Using Docker CLI Directly (Optional)

You can still use plain `docker` commands if you prefer:

```bash
# Build
docker build --platform linux/amd64 -t sfss_headless_cli .

# Run with GDB-friendly options
docker run -it \
  --platform linux/amd64 \
  --cap-add SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --name sfss_headless_cli \
  -v "$PWD":/root/code \
  sfss_headless_cli
```

Inside, compile and debug as usual:

```bash
gcc -g test.c -o sfss_headless_cli
gdb ./sfss_headless_cli
```
