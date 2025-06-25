#!/bin/bash
# This script enumerates scheduled tasks on a Linux system, including cron jobs and systemd timers.
# It collects information about cron jobs, systemd timers, and services, and saves the output
# to a results file in the specified directory.

USER="$(whoami)"
HOST="$(hostname)"
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME="${SCRIPT_DIR}/../results/scheduled_tasks_enum_${USER}_${HOST}_${DATE}"

# /etc/crontab
printf "/etc/crontab content:\n" >> "${FILENAME}"
cat /etc/crontab >> "${FILENAME}" 2>/dev/null
printf "\n" >> "${FILENAME}"

# Cron directories
for dir in daily hourly weekly monthly; do
    CRON_DIR="/etc/cron.${dir}"
    printf "/etc/cron.%s content:\n" "$dir" >> "${FILENAME}"
    ls -la "$CRON_DIR" >> "${FILENAME}" 2>/dev/null
    printf "\n" >> "${FILENAME}"
done

# User crontabs
printf "User crontabs:\n" >> "${FILENAME}"
cut -d: -f1 /etc/passwd | while read user; do
    if crontab -u "$user" -l &>/dev/null; then
        printf "[+] Crontab for user: %s\n" "$user" >> "${FILENAME}"
        crontab -u "$user" -l >> "${FILENAME}"
        printf "\n" >> "${FILENAME}"
    fi
done
printf "\n" >> "${FILENAME}"

# Rsync jobs in cron*
printf "Rsync Backup Jobs in cron directories:\n" >> "${FILENAME}"
grep -r rsync /etc/cron* 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# systemd timers
printf "Systemd timers:\n" >> "${FILENAME}"
systemctl list-timers --all >> "${FILENAME}" 2>/dev/null
printf "\n" >> "${FILENAME}"

# systemd services
printf "Systemd services:\n" >> "${FILENAME}"
systemctl list-units --type=service --all >> "${FILENAME}" 2>/dev/null
printf "\n" >> "${FILENAME}"

# systemd ExecStart commands
printf "ExecStart entries in systemd units:\n" >> "${FILENAME}"
grep -r '^ExecStart=' /etc/systemd/system/ 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# systemd unit file permissions
printf "Systemd unit file permissions:\n" >> "${FILENAME}"
find /etc/systemd/system/ /lib/systemd/system -type f -name "*.service" -exec ls -l {} \; >> "${FILENAME}" 2>/dev/null
printf "\n" >> "${FILENAME}"