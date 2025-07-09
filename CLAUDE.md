# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

microsandbox is a secure MicroVM provisioning system for running untrusted code in isolated environments. It provides hardware-level VM isolation with container-like experience and millisecond startup times.

## Architecture

This is a Rust workspace with the following key components:

- **microsandbox-core**: Core VM management, OCI image handling, and orchestration
- **microsandbox-server**: HTTP/MCP server for sandbox management
- **microsandbox-portal**: WebSocket-based portal for sandbox communication
- **microsandbox-cli**: Command-line interface 
- **microsandbox-utils**: Common utilities and helpers

The repository also includes SDKs (`sdk`) and SDK images (`sdk-images`) for different programming languages.

The Python SDK is kind of the reference implementation.  SDKs generally are just a few classes and most of their functionalities is calling the APIs defined here: https://docs.microsandbox.dev/references/api/. The idea is to make running code via the SDK as easy as it can be.

### Key Directories

- `microsandbox-core/lib/vm/`: MicroVM configuration and FFI bindings
- `microsandbox-core/lib/oci/`: OCI image pulling and layer management
- `microsandbox-core/lib/management/`: Sandbox lifecycle orchestration
- `microsandbox-server/lib/`: HTTP API handlers and MCP integration
- `sdk/`: SDKs for multiple languages (Python, JavaScript, Rust, etc.)
- `sdk-images/`: Dockerfiles for the images used for specifying the execution envs in microsandbox (Python, JavaScript, etc.)

## Development Commands

### Building
```bash
# Build all components
make build

# Build and install to ~/.local/bin and ~/.local/lib
make install

# Build only libkrun dependency
make build_libkrun

# Clean build artifacts
make clean
```

### Testing
```bash
# Run all tests
cargo test --all

# Run tests for specific crate
cargo test -p microsandbox-core

# Run tests with CLI features
cargo test --all --features cli
```

### Server Operations
```bash
# Start server in development mode
msb server start --dev

# Pull sandbox image
msb pull microsandbox/python

# Run temporary sandbox
msb exe --image python
# or
msx python

# Run project sandbox
msb run --sandbox app
# or
msr app
```

## Key Technical Details

### VM Implementation
- Uses libkrun for microVM virtualization
- Platform-specific linking with rpath configuration
- macOS requires code signing with entitlements file
- FFI bindings in `microsandbox-core/lib/vm/ffi.rs`

### OCI Integration
- Docker registry compatible
- Layer-based image distribution
- Multi-platform support
- Database persistence for images and manifests

### Database Schema
- SQLite with sqlx for migrations
- Separate schemas for sandboxes and OCI data
- Located in `microsandbox-core/lib/migrations/`

### MCP Support
- Model Context Protocol server implementation
- Enables AI tool integration (Claude, etc.)
- WebSocket and stdio transport support

## Development Notes

- Project uses Rust 2021 edition with LTO enabled for release builds
- Code signing required on macOS (microsandbox.entitlements)
- VM requires KVM on Linux or Apple Silicon on macOS
- Workspace dependencies managed centrally in root Cargo.toml