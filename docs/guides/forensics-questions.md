# Forensics questions

Forensics questions are text files on the desktop (`Forensics Question 1.txt`, …). Each one asks something about the computer, and you type the answer into the file. They're often worth **more than any single fix**, so do them **first**, before anything you change destroys the evidence.

## How to answer
1. Open the file. Read the **whole** question, including the example answer format.
2. Find the answer.
3. Type it after `ANSWER:` **exactly** in the format asked: same capitals, full path if asked, no extra spaces.
4. **Save** the file (Ctrl+S). Check the Scoring Report: a correct answer shows up within a minute or two.

> [!TIP]
> If there's a question you can't answer in 10 minutes, move on and come back later. A question often becomes obvious once you've explored the system.

---

## The common question types

### "What is the hash of file X?"

| | Linux | Windows (PowerShell) | FreeBSD |
|---|---|---|---|
| SHA-256 | `sha256sum file` | `Get-FileHash file -Algorithm SHA256` | `sha256 file` |
| SHA-1 | `sha1sum file` | `Get-FileHash file -Algorithm SHA1` | `sha1 file` |
| MD5 | `md5sum file` | `Get-FileHash file -Algorithm MD5` | `md5 file` |

Copy only the long string of letters and numbers. Windows prints it in **upper case**. If the question shows a lower-case example, type it in lower case.

### "Decode this message"
Look at the text and guess the encoding:

| Looks like | Probably | Decode with |
|---|---|---|
| Letters, numbers, `+` `/`, often ends with `=` or `==` | **Base64** | Linux: `echo 'aGVsbG8=' \| base64 -d` · Windows: `[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aGVsbG8='))` |
| Only `0-9` and `a-f`, even length | **Hex** | `echo '68656c6c6f' \| xxd -r -p` |
| Only `0` and `1` in groups of 8 | **Binary** | `echo '01101000 01101001' \| perl -lape '$_=pack"(B8)*",@F'` |
| Normal letters but scrambled words | **ROT13 / Caesar** | `echo 'uryyb' \| tr 'A-Za-z' 'N-ZA-Mn-za-m'` |
| `%20`, `%3A` | **URL encoding** | `python3 -c "import urllib.parse,sys;print(urllib.parse.unquote(sys.argv[1]))" 'hi%20there'` |

Several layers are common (e.g. base64 of hex). Decode one layer at a time. **CyberChef** (gchq.github.io/CyberChef) does all of these in a browser, and its "Magic" operation guesses the encoding for you.

### "Find the file that…" / "What is the name of the hidden file…"

| | Linux | Windows |
|---|---|---|
| By name | `sudo find / -iname '*secret*' 2>/dev/null` | `Get-ChildItem C:\ -Recurse -Force -Filter *secret* -ErrorAction SilentlyContinue` |
| Containing text | `sudo grep -rIl 'needle' /home /etc /opt 2>/dev/null` | `Get-ChildItem C:\Users -Recurse -File -Force -ErrorAction SilentlyContinue \| Select-String 'needle' -List \| Select Path` |
| Changed recently | `sudo find / -xdev -mmin -120 -type f 2>/dev/null` (last 2 hours) | `Get-ChildItem C:\Users -Recurse -File -Force -EA 0 \| Where LastWriteTime -gt (Get-Date).AddDays(-2)` |
| Hidden files | names start with `.`: `ls -la` | `Get-ChildItem -Force`, or Explorer → View → Hidden items |

### "Which user…" / "What is the UID / group of…"
```bash
id bob                         # Linux: UID, groups
getent passwd bob              # Linux: home folder, shell
getent group sudo
```
```powershell
Get-LocalUser bob | Format-List *          # Windows: description, last logon, SID
Get-LocalGroupMember Administrators
Get-ADUser bob -Properties *               # Domain Controller
```

### "What port / program is the backdoor using?"
```bash
sudo ss -tulpn                 # Linux: port + program name + PID
ls -l /proc/<PID>/exe          # which file the program is
```
```powershell
Get-NetTCPConnection -State Listen | Select LocalPort, OwningProcess
Get-Process -Id <PID> | Select Name, Path
```

### "Who logged in / what did the attacker do?" (logs)
| Where | Look at |
|---|---|
| Linux (Mint/Ubuntu) | `/var/log/auth.log` (logins, sudo), `/var/log/syslog`, `last`, `lastb` (failed) |
| Debian 12 | `journalctl _COMM=sshd`, `journalctl _COMM=sudo`, `last` |
| Shell history | `/home/*/.bash_history`, `/root/.bash_history` |
| Windows | **Event Viewer** (`eventvwr.msc`) → Windows Logs → **Security**. Event **4624** = logon, **4625** = failed logon, **4720** = user created, **4732** = added to group |
| Windows PowerShell history | `C:\Users\<user>\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt` |
| Web server | `/var/log/apache2/access.log`, `C:\inetpub\logs\LogFiles\` |

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4720} | Format-List TimeCreated, Message   # who was created
```

### "What's in this picture / document?"
- Hidden text in a file: `strings file | less`
- Picture details (camera, GPS, author): `exiftool photo.jpg` (Linux: `sudo apt install libimage-exiftool-perl`), or on Windows right-click → **Properties → Details**
- Office documents are ZIP files: copy, rename to `.zip`, and look inside.

### "What is the password / key for…"
Often in a text file, browser saved passwords, a script, or shell history:
```bash
sudo grep -rIi 'password' /home /opt /var/www 2>/dev/null | head
cat /home/*/.bash_history
```

### "Which package / program installed…"
```bash
dpkg -S /usr/bin/somefile       # which package owns a file
grep ' install ' /var/log/dpkg.log     # what was installed and when
```
Windows: **Settings → Apps** sorted by **Install date**, or **Event Viewer → Application** log (source **MsiInstaller**).

---

## Don't lose the evidence

- Don't delete a user, file or program until you've checked whether a question mentions it.
- If you must change something, **copy it first** (`cp file ~/evidence/`).
- Don't empty the Recycle Bin / Trash until forensics is finished.

## Repeatable investigation procedures

These are practice examples, not active competition answers. Use the question's exact path, hash algorithm, date range and answer format. **Read-only** below means the command is intended not to modify the target deliberately; live inspection still creates shell history/events and can update access times. A live machine is not a forensic disk image. Exports/copies write new files. Scans, quarantine, password resets, package installation, service restarts and deletion can alter evidence.

### F.1 Preserve a file and record metadata

- [ ] Done

**What:** Record path, size, timestamps, owner/permissions and content hash before remediation.

**Why it matters:** A renamed executable can keep the same bytes/hash. Timestamps can be manipulated, and copying a file changes some destination metadata.

**Before changing anything:** Read every forensic question first. Do not execute or preview an untrusted executable/document. Use a private evidence folder outside a web root or shared directory and record the system timezone.

**Clicking (GUI):** Windows **Explorer → View → Show → Hidden items / File name extensions**; right-click the file → **Properties → Details / Security**. Linux file manager **Ctrl+H** shows dotfiles, then **Properties** for the specific file. Do not change attributes just to reveal a file. Use a text editor only when safe and disable active content/macros.

**Typing (check):** Windows PowerShell, elevating only for protected evidence:

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

**Check it worked:** Source and copied content hashes should match at collection time. Record source/destination and the collection time privately. Do not claim the copy preserves every forensic attribute or constitutes a complete chain of custody.

**Undo:** No target change is intended. Remove a redundant working copy only after answers and required evidence have been preserved, following the exercise rules.

**Warnings:** NTFS alternate streams, ACLs, sparse files and symlinks need special care; a simple cross-filesystem copy can lose metadata. Reading a log while it is changing may produce different hashes between passes. Do not upload private samples or credentials to public analysis sites.

### F.2 Find hidden files and inspect encodings safely

- [ ] Done

**What:** Search the smallest relevant scope and decode data without executing it.

**Why it matters:** Filename extensions can be misleading. Base64 is encoding, not encryption; decoded output may be a command or binary rather than readable text.

**Before changing anything:** Record the question's filename/content hints. Search the named user's folder before the whole disk. Access-denied output means coverage is incomplete, not that no file exists.

**Clicking (GUI):** Show hidden files/extensions as in F.1. Open ordinary text in a plain editor rather than a shell; do not enable Office macros or launch scripts.

**Typing (check):** Windows:

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

**Check it worked:** Compare the result's format with the question. Decode one layer at a time; invalid padding/bytes may mean the wrong encoding or incomplete input. Preserve the original string.

**Undo:** No target change is intended; close the text view without saving accidental edits. Do not edit the evidence to make a decoder accept it.

**Warnings:** `strings`, metadata and signatures are clues. An unsigned executable is not automatically malicious; a signed file can still be abused.

### F.3 Processes, connections and persistence correlation

- [ ] Done

**What:** Link a listener to its executable, account and launch mechanism.

**Why it matters:** A process name alone is weak evidence. Killing it can destroy transient state and leave its scheduler/service ready to restart it.

**Before changing anything:** Record the question and collection time. Leave the process running during initial evidence collection unless immediate containment is explicitly required.

**Clicking (GUI):** Windows **Task Manager → Details**, enable **PID / Command line** columns; inspect **Services**, **Startup apps** and Task Scheduler **Actions / Triggers / General**. Linux System Monitor provides PID/user clues; use the terminal for systemd/cron and executable paths.

**Typing (check):** Windows elevated PowerShell:

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

**Typing (fix, only when appropriate):** No remediation in this investigation procedure. Save the requested answer/evidence first, then use the platform's task/service/account procedure for reversible containment.

**Check it worked:** Explain the evidence chain in your notes: local address/port → PID → executable/command line → account → task/service/cron/key. Correlate with logs before attributing an action to a person.

**Undo:** No intentional target change. Do not restart a process to reproduce its original transient state; that creates new evidence.

**Warnings:** Web servers, Python applications and remote support tools may legitimately listen. A listening socket does not prove it was reachable through the firewall or used by an attacker.

### F.4 Event logs, shell history and answer verification

- [ ] Done

**What:** Correlate recorded activity and submit only the requested answer.

**Why it matters:** Logs can be absent, rotated, tampered with or incomplete. Shell history records typed commands selectively and does not prove they succeeded.

**Before changing anything:** Record timezone and avoid clearing logs. Preserve the relevant original files/exports before changing accounts, audit policy or services.

**Clicking (GUI):** Windows `eventvwr.msc` → **Windows Logs → Security** → **Filter Current Log**; inspect the full event message and **Details → XML View** when needed. **Save All Events As** exports a copy. On Linux use the installed Logs viewer or `journalctl`.

**Typing (check):** Windows:

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

**Check it worked:** Compare multiple sources, identify time/actor/target accurately, and type the answer into the desktop question file in the exact requested format. Save with **Ctrl+S**, reopen to confirm persistence, then check the report after its normal refresh interval. A delayed result is not a reason to alter evidence or brute-force guesses.

**Undo:** If you typed an answer in the wrong place, edit only that answer field. Do not change question text, invent missing events or restore logs over the live originals.

**Warnings:** Never include real active competition answers in shared notes. Do not publish private log contents, password material or identifying data in a public pull request.
