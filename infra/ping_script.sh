#!/bin/bash

# Get the list of IP addresses
INSTANCE_IPS=$(cat /tmp/instance_ips.txt)

# Convert the IP addresses into an array
IFS=' ' read -r -a IP_ARRAY <<< "$INSTANCE_IPS"

# Create a file to store results
RESULT_FILE="/tmp/ping_results.log"
> $RESULT_FILE

# Perform round-robin ping tests
for i in "${!IP_ARRAY[@]}"; do
    source_ip=${IP_ARRAY[$i]}
    target_ip=${IP_ARRAY[$(( (i + 1) % ${#IP_ARRAY[@]} ))]}

    echo "Pinging from $source_ip to $target_ip" >> $RESULT_FILE
    if ping -c 3 $target_ip > /dev/null; then
        echo "Success" >> $RESULT_FILE
    else
        echo "Fail" >> $RESULT_FILE
    fi
done