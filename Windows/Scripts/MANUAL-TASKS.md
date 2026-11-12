# Windows 10/11 — tasks to finish after the script

Use this after [windows-10-11.ps1](windows-10-11.ps1). The script can apply configured changes and generate investigation reports, but it cannot decide what is authorized or what earns points on the current image. **Follow the image README and the Scoring Report, not a generic list.**

**Manual** means the script cannot finish that decision or action reliably. **Verify** means the script may have attempted it, but you still need to confirm the result. Do only the tasks that apply to your image.

## 1. Before running any fixes

- [ ] **Read the image README.** Write down authorized users/admins, required local groups and members, critical services, required software, network ports and any prohibited items. If a service account or application is required, protect it even if its name looks unusual. [Start here](../windows-10-11.md#0-before-you-touch-anything).
- [ ] **Preserve forensic answers and evidence before removing anything.** This checklist does not cover solving the forensic questions. [Forensics guide](../windows-10-11.md#1-forensics-questions-first).
- [ ] **Keep administrator access.** Test an authorized admin login, record the original score, and preserve the VM console/recovery method. Only make snapshots if round rules allow them.

## 2. Find the script's unfinished work

1. In the VM, open **File Explorer → Documents → WindowsSecurityWork** (under the Windows account that ran the script).
2. Open the newest `summary-*.csv` and `changes-*.txt`. Address **FAILED** first, then **REVIEW** and **SKIPPED**. **CHANGED** does not mean points were awarded.
3. Open that run's `backups-*` folder and its `review-*.csv` reports. These are **inspection leads**, not confirmed vulnerabilities. Different runs produce different timestamps.
4. Open the desktop **Scoring Report** and compare the current score with the number you recorded before the run. Investigate score drops before doing unrelated changes.

**Do not rerun the entire script blindly.** For a specific failure, use the relevant GUI steps below. For the download and configuration instructions, see [HOW-TO-RUN.md](HOW-TO-RUN.md).

## 3. Users, administrators and groups

### Accounts and passwords

- [ ] **Manual — create a required user that was skipped in `-Yes` mode:** **Win + R → `lusrmgr.msc` → Users → Action → New User**. Enter the exact README-required username, set a secure password, then check its account type. If the user must be an administrator, open **Groups → Administrators → Add** and add only that account. **Verify:** Reopen Users/Administrators and test a permitted login. [Create users](../windows-10-11.md#23-create-users-the-readme-says-should-exist).
- [ ] **Manual — reset a required user's password if the script marked it REVIEW:** **`lusrmgr.msc` → Users → right-click the exact authorized user → Set Password**. Confirm the new password and test an authorized fresh login. Don't change an unknown service account or store a password in JSON. [Passwords](../windows-10-11.md#28-give-users-strong-passwords).
- [ ] **Verify — unauthorized accounts and admin rights:** **`lusrmgr.msc` → Users**; compare each human account to the README. Under **Groups → Administrators**, verify that only approved admins remain. An authorized standard user should **still exist** but no longer be an administrator. If a task specifically requires *removal*, merely disabling the account may not satisfy it. Never remove your only working admin. [Users](../windows-10-11.md#2-users-and-groups).
- [ ] **Verify — Guest and password flags:** In **Users**, open **Guest → Properties** and confirm it is disabled when required. For each specified ordinary user, open **Properties** and verify **Password never expires** is unchecked when expiration is required. Leave system/required service accounts alone. [Guest](../windows-10-11.md#26-disable-the-guest-account-and-the-other-built-ins) · [Password flags](../windows-10-11.md#27-fix-weak-password-settings-on-accounts).

### Custom groups — two separate checks

- [ ] **Verify — group was created:** **Win + R → `lusrmgr.msc` → Groups**. Confirm the exact README group name exists. If missing, select **Action → New Group**, enter that name, then **Create → Close**. [Create a group](../windows-10-11.md#29-create-a-required-custom-local-group).
- [ ] **Verify — all required members were added:** Double-click the group → **Members**. Compare members one by one with the README. If anyone is missing, **Add → enter usernames → Check Names → OK**. Remove only a confirmed unauthorized member. Group creation and membership are **different scoring tasks** when the image requires both. [Add group members](../windows-10-11.md#210-add-the-specified-users-to-the-required-group).

## 4. Password, audit and security policies

- [ ] **Verify — password policy:** **Win + R → `secpol.msc` → Account Policies → Password Policy**. Check **minimum length**, **complexity**, **password history**, **minimum/maximum age**, and **reversible encryption** against the README. Double-click a wrong setting → change it → **Apply → OK**, then reopen to verify. Do **not** use a fixed example such as 12 characters or 24 remembered passwords unless required. [Password Policy](../windows-10-11.md#31-password-policy).
- [ ] **Verify — account lockout:** In **`secpol.msc` → Account Policies → Account Lockout Policy**, check the **threshold**, **duration**, and **reset counter**. Match the image requirement and preserve another working admin login. A duration of `0` may require manual administrator unlock. [Account Lockout](../windows-10-11.md#32-account-lockout-policy).
- [ ] **Manual / verify — audit policies:** **`secpol.msc` → Advanced Audit Policy Configuration → System Audit Policies**. Check the required subcategories and **Success/Failure** selections, including Credential Validation if specified. The script can apply configured subcategories, but you must check effective values and any inherited Group Policy. Don't turn on every high-volume audit blindly. [Audit Policy](../windows-10-11.md#41-audit-policy-record-security-events).
- [ ] **Manual / verify — user rights:** **`secpol.msc` → Local Policies → User Rights Assignment**. Inspect **Manage auditing and security log**, **Take ownership**, and any other specified right. The script handles only selected named removals; review all other rights here. Remove only the exact unauthorized principal; keep necessary built-in/service rights. [User Rights Assignment](../windows-10-11.md#42-user-rights-assignment).
- [ ] **Verify — other security options:** **`secpol.msc` → Local Policies → Security Options**. Check SMB client signing, blank-password network limits, last signed-in account display, and any README-specific network/NTLM settings. Separately inspect UAC, SmartScreen, PowerShell logging, and administrator enumeration if required. Reopen settings after applying them; compatibility or domain policy may override local changes. [Security Options](../windows-10-11.md#43-security-options) · [Other settings](../windows-10-11.md#15-other-settings).

## 5. Defender, firewall and updates

- [ ] **Verify — Microsoft Defender:** **Start → Windows Security → Virus & threat protection → Manage settings**. Confirm real-time protection, cloud protection and required reputation/PUA settings. Open **Exclusions** and check path, process and extension exceptions; remove only confirmed unwanted ones. Review **Protection history** after scanning to make sure required files were not quarantined. [Defender](../windows-10-11.md#5-microsoft-defender-antivirus).
- [ ] **Verify — firewall profiles:** **Windows Security → Firewall & network protection**. Confirm the required **Domain, Private and Public** profiles are enabled. Then **Win + R → `wf.msc` → Inbound Rules**; inspect suspicious enabled Allow rules from the script's `review-inbound-firewall-allow.csv`. Disable a rule only after checking its executable, local port and README requirements. Test required network connections afterward. [Firewall rules](../windows-10-11.md#62-check-the-inbound-rules).
- [ ] **Verify — Windows Update:** **Settings → Windows Update → Check for updates**. Complete only approved updates, review failed/pending installations and reboot requirements. The script can scan or install supported updates, but does **not** force a reboot. [Windows Update](../windows-10-11.md#7-windows-update).
- [ ] **Manual — application updates:** Open each **README-required application** (for example, Chrome or Notepad++) → its **Help / About / Check for Updates** menu. Install approved publisher updates, then verify the version, original/default install directory, and that the application still launches. `winget` cannot guarantee every required vendor version or location. [Application updates](../windows-10-11.md#73-update-the-other-programs).

## 6. Services, remote access and optional features

- [ ] **Manual / verify — critical services:** **Win + R → `services.msc`**. Look up each README-required service and record **Status**, **Startup type**, and **Dependencies**. The script intentionally leaves potentially high-impact services (such as RDP, WinRM, IIS, FTP, Print Spooler and SSH) for review. Do not disable one just because a general hardening list says it is risky. Confirm required functionality still works. [Services](../windows-10-11.md#8-services) · [Critical services](../windows-10-11.md#17-critical-services).
- [ ] **Verify — RDP and Remote Assistance:** **Win + R → `SystemPropertiesRemote`** and **Settings → System → Remote Desktop**. If RDP is required, preserve it, verify authorized users and Network Level Authentication, then test a legitimate remote connection. If not required, confirm it is disabled. Don't cut off your only remote session. [Remote access](../windows-10-11.md#10-remote-access).
- [ ] **Verify — optional Windows features:** **Win + R → `optionalfeatures`**. Check unnecessary legacy components (such as SMBv1) only when the README allows removing them; confirm required file sharing and applications still work. [Windows features](../windows-10-11.md#9-windows-features).
- [ ] **Verify — print-driver restrictions and desktop settings:** If required, check **`gpedit.msc` → Computer Configuration → Administrative Templates → Printers** for Point and Print restrictions. Confirm any required screen lock, AutoPlay, NetBIOS and UAC settings in their actual Windows UI. Test printing and sign-in after changes. [Print restrictions](../windows-10-11.md#83-printer-drivers-printnightmare-fixes) · [Other settings](../windows-10-11.md#15-other-settings).

## 7. Software, files and persistence

- [ ] **Manual — prohibited installed apps:** **Settings → Apps → Installed apps** or **Win + R → `appwiz.cpl`**. Compare every suspect product to the README. Remove only confirmed prohibited programs; verify the intended program is absent and required applications remain. Also check Microsoft Store apps where applicable. [Prohibited software](../windows-10-11.md#12-prohibited-software).
- [ ] **Manual — prohibited files and portable tools:** **File Explorer → Downloads, Desktop, Public folders and other README-specified locations**. The script's `review-suspicious-file-candidates.csv` lists candidates; it does **not** establish that a ZIP, media file, `.exe`, or password list is prohibited. Confirm the exact path and preserve any necessary evidence before removal. [Prohibited files](../windows-10-11.md#13-prohibited-files) · [Portable tools](../windows-10-11.md#123-portable-tools-that-arent-installed).
- [ ] **Manual — scheduled tasks and startup entries:** **Win + R → `taskschd.msc` → Task Scheduler Library**; inspect **Actions** and **Triggers** for unknown tasks. Check **Task Manager → Startup apps** and the script's `review-startup-registry.csv`. The script can disable only exact task/registry entries supplied in JSON. Unknown names alone are not proof of malware. [Startup](../windows-10-11.md#141-programs-that-start-at-logon) · [Scheduled tasks](../windows-10-11.md#142-scheduled-tasks).
- [ ] **Manual — suspicious services, listeners and debugger overrides:** Review `review-services-and-paths.csv`, `review-listening-processes.csv` and `review-ifeo-debuggers.csv`. Use **Task Manager → Details / Open file location** and **`services.msc`** to check the real executable, owner, path and dependency. Do not kill a process by a PID copied from another image or delete Windows accessibility binaries. [Backdoors](../windows-10-11.md#14-backdoors-and-malware).
- [ ] **Manual — hosts file:** Review `review-hosts-file.csv`. If the README confirms an unwanted mapping, open **Notepad as administrator → File → Open → `C:\Windows\System32\drivers\etc\hosts`** (select **All Files**) and modify only that entry after saving a backup. Verify required name resolution afterward. [Hosts file](../windows-10-11.md#145-the-hosts-file).

## 8. Browsers, shares and access

- [ ] **Verify — browser security:** Open **Edge, Chrome and Firefox** if installed/required. In each browser's **Settings → Privacy/Security / Site settings**, verify pop-up and redirect blocking, Safe Browsing/SmartScreen and required extensions. These are often **per-browser or per-user** settings; the script's limited Chrome/Edge popup policies do not replace a full browser check. [Web browsers](../windows-10-11.md#16-web-browsers).
- [ ] **Verify — shares and permissions:** **Win + R → `fsmgmt.msc` → Shares**. Confirm required shares still exist and prohibited custom shares are gone. For required shares, inspect **Properties → Share Permissions**, then open the backing folder in File Explorer → **Properties → Security** to check NTFS permissions. The script can revoke exact share accounts but **does not reconcile all NTFS ACLs**. Test access with an authorized user; do not remove standard `ADMIN$`, `C$`, or `IPC$` shares solely because of `$`. [Shared folders](../windows-10-11.md#11-shared-folders) · [SMB and NTFS](../windows-10-11.md#197-smb-share-permissions-and-ntfs-permissions).

## 9. Final verification

- [ ] All authorized admins/users can sign in and required custom groups/memberships are correct.
- [ ] Password, lockout, audit, user rights, Defender and firewall settings match the README and are still effective.
- [ ] Required apps, browsers, services, remote access, printers, file shares and networking still function.
- [ ] All **FAILED** results have been investigated; **REVIEW** and **SKIPPED** items have a decision recorded.
- [ ] The latest Scoring Report shows no new penalties. Save any required answers and reboot only if necessary and permitted. [Final checklist](../windows-10-11.md#18-final-checks).

**Recovery:** Refer to the original settings saved in the run's `backups-*` folder and the [Windows recovery procedures](../windows-10-11.md#19-manual-verification-recovery-and-missing-investigation-steps). The script does not provide a one-click undo; account/file deletion may not be reversible.

**Scope:** Windows 10/11 workstations. The script has not been runtime-tested on a Windows VM in this session. Some GUI tools are unavailable on Windows Home; the handbook provides alternatives where applicable.
