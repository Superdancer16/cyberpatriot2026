# 🧰 Using the scripts safely

> [!TIP]
> **🧭 Quick orientation:** Use the links below to locate the right topic. Throughout the manuals, look for **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution**.

> [!WARNING]
> **Safety first:** This repository includes three optional platform scripts as well as documentation about *historical external tools*. Review the image README, competition rules, source licenses, and exact script content before using automation.

## 🧭 Quick links

[1. Decide whether external automation is appropriate](#topic-1) · [2. Interpret tool reports as leads](#topic-2)

---


This repository includes **three platform-specific scripts** in addition to its manual handbooks. The *historical upstream paths* in the table below still identify external tools and are **not** local filenames; the upstream configuration builder is not part of this repository.

### Current scripts actually included

- [Windows 10/11 PowerShell script and HOW-TO](../Windows%20Scripts/HOW-TO-RUN.md)
- [Windows Server PowerShell script and HOW-TO](../Windows%20Server%20Scripts/HOW-TO-RUN.md)
- [Debian Bash script and HOW-TO](../Linux%20Scripts/HOW-TO-RUN.md)
- [Central script index with manual-task links](../Scripts/README.md)

### Historical upstream script examples (reference only)

| Upstream family | Historical path | Manual replacement |
|---|---|---|
| Linux | `scripts/linux/harden.sh` | [Mint](../Linux/linux-mint.md), [Ubuntu](../Linux/ubuntu.md), [Debian](../Linux/debian.md) |
| Windows | `scripts/windows/Harden.ps1` | [Windows](../Windows/windows-10-11.md), [Server](../Windows/windows-server.md) |
| FreeBSD | `scripts/freebsd/harden.sh` | [FreeBSD](../Linux/freebsd.md) |

---

<a id="topic-1"></a>
## 1. Decide whether external automation is appropriate

- [ ] Done

**🎯 What:** Review a tool before allowing it to change an image.

**💡 Why it matters:** Old hardening scripts can remove required accounts, expose password hashes, rewrite repositories for an obsolete release, or destroy evidence. An audit mode can still create logs, caches and backups; do not assume it is forensically read-only.

**🛑 Before changing anything:** Check competition rules on outside tools, internet access and snapshots. Finish relevant forensic questions. Record the upstream repository, revision, license, scope, inputs and proposed changes. A README claim that a tool is safe is not verification.

**🖱️ Clicking (GUI):** Open the script as text in Notepad or a text editor. Search for user deletion, file removal, package removal, firewall changes, password handling and downloads. Do not double-click an unknown script.

**🔎 Typing (check):** In a Linux terminal, inspect a downloaded script without executing it:

```bash
less ./harden.sh
```

Press `/` to search, `n` for the next match and `q` to leave. In Windows PowerShell:

```powershell
Get-Content -LiteralPath .\Harden.ps1
Get-FileHash -LiteralPath .\Harden.ps1 -Algorithm SHA256
Get-AuthenticodeSignature -LiteralPath .\Harden.ps1
```

A hash identifies bytes; it establishes trust only when compared with a trusted published hash. An unsigned script is not automatically malicious, and a valid signature is not proof of suitability.

**🛠️ Typing (fix, only when appropriate):** Use the manual checklist for the individual setting. Do not paste a download-and-execute command or bypass execution policy merely to make an unknown file run.

**✅ Check it worked:** Repeat the native OS inspection after any authorized tool run. Test actual logins, web pages, file shares and other required functions. Read the full log, including errors and skipped items.

**↩️ Undo:** Use the tool's actual recorded backup path after inspecting its contents. Restore one setting at a time and repeat syntax and function checks. Restoring a registry export merges keys; it does not necessarily remove newly added values. Restoring files alone does not undo account deletion or package removal.

**⚠️ Warnings:** Never reuse one password for all users, put passwords on command lines, publish hash files, assume every change is backed up, or skip checklist items because a tool reports success.

---

<a id="topic-2"></a>
## 2. Interpret tool reports as leads

| Report word | Next manual step |
|---|---|
| OK | Inspect the effective setting; verify it matches the README |
| CHANGED | Inspect the new value and test the required function |
| WOULD | Review the proposed action; nothing has been verified as fixed |
| SKIPPED / REVIEW | Make an explicit README-based decision |
| FAILED | Read the error and use the relevant manual procedure |

Keep logs private and note the time of each change. See [forensics](../General/All/forensics-questions.md) before collecting or altering potential evidence.
