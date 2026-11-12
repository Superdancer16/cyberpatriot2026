# Manual tasks and checks after the one-run script

The [one-run PowerShell script](windows-10-11.ps1) processes all configured sections automatically. These tasks still require human judgement, a prompt for a secret, or an application-specific interface. The **README and scoring report always override generic hardening advice**.

## Before running

- [ ] Read the image README and confirm authorized users/admins, services, groups, software, file shares, and any prohibited items. [Before changing anything](../Windows/windows-10-11.md#0-before-you-touch-anything).
- [ ] Complete/preserve forensic answers before modifying user accounts, files or suspicious executables. [Forensics](../Windows/windows-10-11.md#1-forensics-questions-first).
- [ ] Record initial score and recovery access. If permitted, create a checkpoint. [Initial steps](../Windows/windows-10-11.md#0-before-you-touch-anything).

## Accounts and policies

| Needs manual judgement | Why | Full guide |
|---|---|---|
| Authorized local account passwords, new-user passwords | The unattended run refuses to store passwords in JSON; run without `-Yes` for secure prompts or set them in the GUI | [Users and groups](../Windows/windows-10-11.md#2-users-and-groups) |
| Confirm exact authorized users and administrator membership | Account names and service-account exceptions come from the active image README, not an inventory alone | [Account review](../Windows/windows-10-11.md#2-users-and-groups) |
| Confirm required group membership | Script creates only the `Groups` entries in JSON; verify every member visually | [Create group](../Windows/windows-10-11.md#29-create-a-required-custom-local-group) · [Add members](../Windows/windows-10-11.md#210-add-the-specified-users-to-the-required-group) |
| Verify password/lockout values and effective GPO | An imported local value may be overridden by domain policy; numeric requirements vary by image | [Password Policy](../Windows/windows-10-11.md#31-password-policy) · [Account Lockout](../Windows/windows-10-11.md#32-account-lockout-policy) |
| User-rights assignment and granular audit policy | Removing the wrong privilege can break service accounts; the script only handles Credential Validation success auditing automatically | [User Rights](../Windows/windows-10-11.md#42-user-rights-assignment) · [Audit Policy](../Windows/windows-10-11.md#41-audit-policy-record-security-events) |

## Applications, services and threats

| Needs manual judgement | Why | Full guide |
|---|---|---|
| Confirm Chrome, Notepad++, Edge and Firefox versions, install paths, default browser and site exceptions | `winget` cannot safely identify every vendor build or required user profile; browser policies may be managed elsewhere | [Application updates](../Windows/windows-10-11.md#73-update-the-other-programs) · [Browsers](../Windows/windows-10-11.md#16-web-browsers) |
| Inspect Windows Update and pending restarts | The default JSON scans; `WindowsUpdate: Install` may install unattended updates, but the script never reboots or resolves every compatibility prompt | [Windows Update](../Windows/windows-10-11.md#7-windows-update) |
| Verify Defender exclusions, detection history, third-party antivirus and compatibility | A named exclusion can be removed, but the script cannot determine every legitimate exception or malware verdict | [Defender](../Windows/windows-10-11.md#5-microsoft-defender-antivirus) |
| Check inbound firewall rules and actual connectivity | Enabling profiles is not enough to prove a server/client works or that an allow rule is unwanted | [Firewall](../Windows/windows-10-11.md#6-firewall) · [Rule inspection](../Windows/windows-10-11.md#62-check-the-inbound-rules) |
| Validate Windows services, remote access, IIS/FTP/printing and SSH/WinRM dependencies | High-impact services are deliberately not auto-disabled even if listed; preserve critical services and admin connection | [Services](../Windows/windows-10-11.md#8-services) · [Remote access](../Windows/windows-10-11.md#10-remote-access) · [Critical services](../Windows/windows-10-11.md#17-critical-services) |
| Inspect scheduled tasks, unusual startup commands and backdoors | Script only disables exact scheduled tasks listed in JSON; unknown programs need path/signature/process/forensic investigation | [Backdoors](../Windows/windows-10-11.md#14-backdoors-and-malware) · [Scheduled tasks](../Windows/windows-10-11.md#142-scheduled-tasks) |
| Decide on prohibited archives, media, portable tools and applications | Removes only exact JSON paths/IDs with `-AllowRemovals`; it will not discover, purge or execute suspect files automatically | [Prohibited software](../Windows/windows-10-11.md#12-prohibited-software) · [Prohibited files](../Windows/windows-10-11.md#13-prohibited-files) |
| Validate SMB signing/SMB1, shares and NTFS permissions | Required file sharing may depend on legacy clients; backup/share ACLs need targeted inspection | [Shared folders](../Windows/windows-10-11.md#11-shared-folders) · [SMB and NTFS](../Windows/windows-10-11.md#197-smb-share-permissions-and-ntfs-permissions) |
| Check screen locking, UAC, PrintNightmare, NetBIOS and other system-specific settings | User-specific policies and driver/legacy compatibility require an accurate Windows version and local context | [Other settings](../Windows/windows-10-11.md#15-other-settings) · [Print spooler](../Windows/windows-10-11.md#83-printer-drivers-printnightmare-fixes) |

## After the script

Open the latest `summary-...csv`, `changes-...txt`, and before/after audits in **Documents → WindowsSecurityWork**. Work through all `REVIEW`/`FAILED` items. Check the image score, and verify that approved administrator logins, required browsers, websites, shares, services, networking and applications still function. Revert only the last confirmed bad change using recorded values; do not guess a rollback or restore a whole VM without checking competition rules. [Final checklist](../Windows/windows-10-11.md#18-final-checks).
