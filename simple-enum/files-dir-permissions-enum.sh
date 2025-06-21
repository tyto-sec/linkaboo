#!/bin/bash
# This script enumerates files and directories with specific permissions on a Linux system.
# It collects information about write permissions, SUID/SGID files, binary capabilities,
# process capabilities, and Python path directories with write permissions.

user="$(whoami)"
host="$(hostname)"
date="$(date -I)"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
filename="${script_dir}/../results/files_and_dir_permissions_enum_${user}_${host}_${date}"

# Print Write Permission Directories
printf "Write Permission Directories:\n" >> "${filename}"
find / \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /snap -o \
    -path /var/lib/docker -o -path /var/run -o -path /var/cache \) -prune -o \
    -type d -perm -o+w -exec ls -dla {} \; 2>/dev/null >> "${filename}"
printf "\n" >> "${filename}"

# Print Write Permission Files
printf "Write Permission Files:\n" >> "${filename}"
find / \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /snap -o \
    -path /var/lib/docker -o -path /var/run -o -path /var/cache \) -prune -o \
    -type f -perm -o+w -exec ls -la {} \; 2>/dev/null >> "${filename}"
printf "\n" >> "${filename}"

# Print SUID Permission Files
printf "SUID Permission Files:\n" >> "${filename}"
find / \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /snap -o \
    -path /var/lib/docker -o -path /var/cache -o -path /var/run \) -prune -o \
    -type f -perm -4000 -exec ls -la {} \; 2>/dev/null >> "${filename}"
printf "\n" >> "${filename}"

# Print SGID Permission Files
printf "SGID Permission Files:\n" >> "${filename}"
find / \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /snap -o \
    -path /var/lib/docker -o -path /var/cache -o -path /var/run \) -prune -o \
    -type f -perm -2000 -exec ls -la {} \; 2>/dev/null >> "${filename}"
printf "\n" >> "${filename}"

# Print Binary Capabilities
printf "Binary Capabilities:\n" >> "${filename}"
find /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /bin /sbin /snap/bin \
    "$HOME/go/bin" "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.npm-global/bin" \
    -type f -exec getcap {} \; 2>/dev/null >> "${filename}"
printf "\n" >> "${filename}"

# Print Process Capabilities
printf "Process Capabilities:\n" >> "${filename}"
for pid in $(ls /proc/ | grep -E '^[0-9]+$'); do
    status="/proc/$pid/status"
    exe=$(readlink -f /proc/$pid/exe 2>/dev/null)
    caps=$(grep ^CapEff "$status" 2>/dev/null | awk '{print $2}')
    uid=$(awk '/^Uid:/ {print $2}' "$status" 2>/dev/null)
    username=$(getent passwd "$uid" | cut -d: -f1)

    # Ignore se CapEff estiver vazio, zero, ou cheio (todas capabilities)
    if [[ -n "$caps" && "$caps" != "0000000000000000" && "$caps" != "000001ffffffffff" && -n "$exe" ]]; then
        echo "[+] Processo PID $pid ($exe) | Usuário: ${username:-UID $uid} | CapEff: $caps"
    fi
done >> "${filename}"
printf "\n" >> "${filename}"

# Print Python Path Directories with Write Permissions
printf "Python Path Directories with Write Permissions:\n" >> "${filename}"
{ 
    python3 -c 'import sys; print("\n".join(sys.path))' | while read dir; do
        [ -d "$dir" ] && ls -ld "$dir"
    done | grep -E 'd.........w.' 
} >> "${filename}" 2>/dev/null
printf "\n" >> "${filename}"

# Print symbolic links owned by root in sensitive directories
printf "Symbolic Links Owned by Root in Sensitive Directories:\n" >> "${filename}"
printf "Link;Target;Owner;Sensible\n" >> "${filename}"
{
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
            printf "$link;$target;$owner;$flag\n" >> "${filename}"
        fi
    done
} 2>/dev/null
printf "\n" >> "${filename}"


base64 -w 0 ${filename} >> "${filename}_encoded"

# Print completion message
printf "Files and directories permissions enumeration completed. Output saved to %s\n" "${filename}"