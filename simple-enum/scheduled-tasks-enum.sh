#!/bin/bash

user="$(whoami)"
host="$(hostname)"
date="$(date -I)"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
filename="${script_dir}/../results/scheduled_tasks_enum_${user}_${host}_${date}"

# Print /etc/crontab content
printf "Print /etc/crontab content:\n" >> "${filename}"
cat /etc/crontab >> "${filename}"
printf "\n" >> "${filename}"

# Print /etc/cron.daily content
printf "Print /etc/cron.daily content:\n" >> "${filename}"
ls -la /etc/cron.daily/ >> "${filename}" 2>/dev/null
printf "\n" >> "${filename}"

# Print /etc/cron.hourly content
printf "Print /etc/cron.hourly content:\n" >> "${filename}" 
ls -la /etc/cron.hourly/ >> "${filename}" 2>/dev/null
printf "\n" >> "${filename}"

# Print /etc/cron.weekly content
printf "Print /etc/cron.weekly content:\n" >> "${filename}"
ls -la /etc/cron.weekly/ >> "${filename}" 2>/dev/null
printf "\n" >> "${filename}"

# Print /etc/cron.monthly content
printf "Print /etc/cron.monthly content:\n" >> "${filename}"
ls -la /etc/cron.monthly/ >> "${filename}" 2>/dev/null
printf "\n" >> "${filename}"

# Print users crontabs
printf "Print users crontabs:\n" >> "${filename}"
for user in $(cut -f1 -d: /etc/passwd); do
    if crontab -u "$user" -l &>/dev/null; then
        printf "[+] Crontab for user: %s\n" "$user" >> "${filename}"
        crontab -u "$user" -l >> "${filename}"
        printf "\n" >> "${filename}"
    fi
done
printf "\n" >> "${filename}"

# List systemd timers
printf "List systemd timers:\n" >> "${filename}"
systemctl list-timers --all >> "${filename}"
printf "\n" >> "${filename}"

# List systemd services
printf "List systemd services:\n" >> "${filename}"
systemctl list-units --type=service --all >> "${filename}"
printf "\n" >> "${filename}"

# List systemd services scripts
printf "List systemd services scripts:\n" >> "${filename}"
grep -r ExecStart= /etc/systemd/system/ >> "${filename}"
printf "\n" >> "${filename}"

# Verify systemd files permissions
printf "Verify systemd unit files permissions:\n" >> "${filename}"
find /etc/systemd/system/ /lib/systemd/system -type f -name "*.service" -exec ls -l {} \; >> "${filename}"
printf "\n" >> "${filename}"

