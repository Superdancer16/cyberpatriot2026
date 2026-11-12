# Debian — tasks to finish after debian.sh

Use this after [debian.sh](debian.sh). The script runs only what you configured and cannot decide what earns points on the current VM. **The README and Scoring Report take priority.**

**Manual** means the script cannot safely finish the task alone. **Verify** means the script may have attempted it but you must check the result.

## 1. Before fixing anything

- [ ] **Read the VM README.** Record authorized users/admins, required groups, critical services, software and ports. [Start here](../debian.md#0-before-you-touch-anything).
- [ ] **Preserve required forensic answers and evidence** before changing accounts, packages, processes or files. [Forensics](../debian.md#1-forensics-questions-first).
- [ ] **Record the original score and admin access.** Check `sudo -v` and keep a working VM console; take a snapshot only when permitted.

## 2. Find unfinished script work

1. Open an admin terminal. Under `/root/DebianSecurityWork`, locate the latest `summary-...tsv` and `changes-...txt`.
2. Work through **FAILED** first, then **REVIEW** and **SKIPPED**. The script's `CHANGED` result does not guarantee scoring points.
3. Review the matching `backups-...` folder for `review-...txt` findings and preserved original files. A suspicious filename, port or cron entry is a clue, not proof.
4. Open the desktop Scoring Report, compare the current score with your starting score, and investigate any drop.

## 3. Users, groups and passwords

- [ ] **Manual — create users skipped by `--yes`:** Use `sudo adduser USER` with the exact README name and set a secure password interactively. Confirm `getent passwd USER` and a fresh authorized login. [Create users](../debian.md#23-create-users-the-readme-says-should-exist).
- [ ] **Manual — change a weak password:** `sudo passwd USER`; confirm the required login still works. Never store passwords inside the JSON. [Passwords](../debian.md#27-give-users-strong-passwords).
- [ ] **Verify — unauthorized users:** Compare `getent passwd`, UID and user home paths to the README. If an unauthorized user must be *removed*, expiring its account may not earn the removal point. Never delete system/service identities blindly. [Account cleanup](../debian.md#22-contain-unauthorized-users-delete-only-when-explicitly-required).
- [ ] **Verify — administrator rights:** `getent group sudo`, `id USER` and any extra sudoers rules. A README-listed **standard** user should remain but not be in `sudo`. [Admins](../debian.md#24-fix-who-is-an-administrator).
- [ ] **Verify — group creation:** `getent group GROUP` should show the exact required group. If absent, use `sudo addgroup GROUP`. [Groups](../debian.md#211-add-a-required-user-to-a-required-group).
- [ ] **Verify — group membership:** `id USER` and `getent group GROUP`; if missing, `sudo adduser USER GROUP`. Membership changes may require another login. [Membership](../debian.md#211-add-a-required-user-to-a-required-group).
- [ ] **Verify — first-login password change:** If required, run `sudo passwd -e USER` and check `sudo chage -l USER`. [Users](../debian.md#2-users-and-groups).
- [ ] **Verify — defaults and existing-user aging:** `grep '^PASS_' /etc/login.defs` and `sudo chage -l USER`. Editing `/etc/login.defs` alone does not change existing accounts. [Default aging](../debian.md#31-password-aging-defaults-for-new-accounts) · [Existing users](../debian.md#32-apply-aging-to-the-users-who-already-exist).
- [ ] **Manual — PAM history and lockout:** Confirm `pam_pwquality`, `pam_pwhistory` and `pam_faillock` versions/ordering using the actual Debian release. The script can change limited quality fields and remove `nullok` when explicitly enabled, but it does not invent a PAM stack. Keep root/console recovery open and test a second login. [Complexity](../debian.md#33-password-complexity-pwquality) · [Lockout](../debian.md#36-account-lockout-after-failed-logins-careful).
- [ ] **Verify — root, powerful groups and sudo rules:** Look for additional UID-0 users, unusual members of `disk`, `shadow`, `docker` or `lxd`, and unauthorized `NOPASSWD`. Do not lock the last recovery route or indiscriminately remove SUID bits. [Privileged accounts](../debian.md#210-account-inventory-privileged-groups-and-safe-verification) · [Sudo policy](../debian.md#12-sudo-rules).

## 4. Firewall, SSH and updates

- [ ] **Verify — firewall:** `sudo ufw status verbose` or `sudo nft list ruleset` for an nftables-managed image. Test every required network port and second-client access. The script will not blindly replace nftables with UFW. [Firewall](../debian.md#4-firewall).
- [ ] **Verify — OpenSSH:** `sudo /usr/sbin/sshd -t`; inspect `sudo /usr/sbin/sshd -T | grep permitrootlogin`. Review `sshd_config.d`, `Match` blocks, public keys, password policy and required ports. Test another permitted SSH login before closing the first session. [SSH](../debian.md#9-ssh-server-only-if-installed).
- [ ] **Verify — package sources and updates:** Review signed APT sources, held packages and `apt list --upgradable`; confirm important security updates, Chromium and OpenSSH are updated without removing required software. [Updates](../debian.md#5-updates).
- [ ] **Verify — automatic package-index refresh:** Inspect `/etc/apt/apt.conf.d/20auto-upgrades` and apt timers. Refreshing package lists is not the same as installing patches. [Automatic updates](../debian.md#53-turn-on-automatic-updates).
- [ ] **Verify — sysctl/network values:** `sysctl net.ipv4.tcp_syncookies net.ipv4.ip_forward`. Do not disable forwarding on a required router, VPN or container gateway. [Kernel settings](../debian.md#10-kernel-and-network-settings).

## 5. Services, prohibited items and persistence

- [ ] **Verify — required services:** `systemctl status UNIT` and `ss -lntup`; test actual websites, FTP transfers, DNS, file shares or databases. The script will not guess whether Apache, FTP, PostgreSQL or SSH is required. [Services](../debian.md#6-services).
- [ ] **Manual — critical service configuration:** Apache, Nginx, PHP, MariaDB/MySQL, FTP, Samba, DNS, Postfix and PostgreSQL each need release- and role-specific validation. The script offers narrow opt-in fixes for Apache, Nginx, vsftpd, Samba and Postfix only. [Critical services](../debian.md#16-critical-services-complete-manual-procedures).
- [ ] **Verify — prohibited packages:** Use `dpkg-query -W PACKAGE` and preview removal dependencies. The script refuses removals affecting several packages; do not purge a required program or desktop component. [Software](../debian.md#7-prohibited-software-and-files).
- [ ] **Verify — prohibited files:** Review candidate-file reports. Search requested paths with `find` and remove only README-confirmed content after preserving evidence. The script does not delete discovered files automatically and protects system paths. [Media](../debian.md#74-media-files-music-and-video) · [Other files](../debian.md#75-other-files-that-break-policy).
- [ ] **Manual — suspicious cron and systemd persistence:** Check `sudo crontab -l`, user crontabs, `systemctl list-timers --all`, `systemctl cat UNIT`, and unusual listener binaries. The script removes only exact configured cron lines or disables exact selected units, not arbitrary PIDs. [Cron](../debian.md#131-scheduled-jobs-cron) · [Backdoors](../debian.md#13-backdoors-and-malware).
- [ ] **Verify — hosts and shell startup:** Inspect `/etc/hosts`, `/etc/profile`, `/etc/profile.d` and user startup entries. The script removes only confirmed exact hosts lines. [Hosts](../debian.md#135-the-hosts-file) · [Startup](../debian.md#137-programs-that-start-when-someone-logs-in).
- [ ] **Verify — sensitive permissions:** `stat -c '%a %U:%G %n' /etc/shadow /etc/gshadow`; review SUID/SGID, capabilities, ownership and world-writable files. The script does not widen an already restrictive shadow mode. [Permissions](../debian.md#11-file-permissions-and-ownership).
- [ ] **Verify — AppArmor and logs:** `sudo aa-status`, `journalctl -p err -n 30` and relevant service status. Investigate disabled profiles and configuration conflicts; the script only applies named installed profiles/logging units. [AppArmor](../debian.md#15-apparmor) · [Logs](../debian.md#14-logging-and-auditing).
- [ ] **Manual — desktop and browser:** Confirm the actual GDM/LightDM login configuration, screen lock and required Chromium/Firefox ESR settings. A browser policy file may not affect a different installed browser. [Login](../debian.md#8-login-screen-and-screen-lock) · [Browser](../debian.md#17-web-browser-and-applications).

## 6. Final verification

- [ ] All README-required users, administrator rights, groups, browsers and critical services still work.
- [ ] No unexpected PAM/sudo lockout, SSH disconnection, blocked firewall port or broken required package.
- [ ] Review all **FAILED**, **REVIEW** and **SKIPPED** items; retain the original backups and change log.
- [ ] Compare the final Scoring Report with the original. Reboot only if needed and allowed, then verify again. [Final checks](../debian.md#19-final-checklist).

**Recovery:** Look under `/root/DebianSecurityWork` in the matching `backups-...` directory, including `originals/`. Restore one changed file at a time, validate configuration syntax and retest required clients. User/file/package deletion is not guaranteed reversible.

This is a Debian 12/13 reference. The executable has not been tested on an actual competition VM in this session.
