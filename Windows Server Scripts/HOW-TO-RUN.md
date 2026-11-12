# Windows Server — download and run inside the VM

Use [windows-server.ps1](windows-server.ps1) with the [Windows Server handbook](../Windows/windows-server.md). The script works with Windows Server 2016, 2019 and 2022 roles described in the handbook. It does not assume a Domain Controller is the same as a standalone server.

Read the image README and save necessary forensic answers before making changes. The script executes only the configuration you approve, not every example in the handbook.

## 1. Download from GitHub inside the server VM

For a Windows Server **Desktop Experience** image:

1. Start the Windows Server VM and sign in using the assigned Windows administrator account.
2. **Inside the VM**, open an installed browser such as Microsoft Edge or Chrome. Do not run the script on your personal host computer.
3. Go to **https://github.com/login** and sign in if you want to use your GitHub account. Because the repo is public, signing in is optional. Never save a personal GitHub password inside a competition VM.
4. Open **https://github.com/Superdancer16/cyberpatriot2026**, verify the branch is **main**, and open **Windows Server Scripts → windows-server.ps1**.
5. Click **Raw** above the code, then **Ctrl+S** if raw text opens in the browser.
6. Save as **Downloads\windows-server.ps1**. In the Save dialog select **All files**, not Text Documents. Verify in File Explorer that the filename is not `windows-server.ps1.txt` or `.html`.
7. Sign out of GitHub in the VM after downloading, and decline browser offers to remember credentials.

**Server Core has no local browser or GUI.** In that case, transfer the reviewed script to the server using a method permitted by the image/competition administrator. Do not install a browser, disable Internet Explorer Enhanced Security Configuration, or enable remote management solely to download this file.

If internet access or outside resources are disallowed during a scored round, do not use an unapproved download method; follow your coach's guidance.

## 2. Start an Administrator PowerShell window

On Desktop Experience, open **Start → Windows PowerShell → Run as administrator → Yes**. On Server Core, use the authorized console's administrator PowerShell session.

```powershell
cd "$env:USERPROFILE\Downloads"
Get-Item .\windows-server.ps1
Get-Content .\windows-server.ps1 -TotalCount 4
```

Confirm the file is PowerShell source starting with `#requires -Version 5.1`, not HTML. If it is blocked by Windows, verify the origin before using `Unblock-File .\windows-server.ps1`.

To list supported modules without changing settings:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -List
```

## 3. Run the read-only audit first

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -Mode Audit
```

The audit records installed roles, OS/domain role, accounts, firewall, shares, services, recent events and, on Domain Controllers, Active Directory, password policies and replication health. It saves reports under **C:\ProgramData\ServerSecurityWork** (or the VM's corresponding `ProgramData` path).

Open **Server Manager → Local Server**, check whether this is a **StandaloneServer**, **MemberServer** or **DomainController**, and record the original Scoring Report. Do not confuse a domain user's password policy with a member server's local policy.

## 4. Generate the exact image configuration

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -InitConfig -Config ".\server-config.json"
notepad .\server-config.json
```

Notepad may not be present on Server Core; use an approved PowerShell editor or edit the JSON on another authorized management machine and transfer it securely.

**Before Apply can run:**

- Set `ExpectedRole` to the actual detected role (`StandaloneServer`, `MemberServer`, or `DomainController`).
- On a DC set `DomainName` to the exact current AD domain, and populate `AuthorizedDomainAdmins`.
- On a standalone/member server populate `AuthorizedLocalAdmins`; add ordinary authorized users in the appropriate array.
- Fill all relevant `RequiredRoles`, `RequiredServices`, `RequiredShares`, `RequiredApplications`, `RequiredPorts`, and `RequiredServiceAccounts` from the VM README.
- Enter **only exact targets** and values you have confirmed from the README. Avoid general templates, wildcard names, and values copied from another image.
- Once the whole configuration matches the image, set `ConfirmedReadme` and `ConfirmedServerRole` to `true`. Do not set `ForensicsComplete=true` until evidence and questions are saved.

### Config areas and what they do

| JSON section | Supported operations |
|---|---|
| `LocalUsers` and `LocalGroups` | Create named users/groups, manage exact membership, disable/demote/delete confirmed unauthorized local accounts |
| `DomainChanges` | Optional AD user/group changes and domain default password policy, **disabled by default** |
| `LocalPasswordPolicy`, `RemoveUserRights`, `AuditSubcategories` | Exact local account policy, selected rights and configured audit subcategories |
| `Firewall`, `Defender`, `SMB`, `Security` | Security baseline and explicitly chosen Windows Server protections |
| `DisableServices`, `DisableFeatures`, `UninstallWindowsFeatures` | Exact installed targets, with server-critical dependencies protected |
| `RemoveShares`, `RemoveShareAccess`, `RemoveStartupValues`, `ClearAccessibilityDebuggers` | Exact custom share/ACL and persistence changes |
| `IIS`, `DNS`, `DHCP`, `TLS` | Narrow server-role settings with prerequisite checks and backups |
| `RemoveFiles`, `UpdatePrograms`, `UninstallPrograms`, `WindowsUpdate` | Exact files, application IDs, and approved Windows Update actions |
| `DiscoveryPaths` | Limited folders to inspect for suspicious files, without deleting discoveries |

If you need to add a local group, the relevant part of the generated JSON could look like this:

```json
"LocalGroups": {
  "Create": ["EXAMPLE_REQUIRED_GROUP"],
  "Members": {
    "EXAMPLE_REQUIRED_GROUP": ["EXAMPLE_USER_A", "EXAMPLE_USER_B"]
  },
  "RemoveMembers": {}
}
```

Use the actual usernames/group names in the current README. Passwords are requested securely during interactive runs and are **not stored in JSON**.

**Firewall safety:** The Windows Server template deliberately starts with `Firewall.EnableProfiles=false`. Only set it to `true` after verifying required AD/DNS/DHCP/IIS/SMB and remote-management rules and ports. This differs from the workstation template.

For a Domain Controller, `DomainChanges.Allowed` defaults to `false`, and the script also requires `-EnableDomainChanges` before it will attempt AD writes. Even with both enabled, protected AD accounts and privileged groups are intentionally left for manual review.

## 5. Run every configured section in one pass

After reviewing the JSON and completing the initial audit:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -Mode Apply -Config ".\server-config.json"
```

Type **APPLY** at the initial confirmation prompt. After fully reviewing the configuration, you can skip that single confirmation:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -Mode Apply -Config ".\server-config.json" -Yes
```

**Important options**—use only when applicable and specifically authorized:

- `-AllowRemovals`: enables only exact, configured local-user/file/software/share/feature removals, after forensic evidence is preserved.
- `-EnableDomainChanges`: together with `DomainChanges.Allowed=true` and the matching domain, permits supported, explicit AD edits.
- `-AllowCompatibilityChanges`: permits opted-in changes that can disrupt legacy clients, such as NTLM-only policy, SMB1 or older TLS protocols and DNS transfers.
- `-Only localusers,defender,firewall`: reruns only those sections.

Example limited rerun:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -Mode Apply -Config ".\server-config.json" -Only defender,firewall,updates
```

The complete section names are available with `-List`: `localusers`, `localgroups`, `adusers`, `adgroups`, `localpasswords`, `domainpasswords`, `rights`, `auditpolicy`, `security`, `defender`, `firewall`, `smb`, `services`, `features`, `shares`, `iis`, `dns`, `dhcp`, `tls`, `persistence`, `files`, `software`, `updates`, `verify`.

The script skips secret password prompts in `-Yes` mode, refuses blanket account/file removal, and never automatically restarts the server.

## 6. Check results before trying another fix

In File Explorer or an elevated PowerShell session, open:

```powershell
explorer.exe "$env:ProgramData\ServerSecurityWork"
```

On Server Core, use `Get-ChildItem "$env:ProgramData\ServerSecurityWork"` instead.

- `summary-...csv` — changes reported as `CHANGED`, `OK`, `REVIEW`, `SKIPPED`, `WOULD`, or `FAILED`.
- `changes-...txt` — detailed action log.
- `audit-...txt`, `backups-...\audit-before.txt`, `audit-after.txt` — audit status.
- `backups-...\review-before-*.csv` and `review-after-*.csv` — role-specific findings and diagnostics.
- `backups-...` — exports of original service, registry, account, firewall, security policy, IIS, DNS, DHCP and SMB settings where applicable.

**`CHANGED` does not mean points were awarded.** Check the Scoring Report, address failures, then follow [MANUAL-TASKS.md](MANUAL-TASKS.md). Test required domain login, DNS, DHCP, IIS, FTP, SMB, RDP/WinRM, required databases and server roles with real clients.

### Troubleshooting

- **Wrong image:** The script refuses Windows workstation systems. Fix `ExpectedRole`/`DomainName` only after checking the actual VM.
- **Script downloaded as HTML or TXT:** Return to the file's **Raw** GitHub view and save with **All files** selected.
- **Cannot change Active Directory:** Domain changes require the DC role, exact domain, `DomainChanges.Allowed=true` and `-EnableDomainChanges`.
- **Domain/local policy not applying:** A GPO or fine-grained policy may override local settings. Inspect the effective source in the Windows Server handbook.
- **Required service broke:** Use the stored original values and follow role-specific recovery procedures. Never remove AD DS, DNS, DHCP or a required server role to chase generic hardening points.

No execution on a real competition Server image was performed while authoring this file. Review results and test the code on an authorized disposable server VM before scored use.
