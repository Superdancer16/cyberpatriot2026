# 🧰 Optional Automation — Existing Script Directory

> [!WARNING]
> These scripts may change users, policies, services, software, network access, or files when configured to apply changes. **Read the competition rules and VM README, complete necessary forensics, inspect the code, and run Audit mode before any Apply mode.** Do not assume a script is permitted or safe for every image.

The script source files **remain in their original directories**. This folder provides one shared navigation page only; no scripts have been moved, removed, renamed, or combined.

## Select the matching operating system

| Target | Source script | Beginner HOW-TO | After-script manual checks | Complete handbook |
|---|---|---|---|---|
| Windows 10/11 workstation | [windows-10-11.ps1](../Windows%20Scripts/windows-10-11.ps1) | [Run instructions](../Windows%20Scripts/HOW-TO-RUN.md) | [Manual tasks](../Windows%20Scripts/MANUAL-TASKS.md) | [Windows manual](../Windows/windows-10-11.md) |
| Windows Server 2016/2019/2022 | [windows-server.ps1](../Windows%20Server%20Scripts/windows-server.ps1) | [Role-aware run instructions](../Windows%20Server%20Scripts/HOW-TO-RUN.md) | [AD/roles manual tasks](../Windows%20Server%20Scripts/MANUAL-TASKS.md) | [Server manual](../Windows/windows-server.md) |
| Debian 12/13 | [debian.sh](../Linux%20Scripts/debian.sh) | [Bash run instructions](../Linux%20Scripts/HOW-TO-RUN.md) | [Manual tasks](../Linux%20Scripts/MANUAL-TASKS.md) | [Debian manual](../Linux/debian.md) |

**Mint, Ubuntu, and FreeBSD:** Use their [manual guides](../Linux/README.md); do not assume the Debian script supports these operating systems.

## Safe order of work

1. Read the image README for required accounts, services, ports, software, and restrictions.
2. Preserve and answer relevant [forensics questions](../Forensics/README.md) before modifying evidence.
3. Review the script and its matching HOW-TO; verify the operating system and role.
4. Run the documented **Audit** mode if permitted; inspect the findings.
5. Configure only explicitly authorized changes. Do not copy assumptions from a different image.
6. Check every action and verify required functions after any permitted Apply operation.
7. Use the linked MANUAL-TASKS file and original comprehensive guide for anything not safely automated.

**Historical external script names are not included in this repository.** The local file paths are the ones in the operating-system table above. The original upstream comparison and detailed safe-tool review workflow have been consolidated below.

[Complete file index](../INDEX.md) · [Repository home](../README.md)

---

## Historical upstream script names (not local files)

| Historical upstream family | Historical path | Current local manual |
|---|---|---|
| Linux | `scripts/linux/harden.sh` | [Mint](../Linux/linux-mint.md), [Ubuntu](../Linux/ubuntu.md), [Debian](../Linux/debian.md) |
| Windows | `scripts/windows/Harden.ps1` | [Windows 10/11](../Windows/windows-10-11.md), [Windows Server](../Windows/windows-server.md) |
| FreeBSD | `scripts/freebsd/harden.sh` | [FreeBSD](../Linux/freebsd.md) |

The historical toolkit's separate configuration builder is **not** part of this repository. Do not try historical paths as though they were in the local Git tree.

<a id="review-external-or-historical-tools-before-running"></a>
## Review external or historical tools before running

The following detailed verification and rollback procedures were retained from the former supplemental script guide. Examples such as `Harden.ps1` refer to hypothetical **external downloads**, not to this repository's scripts. For the local scripts, follow the exact HOW-TO linked above.

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

Keep logs private and note the time of each change. See [forensics](../Forensics/README.md) before collecting or altering potential evidence.
