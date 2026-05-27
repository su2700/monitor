#!/usr/bin/env bash
# Usage: ./monitor.sh TARGET [INTERVAL_SECONDS] [LOG_FILE]
# Example: ./monitor.sh 10.10.11.123 30 monitor.log

TARGET="${1:-}"
INTERVAL="${2:-60}"
LOG_FILE="${3:-}"

# Input Validation
if [[ -z "$TARGET" ]]; then
    echo "Usage: $0 TARGET [INTERVAL_SECONDS] [LOG_FILE]"
    echo "Example: $0 10.10.11.123 30 monitor.log"
    echo "Default interval is 60 seconds."
    exit 1
fi

if [[ ! "$INTERVAL" =~ ^[0-9]+$ ]]; then
    echo "Error: INTERVAL_SECONDS must be a positive integer."
    exit 1
fi

# OS Detection and Wrapper Functions
OS_TYPE="$(uname -s)"

send_notification() {
    local title="$1"
    local message="$2"
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        osascript -e "display notification \"$message\" with title \"$title\""
    else
        notify-send "$title" "$message"
    fi
}

play_alert_sound() {
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        afplay /System/Library/Sounds/Basso.aiff 2>/dev/null || true
    else
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
    fi
}

log_message() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%F %T')
    echo "$timestamp: $message"
    if [[ -n "$LOG_FILE" ]]; then
        echo "$timestamp: $message" >> "$LOG_FILE"
    fi
}

check_connectivity() {
    local target="$1"

    # 1. HTTP/HTTPS Check
    if [[ "$target" =~ ^https?:// ]]; then
        curl -fsS -m 2 -o /dev/null "$target" && return 0
        return 1
    fi

    # 2. Specific Port Check (e.g., host:port)
    if [[ "$target" =~ ^([^:]+):([0-9]+)$ ]]; then
        local host="${BASH_REMATCH[1]}"
        local port="${BASH_REMATCH[2]}"
        nc -z -w 2 "$host" "$port" && return 0
        return 1
    fi

    # 3. ICMP Ping with Fallback to Common Ports
    if ping -c 1 -W 1 "$target" > /dev/null 2>&1; then
        return 0
    fi

    # If ping fails, check common ports as a fallback
    local common_ports=(22 80 443 445 3389)
    for port in "${common_ports[@]}"; do
        if nc -z -w 1 "$target" "$port" > /dev/null 2>&1; then
            return 0
        fi
    done

    return 1
}

# Initialization
PREVIOUS_STATE="unknown"

echo "Monitoring $TARGET every $INTERVAL seconds..."
[[ -n "$LOG_FILE" ]] && echo "Logging to $LOG_FILE"

while true; do
    if check_connectivity "$TARGET"; then
        if [[ "$PREVIOUS_STATE" != "online" ]]; then
            log_message "$TARGET is online"
            if [[ "$PREVIOUS_STATE" == "offline" ]]; then
                send_notification "Box Up" "$TARGET is back online!"
            fi
            PREVIOUS_STATE="online"
        fi
    else
        if [[ "$PREVIOUS_STATE" != "offline" ]]; then
            log_message "$TARGET is offline!"
            send_notification "Box Down" "$TARGET seems offline!"
            play_alert_sound
            PREVIOUS_STATE="offline"
        fi
    fi
    sleep "$INTERVAL"
done
