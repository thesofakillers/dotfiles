#!/bin/bash

declare -a history=()

while true; do
  if ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
    status="$(date): Internet is available"
  else
    status="$(date): Internet is NOT available"
  fi

  # Add new status to history
  history+=("$status")

  # Keep only last 10 entries
  if [ ${#history[@]} -gt 10 ]; then
    history=("${history[@]:1}")
  fi

  # Clear the screen and print the history
  clear
  for line in "${history[@]}"; do
    echo "$line"
  done

  sleep 5
done
