# secretfind

A high-performance, zero-dependency, local secret and API key scanner written in the **D Programming Language**.

`secretfind` recursively scans source code repositories and project directories to catch leaked SSH keys, API credentials, passwords, and tokens before you commit or publish them.

## Key Features

- **Blazing Fast**: Leverages D's optimized JIT-compiled regex engine (`std.regex`).
- **Zero External Dependencies**: Compiled into a standalone native binary with no runtime overhead.
- **Local & Secure**: Never touches the network. Everything stays on your local filesystem.
- **Smart Filtering**: Automatically ignores noise directories like `.git`, `node_modules`, `build`, `.venv`, etc.
- **Colorized CLI Output**: Highlights match types, file paths, and exact line locations in the terminal.

## Detected Patterns

- RSA / OpenSSH Private Keys
- Generic API Keys and Secret Tokens
- AWS Access Key IDs
- GitHub Personal Access Tokens (`ghp_...`)
- Hardcoded Passwords in Source Code
- JSON Web Tokens (JWT)

## Prerequisites

You need a working D compiler (`dmd`, `gdc`, or `ldc`). The easiest way to install `dmd` on Linux is:

```bash
curl -fsS https://dlang.org/install.sh | bash -s dmd
source ~/dlang/dmd-*/activate
```

## Build Instructions

Compile the source with release optimizations:

```bash
# Build the binary
dmd -O -release secretfind.d -of=secretfind

# (Optional) Strip symbols to reduce binary size
strip secretfind
```

## Usage

### Basic Commands

Scan the current working directory:
```bash
./secretfind
```

Scan a specific directory or project:
```bash
./secretfind /path/to/your/project
```

Scan a subfolder relative to your current path:
```bash
./secretfind ./src
```

### Global Installation

To install `secretfind` system-wide so you can invoke it from any directory:

```bash
sudo cp secretfind /usr/local/bin/
```

Once installed, you can scan any project folder by simply typing:

```bash
secretfind /path/to/target
```

Or scan your current folder from anywhere:

```bash
secretfind .
```

## Sample Output

```text
==================================================
  secretfind - Secret & Key Scanner (D Language)
  Target Directory: /home/user/projects/my-app
==================================================

[RSA/SSH Private Key] config/id_rsa
  Line 1: -----BEGIN OPENSSH PRIVATE KEY-----

[Generic API Key] src/api.py
  Line 14: API_KEY = "sk_live_x892348923489234"

--------------------------------------------------
Scan Complete: Analyzed 42 files, found 2 sensitive pattern(s).
```

## License

MIT License. Free to use and modify.
