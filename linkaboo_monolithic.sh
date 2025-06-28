#!/bin/bash
# Monolithic Linkaboo - All-in-one enumeration script

echo -e "\e[1;31mPeekaboo! I see your secrets hiding in the shadows...\e[0m"

USER="$(whoami)"
HOST="$(hostname)"
DATE="$(date -I)"
RESULTS_DIR="/tmp/linkaboo_results"
LOG_FILE="$RESULTS_DIR/main_${USER}_${HOST}_${DATE}.log"

mkdir -p "$RESULTS_DIR"
> "$LOG_FILE"

# Include wordlists

# Create temporary wordlist files
WORDS_WORDLIST="$(mktemp)"
EXTENSIONS_WORDLIST="$(mktemp)"

# Populate sensitive words wordlist
echo "pass" >> "$WORDS_WORDLIST"
echo "password" >> "$WORDS_WORDLIST"
echo "passwd" >> "$WORDS_WORDLIST"
echo "token" >> "$WORDS_WORDLIST"
echo "secret" >> "$WORDS_WORDLIST"
echo "apikey" >> "$WORDS_WORDLIST"
echo "api_key" >> "$WORDS_WORDLIST"
echo "auth" >> "$WORDS_WORDLIST"
echo "authorization" >> "$WORDS_WORDLIST"
echo "credentials" >> "$WORDS_WORDLIST"
echo "ssh" >> "$WORDS_WORDLIST"
echo "id_rsa" >> "$WORDS_WORDLIST"
echo "id_dsa" >> "$WORDS_WORDLIST"
echo "private" >> "$WORDS_WORDLIST"
echo "pem" >> "$WORDS_WORDLIST"
echo "pfx" >> "$WORDS_WORDLIST"
echo "sudo" >> "$WORDS_WORDLIST"
echo "su" >> "$WORDS_WORDLIST"
echo "scp" >> "$WORDS_WORDLIST"
echo "sftp" >> "$WORDS_WORDLIST"
echo "ftp" >> "$WORDS_WORDLIST"
echo "wget" >> "$WORDS_WORDLIST"
echo "curl" >> "$WORDS_WORDLIST"
echo "http" >> "$WORDS_WORDLIST"
echo "https" >> "$WORDS_WORDLIST"
echo "ftp" >> "$WORDS_WORDLIST"
echo "upload" >> "$WORDS_WORDLIST"
echo "download" >> "$WORDS_WORDLIST"
echo "mysql" >> "$WORDS_WORDLIST"
echo "psql" >> "$WORDS_WORDLIST"
echo "sqlite" >> "$WORDS_WORDLIST"
echo "mongo" >> "$WORDS_WORDLIST"
echo "redis" >> "$WORDS_WORDLIST"
echo "db" >> "$WORDS_WORDLIST"
echo "database" >> "$WORDS_WORDLIST"
echo "conn" >> "$WORDS_WORDLIST"
echo "connection" >> "$WORDS_WORDLIST"
echo "root" >> "$WORDS_WORDLIST"
echo "admin" >> "$WORDS_WORDLIST"
echo "docker" >> "$WORDS_WORDLIST"
echo "docker-compose" >> "$WORDS_WORDLIST"
echo "kubectl" >> "$WORDS_WORDLIST"
echo "kubeconfig" >> "$WORDS_WORDLIST"
echo "vault" >> "$WORDS_WORDLIST"
echo "export" >> "$WORDS_WORDLIST"
echo "set" >> "$WORDS_WORDLIST"
echo "env" >> "$WORDS_WORDLIST"
echo "AWS_SECRET_ACCESS_KEY" >> "$WORDS_WORDLIST"
echo "AWS_ACCESS_KEY_ID" >> "$WORDS_WORDLIST"
echo "GCP_PROJECT" >> "$WORDS_WORDLIST"
echo "GOOGLE_CREDENTIALS" >> "$WORDS_WORDLIST"
echo "secretsmanager" >> "$WORDS_WORDLIST"
echo "vault_token"  >> "$WORDS_WORDLIST"

# Populate sensitive extensions wordlist
echo ".conf" >> "$EXTENSIONS_WORDLIST"
echo ".config" >> "$EXTENSIONS_WORDLIST"
echo ".cfg" >> "$EXTENSIONS_WORDLIST"
echo ".ini" >> "$EXTENSIONS_WORDLIST"
echo ".env" >> "$EXTENSIONS_WORDLIST"
echo ".yml" >> "$EXTENSIONS_WORDLIST"
echo ".yaml" >> "$EXTENSIONS_WORDLIST"
echo ".sh" >> "$EXTENSIONS_WORDLIST"
echo ".bash" >> "$EXTENSIONS_WORDLIST"
echo ".bashrc" >> "$EXTENSIONS_WORDLIST"
echo ".zshrc" >> "$EXTENSIONS_WORDLIST"
echo ".profile" >> "$EXTENSIONS_WORDLIST"
echo ".sql" >> "$EXTENSIONS_WORDLIST"
echo ".db" >> "$EXTENSIONS_WORDLIST"
echo ".sqlite" >> "$EXTENSIONS_WORDLIST"
echo ".sqlite3" >> "$EXTENSIONS_WORDLIST"
echo ".dump" >> "$EXTENSIONS_WORDLIST"
echo ".log" >> "$EXTENSIONS_WORDLIST"
echo ".json" >> "$EXTENSIONS_WORDLIST"
echo ".xml" >> "$EXTENSIONS_WORDLIST"
echo ".py" >> "$EXTENSIONS_WORDLIST"
echo ".pyc" >> "$EXTENSIONS_WORDLIST"
echo ".php" >> "$EXTENSIONS_WORDLIST"
echo ".js" >> "$EXTENSIONS_WORDLIST"
echo ".rb" >> "$EXTENSIONS_WORDLIST"
echo ".jar" >> "$EXTENSIONS_WORDLIST"
echo ".pl" >> "$EXTENSIONS_WORDLIST"
echo "go.mod" >> "$EXTENSIONS_WORDLIST"
echo "go.sum" >> "$EXTENSIONS_WORDLIST"
echo ".go" >> "$EXTENSIONS_WORDLIST"
echo ".pfx" >> "$EXTENSIONS_WORDLIST"
echo ".pem" >> "$EXTENSIONS_WORDLIST"
echo ".key" >> "$EXTENSIONS_WORDLIST"
echo ".crt" >> "$EXTENSIONS_WORDLIST"
echo ".cer" >> "$EXTENSIONS_WORDLIST"
echo ".der" >> "$EXTENSIONS_WORDLIST"
echo ".asc" >> "$EXTENSIONS_WORDLIST"
echo ".kdbx" >> "$EXTENSIONS_WORDLIST"
echo ".p12" >> "$EXTENSIONS_WORDLIST"
echo ".p7b" >> "$EXTENSIONS_WORDLIST"
echo ".bak" >> "$EXTENSIONS_WORDLIST"
echo ".old" >> "$EXTENSIONS_WORDLIST"
echo ".orig" >> "$EXTENSIONS_WORDLIST"
echo ".tmp" >> "$EXTENSIONS_WORDLIST"
echo ".swp" >> "$EXTENSIONS_WORDLIST"
echo ".tar" >> "$EXTENSIONS_WORDLIST"
echo ".tgz" >> "$EXTENSIONS_WORDLIST"
echo ".zip" >> "$EXTENSIONS_WORDLIST"
echo ".7z" >> "$EXTENSIONS_WORDLIST"
echo ".rar" >> "$EXTENSIONS_WORDLIST"
echo ".gpg" >> "$EXTENSIONS_WORDLIST"
echo ".enc" >> "$EXTENSIONS_WORDLIST"
echo ".kdb" >> "$EXTENSIONS_WORDLIST"
echo ".ps1" >> "$EXTENSIONS_WORDLIST"
echo ".psm1" >> "$EXTENSIONS_WORDLIST"
echo ".aws/credentials" >> "$EXTENSIONS_WORDLIST"
echo ".npmrc" >> "$EXTENSIONS_WORDLIST"
echo ".git-credentials" >> "$EXTENSIONS_WORDLIST"
echo ".netrc" >> "$EXTENSIONS_WORDLIST"
echo "docker-compose.yml" >> "$EXTENSIONS_WORDLIST"
echo ".dockerignore" >> "$EXTENSIONS_WORDLIST"
echo ".htpasswd" >> "$EXTENSIONS_WORDLIST"
echo ".htaccess" >> "$EXTENSIONS_WORDLIST"
echo ".cnf" >> "$EXTENSIONS_WORDLIST"
echo ".txt" >> "$EXTENSIONS_WORDLIST"
echo ".c" >> "$EXTENSIONS_WORDLIST"


# == Begin embedded modules ==

basic_linux_enum() {
# This script collects basic information about the Linux system and saves it to a file.

FILENAME="$RESULTS_DIR/host_enum_${USER}_${HOST}_${DATE}" 

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

printf "Routing Table:\n" >> "${FILENAME}"
if command -v ip &> /dev/null; then
    ip route show >> "${FILENAME}"
else
    printf "ip command not found, using route command instead.\n" >> "${FILENAME}"
    route -n >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"

printf "ARP Table:\n" >> "${FILENAME}"
if command -v arp &> /dev/null; then
    arp -n >> "${FILENAME}"
else
    printf "arp command not found.\n" >> "${FILENAME}"
fi
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

printf "Print /etc/exports:\n" >> "${FILENAME}"
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

printf "LXC Containers:\n" >> "${FILENAME}"
if command -v lxc-ls &> /dev/null; then
    lxc-ls --fancy >> "${FILENAME}"
else
    printf "lxc-ls command not found.\n" >> "${FILENAME}"
fi
printf "\n" >> "${FILENAME}"


### Hardware

printf "Disk Space:\n" >> "${FILENAME}"
df -hT >> "${FILENAME}"
printf "\n" >> "${FILENAME}"    

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

}

sensitive_files_enum() {
# This script enumerates sensitive files and directories on a Linux system.
# It collects information about files with sensitive names, history commands, suspicious extensions,
# content patterns, hidden files/directories, and log entries.

WORDS_WORDLIST="$WORDS_WORDLIST"
EXTENSIONS_WORDLIST="$EXTENSIONS_WORDLIST"
FILENAME="$RESULTS_DIR/sensitive_files_enum_${USER}_${HOST}_${DATE}"

SEARCH_PATHS="/home /root /etc /var/www /opt /srv"

ALL_FILES=$(mktemp)
find $SEARCH_PATHS -type f -readable -size -5M 2>/dev/null > "$ALL_FILES"

# Files with sensitive words in names
printf "Files with Sensitive Words in Their Names:\n" >> "$FILENAME"
grep -iE "pass|token|secret|key|senha|user|cred|config|login|db|usuario" "$ALL_FILES" >> "$FILENAME"
printf "\n" >> "$FILENAME"

# Files with sensitive extensions
printf "Files with Sensitive Extensions:\n" >> "$FILENAME"
EXT_REGEX=$(sed 's/^\.//' "$EXTENSIONS_WORDLIST" | paste -sd'|' -)
grep -iE "\.($EXT_REGEX)$" "$ALL_FILES" >> "$FILENAME"
printf "\n" >> "$FILENAME"

# Files with sensitive words in content
printf "Files with Sensitive Words in Their Content:\n" >> "$FILENAME"
while read -r file; do
    if grep -Eif "$WORDS_WORDLIST" "$file" &>/dev/null; then
        echo -e "\n[+] File: $file\n" >> "$FILENAME"
        grep -Eif "$WORDS_WORDLIST" "$file" 2>/dev/null >> "$FILENAME"
    fi
done < "$ALL_FILES"
printf "\n" >> "$FILENAME"

# Cleanup
rm -f "$ALL_FILES"

}

permissions_enum() {
# This script enumerates files and directories with specific permissions on a Linux system.

FILENAME="$RESULTS_DIR/files_and_dir_permissions_enum_${USER}_${HOST}_${DATE}"

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

}

scheduled_tasks_enum() {
# This script enumerates scheduled tasks on a Linux system, including cron jobs and systemd timers.
# It collects information about cron jobs, systemd timers, and services, and saves the output
# to a results file in the specified directory.

FILENAME="$RESULTS_DIR/scheduled_tasks_enum_${USER}_${HOST}_${DATE}"

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
}

# == Run each module in parallel ==

MAX_PARALLEL=4
running_jobs=0

run_module() {
    name="$1"
    func="$2"
    echo -e "\e[1;33m[+] Running: $name - $(date '+%H:%M:%S')\e[0m" | tee -a "$LOG_FILE"
    eval "$func" >> "$LOG_FILE" 2>&1
    echo -e "\e[1;32m[+] Finished: $name - $(date '+%H:%M:%S')\e[0m" | tee -a "$LOG_FILE"
}

run_module "basic-linux-enum" basic_linux_enum &
((++running_jobs))
run_module "sensitive-files-enum" sensitive_files_enum &
((++running_jobs))
run_module "files-dir-permissions-enum" permissions_enum &
((++running_jobs))
run_module "scheduled-tasks-enum" scheduled_tasks_enum &
((++running_jobs))

while (( running_jobs > 0 )); do
    wait -n
    ((--running_jobs))
done

# Compress results
ARCHIVE_NAME="results_${USER}_${HOST}_${DATE}"
ARCHIVE_PATH="/tmp/${ARCHIVE_NAME}"

if command -v tar &> /dev/null; then
    tar czf "${ARCHIVE_PATH}.tar.gz" -C "$(dirname "$RESULTS_DIR")" "$(basename "$RESULTS_DIR")"
    echo -e "\e[1;34m[+] Results compressed to ${ARCHIVE_PATH}.tar.gz\e[0m"
elif command -v zip &> /dev/null; then
    zip -r "${ARCHIVE_PATH}.zip" "$RESULTS_DIR" >/dev/null
    echo -e "\e[1;34m[+] Results compressed to ${ARCHIVE_PATH}.zip\e[0m"
elif command -v 7z &> /dev/null; then
    7z a "${ARCHIVE_PATH}.7z" "$RESULTS_DIR" >/dev/null
    echo -e "\e[1;34m[+] Results compressed to ${ARCHIVE_PATH}.7z\e[0m"
else
    echo -e "\e[1;33m[!] No compression tool found. Results left uncompressed.\e[0m"
fi

# Cleanup
rm -f "$WORDS_WORDLIST" "$EXTENSIONS_WORDLIST"
