#!/bin/bash

INSTANCE_IPS=($(cat /tmp/instance_ips.txt))
for ip in "${INSTANCE_IPS[@]}"; do
  for target_ip in "${INSTANCE_IPS[@]}"; do
    if [ "$ip" != "$target_ip" ]; then
      if ping -c 1 $target_ip &> /dev/null; then
        echo "Ping to $target_ip from $ip: SUCCESS" >> /tmp/ping_results.log
      else
        echo "Ping to $target_ip from $ip: FAIL" >> /tmp/ping_results.log
      fi
    fi
  done
done
