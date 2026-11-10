# Debian checklist (Debian 11 / 12)

Debian 12 ("bookworm") is in **Round 2, the State round and the Semifinals** this season.

Debian is Ubuntu's and Linux Mint's "parent", so most commands are the same as the [Linux Mint checklist](linux-mint.md). This page walks through the whole job and explains **the Debian differences** that trip people up. Where a step is exactly the same as Mint, it links there.

> [!IMPORTANT]
> **The five big Debian differences**
> 1. **`sudo` may not work.** If a root password was set when Debian was installed, your user isn't an admin yet. Use **`su -`** to become root (step 0.3).
> 2. **No firewall is installed.** You must install `ufw` (section 4).
> 3. **No `/var/log/auth.log`.** Debian 12 keeps logs in the **journal**, so use `journalctl` for forensics (section 1).
> 4. **Automatic updates are not installed** (section 5).
> 5. The desktop is usually **GNOME**, so the settings are in **Settings**, not Mint's tools.

---

## 0. Before you touch anything

### 0.1 Read the README, take a snapshot, open the Scoring Report
- [ ] Done

See [Reading the README](../start-here/reading-the-readme.md). In VMware: **VM → Snapshot → Take Snapshot**.

### 0.2 Open a terminal
- [ ] Done

GNOME: press the **Super (Windows) key**, type `terminal`, press Enter.

### 0.3 Become an administrator: `sudo` or `su -`
- [ ] Done

```bash
sudo -v
```
- **No error:** good, use `sudo` like on Mint.
- **"Sorry, user ... may not run sudo"**, **"user is not in the sudoers file"** or **"sudo: command not found":** use the **root password** from the README:
  ```bash
  su -               # note the dash! it asks for ROOT's password
  ```
  Your prompt changes to `root@...#`. Now run every command **without** `sudo`.

> [!WARNING]
> Use `su -` **with the dash**. Plain `su` keeps your normal PATH, so commands like `usermod` or `ufw` give "command not found".

Optional, to make life easier: give the README's admins working `sudo` (this is often scored too):
```bash
apt install sudo
usermod -aG sudo alice       # every README admin
```
They must **log out and back in** before `sudo` works for them.

---

## 1. Forensics questions (FIRST)

### 1.1 Answer them before changing anything
- [ ] Done

Same tools as [Mint section 1](linux-mint.md#1-forensics-questions-do-these-first), **except the logs:**
```bash
sudo journalctl _COMM=sshd | tail -50         # SSH logins
sudo journalctl _COMM=sudo                    # every sudo command
sudo journalctl -u cron --since "2 days ago"  # cron jobs that ran
sudo journalctl --list-boots                  # boot history
last -a | head -20                            # recent logins
```
Without `sudo` (or root), `journalctl` shows only **your own** messages, so a login by someone else would be missing.

`/var/log/auth.log` only exists if `rsyslog` is installed (Debian 11 has it; Debian 12 doesn't until you install it in step 10.1, and then it only has new events).

### 1.2 Fast path: run the hardening script
- [ ] Done

**What:** Prepare a manual baseline. The upstream automation is not included in this repository.

**Why it matters:** A status label cannot establish that a setting is correct on this particular image.

**Before changing anything:** Read the README and preserve forensics evidence. Record your current administrator account, required users, services, ports, and initial score.

**Clicking (GUI):** Open the README and Scoring Report from the desktop. In your VM manager, create a practice snapshot only if the round rules permit it. Open the platform's account and service management screens described below.

**Typing (check):** Use the read-only inventory commands in the next section of this checklist. Save their output in a private working folder; do not publish passwords or password hashes.

**Typing (fix, only when appropriate):** Work through one manual item at a time below. Read every command before entering it. There is no script to download from this repository.

**Check it worked:** Repeat each inspection, test the README-required function, then refresh the Scoring Report. A lack of new points does not prove the change failed.

**Undo:** Reverse the most recent change using the recorded value or the procedure's backup. A VM snapshot rollback can discard later fixes; use it only within the rules and verify the resulting score again.

**Warnings:** Never use a guessed list of authorized users or bulk-delete files. See [Using the scripts safely](../start-here/using-the-scripts.md) for the limits of external tools.

---

## 2. Users and groups

### 2.1 List users
- [ ] Done

**Clicking (GNOME):** **Settings → Users** → click **Unlock** (top right) and enter a password.

**Typing:**
```bash
awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd
```

### 2.2 Delete users who are not in the README
- [ ] Done

**Clicking:** **Settings → Users** → **Unlock** → click the user → **Remove User…**

**Typing:**
```bash
sudo deluser mallory              # or as root: deluser mallory
```

### 2.3 Add missing users
- [ ] Done

```bash
sudo adduser erin
```

### 2.4 Fix administrators (the `sudo` group)
- [ ] Done

**Clicking:** **Settings → Users** → click the user → toggle **Administrator**.

**Typing:**
```bash
getent group sudo
sudo deluser bob sudo
sudo usermod -aG sudo alice
```

### 2.5 Hidden root accounts, hidden users, powerful groups, weak passwords
- [ ] Done

Same as [Mint 2.5 – 2.7](linux-mint.md#25-look-for-hidden-root-accounts-and-hidden-users).

### 2.6 The root account
- [ ] Done

On Debian, **root may have a password** (Mint and Ubuntu lock it).
```bash
sudo passwd -S root       # P = has a password, L = locked
```
- If the README/policy requires disabling root password login, first prove a separate authorized sudo/recovery path works (0.3), then use `sudo passwd -l root`. A working sudo setup alone does not require this change.
- If you still need `su -`, **don't lock root**. Just make sure its password is strong: `passwd root`

---

## 3. Password and lockout policy

### 3.1 Same as Mint
- [ ] Done

Follow [Mint section 3](linux-mint.md#3-password-and-lockout-policy) and [the full PAM procedure](linux-mint.md#172-password-aging-pam-and-lockout-without-breaking-login). Inspect installed modules, profiles and control flow; Debian PAM layouts can differ by release, package version and enabled identity providers. Do not replace the stack based on an assumed layout.

`libpam-pwquality` isn't installed by default (Mint 3.3 starts by installing it):
```bash
sudo apt install libpam-pwquality
```

---

## 4. Firewall

### 4.1 Install and turn on UFW
- [ ] Done

**Why:** The image may have no active host firewall, but it may already use native nftables or another manager. First inspect [the existing firewall owner](linux-mint.md#174-ufw-and-nftables-one-firewall-owner). The UFW commands below apply only if UFW is the chosen manager; do not enable a competing policy blindly. Establish required source/port exceptions before enabling default deny.

```bash
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp            # ONLY if SSH is critical; add other critical ports (Mint 4.2)
sudo ufw enable
sudo ufw logging on
sudo ufw status verbose
```
Prefer clicking? `sudo apt install gufw`, then open **Firewall Configuration**.

---

## 5. Updates

### 5.1 Check the software sources
- [ ] Done

```bash
grep -rs '^[^#]' /etc/apt/sources.list*       # every source line, with the file it is in
```
The sources can be in `/etc/apt/sources.list` (one line per source: `deb http://... bookworm main`) or in a `.sources` file in `/etc/apt/sources.list.d/` (blocks of `URIs:`, `Suites:`, `Components:` lines). Check both. Ignore backup copies (names ending in `.save`, `.bak` or `~`): apt only reads `sources.list` and the `.list` / `.sources` files.

For Debian 12 you should see **`deb.debian.org/debian`** with **`bookworm`** and **`bookworm-updates`**, and **`security.debian.org/debian-security`** (or `deb.debian.org/debian-security`) with **`bookworm-security`**. Debian 11 says `bullseye` instead. The components are normally `main` (Debian 12 often adds `non-free-firmware`): that's fine.
- A missing **security** source means no security updates.
- Anything else, especially with `[trusted=yes]` or `Trusted: yes`, should be removed unless the README needs it.
- A **`deb cdrom:`** line makes `apt update` fail or ask for the install disc. Put a `#` in front of it (`sudo nano /etc/apt/sources.list`).

### 5.2 Install all updates
- [ ] Done

```bash
sudo apt update
sudo apt full-upgrade -y
```
(GNOME's **Software** app also shows updates.)

### 5.3 Turn on automatic updates
- [ ] Done

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades       # answer Yes
cat /etc/apt/apt.conf.d/20auto-upgrades
```
**Check it worked:** the file has `APT::Periodic::Update-Package-Lists "1";` and `APT::Periodic::Unattended-Upgrade "1";` (inspect other APT periodic directives too).

### 5.4 Held packages
- [ ] Done

```bash
apt-mark showhold              # anything listed will never update
sudo apt-mark unhold firefox-esr        # change firefox-esr to each name the line above printed
```

### 5.5 Update Firefox ESR and the README's apps
- [ ] Done

**What:** On Debian, Firefox is the package **`firefox-esr`** (there is no `firefox` package, so `apt install firefox` fails). Thunderbird, LibreOffice and the README's critical services also update through `apt`. Step 5.2 updates them all; if you skipped it or it failed, update the important ones on their own:
```bash
apt list --upgradable 2>/dev/null | grep -Ei 'firefox|thunderbird|libreoffice'   # anything listed is out of date
sudo apt install --only-upgrade firefox-esr thunderbird      # skips any that aren't installed
```
**Check it worked:** run the `apt list --upgradable` line again: it prints nothing.

---

## 6. Services

### 6.1 GNOME "Sharing" settings
- [ ] Done

**Clicking:** **Settings → Sharing** (in the list on the left). Turn **off** anything the README doesn't need: **Remote Desktop / Screen Sharing**, **Remote Login** (that's SSH), **File Sharing**, **Media Sharing**.

### 6.2 Turn off services that aren't needed
- [ ] Done

Same table and commands as [Mint section 6](linux-mint.md#6-services):
```bash
systemctl list-units --type=service --state=running
sudo ss -tulpn
sudo systemctl disable --now vsftpd     # change vsftpd to the service you are turning off
sudo apt purge vsftpd                   # remove it completely (change the name here too)
```

---

## 7. Prohibited software and files

### 7.1 Same as Mint
- [ ] Done

Follow [Mint section 7](linux-mint.md#7-prohibited-software-and-files). Debian's GNOME install can include games (`gnome-games`, `aisleriot`, `gnome-mines`, `gnome-sudoku`…):
```bash
dpkg -l | grep -Ei 'gnome-games|aisleriot|mines|sudoku|mahjongg|chess|robots|tetravex|nibbles|klotski|quadrapassel|swell-foop|tali|four-in-a-row|five-or-more|hitori|iagno|lightsoff'
sudo apt purge gnome-games && sudo apt autoremove
```
Debian's standard install also includes **`netcat-traditional`** (the `nc` command, a favourite for backdoors). Remove it only if prohibited by the README, using: `sudo apt purge netcat-traditional`, unless the README needs it.

---

## 8. Login screen and screen lock

### 8.1 No automatic login (GDM)
- [ ] Done

**Clicking:** **Settings → Users** → **Unlock** → turn off **Automatic Login** for every user.

**Typing:**
```bash
sudo nano /etc/gdm3/daemon.conf
```
In `[daemon]`:
```
AutomaticLoginEnable=false
TimedLoginEnable=false
```
In `[security]`: `DisallowTCP=true`.

### 8.2 Screen lock
- [ ] Done

**Clicking:** **Settings → Privacy → Screen** (Debian 11: **Privacy → Screen Lock**): **Blank Screen Delay: 5 minutes**, **Automatic Screen Lock: On**, **Automatic Screen Lock Delay: Screen Turns Off**.

**Check** (in a terminal as **your own user**, not after `su -` or with `sudo`: as root, `gsettings` shows root's settings, not yours):
```bash
gsettings get org.gnome.desktop.screensaver lock-enabled     # true
gsettings get org.gnome.desktop.session idle-delay           # uint32 300
```

### 8.3 Hide the list of users on the login screen
- [ ] Done

**What:** Make the GDM login screen ask for a user name instead of showing every account.

**Why it matters:** The list tells anyone at the keyboard which accounts exist, so they only have to guess a password.

**Typing:**
```bash
sudo sed -i 's/^# *disable-user-list=true/disable-user-list=true/' /etc/gdm3/greeter.dconf-defaults
grep disable-user-list /etc/gdm3/greeter.dconf-defaults      # disable-user-list=true, with no # in front
```
Or by hand: `sudo nano /etc/gdm3/greeter.dconf-defaults`, find `[org/gnome/login-screen]` and delete the `#` in front of `disable-user-list=true` (add the line under that heading if it isn't there).

**Check it worked:** the `grep` line above. The login screen changes after the next restart.

> [!CAUTION]
> Don't run `systemctl restart gdm` to see it sooner: that logs you out at once, and anything unsaved (like a forensics answer) is lost.

---

## 9. SSH, kernel, permissions, sudo rules, backdoors

These are the same on Debian. Follow the Mint sections:

- [ ] [9. SSH server](linux-mint.md#9-ssh-server-only-if-installed)
- [ ] [10. Kernel and network settings](linux-mint.md#10-kernel-and-network-settings-sysctl)
- [ ] [11. File permissions](linux-mint.md#11-file-permissions)
- [ ] [12. Sudo rules](linux-mint.md#12-sudo-rules)
- [ ] [13. Backdoors and malware](linux-mint.md#13-backdoors-and-malware)

---

## 10. Logging and auditing

### 10.1 Install rsyslog and auditd
- [ ] Done

**Why:** Without `rsyslog`, there's no `/var/log/auth.log`. Many people (and some scoring checks) expect it.
```bash
sudo apt install rsyslog auditd
sudo systemctl enable --now rsyslog auditd
```
Audit rules: same as [Mint 14.1](linux-mint.md#14-logging-and-auditing).

### 10.2 AppArmor
- [ ] Done

Debian has AppArmor turned on by default. Check it's still on:
```bash
sudo aa-status                       # "apparmor module is loaded." and a list of profiles
sudo systemctl enable --now apparmor # only if it was turned off
```

---

## 11. Critical services

Follow the [Linux service hardening guide](../guides/linux-service-hardening.md) for every service the README lists.

---

## 12. Final checks

- [ ] Critical services running (`systemctl status <name>`)
- [ ] The README admins can use `sudo` (or you can still `su -`)
- [ ] `sudo ufw status` → active
- [ ] Scoring Report shows **no penalties**
- [ ] Forensics answers saved, final snapshot taken

## 13. Debian-specific manual verification and recovery

### 13.1 Root, sudo and account policy

- [ ] Done

**What:** Establish the image's actual administration path before changing root or PAM.

**Why it matters:** Debian can be installed with a usable root password and no sudo setup. Locking root first can remove the only recovery path.

**Before changing anything:** Keep a root console (`su -`, then enter the root password interactively) open. Do not paste the root password into a command. Follow [Mint 17.1–17.2](linux-mint.md#171-users-root-and-privilege-recovery) for private backups, account reconciliation, aging and PAM tests; inspect the modules actually installed on Debian.

**Clicking (GUI):** In GNOME use **Settings → Users → Unlock**. Xfce/KDE use their own account panels. GUI account panels do not show every service account or sudoers include.

**Typing (check):** In the normal user's terminal:

```bash
cat /etc/os-release
id
command -v sudo
getent group sudo
```

From the root console inspect `passwd -S root` and `visudo -c` if sudo is installed. Do not presume that `su - bob` from root validates Bob's password.

**Typing (fix, only when appropriate):** If the README authorizes your user as an administrator and sudo is absent, from the existing root shell:

```bash
apt install sudo
```

Then, substituting the actual authorized account:

```bash
usermod -aG sudo alice
visudo -c
```

Do not add a duplicate blanket line to sudoers. In a **new login** as Alice run `sudo -v` and `sudo -l`. Only after an independently tested admin/recovery path exists should you consider locking root's password if appropriate; root need not be locked merely to match Ubuntu.

**Check it worked:** New admin login succeeds; approved ordinary users lack unauthorized sudo grants; `sudo chage -l bob` matches the README. Test a normal password change after any PAM modification.

**Undo:** From the retained root console restore the original individual sudoers/group/PAM settings. If root was mistakenly password-locked, restore the recorded state only after checking the authorized access policy; do not unlock it blindly.

**Warnings:** Debian 11/12 package versions differ in PAM profiles and algorithms. Never replace common-auth/common-password with a copied internet stack or re-enable obsolete pam_tally modules.

### 13.2 Debian repositories, security pockets and updates

- [ ] Done

**What:** Use signed repositories for the actual installed Debian release.

**Why it matters:** Mixing stable/testing/Ubuntu packages can make dependency recovery difficult. Debian 11 and 12 support status differs over time; verify current official security/LTS coverage for the image's architecture and packages.

**Before changing anything:** Back up `/etc/apt` using [Mint 17.5](linux-mint.md#175-package-sources-updates-and-vulnerability-triage). Read the installed `man sources.list` and record the release codename.

**Clicking (GUI):** If installed, **Software & Updates / Software Sources** or Synaptic's **Settings → Repositories**. Do not install a new package manager merely for this screen.

**Typing (check):**

```bash
cat /etc/os-release
apt-cache policy
sudo grep -RHE '^(deb |Types:|URIs:|Suites:|Components:|Signed-By:)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
```

Debian 12 uses `bookworm`, `bookworm-updates` and `bookworm-security` for the respective pockets when supported. Debian 11 uses its own `bullseye` suites. Both `.list` and `.sources` formats can be valid. Do not change codenames to those of a newer release during a round.

**Typing (fix, only when appropriate):** Edit only the identified bad entry using `sudo nano` on that file, preserving signed official entries. Then run separately:

```bash
sudo apt update
```

```bash
apt -s upgrade
```

After reviewing a clean preview:

```bash
sudo apt upgrade
```

**Check it worked:** `sudo dpkg --audit` should report no incomplete package configuration; `apt list --upgradable` explains what remains. Verify Firefox ESR and required applications through their supported Debian package updates; Debian security fixes can be backported without adopting an upstream major version.

**Undo:** Restore the affected source file and refresh metadata; installed-package recovery is separate. Do not delete package-manager locks while another manager runs.

**Warnings:** A repository error can reflect a mirror, DNS, clock or lifecycle problem. Do not disable signature checking or copy a historical sources.list to silence it.

### 13.3 Native firewall ownership, logs and desktop

- [ ] Done

**What:** Preserve Debian's actual firewall/logging/desktop design.

**Why it matters:** Debian may use native nftables and journald without UFW or `/var/log/auth.log`. Absence of an Ubuntu GUI does not mean protection is missing.

**Before changing anything:** Save the active rules and identify the existing manager with [Mint 17.4](linux-mint.md#174-ufw-and-nftables-one-firewall-owner). Record GNOME/KDE/Xfce and the display manager.

**Clicking (GUI):** GNOME **Settings → Privacy / Privacy & Security → Screen Lock**; KDE **System Settings → Screen Locking**; Xfce's lock behavior depends on its installed locker. Set and test the actual one. Do not use Cinnamon gsettings keys on Debian GNOME.

**Typing (check):**

```bash
sudo nft list ruleset
systemctl status nftables systemd-journald rsyslog --no-pager
sudo journalctl _COMM=sshd -n 50 --no-pager
sudo journalctl _COMM=sudo -n 50 --no-pager
systemctl status display-manager --no-pager
```

Unknown rsyslog/UFW units may be normal. Investigate actual logging retention instead of assuming a file must exist.

**Typing (fix, only when appropriate):** Keep the existing firewall owner. Use the full native nftables edit/validation procedure linked above if applicable. Use [Mint 17.6–17.8](linux-mint.md#176-ownership-permissions-suid-and-capabilities) for file permissions, cron/systemd persistence, AppArmor and kernel controls, checking supported keys/modules first. Use the [per-service procedures](../guides/linux-service-hardening.md) for Apache/Nginx, databases, FTP, Samba, DNS, DHCP and mail.

**Check it worked:** A new authorized login, sudo, expected logs, new inbound permitted service connections and all required application transactions must succeed. Record the final scoring timestamp and save forensics answers.

**Undo:** Restore only the changed rule/config/key using its backup, validate syntax and retest. Do not flush all nftables rules, clear logs or restart the display manager as a generic repair.

**Warnings:** On remote sessions get console access before changing firewall or authentication. Required services stay enabled even if the README uses different wording from the checklist.
