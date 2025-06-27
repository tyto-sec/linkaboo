#!/bin/bash
# This script enumerates files and directories with specific permissions on a Linux system.

USER="$(whoami)"
HOST="$(hostname)"
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME="${SCRIPT_DIR}/../results/files_and_dir_permissions_enum_${USER}_${HOST}_${DATE}"

EXCLUDED_DIRS="/proc /sys /dev /run /snap /var/lib/docker /var/run /var/cache"

PRUNE_EXPR=""
for d in $EXCLUDED_DIRS; do
    PRUNE_EXPR+=" -path $d -o"
done
PRUNE_EXPR="${PRUNE_EXPR% -o}"

ALL_ENTRIES=$(find / \( $PRUNE_EXPR \) -prune -o -type f -o -type d -print 2>/dev/null)

{
    printf "Write Permission Directories:\n"
    echo "$ALL_ENTRIES" | xargs -r stat -c '%A %n' 2>/dev/null | awk '$1 ~ /^d......w../ {print $2}'

    printf "\nWrite Permission Files:\n"
    echo "$ALL_ENTRIES" | xargs -r stat -c '%A %n' 2>/dev/null | awk '$1 ~ /^-......w../ {print $2}'

    printf "\nSUID Permission Files:\n"
    echo "$ALL_ENTRIES" | xargs -r stat -c '%A %n %a' 2>/dev/null | awk '$1 ~ /^-..s/ || $3 ~ /^4/ {print $2}'

    printf "\nSGID Permission Files:\n"
    echo "$ALL_ENTRIES" | xargs -r stat -c '%A %n %a' 2>/dev/null | awk '$1 ~ /^-.....s/ || $3 ~ /^2/ {print $2}'

    printf "\nBinary Capabilities:\n"
    BIN_PATHS="/usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /bin /sbin /snap/bin $HOME/go/bin $HOME/.cargo/bin $HOME/.local/bin $HOME/.npm-global/bin"
    find $BIN_PATHS -type f -exec getcap {} \; 2>/dev/null

    printf "\nProcess Capabilities:\n"
    for pid in $(ls /proc/ | grep -E '^[0-9]+$'); do
        status="/proc/$pid/status"
        exe=$(readlink -f /proc/$pid/exe 2>/dev/null)
        caps=$(grep ^CapEff "$status" 2>/dev/null | awk '{print $2}')
        uid=$(awk '/^Uid:/ {print $2}' "$status" 2>/dev/null)
        username=$(getent passwd "$uid" | cut -d: -f1)

        if [[ -n "$caps" && "$caps" != "0000000000000000" && "$caps" != "000001ffffffffff" && -n "$exe" ]]; then
            echo "[+] Process PID $pid ($exe) | User: ${username:-UID $uid} | CapEff: $caps"
        fi
    done

    printf "\nPython Path Directories Permissions:\n"
    python3 -c 'import sys; print("\n".join(sys.path))' 2>/dev/null | while read dir; do
        [ -d "$dir" ] && ls -ld "$dir"
    done 2>/dev/null

    printf "\nSymbolic Links Owned by Root in Sensitive Directories:\n"
    printf "Link;Target;Owner;Sensitive\n"
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
            printf "%s;%s;%s;%s\n" "$link" "$target" "$owner" "$flag"
        fi
    done
} >> "$FILENAME"