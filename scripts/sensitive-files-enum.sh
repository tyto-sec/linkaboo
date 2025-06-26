#!/bin/bash
# Optimized script to enumerate sensitive files and directories on a Linux system.
# Scope-reduced search and full content inspection (without head limitation)

USER="$(whoami)"
HOST="$(hostname)"
DATE="$(date -I)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILENAME="${SCRIPT_DIR}/../results/sensitive_files_enum_${USER}_${HOST}_${DATE}"
WORDS_WORDLIST="${SCRIPT_DIR}/../wordlists/sensitive-words-wordlist.txt"
EXTENSIONS_WORDLIST="${SCRIPT_DIR}/../wordlists/sensitive-extensions-wordlist.txt"

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
