
![linkaboo](/img/linkaboo.png)

# linkaboo

**linkaboo** is a powerful and modular Linux enumeration toolkit designed for post-exploitation, CTFs, and privilege escalation analysis. It collects a wide range of system information and highlights potential weak spots in the system.

---

### 🧠 Features

* ✅ Basic system and user information
* 🔐 Sensitive files, hidden files, and insecure logs
* 📁 World-writable files and directories, SUID/SGID binaries, and capabilities
* ⏰ Scheduled tasks including crontabs and systemd timers

---

### 📁 Project Structure

```
linkaboo/
├── main.sh                    # Main orchestrator script
├── scripts/                   # Sub-scripts for modular enumeration
│   ├── basic-linux-enum.sh
│   ├── sensitive-files-enum.sh
│   ├── files-dir-permissions-enum.sh
│   └── scheduled-tasks-enum.sh
├── wordlists/                 # Custom wordlists used for sensitive content matching
│   ├── sensitive-extensions-wordlist.txt
│   └── sensitive-words-wordlist.txt
└── results/                   # Output folder (auto-created)
```

---

### 🚀 Usage

```bash
chmod +x main.sh scripts/*.sh
./main.sh
```

> All output is saved in the `results/` folder and automatically compressed if tools like `tar`, `zip`, or `7z` are available.


Aqui está o trecho para adicionar ao seu **README** explicando como compilar a versão monolítica com `shc` ou diretamente com `gcc`:

---

### 🛠️ Compilation as a Standalone Binary

You can convert the `linkaboo_monolithic.sh` into a standalone executable using [`shc`](https://github.com/neurobin/shc):

```bash
shc -f linkaboo_monolithic.sh -o linkaboo
```

This will produce a binary named `linkaboo`, which can be run independently:

```bash
./linkaboo
```

The output of this binary will be in the `\tmp` folder instead of the default `results` folder.

> The script will also generate a C source file (`linkaboo_monolithic.sh.x.c`) that can be compiled manually if needed.

#### ✅ Manual compilation with `gcc` (alternative method):

```bash
gcc linkaboo_monolithic.sh.x.c -o linkaboo
```

Make sure `gcc` is installed. You can check with:

```bash
gcc --version
```

> ⚠️ **Note:** The compiled binary will only run on the same architecture and environment it was built on (e.g., x86\_64 Linux with compatible glibc).

---

### 🔍 Notes

* The scripts **do not require root**, but results will be more complete if run as root.
* Designed to be portable and fast.
* Ideal for post-exploitation enumeration, local privilege escalation checks, or Linux CTF footholds.

---


### ⚠️ Warning

Linkaboo is noisy. It performs extensive file system and process enumeration, which may trigger EDRs, logging systems, or alerts in monitored environments. Use it only where you have permission.

---

