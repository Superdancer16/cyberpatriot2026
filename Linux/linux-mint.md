# Linux Mint checklist (Mint 20 / 21 / 22, Cinnamon)

Linux Mint is in **Round 1, the State round, and the Semifinals** this season. It is built on Ubuntu, so almost everything here also works on Ubuntu (see the [Ubuntu checklist](ubuntu.md) for the few differences).

**How to use this page**
- Work **top to bottom**. The order matches where points usually are.
- Each item has: **What** · **Why it matters** · **Clicking** (the GUI way) · **Typing** (terminal commands) · **Check it worked** · and sometimes a ⚠️ warning about when *not* to do it.
- `alice`, `bob` etc. are example names. **Use the names from your README.**
- New to the terminal? Read [Linux terminal basics](linux-mint.md#22-complete-linux-terminal-basics-embedded) first (10 minutes).
- Follow the manual procedures and verify every item; automation is not included in this repository.

---


**Prioritization reflects recurring topics in public checklists, not published per-fix score values.** The competition README, required accounts/services and evidence-preservation rules take precedence. Inspect first; change only what is allowed; verify and record rollback.


> [!NOTE]
> **How this guide uses the CyberPatriot XVI–XIX research catalog:** **Official** means documented by CyberPatriot; **Training** means found in public practice/training materials; **Community** means covered by published checklists or educational repositories; **Inferred** means normal vendor-supported security hardening that is **not known to have been scored**. The report is a topic inventory, **not a list of actual confidential competition vulnerabilities, scoring keys or guaranteed points**. In the research-expansion sections below, every suggested change requires a verified scenario reason, a saved original value and a check of required service availability. All PowerShell/Bash examples are **manual commands inside Markdown**, not automation scripts. The image README and current rules always take precedence.

## Part 1 — Basics / Information Needed

### Linux Mint information to know before starting

- [ ] Identify Mint version, Ubuntu base, **Cinnamon/MATE/Xfce** desktop, display manager and available login recovery.
- [ ] Understand sudo, APT packages, Flatpak apps, systemd, UFW, SSH, desktop lock and LightDM-specific settings.
- [ ] Know that Linux Mint GUI paths differ from Ubuntu GNOME, especially **Users and Groups**, **Update Manager** and **Login Window**.
- [ ] Read the image README for authorized users, required services and prohibited software before changes.

**Typing (check):**

~~~bash
cat /etc/os-release
id
systemctl status display-manager --no-pager
command -v ufw
command -v flatpak
~~~

**GUI:** Cinnamon Menu → Administration / Preferences, and the installed login/desktop tools. Only edit the display manager actually installed. Full terminal training remains in the advanced appendix.

## Part 2 — First Things to Do

Open the README, record users/required services, preserve forensics answers and maintain administrator access.

### 0. Before you touch anything

#### 0.1 Read the README
- [ ] Done

Write down the admins, users, critical services, required software and prohibited items. See [Reading the README](../General/All/reading-the-readme.md).

#### 0.2 Take a snapshot
- [ ] Done

**What:** Save the current state of the VM so you can go back if you break it.

**Clicking:** In VMware: **VM → Snapshot → Take Snapshot…**, name it "start".

> [!TIP]
> Take another snapshot whenever your score goes up a lot. If something breaks, **VM → Snapshot → Revert**. You lose the changes since that snapshot, but the scoring engine keeps the points you already earned.

#### 0.3 Open a terminal and check you have admin rights
- [ ] Done

**Typing:** press **Ctrl + Alt + T**, then:
```bash
sudo -v        # asks for YOUR password; no error = you are an admin
whoami         # shows which user you are logged in as
```

#### 0.4 Open the Scoring Report
- [ ] Done

Double-click **Scoring Report** on the desktop. Keep it open in a browser tab and refresh it as you work.

---

---

### 1. Forensics questions (do these FIRST)

#### 1.1 Answer every forensics question before changing anything
- [ ] Done

**What:** Open each `Forensics Question N.txt` on the desktop, find the answer, and type it after `ANSWER:` in the file, then save.

**Why it matters:** They're often worth the most points, and fixing things (deleting users, files) can destroy the evidence you need.

**Typing (the most common tools):**
```bash
sudo find / -iname "*secret*" 2>/dev/null          # find a file by name
sudo grep -rIl "password" /home 2>/dev/null        # find files that contain a word
sha256sum /path/to/file                            # hash of a file
echo 'aGVsbG8=' | base64 -d                        # decode base64
sudo grep -E 'Accepted|Failed' /var/log/auth.log   # who logged in / failed to
```
More techniques: [Forensics questions guide](../General/All/forensics-questions.md).

> [!WARNING]
> Answers must be **exact**: right spelling, capitals, and full paths when asked. Don't delete the "ANSWER:" line.

#### 1.2 Fast path: run the hardening script
- [ ] Done

**What:** Prepare a manual baseline. The upstream automation is not included in this repository.

**Why it matters:** A status label cannot establish that a setting is correct on this particular image.

**Before changing anything:** Read the README and preserve forensics evidence. Record your current administrator account, required users, services, ports, and initial score.

**Clicking (GUI):** Open the README and Scoring Report from the desktop. In your VM manager, create a practice snapshot only if the round rules permit it. Open the platform's account and service management screens described below.

**Typing (check):** Use the read-only inventory commands in the next section of this checklist. Save their output in a private working folder; do not publish passwords or password hashes.

**Typing (fix, only when appropriate):** Work through one manual item at a time below. Read every command before entering it. There is no script to download from this repository.

**Check it worked:** Repeat each inspection, test the README-required function, then refresh the Scoring Report. A lack of new points does not prove the change failed.

**Undo:** Reverse the most recent change using the recorded value or the procedure's backup. A VM snapshot rollback can discard later fixes; use it only within the rules and verify the resulting score again.

**Warnings:** Never use a guessed list of authorized users or bulk-delete files. See [Using the scripts safely](../Misc%20Softwares/using-the-scripts.md) for the limits of external tools.

---

## Part 3 — Commonly Assessed High-Priority Checks

Prioritize account privileges, password policy, firewall and signed updates before lengthy service configuration.

### 2. Users and groups

#### 2.1 See every user on the computer
- [ ] Done

**What:** Get the list of real (human) users and compare it with the README.

**Clicking:** **Menu → Administration → Users and Groups**. Enter your password. Every user is listed on the left with their account type (Administrator / Standard).

**Typing:**
```bash
awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd
```
This prints every user with a user ID (UID) of 1000 or more, which means the real people.

#### 2.2 Delete users who are not in the README
- [ ] Done

**What:** Remove each account that isn't listed as an authorized admin or user.

**Why it matters:** An extra account is the easiest way for an attacker to get back in.

**Clicking:** In **Users and Groups**, select the user → click **Delete** (the "−" button) → keep or delete their files.

**Typing:**
```bash
sudo userdel mallory          # delete the account (keeps /home/mallory for now)
```

**Check it worked:** `id mallory` should say `no such user`.

> [!CAUTION]
> Check the spelling against the README **three times**. Deleting an authorized user is a penalty. Never delete yourself, `root`, or system accounts (UID below 1000 like `www-data`, `syslog`, `messagebus`).

#### 2.3 Create users the README says should exist
- [ ] Done

**Clicking:** **Users and Groups → Add** (the "+" button), choose Standard or Administrator, enter the name, then set a password.

**Typing:**
```bash
sudo adduser erin             # asks for a password and details
```

#### 2.4 Fix who is an administrator
- [ ] Done

**What:** Only the README's admins should be in the `sudo` group (that's what "Administrator" means on Mint).

**Clicking:** In **Users and Groups**, click the user, then set **Account type** to *Administrator* or *Standard*.

**Typing:**
```bash
getent group sudo                       # who has sudo now
sudo deluser bob sudo                   # take admin away from bob
sudo usermod -aG sudo alice             # give admin to alice
getent group adm                        # 'adm' can read logs - normally admins only
```

**Check it worked:** `getent group sudo` lists only the README admins.

#### 2.5 Look for hidden root accounts and hidden users
- [ ] Done

**What:** Find accounts with UID 0 (secret root copies), and accounts with a low UID that can still log in.

**Why it matters:** `useradd -o -u 0 toor` makes a second root that doesn't show up in Users and Groups.

**Typing:**
```bash
awk -F: '$3 == 0 {print $1}' /etc/passwd                          # should print ONLY: root
awk -F: '$3 < 1000 && $7 !~ /(nologin|false|sync)$/ {print $1, $3, $7}' /etc/passwd
```
The second command lists low-UID accounts that have a real shell. Normally that's only `root` (and maybe `postgres` if PostgreSQL is installed).

**Fix:**
```bash
sudo usermod --expiredate 1970-01-02 toor       # only after confirming this account is unauthorized; preserve evidence first
sudo usermod -s /usr/sbin/nologin mallory       # stop a hidden user from logging in
```

#### 2.6 Check other powerful groups
- [ ] Done

**Typing:**
```bash
for g in root shadow disk lxd docker sambashare; do getent group $g; done
```
`shadow` can read password hashes. `disk` can read the raw hard drive. `lxd` and `docker` can become root. Normal users shouldn't be in them:
```bash
sudo gpasswd -d carol shadow
```

#### 2.7 Give users strong passwords
- [ ] Done

**What:** Change every authorized user's password (except your own, unless the README says so) to something strong.

**Why it matters:** Planted users often have passwords like `password` or `123456`.

**Clicking:** **Users and Groups** → click the user → click the password field → set a new one.

**Typing:**
```bash
sudo passwd bob
```
Use 12+ characters with upper case, lower case, a number and a symbol, e.g. `Blue-Train-42!x`. **Write it down.**

> [!WARNING]
> **Don't change your own password** unless the README asks. If you do, you must remember it, because the screen lock and `sudo` will ask for it.

#### 2.8 Lock the root account
- [ ] Done

**What:** Make sure nobody can log in directly as `root`. Admins use `sudo` instead.

**Typing:**
```bash
sudo passwd -S root      # "root L ..." = locked (good). "root P ..." = has a password
sudo passwd -l root      # lock it
```

**Check it worked:** `sudo passwd -S root` shows `L` after the name.

> [!CAUTION]
> Only do this if **you** can use `sudo` (step 0.3 worked). Otherwise you lock yourself out of admin.

#### 2.9 Accounts with no password
- [ ] Done

**What:** Find accounts that have **no password at all**, so anyone can log in as them by just pressing Enter.

**Why it matters:** An empty password is a common planted problem. Removing `nullok` (step 3.5) blocks these logins, but the account should still get a real password or be locked.

**Typing:**
```bash
sudo passwd -S -a | awk '$2 == "NP" {print $1}'   # NP = no password; should print nothing
sudo passwd bob                                    # README user: give them a strong password
sudo passwd -l mallory                             # account that shouldn't log in: lock it
```

**Check it worked:** the first command prints nothing.

---

---

### 3. Password and lockout policy

#### 3.1 Password aging (how long passwords last)
- [ ] Done

**What:** Passwords expire after 90 days, can't be changed again for 7 days, and users get 14 days' warning.

**Typing:**
```bash
sudo nano /etc/login.defs
```
Find these lines (Ctrl+W searches) and change them to:
```
PASS_MAX_DAYS   90
PASS_MIN_DAYS   7
PASS_WARN_AGE   14
```
Save with **Ctrl+O, Enter**, exit with **Ctrl+X**.

**Check it worked:** `grep ^PASS_ /etc/login.defs`

#### 3.2 Apply aging to the users who already exist
- [ ] Done

**Why:** `login.defs` only affects **new** users.

**Typing (repeat for each user):**
```bash
sudo chage -M 90 -m 7 -W 14 bob
sudo chage -l bob            # check: "Maximum number of days" = 90
```

#### 3.3 Password complexity (pwquality)
- [ ] Done

**What:** Make Linux reject weak passwords when someone changes theirs.

**Typing:**
```bash
sudo apt install libpam-pwquality
sudo nano /etc/security/pwquality.conf
```
Set (remove the `#` at the start of each line):
```
minlen = 12
ucredit = -1
lcredit = -1
dcredit = -1
ocredit = -1
difok = 3
maxrepeat = 3
usercheck = 1
dictcheck = 1
enforce_for_root
```
`-1` means "at least one" (upper case, lower case, digit, other symbol).

Also check the PAM line exists:
```bash
grep pwquality /etc/pam.d/common-password
```
It should look like: `password requisite pam_pwquality.so retry=3 ...`. You can add the same options to the end of that line (`minlen=12 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1`).

#### 3.4 Password history (no re-using old passwords)
- [ ] Done

Use the supported `pam_pwhistory` procedure in [17.2](#172-password-aging-pam-and-lockout-without-breaking-login). Do not copy an old `pam_unix remember=` line across releases or append a duplicate module. Preserve the current PAM stack and test with an ordinary user before closing the recovery console.

#### 3.5 No logins with an empty password
- [ ] Done

**What:** Remove the word `nullok` from `/etc/pam.d/common-auth`.

**Why:** `nullok` lets an account with an empty password log in without typing anything.

**Typing:**
```bash
grep nullok /etc/pam.d/common-auth
sudo sed -i 's/ nullok//' /etc/pam.d/common-auth
```

**Check it worked:** `grep -c nullok /etc/pam.d/common-auth` prints `0`.

#### 3.6 Account lockout after failed logins (careful!)
- [ ] Done

**What:** Limit repeated invalid authentication attempts using a module supported by the installed release.

**Why it matters:** Incorrect PAM control flow can deny all users or bypass policy. Package versions and authentication providers determine integration; release age alone is not a reliable module test.

Use [17.2's complete PAM backup, module discovery, lockout verification and recovery procedure](#172-password-aging-pam-and-lockout-without-breaking-login). Never replace the primary PAM block with a generic example or add obsolete pam_tally2 rules based solely on a version name. Keep a root console and test a separate ordinary user's actual password login.

---

---

### 4. Firewall (UFW)

#### 4.1 Turn on the firewall
- [ ] Done

**What:** Block every incoming connection except the ones the README needs.

**Clicking:** **Menu → Preferences → Firewall Configuration** (or type `firewall` in the menu's search box). Switch **Status** on, set **Incoming: Deny** and **Outgoing: Allow**.

**Typing:**
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh              # ONLY if SSH is a critical service in the README
sudo ufw enable
sudo ufw logging on
```

**Check it worked:** `sudo ufw status verbose` shows `Status: active` and `Default: deny (incoming)`.

#### 4.2 Allow the critical services (and nothing else)
- [ ] Done

| README needs | Command |
|---|---|
| SSH | `sudo ufw allow 22/tcp` |
| Web server (Apache/Nginx) | `sudo ufw allow 80/tcp` and `sudo ufw allow 443/tcp` |
| FTP | `sudo ufw allow 21/tcp` |
| Samba (file sharing) | `sudo ufw allow samba` |
| MySQL from other computers | `sudo ufw allow 3306/tcp` |
| DNS server | `sudo ufw allow 53` |

#### 4.3 Remove rules an attacker added
- [ ] Done

**Typing:**
```bash
sudo ufw status numbered
sudo ufw delete 3            # delete rule number 3 (check the number first!)
```
Look for odd ports like 4444, 1337, 31337, 6667, or "ALLOW Anywhere" on a port no critical service uses.

---

---

### 5. Updates

> [!TIP]
> Start updates early: they can take 20+ minutes. You can keep working in another window while they run.

#### 5.1 Install all updates
- [ ] Done

**Clicking:** **Menu → Administration → Update Manager** → **Refresh** → **Install Updates**. If it asks to update itself first, say yes.

**Typing:**
```bash
sudo apt update
sudo apt full-upgrade -y
```

#### 5.2 Turn on automatic updates
- [ ] Done

**Clicking:** **Update Manager → Edit → Preferences → Automation** → turn on **Apply updates automatically**. On the **Options** tab, make sure **Refresh the list of updates automatically** is on.

The same switch from the terminal:
```bash
sudo mintupdate-automation upgrade enable                  # "Apply updates automatically"
systemctl is-enabled mintupdate-automation-upgrade.timer   # prints "enabled" when it's on
```

**Typing (the setting many scoring engines check):**
```bash
sudo apt install unattended-upgrades
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
```
Make it contain:
```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
```

#### 5.3 Check the software sources
- [ ] Done

**What:** Make sure updates come from the official Mint and Ubuntu servers only.

**Clicking:** **Menu → Administration → Software Sources**. Look at **PPAs** and **Additional repositories**. Remove anything you don't recognise. Make sure the official repositories are enabled.

**Typing:**
```bash
grep -rhv '^#' /etc/apt/sources.list /etc/apt/sources.list.d/ | grep .
```
Official addresses: `packages.linuxmint.com`, `archive.ubuntu.com`, `security.ubuntu.com` (or a country mirror). `[trusted=yes]` on a line is a **red flag**: it turns off signature checking.

#### 5.4 Packages "held" back from updating
- [ ] Done

```bash
apt-mark showhold              # anything listed will never update
sudo apt-mark unhold firefox   # change firefox to each name the line above printed
```

**Check it worked:** `apt-mark showhold` prints nothing.

#### 5.5 Update the apps the README mentions
- [ ] Done

Firefox, Thunderbird, LibreOffice and any critical service are updated by 5.1. Check Firefox with **Menu (≡) → Help → About Firefox**.

On Mint, Firefox is a normal `apt` package from the Mint servers (not a snap), so this shows anything still out of date:
```bash
apt list --upgradable 2>/dev/null | grep -Ei 'firefox|thunderbird|libreoffice'   # anything listed is out of date
```
If Update Manager never offers an update for a program, open **Update Manager → Edit → Preferences → Packages**. A package listed there is blocked from updating: select it and remove it from the list.

---

### Research expansion: Flatpak, desktop login and Cinnamon security

- [ ] Review installed software through **both APT and Flatpak** when applicable.

~~~bash
dpkg -l | grep -Ei 'firefox|ssh|vnc|steam|torrent|remote'
command -v flatpak
~~~

If Flatpak is present, separately run:

~~~bash
flatpak list --app
flatpak remotes --show-details
~~~

Do not uninstall apps because they have unusual names. Compare each with required/prohibited software and preserve forensic evidence. Preview dependencies before removing a Debian package.

- [ ] Verify the actual login manager and allowed autologin/guest settings.

~~~bash
systemctl status display-manager --no-pager
sudo grep -RnsE '^[[:space:]]*(autologin-user|autologin-user-timeout|allow-guest)' /etc/lightdm 2>/dev/null
~~~

On a Mint/LightDM image, use the installed **Login Window** GUI or the correct config file/override. On other display managers, these LightDM paths may be irrelevant. Back up an edited file and test login in a second session; **do not restart the display manager** while forensic answers are unsaved.

**Cinnamon screen locking:** Preferences → Screensaver / Screen Lock. Check available schemas as the desktop user (not sudo):

~~~bash
gsettings list-schemas | grep -E 'cinnamon|gnome.desktop.screensaver'
~~~

Record a setting before changing it; only use a schema and key that actually exist.

### Research expansion: common missed persistence and update checks

~~~bash
apt-mark showhold
apt list --upgradable 2>/dev/null
systemctl --failed
systemctl list-timers --all
sudo ss -lntup
~~~

**Read-only scoped file searches:**

~~~bash
sudo find /home /tmp /var/tmp -type f -mtime -2 -print 2>/dev/null
sudo find /usr/local/bin /usr/local/sbin -type f -perm /4000 -ls 2>/dev/null
~~~

**Why:** Suspicious scheduled jobs, unexpected listeners, software installations and SUID changes may indicate unauthorized persistence. However, some SUID files and timers are legitimate. Do not automatically delete all of them or purge desktop metapackages.

**Verify:** Browser, authorized user login, screen lock, sudo, required SSH/web/share traffic, updated score and saved forensic files. Restore only the specific changed setting if a normal task breaks.


### Research report expansion M-R1 — Users, sudo, UID 0 and PAM integrity

- [ ] Done

**Evidence:** Community/training, verified against native Linux tools. This is not an official scoring list.

**GUI:** Cinnamon **Menu → Administration → Users and Groups**; for service identities use Terminal. Read the image README before disabling users.

**Typing (check):**

~~~bash
getent passwd
getent group sudo
awk -F: '$3 == 0 {print $1, $3, $7}' /etc/passwd
sudo passwd -S -a
sudo grep -RnsE 'NOPASSWD|!authenticate|pam_exec|pam_permit|pam_debug' /etc/sudoers /etc/sudoers.d /etc/pam.d 2>/dev/null
~~~

**What to look for:** An unapproved human login, a second UID 0 account, a sudo rule granting unauthorized privileges, or a modified PAM module line. Service users and unusual installed policies may be legitimate; do not infer malice from a name alone.

**Fix only after verifying the exact unauthorized sudo membership:**

~~~bash
sudo gpasswd -d EXAMPLE_USER sudo
~~~

For an unauthorized login, after preserving its forensic evidence:

~~~bash
sudo usermod -L EXAMPLE_USER
sudo usermod -s /usr/sbin/nologin EXAMPLE_USER
~~~

**Verification:** Repeat **id EXAMPLE_USER**, **getent group sudo**, **sudo passwd -S EXAMPLE_USER**, and validate sudoers with **sudo visudo -c**. Test a second authorized admin login.

**Undo:** Restore recorded shell, lock status and group memberships (only if previously authorized). A password lock can leave SSH-key access or existing sessions possible—inspect them. Do not delete the only sudo account or root.

### Research report expansion M-R2 — Password aging, quality and lockout without breaking login

- [ ] Done

**Typing (check):**

~~~bash
grep -E '^PASS_(MAX_DAYS|MIN_DAYS|WARN_AGE)' /etc/login.defs
sudo chage -l EXAMPLE_USER
sudo grep -nEv '^[[:space:]]*(#|$)' /etc/pam.d/common-auth /etc/pam.d/common-password
dpkg-query -W libpam-pwquality libpam-runtime libpam-modules 2>/dev/null
~~~

**Before PAM changes:** Keep a working root/console recovery path; preserve actual config files:

~~~bash
sudo cp -a /etc/pam.d/common-auth /etc/pam.d/common-auth.before-cp
sudo cp -a /etc/pam.d/common-password /etc/pam.d/common-password.before-cp
~~~

**Fix only if the README specifies the illustrative 90-day maximum, 1-day minimum and 7-day warning:**

~~~bash
sudo chage -M 90 -m 1 -W 7 EXAMPLE_USER
~~~

For complexity/history/failed-login controls, inspect the actual installed module and supported **pam-auth-update** profiles. Never paste a new full PAM stack from Debian or a historical GitHub script; module order mistakes can lock out all logins.

**Verification:** Re-run **chage -l** and test a new normal-user login, sudo, and an authorized password change from a separate terminal/session before closing the original administrator session.

**Undo:** Restore the original per-user aging settings or the specific PAM files from backups using your retained root/console access.

### Research report expansion M-R3 — Mint repository integrity, PPAs, updates and Snap preference

- [ ] Done

**Evidence:** Mint-specific community/vender topics; package managers vary by Mint release.

**GUI:** **Menu → Administration → Software Sources**. Inspect **Official Repositories, PPAs, Additional Repositories**; compare against the README and installed release. Then use **Update Manager → Refresh**.

**Typing (check):**

~~~bash
cat /etc/os-release
cat /etc/upstream-release/lsb-release 2>/dev/null
apt-cache policy
sudo grep -RHE '^(deb |Types:|URIs:|Suites:|Components:|Signed-By:|Trusted:)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
apt-mark showhold
sudo dpkg --audit
~~~

**Mint version note:** Mint 21 commonly uses Ubuntu **jammy**, Mint 22 uses **noble**; do not copy release names without checking actual installed OS/base. Unknown PPAs and Trusted: yes sources merit inspection but may be intentionally required.

**Check Snap preference if relevant:**

~~~bash
dpkg-query -W snapd 2>/dev/null
cat /etc/apt/preferences.d/nosnap.pref 2>/dev/null
~~~

**Fix:** Back up the **specific** confirmed malicious repository/PPAs file and disable only that source using Software Sources or careful editor changes. Never delete all PPAs, remove snapd automatically, or disable APT signature checks to silence errors.

**Verification:**

~~~bash
sudo apt update
apt -s upgrade
~~~

Check no unexpected sources/signature errors remain and all required software works. **Undo:** Restore the changed source/preference file backup; reverting sources does not revert installed package versions.

## Part 4 — Services, Desktop, Software and Threat Investigation

Inspect services, software, screen lock, SSH, permissions, privileged groups and persistent threats.

### 6. Services

#### 6.1 See what's running and listening
- [ ] Done

**Typing:**
```bash
systemctl list-units --type=service --state=running
sudo ss -tulpn             # programs listening on network ports
```

#### 6.2 Turn off services the README doesn't need
- [ ] Done

**Typing:**
```bash
sudo systemctl disable --now vsftpd        # stop it now AND at boot
sudo apt purge vsftpd                      # remove it completely (if the README doesn't need it)
```

| Service | Package | Usually… |
|---|---|---|
| Telnet server | `telnetd`, `inetutils-telnetd` | **Remove** (sends passwords in plain text) |
| FTP server | `vsftpd`, `proftpd-core`, `pure-ftpd` | Remove unless the README needs FTP |
| Web server | `apache2`, `nginx` | Remove unless the README needs it |
| Database | `mysql-server`, `mariadb-server`, `postgresql` | Remove unless needed |
| Samba | `samba` | Remove unless file sharing is needed |
| SNMP | `snmpd` | Remove |
| NFS | `nfs-kernel-server`, `rpcbind` | Remove unless needed |
| Printing | `cups` | Disable unless printing is needed |
| Avahi (network discovery) | `avahi-daemon` | Disable |
| VNC / remote desktop | `x11vnc`, `vino`, `xrdp` | Remove unless needed |
| DNS server | `bind9` | Remove unless the README needs DNS |
| Mail server | `postfix`, `dovecot-core` | Remove unless the README needs mail |
| Web proxy | `squid` | Remove unless needed |
| Old insecure servers | `tftpd-hpa`, `xinetd`, `openbsd-inetd`, `rsh-server`, `nis` | **Remove** |
| SSH server | `openssh-server` | Keep **only** if the README mentions SSH |

> [!CAUTION]
> **Never** turn off a service the README lists as critical. Disabling a critical service is a penalty on almost every image.

#### 6.3 Make sure the critical services are running
- [ ] Done

```bash
systemctl status ssh             # "active (running)" in green = good
sudo systemctl enable --now ssh  # start it if it isn't
```

---

---

### 7. Prohibited software and files

#### 7.1 Hacking tools
- [ ] Done

**Clicking:** **Menu → Administration → Synaptic Package Manager**. Search each name, right-click → **Mark for Complete Removal** → **Apply**.

**Typing:**
```bash
dpkg -l | grep -Ei 'nmap|wireshark|john|hydra|aircrack|ophcrack|hashcat|nikto|sqlmap|ettercap|metasploit|netcat|ncat|medusa|kismet|dsniff'
sudo apt purge nmap wireshark john hydra
sudo apt autoremove
```

#### 7.2 Games
- [ ] Done

```bash
dpkg -l | grep -Ei 'aisleriot|gnome-mines|gnome-sudoku|mahjongg|minetest|supertux|freeciv|0ad|wesnoth|bsdgames|steam'
sudo apt purge aisleriot gnome-mines
```

#### 7.3 File-sharing and remote-access programs
- [ ] Done

```bash
dpkg -l | grep -Ei 'transmission|qbittorrent|deluge|frostwire|teamviewer|anydesk|x11vnc|tightvnc|vino'
flatpak list 2>/dev/null       # Mint's own app store installs flatpaks
snap list 2>/dev/null          # Mint has no snap unless someone added it
```
> [!NOTE]
> Mint installs **Transmission** (a torrent program) by default. Remove it unless the README needs it: `sudo apt purge transmission-gtk transmission-common`

#### 7.4 Media files (music and video)
- [ ] Done

**Typing:**
```bash
sudo find /home /root /tmp /srv /opt /var/www -type f \( -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.wav' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.flac' -o -iname '*.ogg' -o -iname '*.wma' -o -iname '*.m4a' \) 2>/dev/null
sudo rm "/home/bob/Music/song.mp3"
```

> [!WARNING]
> Check the forensics questions first. A question might ask about one of these files.

#### 7.5 Other files that break policy
- [ ] Done

Password lists, credit card or social security number files, packet captures (`.pcap`), and hacking scripts:
```bash
sudo find /home /root /tmp /opt -type f \( -iname '*password*' -o -iname '*.pcap' -o -iname '*creditcard*' -o -iname '*.kdbx' \) 2>/dev/null
sudo ls -la /home/*/ /tmp /var/tmp /opt     # look for anything odd, including hidden .files
```

---

---

### 8. Login screen and desktop

#### 8.1 No guest sessions and no automatic login
- [ ] Done

**Clicking:** **Menu → Administration → Login Window → Users** tab. Turn **Allow guest sessions** off (this switch only appears if guest sessions are installed). Clear the **Automatic login** username. Turn **Hide the user list** and **Allow manual login** on, so the login screen doesn't show everyone's name.

**Typing:**
```bash
sudo nano /etc/lightdm/lightdm.conf
```
Under `[Seat:*]` (if the file is new or empty, type the `[Seat:*]` line too):
```
[Seat:*]
allow-guest=false
autologin-user=
greeter-hide-users=true
greeter-show-manual-login=true
```
Also check the other LightDM files, because they can turn these back on. A section called `[SeatDefaults]` is the old name for `[Seat:*]` and counts the same:
```bash
grep -rE 'autologin|allow-guest|hide-users' /etc/lightdm/ /etc/xdg/lightdm/ /usr/share/lightdm/lightdm.conf.d/
```

**Check it worked:** the `grep` shows no user name after `autologin-user=` and no `allow-guest=true`. The changes show on the login screen after the next restart.

#### 8.2 Lock the screen when idle
- [ ] Done

**Clicking:** **Menu → System Settings → Screensaver**:
- **Delay before starting the screensaver:** 5 minutes
- **Lock the computer after the screensaver starts:** on
- **Delay before locking:** Lock immediately

**Typing:** run these in **your own** terminal, **without** `sudo` (`sudo gsettings` changes root's settings, not yours):
```bash
gsettings set org.cinnamon.desktop.session idle-delay 300           # 300 seconds = 5 minutes
gsettings set org.cinnamon.desktop.screensaver lock-enabled true
gsettings set org.cinnamon.desktop.screensaver lock-delay 0         # lock as soon as it starts
```
If it says **The key is not writable**, inspect dconf/organizational policy and verify the effective setting; do not assume it is correct.

**Check it worked:** `gsettings get org.cinnamon.desktop.session idle-delay` prints `uint32 300` and `gsettings get org.cinnamon.desktop.screensaver lock-enabled` prints `true`. (The lock is on by default; the 15-minute delay is what usually needs fixing.)

#### 8.3 Don't open USB drives and CDs automatically
- [ ] Done

**What:** Stop Mint from mounting, opening and running programs from a USB stick or CD the moment it is plugged in.

**Why it matters:** A planted USB stick can start malware on its own if autorun is on.

**Clicking:** **Menu → Preferences → Preferred Applications → Removable media** tab → turn **Prompt or start programs on media insertion** off.

**Typing:** in **your own** terminal, **without** `sudo` (if a key is not writable, inspect the active dconf policy):
```bash
gsettings set org.cinnamon.desktop.media-handling autorun-never true     # never run programs from media
gsettings set org.cinnamon.desktop.media-handling automount false        # don't mount drives by themselves
gsettings set org.cinnamon.desktop.media-handling automount-open false   # don't open a window for them
```

**Check it worked:** `gsettings get org.cinnamon.desktop.media-handling autorun-never` prints `true`.

> [!NOTE]
> With automount off, a USB stick still works: click it in the file manager's side bar to open it.

#### 8.4 Ctrl + Alt + Delete doesn't restart the computer
- [ ] Done

**What:** Stop **Ctrl + Alt + Delete** on a text console (Ctrl + Alt + F3 and similar) from rebooting the machine straight away.

**Why it matters:** Anyone at the keyboard could restart the computer without logging in.

**Typing:**
```bash
sudo systemctl mask ctrl-alt-del.target
```

**Check it worked:** `systemctl is-enabled ctrl-alt-del.target` prints `masked`. (Inside your desktop, Ctrl + Alt + Delete still opens Cinnamon's log-out window; that's normal.)

---

---

### 9. SSH server (only if installed)

```bash
dpkg -l openssh-server       # "ii" at the start = installed
```

#### 9.1 Not needed? Remove it.
- [ ] Done

If the README doesn't mention SSH or remote logins:
```bash
sudo systemctl disable --now ssh
sudo apt purge openssh-server
```
On **Mint 22**, SSH can also be started on demand by `ssh.socket`; if you keep the package, turn that off too (see [SSH on Ubuntu 22.10 and newer](ubuntu.md#ssh-on-ubuntu-2210-and-newer)).

#### 9.2 Needed? Make it safe.
- [ ] Done

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo nano /etc/ssh/sshd_config
```

| Setting | Value | Why |
|---|---|---|
| `PermitRootLogin` | `no` | Nobody logs in directly as root |
| `PermitEmptyPasswords` | `no` | No logins without a password |
| `MaxAuthTries` | `4` | Fewer password guesses per connection |
| `X11Forwarding` | `no` | Don't forward the desktop |
| `LoginGraceTime` | `60` | Drop slow, half-finished logins |
| `ClientAliveInterval` | `300` | Probe whether the encrypted client connection is responsive |
| `ClientAliveCountMax` | `3` | (with the line above) |
| `HostbasedAuthentication` | `no` | Old, weak login method |
| `IgnoreRhosts` | `yes` | Old, weak login method |
| `PermitUserEnvironment` | `no` | Users can't change SSH's environment |
| `AllowTcpForwarding` | `no` | No tunnelling through this computer |
| `LogLevel` | `VERBOSE` | Better logs |
| `Banner` | `/etc/issue.net` | Show a warning before login |

Then test and reload:
```bash
sudo sshd -t && sudo systemctl reload ssh       # sshd -t prints nothing if the file is OK
```
If `sshd -t` says **Missing privilege separation directory: /run/sshd**, SSH is stopped right now: run `sudo mkdir -p /run/sshd` and test again.

**Check it worked:** `sudo sshd -T | grep -Ei 'permitrootlogin|permitemptypasswords|maxauthtries'` shows `permitrootlogin no`, `permitemptypasswords no` and `maxauthtries 4`.

> [!WARNING]
> Leave `PasswordAuthentication yes` unless the README says otherwise. First prove that each required user has a working permitted authentication method in a separate connection; otherwise disabling passwords can lock them out.

#### 9.3 Check for override files
- [ ] Done

Files in `/etc/ssh/sshd_config.d/` are read **first**, and for SSH the first value wins, so they override everything above:
```bash
grep -r . /etc/ssh/sshd_config.d/ 2>/dev/null
sudo sshd -T | grep -Ei 'permitrootlogin|permitemptypasswords|passwordauthentication'   # the settings actually in use
```

#### 9.4 Planted SSH keys
- [ ] Done

```bash
sudo find / -name 'authorized_keys*' 2>/dev/null -exec ls -la {} \; -exec cat {} \;
```
Record key fingerprints and compare them with the README and known administrators. Root keys can be legitimate management credentials. Back up the file and remove only the confirmed unauthorized key line, then test required users again.

---

---

### 11. File permissions

#### 11.1 Password files
- [ ] Done

```bash
ls -l /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo chmod 644 /etc/passwd /etc/group
sudo chmod 640 /etc/shadow /etc/gshadow
sudo chown root:shadow /etc/shadow /etc/gshadow
```

**Check it worked:** run the `ls -l` line again: `passwd` and `group` show `-rw-r--r-- root root`, `shadow` and `gshadow` show `-rw-r----- root shadow`.

#### 11.2 SUID programs (run as root for anyone)
- [ ] Done

**Why:** If `find`, `vim`, `bash` or `python3` has the SUID bit, any user can become root with one command.

```bash
sudo find / -xdev -perm -4000 -type f 2>/dev/null
sudo chmod u-s /usr/bin/find
```
Normal SUID programs include `passwd`, `sudo`, `su`, `mount`, `umount`, `chsh`, `chfn`, `gpasswd`, `newgrp`, `pkexec`, `fusermount3` and `ssh-keysign`. Look up anything else.

#### 11.3 Files anyone can change
- [ ] Done

```bash
sudo find / -xdev -type f -perm -0002 ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null
sudo chmod o-w /path/to/file
```

**Check it worked:** the `find` line prints nothing (files inside `/tmp` are OK).

#### 11.4 Home folders
- [ ] Done

```bash
ls -ld /home/*
sudo chmod 750 /home/bob        # other users can't look inside
```

**Check it worked:** in `ls -ld /home/*` every folder ends in `---`, e.g. `drwxr-x--- bob bob`. Each folder should also belong to its own user (`sudo chown bob: /home/bob` fixes one that doesn't).

---

---

### 12. Sudo rules

#### 12.1 Check /etc/sudoers and /etc/sudoers.d/
- [ ] Done

**Typing:**
```bash
sudo cat /etc/sudoers
sudo ls -la /etc/sudoers.d/ && sudo cat /etc/sudoers.d/*
```
Look for:
- `NOPASSWD`: sudo without a password. Remove it.
- Lines giving a **normal user** `ALL=(ALL) ALL`.
- `Defaults !authenticate`. Remove it.

**Edit only with visudo** (it checks for mistakes before saving):
```bash
sudo visudo                          # main file
sudo visudo -f /etc/sudoers.d/90-bob # a file in sudoers.d
```

> [!CAUTION]
> A typo in sudoers can break `sudo` for everyone. That's why you **always** use `visudo`.

---

---

### 13. Backdoors and malware

#### 13.1 Scheduled jobs (cron)
- [ ] Done

```bash
sudo ls -la /var/spool/cron/crontabs/                  # one file per user
for u in $(cut -d: -f1 /etc/passwd); do sudo crontab -l -u $u 2>/dev/null | grep -v '^#' | sed "s/^/$u: /"; done
cat /etc/crontab; ls -la /etc/cron.d /etc/cron.hourly /etc/cron.daily
sudo atq 2>/dev/null                                   # one-off "at" jobs (remove one: sudo atrm 3)
systemctl list-timers --all                            # systemd timers: another kind of scheduled job
```
Red flags: `nc`, `ncat`, `bash -i`, `/dev/tcp/`, `curl ... | bash`, `wget`, `base64 -d`, `python -c`, files in `/tmp`.

**Fix:** `sudo crontab -e -u bob` (delete the line), or `sudo rm /etc/cron.d/badfile`.

#### 13.2 Services that start a backdoor at boot
- [ ] Done

```bash
systemctl list-unit-files --type=service --state=enabled
ls -la /etc/systemd/system/ | grep -v '\.wants'
```
For any unit you don't recognise: `systemctl cat name.service` shows what it runs. Remove a bad one:
```bash
sudo systemctl disable --now evil.service && sudo rm /etc/systemd/system/evil.service && sudo systemctl daemon-reload
```

#### 13.3 Programs listening for connections
- [ ] Done

```bash
sudo ss -tulpn
```
`nc`, `ncat`, `socat`, `python`, `perl` or `bash` listening on a port is almost always a backdoor. Note the PID, stop it (`sudo kill -9 PID`), **then find what starts it** (13.1, 13.2, 13.4).

#### 13.4 Start-up files and fake commands
- [ ] Done

```bash
cat /etc/rc.local 2>/dev/null
ls /etc/profile.d/
grep -n 'alias' /home/*/.bashrc /root/.bashrc /etc/bash.bashrc
```
Watch for aliases that hijack commands, e.g. `alias sudo='...'` or `alias ls='...'`. Also check `/usr/local/bin` for programs named like system commands (a fake `ls` or `sudo`).

#### 13.5 The hosts file
- [ ] Done

```bash
cat /etc/hosts
```
Localhost, hostname and README-required internal mappings can all be legitimate. Back up `/etc/hosts`, compare each mapping with the scenario, and comment only confirmed unauthorized overrides using `sudo nano /etc/hosts`. Test the actual required hostname afterwards; an unfamiliar address alone is not proof of an attacker.

**Check it worked:** `grep -v '^#' /etc/hosts` shows only the normal lines.

#### 13.6 Hidden root-kit tricks
- [ ] Done

```bash
cat /etc/ld.so.preload 2>/dev/null          # should not exist or be empty
grep -n 'pam_permit' /etc/pam.d/common-auth # "auth sufficient pam_permit.so" = anyone can log in
```

#### 13.7 Programs that start when someone logs in
- [ ] Done

**Clicking:** **Menu → Preferences → Startup Applications**.

**Typing:** `ls /etc/xdg/autostart/ /home/*/.config/autostart/`

#### 13.8 Tampered system programs
- [ ] Done

```bash
sudo dpkg --verify | grep -v ' c '           # takes a minute or two; lines with a 5 = changed file
```
Fix by reinstalling the package that owns it: `dpkg -S /usr/bin/ls`, then `sudo apt install --reinstall coreutils`.

#### 13.9 Malware scanners (optional, slow)
- [ ] Done

```bash
sudo apt install clamav rkhunter chkrootkit
sudo systemctl stop clamav-freshclam      # the updater service blocks a manual update while it runs
sudo freshclam                            # download the newest virus list
sudo systemctl start clamav-freshclam
sudo clamscan -ri /home                   # -r = every subfolder, -i = list only infected files
sudo rkhunter --check --sk                # --sk = don't stop for Enter after each part
sudo chkrootkit | grep INFECTED           # nothing printed = nothing found
```
These tools only **report**. Look at each file they name (forensics first!) before you delete it. Warnings from `rkhunter` and `chkrootkit` are often false alarms (for example `Linux.Xor.DDoS` for a harmless script in `/tmp`); `sudo less /var/log/rkhunter.log` shows the details.

---

---

### 14. Logging and auditing

#### 14.1 System logs and the audit daemon
- [ ] Done

```bash
sudo apt install auditd rsyslog
sudo systemctl enable --now auditd rsyslog
```
Add audit rules that record changes to the password files:
```bash
echo '-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/sudoers -p wa -k sudoers' | sudo tee /etc/audit/rules.d/50-practice.rules
sudo augenrules --load
```

**Check it worked:** `systemctl is-active auditd rsyslog` prints `active` twice, and `sudo auditctl -l` lists the `-w /etc/passwd` rules.

---

---

### 15. AppArmor

#### 15.1 Make sure AppArmor is on
- [ ] Done

```bash
sudo aa-status
sudo systemctl enable --now apparmor
```
If a profile is in **complain** mode for no reason, enforce it (needs `sudo apt install apparmor-utils`):
```bash
sudo aa-enforce /usr/bin/man      # change /usr/bin/man to the name aa-status listed under "complain mode"
```

**Check it worked:** `sudo aa-status` starts with `apparmor module is loaded` and lists profiles `in enforce mode`; `systemctl is-enabled apparmor` prints `enabled`.

---

---

### 17. Web browser (Firefox)

#### 17.1 Firefox security settings
- [ ] Done

**What:** Turn on Firefox's built-in protections. Images often switch them off.

**Why it matters:** Pop-ups, add-on installs and fake websites are how malware gets onto a desktop.

**Clicking:** open Firefox → **≡ → Settings → Privacy & Security**. Labels move between Firefox versions, so if you can't find one, type a word from it (`pop-up`, `add-ons`, `deceptive`, `HTTPS`) into the **Find in Settings** box at the top.
- **Block pop-up windows** ✔
- **Warn you when websites try to install add-ons** ✔
- **Block dangerous and deceptive content** ✔ (and the boxes under it)
- **HTTPS-Only Mode** → on in all windows
- **Passwords:** untick saving passwords unless the README needs it, and check **Saved passwords** for any that shouldn't be there

Then open **≡ → Add-ons and themes → Extensions** and remove any you don't recognise.

**Check it worked:** close and reopen Firefox, then look at the same page again: the boxes are still ticked. If a box is greyed out with "Your browser is being managed by your organization", look at `about:policies` to see which rule sets it.

> [!NOTE]
> Do this in the Firefox of the user you are logged in as. Each user has their own Firefox settings.

---


### Research report expansion M-R4 — LightDM guest sessions and automatic login

- [ ] Done

**GUI:** Cinnamon **Menu → Administration → Login Window** (when installed). Inspect permitted autologin/guest options and actual active display manager.

**Typing (check):**

~~~bash
systemctl status display-manager --no-pager
sudo grep -RnsE '^[[:space:]]*(allow-guest|autologin-user|autologin-user-timeout)' /etc/lightdm /usr/share/lightdm/lightdm.conf.d 2>/dev/null
~~~

**What to look for:** Unauthorized guest login or auto-login. LightDM can load multiple configuration snippets; vendor defaults may be overridden by user local settings. If installed manager is not LightDM, use that manager's actual controls.

**Fix only if the README prohibits guest sessions and LightDM is active:** Inspect existing override first. If a new local override is appropriate:

~~~bash
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo nano /etc/lightdm/lightdm.conf.d/50-cp-security.conf
~~~

Configuration file contents:

~~~text
[Seat:*]
allow-guest=false
~~~

Do not overwrite an existing file without a private backup. Avoid duplicate options/sections.

**Verification:** Recheck the actual effective config and test a **new** authorized login at a safe checkpoint; do not restart LightDM mid-round while unsaved forensic work exists.

**Undo:** Restore an existing file's exact backup, or remove only your newly created override after checking its path and contents. Verify the original login workflow.

### Research report expansion M-R5 — Cinnamon screen-lock and user settings

- [ ] Done

**GUI:** **System Settings → Screensaver**. Inspect auto-lock and lock-on-resume rules for the *actual* logged-in user.

**Typing (check as ordinary desktop user, NOT root):**

~~~bash
printf '%s\n' "$XDG_CURRENT_DESKTOP"
gsettings list-schemas | grep -E 'cinnamon.desktop.screensaver|gnome.desktop.screensaver'
~~~

If installed:

~~~bash
gsettings list-recursively org.cinnamon.desktop.screensaver
~~~

**Fix:** Change only the policy-required setting in the GUI; if using gsettings first record the actual schema/key/type and old value. Cinnamon, MATE and Xfce are different; don't copy GNOME keys blindly.

**Verification:** Recheck the relevant key with **gsettings get** and test lock/unlock/resume. **Undo:** Restore exact old user-specific value and test login again.

### Research report expansion M-R6 — Software, Flatpak, files, timers and SUID investigation

- [ ] Done

**Evidence:** Community/training inventory topics; a potentially risky filename is not itself a confirmed vulnerability.

**Typing (check):**

~~~bash
dpkg -l | grep -Ei 'nmap|wireshark|netcat|steam|transmission|qbittorrent|hydra|john'
command -v flatpak
~~~

If Flatpak is installed:

~~~bash
flatpak list --app
~~~

~~~bash
sudo find /home -type f \( -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.avi' -o -iname '*.torrent' \) -print 2>/dev/null
sudo crontab -l
systemctl list-timers --all
systemctl list-unit-files --type=service --state=enabled
sudo ss -lntup
~~~

~~~bash
sudo find /etc /usr/local /opt -xdev -type f -perm /0002 -ls 2>/dev/null
sudo find /usr/local/bin /usr/local/sbin -type f \( -perm /4000 -o -perm /2000 \) -ls 2>/dev/null
cat /etc/hosts
~~~

**Fix:** For a truly prohibited APT package preview dependency removals first using **apt -s purge ACTUAL_PACKAGE**, then remove only when authorized. For a verified malicious cron/unit/hosts mapping, back up the exact file and disable/remove only that entry **after forensic evidence is saved**.

**Verification:** Re-run the relevant single inspection and test the expected browser, SSH, file share, database, user login and scoring report.

**Undo:** Restore the one package with its original configuration, the backed-up cron/hosts line, the recorded service state, or file permissions. Do not run a blanket rm, chmod -R or mass package purge.

### Research report expansion M-R7 — SSH, UFW, AppArmor and required-service rollback

- [ ] Done

**Typing (check):**

~~~bash
systemctl status ssh --no-pager
sudo /usr/sbin/sshd -T 2>/dev/null | grep -Ei '^(permitrootlogin|permitemptypasswords|passwordauthentication)'
sudo ufw status verbose
sudo aa-status
systemctl status unattended-upgrades --no-pager
~~~

Missing units/tools can be normal on an image. Before editing SSH, back up the exact config, check README-required auth/port, run **sudo /usr/sbin/sshd -t**, reload only if supported, and **test a second authorized SSH login** while the old session remains open. Do not disable password auth when required.

Before turning on UFW's default inbound deny, add exact allow rules for required SSH/web/file-share services and retain console access. Do not run **ufw reset** as a repair. Investigate AppArmor DENIED events instead of globally disabling the framework. Use Mint Update Manager and signed APT sources for updates.

**Verify:** Active required service connections and scoring report, user login and privilege elevation. **Undo:** Reverse the last specific change (firewall rule, SSH config, AppArmor profile, service unit) from its recorded state; never delete score data or restore malicious files casually.

## Part 5 — Advanced Kernel and Reference Procedures

Retain all detailed service, investigation, terminal and kernel procedures for later targeted use.

### 10. Kernel and network settings (sysctl)

#### 10.1 Turn on network and memory protections
- [ ] Done

**Typing:**
```bash
sudo nano /etc/sysctl.conf
```
Add (or fix) these lines:
```
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv6.conf.all.accept_redirects = 0
kernel.randomize_va_space = 2
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
```
Apply them now:
```bash
sudo sysctl -p
```

**Check:** `sysctl kernel.randomize_va_space` prints `= 2`. Also look for files in `/etc/sysctl.d/` that set the opposite (for example `ip_forward=1`): `grep -r . /etc/sysctl.d/`

#### 10.2 Turn off core dumps
- [ ] Done

**What:** Stop crashing programs from writing a "core dump" (a copy of everything in their memory) to disk.

**Why it matters:** A core dump can contain passwords and keys that were in the program's memory. `fs.suid_dumpable = 0` in 10.1 covers programs that run as root; this line covers everyone else.

**Typing:**
```bash
echo '* hard core 0' | sudo tee -a /etc/security/limits.conf
grep -rs core /etc/security/limits.conf /etc/security/limits.d/ | grep -v ':#'   # any other "core" line (e.g. "bob - core unlimited") overrides it: delete it
```

**Check it worked:** `sudo su - bob -c 'ulimit -Hc'` prints `0` (new logins pick it up; your open terminal keeps the old value). Don't check with `sudo -u bob`: `sudo` sets this limit by itself, so it can print `0` even when the setting is wrong.

---

---

### 16. Critical services (only what the README lists)

If the README needs a web server, database, FTP, Samba or similar, **harden it instead of removing it**. Step-by-step: [Linux service hardening guide](linux-mint.md#20-complete-linux-critical-service-hardening-procedures-embedded).

---

---

### 17. Detailed manual safety and verification procedures

These procedures supplement every earlier checklist table. Ubuntu and Debian use the same underlying APT/systemd tools where stated; their own checklists describe differences. Open **Menu → Terminal** or press **Ctrl+Alt+T**. Configuration blocks marked `text` are file contents, not commands. Examples use `bob`; substitute the README's actual account. Do not paste placeholders such as `<PID>` literally.

#### 17.1 Users, root and privilege recovery

- [ ] Done

**What:** Reconcile people, service identities and powerful groups without losing administrator access.

**Why it matters:** A low UID or an unfamiliar name is not proof of an attacker. Locking a password does not revoke SSH keys, an existing session or a sudo grant.

**Before changing anything:** Record authorized users and service dependencies. Keep a working root terminal open while testing authentication. Protect backups:

```bash
sudo install -d -m 700 /root/cp-backups
sudo cp -a /etc/passwd /etc/group /etc/shadow /etc/gshadow /root/cp-backups/
```

Never copy shadow files to a world-readable desktop directory. Account files form a related database; blindly restoring an old copy can conflict with users created by later package installations.

**Clicking (GUI):** **Menu → Administration → Users and Groups**; select each person, inspect account type and group membership, compare with the README. Do not delete a home directory while forensics remains unresolved. GUI absence means use the terminal; do not install another desktop.

**Typing (check):**

```bash
whoami
id
sudo -v
getent passwd
getent group sudo
sudo awk -F: '$3 == 0 { print $1, $3, $6, $7 }' /etc/passwd
```

`sudo -v` validates the current user's sudo access. Normally only root has UID 0, but investigate any exception before editing. `getent` can include directory-service accounts that are not in local files. Inspect an account:

```bash
id bob
sudo passwd -S bob
sudo chage -l bob
sudo -l -U bob
```

`P` means a usable password hash, `L` a locked password, `NP` no password. None proves the password is strong. `sudo -l -U` lists policy, including grants outside the sudo group.

**Typing (fix, only when appropriate):** Grant only the README-approved administrator and retain other groups:

```bash
sudo usermod -aG sudo bob
```

Remove one unauthorized membership:

```bash
sudo gpasswd -d bob sudo
```

For a confirmed unauthorized account, after evidence collection use account expiration for reversible denial of normal new logins:

```bash
sudo usermod --expiredate 1970-01-02 mallory
```

Investigate existing sessions, processes, keys and services separately. If deletion is explicitly required, preserve its UID, groups and home first, then use `sudo userdel mallory` without `-r`; delete the preserved data only after evidence review and authorization.

**Check it worked:** Log into a **new** permitted session as the authorized user and run `id` and `sudo -l`. Group changes do not alter existing sessions. Check an expired account with `sudo chage -l mallory`.

**Undo:** Re-add a removed group with `sudo usermod -aG sudo bob` only if it was originally authorized. Restore the recorded account expiry with `sudo chage -E YYYY-MM-DD mallory`, or `sudo chage -E -1 mallory` only if it originally had no expiration. Do not unlock an account that was originally locked. Account deletion cannot be undone just by recreating a name.

**Warnings:** Never use `usermod -G sudo` without `-a` to add membership; it replaces supplementary groups. Do not lock root on Debian until a separate administrator and recovery path work. Service identities such as postgres may legitimately use a shell for maintenance.

#### 17.2 Password aging, PAM and lockout without breaking login

- [ ] Done

**What:** Set password policy and validate the actual PAM stack used for login/password changes.

**Why it matters:** Incorrect PAM ordering can allow weak passwords or deny every login. `/etc/login.defs` defaults do not change existing users. `pam_tally`/`pam_tally2` examples from older scripts are obsolete on modern releases.

**Before changing anything:** Keep a root console open and back up all affected files:

```bash
sudo cp -a /etc/pam.d /root/cp-backups/pam.d.before-policy
sudo cp -a /etc/security /root/cp-backups/security.before-policy
sudo cp -a /etc/login.defs /root/cp-backups/login.defs.before-policy
```

Use unique backup names if repeating. Record `sudo chage -l bob` before modifying that user.

**Clicking (GUI):** Use **Users and Groups** to change only approved user passwords. Standard desktop settings do not expose the complete PAM stack or aging policy; use the terminal for those.

**Typing (check):**

```bash
grep -nE 'pam_unix|pam_pwquality|pam_pwhistory|pam_faillock|nullok' /etc/pam.d/common-auth /etc/pam.d/common-account /etc/pam.d/common-password
ls /usr/share/pam-configs
find /usr/lib -name pam_faillock.so -o -name pam_pwhistory.so -o -name pam_pwquality.so 2>/dev/null
```

Do not insert a module that is absent. Read the installed `man pam_pwquality`, `man pam_pwhistory`, `man pam_faillock` and `man pam-auth-update`; capabilities vary with release and package version.

**Typing (fix, only when appropriate):** Apply README aging values to one existing human user:

```bash
sudo chage -M 90 -m 1 -W 14 bob
```

This means maximum age 90 days, minimum age 1 day, warning 14 days. Use scenario values rather than blindly applying these to service accounts. Inspect/edit defaults for future accounts:

```bash
sudo nano /etc/login.defs
```

For complexity, install only the applicable policy package if absent and permitted:

```bash
sudo apt install libpam-pwquality
```

Use its supplied profile through `sudo pam-auth-update`, selecting password quality without deselecting the required Unix authentication profile. Edit `/etc/security/pwquality.conf` using the settings in section 3.3. A root user can bypass quality unless enforcement is configured; test as an ordinary user.

For history, prefer `pam_pwhistory` when supported. Inspect the existing common-password sequence: quality must obtain the new token, history must check it, and pam_unix must consume it via `use_authtok`. A typical history module line is:

```text
password required pam_pwhistory.so remember=5 use_authtok
```

This is **not** a complete PAM stack. Place it after the active quality module and before the password-writing module, accounting for numeric jump controls already present. Do not append a module after `pam_deny` and assume it executes. Do not duplicate `remember` mechanisms.

For supported faillock, `/etc/security/faillock.conf` can specify:

```text
deny = 5
fail_interval = 900
unlock_time = 900
```

These values alone do not enable lockout: the distribution's PAM stack needs correctly ordered preauth/authfail/account integration. Prefer a supplied distribution profile if present. If none exists, do not paste a generic replacement stack; review the installed module's example and existing control flow with a mentor before changing authentication. Do not lock root or your only administrator to test it.

**Check it worked:** Keep the root console open. From a **separate ordinary user session**, run `passwd` and confirm a deliberately weak test password is rejected before choosing a unique strong one. A root `su - bob` can bypass the password and is not proof authentication works. Test a normal new login and sudo. Inspect errors:

```bash
sudo journalctl _COMM=sudo -n 30 --no-pager
sudo chage -l bob
sudo faillock --user bob
```

Use `faillock` only if installed/configured. An empty record can mean no failures, not successful integration.

**Undo:** From the root console, restore the specific modified PAM/config files from backup (preserving metadata), then test a separate login again before exiting root. To clear a mistakenly locked test account's faillock counter:

```bash
sudo faillock --user bob --reset
```

Restore the user's recorded `chage` values individually. A password reset is not reversible to the unknown old plaintext password.

**Warnings:** Never expose hashes, use one shared password, or test repeated failed logins against the active administrator. Do not restart the desktop display manager while unsaved work is open.

#### 17.3 SSH: effective configuration and a second-session test

- [ ] Done

**What:** Secure an installed required SSH server while retaining permitted users.

**Why it matters:** Included files, Match blocks and socket activation can make the effective configuration differ from the file you edited.

**Before changing anything:** Record the required port, authentication methods, source networks and any SFTP/forwarding requirements. Keep your existing remote connection and console open.

**Clicking (GUI):** Use the VM console for recovery. A desktop's sharing panel may configure remote desktop rather than OpenSSH; do not treat them as the same service.

**Typing (check):**

```bash
dpkg-query -W openssh-server
systemctl status ssh.service ssh.socket --no-pager
sudo /usr/sbin/sshd -T | grep -Ei 'port |listenaddress|permitrootlogin|passwordauthentication|pubkeyauthentication|permitemptypasswords|allowusers|allowgroups'
sudo ss -ltnp
```

`sshd -T` parses effective defaults. Match-dependent rules need a connection-specific inspection, using real values:

```bash
sudo /usr/sbin/sshd -T -C user=bob,host=client.example,addr=192.168.10.20
```

**Typing (fix, only when appropriate):**

```bash
sudo cp -a /etc/ssh /root/cp-backups/ssh.before-cp
sudo nano /etc/ssh/sshd_config
```

Inspect section 9's table and actual included files. Set `PermitRootLogin no` and `PermitEmptyPasswords no` if compatible with the scenario; retain a tested authentication method for each required user. A first parsed value generally wins for a given context; inspect where Include appears rather than assuming all drop-ins always override all main-file lines. `ClientAliveInterval`/`ClientAliveCountMax` detect unresponsive clients; a responsive idle client can stay connected.

Validate:

```bash
sudo /usr/sbin/sshd -t
```

No output and exit 0 is expected. Then, for ordinary config changes:

```bash
sudo systemctl reload ssh.service
```

For socket-managed port/listen changes follow the Ubuntu-specific procedure; a daemon reload alone might not change the listening socket.

**Check it worked:** In a second terminal on an authorized client, use `ssh bob@server-name` with the actual hostname and port. Confirm login and the required sudo/SFTP function, then repeat `sshd -T`, `ss -ltnp` and the journal check. Close the old connection only after success.

**Undo:** Restore the particular edited SSH config/drop-in from `/root/cp-backups/ssh.before-cp`, remove only newly created drop-ins, run `sshd -t`, and reload/restart the appropriate unit from the console. Restore firewall port/source changes too.

**Warnings:** Do not delete all authorized_keys files. Inspect fingerprints with `ssh-keygen -lf FILE` and remove only confirmed unauthorized keys after preserving them privately. A root key may be legitimate recovery access.

#### 17.4 UFW and nftables: one firewall owner

- [ ] Done

**What:** Inspect the active firewall and permit required inbound services before imposing default deny.

**Why it matters:** UFW can use nftables through compatibility tools. Mixing independent policies or flushing rules can break both access and scoring.

**Before changing anything:** Use the console. Record actual server ports, UDP services, IPv6 use and source networks. Do not change `/etc/ufw/before.rules` to copy legacy anti-spoofing snippets without understanding existing defaults.

**Clicking (GUI):** If installed, **Menu → Firewall Configuration** (GUFW) → unlock → inspect profiles and existing rules. Create the required allow rule before switching the firewall on. GUFW configures UFW; it is not a separate firewall engine.

**Typing (check and backup):**

```bash
sudo ufw status verbose
sudo nft list ruleset
sudo iptables-save
sudo cp -a /etc/ufw /root/cp-backups/ufw.before-cp
```

Inactive UFW does not prove no firewall exists. Save native nftables rules if that is the owner's tool:

```bash
sudo nft list ruleset | sudo tee /root/cp-backups/nft-before.nft > /dev/null
```

**Typing (fix, only when appropriate):** UFW example for required SSH from the example lab network:

```bash
sudo ufw allow from 192.168.10.0/24 to any port 22 proto tcp
```

Then:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

Use actual required ports. FTP may need passive data ports, DNS both TCP/UDP 53, DHCP its interface-specific UDP path. Do not guess these from the process name.

If the image already uses native nftables, preserve that policy and edit `/etc/nftables.conf` instead of enabling UFW. Back it up first. In the **existing** input base chain, preserve loopback, established/related traffic and required ICMP/ICMPv6, add source-scoped service rules before any matching drop, then validate:

```bash
sudo nft -c -f /etc/nftables.conf
```

Only after reviewing the entire ruleset from the console:

```bash
sudo nft -f /etc/nftables.conf
```

Do not paste a second generic input chain. Stateful IPv6 operation needs ICMPv6 neighbor discovery; blanket blocking it breaks networking.

**Check it worked:** Query the owner's rules and test a fresh permitted connection from another machine. Verify required remote services and IPv4/IPv6 as applicable, not merely `ping` or an old established SSH session.

**Undo:** For a newly created UFW rule use `sudo ufw status numbered`, identify its exact number and `sudo ufw delete NUMBER` (replace NUMBER). Restore recorded defaults only if changed. For native nftables restore the reviewed full policy from the console; understand whether the file flushes existing tables before loading. Do not run `nft flush ruleset` remotely as a shortcut.

**Warnings:** Do not add a broad allow-all rule to make one service work. Keep required outbound traffic and DNS; never disable IPv6 merely because an old script did.

#### 17.5 Package sources, updates and vulnerability triage

- [ ] Done

**What:** Verify release-matched signed repositories and update installed required software.

**Why it matters:** Mixed releases, obsolete PPAs and untrusted keys can introduce malicious or incompatible packages. Historical 2016 repository lists are unsuitable for current images.

**Before changing anything:** Record release and repositories; keep a working desktop and network.

**Clicking (GUI):** Mint **Menu → Administration → Software Sources**; inspect official repositories and each additional repository/PPA. Use **Update Manager → Refresh**, review updates, then install supported security updates. Do not select a major release upgrade during a timed round.

**Typing (check):**

```bash
cat /etc/os-release
apt-cache policy
sudo grep -RHE '^(deb |Types:|URIs:|Suites:|Components:|Signed-By:)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
apt-mark showhold
```

DEB822 `.sources` files and traditional `.list` files are both valid. A trusted `Signed-By` key is repository-specific; never bypass signature validation with `trusted=yes` or `--allow-unauthenticated` to suppress an error.

**Typing (fix, only when appropriate):** Back up sources before disabling a confirmed unauthorized entry:

```bash
sudo cp -a /etc/apt /root/cp-backups/apt.before-cp
```

Use the GUI or `sudo nano` on that specific file. Preserve the matching Mint and Ubuntu base suites; Linux Mint Debian Edition follows Debian instead. Then:

```bash
sudo apt update
```

Stop on signature, release or 404 errors and investigate the specific source. After success preview the proposed upgrade:

```bash
apt -s upgrade
```

Review changes, then:

```bash
sudo apt upgrade
```

Do not blindly purge held packages or run autoremove. Preview any targeted removal with `apt -s remove PACKAGE` using the actual name; preserve required dependencies and desktop metapackages.

**Check it worked:** `apt list --upgradable` reports remaining upgrades; some may be phased, held or require a reviewed dependency transition. Run `sudo dpkg --audit` for incomplete package configuration and open required applications after updating. There is no universal APT command that proves every installed package has no vulnerability; consult distribution security advisories for the exact installed release/version.

**Undo:** Restore the one source file you changed, then `apt update`. Package updates are not undone by restoring sources: use a supported package rollback or allowed practice snapshot only after checking dependencies and preserving later work.

**Warnings:** On interruption inspect the real package-manager error. Do not delete lock files while another package manager is active. If no manager is running and configuration was interrupted, `sudo dpkg --configure -a` can finish pending configuration; review its output before proceeding.

#### 17.6 Ownership, permissions, SUID and capabilities

- [ ] Done

**What:** Find dangerous permissions without recursively changing the whole OS.

**Why it matters:** Some SUID/SGID files and capabilities are intentional; removing all privileged bits breaks tools such as passwd and sudo.

**Before changing anything:** Preserve path, owner, group and octal mode with `stat`. Do not print `/etc/shadow` contents into a shared log.

**Clicking (GUI):** File manager → exact file **Properties → Permissions**. Compare owner/group/access with the package or required application's expected state. The GUI may omit ACLs and capabilities.

**Typing (check):**

```bash
sudo stat -c '%a %U:%G %n' /etc/passwd /etc/group /etc/shadow /etc/gshadow
sudo find / -xdev -type f -perm /6000 -ls 2>/dev/null
sudo find /home /tmp /var/tmp -xdev -type f -perm -0002 -ls 2>/dev/null
sudo getcap -r /usr /opt 2>/dev/null
```

Mint/Ubuntu/Debian commonly use root:shadow mode 640 for `/etc/shadow`; compare the distribution's baseline rather than applying it on FreeBSD. World-writable temporary directories often legitimately use sticky mode 1777. Check package ownership and modifications:

```bash
dpkg-query -S /usr/bin/passwd
sudo dpkg -V passwd
```

Verification output is a lead; local configuration can legitimately differ, and package metadata on a compromised machine is not an independent trusted baseline.

**Typing (fix, only when appropriate):** If `/etc/shadow` is incorrectly world-readable on the listed Linux families:

```bash
sudo chown root:shadow /etc/shadow
sudo chmod 640 /etc/shadow
```

For a confirmed unauthorized SUID copy only, remove that bit from the exact path:

```bash
sudo chmod u-s /opt/unauthorized-tool
```

**Check it worked:** Repeat `stat` and the targeted listing. Test authorized password changes and sudo from a separate session. Inspect ACLs with `getfacl PATH` if available; mode bits alone may not explain effective access.

**Undo:** Restore the recorded owner/group/mode on that exact file. For package-owned executables prefer a trusted package repair after evidence collection, rather than copying an unknown binary.

**Warnings:** Never `chmod -R 777`, recursively chown system directories, remove all SUID files, or overwrite file ACLs simply because a scanner flags them.

#### 17.7 Cron, systemd and malicious persistence

- [ ] Done

**What:** Review scheduled and boot/login execution paths.

**Why it matters:** Legitimate backup, update and service tasks also run as root. Deleting all cron jobs destroys required operations and evidence.

**Before changing anything:** Record command, user, schedule, file path and package owner. Keep copies in `/root/cp-backups`, outside executable startup locations.

**Clicking (GUI):** Mint **Menu → Preferences → Startup Applications**; inspect each entry and disable only an unauthorized one. This does not cover systemd, root cron or every user's desktop startup.

**Typing (check):**

```bash
sudo crontab -l
sudo crontab -u bob -l
sudo ls -la /etc/cron.d /etc/cron.daily /etc/cron.hourly
systemctl list-timers --all
systemctl list-unit-files --state=enabled
systemctl --user list-unit-files --state=enabled
```

“No crontab” is not an error requiring a new job. Inspect a suspicious system unit:

```bash
systemctl cat example.service
systemctl show example.service -p FragmentPath -p DropInPaths -p User -p ExecStart
```

Also inspect `/etc/rc.local`, `/etc/profile.d`, `/etc/ld.so.preload`, `/etc/systemd/system`, user shell profiles and `~/.config/autostart`. Do not run referenced suspicious scripts.

**Typing (fix, only when appropriate):** Save a user's existing crontab first:

```bash
sudo crontab -u bob -l | sudo tee /root/cp-backups/bob-crontab.before-cp > /dev/null
```

Only use the backup if the listing succeeded. Edit that user's crontab with `sudo crontab -u bob -e`, removing just the unauthorized line. For a confirmed unauthorized unit:

```bash
sudo systemctl disable --now example.timer
sudo systemctl disable --now example.service
```

Inspect any socket/path activation too; disabling one unit may not prevent another from starting it. Do not disable real system units named by the README.

**Check it worked:** Re-list the crontab, unit state and timers, inspect the process/listener and test required scheduled jobs. `systemctl daemon-reload` is needed after unit-file changes, but is not itself a service restart.

**Undo:** Reinstall a valid saved crontab with `sudo crontab -u bob /root/cp-backups/bob-crontab.before-cp`. Restore the recorded enabled/running states individually; do not enable every unit you inspected. A copied startup file must return to its original owner and mode.

**Warnings:** Do not `crontab -r`, blanket-remove `.desktop` files, or restrict all cron access to root unless the scenario actually requires it. User timers run in the user's manager; root's `systemctl --user` is not the desktop user's manager.

#### 17.8 Kernel, AppArmor and logging

- [ ] Done

**What:** Apply supported kernel controls, keep mandatory-access controls active and preserve investigation logs.

**Why it matters:** Linux kernel settings differ from FreeBSD, and routers/VPNs/containers may require forwarding. AppArmor denials can explain an otherwise confusing service failure.

**Before changing anything:** Record current values and inspect existing drop-ins. Do not disable AppArmor or forwarding without checking the role.

**Clicking (GUI):** System Monitor can show processes/resources; use **Logs** if installed for system errors. Kernel and AppArmor policy normally require terminal inspection.

**Typing (check):**

```bash
sysctl net.ipv4.ip_forward net.ipv4.tcp_syncookies kernel.randomize_va_space
sudo grep -RHE 'ip_forward|accept_redirects|randomize_va_space' /etc/sysctl.conf /etc/sysctl.d 2>/dev/null
sudo aa-status
sudo journalctl -k -g 'apparmor="DENIED"' --no-pager
sudo journalctl --since '1 hour ago' -p warning --no-pager
```

No `aa-status` command means inspect whether apparmor utilities are installed before assuming the security mechanism is absent. Do not replace a working LSM configuration blindly.

**Typing (fix, only when appropriate):** Back up any existing chosen drop-in and edit:

```bash
sudo nano /etc/sysctl.d/60-cp-local.conf
```

Example supported workstation settings (file contents):

```text
net.ipv4.tcp_syncookies = 1
kernel.randomize_va_space = 2
```

Syncookies help during a TCP SYN backlog overflow; ASLR makes memory layout less predictable. They are not a firewall or malware detector. Do not add unknown keys or disable IPv6 globally. Apply just this file:

```bash
sudo sysctl -p /etc/sysctl.d/60-cp-local.conf
```

If a required service is denied by AppArmor, inspect the named profile and denied operation, confirm the operation is legitimate, and update only the relevant local profile rule using distribution guidance. Do not put every profile in complain mode.

**Check it worked:** Query the two sysctl values again, test the required service and review fresh kernel denials. Check `systemctl status systemd-journald`; rsyslog/auth.log may not be installed on every Debian-based image. `journalctl --list-boots` shows retained boots, not a guarantee all historical logs were preserved.

**Undo:** Restore the old drop-in or remove only your newly created file, then explicitly restore the recorded runtime values using `sudo sysctl -w KEY=OLDVALUE` with real values. Removing a file alone does not undo its live settings. Restore only the changed AppArmor rule and reload its individual profile after validation.

**Warnings:** Do not clear journals, truncate logs, or install a logging daemon merely to force one filename to exist. Log output can contain personal data and secrets; keep it private.

#### 17.9 Service and desktop completion checks

- [ ] Done

**What:** Verify required services, desktop login and ordinary-user workflows after hardening.

**Why it matters:** A daemon can be running while its application is unreachable, its database is down or its permissions deny required users.

**Before changing anything:** Note the original display manager with `systemctl status display-manager`; Cinnamon, MATE, Xfce and GNOME use different settings schemas.

**Clicking (GUI):** In the logged-in user's **Screensaver / Privacy → Screen Lock**, set an appropriate timeout and require a password. In login settings disable unauthorized autologin. In the browser review extensions, protection settings and **Help → About** updates. Test locking and unlocking before logging out.

**Typing (check):** As the desktop user, without sudo:

```bash
gsettings list-schemas | grep -E 'cinnamon|gnome.desktop.screensaver|gnome.desktop.session'
```

Use only the schema that exists. Record `gsettings get SCHEMA KEY` before each earlier desktop change; the exact schema/key in section 8 applies to Cinnamon, not every Mint flavor. For system health:

```bash
systemctl --failed
ip -br address
ip route
sudo ss -tulpn
```

**Typing (fix, only when appropriate):** Apply the distribution-specific desktop procedure and the per-service instructions in [Linux service hardening](linux-mint.md#20-complete-linux-critical-service-hardening-procedures-embedded). Do not stop a service merely because it appears in the listening-port list.

**Check it worked:** New authorized login, screen lock/unlock, sudo, hostname resolution, required web/database/share/SSH transactions, all saved forensic answers, current score timestamp, no new service failures. Check package operations have completed before any necessary reboot.

**Undo:** Restore the recorded desktop key with `gsettings set` or its GUI value. Restore the exact display-manager config from backup if login fails, using console access. Do not restart the display manager to test while unsaved work remains.

**Warnings:** A reboot can lose unsaved work and remote access. Finish updates and preserve recovery access first; the rules and actual update state determine whether/when to reboot.


---

---

### 20. Complete Linux critical-service hardening procedures (embedded)

The original practical text and copyable command blocks are retained here for self-contained study. For a Debian image, use Debian-specific explanations in Sections 0–19 before changing a setting.


When the README says a service **must keep working**, you don't remove it. You make it **safer**. This guide covers the services that appear most often on Mint, Debian and Ubuntu images.

> [!IMPORTANT]
> Rules for every service:
> 1. **Back up the config file first:** `sudo cp file file.bak`
> 2. **Test the config** before restarting (each section shows the test command).
> 3. **Check the service still works** after restarting: `systemctl status <name>`. If it's red or "failed", restore the backup.
> 4. **Check the Scoring Report.** If the score dropped, undo your last change.

Use the per-service manual procedures below for every installed required service. No automation is included in this repository.

---

##### Safe service editing workflow

All commands here are for a **terminal on Ubuntu, Linux Mint or Debian**, using `sudo` for privileged operations. They are written individually so you can inspect the result before the next command. They are not commands to run on this handbook's development workspace. For FreeBSD use its [own checklist](freebsd.md); packages generally configure under `/usr/local/etc` and use rc services.

Before every service change: read the README, identify its package/unit, record a working client test, preserve evidence, and keep console access. A package can be absent without being a vulnerability. Do not install an unnecessary server just to complete a checklist. Replace all example site, share, user and network names with the image's actual values.

For a config edit, `sudo cp -a` preserves metadata. Use a unique backup suffix if `.before-cp` already exists. In `nano`, **Ctrl+W** searches, **Ctrl+O → Enter** saves, **Ctrl+X** exits. Edit existing directives in their correct section instead of appending contradictory copies. Check included files and per-site overrides. A successful syntax check does not prove client access works.

If a service fails: read `systemctl status` and `journalctl -u UNIT -n 50 --no-pager`, restore the edited file, recheck syntax, then reload/restart. Do not purge and reinstall as a first repair.


##### Apache web server (`apache2`)

| What | Where | Change to |
|---|---|---|
| Hide the version number | `/etc/apache2/conf-available/security.conf` | `ServerTokens Prod` and `ServerSignature Off` |
| Disable TRACE requests | same file | `TraceEnable Off` |
| No folder listings | `/etc/apache2/apache2.conf` (and site files) | In `Options` lines, remove the word `Indexes` (e.g. `Options FollowSymLinks`) |
| Turn off the listing module | — | Disable `Indexes` in the affected directory; do not force module removal |
| Turn off user home pages | — | `sudo a2dismod userdir` (if enabled) |
| Run as www-data, not root | `/etc/apache2/envvars` | `APACHE_RUN_USER=www-data` and `APACHE_RUN_GROUP=www-data` |
| Security headers | new file `/etc/apache2/conf-available/security-headers.conf` | see below |

```bash
sudo a2enmod headers
echo '<IfModule mod_headers.c>
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
</IfModule>' | sudo tee /etc/apache2/conf-available/security-headers.conf
sudo a2enconf security security-headers
sudo apache2ctl configtest          # must say "Syntax OK"
sudo systemctl reload apache2
```

Also check:
- **Web files shouldn't be writable by the web server:** `sudo find /var/www -user www-data -type f`. Usually they should be owned by root: `sudo chown -R root:root /var/www/html` (careful: upload folders for an app like WordPress need write access).
- **Web shells** (hacker control pages hidden in the site): `sudo grep -rlE 'eval\(|base64_decode|shell_exec|system\(\$_' /var/www`
- **`.htaccess` files** that redirect visitors somewhere else: `sudo find /var/www -name .htaccess -exec cat {} \;`

---

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Apache web server (`apache2`) without removing the required service.

**Why it matters:** These reduce version disclosure and disable TRACE; they do not replace patching. Check each enabled site for Options Indexes and remove only Indexes if browsing is not required.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' apache2
systemctl status apache2 --no-pager
systemctl cat apache2
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Open the required site in Firefox. There is no standard desktop GUI for Apache configuration; use the editor commands below.

**Typing (check and backup):** Main configuration: `/etc/apache2/conf-available/security.conf`. First preserve it:

```bash
sudo cp -a /etc/apache2/conf-available/security.conf /etc/apache2/conf-available/security.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/apache2/conf-available/security.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
ServerTokens Prod
ServerSignature Off
TraceEnable Off
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo apache2ctl configtest
```

Expected: Syntax OK. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload apache2
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status apache2 --no-pager
sudo journalctl -u apache2 -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
curl -I http://127.0.0.1/
```

Expected: An expected HTTP status and working required page; a redirect or authenticated response can be legitimate. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/apache2/conf-available/security.conf.before-cp /etc/apache2/conf-available/security.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### Nginx web server

```bash
sudo nano /etc/nginx/nginx.conf
```
In the `http { ... }` block: `server_tokens off;`

In the site files (`/etc/nginx/sites-enabled/*`): change `autoindex on;` to `autoindex off;`, and optionally add:
```
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
```
```bash
sudo nginx -t                       # must say "test is successful"
sudo systemctl reload nginx
```

---

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Nginx web server without removing the required service.

**Why it matters:** Place server_tokens inside the existing http block. In the actual site block inspect autoindex off; and avoid changing proxy_pass or document roots blindly.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' nginx
systemctl status nginx --no-pager
systemctl cat nginx
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Open the required site in a browser and compare with the baseline. Use a terminal editor for server settings.

**Typing (check and backup):** Main configuration: `/etc/nginx/nginx.conf`. First preserve it:

```bash
sudo cp -a /etc/nginx/nginx.conf /etc/nginx/nginx.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/nginx/nginx.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
server_tokens off;
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo nginx -t
```

Expected: syntax is ok and test is successful. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload nginx
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status nginx --no-pager
sudo journalctl -u nginx -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
curl -I http://127.0.0.1/
```

Expected: The required site still loads. For a virtual host, repeat with its real hostname; localhost alone can select the wrong site. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/nginx/nginx.conf.before-cp /etc/nginx/nginx.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### PHP (used by the website)

Edit the **web** PHP settings, not the command-line ones: `/etc/php/<version>/apache2/php.ini` (Apache) or `/etc/php/<version>/fpm/php.ini` (Nginx).

| Setting | Value | Why |
|---|---|---|
| `expose_php` | `Off` | Hide the PHP version |
| `display_errors` | `Off` | Don't show error details to visitors |
| `log_errors` | `On` | …but do log them |
| `allow_url_fopen` | `Off` | Restricts URL-aware file functions; can break legitimate HTTP integrations |
| `allow_url_include` | `Off` | Pages can't include remote code |
| `disable_functions` | `exec,passthru,shell_exec,system,proc_open,popen` | Reduces some command-execution paths; not a sandbox |
| `session.cookie_httponly` | `1` | JavaScript can't steal login cookies |
| `session.use_strict_mode` | `1` | Rejects made-up session IDs |

Then `sudo systemctl reload apache2` (or `php8.1-fpm` etc.).

> [!WARNING]
> `disable_functions` can break some web apps. If the site stops working after the change, remove functions from the list one at a time.

---

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed PHP (used by the website) without removing the required service.

**Why it matters:** Identify the active version and SAPI before editing: php --ini shows CLI settings, not necessarily Apache or FPM. Typical web files are /etc/php/8.2/apache2/php.ini or /etc/php/8.2/fpm/php.ini; discover the actual path. Do not add these lines to a directory.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' php-common
systemctl status apache2 --no-pager
systemctl cat apache2
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use the web application in a browser. Do not expose phpinfo publicly to inspect settings.

**Typing (check and backup):** Main configuration: `/etc/php`. First preserve it:

```bash
sudo cp -a /etc/php /etc/php.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo find /etc/php -maxdepth 3 -name php.ini -print
# Open the discovered web SAPI file, for example:
sudo nano /etc/php/8.2/apache2/php.ini
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
display_errors = Off
log_errors = On
expose_php = Off
allow_url_include = Off
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
php -l /var/www/html/index.php
```

Expected: No syntax errors detected (this checks that PHP source file, not web php.ini). If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload apache2
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status apache2 --no-pager
sudo journalctl -u apache2 -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
curl -I http://127.0.0.1/
```

Expected: The application still signs in and performs a normal permitted operation; check its error log. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/php.before-cp/. /etc/php/
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### MySQL / MariaDB

##### Built-in hardening tool
```bash
sudo mysql_secure_installation
```
Answer **yes** to: remove anonymous users, disallow root login remotely, remove the test database, reload privileges.

##### Settings file
`/etc/mysql/mysql.conf.d/mysqld.cnf` (MySQL) or `/etc/mysql/mariadb.conf.d/50-server.cnf` (MariaDB), under `[mysqld]`:
```
bind-address = 127.0.0.1      # only this computer can connect (skip if the README says others connect)
local_infile = 0              # SQL can't read files from the server's disk
```
```bash
sudo systemctl restart mysql      # or mariadb
```

##### Look at the database users
```bash
sudo mysql
```
```sql
SELECT user, host, plugin FROM mysql.user;          -- every database account
-- Only after recording SHOW CREATE USER and SHOW GRANTS for the exact account:
DROP USER ''@'localhost';                            -- an anonymous account
DROP USER 'root'@'%';                                -- root allowed from anywhere
-- Change an application credential only together with its private application configuration; never reuse a handbook example password.
SHOW GRANTS FOR 'webapp'@'localhost';                -- what this account can do
FLUSH PRIVILEGES;
EXIT;
```
Accounts that aren't needed, or that have `ALL PRIVILEGES` without needing them, are common planted problems.

---

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed MySQL / MariaDB without removing the required service.

**Why it matters:** Edit the existing mysqld section rather than creating duplicates. Loopback binding is appropriate only for local clients. MySQL uses mysql-server, unit mysql and usually /etc/mysql/mysql.conf.d/mysqld.cnf; substitute all three if that is installed. Preserve Unix-socket root authentication.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' mariadb-server
systemctl status mariadb --no-pager
systemctl cat mariadb
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** If a trusted database client is already installed, inspect user/grant screens without deleting accounts. No generic desktop control panel exists.

**Typing (check and backup):** Main configuration: `/etc/mysql/mariadb.conf.d/50-server.cnf`. First preserve it:

```bash
sudo cp -a /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
[mysqld]
bind-address = 127.0.0.1
local_infile = 0
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo mariadbd --help --verbose > /dev/null
```

Expected: Exit status 0; this is a preliminary option parse, not a complete live validation. If the validation fails, do not continue. When correct:

```bash
sudo systemctl restart mariadb
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status mariadb --no-pager
sudo journalctl -u mariadb -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo mariadb -e "SELECT VERSION(); SHOW VARIABLES LIKE 'bind_address'; SHOW VARIABLES LIKE 'local_infile';"
```

Expected: Version output and expected variable values; also test the application with its own database credentials. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/mysql/mariadb.conf.d/50-server.cnf.before-cp /etc/mysql/mariadb.conf.d/50-server.cnf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### vsftpd (FTP server)

```bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
sudo nano /etc/vsftpd.conf
```
| Setting | Value | Why |
|---|---|---|
| `anonymous_enable` | `NO` | No logins without an account |
| `anon_upload_enable` | `NO` | Anonymous users can't upload |
| `anon_mkdir_write_enable` | `NO` | …or make folders |
| `local_enable` | `YES` | Real users can log in (if the README needs it) |
| `chroot_local_user` | `YES` | Users are locked into their home folder |
| `allow_writeable_chroot` | `NO` (or absent) | Prefer a root-owned jail with a separate user-writable upload subdirectory |
| `xferlog_enable` | `YES` | Log every file transfer |
| `ssl_enable` | `YES` | Encrypt passwords and files (only if a certificate is set in `rsa_cert_file`) |

```bash
sudo systemctl restart vsftpd && systemctl status vsftpd
```
Also check `/etc/ftpusers` (users **not** allowed to use FTP; `root` should be in it) and the `userlist_*` settings.

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed vsftpd (FTP server) without removing the required service.

**Why it matters:** Retain anonymous read access only if required. If chroot_local_user=YES, use a root-owned, non-writable jail root and a separate user-writable upload directory. Enable TLS only with an installed valid certificate and compatible required clients.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' vsftpd
systemctl status vsftpd --no-pager
systemctl cat vsftpd
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use a trusted FTP client if installed; test the actual server name, authentication and TLS behavior.

**Typing (check and backup):** Main configuration: `/etc/vsftpd.conf`. First preserve it:

```bash
sudo cp -a /etc/vsftpd.conf /etc/vsftpd.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/vsftpd.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
anonymous_enable=NO
anon_upload_enable=NO
xferlog_enable=YES
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo grep -nE "anonymous_enable|anon_upload_enable|chroot|ssl_enable|rsa_cert|pasv_" /etc/vsftpd.conf
```

Expected: Review each setting manually; vsftpd has no portable standalone syntax-test flag. If the validation fails, do not continue. When correct:

```bash
sudo systemctl restart vsftpd
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status vsftpd --no-pager
sudo journalctl -u vsftpd -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo ss -ltnp | grep ":21 "
```

Expected: An FTP listener on the intended address; then log in and transfer an allowed test file with the required client. Port 21 alone does not verify passive data transfers. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/vsftpd.conf.before-cp /etc/vsftpd.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### ProFTPD
In `/etc/proftpd/proftpd.conf`: `DefaultRoot ~`, `RootLogin off`, `ServerIdent off`, and comment out (`#`) the whole `<Anonymous ~ftp> ... </Anonymous>` block. Test with `sudo proftpd -t`.

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed ProFTPD without removing the required service.

**Why it matters:** Disable only an unauthorized Anonymous block and review Include files. DefaultRoot confines users to their home directory; verify necessary shared directories remain accessible.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' proftpd-core
systemctl status proftpd --no-pager
systemctl cat proftpd
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use the required FTP client and inspect the connection log for TLS or permission errors.

**Typing (check and backup):** Main configuration: `/etc/proftpd/proftpd.conf`. First preserve it:

```bash
sudo cp -a /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/proftpd/proftpd.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
DefaultRoot ~
RootLogin off
ServerIdent off
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo proftpd -t
```

Expected: Syntax check complete. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload proftpd
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status proftpd --no-pager
sudo journalctl -u proftpd -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo ss -ltnp | grep ":21 "
```

Expected: Listener remains and an authorized client can list and transfer in its intended directory. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/proftpd/proftpd.conf.before-cp /etc/proftpd/proftpd.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### Pure-FTPd
```bash
echo yes | sudo tee /etc/pure-ftpd/conf/NoAnonymous
echo yes | sudo tee /etc/pure-ftpd/conf/ChrootEveryone
sudo systemctl restart pure-ftpd
```

---

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Pure-FTPd without removing the required service.

**Why it matters:** These are separate filename/value pairs, not lines for one configuration file: edit /etc/pure-ftpd/conf/NoAnonymous and /etc/pure-ftpd/conf/ChrootEveryone to contain yes. Preserve anonymous access when explicitly required.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' pure-ftpd
systemctl status pure-ftpd --no-pager
systemctl cat pure-ftpd
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use the required FTP client; no standard desktop GUI edits the Debian wrapper files.

**Typing (check and backup):** Main configuration: `/etc/pure-ftpd/conf`. First preserve it:

```bash
sudo cp -a /etc/pure-ftpd/conf /etc/pure-ftpd/conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/pure-ftpd/conf/NoAnonymous
sudo nano /etc/pure-ftpd/conf/ChrootEveryone
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
NoAnonymous: yes
ChrootEveryone: yes
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo pure-ftpd-wrapper --show-options
```

Expected: Inspect generated options; this does not start a server or guarantee runtime validity. If the validation fails, do not continue. When correct:

```bash
sudo systemctl restart pure-ftpd
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status pure-ftpd --no-pager
sudo journalctl -u pure-ftpd -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo ss -ltnp | grep ":21 "
```

Expected: Listener present and authorized FTP login and data transfer work. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/pure-ftpd/conf.before-cp/. /etc/pure-ftpd/conf/
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### Samba (Windows file sharing)

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
sudo nano /etc/samba/smb.conf
```
In `[global]`:
```
   restrict anonymous = 2
   map to guest = never
   usershare allow guests = no
   server min protocol = SMB2
```
In each share (`[sharename]`): `guest ok = no` (or remove `public = yes`). Check `read only` and `valid users` match what the README says.
```bash
testparm -s                    # check the file
sudo systemctl restart smbd
sudo pdbedit -L                # Samba users: remove any that aren't authorized
sudo smbpasswd -x mallory
```

---

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Samba (Windows file sharing) without removing the required service.

**Why it matters:** Edit the existing global section. In each required share inspect guest ok, valid users, read only and path. Guest access can be an explicit scenario requirement. Preserve directory ownership and Unix group permissions.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' samba
systemctl status smbd --no-pager
systemctl cat smbd
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** On Windows use File Explorer with \\server\share, or Linux Files → Other Locations → smb://server/share. Test read/write as the required ordinary user.

**Typing (check and backup):** Main configuration: `/etc/samba/smb.conf`. First preserve it:

```bash
sudo cp -a /etc/samba/smb.conf /etc/samba/smb.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/samba/smb.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
[global]
   map to guest = never
   usershare allow guests = no
   server min protocol = SMB2
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo testparm -s
```

Expected: Loaded services file OK; warnings still need review. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload smbd
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status smbd --no-pager
sudo journalctl -u smbd -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo smbclient -L localhost -U alice
```

Expected: Authorized share list; supply the password interactively and use a real authorized Samba account. smbclient may not be installed; use an existing Windows client instead. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/samba/smb.conf.before-cp /etc/samba/smb.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### BIND DNS server

In `/etc/bind/named.conf.options`, inside `options { ... };`:
```
        version "none";                 // hide the version
        allow-transfer { none; };       // don't hand out the zone to anyone
        allow-recursion { localhost; localnets; };
```
```bash
sudo named-checkconf && sudo systemctl reload named
```
Also look in `/etc/bind/named.conf.local` for zones with `allow-transfer { any; };` or `allow-update { any; };`.

---

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed BIND DNS server without removing the required service.

**Why it matters:** Merge into the existing options block; do not create a second block. Replace localnets with explicit approved networks where practical. Required secondary DNS servers need an explicit allow-transfer ACL, preferably TSIG; none would break transfers. Inspect zone-level overrides.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' bind9
systemctl status named --no-pager
systemctl cat named
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use client network settings to confirm the expected DNS server; edit BIND through the terminal.

**Typing (check and backup):** Main configuration: `/etc/bind/named.conf.options`. First preserve it:

```bash
sudo cp -a /etc/bind/named.conf.options /etc/bind/named.conf.options.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/bind/named.conf.options
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
options {
    allow-recursion { localhost; localnets; };
    allow-transfer { none; };
};
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo named-checkconf
```

Expected: No output and exit 0; separately run named-checkzone for every edited zone. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload named
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status named --no-pager
sudo journalctl -u named -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
dig @127.0.0.1 example.org
```

Expected: Expected answer/status for a real required zone; also test an authorized remote client and any required secondary server. An authoritative-only server may correctly refuse unrelated recursion. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/bind/named.conf.options.before-cp /etc/bind/named.conf.options
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### Postfix mail server

```bash
sudo postconf -e 'disable_vrfy_command = yes'        # can't ask "does user X exist?"
sudo postconf -e 'smtpd_helo_required = yes'
sudo postconf -e 'smtpd_banner = $myhostname ESMTP'  # hide the version
postconf mynetworks                                  # must NOT contain 0.0.0.0/0 (open relay)
sudo postfix check && sudo systemctl reload postfix
```

---

##### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Postfix mail server without removing the required service.

**Why it matters:** These reduce user enumeration and require a proper SMTP greeting. Inspect mynetworks and smtpd_relay_restrictions: never trust 0.0.0.0/0 or ::/0. Preserve approved relay networks, local destinations and authenticated submission.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' postfix
systemctl status postfix --no-pager
systemctl cat postfix
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use an already configured local mail client if permitted; no general desktop GUI safely edits relay policy.

**Typing (check and backup):** Main configuration: `/etc/postfix/main.cf`. First preserve it:

```bash
sudo cp -a /etc/postfix/main.cf /etc/postfix/main.cf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/postfix/main.cf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
disable_vrfy_command = yes
smtpd_helo_required = yes
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo postfix check
```

Expected: No diagnostics; warnings require review. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload postfix
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status postfix --no-pager
sudo journalctl -u postfix -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo postconf mynetworks smtpd_relay_restrictions mydestination
```

Expected: Only expected trusted networks/destinations; perform an authorized local delivery test and inspect mail logs. Do not send test messages to real third parties. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/postfix/main.cf.before-cp /etc/postfix/main.cf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

##### SSH
See section 9 of the [Linux Mint checklist](linux-mint.md#9-ssh-server-only-if-installed).

---

##### WordPress (and other web apps)
- Update WordPress, plugins and themes from the admin dashboard.
- Delete admin accounts in WordPress that the README doesn't list (**Users** page).
- In `wp-config.php`, add `define('DISALLOW_FILE_EDIT', true);` so the dashboard can't edit PHP files.
- Make sure `wp-config.php` isn't readable by everyone: `sudo chmod 640 wp-config.php`.

##### PostgreSQL: local and required remote database access

- [ ] Done

**What:** Inspect PostgreSQL listening addresses, client authentication and database roles.

**Why it matters:** `trust` authentication can let a connecting client impersonate database users without a password. An overly restrictive listener can break a required web application on another machine.

**Before changing anything:** In a Linux terminal run:

```bash
dpkg-query -W postgresql postgresql-common
pg_lsclusters
```

`pg_lsclusters` lists version, cluster, port, status and data/log directories. The generic `postgresql.service` can be `active (exited)` while a cluster is down; inspect the listed cluster. Connect locally:

```bash
sudo -u postgres psql -c 'SHOW config_file;' -c 'SHOW hba_file;' -c 'SHOW listen_addresses;'
```

**Clicking (GUI):** Use a trusted installed database client to test the authorized account; do not use a superuser's successful connection as the ordinary client's test. There is no standard desktop GUI for these configuration files.

**Typing (check and backup):** Substitute the actual paths shown above. For version 15 cluster main:

```bash
sudo cp -a /etc/postgresql/15/main/postgresql.conf /etc/postgresql/15/main/postgresql.conf.before-cp
sudo cp -a /etc/postgresql/15/main/pg_hba.conf /etc/postgresql/15/main/pg_hba.conf.before-cp
```

**Typing (fix, only when appropriate):**

```bash
sudo nano /etc/postgresql/15/main/postgresql.conf
```

Inspect `listen_addresses = 'localhost'` for local-only clients. Required remote clients need the intended server address, not a blind wildcard. Then:

```bash
sudo nano /etc/postgresql/15/main/pg_hba.conf
```

Keep legitimate local peer authentication. Replace only an unauthorized `trust` rule with a compatible method. An example restricted remote rule is configuration text:

```text
host    appdb    appuser    192.168.10.0/24    scram-sha-256
```

First ensure that the role has a SCRAM password and clients support it. PostgreSQL uses the **first matching** HBA rule; a later secure rule does not override an earlier broad one.

**Typing (validate/apply):**

```bash
sudo -u postgres psql -c 'SELECT line_number,error FROM pg_hba_file_rules WHERE error IS NOT NULL;'
sudo -u postgres psql -c 'SELECT sourcefile,sourceline,name,error FROM pg_file_settings WHERE error IS NOT NULL;'
```

No error rows is expected, but these views do not replace client tests. Reload HBA-only changes:

```bash
sudo -u postgres psql -c 'SELECT pg_reload_conf();'
```

Listener changes require a scheduled cluster restart, for this example:

```bash
sudo pg_ctlcluster 15 main restart
```

**Check it worked:** Run `pg_lsclusters`, re-query settings and test the real application as its database role. In `psql`, `\du` lists roles; inspect unexpected superuser, create-role or replication privileges. Do not put passwords on the shell command line.

**Undo:** Restore the two original files, validate them again, reload or restart according to which setting changed, and repeat the client test. Restore role credentials/grants separately if they changed.

**Warnings:** A config backup is not a database backup. Do not drop roles or databases until ownership, application dependencies and forensics are resolved.

##### ISC DHCP and Kea: identify the implementation first

- [ ] Done

**What:** Keep required address allocation working while removing unauthorized scope or gateway settings.

**Why it matters:** A wrong DHCP router or DNS option can disconnect every client even though the daemon is running.

**Before changing anything:** Terminal checks:

```bash
dpkg-query -W isc-dhcp-server kea-dhcp4-server
systemctl status isc-dhcp-server kea-dhcp4-server --no-pager
ip -br address
```

A not-installed result is normal. Determine which implementation owns UDP 67 with `sudo ss -lunp`. Do not start a second DHCP server on the same lab network.

**Clicking (GUI):** On a test client, open network settings and record its lease address, mask, router and DNS servers. A server GUI is not generally provided.

**Typing (check and backup):** ISC uses `/etc/dhcp/dhcpd.conf` and `/etc/default/isc-dhcp-server`. Kea normally uses `/etc/kea/kea-dhcp4.conf`. For the installed ISC example:

```bash
sudo cp -a /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.before-cp
sudo cp -a /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.before-cp
sudo nano /etc/dhcp/dhcpd.conf
```

**Typing (fix, only when appropriate):** In the existing `subnet ... netmask ... {}` block, inspect `range`, `option routers`, and `option domain-name-servers`. The range must belong to the subnet and exclude static server addresses. In `/etc/default/isc-dhcp-server`, `INTERFACESv4` must name the intended lab-facing interface. Keep relay requirements.

**Typing (validate/apply):**

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

Only after a successful test:

```bash
sudo systemctl restart isc-dhcp-server
```

For installed Kea instead, back up its JSON file, edit the existing `Dhcp4` → `subnet4`, `pools`, `option-data` and `interfaces-config` settings; preserve JSON types and validate:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Then restart `kea-dhcp4-server` only after success. Do not apply ISC syntax to Kea.

**Check it worked:** Inspect unit status/journal and renew a noncritical authorized test client's lease through its network GUI. Verify assigned address, gateway, DNS and access to a required internal hostname. A listening UDP socket alone is insufficient.

**Undo:** Restore the changed file(s), validate with the same implementation's command and restart that unit. Do not delete the lease database to repair a syntax error.

**Warnings:** ISC DHCP is a legacy implementation; preserve the scenario's installed server rather than migrating implementations during a timed round. Do not renew your only remote-management client's lease until console access exists.

##### Web application files and certificates

- [ ] Done

**What:** Preserve required application behavior while checking secrets, writable directories and TLS.

**Why it matters:** Removing a file because it contains `eval` or `exec` can destroy legitimate code; a web shell may also use neither string.

**Before changing anything:** Back up the application, database and virtual-host config separately. Identify the web worker account and required write directories. Do not put backups containing credentials in the web root.

**Clicking (GUI):** In the application's admin panel review users, plugins, themes and supported updates. In a browser inspect the certificate hostname, expiry and chain for the actual required HTTPS hostname.

**Typing (check):**

```bash
sudo find /var/www -xdev -type f -mtime -7 -ls
sudo find /var/www -xdev -type f -perm -0002 -ls
sudo stat /var/www/html/wp-config.php
```

Unexpected recent or world-writable files need comparison with a trusted package/application baseline. Do not run suspicious PHP files or publish configuration secrets.

**Typing (fix, only when appropriate):** For WordPress, use the editor on the actual `wp-config.php` and add `define('DISALLOW_FILE_EDIT', true);` only once before the final stop-editing comment. Set ownership/group so only the actual administrator and web worker can read credentials; `chmod 640` alone is not sufficient if the group is wrong. Update through supported application mechanisms after backup.

**Check it worked:** Test login, static pages, uploads if required, database access and HTTPS from the intended client. Inspect application/server logs without clearing them.

**Undo:** Restore the particular changed config or supported application/database backup. Restore compatible versions together; a database schema migration may not support file-only rollback.

**Warnings:** Headers, hidden version strings and disabled PHP functions are supporting controls, not proof an application is secure. Keep required functionality and patch vulnerabilities.



---

---

### 21. Advanced Linux manual investigations (embedded)

The original practical text and copyable command blocks are retained here for self-contained study. For a Debian image, use Debian-specific explanations in Sections 0–19 before changing a setting.


> Use alongside [Linux Mint](linux-mint.md), [Ubuntu](ubuntu.md), [Debian](debian.md), and [critical service hardening](linux-mint.md#20-complete-linux-critical-service-hardening-procedures-embedded). This page assumes **Ubuntu / Debian / Linux Mint using systemd**; consult the [FreeBSD checklist](freebsd.md) for FreeBSD-specific commands. **Read the image README and preserve forensics evidence first.**

These are individually copyable terminal commands. **Inspection is not the same as permission to modify.** Run modifications only after verifying accounts, critical services, connectivity and backups.

##### L1. Verify user identities and sudo privileges—don't guess from names

- [ ] Matched every privileged identity to the competition README.

**Typing (check, Terminal):**

~~~bash
getent passwd
~~~

The third colon-delimited field is the UID, and the final field is the login shell. Service accounts commonly use \`/usr/sbin/nologin\`; that is not automatically suspicious.

~~~bash
awk -F: '$3 == 0 {print $1 " UID=" $3 " home=" $6 " shell=" $7}' /etc/passwd
~~~

Only \`root\` normally needs UID 0. An additional UID 0 account requires investigation, but **do not delete it before the README check and forensic preservation**.

~~~bash
getent group sudo
sudo grep -RnsE '^[[:space:]]*[^#[:space:]].*(ALL|NOPASSWD)' /etc/sudoers /etc/sudoers.d 2>/dev/null
~~~

**Interpretation:** Sudo rules can grant rights to users/groups without those names appearing as members of the \`sudo\` group. Look for \`NOPASSWD\`, wildcards and unusual command allowlists, but understand service/administration needs before editing.

**Before editing a sudo rule:**

~~~bash
sudo visudo -c
sudo cp -a /etc/sudoers /etc/sudoers.cp-backup
~~~

If authorized, use \`sudo visudo\` for the main file or \`sudo visudo -f /etc/sudoers.d/NAME\` for a specific included file. **Never edit sudo policy with an unvalidated plain-text overwrite.**

**Check after an authorized edit:**

~~~bash
sudo visudo -c
~~~

**Recovery:** Restore the backed-up single file through a root/recovery console if sudo stops working. Test a separate authorized session before leaving the administrator session.

##### L2. SSH: inspect *effective* settings and socket activation

- [ ] Confirmed whether SSH is required, listening and correctly configured.

**Typing (check):**

~~~bash
systemctl status ssh --no-pager
systemctl status ssh.socket --no-pager
sudo ss -lntp
~~~

A distribution may use \`ssh.service\`, \`ssh.socket\` or other units; an inactive service does **not** alone mean that clients cannot connect. Ubuntu releases since 22.10 may use socket activation, with a generator-based configuration behavior on Ubuntu 24.04.

**Find the effective configuration, including snippets:**

~~~bash
sudo grep -RnsE '^[[:space:]]*(Include|PermitRootLogin|PasswordAuthentication|KbdInteractiveAuthentication|AllowUsers|AllowGroups|PubkeyAuthentication|Port|ListenAddress)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d 2>/dev/null
~~~

~~~bash
sudo /usr/sbin/sshd -t
sudo /usr/sbin/sshd -T | grep -Ei '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|kbdinteractiveauthentication|allowusers|allowgroups) '
~~~

\`sshd -t\` checks configuration syntax. \`sshd -T\` prints effective settings for a generic connection; **\`Match\` rules may alter settings for particular users/hosts**, so check their applicability before concluding all sessions have the same policy.

**GUI / file editing:** In a terminal use \`sudo nano /etc/ssh/sshd_config\` or edit the *specific* applicable file under \`/etc/ssh/sshd_config.d/\`. Before modifying it, copy that same file with \`sudo cp -a source destination\` to a backup path.

**Safe sequence for an authorized change:**

1. Keep the existing administrative session open.
2. Record current listening port, login method and allowed source addresses.
3. Confirm the README-required SSH accounts and methods; do **not** blindly disable password authentication if no working keys exist.
4. Edit the specific applicable setting, avoiding conflicting \`Include\` or \`Match\` directives.
5. Run \`sudo /usr/sbin/sshd -t\`; **stop if it reports errors**.
6. Reload the relevant service if supported and consistent with socket activation. On a conventional systemd SSH service:

~~~bash
sudo systemctl reload ssh
~~~

7. Open **a second SSH session** from an approved client, test normal login, and only then close the original session.

**Recovery:** Restore the exact backed-up config and reload/activate the appropriate unit using VM console if the remote test fails. If you changed the listening port on a socket-activated release, verify the socket generator/unit state too; don't assume an \`sshd_config\` reload alone changes the listener.

##### L3. PAM policy: inspect order before adding modules

- [ ] Inspected current PAM stack and package availability.

**Typing (check):**

~~~bash
dpkg-query -W libpam-pwquality libpam-modules libpam-runtime 2>/dev/null
sudo grep -nEv '^[[:space:]]*(#|$)' /etc/pam.d/common-password /etc/pam.d/common-auth
grep -E '^[[:space:]]*PASS_(MAX|MIN|WARN)' /etc/login.defs
~~~

**Interpretation:** PAM is order-sensitive. A duplicated \`pam_unix.so\`, unsuitable control flag, or unavailable module can lock out every user. \`/etc/login.defs\` supplies defaults for some tools; it does **not** automatically change every existing account's expiry settings.

**Read one existing user's actual policy (replace username):**

~~~bash
sudo chage -l exampleuser
~~~

If changing aging is required, consult the policy specified in the README and the [Mint checklist](linux-mint.md#3-password-and-lockout-policy) for \`chage\` examples.

**Before edits:** Preserve backups of \`/etc/pam.d/common-password\`, \`common-auth\` and the relevant original config, plus working console/root access. When available, use distribution-maintained \`pam-auth-update\` rather than inventing a new stack.

**Verification:** Before logging out, test authentication in a *new local or console session* as an authorized ordinary user and verify an authorized sudo elevation. Never intentionally force a logout while authentication is unverified.

**Recovery:** Restore the specific original PAM file using recovery/console access, then retest. This is a high-risk category and should not be changed merely because a generic checklist recommends a number.

##### L4. Check scheduled persistence in cron and systemd

- [ ] Investigated scheduler entries before deleting anything.

**Typing (check):**

~~~bash
sudo cat /etc/crontab
sudo ls -la /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly
sudo crontab -l
~~~

The last command shows root's crontab because of \`sudo\`. To inspect one authorized user's crontab:

~~~bash
sudo crontab -u exampleuser -l
~~~

**Inspect enabled and currently active units:**

~~~bash
systemctl list-unit-files --type=service --state=enabled
systemctl list-timers --all
systemctl --failed
~~~

**Inspect where a particular unit comes from (replace the name):**

~~~bash
systemctl cat example.service
systemctl show example.service -p FragmentPath -p ExecStart -p User -p WantedBy
~~~

**What to look for:** Unexpected execution from writable directories, shell commands launched as root, timers with misleading names, recent unexplained unit changes. A valid systemd service may be intentionally started through sockets or dependencies even when its service unit is disabled.

**Verification:** Correlate any suspicious entry with \`journalctl -u example.service\`, ownership, file hashes, the README, and required software. Do not execute suspicious payloads.

**Recovery:** For an unauthorized entry, document and preserve it before making the smallest authorized change. To undo a previous disable operation, restore the recorded original unit enablement/state only; do not indiscriminately enable every listed service.

##### L5. Firewall: preserve required access before enabling UFW

- [ ] Identified real listeners, rule owner and permitted clients.

**Typing (check):**

~~~bash
sudo ss -lntup
sudo ufw status verbose
sudo ufw status numbered
~~~

On hosts using \`nftables\` directly, inspect **before** adding UFW rules:

~~~bash
sudo nft list ruleset
~~~

**Interpretation:** A service on \`127.0.0.1\` is locally bound, while \`0.0.0.0\` or \`[::]\` may be externally reachable if network/firewall paths allow. A listening port is not automatically unnecessary.

**Before an approved UFW enablement:** Write down required SSH, HTTP/HTTPS, DNS, DHCP and other ports from the README; check the current remote-management path.

For an image requiring SSH on TCP 22, the specific allowance is:

~~~bash
sudo ufw allow 22/tcp
~~~

Only after verifying the required rules and retaining console access, if UFW is the chosen firewall:

~~~bash
sudo ufw enable
sudo ufw status verbose
~~~

**Verify:** From an approved client, retest every README-required service and the management connection. \`ufw\` is a front end to Linux packet filtering and may coexist/conflict with other managers; do **not** reset \`iptables\`/\`nftables\` blindly.

**Recovery:** If you blocked access, use the VM console to restore the documented previous UFW state/rules; avoid deleting all firewall rules as a first response.

##### L6. Narrow file and package investigations

- [ ] Inspected evidence, not deleted files by extension alone.

~~~bash
sudo find /home /root /tmp /var/tmp -type f -mtime -2 -printf '%TY-%Tm-%Td %TH:%TM %u %m %p\n' 2>/dev/null
sudo find /home /root /tmp /var/tmp -type f -perm /0002 -ls 2>/dev/null
sudo find /usr/local/bin /usr/local/sbin -type f -perm /4000 -ls 2>/dev/null
~~~

**Interpretation:** These are *scoped searches*. They do not prove the rest of the file system is clean. World-writable and SUID files can be legitimate; an unusual entry requires review of owner, package and use.

~~~bash
dpkg -S /usr/bin/ssh 2>/dev/null
apt-cache policy openssh-server
grep -h ' install ' /var/log/dpkg.log* 2>/dev/null | tail -30
~~~

If \`dpkg -S\` reports no owning package for another path, investigate—some applications are legitimately installed outside dpkg.

**Final check:**

~~~bash
systemctl --failed
sudo ss -lntup
who
~~~

Confirm normal login, sudo, DNS/networking and all required services. Record any unverified concern rather than destroy unknown files.

##### References and cross-checks

- [Ubuntu 24.04 OpenSSH socket activation notes](https://documentation.ubuntu.com/release-notes/24.04/)
- [Ubuntu security: Unnecessarily open ports](https://documentation.ubuntu.com/security/common-mistakes/unnecessarily-open-ports/)
- [Ubuntu security: Firewalls](https://documentation.ubuntu.com/security/security-features/network/firewall/)
- CyberPatriot community topic inventories: [PeapGit CPLHF](https://github.com/PeapGit/cplhf) (historical hardening automation: **do not execute as part of this guide**), [Minagera Linux checklist](https://github.com/Minagera/CyberPatriot/blob/main/Checklists/Linux/README.md), [chessischess Linux checklist](https://github.com/chessischess/cyberpatriot-checklist/blob/master/Linux_Checklist.md).



---

---

### 22. Complete Linux terminal basics (embedded)

The original practical text and copyable command blocks are retained here for self-contained study. For a Debian image, use Debian-specific explanations in Sections 0–19 before changing a setting.


The **terminal** is a window where you type commands instead of clicking. On Linux most security work is faster in the terminal, and many settings can *only* be changed there.

**Open it:** press **Ctrl + Alt + T**, or open the menu and search for "Terminal".

##### How a command looks

```bash
id bob
```
- `id` = the command (show identity and group membership).
- `sudo` before a privileged command means run it with administrative authority; it normally asks for **your** password and does not echo it. This read-only example does not need it.
- `bob` = what to do it to.

Press **Enter** to run it. If it worked, Linux often prints **nothing**. Check the exit status and repeat the native verification; silence alone is not proof of success.

##### Keys that save time
| Key | What it does |
|---|---|
| **Tab** | Auto-complete a file or command name. Press it twice to see the choices. |
| **↑ / ↓** | Bring back earlier commands. |
| **Ctrl + C** | Stop the command that is running. |
| **Ctrl + Shift + C / V** | Copy / paste *inside the terminal* (plain Ctrl+C means "stop"!). |
| **q** | Quit a viewer like `less` or `man`. |

##### The 20 commands you'll actually use
| Command | What it does | Example |
|---|---|---|
| `pwd` | Show which folder you're in | `pwd` |
| `ls -la` | List files, including hidden ones (names starting with `.`) | `ls -la /home/bob` |
| `cd` | Go to a folder | `cd /etc` |
| `cat` | Print a file | `cat /etc/passwd` |
| `less` | Read a long file (q to quit, / to search) | `less /var/log/auth.log` |
| `nano` | Simple text editor (Ctrl+O save, Ctrl+X exit) | `sudo nano /etc/ssh/sshd_config` |
| `grep` | Find lines containing a word | `grep -i bob /etc/group` |
| `find` | Find files | `sudo find /home -iname "*.mp3"` |
| `rm` | Delete a file (no recycle bin!) | `sudo rm /home/bob/song.mp3` |
| `cp` | Copy | `sudo cp file file.bak` |
| `sudo` | Run as administrator | `sudo apt update` |
| `apt` | Install / remove / update software | `sudo apt purge nmap` |
| `systemctl` | Start / stop / check services | `systemctl status ssh` |
| `ss -tulpn` | Show what's listening on the network | `sudo ss -tulpn` |
| `ps aux` | Show running programs | `ps aux \| grep nc` |
| `id` | Show a user's groups | `id bob` |
| `passwd` | Change a password | `sudo passwd bob` |
| `chmod` / `chown` | Change permissions / owner | `sudo chmod 640 /etc/shadow` |
| `history` | Show your past commands | `history` |
| `man` | The manual for a command | `man userdel` |

##### Reading permissions
```
-rw-r----- 1 root shadow 1234 Oct 22 10:00 /etc/shadow
 ^^^ owner can read+write
    ^^^ group can read
       ^^^ others: nothing
```
Numbers: r=4, w=2, x=1. So `640` = owner rw (6), group r (4), others none (0).

##### Paths you'll see a lot
| Path | What's there |
|---|---|
| `/etc/` | Settings files for almost everything |
| `/home/<user>/` | Each user's files (Desktop, Documents, Downloads...) |
| `/var/log/` | Log files |
| `/tmp/` | Temporary files (attackers like hiding things here) |
| `/root/` | The root user's home folder |

##### Safety tips
- **Read the command before pressing Enter**, especially anything with `rm`.
- Before editing a settings file, **copy it**: `sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak`
- If a command asks `[Y/n]`, read what it's about to remove before answering.
- Recovery depends on the operation. Record values/backups before changes; deletion and credential changes may have no simple undo.

##### Practice a safe inspect–edit–verify–undo cycle

- [ ] Done

**What:** Learn quoting, exit status, file editing and recovery on a harmless private practice file.

**Why it matters:** Commands act on exact paths; spaces, shell wildcards and redirection change their meaning. A blank result is not proof of success.

**Before changing anything:** Use a normal user's terminal on a permitted practice image. These commands do not need sudo. Do not use a real security configuration for your first editing exercise.

**Clicking (GUI):** Open **Terminal** from the desktop menu. Open the file manager alongside it and compare your home directory with `pwd` and `ls -la`. In a terminal, **Ctrl+Shift+V** pastes; inspect the whole pasted line before Enter.

**Typing (check/create):**

```bash
pwd
mkdir -m 700 "$HOME/cp-terminal-practice"
```

If the directory exists, inspect it instead of overwriting existing work. Create a harmless file:

```bash
printf '%s\n' 'original value' > "$HOME/cp-terminal-practice/example notes.txt"
```

Double quotes keep the path with spaces together; `$HOME` expands to your home folder. Single quotes keep text literal. `>` overwrites a file; `>>` appends. Neither belongs in a command unless you intend a write.

**Typing (edit):**

```bash
cp -p "$HOME/cp-terminal-practice/example notes.txt" "$HOME/cp-terminal-practice/example notes.txt.before"
nano "$HOME/cp-terminal-practice/example notes.txt"
```

Change the text, **Ctrl+O → Enter** to save, **Ctrl+X** to leave. Use `command --help` or `man command` to inspect options; press `q` to leave a manual. A leading `#` in handbook prose is not a command prompt to paste.

**Check it worked:**

```bash
cat "$HOME/cp-terminal-practice/example notes.txt"
echo "$?"
```

`$?` is the previous command's exit status: usually 0 means success; nonzero needs interpretation. For `grep`, 1 means no match, while 2 commonly means an error. Check immediately; any intervening command changes `$?`. `&&` runs the next command only after success, but a beginner should inspect commands individually first.

**Undo:**

```bash
cp -p "$HOME/cp-terminal-practice/example notes.txt.before" "$HOME/cp-terminal-practice/example notes.txt"
cat "$HOME/cp-terminal-practice/example notes.txt"
```

Expect `original value`. Practice files may be removed through the file manager after you have checked their paths.

**Warnings:** `sudo command > /protected/file` elevates the command, not the shell opening the file. Do not solve permission errors with `chmod 777`. Avoid `rm -rf`, guessed wildcards, copied shell prompts and piping downloads into a shell. **Ctrl+C** is appropriate for a stuck search, but interrupting package configuration or file writes can leave incomplete work.

## Part 6 — Final Verification

Check required functions, users, services, firewall, score and forensic evidence before concluding.

### 18. Final checks

- [ ] Every critical service is running: `systemctl status ssh` (repeat with each service the README lists)
- [ ] You can still use `sudo`
- [ ] The Scoring Report shows **no penalties**
- [ ] All forensics answers are saved
- [ ] Take a final snapshot
- [ ] **Don't reboot** unless you need to. If you must, reboot once and check everything still works.

