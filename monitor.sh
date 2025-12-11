#!/usr/bin/env bash
# Usage: ./monitor.sh TARGET INTERVAL_SECONDS
# Example: ./monitor.sh 10.10.11.123 30

TARGET="${1:-}"
INTERVAL="${2:-}"

if [[ -z "$TARGET" || -z "$INTERVAL" ]]; then
    echo "Usage: $0 TARGET INTERVAL_SECONDS"
    echo "Example: $0 10.10.11.123 30"
    exit 1
fi

echo "Monitoring $TARGET every $INTERVAL seconds..."

while true; do
    if ping -c 1 -W 1 "$TARGET" > /dev/null 2>&1; then
        echo "$(date '+%F %T'): $TARGET is online"
    else
        notify-send "Box Down" "$TARGET seems offline!"
        echo "$(date '+%F %T'): $TARGET is offline!"
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
    fi
    sleep "$INTERVAL"
done
