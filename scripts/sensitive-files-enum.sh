#!/bin/bash
# This script enumerates sensitive files and directories on a Linux system.
# It collects information about files with sensitive names, history commands, suspicious extensions,
# content patterns, hidden files/directories, and log entries.

USER="$(whoami)"
HOST="$(hostname)"
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME="${SCRIPT_DIR}/../results/sensitive_files_enum_${USER}_${HOST}_${DATE}"
WORDS_WORDLIST="${SCRIPT_DIR}/../wordlists/sensitive-words-wordlist.txt"
EXTENSIONS_WORDLIST="${SCRIPT_DIR}/../wordlists/sensitive-extensions-wordlist.txt"

# Files with sensitive words in their names
printf "Files with Sensitive Words in Their Names:\n" >> "${FILENAME}"
find / -type f \( -iname "*pass*" -o -iname "*token*" -o -iname "*secret*" -o -iname "*key*" -o -iname "*senha*" \
    -o -iname "*user*" -o -iname "*cred*" -o -iname "*config*" -o -iname "*login*" -o -iname "*db*" -o -iname "*usuario*" \) \
    2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# History files with sensitive commands
printf "History Files with Sensitive Commands:\n" >> "${FILENAME}"
find /home /root -type f \( -name '*_hist' -o -name '*_history' \) 2>/dev/null | while read -r file; do
    printf "\n[+] %s\n" "$(ls -al "$file")" >> "${FILENAME}"
    printf "History Sensitive Commands:\n" >> "${FILENAME}"
    grep -Eif "$(realpath "$WORDS_WORDLIST")" "$file" 2>> /dev/null >> "${FILENAME}" || echo "(no match found)" >> "${FILENAME}"
done
printf "\n" >> "${FILENAME}"

# Files with sensitive extensions
printf "Files with Sensitive Extensions:\n" >> "${FILENAME}"
EXPR=""
while read -r ext; do
    ext="${ext#.}"
    EXPR="$EXPR -o -iname '*.$ext'"
done < "$EXTENSIONS_WORDLIST"
EXPR="${EXPR# -o }"
eval "find / -type f \\( $EXPR \\) 2>/dev/null" >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# Files with sensitive words in content
printf "Files with Sensitive Words in Their Content:\n" >> "${FILENAME}"
find / -type f -readable -size -5M 2>/dev/null | while read -r file; do
    if grep -Eif "$WORDS_WORDLIST" "$file" 2>/dev/null; then
        echo -e "\n[+] File: $file\n" >> "${FILENAME}"
        grep -Eif "$WORDS_WORDLIST" "$file" 2>/dev/null >> "${FILENAME}"
    fi
done
printf "\n" >> "${FILENAME}"

# Hidden files and directories
printf "Hidden Files and Directories:\n" >> "${FILENAME}"
find / \( -type f -name '.*' -o -type d -name '.*' \) -exec ls -adl {} \; 2>/dev/null >> "${FILENAME}"
printf "\n" >> "${FILENAME}"

# Sensitive logs
printf "Sensitive Logs:\n" >> "${FILENAME}"
for file in /var/log/*; do
    matches=$(grep -Ei "accepted|session opened|session closed|failure|failed|ssh|password changed|new user|delete user|sudo|COMMAND=|logs" "$file" 2>/dev/null)
    if [[ -n "$matches" ]]; then
        echo -e "\nLog file: $file" >> "${FILENAME}"
        echo "$matches" >> "${FILENAME}"
    fi
done
printf "\n" >> "${FILENAME}"
