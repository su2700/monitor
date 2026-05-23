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

The script requires a target and an interval in seconds, with an optional log file.

```bash
./monitor.sh <TARGET> <INTERVAL> [LOG_FILE]
```

**Example:**
```bash
./monitor.sh 1.1.1.1 60 connectivity.log
```

### Stopping
Use `Ctrl+C` to terminate the script.

## Dependencies

- **Linux**: `bash`, `iputils-ping`, `libnotify-bin`, `pulseaudio-utils`.
- **macOS**: `bash`, `ping` (built-in), `osascript` (built-in), `afplay` (built-in).

## Architecture & Conventions

- **Entry Point**: `monitor.sh`
- **Logic**:
  - **Input Validation**: Ensures `INTERVAL` is a positive integer.
  - **OS Detection**: Uses `uname -s` to select appropriate notification and audio commands.
  - **State Tracking**: Uses `PREVIOUS_STATE` variable to trigger alerts only on status transitions (Online ↔ Offline).
  - **Logging**: A unified `log_message` function handles console output and optional file appending.
- **Formatting**:
  - Logs follow the format: `YYYY-MM-DD HH:MM:SS: <TARGET> is [online|offline!]`.
