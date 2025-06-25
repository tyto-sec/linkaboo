#!/bin/bash
# This script collects basic information about the Linux system and saves it to a file.

USER="$(whoami)"
HOST="$(hostname)"
DATE="$(date -I)"  # corrigido: DATE → date
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME="${SCRIPT_DIR}/../results/host_enum_${USER}_${HOST}_${DATE}"  # corrigido: script_dir → SCRIPT_DIR

### Users

printf "User: %s\n\n" "$USER" >> "${FILENAME}"
printf "Id: %s\n\n" "$(id)" >> "${FILENAME}"

printf "Active Users:\n" >> "${FILENAME}"
w >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Last Logins:\n" >> "${FILENAME}"
last -a | head -n 20 >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Users Last Logins:\n" >> "${FILENAME}"
lastlog | head -n 20 >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Sudoers:\n" >> "${FILENAME}"
if command -v sudo &> /dev/null; then
    sudo -n -l 2>/dev/null || echo "sudo -l requires password" >> "${FILENAME}" 
else
    printf "sudo command not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"

printf "Users:\n" >> "${FILENAME}"
cat /etc/passwd >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Groups:\n" >> "${FILENAME}"
cat /etc/group >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Shadow File:\n" >> "${FILENAME}"
cat /etc/shadow >> "${FILENAME}"
printf "\n" >> "${FILENAME}"


### Host

printf "Host: %s\n\n" "$HOST" >> "${FILENAME}"
printf "DNS Domain Name: %s\n\n" "$(hostname -d)" >> "${FILENAME}"
printf "OS: %s\n\n" "$(uname -a)" >> "${FILENAME}"

printf "Distro and Release:\n" >> "${FILENAME}"
cat /etc/os-release >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Working Directory: %s\n\n" "$(pwd)" >> "${FILENAME}"

printf "Active Terminals:\n" >> "${FILENAME}"
who -u >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Available Shells:\n" >> "${FILENAME}"
grep -v '^#' /etc/shells >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Interfaces IP Addresses:\n" >> "${FILENAME}"
ip -brief address >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Environment Variables:\n" >> "${FILENAME}"
env >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Mounted Filesystems:\n" >> "${FILENAME}"
if command -v mount &> /dev/null; then
    mount | column -t >> "${FILENAME}"
else
    printf "mount command not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"

printf "Root Content:\n" >> "${FILENAME}"
ls -la / >> "${FILENAME}"
printf "\n" >> "${FILENAME}"


### Processes

printf "Listening TCP Processes:\n" >> "${FILENAME}"
if command -v netstat &> /dev/null; then
    netstat -nlpt >> "${FILENAME}"
elif command -v ss &> /dev/null; then
    ss -lntp >> "${FILENAME}"
else
    echo "Processes Listening Program Not Found." >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"

printf "Boot Enabled Services:\n" >> "${FILENAME}"
systemctl list-unit-files --state=enabled --no-pager | grep enabled >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Tmux Sessions:\n" >> "${FILENAME}"
ps aux | grep tmux >> "${FILENAME}" || echo "No tmux sessions found." >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Current Process Capabilities:\n" >> "${FILENAME}"
if command -v capsh &> /dev/null; then
    capsh --print >> "${FILENAME}"
else
    printf "capsh command not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"


### NFS Shares

printf "NFS Shares:\n" >> "${FILENAME}"
if command -v showmount &> /dev/null; then
    showmount -e >> "${FILENAME}"
else
    printf "showmount command not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"

printf "/etc/exports:\n" >> "${FILENAME}"
if [ -f /etc/exports ]; then
    cat /etc/exports >> "${FILENAME}"
else
    printf "/etc/exports file not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"


### Containers

printf "Docker Sock Permissions:\n" >> "${FILENAME}"
if [ -S /var/run/docker.sock ]; then
    ls -l /var/run/docker.sock >> "${FILENAME}"
else
    printf "Docker socket not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"

printf "Docker Containers:\n" >> "${FILENAME}"
if command -v docker &> /dev/null; then
    docker ps -a >> "${FILENAME}"
else
    printf "Docker command not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"

printf "Container Check:\t" >> "${FILENAME}"
grep -qa 'docker\|lxc' /proc/1/cgroup && echo "Rodando em container" >> "${FILENAME}" || echo "Não está rodando em container" >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "LXC Containers:\n" >> "${FILENAME}"
if command -v lxc-ls &> /dev/null; then
    lxc-ls --fancy >> "${FILENAME}"
else
    printf "lxc-ls command not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"


### Hardware

printf "Block Devices:\n" >> "${FILENAME}"
lsblk >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "USB Devices:\n" >> "${FILENAME}"
lsusb >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "PCI Devices:\n" >> "${FILENAME}"
lspci >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Hardware:\n" >> "${FILENAME}"
lscpu >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

printf "Printers:\n" >> "${FILENAME}"
lpstat -p 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"
