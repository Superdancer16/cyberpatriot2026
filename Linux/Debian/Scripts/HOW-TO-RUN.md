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
