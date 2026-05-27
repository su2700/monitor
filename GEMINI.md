# Network Monitor

A lightweight Bash-based network monitoring tool designed to track host availability and provide real-time alerts.

## Project Overview

- **Purpose**: Monitors network connectivity to a specific IP or hostname.
- **Key Features**:
  - Continuous ping-based monitoring.
  - State-change tracking to avoid notification spam.
  - Cross-platform support for Linux and macOS.
  - Optional file logging.
  - Desktop notifications and audio alerts.
- **Tech Stack**: Bash.

## Usage

### Running the Monitor

The script can be run directly or as a global command if symlinked to the path (e.g., `~/.local/bin/monitor`).

```bash
# As a global command
monitor <TARGET> [INTERVAL] [LOG_FILE]

# As a local script
./monitor.sh <TARGET> [INTERVAL] [LOG_FILE]
```

**Note**: Default interval is 60 seconds.

**Example:**
```bash
./monitor.sh 1.1.1.1 60 connectivity.log
```

### Stopping
Use `Ctrl+C` to terminate the script.

## Dependencies

- **Linux**: `bash`, `iputils-ping`, `libnotify-bin`, `pulseaudio-utils`, `curl`, `netcat`.
- **macOS**: `bash`, `ping` (built-in), `osascript` (built-in), `afplay` (built-in), `curl` (built-in), `netcat` (built-in).

## Architecture & Conventions

- **Entry Point**: `monitor.sh`
- **Logic**:
  - **Input Validation**: Ensures `INTERVAL` is a positive integer.
  - **OS Detection**: Uses `uname -s` to select appropriate notification and audio commands.
  - **State Tracking**: Uses `PREVIOUS_STATE` variable to trigger alerts only on status transitions (Online ↔ Offline).
  - **Connectivity Checks**:
    - **HTTP/HTTPS**: Uses `curl` for URLs.
    - **TCP Port**: Uses `nc` for `host:port` targets.
    - **Fallback Logic**: For plain IPs/hostnames, attempts `ping` first, then falls back to scanning common ports (22, 80, 443, 445, 3389) via `nc`.
  - **Logging**: A unified `log_message` function handles console output and optional file appending.
- **Formatting**:
  - Logs follow the format: `YYYY-MM-DD HH:MM:SS: <TARGET> is [online|offline!]`.
