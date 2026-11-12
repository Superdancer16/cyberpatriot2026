# 🔎 Forensics — Searchable Question Finder

> [!TIP]
> Start here when a forensics prompt looks unfamiliar. Open the correct operating-system guide, then use **Ctrl+F** for the terms from the question. These are investigative guides, not a collection of live competition answers.

## Choose the guide for your image

| Image | Searchable handbook | Useful Ctrl+F terms |
|---|---|---|
| Windows 10 / Windows 11 | [Windows forensics](../../Windows/forensics.md) | Base64, ROT13, Caesar, XOR, encryption, BitLocker, file signature, alternate data stream, event log, registry, port, hash |
| Windows Server / Active Directory | [Server forensics](../../Server/forensics.md) | domain user, SID, group, Group Policy, DNS, DHCP, IIS, SMB, certificate, CMS, DPAPI, AES, event log |
| Debian / Mint / Ubuntu | [Linux forensics](../../Linux/forensics.md) | GPG, OpenSSL, ROT13, Base64, hex, ELF, UID, GID, chmod, sudo, SSH, cron, journalctl, PCAP |

## If your question does not match a chapter

1. **Identify the artifact:** Is it a message, file, archive, user account, service, network capture, or log entry?
2. **Copy exact wording:** Search the right guide using a distinctive noun, extension, cipher name, port, or tool.
3. **Check layers:** A suspicious string might be encoded more than once; encoding is not the same as encryption, and genuine encryption requires the correct key or authorized recovery method.
4. **Preserve evidence first:** Record paths, timestamps and copies when appropriate. Do not delete suspicious files just because the question mentions them.
5. **Verify the result:** Check that decoded text, a username, hash, or event timestamp actually answers the question.

**Start:** Read [the image README](../General/reading-the-readme.md) and finish forensic question files before hardening. The platform guides above cover the detailed question types; the preserved cross-platform investigation procedures below cover safe collection, decoding, process correlation, and log verification.

[Complete file index](../INDEX.md) · [Repository home](../../README.md)

---

## Quick question-answer workflow (all images)

1. Read every desktop forensic-question file and note the **exact requested format** (value, name, full path, capitalization, encoding, or timestamp).
2. Preserve the original clue and record the system time/timezone. Avoid deleting or restarting anything mentioned in a question.
3. Use the platform guide above to investigate, or the cross-platform workflows below when you need a repeatable evidence-handling procedure.
4. Type the final answer **after `ANSWER:` in the existing question file**, save it with **Ctrl+S**, reopen to confirm, and verify the Scoring Report after its normal update interval. Do not alter the question wording.
5. If a question takes too long, record what you checked and return after other independent tasks. Do not brute-force guesses or destroy evidence.

Forensics commands described as read-only still cause incidental shell history, timestamps, or log entries. Copies and exports write new files; preserve evidence with permission. Do not upload private files, credentials, or VM artifacts to public websites.

<a id="freebsd-quick-reference"></a>
## FreeBSD forensic quick reference (BSD, not Linux)

The [FreeBSD handbook](../FreeBSD/freebsd.md) is a **separate** BSD-specific reference. Do **not** assume GNU `stat`, Linux `/proc`, `ss`, `systemctl`, or `sha256sum` are present. Use FreeBSD's native tools when the exercise involves FreeBSD.

| Question type | FreeBSD read-only starting point |
|---|---|
| SHA-256 file hash | `sha256 /path/to/file` |
| SHA-1 / MD5 file hash | `sha1 /path/to/file` / `md5 /path/to/file` |
| Owner, mode, size, timestamp | `stat -x /path/to/file` |
| User accounts and groups | `id username`, `pw usershow username`, `pw groupshow wheel` |
| Listening ports and owning process | `sockstat -4 -6 -l` |
| Inspect a process | `ps -p 4242 -o pid,ppid,user,command`, `procstat -b 4242` |
| Logs and security events | Review configured `/var/log/` syslog files; if auditing is enabled, consult `praudit` and the exercise's audit configuration |
| Scheduled tasks and startup | Review `crontab -l`, `/etc/crontab`, `/etc/rc.conf`, and relevant `/usr/local/etc/rc.d/` scripts |

Replace paths, usernames, and PIDs with values from the current question; record the time and never change logs just to make the answer appear.

---

## Repeatable investigation procedures

These are practice examples, not active competition answers. Use the question's exact path, hash algorithm, date range and answer format. **Read-only** below means the command is intended not to modify the target deliberately; live inspection still creates shell history/events and can update access times. A live machine is not a forensic disk image. Exports/copies write new files. Scans, quarantine, password resets, package installation, service restarts and deletion can alter evidence.

### F.1 Preserve a file and record metadata

- [ ] Done

**🎯 What:** Record path, size, timestamps, owner/permissions and content hash before remediation.

**💡 Why it matters:** A renamed executable can keep the same bytes/hash. Timestamps can be manipulated, and copying a file changes some destination metadata.

**🛑 Before changing anything:** Read every forensic question first. Do not execute or preview an untrusted executable/document. Use a private evidence folder outside a web root or shared directory and record the system timezone.

**🖱️ Clicking (GUI):** Windows **Explorer → View → Show → Hidden items / File name extensions**; right-click the file → **Properties → Details / Security**. Linux file manager **Ctrl+H** shows dotfiles, then **Properties** for the specific file. Do not change attributes just to reveal a file. Use a text editor only when safe and disable active content/macros.

**🔎 Typing (check):** Windows PowerShell, elevating only for protected evidence:

```powershell
Get-Date -Format o
Get-TimeZone
Get-Item -LiteralPath 'C:\Users\bob\Documents\sample.txt' -Force | Format-List FullName,Length,Attributes,CreationTimeUtc,LastWriteTimeUtc,LastAccessTimeUtc
Get-Acl -LiteralPath 'C:\Users\bob\Documents\sample.txt' | Format-List Owner,AccessToString
Get-FileHash -LiteralPath 'C:\Users\bob\Documents\sample.txt' -Algorithm SHA256
```

Linux terminal:

```bash
date -Is
timedatectl
stat /home/bob/Documents/sample.txt
sha256sum /home/bob/Documents/sample.txt
```

FreeBSD root/user `sh` as appropriate uses `stat -x PATH` and `sha256 PATH`, not GNU `stat -c`. A SHA-256 digest has 64 hexadecimal characters; the filename is not part of the hash answer.

**Typing (preserve, writes a copy):** Linux, with appropriate authorization and a private destination:

```bash
sudo install -d -m 700 /root/cp-evidence
sudo cp -a /home/bob/Documents/sample.txt /root/cp-evidence/sample.txt
sudo sha256sum /root/cp-evidence/sample.txt
```

On Windows copy into an access-restricted evidence folder and hash the copy:

```powershell
Copy-Item -LiteralPath 'C:\Users\bob\Documents\sample.txt' -Destination 'C:\CP-Backups\sample-evidence.txt'
Get-FileHash -LiteralPath 'C:\CP-Backups\sample-evidence.txt' -Algorithm SHA256
```

**✅ Check it worked:** Source and copied content hashes should match at collection time. Record source/destination and the collection time privately. Do not claim the copy preserves every forensic attribute or constitutes a complete chain of custody.

**↩️ Undo:** No target change is intended. Remove a redundant working copy only after answers and required evidence have been preserved, following the exercise rules.

**⚠️ Warnings:** NTFS alternate streams, ACLs, sparse files and symlinks need special care; a simple cross-filesystem copy can lose metadata. Reading a log while it is changing may produce different hashes between passes. Do not upload private samples or credentials to public analysis sites.

### F.2 Find hidden files and inspect encodings safely

- [ ] Done

**🎯 What:** Search the smallest relevant scope and decode data without executing it.

**💡 Why it matters:** Filename extensions can be misleading. Base64 is encoding, not encryption; decoded output may be a command or binary rather than readable text.

**🛑 Before changing anything:** Record the question's filename/content hints. Search the named user's folder before the whole disk. Access-denied output means coverage is incomplete, not that no file exists.

**🖱️ Clicking (GUI):** Show hidden files/extensions as in F.1. Open ordinary text in a plain editor rather than a shell; do not enable Office macros or launch scripts.

**🔎 Typing (check):** Windows:

```powershell
Get-ChildItem -LiteralPath 'C:\Users\bob' -Recurse -File -Force -ErrorAction Continue | Where-Object Name -like '*secret*' | Select-Object FullName,Length,LastWriteTimeUtc
```

Linux:

```bash
sudo find /home/bob -xdev -type f -iname '*secret*' -ls
sudo grep -rInI -- 'specific phrase' /home/bob/Documents
file /home/bob/Documents/sample.txt
```

`-I` avoids treating binary data as text; `-xdev` excludes mounted filesystems, so record that limitation. `file` describes magic bytes heuristically, not whether a file is safe.

**Typing (decode only):** Linux literal test:

```bash
printf '%s' 'aGVsbG8=' | base64 --decode
```

PowerShell:

```powershell
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aGVsbG8='))
```

Expected output is `hello`. A PowerShell `-EncodedCommand` is commonly UTF-16LE; inspect as text with `[Text.Encoding]::Unicode.GetString(...)` when appropriate. Do not pass decoded text to `Invoke-Expression`, `bash`, `cmd` or a script interpreter.

**✅ Check it worked:** Compare the result's format with the question. Decode one layer at a time; invalid padding/bytes may mean the wrong encoding or incomplete input. Preserve the original string.

**↩️ Undo:** No target change is intended; close the text view without saving accidental edits. Do not edit the evidence to make a decoder accept it.

**⚠️ Warnings:** `strings`, metadata and signatures are clues. An unsigned executable is not automatically malicious; a signed file can still be abused.

### F.3 Processes, connections and persistence correlation

- [ ] Done

**🎯 What:** Link a listener to its executable, account and launch mechanism.

**💡 Why it matters:** A process name alone is weak evidence. Killing it can destroy transient state and leave its scheduler/service ready to restart it.

**🛑 Before changing anything:** Record the question and collection time. Leave the process running during initial evidence collection unless immediate containment is explicitly required.

**🖱️ Clicking (GUI):** Windows **Task Manager → Details**, enable **PID / Command line** columns; inspect **Services**, **Startup apps** and Task Scheduler **Actions / Triggers / General**. Linux System Monitor provides PID/user clues; use the terminal for systemd/cron and executable paths.

**🔎 Typing (check):** Windows elevated PowerShell:

```powershell
Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
Get-NetUDPEndpoint | Select-Object LocalAddress,LocalPort,OwningProcess
Get-CimInstance Win32_Process -Filter 'ProcessId=4242' | Select-Object ProcessId,ParentProcessId,ExecutablePath,CommandLine
Get-CimInstance Win32_Service | Where-Object ProcessId -eq 4242 | Select-Object Name,StartName,PathName
```

Replace 4242 with the actual PID. Linux:

```bash
sudo ss -tulpn
ps -p 4242 -o pid,ppid,user,lstart,args
sudo readlink /proc/4242/exe
sudo tr '\0' ' ' < /proc/4242/cmdline
```

If shell redirection lacks permission, run the read within an authorized root shell; prefixing only `tr` with sudo does not elevate the shell's `<` open. On FreeBSD use `sockstat -4 -6 -l`, `ps -p 4242 -o pid,ppid,user,command` and `procstat -b 4242` instead of `/proc` assumptions.

Inspect Linux persistence read-only:

```bash
sudo crontab -u bob -l
systemctl list-timers --all
systemctl cat example.service
sudo grep -RIn -- '4242\|suspect-name' /etc/cron.d /etc/systemd/system 2>/dev/null
```

A PID may be reused; correlate executable/start time, not the number alone. Inspect SSH Match blocks, include files and authorized_keys fingerprints; unauthorized users/keys are potential persistence but require README comparison. Do not print private keys.

For Windows registry investigation:

```powershell
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
Get-ScheduledTask | Select-Object TaskPath,TaskName,Actions,Triggers,Principal
```

**🛠️ Typing (fix, only when appropriate):** No remediation in this investigation procedure. Save the requested answer/evidence first, then use the platform's task/service/account procedure for reversible containment.

**✅ Check it worked:** Explain the evidence chain in your notes: local address/port → PID → executable/command line → account → task/service/cron/key. Correlate with logs before attributing an action to a person.

**↩️ Undo:** No intentional target change. Do not restart a process to reproduce its original transient state; that creates new evidence.

**⚠️ Warnings:** Web servers, Python applications and remote support tools may legitimately listen. A listening socket does not prove it was reachable through the firewall or used by an attacker.

### F.4 Event logs, shell history and answer verification

- [ ] Done

**🎯 What:** Correlate recorded activity and submit only the requested answer.

**💡 Why it matters:** Logs can be absent, rotated, tampered with or incomplete. Shell history records typed commands selectively and does not prove they succeeded.

**🛑 Before changing anything:** Record timezone and avoid clearing logs. Preserve the relevant original files/exports before changing accounts, audit policy or services.

**🖱️ Clicking (GUI):** Windows `eventvwr.msc` → **Windows Logs → Security** → **Filter Current Log**; inspect the full event message and **Details → XML View** when needed. **Save All Events As** exports a copy. On Linux use the installed Logs viewer or `journalctl`.

**🔎 Typing (check):** Windows:

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security';Id=4624,4625,4720,4732;StartTime=(Get-Date).AddDays(-2)} -MaxEvents 100 | Format-List TimeCreated,Id,Message
```

4624 success/4625 failure refer to logon events; 4720 creates an account and 4732 changes a local security-group membership. Domain global group changes can use other IDs such as 4728. Distinguish **Subject** (actor) from **Target** (changed account). For 4624 inspect logon type, source address and account; a service logon is not an interactive console login.

Linux:

```bash
sudo journalctl --since '2026-01-01 10:00:00' --until '2026-01-01 11:00:00' -u ssh --no-pager
last -F
sudo lastb -F
sudo grep -n 'sudo:' /var/log/auth.log
```

Replace dates with the question's interval. Missing auth.log/lastb records can mean that logging component/file is absent; use the journal and document the limitation. Inspect rotated logs without changing them; use `zless` for compressed logs where available. FreeBSD uses its configured syslog files and, if enabled, audit trails read with `praudit`.

**Typing (preserve, writes export):** Windows elevated PowerShell:

```powershell
wevtutil epl Security C:\CP-Backups\Security-before.evtx
```

Use a private existing destination and a unique filename. This exports; it does not clear the source.

**✅ Check it worked:** Compare multiple sources, identify time/actor/target accurately, and type the answer into the desktop question file in the exact requested format. Save with **Ctrl+S**, reopen to confirm persistence, then check the report after its normal refresh interval. A delayed result is not a reason to alter evidence or brute-force guesses.

**↩️ Undo:** If you typed an answer in the wrong place, edit only that answer field. Do not change question text, invent missing events or restore logs over the live originals.

**⚠️ Warnings:** Never include real active competition answers in shared notes. Do not publish private log contents, password material or identifying data in a public pull request.
