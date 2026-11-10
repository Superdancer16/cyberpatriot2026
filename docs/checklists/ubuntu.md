# Ubuntu checklist (20.04 / 22.04 / 24.04)

Ubuntu isn't in this season's CyberPatriot lineup, but it's very common on **older practice images**. Linux Mint is built on Ubuntu, so **follow the [Linux Mint checklist](linux-mint.md)**. Many underlying commands are shared, but inspect the actual package versions, desktop and configuration before following them. Differences are documented below.

> [!TIP]
> Use the shared [manual preparation step](linux-mint.md#12-fast-path-run-the-hardening-script) and the Ubuntu-specific procedures below. No automation is included.

---

## Differences from Linux Mint

### Users: GNOME Settings instead of "Users and Groups"
- [ ] Done

**Settings → Users** → **Unlock**. Add or remove users, and toggle **Administrator**. The terminal commands are the same as Mint section 2.

### Updates: "Software & Updates" instead of "Update Manager"
- [ ] Done

**Clicking:** open **Software & Updates** → **Updates** tab:
- **Subscribed to:** All updates
- **Automatically check for updates:** **Daily**
- **When there are security updates:** **Download and install automatically**

Then open **Software Updater** and install everything.

On the **Other Software** tab, untick any PPA the README doesn't need.

> [!NOTE]
> Ubuntu 24.04 keeps its sources in **`/etc/apt/sources.list.d/ubuntu.sources`** (a newer format with `URIs:` and `Suites:` lines) instead of `/etc/apt/sources.list`.

### Firefox (and other apps) are "snaps"
- [ ] Done

On Ubuntu 22.04+, Firefox is a **snap** package, so `apt` doesn't update it:
```bash
snap list                       # every snap app
sudo snap refresh               # update all snaps (including Firefox)
sudo snap remove steam          # remove a prohibited snap app: change steam to the name from snap list
```

### Firewall: UFW is installed but OFF
- [ ] Done

Use [the firewall ownership and recovery procedure](linux-mint.md#174-ufw-and-nftables-one-firewall-owner). If GUFW is already installed it provides a UFW GUI; it is not necessary to install it for manual terminal configuration.

### Login screen: GDM instead of LightDM
- [ ] Done

**Settings → Users** → turn off **Automatic Login**. Or edit `/etc/gdm3/custom.conf` (Ubuntu's name for it), under `[daemon]`:
```
AutomaticLoginEnable=false
TimedLoginEnable=false
```
To inspect or change the login-screen user list, review `/etc/gdm3/greeter.dconf-defaults` and the version-specific procedure in [Debian step 8.3](debian.md#83-hide-the-list-of-users-on-the-login-screen).

### Screen lock: GNOME settings
- [ ] Done

**Settings → Privacy (& Security) → Screen** (or **Screen Lock**): **Automatic Screen Lock: On**, **Blank Screen Delay: 5 minutes**.
```bash
gsettings get org.gnome.desktop.screensaver lock-enabled      # true
```

### Remote access: GNOME "Sharing"
- [ ] Done

**Settings → Sharing** (24.04: **Settings → System → Remote Desktop / Secure Shell**). Turn off **Screen Sharing / Remote Desktop**, **Remote Login** (SSH), and **Media Sharing** unless the README needs them.

### SSH on Ubuntu 22.10 and newer
- [ ] Done

SSH may be started **on demand** by `ssh.socket`. To turn it off completely:
```bash
sudo systemctl disable --now ssh.socket ssh.service
systemctl is-enabled ssh.socket ssh.service      # both should say "disabled"
```
If the README needs SSH and you change `Port` or `ListenAddress` in `sshd_config`, the socket decides the port, so also run `sudo systemctl daemon-reload && sudo systemctl restart ssh.socket`.

### Ubuntu 20.04: inspect available PAM modules
- [ ] Done

Inspect installed PAM modules and use [the supported PAM procedure](linux-mint.md#172-password-aging-pam-and-lockout-without-breaking-login); do not select pam_tally2 solely because the image is Ubuntu 20.04.

### Default games and apps
- [ ] Done

A normal Ubuntu desktop install includes **AisleRiot Solitaire, Mahjongg, Mines, Sudoku** and **Transmission** (torrents). Remove them unless the README needs them:
```bash
sudo apt purge aisleriot gnome-mahjongg gnome-mines gnome-sudoku transmission-gtk transmission-common
```

## Ubuntu manual baseline and release differences

### U.1 Establish release, desktop and authentication recovery

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

### U.2 APT sources and supported security updates

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

### U.3 SSH socket activation on newer Ubuntu

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

### U.4 GNOME desktop, firewall and services

- [ ] Done

**What:** Configure the actual desktop user's screen lock and complete the shared Linux service checks.

**Why it matters:** `sudo gsettings` targets the wrong user; a secure desktop does not compensate for an open server.

**Before changing anything:** Record the user's current values and inspect installed schemas. Use [Mint 17.4–17.9](linux-mint.md#174-ufw-and-nftables-one-firewall-owner) for firewall, package, permissions, persistence, kernel/AppArmor, log and recovery procedures, and [service hardening](../guides/linux-service-hardening.md) for each installed required daemon.

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
