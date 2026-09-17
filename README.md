# sfss_headless_cli

A minimal Ubuntu 24.04 headless development and debugging environment for C/C++ through Docker.

The container runs as **x86-64 (`linux/amd64`)**.

This setup is required because the module labs require an x86 environment and standard Rosetta 2 emulation blocks native Linux `ptrace` system calls (such as `PTRACE_GETREGS`). To bypass this, the environment pairs GDB with QEMU user-mode emulation.

## Included

* **GCC / G++** — C and C++ compiler
* **GDB** — debugger
* **QEMU User Emulation (`qemu-user`)** — x86_64 GDB server stub
* **Git** — version control
* **Build tools** — basic C/C++ build environment
* **ripgrep** — fast text searching
* **fd** — fast file searching
* **Docker CLI** — Docker command-line client
* **Helper CLI Scripts** — `dbg-build`, `dbg-server`, `dbg-client`

## Directory Structure

```text
sfss_headless_cli/
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Architecture

The container uses:

```text
linux/amd64

Host (Apple Silicon Mac / Linux / Windows)
       │
       ▼
Docker Container (sfss_headless_cli)
       │
       ├── Terminal 1: QEMU GDB Stub (qemu-x86_64 -g 1234)
       │                     ▲
       │                     │ TCP :1234
       │                     ▼
       └── Terminal 2: GDB Client (gdb ./binary)
```

## Dockerfile

The `Dockerfile` builds the Ubuntu 24.04 environment, installs compilation and debugging tools (including `qemu-user`), and configures helper scripts.

Packages installed include:

```bash
apt-get install -y \
    gcc \
    g++ \
    gdb \
    qemu-user \
    make \
    file \
    strace
```

## Building

Explicitly build the image for `linux/amd64`.

From the directory containing `Dockerfile` and `docker-compose.yml`:

```bash
docker compose build
```

## Running

Start the container environment in the background:

```bash
docker compose up -d
```

### Terminal 1: Compile & Start Debug Server

```bash
docker exec -it sfss_headless_cli bash

# Compile test.c into a binary named 'test'
dbg-build test.c

# Start the QEMU GDB stub (waits for connection on port 1234)
dbg-server test
```

### Terminal 2: Connect GDB Client

```bash
docker exec -it sfss_headless_cli bash

# Attach GDB to the running QEMU server
dbg-client test
```

## GDB Commands

* `(gdb) break main`
* `(gdb) continue`
* `(gdb) disassemble main`

## Helper Script Details

### `dbg-build`

Command:

```bash
gcc -g -no-pie -fno-stack-protector -z execstack "$SRC" -o "$OUT"
```

Purpose: Compiles C source files with standard binary exploitation and debugging flags enabled.

Flag breakdown:

* `-g`: Includes debugging symbols in the compiled ELF binary so GDB can resolve function names, line numbers, and variable names.
* `-no-pie`: Disables Position-Independent Executable (PIE). This forces code section addresses to remain fixed and low in virtual memory (e.g., `0x401000` instead of randomized `0xffff...` addresses), providing 1:1 address parity between GDB disassemblies.
* `-fno-stack-protector`: Disables GCC stack canaries (buffer overflow detection), allowing raw stack manipulation during labs.
* `-z execstack`: Marks the stack memory region as executable, allowing code injected onto the stack to run.

### `dbg-server`

Command:

```bash
qemu-x86_64 -g 1234 "$1"
```

Purpose: Runs the compiled target binary inside QEMU user-mode emulation while acting as a remote GDB debugging stub.

Flag breakdown:

* `qemu-x86_64`: Executes x86_64 binaries on non-native or emulated hosts.
* `-g 1234`: Freezes process execution at the very first instruction and opens a TCP listening socket on port `1234` waiting for a GDB client to connect.

### `dbg-client`

Command:

```bash
gdb "$1" -ex "set disassembly-flavor intel" -ex "target remote :1234"
```

Purpose: Launches GDB, loads the binary's symbol table, sets preferred syntax, and connects directly to the running QEMU server session.

Flag breakdown:

* `"$1"`: Loads the target binary into GDB first so symbol tables, section headers, and Procedure Linkage Table (`PLT`) entries (such as `<printf@plt>`) resolve correctly.
* `-ex "set disassembly-flavor intel"`: Automatically configures assembly rendering to Intel syntax (`mov rax, rbx`) instead of default AT&T syntax (`movq %rbx, %rax`).
* `-ex "target remote :1234"`: Attaches GDB via TCP to the QEMU server instance listening on port `1234`.

## Reopening the Container

If the container has stopped, start it again and attach a shell:

```bash
docker compose start
docker exec -it sfss_headless_cli bash
```

## Rebuilding

If the `Dockerfile` or `docker-compose.yml` changes, rebuild the image:

```bash
docker compose up -d --build
```

### To fully recreate the container

```bash
docker compose down
docker compose up -d --build --force-recreate
```

## Using Docker CLI Directly (Optional)

You can use plain `docker` commands without `docker-compose`:

```bash
# Build
docker build --platform linux/amd64 -t sfss_headless_cli .

# Run with required security capabilities
docker run -it \
  --platform linux/amd64 \
  --cap-add SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --name sfss_headless_cli \
  -v "$PWD":/root/code \
  sfss_headless_cli
```

Inside the container run the same helper commands:

```bash
dbg-build test.c
dbg-server test
```

Then from a second host terminal:

```bash
docker exec -it sfss_headless_cli dbg-client test
```
