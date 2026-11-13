# 🐧 Debian 12/13 script — beginner's step-by-step guide

**Never opened a Linux terminal? You can still follow Part A.** This page shows exactly how to download, check, and run the [Debian script](debian.sh) in its **Audit** mode first. It also explains the extra setup needed before **Apply**.

> [!IMPORTANT]
> **Run commands INSIDE your assigned Debian 12 or 13 virtual machine (VM), never on your own computer.** This script is **not** for Ubuntu, Linux Mint, FreeBSD, or Windows. Check the competition rules before downloading or using tools. Read the VM desktop README and preserve forensic questions before any changes.
>
> **AUDIT = inspect settings and write a report; APPLY = may change the computer.** It is fine to stop after Audit and use the [manual tasks](MANUAL-TASKS.md).

## A few words explained

| Term | Plain-English meaning |
|---|---|
| **VM** | The Debian computer running inside your VM software |
| **Terminal** | A window where you type commands into Linux |
| **`debian.sh`** | The script file you will download and run with Bash |
| **Bash** | The command interpreter that reads `.sh` scripts |
| **Audit** | Check settings and write reports without performing hardening fixes |
| **Apply** | Attempt the configuration changes you approved |
| **`image-config.json`** | A normal text file that tells the script which users/services to protect and what changes to make |
| **`sudo`** | Run a command with administrator (root) privileges; it may ask for your VM login password |

**How to enter commands:** Copy **one command at a time** from a gray code block, paste into Terminal (usually **Ctrl+Shift+V**), and press **Enter**. You don't type the dollar sign shown in some online Linux examples. Uppercase/lowercase filenames matter.

## ✅ Part A — First time: download → check → AUDIT

### Step 1 — Open Debian and read the VM instructions

1. Open the **Debian VM** in VMware or your authorized virtualization program; log into its normal assigned account.
2. Make sure you are inside the **VM desktop**, not your personal computer.
3. Read the **VM desktop README**. Record authorized administrators/users, software and services that must stay running, and any forbidden changes.
4. Answer/preserve forensic questions and record the initial Scoring Report before hardening.
5. Keep access to the VM console. Make a practice snapshot **only if the exercise rules allow one**.

### Step 2 — Download `debian.sh` inside the VM

1. Inside Debian, open Firefox, Firefox ESR, Chromium, or whichever browser is already installed.
2. Go straight to [debian.sh on GitHub](https://github.com/Superdancer16/cyberpatriot2026/blob/main/Linux/Debian/Scripts/debian.sh). The repository is **public**; no GitHub sign-in is required.
3. Click **Raw** above the code. You should see plain text beginning with **`#!/usr/bin/env bash`**.
4. Press **Ctrl+S**, choose the **Downloads** folder, and save it as **`debian.sh`**. If you see a file-type option, use plain text or **All files**. In some browsers you can also right-click **Raw → Save link as**.
5. Open the file manager and look inside **Downloads**. If you cannot find the download, press **Ctrl+J** in your browser and use **Show in folder**. The file should be named **`debian.sh`**, **not** `debian.sh.txt`, `debian.sh.html` or `debian.sh.sh`.
6. Do not save personal GitHub credentials in the VM. If the competition disallows outside downloads, stop and ask your coach for an approved transfer method.

> [!CAUTION]
> Do **not** execute a GitHub webpage saved as HTML, or copy commands from an unreviewed source. If the file starts with HTML rather than `#!/usr/bin/env bash`, re-download the **Raw** file.

### Step 3 — Open Terminal

1. On the **Debian VM desktop**, press **Ctrl+Alt+T**. If nothing happens, open the **Applications** menu and search **Terminal**.
2. A window appears with a cursor and a prompt (often ending in `$`). That prompt is **not part of a command**.
3. To paste into Terminal, use **Ctrl+Shift+V** or right-click → **Paste**. Then press **Enter**.

### Step 4 — Go into Downloads

Copy and run:

~~~bash
cd ~/Downloads
~~~

Now check your current folder:

~~~bash
pwd
~~~

**Expected:** A path like `/home/your-username/Downloads`. Check that the script exists:

~~~bash
ls -l debian.sh
~~~

**Expected:** A line containing the filename `debian.sh`. Check the first line:

~~~bash
head -n 1 debian.sh
~~~

**Expected:** `#!/usr/bin/env bash`. If you see HTML or **No such file**, go back to Step 2.

### Step 5 — Confirm Debian version and check script syntax

First check which operating system your VM is running:

~~~bash
grep -E '^(ID|VERSION_ID)=' /etc/os-release
~~~

**Expected:** `ID=debian`, with `VERSION_ID="12"` or `VERSION_ID="13"` (the quotes may vary). If it says Mint, Ubuntu, or another release, **stop**. This script is Debian-only.

Now check Bash syntax **without running the hardening actions**:

~~~bash
bash -n ./debian.sh && echo "Bash syntax OK"
~~~

**Expected:** `Bash syntax OK`. If you see an error instead, do not run the script; check that you downloaded the full Raw file.

**You do not need to make this script executable with `chmod`.** The guide runs it explicitly using `bash`.

### Step 6 — Run AUDIT before attempting any fixes

Copy and paste:

~~~bash
sudo bash ./debian.sh --audit
~~~

Press **Enter**. Debian may ask:

`[sudo] password for your-username:`

Type your **VM account password** and press **Enter**. **You will not see letters, dots, or asterisks while typing**; this is normal, not a frozen screen. Never type your personal computer or GitHub password.

**Expected:** The script checks accounts, groups, password policy, firewall, services, packages, SSH, and other basic settings. It reports that an audit file was saved. Audit **does not apply configured security fixes**; it does create report, log, and backup-directory files.

### Step 7 — Find your audit results

After running with `sudo`, the script normally stores logs under **`/root/DebianSecurityWork`**. To list the results:

~~~bash
sudo ls -lt /root/DebianSecurityWork
~~~

Look for the newest **`audit-...txt`** file, the `changes-...txt` log, `summary-...tsv`, and a `backups-...` folder. The script also prints the actual report paths, which take priority if your `sudo` environment uses a different home directory.

To display the **newest** audit report in Terminal on a normal Debian `sudo` setup, you can paste this entire line:

~~~bash
sudo sh -c 'cat "$(ls -t /root/DebianSecurityWork/audit-*.txt | head -n 1)"'
~~~

Read it and compare it with the VM README. An unexpected account or service is **not automatically unauthorized**.

**🎉 Your first successful Audit is complete. You can stop here.** For actual fixes, see the [Debian manual checklist](MANUAL-TASKS.md) and [complete handbook](../debian.md).

---

## ⚠️ Part B — Only with a reviewed config: APPLY

**Apply can alter logins, sudo rights, PAM, firewall rules, SSH, packages, services and files.** Before touching these, confirm that you still have a working VM console and that the active README approves the intended actions. If you're unfamiliar with the required users or services, ask your coach to review the config or use the manual guide instead.

### Step 8 — Create `image-config.json`

Still in Terminal, in the `~/Downloads` folder:

~~~bash
bash ./debian.sh --init-config --config ./image-config.json
~~~

**Expected:** A message saying `Created ./image-config.json`. If it says **Refusing overwrite**, your config already exists; **do not delete it**. Reopen and edit it.

Open the config with the built-in text editor:

~~~bash
nano ./image-config.json
~~~

You will see text with names, empty lists, braces, and `false` values. **This is a template, not a finished configuration.**

### Step 9 — Understand and complete the config

You should see fields like these already in the generated file:

~~~json
"ConfirmedReadme": false,
"ForensicsComplete": false,
"AuthorizedAdmins": [],
"AuthorizedUsers": [],
"RequiredServices": [],
"RequiredSoftware": [],
"RequiredPorts": []
~~~

**What these symbols mean:** `[]` is a list; `{}` is a group of settings; `false` means off/unconfirmed; `true` means on/confirmed. **Names need double quotes**. Multiple names in a list are separated by commas. JSON cannot contain comments.

Fill in these key fields **using the actual VM desktop README**:

1. **`AuthorizedAdmins`:** everyone who is supposed to have sudo/admin rights. Must contain at least one real, authorized administrator.
2. **`AuthorizedUsers`:** ordinary users who are allowed on this image.
3. **`RequiredServices`, `RequiredSoftware`, `RequiredPorts`:** anything that must keep working (web/FTP/database servers, SSH access, etc., when required).
4. **All requested changes:** choose only exact users, packages, settings, and files after confirming they are safe. Empty lists or `false` are better than guessing.
5. **`ForensicsComplete`:** only set to `true` after preserving necessary answers and evidence.
6. **`ConfirmedReadme`:** only set to `true` **last**, after reviewing the entire file against the README.

**Do not fill in fake usernames, remove users at random, or enable everything.** In particular, review `EnableUFW`, `InstallUFW`, `SSH`, `PasswordAging`, `RemoveUsers`, `RemovePackages`, `RemoveFiles`, and `ServiceHardening`. Enabling a firewall without required port rules or changing PAM/SSH can lock you out.


#### Step 9A — Collect the real names before editing

**First identify what is already on the VM.** The exercise README is the source of truth; these commands only help you identify exact Linux names. Run each separately in Terminal (they inspect the machine, but some may create normal shell/log activity).

~~~bash
whoami
id
getent passwd
getent group sudo
systemctl list-units --type=service --state=running --no-pager
ss -lntup
~~~

- `whoami` is your **current username**. The name after `uid=` in `id` is also useful. It is not automatically the only authorized administrator.
- `getent passwd` lists many **system accounts** too. Use the README, not this output alone, to decide who is authorized.
- A service's name is the **systemd unit** such as `ssh`, `apache2`, `smbd`, `vsftpd`, or `nginx`; it is **not** the description displayed in a GUI.
- `ss -lntup` shows listening ports. A displayed port is not automatically a port you should expose with UFW.
- Read the README first for required SSH, web, FTP, database, printing, or custom application functionality. The service must really exist on the VM before you configure it.

#### Step 9B — Exact field-by-field reference

**Value types:** `["item1", "item2"]` is a list of strings; `{"key": ["item"]}` is an object mapping names to lists; `{"option": true}` is an object with switches. A blank `[]` or `{}` means you are **not requesting that action**. Names/paths are case-sensitive on Linux.

**1. Identity, permissions, and requirements**

| JSON key | Exactly what belongs there; representative examples |
|---|---|
| `ConfirmedReadme` | `false` until you have checked **every** setting against the current VM README. Set `true` only at the very end. This is an approval switch, not a security fix. |
| `ForensicsComplete` | `false` until forensic questions and relevant evidence have been saved; then `true`. Does **not** answer the questions for you. |
| `AuthorizedAdmins` | Array of **actual usernames** that the README explicitly authorizes for sudo, e.g. `["labadmin"]`. **Important:** the script may add these existing accounts to the `sudo` group during Apply. Never put every user here. |
| `AuthorizedUsers` | Array of ordinary authorized usernames, e.g. `["labstudent", "labviewer"]`, **not** account display names. A person listed here isn't automatically an admin. |
| `RequiredServices` | Array of *actual systemd service names* needed by the image: examples `["ssh", "apache2"]` or `["smbd"]`, **only when the VM needs them**. Protects these services from automated disabling; enables service-specific hardening when selected. |
| `RequiredSoftware` | Exact Debian **APT package names** needed by the VM, e.g. `["openssh-server", "apache2"]`, not friendly application titles. Helps protect packages from removal. |
| `RequiredPorts` | Array of required listening ports with protocols, e.g. `["22/tcp", "80/tcp"]` for an SSH/web lab; `"53/udp"` for DNS if required. When `EnableUFW` is true, the script will issue `ufw allow` for these ports. **Never open every familiar port.** |
| `ScanPaths` | Existing **absolute directories** for file discovery, e.g. `["/home", "/tmp", "/var/tmp"]`. These are *inspection locations*, not deletion targets. Avoid scanning the full filesystem unnecessarily. |

**2. Users, groups, and passwords**

| JSON key | Exactly what belongs there; common use |
|---|---|
| `NewUsers` | List of **missing, README-required** usernames, e.g. `["labnewuser"]`. Each must also be in `AuthorizedUsers` or `AuthorizedAdmins`; the script prompts for its password. |
| `SetPasswords` | Existing authorized usernames whose passwords you intentionally need to reset, e.g. `["labstudent"]`. **Do not put passwords in JSON**; the script prompts interactively. |
| `ExpirePasswords` | Existing authorized users who must change password at next login, e.g. `["labstudent"]`. This calls `chage -d 0`; it can interrupt account usage. |
| `DemoteSudo` | Existing usernames that should no longer belong to the `sudo` group. Ordinary authorized users must also appear in `AuthorizedUsers`. Check access first. |
| `DisableUsers` | **Exact unauthorized usernames** to expire/disable, e.g. `["unauthorizedlab"]`. The script uses account expiration; it does not delete their home folders. Verify against README. |
| `RemoveUsers` | **Exact unauthorized usernames** to remove. Destructive; requires `--allow-removals` and a forensic-review guard. Prefer manual review first. |
| `NewGroups` | Array of missing *Linux group names* required by the README, e.g. `["labreaders"]`. Group creation alone does not add users. |
| `GroupMembers` | Object mapping **group name to array of authorized usernames**, e.g. `{"labreaders": ["labstudent"]}`. Adds existing users to existing groups (or groups created by `NewGroups`). |
| `RemoveGroupMembers` | Object mapping group to exact names whose membership should be removed, e.g. `{"labreaders": ["unapproveduser"]}`. Avoid removing required sudo/group access. |
| `PasswordAging` | Object with numbers for **new-account defaults** in `/etc/login.defs`: `{"PASS_MAX_DAYS": 90, "PASS_MIN_DAYS": 7, "PASS_WARN_AGE": 14}`. These numbers are examples, **not universal scoring values**. |
| `UserAging` | Object for **existing** authorized users: `{"labstudent": {"max": 90, "min": 7, "warn": 14}}`. These map to `chage` maximum days, minimum days, and warning days. |
| `PasswordQuality` | Object of integer options for `/etc/security/pwquality.conf`. Examples: `{"minlen": 12, "difok": 4}`. The script also accepts `maxrepeat`, `ucredit`, `lcredit`, `dcredit`, `ocredit`, `dictcheck` and `usercheck`; it requires `pam_pwquality.so` in the active PAM configuration. Don't invent missing modules or reorder PAM automatically. |
| `RemovePAMNullok` | `true` removes `nullok` from an active `pam_unix.so` line in `/etc/pam.d/common-auth`. Leave `false` until PAM is inspected and you have a console recovery path. Wrong PAM settings can lock out users. |

**3. Firewall, services, SSH, packages, and kernel**

| JSON key | Exactly what belongs there; common use |
|---|---|
| `EnableUFW` | `true` means **enable the UFW firewall** after adding required port rules. Leave `false` unless UFW is the intended firewall owner; check for existing nftables and current remote access. |
| `InstallUFW` | `true` permits installing the `ufw` package **if missing** when UFW enablement is selected; requires allowed APT/network access. |
| `FirewallAllowPorts` | Additional exact UFW port strings, e.g. `["443/tcp"]` if explicitly required. `RequiredPorts` are also added when UFW is enabled. |
| `SSH.DisableRootLogin` | `true` edits SSH server config to set `PermitRootLogin no`, when the SSH server exists and that is allowed by the README. |
| `SSH.DisableEmptyPasswords` | `true` sets `PermitEmptyPasswords no` for SSH. Test effective config and a second authorized SSH connection. |
| `DisableServices` | Array of exact **unneeded service names** to stop and disable, e.g. `["example-daemon"]` when confirmed unwanted. Never list required services, networking, or logging units. |
| `EnableRequiredServices` | `true` tries to start services in `RequiredServices` if they are down; database/DNS services receive extra manual-review safeguards. |
| `UpdatePackageLists` | `true` runs an APT package-index refresh; it doesn't itself install all upgrades. |
| `UpgradePackages` | `true` requests an APT-wide upgrade of currently installed packages. Review expected removals, dependencies, required services, and network access before enabling. |
| `UpdatePackages` | List of exact installed APT package names to upgrade individually, e.g. `["openssl", "curl"]` only when these packages are installed and updates are authorized. |
| `EnableDailyUpdateRefresh` | `true` enables a daily APT package-list refresh setting (not a guarantee every package is upgraded). |
| `Sysctl` | Object of **specific allowed kernel options → numeric values**, e.g. `{"net.ipv4.tcp_syncookies": 1}`. Supported choices include `net.ipv4.ip_forward`, `kernel.randomize_va_space`, and the permitted redirect/source-route keys in the script. **Do not blindly set forwarding to 0** on a router/VPN VM. |
| `FixShadowPermissions` | `true` removes group-write/world access from `/etc/shadow` and `/etc/gshadow` when necessary. Does not blindly reset all ownership/modes. |
| `AppArmorProfiles` | Array of **existing absolute profile paths** in `/etc/apparmor.d/`, e.g. `["/etc/apparmor.d/usr.sbin.some-daemon"]` *only after verifying the file exists*. Requests enforce mode; can break required apps. |

**4. Files, persistence, desktop, applications, and logs**

| JSON key | Exactly what belongs there; common use |
|---|---|
| `RemovePackages` | Exact unwanted Debian **package names** to purge, e.g. an explicitly prohibited game/torrent package. The script simulates dependencies first and requires removal approval. Do not remove a package the README requires. |
| `RemoveFiles` | Exact **absolute file paths**, not glob patterns or whole folders, e.g. `["/home/labstudent/Downloads/prohibited-file.mp3"]` **only if explicitly prohibited and evidence is saved**. Deletion is not automatically reversible. |
| `RemoveCronLines` | List of objects `{"User": "labstudent", "Line": "* * * * * /home/labstudent/unsafe-job.sh"}`. The line must **exactly match** a user's existing crontab entry; only use after proving it is unauthorized. |
| `RemoveHostsLines` | Array of **exact complete lines** from `/etc/hosts` that must be removed, e.g. `["198.51.100.8 example.test"]` only if the entry is unauthorized. Keep localhost/required mappings. |
| `DisableUnits` | Exact unneeded `systemd` service unit names such as `"example-daemon.service"`. Verify they are not required; stopping them affects running services. |
| `Desktop.DisableGdmAutologin` | `true` disables auto-login in **GDM3 only**. Debian images using LightDM or another login manager need manual guidance. |
| `Browsers.ChromiumBlockPopups` | `true` sets a Chromium-managed policy that blocks normal popups; only relevant when Chromium is installed. Verify required sites still work. |
| `Logging.EnableAuditd` | `true` starts/enables installed `auditd`; does not install it if missing. |
| `Logging.EnableRsyslog` | `true` starts/enables installed `rsyslog`; doesn't mean every log source becomes available. |
| `ServiceHardening.Apache` | `true` hardens a **README-required** `apache2` service, including security headers/TRACE settings. Test the website afterward. |
| `ServiceHardening.Nginx` | `true` hides version details for a **required** `nginx` service; verify proxy/sites. |
| `ServiceHardening.VsftpdNoAnonymous` | `true` disables anonymous logins for required `vsftpd`; verify authorized FTP access. |
| `ServiceHardening.SambaNoSMB1` | `true` enforces SMB2 or later for required `smbd`; check all authorized Windows clients. |
| `ServiceHardening.PostfixNoVRFY` | `true` disables SMTP `VRFY` for required `postfix`; verify mail flow. |

#### Step 9C — Complete example JSON (fictional practice VM)

**Open the [full example JSON file](EXAMPLE-CONFIG-DO-NOT-APPLY.json)** if you want a single copyable reference. It contains **every key in the generated script template**, with realistic *shapes* and some nonempty fictional values.

> [!CAUTION]
> **This is a reference, not a ready-to-run solution.** All `lab...` users and required services are invented. The values `90`, `7`, `14`, and `12` are teaching examples, not assumed CyberPatriot scoring requirements. The file deliberately keeps `ConfirmedReadme: false` and `ForensicsComplete: false` to prevent casual Apply. Replace the example with the **generated JSON** and review every field before ever setting confirmation flags.

~~~json
{
  "ConfirmedReadme": false,
  "ForensicsComplete": false,
  "AuthorizedAdmins": [
    "labadmin"
  ],
  "AuthorizedUsers": [
    "labstudent"
  ],
  "RequiredServices": [
    "ssh",
    "apache2"
  ],
  "RequiredSoftware": [
    "openssh-server",
    "apache2"
  ],
  "RequiredPorts": [
    "22/tcp",
    "80/tcp"
  ],
  "NewUsers": [],
  "DisableUsers": [],
  "RemoveUsers": [],
  "DemoteSudo": [],
  "SetPasswords": [],
  "ExpirePasswords": [],
  "NewGroups": [
    "labreaders"
  ],
  "GroupMembers": {
    "labreaders": [
      "labstudent"
    ]
  },
  "RemoveGroupMembers": {},
  "PasswordAging": {
    "PASS_MAX_DAYS": 90,
    "PASS_MIN_DAYS": 7,
    "PASS_WARN_AGE": 14
  },
  "UserAging": {
    "labstudent": {
      "max": 90,
      "min": 7,
      "warn": 14
    }
  },
  "PasswordQuality": {
    "minlen": 12,
    "difok": 4
  },
  "RemovePAMNullok": false,
  "EnableUFW": false,
  "InstallUFW": false,
  "FirewallAllowPorts": [],
  "UpdatePackageLists": false,
  "UpgradePackages": false,
  "UpdatePackages": [],
  "EnableDailyUpdateRefresh": false,
  "DisableServices": [],
  "EnableRequiredServices": false,
  "SSH": {
    "DisableRootLogin": false,
    "DisableEmptyPasswords": false
  },
  "Sysctl": {
    "net.ipv4.tcp_syncookies": 1
  },
  "FixShadowPermissions": false,
  "RemovePackages": [],
  "RemoveFiles": [],
  "RemoveCronLines": [],
  "RemoveHostsLines": [],
  "DisableUnits": [],
  "Desktop": {
    "DisableGdmAutologin": false
  },
  "Browsers": {
    "ChromiumBlockPopups": false
  },
  "AppArmorProfiles": [],
  "Logging": {
    "EnableAuditd": false,
    "EnableRsyslog": false
  },
  "ServiceHardening": {
    "Apache": false,
    "Nginx": false,
    "VsftpdNoAnonymous": false,
    "SambaNoSMB1": false,
    "PostfixNoVRFY": false
  },
  "ScanPaths": [
    "/home",
    "/tmp",
    "/var/tmp"
  ]
}
~~~

**How to adapt it:** If your VM has no required Apache, remove `"apache2"` from `RequiredServices` and `RequiredSoftware`. If SSH is not required, do not open `22/tcp`. If you have no required new groups, set `NewGroups` to `[]` and `GroupMembers` to `{}`. If the README gives no password-aging values, make `PasswordAging` and `UserAging` empty objects. Leave uncertain actions switched off; never turn every `false` to `true`.

**Before saving in nano:** Double-check that each string has quotes, arrays use square brackets, nested settings use curly braces, and there is no trailing comma after the last field. Continue with **Step 10** below to save and validate the JSON.

### Step 10 — Save the file in nano

1. Press **Ctrl+O** (the letter O, not zero): nano says **File Name to Write**.
2. Press **Enter** to keep the name `image-config.json`.
3. Press **Ctrl+X** to exit and return to Terminal.

To check that the text is correctly formatted as JSON **without applying anything**, run:

~~~bash
python3 -m json.tool ./image-config.json > /dev/null && echo "JSON format OK"
~~~

**Expected:** `JSON format OK`. If it reports a line/column error, use `nano ./image-config.json` again to fix missing quotes, commas, or brackets. **Valid JSON does not mean safe security settings.**

### Step 11 — Apply the reviewed choices

**Only when your README, users, protected services, and console access have all been verified**, run:

~~~bash
sudo bash ./debian.sh --apply --config ./image-config.json
~~~

If sudo asks for your VM password, type it and press **Enter**. The script asks you to type **`APPLY`**; type it exactly and press **Enter** **only if you are ready**. Otherwise cancel at the prompt.

The script performs its configured checks and changes, makes logs/backups, and performs follow-up auditing. **It does not automatically reboot Debian.**

### Step 12 — Review results and finish required manual checks

At the end of the script, it prints the paths to **Results**, **Log**, **Backups**, and **Audit**. Under normal `sudo` settings those files are in `/root/DebianSecurityWork`.

~~~bash
sudo ls -lt /root/DebianSecurityWork
~~~

Find the latest `summary-...tsv` and `changes-...txt` and read any **FAILED** or **REVIEW** entries. (A TSV is a text table; you can read it with an authorized viewer or with the `cat` command using the printed file path.)

| Result | Beginner meaning |
|---|---|
| `CHANGED` | An action ran; **it does not prove points were awarded** |
| `OK` | The inspection was acceptable or completed without a fix |
| `REVIEW` / `SKIPPED` | Check it manually against the VM README |
| `FAILED` | The script could not complete an action; read its error |
| `WOULD` | A change it considered without applying it |

Compare your Scoring Report with the original score. Test authorized logins/sudo, SSH, firewall access, web/FTP/database services and other explicitly required functionality. Follow the [remaining manual tasks](MANUAL-TASKS.md). If the score falls or a critical service breaks, **stop, identify the exact change, and undo only that change** using the recorded before-state or backup. Account/file deletion may not be reversible.

## Optional advanced options (not for a first run)

- **See command help:** `bash ./debian.sh --help`.
- **See section names:** `bash ./debian.sh --list`.
- **Run only selected sections:** append `--only users,groups,ssh` to your reviewed Apply command.
- **Skip the initial confirmation:** append `--yes`. This can skip password prompts; **not recommended for beginners**.
- **Allow exact configured deletions:** append `--allow-removals`. This may destroy files or accounts; only after README verification and forensic preservation.

## Troubleshooting

| Problem | What to do |
|---|---|
| `No such file or directory` | Run `cd ~/Downloads`, then `ls -l debian.sh`. If missing, inspect the browser's Downloads folder and exact filename |
| First line is HTML | Go back to GitHub and download the **Raw** file, not the webpage |
| `bash: syntax error` during `bash -n` | The download may be incomplete/corrupt; stop and verify the file |
| `Only Debian is supported` | Confirm `ID` and `VERSION_ID` using Step 5. Never run this on Mint or Ubuntu |
| sudo password seems invisible | This is normal. Carefully type the **VM user's password**, then press Enter |
| User is not allowed to use sudo | Stop and ask your coach/admin; do not bypass assigned permissions |
| Config already exists | Edit the existing `image-config.json`; never overwrite it without preserving your work |
| JSON validation fails | Check quotes, commas, brackets, and `true`/`false` (not `True`/`False`) |
| `AuthorizedAdmins cannot be empty` | Read the VM README and list the actual authorized admins; do not invent names |
| Audit report not in `/root` | Look at the exact report path printed by the script; `sudo` can vary by environment |
| SSH, login, or firewall stops working | **Stop applying changes**, use VM console and a known backup, and follow the [Debian recovery instructions](../debian.md) |

**Need more detail?** [Debian manual tasks](MANUAL-TASKS.md) · [Comprehensive Debian handbook](../debian.md) · [General script safety and rollback](../../../General/script-safety.md).

*This guide was checked against the script's command-line interface, but the rewritten steps have not been end-to-end tested on a Debian competition image.*
