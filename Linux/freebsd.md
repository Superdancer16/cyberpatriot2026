# FreeBSD checklist (13 / 14)

FreeBSD may appear in the **Semifinals** (depending on tier). It's a Unix like Linux, but **many commands and file locations are different**. Use this translation table whenever you get stuck.

## FreeBSD vs. Linux, the quick translation

| Task | Linux | FreeBSD |
|---|---|---|
| Become root | `sudo -i` | `su -` (you must be in the **wheel** group), then type `sh` |
| Admin group | `sudo` | `wheel` |
| Add / delete user | `adduser` / `userdel` | `adduser` (interactive) or `pw useradd` / `pw userdel` |
| User info | `/etc/shadow` | `/etc/master.passwd` (edit with `vipw`, never directly) |
| Install / remove software | `apt install` / `apt purge` | `pkg install` / `pkg delete` |
| Update packages | `apt upgrade` | `pkg upgrade` |
| Update the OS | (part of apt) | `freebsd-update fetch install` |
| Services | `systemctl` | `service <name> start/stop` and `sysrc <name>_enable=YES/NO` |
| Start-up settings | systemd units | `/etc/rc.conf` (change with `sysrc`) |
| Firewall | `ufw` | `pf` (`/etc/pf.conf`) or `ipfw` |
| Kernel settings | `/etc/sysctl.conf` | `/etc/sysctl.conf` (different names) |
| Listening ports | `ss -tulpn` | `sockstat -4 -6 -l` |
| Logs | `/var/log/auth.log`, `journalctl` | `/var/log/auth.log`, `/var/log/messages`, `/var/log/security` |
| Simple editor | `nano` | `ee` (Easy Editor; **Esc** opens the menu) |
| Cron jobs | `/var/spool/cron/crontabs/` | `/var/cron/tabs/` |
| Is a file from a package? | `dpkg -S file` | `pkg which file` |
| Home folders | `/home` | `/home` (on FreeBSD 13 it is a link to `/usr/home`) |

> [!TIP]
> Follow these procedures manually. [Step 0.1](#01-fast-path-run-the-hardening-script) now explains preparation and verification; no automation is included.

> [!IMPORTANT]
> The commands on this page are written for the `sh` shell. On **FreeBSD 13** (and on a 14 that was upgraded from 13) root's shell is `csh`, which reads them differently (for example `2>/dev/null` hides the results instead of the errors). After `su -`, always type `sh` and press Enter; it does no harm if you were already in `sh`.

---

## 0. Before you start

- [ ] Read the README; write down admins, users, critical services.
- [ ] Take a VMware snapshot.
- [ ] Become root: `su -` (or `sudo -i` / `doas -s` if those are installed), then type `sh` (see the box above).
- [ ] Answer the forensics questions ([guide](../General/All/forensics-questions.md)). `sha256 file` hashes a file on FreeBSD (`sha256sum` may not exist).

### 0.1 Fast path: run the hardening script
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

## 1. Users and groups

### 1.1 List users
- [ ] Done

```bash
awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd
```

### 1.2 Delete unauthorized users, add missing ones
- [ ] Done

```bash
pw userdel mallory              # add -r to also delete their home folder
adduser                         # interactive: asks for name, shell, password...
pw useradd erin -m -s /bin/sh   # or without questions: creates erin with a home folder...
passwd erin                     # ...then give erin a password
```

### 1.3 Admins = the `wheel` group
- [ ] Done

```bash
pw groupshow wheel
pw groupmod wheel -d bob        # remove bob
pw groupmod wheel -m alice      # add alice
grep pam_group /etc/pam.d/su    # must NOT start with #: only wheel members may use su
```
If the `pam_group` line starts with `#`, anyone who learns the root password can use `su`. Open the file with `ee /etc/pam.d/su` and delete the `#` (the line is `auth requisite pam_group.so no_warn group=wheel root_only fail_safe ruser`).
If `sudo` or `doas` is installed, also check their rules (section 7).

### 1.4 Hidden root accounts
- [ ] Done

```bash
awk -F: '$3 == 0 {print $1, $2}' /etc/master.passwd
```
FreeBSD normally has **`root`** and **`toor`** with UID 0. `toor` is fine **only if** its password field is `*` or starts with `*LOCKED*` (that is what `pw lock` adds). If `toor` has a real password, remove it:
```bash
pw usermod toor -h -            # sets toor's password field to * (no password login)
pw userdel mallory              # any OTHER UID-0 account is a backdoor: delete it (no -r: its home may be /root)
```

### 1.5 Empty passwords and weak passwords
- [ ] Done

```bash
awk -F: '$2 == "" {print $1}' /etc/master.passwd     # accounts with NO password
passwd bob                                           # set a strong password
pw lock mallory                                      # or lock an account nobody should log in to
```

> [!CAUTION]
> If **`root`** is on the empty-password list, give it a password with `passwd root`. **Never lock root**: you would lose `su -`. Keep a tested root/sudo/doas recovery path before any authentication change.

### 1.6 System accounts that can log in
- [ ] Done

**What:** System accounts (UID below 1000, like `daemon`, `www`, `games`) never log in, so their shell is `/usr/sbin/nologin`. An attacker who gives one a real shell (and a password) has a hidden login.
```bash
awk -F: '$3 < 1000 && $7 != "/usr/sbin/nologin" {print $1, $3, $7}' /etc/passwd
pw usermod mallory -s /usr/sbin/nologin    # mallory = the account you found
```
Normal output: `root`, `toor` (empty shell) and `uucp` (its own `uucico` program), plus accounts that a README service's package made (for example `postgres`). Anything else with `/bin/sh`, `/bin/csh` or `/usr/local/bin/bash` is suspicious, and so is an account name you don't recognize.

---

## 2. Password policy

### 2.1 Strong hashing and password expiry (`/etc/login.conf`)
- [ ] Done

```bash
ee /etc/login.conf
```
In the **`default:`** block, make sure these lines exist:
```
	:passwd_format=sha512:\
	:passwordtime=90d:\
```
Every line in the block except the last ends with `\`. Then **rebuild the database** (required!):
```bash
cap_mkdb /etc/login.conf
```
Both settings only apply to passwords set **after** this: if you already changed passwords in 1.5, set them again (`passwd bob`). `minpasswordlen` and `mixpasswordcase` in `login.conf` do nothing on FreeBSD (the manual lists them as "not implemented"); password length is set in 2.2.

### 2.2 Password complexity (`pam_passwdqc`)
- [ ] Done

```bash
ee /etc/pam.d/passwd
```
Make sure this line is active (no `#` in front) and comes **before** the `pam_unix.so` line:
```
password	requisite	pam_passwdqc.so	min=disabled,disabled,disabled,12,12 similar=deny retry=3 enforce=users
```
This asks for 12+ characters using at least three kinds (lower case, upper case, digits, symbols). `enforce=users` does not check root, so test it as a normal user: `su - bob`, then `passwd` (it asks for bob's current password first), try a weak password (it must be refused), then `exit`.

---

## 3. Firewall (pf)

### 3.1 Write a pf ruleset
- [ ] Done

```bash
ee /etc/pf.conf
```
```
set skip on lo0
block in log all
pass out all keep state
pass in inet proto icmp icmp-type { echoreq, unreach }
anchor "blacklistd/*" in                         # lets blacklistd (step 5.1) block password guessers
pass in proto tcp to port { 22 } keep state      # ONLY the README's critical ports (22=SSH, 80/443=web, 21=FTP...)
```
If the README lists no network services, delete the last line (an empty `{ }` is an error).
Check it, then turn it on:
```bash
pfctl -nf /etc/pf.conf          # check for mistakes (no output = OK)
sysrc pf_enable=YES pflog_enable=YES
service pf start                # or: pfctl -f /etc/pf.conf -e
pfctl -sr                       # show the rules in use
```
**Check it worked:** `pfctl -s info | head -1` says `Status: Enabled`.

FreeBSD has a second firewall, `ipfw`. If `sysrc -n firewall_enable` says `YES`, the image also uses it (inspect both policies before changing either). `sysrc firewall_type firewall_myservices` shows how it is set up; `open` lets everything in. To make it block too, use the `workstation` type and list only the README's ports:
```bash
sysrc firewall_type=workstation firewall_myservices="22/tcp" firewall_allowservices=any   # 22/tcp = SSH: list only the README's ports
service ipfw restart
ipfw list                       # the rules now in use
```

---

## 4. Services

### 4.1 See what starts at boot
- [ ] Done

```bash
service -e                      # every enabled service
sysrc -a | grep enable          # every *_enable setting
sockstat -4 -6 -l               # what's listening
```

### 4.2 Turn off what the README doesn't need
- [ ] Done

```bash
sysrc ftpd_enable=NO    ; service ftpd onestop
sysrc inetd_enable=NO   ; service inetd onestop       # inetd starts telnet, ftp, tftp...
sysrc nfs_server_enable=NO rpcbind_enable=NO           # NFS file sharing (only if the README doesn't need it)
service nfsd onestop ; service mountd onestop ; service rpcbind onestop
```
Do the same for anything else in the 4.1 lists that the README doesn't need, for example `sysrc apache24_enable=NO ; service apache24 onestop`. The `sysrc` name is the one from `sysrc -a`; the `service` name is the last part of the `service -e` path (e.g. `nginx`, `mysql-server`, `samba_server`).
Also check `/etc/inetd.conf`: any line without `#` starts a service (telnet, ftp...). Comment them out. (There is no `telnetd_enable`: the telnet server runs through inetd, and FreeBSD 14 only has it as a package, `freebsd-telnetd`.)

### 4.3 Safer defaults in `/etc/rc.conf`
- [ ] Done

```bash
sysrc sendmail_enable=NONE      # no mail server (unless the README needs mail)
sysrc syslogd_flags="-ss"       # logging doesn't listen on the network
sysrc clear_tmp_enable=YES      # empty /tmp at every boot
sysrc dumpdev=NO                # no crash dumps (they contain memory, i.e. passwords)
```
**Check it worked:** `sysrc sendmail_enable syslogd_flags clear_tmp_enable dumpdev` shows `NONE`, `-ss`, `YES`, `NO`. These take effect at the next boot; `service syslogd restart` applies the syslogd one now (restart it manually only after reviewing the configuration).

---

## 5. SSH

### 5.1 Secure sshd_config
- [ ] Done

Only if SSH is critical; otherwise `sysrc sshd_enable=NO; service sshd stop`.
```bash
ee /etc/ssh/sshd_config
```
Same settings as the [Linux Mint SSH table](linux-mint.md#92-needed-make-it-safe), plus `UseBlacklist yes`. Then:
```bash
sshd -t && service sshd reload
sysrc blacklistd_enable=YES && service blacklistd start      # blocks password guessing
```
blacklistd blocks through pf, so it only works if `/etc/pf.conf` has the `anchor "blacklistd/*" in` line from 3.1. Inspect the existing policy and daemon integration; validate with `pfctl -nf /etc/pf.conf` before loading changes. An anchor alone is not complete blacklist protection.

---

## 6. Software and updates

### 6.1 Remove prohibited packages
- [ ] Done

```bash
pkg info                        # everything installed
pkg info | grep -Ei 'nmap|john|hydra|wireshark|aircrack|hashcat|nikto|sqlmap|ettercap|netcat|minetest|supertux|transmission|qbittorrent|x11vnc'
pkg delete -y nmap
pkg autoremove -y
```
> [!NOTE]
> `/usr/bin/nc` (netcat) is **part of FreeBSD itself** and can't be removed. Look for it in cron jobs and running processes instead.

### 6.2 Known security holes
- [ ] Done

```bash
pkg audit -F                    # lists installed packages with known vulnerabilities
```

### 6.3 Updates
- [ ] Done

```bash
pkg lock -l                     # locked packages are never upgraded
pkg unlock -y openssl           # only if the list shows one: unlock it (use the name from the list)
freebsd-update fetch install    # OS updates (press q if a list appears)
pkg update && pkg upgrade -y    # package updates
freebsd-version -kr             # installed kernel, then running kernel
```
If those two lines differ, reboot so the new kernel runs. If `pkg update` fails, look for a fake repository in `/etc/pkg/FreeBSD.conf` and `/usr/local/etc/pkg/repos/`.

Then turn on the nightly update check (it downloads updates and mails root, but never installs them by itself):
```bash
grep freebsd-update /etc/crontab
echo '0 3 * * * root /usr/sbin/freebsd-update cron' >> /etc/crontab   # only if the grep showed nothing
```

### 6.4 Media files
- [ ] Done

```bash
find /home /usr/home /root /tmp -type f \( -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.wav' -o -iname '*.flac' \)
```

---

## 7. sudo / doas rules

### 7.1 No password-less root
- [ ] Done

```bash
cat /usr/local/etc/sudoers /usr/local/etc/sudoers.d/* 2>/dev/null   # edit with: visudo
cat /usr/local/etc/doas.conf 2>/dev/null
```
Remove `NOPASSWD` (sudo) and `nopass` (doas). Only the README admins (or `%wheel`) should have rules.

---

## 8. Kernel security settings

### 8.1 /etc/sysctl.conf
- [ ] Done

Open the file with `ee /etc/sysctl.conf` and make sure it has these lines (change a line that already sets the same name instead of adding a second one):
```
security.bsd.see_other_uids=0
security.bsd.see_other_gids=0
security.bsd.see_jail_proc=0
security.bsd.unprivileged_read_msgbuf=0
security.bsd.unprivileged_proc_debug=0
security.bsd.hardlink_check_uid=1
security.bsd.hardlink_check_gid=1
kern.randompid=1
net.inet.tcp.blackhole=2
net.inet.udp.blackhole=1
net.inet.ip.random_id=1
net.inet.icmp.drop_redirect=1
net.inet.ip.redirect=0
net.inet.ip.sourceroute=0
net.inet.ip.accept_sourceroute=0
net.inet.tcp.drop_synfin=1
net.inet.ip.forwarding=0
net.inet6.ip6.redirect=0
kern.elf64.aslr.enable=1
```
Apply right away: `service sysctl restart`. `see_other_uids=0` means users can't see each other's processes.

**Check it worked:** `sysctl security.bsd.see_other_uids net.inet.tcp.blackhole` shows `0` and `2`.

### 8.2 Ask for the root password in single-user mode
- [ ] Done

**What:** Anyone at the keyboard can reboot into single-user mode and get a root shell **without a password** unless the `console` line in `/etc/ttys` says `insecure`. This is the "Enable console password prompt" choice of the FreeBSD installer's hardening menu.
```bash
grep '^console' /etc/ttys                     # default: console none unknown off secure
sed -i '' '/^console/s/off secure/off insecure/' /etc/ttys
grep '^console' /etc/ttys                     # now ends in: off insecure
```
Change **only** the `console` line. Making the `ttyv` lines insecure stops root from logging in at the screen.

While you are at boot settings, the installer's other hardening choice is "Disallow DTrace destructive-mode". It goes in `/boot/loader.conf` and works after a reboot:
```bash
grep -q allow_destructive_dtrace /boot/loader.conf || echo 'security.bsd.allow_destructive_dtrace=0' >> /boot/loader.conf
```

### 8.3 Kernel securelevel (optional, do it LAST)
- [ ] Done

**What:** At securelevel 1 nobody, not even root, can load kernel modules, remove the "system immutable" file flag or write to raw memory and mounted disks. It only takes effect at the next boot.
```bash
sysrc kern_securelevel_enable=YES kern_securelevel=1
```
**Check it worked (after a reboot):** `sysctl kern.securelevel` shows `1`.

> [!CAUTION]
> Once it is on, `freebsd-update install` refuses to run ("Updates cannot be installed when the system securelevel is greater than zero"), and the level can't be lowered without setting `kern_securelevel_enable=NO` and rebooting. Do it only after all updates (6.3) are done, and only if the README doesn't say you need to load kernel modules or install updates later.

---

## 9. Permissions

### 9.1 Important files and SUID programs
- [ ] Done

```bash
ls -l /etc/master.passwd /etc/spwd.db      # must be -rw------- root wheel
chmod 600 /etc/master.passwd
find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null   # SUID/SGID programs (no -xdev: /home is often a separate ZFS file system)
chmod u-s,g-s /usr/bin/find                    # if find/vi/sh/python etc. are SUID or SGID
ls -ld /home/*                                 # home folders: no access for others (drwx------ or drwxr-x---)
chmod 700 /home/bob                            # fix one that is open to everyone
```

---

## 10. Backdoors

### 10.1 Cron, start-up scripts, shell files, keys, hosts
- [ ] Done

```bash
ls -la /var/cron/tabs/ ; grep -Hv '^#' /var/cron/tabs/* 2>/dev/null   # every user's cron jobs (file name = user)
cat /etc/crontab
cat /etc/rc.local /etc/rc.conf.local 2>/dev/null
ls /etc/cron.d /usr/local/etc/cron.d /var/at/jobs 2>/dev/null   # more cron files and "at" jobs
cat /etc/periodic.conf /etc/daily.local 2>/dev/null ; ls /usr/local/etc/periodic/*/ 2>/dev/null   # periodic jobs run daily as root (look for *_local= or odd scripts)
ls /usr/local/etc/rc.d/ ; for f in /usr/local/etc/rc.d/*; do pkg which -q "$f" >/dev/null || echo "NOT FROM A PACKAGE: $f"; done
grep -n alias /root/.cshrc /root/.shrc /home/*/.shrc /home/*/.cshrc 2>/dev/null
find / -name authorized_keys 2>/dev/null
cat /etc/hosts
sockstat -4 -6 -l
kldstat                          # loaded kernel modules
grep _load /boot/loader.conf     # modules loaded at boot
```
FreeBSD's own `.cshrc`/`.shrc` have harmless aliases like `h`, `j`, `la`, `lf`, `ll`. An alias that changes `su`, `sudo`, `ls`, `ps` or `passwd` is a trap.

### 10.2 Tampered system files
- [ ] Done

```bash
freebsd-update IDS | less        # lists system files that differ from the official release
```
(Changed config files in `/etc` are normal; changed programs in `/bin`, `/sbin`, `/usr/bin` are **not**.)

---

## 11. Logging

### 11.1 Security auditing on
- [ ] Done

```bash
sysrc auditd_enable=YES && service auditd start
grep ^flags /etc/security/audit_control       # e.g. flags:lo,aa,ad
```
**Check it worked:** `service auditd status` says it is running (if it was already running before the flags changed, `audit -s` reloads them; run it yourself after reviewing the change), and `praudit /var/audit/current | tail` shows recent events (logins, `su`).

---

## 12. Final checks
- [ ] Critical services still running (`service <name> status`)
- [ ] `pfctl -s info` → Status: Enabled
- [ ] You can still `su -`
- [ ] Scoring Report: no penalties

## 13. FreeBSD-specific recovery and service workflow

The commands below use a **root console running `sh`**, even though fences use `bash` for consistent highlighting. They do not require installing Bash. Enter `su -` and supply the root password interactively, then enter `sh`. Do not use Linux `apt`, `systemctl`, UFW, AppArmor or `/etc/shadow` recipes on FreeBSD.

### 13.1 Account, wheel and PAM recovery

- [ ] Done

**What:** Preserve usable administration and inspect FreeBSD account policy.

**Why it matters:** `wheel` controls root escalation through the configured `su` PAM policy; membership alone does not grant passwordless sudo. FreeBSD account data includes database files rebuilt by its native tools.

**Before changing anything:** Keep one root console open. Save private copies:

```bash
install -d -m 700 /root/cp-backups
cp -p /etc/master.passwd /etc/group /etc/login.conf /root/cp-backups/
cp -Rp /etc/pam.d /root/cp-backups/pam.d.before-cp
```

Do not expose `/etc/master.passwd`, which contains password hashes. Use unique backup paths when repeating.

**Clicking (GUI):** A base FreeBSD installation has no standard graphical account control panel. Use the VM console and `ee` text editor. In `ee`, press **Esc** for its menu and follow the save/exit prompts.

**Typing (check):**

```bash
id
pw usershow bob
pw groupshow wheel
pw usershow -a | awk -F: '$3 == 0 { print $1, $3, $6, $7 }'
pw usershow bob -P
```

The last command pretty-prints account details, not a plaintext password. Root and the traditional `toor` alternative may exist; investigate enabled credentials and shells rather than deleting every extra UID-0 entry blindly. Inspect `/etc/pam.d/su` and installed sudo/doas rules if used.

**Typing (fix, only when appropriate):** For an authorized administrator:

```bash
pw groupmod wheel -m bob
```

For a confirmed unauthorized member:

```bash
pw groupmod wheel -d mallory
```

For confirmed unauthorized account containment, after forensics:

```bash
pw lock mallory
```

This locks the password; inspect SSH keys and active sessions too. Use `vipw` for account-file edits; never edit master.passwd with a generic editor or restore it by ordinary copying while expecting databases to update automatically.

**Check it worked:** New login as the intended ordinary user, `id`, and a permitted `su -` with root's password. Root's own `su - bob` does not validate Bob's password. Test existing sudo/doas authorization separately if installed.

**Undo:** Restore recorded wheel membership with `pw groupmod`, and `pw unlock mallory` only if it was originally unlocked. Recover account entries with `vipw`/supported account tools and their database rebuilding, coordinating any changes made since backup. Do not blindly overwrite account databases.

**Warnings:** Do not lock root while `su` is your only administrator path. Service accounts and the base `toor` entry need context. Never log password hashes or use a shared example password.

### 13.2 Login classes, password quality and aging

- [ ] Done

**What:** Apply FreeBSD login class capabilities and PAM password quality carefully.

**Why it matters:** `/etc/login.conf` syntax uses colon-delimited capabilities and line continuations; an invalid file or PAM line can break password changes. An expired credential is distinct from a locked account.

**Before changing anything:** Back up `/etc/login.conf`, its database if present, and `/etc/pam.d/passwd`. Keep a root console. Record the user's class and expiration with `pw usershow bob -P`.

**Clicking (GUI):** No standard base GUI exists; use `ee /etc/login.conf` and inspect the account's class with native tools.

**Typing (check):**

```bash
grep -nE 'passwd_format|passwordtime|default:' /etc/login.conf
cat /etc/pam.d/passwd
man login.conf
man pam_passwdqc
```

Read the installed release's manual. Do not assume Linux pwquality options work with FreeBSD passwdqc or force an older hashing algorithm over a supported stronger default.

**Typing (fix, only when appropriate):** In the applicable class, preserve the stanza and inspect `passwordtime=90d` only if 90-day expiration is required. Keep supported hashing defaults unless the README or current release guidance requires a change. Rebuild after editing:

```bash
cap_mkdb /etc/login.conf
```

Use section 2.2's `pam_passwdqc` line only when that module is available and the actual stack has the expected order. For an existing user's explicit password expiry, consult `man pw` and use the scenario's recorded date; changing a login class does not retroactively prove all old passwords comply.

**Check it worked:** As an ordinary authorized user in a separate session run `passwd`, confirm rejection of a deliberately weak test password, then choose a unique strong password. Verify a fresh login succeeds and inspect the user's resulting expiry. Do not test on root first.

**Undo:** Restore the changed PAM file and login.conf from private backup, run `cap_mkdb /etc/login.conf` again, and restore the user's recorded expiry with the native account tool. Test before closing root.

**Warnings:** Never append Linux pam_faillock or pam_pwhistory recipes into FreeBSD's stack without explicit release support and correct policy integration. Do not repeatedly fail the only administrator login to test lockout.

### 13.3 pf with console recovery and required client tests

- [ ] Done

**What:** Validate and load the existing packet-filter policy without discarding required traffic.

**Why it matters:** A syntactically valid ruleset can still lock out administrators or block DHCP, DNS and IPv6 neighbor discovery. FreeBSD pf differs from current OpenBSD pf.

**Before changing anything:** Use the local VM console, identify interfaces and active firewall ownership. Do not run pf and ipfw concurrently merely because both are available.

**Clicking (GUI):** There is no standard pf GUI on base FreeBSD. Keep the VM console visible while a second authorized machine tests access.

**Typing (check and backup):**

```bash
ifconfig
route -n get default
sysrc pf_enable firewall_enable
pfctl -s info
pfctl -sr
cp -p /etc/rc.conf /root/cp-backups/rc.conf.before-pf
```

If `/etc/pf.conf` exists:

```bash
cp -p /etc/pf.conf /root/cp-backups/pf.conf.before-cp
```

A disabled filter or missing config requires deliberate planning, not blind replacement. Record whether it was enabled and save existing rules privately.

**Typing (fix, only when appropriate):** `ee /etc/pf.conf`; preserve the existing policy and add only required source-scoped service allowances. For example, within a suitable existing policy:

```text
pass in on em0 inet proto tcp from 192.168.10.0/24 to (em0) port 22 keep state
```

Replace interface/subnet/port. The broad example in section 3 is only a starting illustration: retain DHCP client/server, DNS and necessary ICMP/ICMPv6 rules for the actual role. Validate:

```bash
pfctl -nf /etc/pf.conf
```

No output/exit 0 means syntax passed. For an already-enabled filter load the reviewed file:

```bash
pfctl -f /etc/pf.conf
```

For a deliberately new pf deployment, after preserving required allowances:

```bash
sysrc pf_enable=YES
service pf start
```

**Check it worked:** `pfctl -s info` should show Enabled; `pfctl -sr` should show intended rules. Test **new** required connections, DHCP renewal on a noncritical test client if applicable, and name resolution. Existing states can hide a missing allow rule.

**Undo:** From the console restore the original file, validate and load it again. If pf was newly enabled and must be reverted, `pfctl -d` disables filtering temporarily; then restore the recorded rc.conf enable state. Do not leave protection disabled as the permanent repair. Do not `pfctl -F all` to troubleshoot one denied connection.

**Warnings:** A blacklisting anchor only has effect if its daemon and application integration are correctly configured; do not assume the anchor alone stops guessing. Do not replace an existing ipfw policy using a pf tutorial.

### 13.4 SSH and package-provided network services

- [ ] Done

**What:** Use rc services, package-specific configuration and actual client tests.

**Why it matters:** FreeBSD base OpenSSH uses `/etc/ssh`; third-party servers generally use `/usr/local/etc`, not Linux paths.

**Before changing anything:** Record required clients and working transactions. Keep root console and an existing authorized connection open. Determine base versus package ownership:

```bash
service -l
service -e
sockstat -4 -6 -l
pkg info
```

A base file may not belong to a pkg package; `pkg which PATH` returning no owner does not prove malware.

**Clicking (GUI):** Test required web/file/database applications with an existing client/browser. Server configuration normally uses `ee`, not a base graphical control panel.

| Required service | Typical rc name | Typical config | Validation before apply |
|---|---|---|---|
| Base OpenSSH | `sshd` | `/etc/ssh/sshd_config` | `/usr/sbin/sshd -t` |
| Apache package | `apache24` | `/usr/local/etc/apache24/httpd.conf` and Includes/sites | `/usr/local/sbin/apachectl configtest` |
| Nginx package | `nginx` | `/usr/local/etc/nginx/nginx.conf` | `/usr/local/sbin/nginx -t` |
| Samba package | `samba_server` | `/usr/local/etc/smb4.conf` | `/usr/local/bin/testparm -s` |
| BIND package | `named` | `/usr/local/etc/namedb/named.conf` | `named-checkconf` plus zone checks |
| PostgreSQL package | `postgresql` | Discover active config through SQL | Check `pg_file_settings` / `pg_hba_file_rules` as the DB administrator |
| MySQL/MariaDB package | `mysql-server` | Inspect package sample and active includes under `/usr/local/etc` | Version-specific option validation and application test |

Names/paths depend on installed package/version and may be overridden by rc.conf. Inspect `service NAME rcvar`, `sysrc -a` and package messages before editing.

**Typing (check, backup and edit):** SSH example:

```bash
service sshd status
sysrc sshd_enable
cp -p /etc/ssh/sshd_config /root/cp-backups/sshd_config.before-cp
ee /etc/ssh/sshd_config
```

**Typing (fix, only when appropriate):** Inspect `PermitRootLogin no`, `PermitEmptyPasswords no` and the actual authentication rules, preserving a permitted login for each required user. Keep forwarding/SFTP only as required. Validate and apply separately:

```bash
/usr/sbin/sshd -t
```

After no errors:

```bash
service sshd reload
```

For another installed server, use the table to identify its file, copy it privately with `cp -p`, open it with `ee`, apply the compatible defensive directives described in [service hardening](linux-service-hardening.md), then use its actual validation command. Read `service NAME` usage to confirm reload support; use a scheduled restart only when needed. Never assume a Linux package/unit/path applies.

**Check it worked:** `service sshd status`, `/usr/sbin/sshd -T` and `sockstat -4 -6 -l`; test a fresh authorized SSH session. For each other service test its actual authorized client operation, not merely its rc status. Inspect `/var/log/messages`, `/var/log/auth.log` and the daemon's configured log.

**Undo:** Restore the exact changed file, validate it and reload/restart that service. Restore its recorded rc enable value with `sysrc NAME_enable=YES/NO` only after confirming the real variable. Preserve original stopped/disabled states for services that were not needed.

**Warnings:** Do not disable a required SSH/web/database server or replace its full config with a Linux excerpt. Do not change `PermitRootLogin` until a working ordinary-user administration path is established.

### 13.5 Packages, permissions, persistence and final verification

- [ ] Done

**What:** Complete FreeBSD-native update and investigation checks without applying Linux baselines.

**Why it matters:** Base-system updates and pkg packages are separate. Base support/update methods depend on release and installation type; a handbook version label does not establish current support.

**Before changing anything:** Record release, enabled repositories and package origin. Preserve evidence and pending forensic answers. Do not raise kernel securelevel while repair may require changing immutable files.

**Clicking (GUI):** Use a file manager only if installed to inspect specific file properties; do not recursively change system ownership. Keep the console for package/update recovery.

**Typing (check):**

```bash
freebsd-version -ku
pkg -vv
pkg audit -F
pkg check -s -a
stat -f '%Lp %Su:%Sg %N' /etc/master.passwd /etc/passwd /etc/group
find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -ls 2>/dev/null
crontab -l
crontab -u bob -l
ls -la /etc/cron.d /usr/local/etc/rc.d /usr/local/etc/periodic 2>/dev/null
```

`pkg audit -F` refreshes advisory metadata, so it writes to disk; it is not evidence-preserving analysis. Hash mismatches need investigation, not automatic removal. FreeBSD master.passwd should not be readable by ordinary users; do not apply Linux root:shadow mode 640 to it.

**Typing (fix, only when appropriate):** Preview package upgrades:

```bash
pkg upgrade -n
```

After reviewing required packages and repository consistency:

```bash
pkg upgrade
```

For a supported release/install that uses binary `freebsd-update`, follow that release's instructions for `freebsd-update fetch` and `freebsd-update install`, reviewing changes before applying. Do not assume the same mechanism works on every development/custom-kernel/pkgbase installation. Do not do a major release upgrade during a timed round.

For an unauthorized cron entry, back up the user's crontab and use `crontab -u bob -e` to remove only that line. Inspect `/etc/crontab`, `/etc/periodic`, rc.local, shell profiles and SSH keys; never wipe all scheduled jobs. For kernel edits, record each current `sysctl KEY` value, back up `/etc/sysctl.conf`, change only a supported role-appropriate key, and verify both runtime and persistence.

**Check it worked:** Repeat package audit after updates, inspect rc services and socket listeners, test permitted logins and required services, review logs, and verify scoring freshness. For auditd inspect `/etc/security/audit_control`, `service auditd status`, and read an appropriate saved audit file with `praudit`; do not clear trails.

**Undo:** Restore the individual config/cron/sysctl value and validate again. A removed sysctl file entry does not reset the live value. Use supported package/base recovery for the specific update; file backups do not reverse package changes. Boot environments are useful only when available and permitted, and rollback can discard later fixes.

**Warnings:** Securelevel can prevent repairs until reboot; leave optional hardening until core functionality is verified. Never clear logs, remove every privileged binary, or delete package-owned system files based on names alone.
