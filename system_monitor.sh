#!/bin/bash
# ============================================
#  Linux System Resource Monitor
#  Author: Abderrahmen Saidi
#  Description: Monitors CPU, Memory, and Disk usage,
#   and alerts if thresholds are exceeded.
# ============================================

# Default threshold values 
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

LOG_FILE="monitor.log"
CONFIG_FILE="monitor.conf"
INTERVAL=${1:-2} # Default refresh interval in seconds

# Exit on Ctrl+C
trap 'echo "$(tput setaf 3)Monitoring stopped.$(tput sgr0)"; exit 0' SIGINT

# Function to log messages with timestamp
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to send an alert
send_alert() {
  message="ALERT: $1 usage exceeded threshold! Current value: $2%"
  echo "$(tput setaf 1)$message$(tput sgr0)"
  log "$message"
}

# Monitoring loop
while true; do
  # CPU usage
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
  cpu_usage=${cpu_usage%.*}
  ((cpu_usage >= CPU_THRESHOLD)) && send_alert "CPU" "$cpu_usage"

  # Memory usage
  memory_usage=$(free | awk '/Mem/ {printf("%3.1f", ($3/$2) * 100)}')
  memory_usage=${memory_usage%.*}
  ((memory_usage >= MEMORY_THRESHOLD)) && send_alert "Memory" "$memory_usage"

  # Disk usage
  disk_usage=$(df -h / | awk '/\// {print $(NF-1)}')
  disk_usage=${disk_usage%?}
  ((disk_usage >= DISK_THRESHOLD)) && send_alert "Disk" "$disk_usage"

  # Display current stats
  clear
  echo "$(tput bold)$(tput setaf 6)System Resource Monitor$(tput sgr0)"
  echo "--------------------------------------"
  echo "$(tput setaf 2)CPU:$(tput sgr0)     $cpu_usage%"
  echo "$(tput setaf 2)Memory:$(tput sgr0)  $memory_usage%"
  echo "$(tput setaf 2)Disk:$(tput sgr0)    $disk_usage%"
  echo
  echo "Thresholds → CPU: ${CPU_THRESHOLD}% | MEM: ${MEMORY_THRESHOLD}% | DISK: ${DISK_THRESHOLD}%"
  echo "Logging to: $LOG_FILE"
  echo "Refresh interval: ${INTERVAL}s"
  log "CPU: $cpu_usage%, Memory: $memory_usage%, Disk: $disk_usage%"
  sleep "$INTERVAL"
done
