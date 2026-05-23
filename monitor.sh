#!/usr/bin/env bash
# Usage: ./monitor.sh TARGET INTERVAL_SECONDS [LOG_FILE]
# Example: ./monitor.sh 10.10.11.123 30 monitor.log

TARGET="${1:-}"
INTERVAL="${2:-}"
LOG_FILE="${3:-}"

# Input Validation
if [[ -z "$TARGET" || -z "$INTERVAL" ]]; then
    echo "Usage: $0 TARGET INTERVAL_SECONDS [LOG_FILE]"
    echo "Example: $0 10.10.11.123 30 monitor.log"
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

# Initialization
PREVIOUS_STATE="unknown"

echo "Monitoring $TARGET every $INTERVAL seconds..."
[[ -n "$LOG_FILE" ]] && echo "Logging to $LOG_FILE"

while true; do
    if ping -c 1 -W 1 "$TARGET" > /dev/null 2>&1; then
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
