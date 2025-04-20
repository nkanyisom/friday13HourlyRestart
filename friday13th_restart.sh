#!/bin/bash

# Friday the 13th Hourly Restart Script
# WARNING: This will forcefully restart the system when conditions are met

# Configuration
TEST_MODE=true  # Set to true for testing (uses current date regardless)
LOG_FILE="/var/log/friday13_restart.log"

# Check root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root" >&2
    exit 1
fi

# Create log directory if needed
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if today is Friday the 13th
check_date() {
    local today day month weekday
    
    if [ "$TEST_MODE" = true ]; then
        log "TEST MODE ACTIVE - Using current date for testing"
        today=$(date)
    else
        today=$(date)
    fi

    day=$(date -d "$today" +%d)
    weekday=$(date -d "$today" +%A)
    month=$(date -d "$today" +%m)

    if [ "$day" = "13" ] && [ "$weekday" = "Friday" ]; then
        log "Condition met: Friday the 13th of month $month"
        return 0
    else
        log "Date check failed (Today: $weekday $day, Month: $month)"
        return 1
    fi
}

# Main execution
log "=== Starting Friday the 13th check ==="

if check_date; then
    current_hour=$(date +%H)
    log "Friday the 13th detected - Preparing restart (Hour: $current_hour)"
    
    # Check if it's exactly on the hour
    if [ "$(date +%M)" = "00" ] || [ "$TEST_MODE" = true ]; then
        log "Initiating system restart..."
        
        # Write to syslog
        logger -t "Friday13" "System restart initiated by Friday the 13th script"
        
        # Actual restart command (commented for safety during testing)
        if [ "$TEST_MODE" = false ]; then
            log "REAL RESTART WOULD OCCUR HERE"
            # shutdown -r now
        else
            log "TEST MODE: Would restart now (command commented out)"
        fi
    else
        log "Not exactly on the hour (current minute: $(date +%M))"
    fi
fi

log "=== Script complete ==="
