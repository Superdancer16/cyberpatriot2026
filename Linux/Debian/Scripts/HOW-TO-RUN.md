# Debian 12/13 script — download and run inside the VM

Use [debian.sh](debian.sh) with the [Debian handbook](../debian.md). Like the Windows script, it has an audit, image-specific JSON configuration, all-in-one Apply mode, logs and backups. The active image README always takes priority.

## 1. Log in to GitHub inside the Debian VM

1. Start the Debian virtual machine and sign in to its assigned user account.
2. Inside the VM, open Firefox ESR, Chromium or another installed browser.
3. Go to **https://github.com/login**, sign in if necessary and complete any verification. The repository is public, so a GitHub login is optional.
4. Open **https://github.com/Superdancer16/cyberpatriot2026** and choose branch **main**.
5. Open **Linux → Debian → Scripts**, select **debian.sh**, and click **Raw**.
6. Save the raw text to **Downloads → debian.sh** in the VM. If the browser displays the text, use **Ctrl+S** and select a plain file, not a complete webpage. Confirm the file is not named `.html` or `.txt`.
7. Sign out of GitHub and decline to save personal credentials inside the VM. Do not download or run it on your host computer.

If browsing or external downloads are not permitted in your round, use only the transfer process approved by your coach.

## 2. Verify the downloaded script

Open Terminal in the Debian VM (often **Ctrl+Alt+T**) and run:

```bash
cd ~/Downloads
ls -l debian.sh
head -n 3 debian.sh
bash -n debian.sh
```

The first line should be `#!/usr/bin/env bash`. The `bash -n` check should produce no errors. This script supports Debian 12/13 only.

## 3. Audit first, before any changes

```bash
sudo bash ./debian.sh --audit
```

Read the VM README, note the initial scoring report and preserve any necessary forensic evidence. Audit produces files in `/root/DebianSecurityWork`. Nothing is hardened in Audit mode.

## 4. Create the README-specific config

Create the JSON template as your regular VM user:

```bash
bash ./debian.sh --init-config --config ./image-config.json
nano ./image-config.json
```

In nano, use **Ctrl+O → Enter** to save and **Ctrl+X** to exit.

| JSON field | Use |
|---|---|
| `AuthorizedAdmins`, `AuthorizedUsers` | Exact authorized accounts; at least one administrator required |
| `RequiredServices`, `RequiredSoftware`, `RequiredPorts` | Things that the script must protect |
| `NewUsers`, `DemoteSudo`, `SetPasswords`, `ExpirePasswords`, `DisableUsers`, `RemoveUsers` | Specific account changes |
| `NewGroups`, `GroupMembers`, `RemoveGroupMembers` | Group creation and exact user membership |
| `PasswordAging`, `UserAging`, `PasswordQuality`, `RemovePAMNullok` | Selected Debian password-aging/PAM controls |
| `EnableUFW`, `InstallUFW`, `FirewallAllowPorts` | UFW and permitted service/remote-management ports |
| `UpdatePackageLists`, `UpgradePackages`, `UpdatePackages`, `EnableDailyUpdateRefresh` | APT repository refresh, updates and daily checking |
| `SSH`, `DisableServices`, `EnableRequiredServices`, `Sysctl` | SSH, required services and selected kernel values |
| `FixShadowPermissions`, `AppArmorProfiles`, `Logging` | Sensitive permissions, AppArmor and logs |
| `RemovePackages`, `RemoveFiles`, `RemoveCronLines`, `RemoveHostsLines`, `DisableUnits` | Exact confirmed unwanted items |
| `Desktop`, `Browsers`, `ServiceHardening` | Opt-in GDM, Chromium and service-specific changes |
| `ScanPaths` | Additional folders for read-only file candidate searches |

Example group entries inside the existing JSON:

```json
"NewGroups": ["EXAMPLE_GROUP"],
"GroupMembers": {
  "EXAMPLE_GROUP": ["EXAMPLE_USER_A", "EXAMPLE_USER_B"]
}
```

For password minimum age, the JSON may contain `"PasswordAging": {"PASS_MIN_DAYS": 7}` only if the image asks for seven days. Never assume generic example values are scored.

Fill authorized users, critical services and packages from your actual image. Once reviewed, change `"ConfirmedReadme": false` to `true`. Set `"ForensicsComplete": true` only after preserving required evidence. Leave compatibility-sensitive toggles `false` unless the current README requires them.

## 5. One command runs all configured sections

```bash
sudo bash ./debian.sh --apply --config ./image-config.json
```

Type **APPLY** when prompted. After reviewing your JSON, you can skip this initial prompt:

```bash
sudo bash ./debian.sh --apply --config ./image-config.json --yes
```

If you also configured **exact accounts, packages or files that must be removed**, and forensic evidence is preserved, add:

```bash
sudo bash ./debian.sh --apply --config ./image-config.json --yes --allow-removals
```

This is not a blanket cleanup command. Only named targets can be removed; required accounts and services are checked against the JSON. `--yes` skips creation/password reset operations that require entering a secret password; use a run without `--yes` for those prompts.

For a smaller rerun:

```bash
sudo bash ./debian.sh --apply --config ./image-config.json --only users,groups,ssh
```

Available sections: `discovery`, `users`, `groups`, `passwords`, `pam`, `firewall`, `updates`, `services`, `ssh`, `kernel`, `permissions`, `software`, `files`, `persistence`, `hosts`, `desktop`, `browsers`, `apparmor`, `logging`, `serverapps`, `verify`.

## 6. Check results and finish manual tasks

Under `/root/DebianSecurityWork`, inspect the newest:

- `audit-...txt`: basic system audit.
- `changes-...txt`: actions and errors.
- `summary-...tsv`: `CHANGED`, `OK`, `WOULD`, `REVIEW`, `SKIPPED`, `FAILED`.
- `backups-...` folder: saved original files, service state and `review-...txt` investigations.

`CHANGED` means a command ran, not that points were awarded. Reopen the VM Scoring Report, compare with your original score, and work through [MANUAL-TASKS.md](MANUAL-TASKS.md). Verify authorized users, sudo, SSH, UFW, browser, web/FTP/database clients and other required services.

The script does not reboot. Restore only the exact changed file or setting if the score drops or a required service fails. User/file deletion is not automatically reversible.

## Troubleshooting

- **File not found:** In Terminal, check `pwd` and `ls -l ~/Downloads/debian.sh`. If it starts with HTML, download **Raw** again.
- **Configuration error:** Fix the JSON using `nano`; ensure `AuthorizedAdmins` is filled and `ConfirmedReadme` is true only after checking the README.
- **Permissions error:** Run Apply using `sudo`, not from your personal host.
- **SSH/PAM/firewall problem:** Keep console access, inspect the backup and manual guide, and avoid retrying the entire script blindly.

No execution test on a Debian competition image has been performed in this session. Confirm current rules for using external scripts and resources.
