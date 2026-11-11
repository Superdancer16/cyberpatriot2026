# Ubuntu CyberPatriot — Complete, Prioritized Step-by-Step Handbook

**Ubuntu workstation and server practice for Ubuntu 22.04 and 24.04, with legacy 20.04 notes.** This is a comprehensive documentation-only guide, not an auto-hardening script. It places **Basics / Information Needed → First Things to Do → Commonly Assessed Checks → Services and Software → Advanced Topics → Final Verification** in increasing complexity.

> [!IMPORTANT]
> **Actual competition scope:** CyberPatriot XIX (2026–27) lists **Ubuntu 24** for the high-school State Round and **Ubuntu 22** in training rounds. Check the [official current challenges-by-round schedule](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round) before assuming what image will appear.
>
> **Scoring:** No public guide can promise the points from any individual fix. The image README defines authorized users, critical services, prohibited software and constraints. **Read it and preserve forensic evidence before remediation.**


> [!NOTE]
> **How this guide uses the CyberPatriot XVI–XIX research catalog:** **Official** means documented by CyberPatriot; **Training** means found in public practice/training materials; **Community** means covered by published checklists or educational repositories; **Inferred** means normal vendor-supported security hardening that is **not known to have been scored**. The report is a topic inventory, **not a list of actual confidential competition vulnerabilities, scoring keys or guaranteed points**. In the research-expansion sections below, every suggested change requires a verified scenario reason, a saved original value and a check of required service availability. All PowerShell/Bash examples are **manual commands inside Markdown**, not automation scripts. The image README and current rules always take precedence.

## Part 1 — Basics / Information Needed

### 1.1 Ubuntu terms, differences and useful GUIs

- [ ] Understand **sudo** (an authorized privilege elevation), **APT** (Debian/Ubuntu package manager), **Snap** (separate package distribution), **systemd services/timers/sockets**, **UFW**, **AppArmor**, **PAM**, **Netplan** and **NetworkManager**.
- [ ] Know the desktop-versus-server difference. GNOME users can open **Settings → Users**, **Privacy / Screen Lock**, **Sharing**, and **Software & Updates** if installed. A headless Ubuntu Server often has no desktop.
- [ ] Keep a working authorized sudo/console session while changing accounts, SSH, network configuration, firewall or PAM.
- [ ] Check actual installed version and architecture. Ubuntu 24.04 and 22.04 differ in OpenSSH activation, package versions and some GNOME settings.
- [ ] Use individual copyable commands; **do not run a downloaded one-line hardening script**.

**Typing (check; Terminal via Ctrl+Alt+T on a desktop, console on server):**

~~~bash
cat /etc/os-release
uname -r
id
command -v sudo
systemctl status display-manager --no-pager
~~~

**Interpretation:** **PRETTY_NAME** and **VERSION_ID** identify the release. A missing display manager is normal on Ubuntu Server. A lack of sudo rights is a real operational constraint—do not lock root or the only authorized admin without recovery.

### 1.2 How to read and verify commands

**Read-only inspection** usually uses **cat, getent, stat, apt-cache, systemctl status, ss, journalctl**, and **grep**. Modification uses **passwd, usermod, systemctl disable, ufw enable, apt install, nano** or editing configuration. Inspect first.

**GUI editing:** use **Files** to locate a nonprotected file, and a terminal text editor for privileged config. To edit a protected file that actually exists:

~~~bash
sudo nano /etc/ssh/sshd_config
~~~

**Nano keys:** Ctrl+W search → Ctrl+O and Enter save → Ctrl+X exit. For an actual file you intend to modify, back it up first:

~~~bash
sudo cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.before-cp
~~~

This is **only an example when OpenSSH Server is installed**. Choose a new backup name if .before-cp already exists. Reversing a change requires restoring the actual saved file and verifying the service's configuration syntax.

## Part 2 — First Things to Do

### 2.1 Read the competition image README and scoring report

- [ ] Open the README on the desktop, record **authorized administrators**, **normal users**, **required software**, **prohibited files/apps**, **critical services/ports**, and **forensics question locations**.
- [ ] Read it again before disabling any service. The same program (SSH, FTP, web server, database, Samba, printing, DNS) can be prohibited on one image and critical on another.
- [ ] Open the scoring report and record the starting value. Refresh after individually verified changes; do not modify scoring-engine files.
- [ ] Take a VM snapshot only if permitted; rollback may discard subsequent fixes.

**Typing (check; do not modify files):**

~~~bash
whoami
id
getent passwd
getent group sudo
systemctl list-units --type=service --state=running
sudo ss -lntup
~~~

Compare the output with the README. Ordinary service accounts are often expected and must not be removed.

### 2.2 Answer forensic questions before deleting or changing evidence

- [ ] Read each question word for word, identify the specific requested evidence, save exact answers in the original provided format, then proceed with remediation.

**Typing (read-only examples):**

~~~bash
find "$HOME/Desktop" -maxdepth 2 -type f -iname '*forensic*' -print 2>/dev/null
find /home /root -type f -iname '*secret*' -print 2>/dev/null
~~~

For a discovered evidence file, replace the example path:

~~~bash
file /home/exampleuser/Documents/suspect.dat
stat /home/exampleuser/Documents/suspect.dat
sha256sum /home/exampleuser/Documents/suspect.dat
~~~

View authentication and service activity without clearing logs:

~~~bash
sudo journalctl --since '24 hours ago' --no-pager
sudo journalctl -u ssh -n 50 --no-pager
last -a | head -25
~~~

**Why:** File hashes, timestamps, processes, user accounts and logs may change or disappear after upgrades, user deletion, antivirus cleanup or service restarts. A missing event is not proof no action occurred. **Never execute suspicious files**, including decoded Base64 payloads.

**Verify/undo:** Confirm forensic answers are saved. Restore only an accidental file modification from a permitted backup; deleting evidence may not be reversible.

### 2.3 Establish an administrative recovery route

- [ ] Confirm the authorized admin can elevate; keep the VM console available before SSH/firewall/network edits.

~~~bash
sudo -v
sudo -l
id
~~~

If sudo is unauthorized or unavailable, investigate the provided account/password policy rather than changing permissions blindly.

## Part 3 — Commonly Assessed High-Priority Checks

These are **frequently appearing concepts in public checklists**, not a guaranteed points list. Do the scenario-required, low-risk checks first.

### 3.1 Users, groups, UID 0 and sudo rights

- [ ] Compare every real human account and privileged group against the image README.

**Typing (check):**

~~~bash
getent passwd
getent group sudo
getent group adm
awk -F: '$3 == 0 {print $1, $3, $7}' /etc/passwd
sudo passwd -S -a
~~~

Only root normally needs UID 0. Service accounts with lower UIDs and nonlogin shells can be legitimate. The sudo group is not the only source of privileged rights; inspect sudoers in Part 3.2.

**GUI:** GNOME → **Settings → Users → Unlock**, compare authorized account roles (GUI omits many system accounts).

**Change examples ONLY after matching the README:**

~~~bash
sudo adduser exampleuser
~~~

~~~bash
sudo usermod -aG sudo exampleuser
~~~

~~~bash
sudo gpasswd -d exampleuser sudo
~~~

Do not run all three on the same example person. A user with changed group membership may need a new login session. **Never remove your only authorized administrator, root, a required service account or the scoring-engine identity.**

**Verify:**

~~~bash
id exampleuser
getent group sudo
~~~

**Undo:** Restore precisely the prior account role/group, testing a second authorized admin login. Deleting a user/home directory is much harder to reverse than disabling a confirmed unauthorized account.

### 3.2 Strong passwords, aging, PAM and lockout

- [ ] Know the README's exact password policy; inspect actual PAM modules before editing.

**Typing (check):**

~~~bash
sudo chage -l exampleuser
grep -E '^PASS_(MAX_DAYS|MIN_DAYS|WARN_AGE)' /etc/login.defs
sudo grep -nEv '^[[:space:]]*(#|$)' /etc/pam.d/common-auth /etc/pam.d/common-password
sudo grep -RnsE 'pam_pwquality|pam_pwhistory|pam_faillock|nullok' /etc/pam.d /etc/security 2>/dev/null
sudo visudo -c
~~~

**What to know:** login.defs supplies defaults for *new accounts*; existing users need their own aging review. PAM controls authentication and is **order-sensitive**. Copying a random stack can lock out every account. pam_tally2 is obsolete on modern Ubuntu. Check whether **libpam-pwquality** and supported auth profiles exist before editing.

**Changing one authorized user's password (interactive, if required):**

~~~bash
sudo passwd exampleuser
~~~

**Aging example ONLY if the README specifies 90 maximum / 1 minimum / 14 warning days:**

~~~bash
sudo chage -M 90 -m 1 -W 14 exampleuser
~~~

**Verify:**

~~~bash
sudo chage -l exampleuser
sudo visudo -c
~~~

**Undo:** Restore the previously recorded aging values if wrong. Before any PAM edit, retain a root console, back up the exact file and test a new ordinary-user authentication before closing the old login. Do not add duplicate pam_unix or pam_faillock entries blindly.

### 3.3 Firewall rules and required ports

- [ ] Discover actual firewall owner and **required service ports** before enabling deny-by-default.

**Typing (check):**

~~~bash
sudo ss -lntup
sudo ufw status verbose
sudo ufw status numbered
sudo nft list ruleset
~~~

UFW is common on Ubuntu but not guaranteed active. An active nftables manager or a container firewall may already own rules. A listening port is not automatically malicious.

**If UFW is the chosen manager and the README requires SSH on TCP 22**, allow SSH **before** activating a blocking firewall:

~~~bash
sudo ufw allow 22/tcp
~~~

If confirmed compatible with all required roles:

~~~bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo ufw status verbose
~~~

**Other rules are task-specific:** Web TCP 80/443; DNS TCP/UDP 53; DHCP broadcasts/relay; SMB TCP 445; FTP negotiated data ranges; database ports only to authorized clients.

**Verification:** From an approved client test SSH/web/share/database functionality and check native rules. **Undo:** Restore only the rule/change documented in the baseline using VM console if remote access fails; never flush all nftables rules or reset UFW to troubleshoot one port.

### 3.4 Signed APT repositories and security updates

- [ ] Verify installed Ubuntu version and repository source integrity. Some releases use deb822 .sources files.

~~~bash
cat /etc/os-release
apt-cache policy
sudo grep -RHE '^(deb |Types:|URIs:|Suites:|Components:|Signed-By:)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
apt-mark showhold
sudo dpkg --audit
~~~

Use the Ubuntu release codename shown in /etc/os-release (such as **jammy** or **noble**). Never insert Debian, Mint or unsupported PPA sources just because a guide says to update. Source lines with **trusted=yes** need special scrutiny; do not bypass signature verification.

**Update sequence after verifying sources and backup:**

~~~bash
sudo apt update
apt -s upgrade
~~~

Review a clean preview and ensure it will not remove required packages, then when permitted:

~~~bash
sudo apt upgrade
~~~

**Held packages:** If apt-mark showhold lists packages, investigate *why* they were held before removing the hold. A failed apt update could be DNS/time/mirror/repository rather than a missing permission.

**Verification:** Re-run apt list --upgradable and dpkg --audit; check required service function and pending reboot status. Do not perform a release upgrade or force reboot mid-round.

### 3.5 Snap packages and Firefox (Ubuntu-specific)

- [ ] Know that Ubuntu's Firefox on many supported desktop versions is delivered as a **Snap**, not simply a Debian package.

**Typing (check, only if Snap is installed):**

~~~bash
command -v snap
snap list
snap refresh --list
~~~

**Clicking:** Open **Software / App Center** or Firefox **Help → About Firefox**, using the actual desktop application. **Do not assume the APT package alone updates Firefox's Snap.**

**Change only if necessary/allowed:** Snap's supported refresh mechanism manages installed packages; do not remove snapd or unrelated snaps to speed the image. Confirm which browser and application packages the README requires.

**Verify:** Check version, application launch, and any required browser extension. A staged refresh or version number alone doesn't prove a scored vulnerability.

### 3.6 Required-service preservation

- [ ] Before turning off any daemons, identify dependency and required-client test.

~~~bash
systemctl list-units --type=service --state=running
systemctl list-unit-files --type=service --state=enabled
sudo ss -lntup
systemctl --failed
~~~

Investigate **openssh-server**, apache2/nginx, Samba, vsftpd, PostgreSQL/MariaDB, DNS, DHCP, mail, printing, VNC/RDP and other servers. Many are legitimate on some images.

**Narrow change (only for confirmed disallowed service):**

~~~bash
sudo systemctl disable --now example.service
~~~

**Check:** Confirm whether the service also uses **.socket** activation, a timer, dependency or alias. Test every README-required service afterward. **Undo:** Restore exactly the previous enable/running state, not blindly enable every listed unit.


### Research report expansion U-R1 — Ubuntu users, sudo, UID 0 and local authentication

- [ ] Done

**Evidence:** Official/training Windows/Linux image themes, community Linux checklists, and native Ubuntu commands. No secret scoring list is claimed.

**GUI (Desktop):** **Settings → Users → Unlock**. Compare authorized students/admins to the actual README; a headless server may have no GUI. Check service accounts separately in Terminal.

**Typing (check):**

~~~bash
getent passwd
getent group sudo
getent group adm
awk -F: '$3 == 0 {print $1 " UID=" $3 " SHELL=" $7}' /etc/passwd
sudo passwd -S root
sudo passwd -S -a
~~~

**Investigate sudo policies and high-privilege groups:**

~~~bash
sudo visudo -c
sudo grep -RnsE 'NOPASSWD|!authenticate' /etc/sudoers /etc/sudoers.d 2>/dev/null
getent group docker
getent group lxd
~~~

**Fix only if identity is verified unauthorized:** Remove **one** privileged membership:

~~~bash
sudo gpasswd -d EXAMPLE_USER sudo
~~~

A confirmed unauthorized account can be contained with a password lock and nonlogin shell after saving evidence:

~~~bash
sudo usermod -L EXAMPLE_USER
sudo usermod -s /usr/sbin/nologin EXAMPLE_USER
~~~

**Important:** Password locking may **not** prevent SSH-key logins or established sessions. A duplicate UID 0 account should be investigated, not have its UID changed blindly.

**Verification:** Recheck **id EXAMPLE_USER**, **getent group sudo** and an authorized new admin login. **Undo:** Restore the exact previous group membership, login shell and lock state; avoid deleting home files before forensics.

### Research report expansion U-R2 — Password aging, PAM quality, history and lockout

- [ ] Done

**Evidence:** Community/vendor-supported PAM controls. Historical length/age thresholds in the report vary, so the README supplies actual numeric constraints.

**Typing (check):**

~~~bash
grep -E '^PASS_(MAX_DAYS|MIN_DAYS|WARN_AGE)' /etc/login.defs
sudo chage -l EXAMPLE_USER
sudo grep -nEv '^[[:space:]]*(#|$)' /etc/pam.d/common-auth /etc/pam.d/common-password
sudo grep -RnsE 'pam_pwquality|pam_pwhistory|pam_faillock|pam_unix|pam_exec' /etc/pam.d 2>/dev/null
~~~

**Before editing PAM:** Keep a working admin/VM-console session and back up only the file actually targeted. Ubuntu's PAM integration supports **pam-auth-update** with installed profiles; a wrong control flag can block all users. Never copy a Debian/Mint stack without checking installed modules.

**Change example only if README requires 90 maximum / 1 minimum / 7 warning days:**

~~~bash
sudo chage -M 90 -m 1 -W 7 EXAMPLE_USER
~~~

**Verification:** Repeat **chage -l**, test a second normal-user login and an authorized sudo/password change *before closing the current admin session*.

**Undo:** Restore exact previous chage values and backed-up PAM file with recovery-console access. Do not indiscriminately disable PAM controls to repair one bad login.

### Research report expansion U-R3 — UFW, required ports, service identification and rollback

- [ ] Done

**Evidence:** Ubuntu vendor-backed UFW and community required-service checklists.

**Typing (check):**

~~~bash
sudo ufw status verbose
sudo ufw status numbered
sudo nft list ruleset
sudo ss -lntup
~~~

**Before change:** Record real required ports/services: SSH on its actual port, Apache/Nginx on assigned HTTP/TLS ports, Samba, DNS, DHCP, FTP, databases and authorized management. Verify whether UFW is the active firewall manager and keep console recovery.

**Fix only if UFW is chosen and SSH on TCP 22 must remain available:**

~~~bash
sudo ufw allow 22/tcp
~~~

Then, after reviewing all required exceptions:

~~~bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
~~~

**Verification:** Repeat **sudo ufw status numbered**, then test every required app from an authorized client. An active rule does not prove remote traffic works; use a real protocol-level connection check.

**Undo:** Restore the **specific** mistaken allow/deny rule or old policy from its recorded backup via console. Avoid disabling the entire firewall as a final workaround. If nftables/firewalld already owns the policy, do not layer an incompatible manager on top.

### Research report expansion U-R4 — SSH root access, effective directives and socket activation

- [ ] Done

**Evidence:** Vendor-backed Ubuntu OpenSSH configuration; may be required or absent by scenario.

**Typing (check):**

~~~bash
dpkg-query -W openssh-server 2>/dev/null
systemctl status ssh --no-pager
systemctl status ssh.socket --no-pager
sudo grep -RnsE '^[[:space:]]*(Include|Match|PermitRootLogin|PermitEmptyPasswords|PasswordAuthentication|X11Forwarding|MaxAuthTries)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d 2>/dev/null
sudo /usr/sbin/sshd -t
sudo /usr/sbin/sshd -T | grep -Ei '^(permitrootlogin|permitemptypasswords|passwordauthentication|x11forwarding|maxauthtries)'
~~~

**Version nuance:** Ubuntu 22.10+ may use SSH socket activation. On updated Ubuntu 24.04, socket listening configuration can be derived from sshd_config; **a stopped ssh.service does not automatically mean SSH is unreachable**.

**Before change:** Keep a current authenticated admin session and VM console, record the real SSH port, required password/key method and all Match/Include directives, then back up the actual file.

**Configuration example only when README permits it:**

~~~text
PermitRootLogin no
PermitEmptyPasswords no
~~~

Do not disable password authentication if the required authorized user has no tested SSH key. Other settings like **X11Forwarding no** or **MaxAuthTries 3** require compatibility review.

**Typing (validate then reload when supported):**

~~~bash
sudo /usr/sbin/sshd -t
sudo systemctl reload ssh
~~~

**Verification:** Establish a **second separate authorized SSH login**, inspect effective config and current listener. Check ssh.socket as well if used.

**Undo:** Restore backed-up exact config using the console, validate it and reload the correct service/socket state. Never close the original management connection until the new one works.

## Part 4 — Services, Software, Desktop and Persistence

### 4.1 SSH service and socket activation (critical Ubuntu difference)

- [ ] Confirm whether SSH is installed/required and whether **ssh.service** or **ssh.socket** controls the listener.

~~~bash
dpkg-query -W openssh-server 2>/dev/null
systemctl status ssh --no-pager
systemctl status ssh.socket --no-pager
sudo ss -lntp
~~~

Ubuntu 22.10+ may use SSH socket activation. Ubuntu 24.04's SSH socket behavior can be generated from sshd configuration, depending on package updates. **A stopped ssh.service does not prove remote SSH is disabled.**

Inspect the effective config and includes:

~~~bash
sudo grep -RnsE '^[[:space:]]*(Include|Match|Port|PasswordAuthentication|PermitRootLogin|PubkeyAuthentication|AllowUsers)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d 2>/dev/null
sudo /usr/sbin/sshd -t
sudo /usr/sbin/sshd -T | grep -Ei '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication)'
~~~

**Change workflow if README requires hardening:** Record original SSH server port/authentication, back up actual edited sshd_config or .d snippet, use sudo nano on that file, run **sshd -t**, reload when supported, **open a second authorized SSH session**, then close the original session only after success. Match rules can override per-user/client behavior. Do not disable password auth unless tested public keys exist and are authorized.

**Authorized keys investigation:**

~~~bash
sudo find /home /root -type f -path '*/.ssh/authorized_keys' -ls 2>/dev/null
~~~

Inspect each identified file's owner/mode, keys and README need; never delete all keys blindly.

### 4.2 GNOME, GDM, automatic login and screen locking

- [ ] Identify actual display manager and desktop. Do not apply these GNOME-specific settings to Ubuntu Server, KDE or Xfce images.

**Clicking:** GNOME **Settings → Users → Unlock** to inspect automatic login; **Settings → Privacy & Security / Screen Lock** to require a password after inactivity; **Settings → Sharing / Remote Desktop** to review required/unneeded remote features. Exact labels vary with GNOME release.

**Typing (check, run as the logged-in desktop user, NOT sudo):**

~~~bash
gsettings list-schemas | grep -E 'gnome.desktop.screensaver|gnome.desktop.session'
gsettings get org.gnome.desktop.screensaver lock-enabled
gsettings get org.gnome.desktop.session idle-delay
~~~

**GDM config inspection (read-only):**

~~~bash
systemctl status display-manager --no-pager
sudo grep -RnsE 'AutomaticLogin|TimedLogin|AutomaticLoginEnable' /etc/gdm3 2>/dev/null
~~~

If editing a real GNOME/GDM configuration, back up the specific file and use the section/syntax shown by the installed package. For current user gsettings keys, record original values first. **Do not restart gdm3 to test while unsaved work exists**: that will terminate GUI sessions.

**Verify:** Lock and unlock the actual authorized desktop account, confirm no unauthorized autologin, and test required remote access. **Undo:** Restore individual previous key/GUI value or GDM file from backup.

### 4.3 Prohibited packages, Flatpak and suspicious media

- [ ] Check the README's prohibited software list before removing packages or media.

~~~bash
dpkg -l | grep -Ei 'steam|transmission|qbittorrent|john|hydra|nmap|wireshark|vnc|telnet|netcat'
command -v flatpak
command -v snap
~~~

If Flatpak is present, run **flatpak list --app** separately; if Snap exists, inspect **snap list**. Network tools may be legitimate diagnostics, and a game may be README-required—name alone does not imply permission to delete.

**File search (read-only, scoped):**

~~~bash
sudo find /home /root /tmp /var/tmp -type f \( -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.torrent' \) -print 2>/dev/null
~~~

**Check before removing:** file ownership, hash, user, forensic question references, app dependencies and any required customer data. For a single confirmed prohibited APT package, simulate removal first:

~~~bash
apt -s purge example-package
~~~

Only then consider an authorized targeted removal. **Never run a pasted bulk apt purge list or wildcard rm**.

### 4.4 Cron, systemd timers, shell startup and backdoors

- [ ] Inspect scheduling and persistence before disabling anything.

~~~bash
sudo cat /etc/crontab
sudo ls -la /etc/cron.d /etc/cron.daily /etc/cron.hourly
sudo crontab -l
systemctl list-timers --all
systemctl list-unit-files --type=service --state=enabled
~~~

For one actual suspicious service:

~~~bash
systemctl cat example.service
systemctl show example.service -p FragmentPath -p ExecStart -p User
sudo journalctl -u example.service -n 50 --no-pager
~~~

**What to look for:** Newly created units, unexpected scripts from writable directories, unusual user login hooks, scheduled commands and unexpected listeners. These can be legitimate; record evidence and compare with README before changing. **Do not execute unknown scripts to test them.**

### 4.5 File ownership, SUID/capabilities and sensitive configuration

- [ ] Inspect permissions and owners on password-related files and writable directories.

~~~bash
stat -c '%A %a %U:%G %n' /etc/passwd /etc/group /etc/shadow /etc/gshadow
sudo find /usr/bin /usr/sbin /usr/local/bin -xdev -type f -perm /4000 -ls 2>/dev/null
sudo find /home /tmp /var/tmp -xdev -type f -perm /0002 -ls 2>/dev/null
~~~

**Interpretation:** /etc/shadow should not be readable by ordinary users, but exact Debian/Ubuntu mode/group may differ. SUID files such as passwd can be legitimate. **Do not chmod -R or chown -R system directories**. For an investigated file, use **dpkg -S /path**, stat and hash. Restore only verified incorrect mode/owner from a recorded baseline.

### 4.6 Package and service-specific verification

| Required service | Inspect | Safe configuration validation |
|---|---|---|
| SSH | systemctl status ssh | sudo /usr/sbin/sshd -t |
| Apache | systemctl status apache2 | sudo apache2ctl configtest |
| Nginx | systemctl status nginx | sudo nginx -t |
| MariaDB | systemctl status mariadb | SELECT VERSION() from authorized local client |
| PostgreSQL | pg_lsclusters | Check actual cluster and pg_hba.conf, test authorized connection |
| Samba | systemctl status smbd | testparm -s |
| BIND DNS | systemctl status named / bind9 | named-checkconf; test authoritative/recursive query |
| FTP (vsftpd) | systemctl status vsftpd | Review config and test required authorized FTP/TLS client |
| Postfix mail | systemctl status postfix | postfix check; test required mail flow |
| DHCP | Check installed isc-dhcp-server or Kea | Test client lease, relay and scope |

Commands depend on installed packages and actual service units. **Never install a server package merely because it appears in this table.**

**Safe editing pattern:** (1) record working client transaction, (2) find actual service and config, (3) back up exact file, (4) edit a single setting, (5) validate supported syntax, (6) reload if supported or schedule a controlled restart, (7) rerun client test and examine journal, (8) restore from backup on regression.

### 4.7 Journal and AppArmor

~~~bash
sudo journalctl -p warning -n 50 --no-pager
sudo journalctl -u ssh -n 50 --no-pager
command -v aa-status
sudo aa-status
~~~

Some Ubuntu installations use **journald** without a separate auth.log; rsyslog may also be installed. AppArmor modules/profiles vary; a DENIED message warrants targeted policy review, not disabling all confinement. Preserve evidence, disk space, and necessary service operation.


### Research report expansion U-R5 — AppArmor, security update timers and apt integrity

- [ ] Done

**Evidence:** Ubuntu vendor-backed LSM/update behavior and community practice. Missing tools are not automatically a scored issue.

**Typing (check):**

~~~bash
sudo aa-status
systemctl status apparmor --no-pager
sudo journalctl -k -n 80 --no-pager | grep -i apparmor
dpkg-query -W unattended-upgrades 2>/dev/null
systemctl status apt-daily-upgrade.timer --no-pager
apt-cache policy
apt-mark showhold
sudo dpkg --audit
~~~

**What to look for:** Unexpected AppArmor disabled status, suspicious manual complain-mode profiles, update timer intentionally disabled, untrusted APT sources/PPAs or held security packages. A missing audit rule/profile or timer may be deliberate; inspect the required setup.

**Typing (fix only if the installed AppArmor service is required and was disabled):**

~~~bash
sudo systemctl enable --now apparmor
~~~

If the actual image requires unattended-upgrades and the package is absent, after verifying signed sources:

~~~bash
sudo apt update
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
~~~

**Verification:** Repeat **aa-status**, confirm relevant profiles and required application behavior, inspect **/etc/apt/apt.conf.d/20auto-upgrades** and apt timer/log behavior. An active timer may have an inactive oneshot service between runs; that is normal.

**Undo:** Restore a specific AppArmor profile mode or APT configuration from its recorded baseline. Never disable AppArmor globally or delete system update logs to hide one DENIED message.

### Research report expansion U-R6 — Cron, systemd, shell startup, permissions and unwanted apps

- [ ] Done

**Evidence:** Shared community training topics, not verified secret scoring items.

**Typing (check):**

~~~bash
sudo cat /etc/crontab
sudo ls -la /etc/cron.d /etc/cron.daily /etc/cron.hourly
sudo crontab -l
systemctl list-timers --all
systemctl list-unit-files --type=service --state=enabled
sudo ss -lntup
~~~

~~~bash
stat -c '%A %a %U:%G %n' /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/sudoers
sudo find /etc /usr/local /opt -xdev -type f -perm /0002 -ls 2>/dev/null
sudo find /usr/local/bin /usr/local/sbin -type f \( -perm /4000 -o -perm /2000 \) -ls 2>/dev/null
cat /etc/hosts
~~~

**Unapproved app inventory:**

~~~bash
dpkg -l | grep -Ei 'nmap|netcat|wireshark|steam|transmission|qbittorrent|john|hydra'
command -v snap
~~~

Check **snap list** only if Snap exists; Ubuntu Firefox may be a Snap rather than a deb. Do not remove snapd or a required application based on another distribution's default.

**Fix:** Confirm the exact README prohibition and preserve evidence first. For one prohibited APT package, use **apt -s purge ACTUAL_PACKAGE** to preview dependencies; only then consider a targeted removal. For a verified malicious timer/cron job, disable or comment just the offending item after backing up its file.

**Verification:** Re-run individual searches, test authorized applications and service clients, confirm update state and scoring report.

**Undo:** Restore the old unit/cron line/hosts mapping, file mode, or original package and application configuration; never bulk-delete media files, services or all SUID bits.

### Research report expansion U-R7 — Critical-service recovery and scoring regression triage

- [ ] Done

**Evidence:** CyberPatriot required-service principle and standard systemd administration.

**Typing (check):**

~~~bash
systemctl list-units --type=service --state=running
systemctl --failed
sudo ss -lntup
sudo journalctl -p err -n 50 --no-pager
~~~

**Before acting:** Match actual unit names to the README and record original enabled/running status. Common required roles can include SSH, Apache/Nginx, MariaDB, PostgreSQL, Samba, DNS/BIND, DHCP and mail services.

**Fix ONLY when a service explicitly required by the README was accidentally disabled and its original state was enabled:**

~~~bash
sudo systemctl enable EXAMPLE_REQUIRED.service
sudo systemctl start EXAMPLE_REQUIRED.service
~~~

**Verification:**

~~~bash
systemctl is-enabled EXAMPLE_REQUIRED.service
systemctl is-active EXAMPLE_REQUIRED.service
sudo journalctl -u EXAMPLE_REQUIRED.service -n 50 --no-pager
~~~

Then test its real authorized client transaction (for example SSH login, HTTPS request, SMB share, DNS lookup or DB connection). A green systemctl status alone does not prove it fulfills its application task.

**Undo:** Return that specific unit to the recorded prior state when a change was incorrect, keeping the required service operational. Do not force every service Automatic or purge a server simply because a general checklist listed it as risky.

**Scoring drop:** Compare the **one most recent modification** against the previously working state, restore it if it broke a required service, repeat functionality tests, then refresh the official scoring report. Preserve scoring data rather than editing or deleting it.

**References:** [Ubuntu Security](https://documentation.ubuntu.com/security/), [Ubuntu Server docs](https://ubuntu.com/server/docs), [Ubuntu OpenSSH](https://documentation.ubuntu.com/server/how-to/security/openssh-server/).

## Part 5 — Advanced Networking and Policy

### 5.1 Netplan versus NetworkManager

- [ ] Before network configuration changes, identify which renderer actually owns the interface.

~~~bash
ip -br address
ip route
ls -la /etc/netplan
command -v netplan
networkctl status
nmcli general status
~~~

**Interpretation:** Ubuntu Server often uses **systemd-networkd via Netplan**; Ubuntu Desktop often uses **NetworkManager**. Either may differ. A correct YAML file is not proof its routing/DNS behavior works.

**GUI:** GNOME **Settings → Network** or **Wi-Fi**, when NetworkManager is installed. On server, inspect the real network YAML and interface name before changing it.

**Safe procedure:** Back up only the actual edited YAML file, preserve local console/recovery, verify indentation/schema, and use a controlled supported **netplan try** workflow when available rather than abruptly applying network changes over the only SSH session. Verify gateway, DNS lookup and required service clients before confirming. Never overwrite the whole YAML file from a generic sample.

### 5.2 Sysctl, kernel and networking controls

~~~bash
sysctl net.ipv4.ip_forward
sysctl net.ipv4.conf.all.accept_redirects
sysctl kernel.randomize_va_space
sudo grep -RnsE 'net.ipv4|net.ipv6|kernel.randomize_va_space' /etc/sysctl.conf /etc/sysctl.d 2>/dev/null
~~~

**Security notes:** A desktop generally doesn't need IP forwarding, but router/VPN/container/DHCP images may. Avoid blindly disabling IPv6 or forwarding to chase points. Back up the actual .conf file before adjusting one approved setting; check effective values and service reachability afterward.

### 5.3 Auditing, logs and account-lockout policy cautions

**Typing (check):**

~~~bash
systemctl status auditd rsyslog systemd-journald --no-pager
sudo grep -RnsE 'pam_faillock|pam_pwhistory|pam_pwquality|pam_unix' /etc/pam.d 2>/dev/null
sudo journalctl -b -p err --no-pager
~~~

**Why:** PAM changes are among the easiest ways to lose logins; audit configuration can fill disks or create excessive events if indiscriminately enabled. Use supported Ubuntu PAM profiles and record actual modules before adding or modifying a policy. Keep a working root/console recovery path. Audit event presence depends on enabled logging and retention.

### 5.4 Original Ubuntu-specific release and desktop reference

The following existing Ubuntu guidance is retained as a reference. **The full sections above govern the recommended order and safe workflow.** For conflicts, prefer installed-version documentation and the actual README, not a Mint-derived or older Ubuntu example.



### Differences from Linux Mint

#### Users: GNOME Settings instead of "Users and Groups"
- [ ] Done

**Settings → Users** → **Unlock**. Add or remove users, and toggle **Administrator**. The terminal commands are the same as Mint section 2.

#### Updates: "Software & Updates" instead of "Update Manager"
- [ ] Done

**Clicking:** open **Software & Updates** → **Updates** tab:
- **Subscribed to:** All updates
- **Automatically check for updates:** **Daily**
- **When there are security updates:** **Download and install automatically**

Then open **Software Updater** and install everything.

On the **Other Software** tab, untick any PPA the README doesn't need.

> [!NOTE]
> Ubuntu 24.04 keeps its sources in **`/etc/apt/sources.list.d/ubuntu.sources`** (a newer format with `URIs:` and `Suites:` lines) instead of `/etc/apt/sources.list`.

#### Firefox (and other apps) are "snaps"
- [ ] Done

On Ubuntu 22.04+, Firefox is a **snap** package, so `apt` doesn't update it:
```bash
snap list                       # every snap app
sudo snap refresh               # update all snaps (including Firefox)
sudo snap remove steam          # remove a prohibited snap app: change steam to the name from snap list
```

#### Firewall: UFW is installed but OFF
- [ ] Done

Use [the firewall ownership and recovery procedure](linux-mint.md#174-ufw-and-nftables-one-firewall-owner). If GUFW is already installed it provides a UFW GUI; it is not necessary to install it for manual terminal configuration.

#### Login screen: GDM instead of LightDM
- [ ] Done

**Settings → Users** → turn off **Automatic Login**. Or edit `/etc/gdm3/custom.conf` (Ubuntu's name for it), under `[daemon]`:
```
AutomaticLoginEnable=false
TimedLoginEnable=false
```
To inspect or change the login-screen user list, review `/etc/gdm3/greeter.dconf-defaults` and the version-specific procedure in [Debian step 8.3](debian.md#83-hide-the-list-of-users-on-the-login-screen).

#### Screen lock: GNOME settings
- [ ] Done

**Settings → Privacy (& Security) → Screen** (or **Screen Lock**): **Automatic Screen Lock: On**, **Blank Screen Delay: 5 minutes**.
```bash
gsettings get org.gnome.desktop.screensaver lock-enabled      # true
```

#### Remote access: GNOME "Sharing"
- [ ] Done

**Settings → Sharing** (24.04: **Settings → System → Remote Desktop / Secure Shell**). Turn off **Screen Sharing / Remote Desktop**, **Remote Login** (SSH), and **Media Sharing** unless the README needs them.

#### SSH on Ubuntu 22.10 and newer
- [ ] Done

SSH may be started **on demand** by `ssh.socket`. To turn it off completely:
```bash
sudo systemctl disable --now ssh.socket ssh.service
systemctl is-enabled ssh.socket ssh.service      # both should say "disabled"
```
If the README needs SSH and you change `Port` or `ListenAddress` in `sshd_config`, the socket decides the port, so also run `sudo systemctl daemon-reload && sudo systemctl restart ssh.socket`.

#### Ubuntu 20.04: inspect available PAM modules
- [ ] Done

Inspect installed PAM modules and use [the supported PAM procedure](linux-mint.md#172-password-aging-pam-and-lockout-without-breaking-login); do not select pam_tally2 solely because the image is Ubuntu 20.04.

#### Default games and apps
- [ ] Done

A normal Ubuntu desktop install includes **AisleRiot Solitaire, Mahjongg, Mines, Sudoku** and **Transmission** (torrents). Remove them unless the README needs them:
```bash
sudo apt purge aisleriot gnome-mahjongg gnome-mines gnome-sudoku transmission-gtk transmission-common
```

### Ubuntu manual baseline and release differences

#### U.1 Establish release, desktop and authentication recovery

- [ ] Done

**What:** Identify Ubuntu's release and installed desktop before following shared Linux procedures.

**Why it matters:** Ubuntu 20.04, 22.04 and 24.04 differ in support, configuration defaults and service activation. Mint's Cinnamon paths do not configure GNOME.

**Before changing anything:** Read the README, answer forensics and keep console access. Use [Mint 17.1–17.2](linux-mint.md#17-detailed-manual-safety-and-verification-procedures) for the complete account backup, sudo and PAM recovery steps; those APT/PAM concepts apply here, but inspect installed module versions first.

**Clicking (GUI):** **Settings → About** identifies the OS. **Settings → Users → Unlock** shows human users and account types. Open **Activities**, search **Terminal**, and launch it. `Ctrl+Alt+T` usually opens Terminal.

**Typing (check):**

```bash
cat /etc/os-release
systemctl status display-manager --no-pager
id
sudo -v
```

Expected: the actual release codename/version, the display-manager unit, your user/group list, and successful sudo validation. A server image may have no display manager.

**Typing (fix, only when appropriate):** Reconcile users and privileges through the GUI or shared 17.1 procedure. Apply password expiration individually with `sudo chage`, not by assuming edits to login.defs updated existing users. Keep a separate root console during PAM changes.

**Check it worked:** Test a new ordinary-user login and an authorized sudo session. Confirm no required service identity was removed.

**Undo:** Restore the recorded membership/account state and modified PAM files using the recovery console, as described in the linked procedure.

**Warnings:** Do not install Cinnamon tools to make a Mint screenshot match. Ubuntu 20.04 standard maintenance has ended; expanded support depends on its support arrangement. Do not perform a major release upgrade during a round.

#### U.2 APT sources and supported security updates

- [ ] Done

**What:** Inspect repositories in their actual format and install supported updates.

**Why it matters:** Ubuntu 24.04 commonly uses `/etc/apt/sources.list.d/ubuntu.sources` (DEB822); older images commonly use `/etc/apt/sources.list`. Replacing either with an old internet list can mix releases.

**Before changing anything:** Back up `/etc/apt` following [Mint 17.5](linux-mint.md#175-package-sources-updates-and-vulnerability-triage). Record required applications and existing third-party sources.

**Clicking (GUI):** **Software & Updates → Ubuntu Software / Other Software**; compare enabled sources with the installed release. **Software Updater** checks and installs updates. Do not enable a PPA merely because it promises a newer version.

**Typing (check):**

```bash
apt-cache policy
sudo grep -RHE '^(deb |Types:|URIs:|Suites:|Signed-By:)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
```

`Suites` must match the installed codename and its legitimate updates/security pockets. Signing keys should be repository-scoped.

**Typing (fix, only when appropriate):** Correct the specific unauthorized/mismatched entry through the GUI or `sudo nano` on that source file. Then:

```bash
sudo apt update
```

Continue only after reviewing all errors:

```bash
apt -s upgrade
```

If the preview preserves the required software:

```bash
sudo apt upgrade
```

**Check it worked:** `sudo dpkg --audit`, `apt list --upgradable`, and the Updater should agree about incomplete/pending work. Open the required applications. Check whether a restart is requested with `test -f /var/run/reboot-required && cat /var/run/reboot-required`.

**Undo:** Restore only the source file changed and refresh metadata. A package update needs its own supported rollback; the source backup does not undo installed versions.

**Warnings:** Do not use `--allow-unauthenticated`, disable TLS validation or switch suites to bypass an error. Check the actual source, network and release support first.

#### U.3 SSH socket activation on newer Ubuntu

- [ ] Done

**What:** Inspect both SSH daemon configuration and the systemd socket that may own the listening port.

**Why it matters:** On newer Ubuntu installations, stopping `ssh.service` may leave `ssh.socket` able to start it again. Socket behavior varies with packaging and upgrades.

**Before changing anything:** Preserve `/etc/ssh` and any `/etc/systemd/system/ssh.socket.d` overrides. Keep the console and one existing connection open. Use [Mint 17.3](linux-mint.md#173-ssh-effective-configuration-and-a-second-session-test) for the full authentication procedure.

**Clicking (GUI):** Use the VM console. GNOME remote desktop settings do not control OpenSSH.

**Typing (check):**

```bash
systemctl status ssh.service ssh.socket --no-pager
systemctl cat ssh.socket
systemctl show ssh.socket -p Listen -p FragmentPath -p DropInPaths
sudo /usr/sbin/sshd -T | grep -E '^(port|listenaddress) '
sudo ss -ltnp
```

A running socket unit may be the listener even while the daemon is idle. Inspect drop-ins and generated configuration; do not assume every 22.04 image uses socket activation.

**Typing (fix, only when appropriate):** For required SSH edit and validate the actual sshd config as in 17.3. If changing only authentication, reload the running daemon. If changing the socket's port/address, review the installed Ubuntu OpenSSH packaging instructions and actual unit drop-ins, then from the console:

```bash
sudo /usr/sbin/sshd -t
```

After success, when the observed setup uses a socket:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ssh.socket
sudo systemctl restart ssh.service
```

Changing/restarting listeners can interrupt access. Add the new required firewall allowance before testing. If SSH is confirmed unnecessary, disable both activation paths individually:

```bash
sudo systemctl disable --now ssh.socket
sudo systemctl disable --now ssh.service
```

A missing socket unit is normal on some installations; do not install one merely for consistency.

**Check it worked:** Compare `ss`, `systemctl show ssh.socket -p Listen` and `sshd -T`; test a **new** authorized SSH connection to the actual port. If disabled, no SSH listener should remain unless another instance exists; investigate its PID instead of killing it blindly.

**Undo:** Restore the exact changed config/override, remove only new overrides, validate, daemon-reload and restore the original unit enabled/running states. Re-test from a second client.

**Warnings:** An existing SSH session is not a test of a new listener. Do not restart networking to repair a socket configuration error.

#### U.4 GNOME desktop, firewall and services

- [ ] Done

**What:** Configure the actual desktop user's screen lock and complete the shared Linux service checks.

**Why it matters:** `sudo gsettings` targets the wrong user; a secure desktop does not compensate for an open server.

**Before changing anything:** Record the user's current values and inspect installed schemas. Use [Mint 17.4–17.9](linux-mint.md#174-ufw-and-nftables-one-firewall-owner) for firewall, package, permissions, persistence, kernel/AppArmor, log and recovery procedures, and [service hardening](linux-mint.md#20-complete-linux-critical-service-hardening-procedures-embedded) for each installed required daemon.

**Clicking (GUI):** **Settings → Privacy → Screen Lock** on older GNOME, or **Privacy & Security → Screen Lock** on newer versions. Enable automatic locking and require a password; disable automatic login in **Users** if unauthorized. **Files → Preferences** contains removable-media behavior on some releases; other versions use **Settings → Removable Media**.

**Typing (check):** In the logged-in desktop user's terminal, without sudo:

```bash
gsettings get org.gnome.desktop.session idle-delay
gsettings get org.gnome.desktop.screensaver lock-enabled
gsettings get org.gnome.desktop.screensaver lock-delay
```

**Typing (fix, only when appropriate):** If these schemas/keys exist and the README permits:

```bash
gsettings set org.gnome.desktop.session idle-delay 300
gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.screensaver lock-delay 0
```

**Check it worked:** Query the same keys, lock/unlock as that user, then test authorized service transactions. On Ubuntu Server skip desktop settings and inspect server roles instead.

**Undo:** Restore each recorded key value or original GUI value. If a key is not writable, inspect organizational dconf policy instead of overriding it by force.

**Warnings:** Do not restart GDM to test settings while work is unsaved. Do not remove required DNS/SSH/database/web services simply because the image is called a workstation.


## Part 6 — Final Verification

- [ ] Every forensic question has an evidence-supported answer and was saved in the required format.
- [ ] Authorized users and sudo privileges match the image README; a second authorized login works.
- [ ] Password aging/PAM changes (if any) have been tested without locking out users.
- [ ] Firewall/UFW/native rules permit every required inbound service, no more than needed.
- [ ] APT and Snap updates are checked and packages come from legitimate signed sources.
- [ ] Firefox/required browsers, GNOME lock, login screen and remote access match the scenario.
- [ ] SSH, database, web, DNS, DHCP, Samba, FTP/mail and other explicitly required services work from authorized clients.
- [ ] Suspicious cron, systemd, file permissions, new services, prohibited packages and media were reviewed without evidence destruction.
- [ ] Logs and AppArmor state are understood; no unrelated broad scripts or destructive commands were run.
- [ ] Changes are recorded with old state, final state, verification and a specific rollback plan.
- [ ] Final score refreshed; no unexpected reboot or last-minute mass cleanup.

**Typing (final read-only checks):**

~~~bash
cat /etc/os-release
id
sudo visudo -c
sudo dpkg --audit
apt list --upgradable 2>/dev/null
systemctl --failed
sudo ss -lntup
sudo journalctl -p err -n 30 --no-pager
~~~

**If something fails:** Investigate the last specific changed file, unit, group or firewall rule, restore it from the recorded baseline, verify required access and rerun the same inspection. A stable working system and saved forensics evidence are more important than speculative last-minute changes.

## Sources and additional topic inventories

- [Official CyberPatriot XIX rounds and images](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round)
- [Ubuntu documentation](https://documentation.ubuntu.com/)
- [Ubuntu security: firewall, ports, hardening](https://documentation.ubuntu.com/security/)
- [Ubuntu Server documentation](https://ubuntu.com/server/docs)
- [Microsoft and Linux checklists in Ripper1004 CyberPatriot Toolkit](https://github.com/Ripper1004/CyberPatriot-Toolkit/tree/main/docs)
- [Minagera CyberPatriot Linux checklist](https://github.com/Minagera/CyberPatriot/blob/main/CyberPatriot/Checklists/Linux/README.md)
- [chessischess CyberPatriot Linux checklist](https://github.com/chessischess/cyberpatriot-checklist)
- [Original Ubuntu-specific reference](https://github.com/Ripper1004/CyberPatriot-Toolkit/blob/main/docs/checklists/ubuntu.md)

**Scope:** All examples are for authorized defensive administration. This guide does **not** reproduce proprietary scoring keys or promise particular point values; exact competition rules and the image README take priority.
