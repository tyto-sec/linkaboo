#!/bin/bash
# Main script to run complete enumeration
# It collects system information, sensitive files, directory permissions, and scheduled tasks.

echo -e "\e[1;31mPeekaboo! I see your secrets hiding in the shadows...\e[0m"

USER="$(whoami)"
HOST="$(hostname)"
DATE="$(date -I)"

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd scripts && pwd)"
RESULTS_DIR="$SCRIPTS_DIR/../results"
LOG_FILE="$RESULTS_DIR/main_${USER}_${HOST}_${DATE}.log"
mkdir -p "$RESULTS_DIR"
> "$LOG_FILE"

SCRIPTS=(
    "basic-linux-enum.sh"
    "sensitive-files-enum.sh"
    "files-dir-permissions-enum.sh"
    "scheduled-tasks-enum.sh"
)

MAX_PARALLEL=4
running_jobs=0

run_script() {
    local script_name="$1"
    local path="$SCRIPTS_DIR/$script_name"

    if [[ -x "$path" ]]; then
        echo -e "\e[1;33m[+] Running: $script_name - $(date '+%H:%M:%S')\e[0m" | tee -a "$LOG_FILE"
        "$path" >> "$LOG_FILE" 2>&1
        echo -e "\e[1;32m[+] Finished: $script_name - $(date '+%H:%M:%S')\e[0m" | tee -a "$LOG_FILE"
    else
        echo -e "\e[1;31m[!] Script not found or not executable: $script_name\e[0m" | tee -a "$LOG_FILE"
    fi
}

for script in "${SCRIPTS[@]}"; do
    run_script "$script" &
    ((++running_jobs))

    if [[ "$running_jobs" -ge "$MAX_PARALLEL" ]]; then
        wait -n
        ((--running_jobs))
    fi
done

wait

echo -e "\e[1;36m[*] Enumeration completed. Logs saved to: $LOG_FILE\e[0m"

ARCHIVE_NAME="results_${USER}_${HOST}_${DATE}"
ARCHIVE_PATH="$(dirname "$RESULTS_DIR")/$ARCHIVE_NAME"

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
