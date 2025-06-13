#!/bin/bash
# This script collects basic information about the Linux system and saves it to a file.
# It includes user identity, host information, operating system details, network interfaces,
# active terminals, available shells, listening processes, boot enabled services, environment variables,
# user accounts, block devices, USB devices, PCI devices, hardware information, and printers.

user="$(whoami)"
host="$(hostname)"
date="$(date -I)"
filename="${user}_${host}_${date}"

# Displays current username.
printf "User: %s\n\n" "$(whoami)" >> "${filename}"

# Returns user's identity
printf "Id: %s\n\n" "$(id)" >> "${filename}"

# Prints the name of current host system.
printf "Host: %s\n\n" "$(hostname)" >> "${filename}"

# Prints DNS domain name
printf "DNS Domain Name: %s\n\n" "$(hostname -d)" >> "${filename}"

# Prints information about the operating system name and system hardware.
printf "OS: %s\n\n" "$(uname -a)" >> "${filename}"

# Prints Linux Distro and Release
printf "Distro and Release:\n" >> "${filename}"
cat /etc/os-release >> "${filename}"
printf "\n" >> "${filename}"

# Returns working directory name
printf "Working Directory: %s\n\n" "$(pwd)" >> "${filename}"

# Print Active Terminals
printf "Active Terminals:\n" >> "${filename}"
who >> "${filename}"
printf "\n" >> "${filename}"

# Print Available Shells
printf "Available Shells:\n" >> "${filename}"
cat /etc/shells | grep -v '#' >> "${filename}"
printf "\n" >> "${filename}"

# Print Interfaces IP Addresses
printf "Interfaces IP Addresses:\n" >> "${filename}"
ip -brief address >> "${filename}"
printf "\n" >> "${filename}"

# Print Listening TCP Processes
printf "Listening TCP Processes:\n" >> "${filename}"
netstat -nlpt >> "${filename}"
printf "\n" >> "${filename}"

# Return Boot Enabled Services
printf "Boot Enabled Services:\n" >> "${filename}"
systemctl list-unit-files --state=enabled --no-pager | grep enabled >> "${filename}"
printf "\n" >> "${filename}"

# Print environment variables
printf "Environment Variables:\n" >> "${filename}"
env >> "${filename}"
printf "\n" >> "${filename}"

# Return /etc/passwd
printf "Users:\n" >> "${filename}"
cat /etc/passwd >> "${filename}"
printf "\n" >> "${filename}"

# Return Block Devices
printf "Block Devices:\n" >> "${filename}"
lsblk >> "${filename}"
printf "\n" >> "${filename}"

# Return USB Devices
printf "USB Devices:\n" >> "${filename}"
lsusb >> "${filename}"
printf "\n" >> "${filename}"

# Return PCI Devices
printf "PCI Devices:\n" >> "${filename}"
lspci >> "${filename}"
printf "\n" >> "${filename}"

# Return Hardware Info
printf "Hardware:\n" >> "${filename}"
lscpu >> "${filename}"
printf "\n" >> "${filename}"

# Return Printers
printf "Printers:\n" >> "${filename}"
lpstat >> "${filename}"
printf "\n" >> "${filename}"

base64 -w 0 ${filename} >> "${filename}_encoded"

# Print completion message
printf "Basic Linux enumeration completed. Output saved to %s\n" "${filename}"
