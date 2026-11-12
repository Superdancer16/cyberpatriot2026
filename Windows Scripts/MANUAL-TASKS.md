# Checks the script cannot decide for you

The [one-run script](windows-10-11.ps1) now automates more settings and produces detailed inventory files. It **does not identify which vulnerability earns points** on your image. Use the actual README, scoring report, and [Windows 10/11 handbook](../Windows/windows-10-11.md) to make the final decisions.

## Before any fixes

- [ ] Read the current image README and list **authorized users/admins, required services, software, groups, shares and ports**. [First steps](../Windows/windows-10-11.md#0-before-you-touch-anything)
- [ ] Answer or preserve all required forensic evidence **before deleting users, files or software**. [Forensics](../Windows/windows-10-11.md#1-forensics-questions-first)
- [ ] Record the original score, test a working administrator account and keep console/recovery access. Snapshots are only for rounds where the rules permit them.

## What the updated script can do

| Type | Automated only when configured | Still check afterward |
|---|---|---|
| Accounts | Guest, exact users/groups/memberships, password-expiration flags, authorized password resets with a prompt | Required users remain, correct administrator group and actual login work |
| Policies | Local password/lockout, selected user rights, audit subcategories, UAC, network security and logging | The image's intended effective values and domain GPO precedence |
| Firewall/SMB | Enable firewall, disable exact unwanted inbound Allow rules, SMB signing, optional SMBv1 | Required ports, clients, shares and actual network traffic |
| Defender | Real-time/PUA, updates, exact exclusions, optional quick scan after forensics | Whether exclusions are legitimate and anything was quarantined |
| Services/features | Disable exact unneeded services/features, check critical services | IIS, FTP, print, SSH, RDP and other dependencies |
| Startup threats | Inventory startup keys/tasks/IFEO, remove explicitly named Run values and debugger overrides | Whether a binary, task or listener is truly malicious |
| Apps/files | Inspect Store apps/programs/file candidates; remove exact IDs/paths with `-AllowRemovals` | No required app or data was lost |
| Sharing | Remove exact custom share or share account permission with `-AllowRemovals` | Both share and NTFS permissions, authorized user access |

## Tasks requiring a human decision

| Task | Why it stays manual or partially manual | Full handbook |
|---|---|---|
| **Determine who is authorized** | A username absent from the README may still be a required service identity; never guess | [Users and groups](../Windows/windows-10-11.md#2-users-and-groups) |
| **Create accounts or reset passwords in a `-Yes` run** | The script refuses to store plaintext passwords; rerun without `-Yes` for secure prompts | [Create users](../Windows/windows-10-11.md#23-create-users-the-readme-says-should-exist) · [Passwords](../Windows/windows-10-11.md#28-give-users-strong-passwords) |
| **Confirm requested group memberships** | A JSON group list creates exactly those members, not an inferred membership | [Create groups](../Windows/windows-10-11.md#29-create-a-required-custom-local-group) · [Add members](../Windows/windows-10-11.md#210-add-the-specified-users-to-the-required-group) |
| **Check effective policies and advanced rights** | Local policy may be overridden; only named, supported privileges are changed | [Password and lockout](../Windows/windows-10-11.md#3-account-policies-passwords-and-lockout) · [Rights](../Windows/windows-10-11.md#42-user-rights-assignment) |
| **Assess unknown firewall rules** | Script saves inbound-Allow inventory but disables only exact rule names in the JSON | [Firewall rules](../Windows/windows-10-11.md#62-check-the-inbound-rules) · [Advanced verification](../Windows/windows-10-11.md#195-firewall-rule-inspection-and-required-ports) |
| **Assess suspicious network listeners** | An open port or unusual executable path alone does not establish a backdoor | [Backdoors and malware](../Windows/windows-10-11.md#14-backdoors-and-malware) · [Service checks](../Windows/windows-10-11.md#143-services-that-run-strange-programs) |
| **Inspect the hosts file** | The script exports hosts entries but does not automatically delete them | [Hosts file](../Windows/windows-10-11.md#145-the-hosts-file) |
| **Verify app and browser updates** | `winget` and browser policies cannot guarantee a compatible app version or its location | [Application updates](../Windows/windows-10-11.md#73-update-the-other-programs) · [Browsers](../Windows/windows-10-11.md#16-web-browsers) |
| **Review Store apps and prohibited content** | Scan reports are candidates, not a definitive scoring list; removals require confirmed IDs/paths | [Prohibited software](../Windows/windows-10-11.md#12-prohibited-software) · [Prohibited files](../Windows/windows-10-11.md#13-prohibited-files) |
| **Check Defender findings** | A scan may quarantine useful evidence; review its detection history and legitimate exclusions | [Defender](../Windows/windows-10-11.md#5-microsoft-defender-antivirus) |
| **Verify printer/RDP/security compatibility** | Tightening NTLM, UAC, driver restrictions or remote logon may break legitimate applications | [Remote access](../Windows/windows-10-11.md#10-remote-access) · [Print driver restrictions](../Windows/windows-10-11.md#83-printer-drivers-printnightmare-fixes) |
| **Validate SMB and NTFS permissions** | Share-level access is not the same as underlying folder ACLs | [Shares](../Windows/windows-10-11.md#11-shared-folders) · [SMB and NTFS](../Windows/windows-10-11.md#197-smb-share-permissions-and-ntfs-permissions) |
| **Recover accidental changes** | Registry/policy backups support targeted restoration, but deleted files and users may be unrecoverable | [Recovery](../Windows/windows-10-11.md#19-manual-verification-recovery-and-missing-investigation-steps) |

## After the full run

1. Open **Documents → WindowsSecurityWork** and inspect the most recent `summary-...csv`, `changes-...txt`, `audit-...txt`, and `backups-.../review-...csv` files. `REVIEW` and `FAILED` need human attention.
2. Open the **Scoring Report**, compare to the original score, and double-check every change that may have broken a required service.
3. Verify all authorized users can log in, required browsers/apps remain, and network access, printing, shares and approved remote access still work. Use the [final checklist](../Windows/windows-10-11.md#18-final-checks).

The script does not reboot automatically, does not guarantee points, and has not been tested in a Windows VM in this session.
