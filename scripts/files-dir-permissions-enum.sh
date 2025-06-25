#!/bin/bash
# This script enumerates files and directories with specific permissions on a Linux system.

USER="$(whoami)"
HOST="$(hostname)"
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME="${SCRIPT_DIR}/../results/files_and_dir_permissions_enum_${USER}_${HOST}_${DATE}"

# Write Permission Directories
printf "Write Permission Directories:\n" >> "${FILENAME}"
find / \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /snap -o \
    -path /var/lib/docker -o -path /var/run -o -path /var/cache \) -prune -o \
    -type d -perm -o+w -exec ls -dla {} \; 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# Write Permission Files
printf "Write Permission Files:\n" >> "${FILENAME}"
find / \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /snap -o \
    -path /var/lib/docker -o -path /var/run -o -path /var/cache \) -prune -o \
    -type f -perm -o+w -exec ls -la {} \; 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# SUID Files
printf "SUID Permission Files:\n" >> "${FILENAME}"
find / \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /snap -o \
    -path /var/lib/docker -o -path /var/cache -o -path /var/run \) -prune -o \
    -type f -perm -4000 -exec ls -la {} \; 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# SGID Files
printf "SGID Permission Files:\n" >> "${FILENAME}"
find / \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /snap -o \
    -path /var/lib/docker -o -path /var/cache -o -path /var/run \) -prune -o \
    -type f -perm -2000 -exec ls -la {} \; 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# Binary Capabilities
printf "Binary Capabilities:\n" >> "${FILENAME}"
find /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /bin /sbin /snap/bin \
    "$HOME/go/bin" "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.npm-global/bin" \
    -type f -exec getcap {} \; 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# Process Capabilities
printf "Process Capabilities:\n" >> "${FILENAME}"
for pid in $(ls /proc/ | grep -E '^[0-9]+$'); do
    status="/proc/$pid/status"
    exe=$(readlink -f /proc/$pid/exe 2>/dev/null)
    caps=$(grep ^CapEff "$status" 2>/dev/null | awk '{print $2}')
    uid=$(awk '/^Uid:/ {print $2}' "$status" 2>/dev/null)
    username=$(getent passwd "$uid" | cut -d: -f1)

    if [[ -n "$caps" && "$caps" != "0000000000000000" && "$caps" != "000001ffffffffff" && -n "$exe" ]]; then
        echo "[+] Process PID $pid ($exe) | User: ${username:-UID $uid} | CapEff: $caps"
    fi
done >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# Python Path Writeable Directories
printf "Python Path Directories with Write Permissions:\n" >> "${FILENAME}"
python3 -c 'import sys; print("\n".join(sys.path))' 2>/dev/null | while read dir; do
    [ -d "$dir" ] && ls -ld "$dir"
done 2>/dev/null | grep -E 'd.........w.' >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# Root-owned Symlinks in Sensitive Paths
printf "Symbolic Links Owned by Root in Sensitive Directories:\n" >> "${FILENAME}"
printf "Link;Target;Owner;Sensitive\n" >> "${FILENAME}"
find / -xtype l 2>/dev/null | while read -r link; do
    target=$(readlink "$link")
    owner=$(stat -c '%U' "$link" 2>/dev/null)
    if [[ "$owner" == "root" ]]; then
        case "$link" in
            /etc/*|/usr/*|/var/*|/opt/*|/lib/*)
                flag="YES"
                ;;
            *)
                flag="NO"
                ;;
        esac
        printf "%s;%s;%s;%s\n" "$link" "$target" "$owner" "$flag" >> "${FILENAME}"
    fi
done
printf "\n" >> "${FILENAME}"
