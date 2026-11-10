# Linux advanced manual investigations: SSH, PAM, UFW and persistence

> Use alongside [Linux Mint](../checklists/linux-mint.md), [Ubuntu](../checklists/ubuntu.md), [Debian](../checklists/debian.md), and [critical service hardening](linux-service-hardening.md). This page assumes **Ubuntu / Debian / Linux Mint using systemd**; consult the [FreeBSD checklist](../checklists/freebsd.md) for FreeBSD-specific commands. **Read the image README and preserve forensics evidence first.**

These are individually copyable terminal commands. **Inspection is not the same as permission to modify.** Run modifications only after verifying accounts, critical services, connectivity and backups.

## L1. Verify user identities and sudo privileges—don't guess from names

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

## L2. SSH: inspect *effective* settings and socket activation

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

## L3. PAM policy: inspect order before adding modules

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

If changing aging is required, consult the policy specified in the README and the [Mint checklist](../checklists/linux-mint.md#3-password-and-lockout-policy) for \`chage\` examples.

**Before edits:** Preserve backups of \`/etc/pam.d/common-password\`, \`common-auth\` and the relevant original config, plus working console/root access. When available, use distribution-maintained \`pam-auth-update\` rather than inventing a new stack.

**Verification:** Before logging out, test authentication in a *new local or console session* as an authorized ordinary user and verify an authorized sudo elevation. Never intentionally force a logout while authentication is unverified.

**Recovery:** Restore the specific original PAM file using recovery/console access, then retest. This is a high-risk category and should not be changed merely because a generic checklist recommends a number.

## L4. Check scheduled persistence in cron and systemd

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

## L5. Firewall: preserve required access before enabling UFW

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

## L6. Narrow file and package investigations

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

## References and cross-checks

- [Ubuntu 24.04 OpenSSH socket activation notes](https://documentation.ubuntu.com/release-notes/24.04/)
- [Ubuntu security: Unnecessarily open ports](https://documentation.ubuntu.com/security/common-mistakes/unnecessarily-open-ports/)
- [Ubuntu security: Firewalls](https://documentation.ubuntu.com/security/security-features/network/firewall/)
- CyberPatriot community topic inventories: [PeapGit CPLHF](https://github.com/PeapGit/cplhf) (historical hardening automation: **do not execute as part of this guide**), [Minagera Linux checklist](https://github.com/Minagera/CyberPatriot/blob/main/Checklists/Linux/README.md), [chessischess Linux checklist](https://github.com/chessischess/cyberpatriot-checklist/blob/master/Linux_Checklist.md).
