# Network Monitor Script

A simple bash script to monitor network connectivity to a target host with desktop notifications and audio alerts.

## Features

- 🔄 Continuous monitoring with configurable intervals
- 🔔 Desktop notifications on status change (Online ↔ Offline)
- 🔊 Audio alerts for offline events
- 📝 Optional timestamped logging to a file
- 🍎 Cross-platform support (Linux & macOS)
- ⚡ Lightweight with minimal dependencies
- 🛡️ Anti-spam: Alerts only trigger when the status actually changes

## Requirements

### Linux
- `bash` - Shell interpreter
- `ping` - Network connectivity testing
- `notify-send` - Desktop notifications (libnotify)
- `paplay` - Audio playback (optional, PulseAudio)

### macOS
- `bash` - Shell interpreter
- `ping` - Network connectivity testing (built-in)
- `osascript` - Desktop notifications (built-in)
- `afplay` - Audio playback (built-in)

## Installation

1. Clone or download the script:
```bash
git clone <repository-url>
cd monitor
```

2. Make the script executable and add it to your path:
```bash
chmod +x monitor.sh
mkdir -p ~/.local/bin
ln -s "$(pwd)/monitor.sh" ~/.local/bin/monitor
```
*(Ensure `~/.local/bin` is in your `$PATH`)*

## Usage

If installed globally:
```bash
monitor TARGET INTERVAL_SECONDS [LOG_FILE]
```

Otherwise:
```bash
./monitor.sh TARGET INTERVAL_SECONDS [LOG_FILE]
```

### Parameters

- **TARGET** - IP address or hostname to monitor
- **INTERVAL_SECONDS** - Time between checks (in seconds)
- **LOG_FILE** - (Optional) Path to a file where status changes will be logged

### Examples

Monitor a HackTheBox machine every 30 seconds:
```bash
./monitor.sh 10.10.11.123 30
```

Monitor a local server every 10 seconds and log to `uptime.log`:
```bash
./monitor.sh 192.168.1.100 10 uptime.log
```

## How It Works

1. The script pings the target host once per interval.
2. It tracks the state of the host.
3. **If the state changes** (e.g., from Online to Offline):
   - Sends a desktop notification.
   - Logs the status with a timestamp to console (and optionally a file).
   - Plays an alarm sound if the host went offline.
4. If the state remains the same, it continues monitoring silently to avoid notification spam.
5. Repeats indefinitely until stopped (Ctrl+C).

## Output Example

```
Monitoring 10.10.11.123 every 30 seconds...
2025-12-11 19:38:00: 10.10.11.123 is online
2025-12-11 19:38:30: 10.10.11.123 is online
2025-12-11 19:39:00: 10.10.11.123 is offline!
2025-12-11 19:39:30: 10.10.11.123 is online
```

## Use Cases

- **CTF/HackTheBox**: Monitor when a box resets or goes down
- **Server Monitoring**: Track uptime of critical services
- **Network Troubleshooting**: Detect intermittent connectivity issues
- **Development**: Monitor when local services restart

## Stopping the Monitor

Press `Ctrl+C` to stop the monitoring script.

## Troubleshooting

### No desktop notifications
Install libnotify:
```bash
# Debian/Ubuntu
sudo apt install libnotify-bin

# Arch Linux
sudo pacman -S libnotify

# Fedora
sudo dnf install libnotify
```

### No audio alerts
Install PulseAudio:
```bash
# Debian/Ubuntu
sudo apt install pulseaudio-utils

# Arch Linux
sudo pacman -S pulseaudio

# Fedora
sudo dnf install pulseaudio-utils
```

### Permission denied
Make sure the script is executable:
```bash
chmod +x monitor.sh
```

## License

Free to use and modify as needed.

## Author

Created for network monitoring and CTF/penetration testing scenarios.
