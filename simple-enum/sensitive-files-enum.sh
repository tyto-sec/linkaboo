#!/bin/bash
# This script enumerates sensitive files and directories on a Linux system.
# It collects information about files with sensitive words in their names, history files with sensitive commands,
# files with sensitive extensions, files with sensitive words in their content, hidden files and directories,
# and sensitive logs. The results are saved to a file and encoded in base64.

user="$(whoami)"
host="$(hostname)"
date="$(date -I)"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
filename="${script_dir}/../results/sensitive_files_enum_${user}_${host}_${date}"
words_wordlist="../wordlists/sensitive-words-wordlist.txt"
extensions_wordlist="../wordlists/sensitive-extensions-wordlist.txt"

# Files with sensitive words in their names
printf "Files with Sensitive Words in Their Names:\n" >> "${filename}"
find / -type f \( -iname "*pass*" -o -iname "*token*" -o -iname "*secret*" -o -iname "*key*" -o -iname "*senha*" \
    -o -iname "*user*" -o -iname "*cred*" -o -iname "*config*" -o -iname "*login*" -o -iname "*db*" -o -iname "*usuario*" \) \
    2>/dev/null >> "${filename}"
printf "\n" >> "${filename}"

# History files with sensitive commands
printf "History Files:\n" >> "${filename}"
find /home /root -type f \( -name '*_hist' -o -name '*_history' \) \
    -exec sh -c '
        file="$1"
        wordlist="$2"
        echo -e "\n[+] $(ls -al "$file")"
        echo -e "\nHistory Sensitive Commands:"
        grep -Eif "$wordlist" "$file" 2>/dev/null || echo "(nenhuma correspondência encontrada)"
    ' _ {} "$(realpath "$words_wordlist")" \; 2>/dev/null >> "${filename}"
printf "\n" >> "${filename}"

# Files with sensitive extensions
printf "Files with Sensitive Extensions:\n" >> "${filename}"
expr=""
while read -r ext; do
    ext="${ext#.}"  # remove ponto inicial se existir
    expr="$expr -o -iname '*.$ext'"
done < "$extensions_wordlist"
expr="${expr# -o }"
eval "find / -type f \( $expr \) 2>/dev/null" >> "${filename}"
printf "\n" >> "${filename}"

# Files with sensitive words in their content
printf "Files with Sensitive Words in Their Content:\n" >> "${filename}"
find / -type f -readable -size -5M 2>/dev/null \
    -exec sh -c '
        wordlist="$1"
        file="$2"
        grep -Eif "$wordlist" "$file" 2>/dev/null && echo -e "\n[+] Arquivo: $file\n"
    ' _ "$(realpath "$words_wordlist")" {} \; >> "${filename}"
printf "\n" >> "${filename}"

# Hidden files and directories
printf "Hidden Files and Directories:\n" >> "${filename}"
find / \( -type f -name '.*' -o -type d -name '.*' \) -exec ls -adl {} \; 2>/dev/null >> "${filename}"
printf "\n" >> "${filename}"

# Sensitive logs
printf "Sensitive Logs:\n" >> "${filename}"
for file in /var/log/* 2>/dev/null; do
    matches=$(grep -Ei "accepted|session opened|session closed|failure|failed|ssh|password changed|new user|delete user|sudo|COMMAND=|logs" "$file" 2>/dev/null)
    if [[ -n "$matches" ]]; then
        echo -e "\nLog file: $file"
        echo "$matches"
    fi
done >> "${filename}"
printf "\n" >> "${filename}"

base64 -w 0 ${filename} >> "${filename}_encoded"

# Print completion message
printf "Sensitive files enumeration completed. Output saved to %s\n" "${filename}"