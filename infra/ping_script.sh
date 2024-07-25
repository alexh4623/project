#!/bin/bash

# File containing the IP addresses
IP_FILE="/tmp/instance_ips.txt"
# Log file to record the results
LOG_FILE="/tmp/ping_results.log"

# Read IPs into an array
readarray -t IPS < "$IP_FILE"

# Ensure we have at least two IPs
if [ "${#IPS[@]}" -lt 2 ]; then
  echo "Error: At least 2 IP addresses are required in $IP_FILE" | tee -a "$LOG_FILE"
  exit 1
fi

# Function to perform the ping and log the result
ping_and_log() {
  local source_ip="$1"
  local target_ip="$2"

  if ping -c 1 "$target_ip" &> /dev/null; then
    echo "Success: $source_ip -> $target_ip" | tee -a "$LOG_FILE"
  else
    echo "Fail: $source_ip -> $target_ip" | tee -a "$LOG_FILE"
  fi
}

# Perform round-robin pings
for ((i = 0; i < ${#IPS[@]}; i++)); do
  source_ip=${IPS[$i]}
  target_ip=${IPS[$(( (i+1) % ${#IPS[@]} ))]}
  ping_and_log "$source_ip" "$target_ip"
done
