# 🖥️ Windows Server script — beginner's step-by-step guide

**New to Windows Server or PowerShell? Follow Part A first.** This guide walks through downloading, inspecting, and running the [Windows Server script](windows-server.ps1) in an authorized **Windows Server 2016 / 2019 / 2022 virtual machine (VM)**. For a normal Windows 10/11 computer, use the [Windows workstation guide](../../Windows/Scripts/HOW-TO-RUN.md) instead.

> [!IMPORTANT]
> **Only work INSIDE the assigned VM, not on your personal computer.** Follow its desktop README, authorized accounts/required services, and current competition rules. If downloads or automated changes are prohibited, do **not** run this tool.
>
> **Part A (Audit) checks and records settings without applying hardening fixes. Part B (Apply) can change the server.** On a Domain Controller, careless changes can break logins, DNS, DHCP, Group Policy, and other machines. **Do not proceed with Apply if you are unsure of the server role or required services.**

## Five terms to know

| Term | Meaning |
|---|---|
| **VM** | The virtual Windows Server computer inside VMware or other VM software |
| **PowerShell** | A Windows command window where you paste and run commands |
| **`windows-server.ps1`** | The PowerShell script file you will download |
| **Audit** | Inspect the server and save a report; do not apply configured fixes |
| **Apply / config** | Run changes chosen in a separate JSON text file (`server-config.json`) |
| **Server role** | What the machine does: `StandaloneServer`, `MemberServer`, or `DomainController` |

**How to use commands:** Copy one line from each code block, paste it into **Windows PowerShell**, and press **Enter**. Do not type the `PS C:\...>` prompt that the terminal displays.

## ✅ Part A — Safe first run: download → check → AUDIT

### Step 1 — Make sure you are using the server VM

1. Open your assigned **Windows Server VM**. Sign in using its authorized administrator account.
2. Read its **desktop README**. Make a list of services and roles that must work: for example, **Active Directory (AD), DNS, DHCP, IIS, file sharing, and remote login**. Only include those actually required by *this* image.
3. Save/answer required forensic questions before changing accounts, logs, files, or services; note your starting Scoring Report.
4. Keep console access available. Only use a snapshot or other recovery method if the exercise rules allow it.
5. **If you are on Server Core** (no ordinary desktop or local browser), skip the browser steps below: use a **coach-approved method** to transfer the reviewed script into that VM, then use its authorized PowerShell console. Do not install a browser, open remote-management ports, or weaken security just to fetch the file.

### Step 2 — Download the script (Desktop Experience only)

1. **Inside the Server VM**, open an installed browser (Edge, Chrome, etc.). This public repository does **not** require you to sign into GitHub.
2. Open [windows-server.ps1 on GitHub](https://github.com/Superdancer16/cyberpatriot2026/blob/main/Server/Scripts/windows-server.ps1).
3. Click **Raw** above the code. It should display plain text, starting with `#requires -Version 5.1`.
4. Press **Ctrl+S** to save that raw text. Choose **Downloads**, set **Save as type → All files** if shown, and save as **`windows-server.ps1`**. Some browsers also support right-clicking **Raw → Save link as**.
5. If you cannot find the file, press **Ctrl+J** in the browser and choose **Show in folder**. In **File Explorer → Downloads**, turn on file extensions: on Server 2022 use **View → Show → File name extensions**; on older Server desktops use the **View** ribbon's **File name extensions** checkbox. Check the name is exactly **`windows-server.ps1`** (not `.ps1.txt` or `.html`).
6. Sign out of GitHub if you signed in; do not save your personal credentials inside a competition VM.

> [!CAUTION]
> A GitHub webpage saved as `.html` is **not** a PowerShell script. Do not rename HTML to `.ps1`; repeat the Raw download. Use an approved transfer method when external browsing is not allowed.

### Step 3 — Open PowerShell as Administrator

1. **On the Server VM**, click **Start** and search for **Windows PowerShell**.
2. Right-click **Windows PowerShell** → **Run as administrator** → **Yes**.
3. A command window appears. It may start with `PS C:\Windows\system32>`; that is normal. Use the built-in **Windows PowerShell 5.1**.
4. If using **Server Core**, use its existing authorized administrator PowerShell session. Have an experienced teammate help with file transfer or editing if necessary; you can stop after Audit.

### Step 4 — Find the downloaded file

If you saved the file in **Downloads**, run:

~~~powershell
cd "$env:USERPROFILE\Downloads"
~~~

Verify your current folder:

~~~powershell
Get-Location
~~~

**Expected:** A folder ending in `\Downloads`. Now check the file:

~~~powershell
Get-Item .\windows-server.ps1
~~~

**Expected:** Information about the script's name, length and date. Show the first line:

~~~powershell
Get-Content .\windows-server.ps1 -TotalCount 1
~~~

**Expected:** `#requires -Version 5.1`. If PowerShell says **Cannot find path**, use File Explorer to find the actual download location and correct filename. If the first line contains HTML, repeat Step 2.

If Server Core or your approved transfer placed the script **somewhere else**, use the actual folder containing it instead of the Downloads command above. All later commands assume your PowerShell window is in that folder.

### Step 5 — Run the read-only AUDIT

Copy this line exactly:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -Mode Audit
~~~

Press **Enter**. The script identifies whether the VM is a **StandaloneServer**, **MemberServer**, or **DomainController**, and inspects installed roles, users, networking, security policies, and services.

**Expected:** The terminal shows audit information and report results, not a request to apply all hardening. It may mention missing features when a role isn't installed; that is not a reason to install it. Audit creates report/log files but **does not apply hardening changes**.

### Step 6 — Open and read the audit results

On a Server VM **with a desktop**, paste:

~~~powershell
explorer.exe "$env:ProgramData\ServerSecurityWork"
~~~

On **Server Core** (or when Explorer is unavailable), list the files instead:

~~~powershell
Get-ChildItem "$env:ProgramData\ServerSecurityWork"
~~~

Look for the newest `audit-...txt`, `summary-...csv`, and `changes-...txt` files. In Desktop Experience, double-click a text report to inspect it. On Server Core, an administrator can use `Get-Content` with the exact file path listed.

**Check the detected server role** in the report and compare its findings with your VM README. Do not assume a role should be removed just because it looks unusual.

**🎉 Audit completed. It is completely fine to stop here.** Use the [manual tasks](MANUAL-TASKS.md) and the [full Server handbook](../windows-server.md) to review findings one at a time.

---

## ⚠️ Part B — Only with a reviewed configuration: APPLY

**This part can change your VM.** Stop if you cannot identify the server's role, its required services, its users, or its current recovery/console path. On a Domain Controller, ask someone familiar with Active Directory to review the configuration.

### Step 7 — Find out what kind of server you have

The script reports the detected role during Audit. You can also use **Server Manager → Local Server** when a desktop is available. To view computer/domain details in PowerShell:

~~~powershell
Get-CimInstance Win32_ComputerSystem | Select-Object Domain,PartOfDomain,DomainRole
~~~

- **StandaloneServer**: Server not joined to a domain and not a Domain Controller.
- **MemberServer**: Server joined to a domain but **not** a Domain Controller.
- **DomainController**: Runs AD DS and manages a domain; needs extra care.

**Not sure which one you have? Do not run Apply.** Ask a coach or mentor to confirm the role and the domain name.

### Step 8 — Create the JSON configuration file (once)

Back in the same PowerShell folder containing `windows-server.ps1`:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -InitConfig -Config ".\server-config.json"
~~~

**Expected:** A new file named `server-config.json` appears. The script will **not overwrite** a file that already exists.

On Desktop Experience, open it:

~~~powershell
notepad .\server-config.json
~~~

**Server Core note:** Notepad may not be installed. Use an approved text editor or have an experienced teammate edit the JSON on an authorized management computer and transfer it securely. Do **not** install extra software on the VM just for this step.

### Step 9 — Fill out the important JSON fields

In Notepad, look for the existing fields below; **edit their values in the generated file** rather than pasting these fragments in again.

~~~json
"ConfirmedReadme": false,
"ConfirmedServerRole": false,
"ForensicsComplete": false,
"ExpectedRole": "StandaloneServer",
"DomainName": "",
"AuthorizedLocalAdmins": [],
"AuthorizedDomainAdmins": []
~~~

What these mean:

1. **`ExpectedRole`:** Set to the **exact role detected in the audit**: `StandaloneServer`, `MemberServer`, or `DomainController`.
2. **`DomainName`:** On a Domain Controller, fill in the exact domain name found by the script (do not guess it).
3. **`AuthorizedLocalAdmins`:** List actual authorized local administrators on standalone/member servers. This list **cannot be empty** for those roles.
4. **`AuthorizedDomainAdmins`:** List actual authorized domain administrators on a Domain Controller. This list **cannot be empty** on a DC.
5. **`AuthorizedLocalUsers` and `AuthorizedDomainUsers`:** Use only the appropriate lists of authorized non-admin users for your VM.
6. **`RequiredRoles`, `RequiredServices`, `RequiredShares`, `RequiredApplications`, `RequiredPorts` and `RequiredServiceAccounts`:** Identify what **must not be broken**.
7. **`ForensicsComplete`:** Set to `true` only after necessary evidence and answers are saved.
8. **`ConfirmedReadme` and `ConfirmedServerRole`:** Set to `true` **last**, only after the entire configuration has been checked against the VM README and actual detected role.

**JSON basics:** `[]` is a list (e.g., `["USER_A", "USER_B"]`); quotes around names are required; commas separate entries; `true`/`false` are lowercase and **not quoted**. The example names in this explanation are placeholders, **never real accounts to create or remove**. Don't put passwords in the file.

> [!WARNING]
> The generated template has **some enabled defaults**, including Defender-related options. **Firewall.EnableProfiles is false initially** because enabling a server firewall without checking role-specific ports could lock you out. Review **every section** (Firewall, Defender, SMB, Security, LocalUsers, DomainChanges, services, shares, roles, etc.), not only the fields above. Do not enable or remove a feature just to seek points.
>
> On Domain Controllers, `DomainChanges.Allowed` defaults to `false` and AD modifications also require a separate command option. Leave these protections in place unless an experienced, authorized teammate has reviewed the exact changes.

Save the file with **Ctrl+S** and close Notepad.


#### Step 9A — Identify server role and real names first

**Never guess Domain Controller versus member server.** The [Server handbook](../windows-server.md) explains the differences. Use the VM README and the audit report, then run these *inspection commands* in elevated Windows PowerShell:

~~~powershell
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain,DomainRole
Get-WindowsFeature | Where-Object Installed | Select-Object Name,DisplayName
Get-Service | Select-Object Name,DisplayName,Status | Sort-Object Name
Get-SmbShare | Select-Object Name,Path
Get-NetTCPConnection -State Listen | Select-Object LocalPort,OwningProcess
~~~

- **Role:** The script detects `StandaloneServer`, `MemberServer`, or `DomainController` during Audit; enter that **exact string** in `ExpectedRole`. `DomainRole` codes from Windows are clues, but use the script's actual detected role.
- **`RequiredRoles`:** Prefer the exact installed Windows role/feature `Name` (e.g. `Web-Server`, `AD-Domain-Services`, `DNS`, `DHCP`). The script also recognizes `IIS` in its IIS-specific checks. Don't assume a role is required just because it is installed.
- **`RequiredServices`:** Use actual service `Name` strings (e.g. `W3SVC` for IIS, `DNS`, `DHCPServer`, `TermService` for RDP), not `DisplayName`.
- **`RequiredPorts`:** Enter ports used by services that **must stay accessible**, for example `"80/tcp"` for a required HTTP site or `"3389/tcp"` for required RDP. A port being open is not enough evidence that it is needed.
- **Domain Controller:** An AD domain is **not the same** as a local Windows user database. Never put an invented domain or OU into a real configuration.

#### Step 9B — Every top-level JSON field

**Type guide:** `[]` = array; `{}` = object of settings; `true`/`false` = Boolean. Fields ending in a plural name usually hold arrays of **exact names**, not instructions or PowerShell commands. Leave unknown actions empty or false.

**1. Confirmations, accounts, and protected roles**

| Field | Exactly what belongs there |
|---|---|
| `ConfirmedReadme` | `false` until the VM README and all required accounts/services have been reviewed. Then `true` **last**. |
| `ConfirmedServerRole` | `false` until you have verified the script-detected role. Set `true` only after matching `ExpectedRole`. |
| `ForensicsComplete` | `false` until all necessary forensic answers and evidence are preserved. Then `true`. |
| `ExpectedRole` | Exactly one string: `"StandaloneServer"`, `"MemberServer"`, or `"DomainController"`, matching Audit. |
| `DomainName` | On a DC, the current **DNS domain name** exactly as reported, e.g. fictional `"lab.example.test"`; blank `""` for standalone. Do not guess. |
| `AuthorizedLocalAdmins` | Exact authorized **local** admin usernames, e.g. `["labadmin"]`, required for standalone/member servers. |
| `AuthorizedLocalUsers` | Exact authorized non-admin local usernames, e.g. `["labstudent"]`. |
| `AuthorizedDomainAdmins` | Exact authorized AD/domain administrator usernames, required on a DC. |
| `AuthorizedDomainUsers` | Exact authorized ordinary AD user names; only meaningful when using a domain. |
| `RequiredServiceAccounts` | Service identity names required to keep a job running; do not disable/reset or group-change them without checking dependencies. |
| `RequiredServices` | Service **Names** needed by the VM, e.g. `["W3SVC", "TermService"]` for required IIS and RDP; examples for other roles include `DNS`, `DHCPServer`, `NTDS`. |
| `RequiredRoles` | Required installed roles/features, e.g. `["Web-Server"]` for IIS, or `["AD-Domain-Services", "DNS"]` on a DC. These protect server-role functionality. |
| `RequiredShares` | Exact required SMB share names, not disk folder paths, e.g. `["LabShare"]`. |
| `RequiredApplications` | Required installed application display names, e.g. `["Mozilla Firefox"]` **if the image says it must remain installed**. Cross-check exact winget IDs before any uninstall. |
| `RequiredPorts` | Array of string ports, optionally with protocol, e.g. `["80/tcp","3389/tcp"]`. These help the script avoid disabling relevant firewall rules. **Listing a port does not itself open or test it.** |
| `DiscoveryPaths` | Array of exact folders used only for finding suspicious file candidates, e.g. `["C:\\Users\\Public", "C:\\Temp"]`. The script limits supported scan roots; do not enter full drives indiscriminately. |

**2. Accounts, groups, password policy, and auditing**

| Field | Exactly what belongs there; shape example |
|---|---|
| `LocalUsers.Create` | List of **missing authorized local usernames** to create, e.g. `["labstudent"]`, also named in authorized lists. Password supplied interactively. |
| `LocalUsers.Disable` | List of exact unauthorized local usernames to disable; verify the current account/critical service is not dependent on them. |
| `LocalUsers.Delete` | List of exact unauthorized local usernames to delete; requires `-AllowRemovals` and saved forensics. Destructive. |
| `LocalUsers.DemoteAdmins` | Existing local users who must lose local Administrators membership but keep their account. |
| `LocalUsers.PasswordExpires` | Authorized local users whose `PasswordNeverExpires` should become false; it does **not** mean force password change immediately. |
| `LocalUsers.ResetPasswords` | Authorized local accounts whose passwords need interactive reset; never store passwords in JSON. |
| `LocalGroups.Create` | Array of exact local group names to create, e.g. `["LabReaders"]`. |
| `LocalGroups.Members` | Object mapping **group → authorized members**, e.g. `{"LabReaders": ["labstudent"]}`. |
| `LocalGroups.RemoveMembers` | Object mapping **group → exact users to remove**, e.g. `{"LabReaders": ["unapproveduser"]}`. |
| `LocalPasswordPolicy` | Object of **numbers**, e.g. `{"MinimumPasswordLength":12,"PasswordComplexity":1}`. Supported names: `MinimumPasswordLength`, `PasswordHistorySize`, `MinimumPasswordAge`, `MaximumPasswordAge`, `PasswordComplexity`, `ClearTextPassword`, `LockoutBadCount`, `LockoutDuration`, `ResetLockoutCount`. Binary options need 0/1; domain policy may override local settings. |
| `RemoveUserRights` | Object `{"SeDebugPrivilege": ["unapproveduser"]}` for specifically unauthorized privileges; supported rights include `SeSecurityPrivilege`, `SeTakeOwnershipPrivilege`, `SeDebugPrivilege`, `SeBackupPrivilege`, and `SeRestorePrivilege`. **Never remove required admin/service privileges indiscriminately.** |
| `AuditSubcategories` | Object `{"Logon": "SuccessAndFailure"}`. Values must be `"Success"`, `"Failure"`, or `"SuccessAndFailure"` and use the exact audit subcategory name on the VM. |
| `DomainChanges` | **A nested AD object, not a flat list.** Exact field reference in Step 9C. Leave `Allowed:false` for normal beginner use. |

**3. Firewall, antivirus, file sharing, services, and installations**

| Field | Exactly what belongs there |
|---|---|
| `Firewall.EnableProfiles` | `true` enables Domain/Private/Public Windows Firewall profiles. **Default is false** in Server template to prevent lockouts; verify all required role ports and RDP first. |
| `Firewall.DisableRules` | Exact **internal rule names** returned by `Get-NetFirewallRule -Name`, *not* descriptions; only for known unwanted inbound Allow rules. |
| `Defender.Enable` | `true` requests Defender realtime and PUA protections if installed/appropriate. |
| `Defender.UpdateSignatures` | `true` requests Defender signature refresh, subject to approved network access. |
| `Defender.QuickScan` | `true` requests a quick scan; wait until forensic evidence is preserved. |
| `Defender.RemovePathExclusions` | Exact path exclusions verified unnecessary via `Get-MpPreference`. |
| `Defender.RemoveProcessExclusions` | Exact process exclusions verified unnecessary. |
| `Defender.RemoveExtensionExclusions` | Exact file extension exclusions verified unnecessary. |
| `SMB.RequireServerSigning` | `true` requires signing on server-hosted SMB shares; may disrupt old clients. |
| `SMB.RequireClientSigning` | `true` requires signing when this server accesses other SMB shares. |
| `SMB.DisableSMB1` | `true` disables legacy SMB1, with extra DC/compatibility checks; test required SMB clients. |
| `DisableServices` | Exact service **Names** to stop/disable, e.g. a confirmed unnecessary third-party service; don't include `DNS`, `NTDS`, `W3SVC`, or required units. |
| `DisableFeatures` | Exact names of Windows **optional features** to disable only if unnecessary. |
| `UninstallWindowsFeatures` | Exact installed Server role/feature names to **remove**; may break dependencies. Requires removal permission and forensics. |
| `DisableScheduledTasks` | Full names of unauthorized non-Microsoft scheduled tasks, e.g. `["\\LabTasks\\UnwantedTask"]`. |
| `RemoveStartupValues` | Array of objects `[{"Path":"HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run","Name":"UnwantedEntry"}]` for an exact Run/RunOnce registry value. |
| `RemoveHostsEntries` | Array of exact **full lines** from `hosts` to remove, e.g. an explicitly malicious mapping; requires `-AllowRemovals` and is guarded on DCs. |
| `ClearAccessibilityDebuggers` | Exact allowlisted executable names (e.g. `"sethc.exe"`, `"utilman.exe"`, `"osk.exe"`, `"magnify.exe"`, `"narrator.exe"`) *only* when an unwanted debugger hijack is verified. |
| `RemoveShares` | Exact non-system share names to remove after verification; destructive and requires `-AllowRemovals`. |
| `RemoveShareAccess` | Array `[{"Share":"LabShare","Account":"unapproveduser"}]` to revoke an exact SMB share grant, **not** its NTFS ACL. |
| `RemoveFiles` | Exact full paths to **files** that must be removed, e.g. `["C:\\Users\\Public\\unapproved.exe"]` only with preserved evidence and removal approval. No bulk deletions. |
| `UpdatePrograms` | Exact winget package IDs to update, e.g. `["Mozilla.Firefox"]` only if installed and approved. |
| `UninstallPrograms` | Exact winget IDs to remove, **not** friendly display titles; requires `-AllowRemovals`. |
| `WindowsUpdate` | Exactly `"None"`, `"Scan"`, or `"Install"`; `"Install"` attempts updates but does not automatically reboot. |
| `IIS`, `DNS`, `DHCP`, `TLS` | Server role-specific nested objects explained in Step 9D. |
| `Security` | Nested Windows Server security settings explained in Step 9E. |

#### Step 9C — Domain Controller `DomainChanges` fields

Only configure this object if the VM is **really a Domain Controller** and your team has explicitly approved AD writes. On a standalone/member server, leave the example's defaults (all empty and `Allowed:false`).

| DomainChanges key | Expected value |
|---|---|
| `Allowed` | `false` by default. When `true`, AD writes still require the separate `-EnableDomainChanges` command option, a matching domain, and authorization. |
| `DisableUsers` | Array of exact **unauthorized AD `SamAccountName`** strings; protected/service/privileged users are skipped. |
| `NewUsers` | Array of **objects**, e.g. `[{"SamAccountName":"labstudent","Name":"Lab Student","OU":"OU=Students,DC=lab,DC=example,DC=test"}]`. The OU must exist under the actual domain and the username must appear in authorized domain lists; password is interactive. |
| `ExpirePasswords` | Exact authorized non-service AD usernames that must change password at next logon. |
| `ResetPasswords` | Authorized ordinary AD usernames needing an interactive reset; do not reset privileged/service identities blindly. |
| `NewGroups` | Array of **objects** like `[{"Name":"LabReaders","OU":"OU=Groups,DC=lab,DC=example,DC=test","Scope":"Global"}]`. Supported scopes: `Global`, `DomainLocal`, `Universal`. |
| `AddGroupMembers` | Object `{"LabReaders":["labstudent"]}` for verified, authorized domain-group membership. Does not grant Domain Admin privileges indiscriminately; privileged groups require human review. |
| `RemoveGroupMembers` | Object `{"LabReaders":["unapproveduser"]}` for an explicitly unauthorized member, after checking app dependencies. |
| `ChangeDefaultPasswordPolicy` | `true` requests changing the default **domain** password policy (different from `LocalPasswordPolicy`); also requires AD-write safeguards. |
| `DefaultPasswordPolicy` | Object with **numbers or booleans**, using these exact keys: `MinPasswordLength`, `PasswordHistoryCount`, `ComplexityEnabled`, `ReversibleEncryptionEnabled`, `LockoutThreshold`, `LockoutDurationMinutes`, `LockoutObservationWindowMinutes`, `MinPasswordAgeDays`, `MaxPasswordAgeDays`. Example `{"MinPasswordLength":12,"ComplexityEnabled":true}` **only if explicitly specified**; check effective domain and fine-grained policies first. |

**Important:** On a DC, `ExpectedRole` must equal `"DomainController"`, `DomainName` must match the server's **real** AD DNS domain, and `AuthorizedDomainAdmins` must list real authorized administrators. The complete example below illustrates a **standalone server**, not a DC. **Don't simply change the role string to make a config pass validation.**

#### Step 9D — Server-role-specific settings

| Nested field | Exact structure and when relevant |
|---|---|
| `IIS.DisableDirectoryBrowsingOnSites` | Array of exact IIS website names, e.g. `["Default Web Site"]`, if IIS is required and directory browsing should be disabled. `RequiredRoles` must contain `"Web-Server"` or `"IIS"`. Test the website afterward. |
| `DNS.SecureDynamicUpdateZones` | Array of exact AD-integrated **primary zone names**, e.g. `["lab.example.test"]`, only when that zone is owned by the VM and secure updates are required. |
| `DNS.DisableZoneTransfers` | Exact primary DNS zone names where transfers should be disabled; **requires `-AllowCompatibilityChanges`**, and can break legitimate secondaries. |
| `DNS.RequiredSecondaryServers` | Array of names/addresses of legitimate secondary DNS servers. A non-empty list makes the script skip broad no-transfer changes for safety; configure restricted transfers manually. |
| `DHCP.EnableAuditLogging` | `true` requests DHCP audit logging **only if DHCP is installed and declared required**. Does not configure scopes/leases for you. |
| `TLS.DisableServerProtocols` | List of exact legacy protocol names from `"SSL 2.0"`, `"SSL 3.0"`, `"TLS 1.0"`, `"TLS 1.1"`; can disrupt required clients. |
| `TLS.CompatibilityConfirmed` | `true` means the necessary protocol/client testing was performed. The script also requires `-AllowCompatibilityChanges` for TLS protocol changes. |

#### Step 9E — Each `Security` setting

All values below are **`true`/`false`** inside the `Security` object. `true` requests that action when its dependencies allow it. **None is automatically guaranteed safe on a domain controller.**

| Security subkey | What it requests |
|---|---|
| `SmartScreen` | Enable Microsoft SmartScreen policy, where applicable. |
| `RestrictBlankPasswords` | Restrict network access for blank-password local accounts. |
| `EnableUAC` | Turn on User Account Control and admin elevation prompts (may need restart). |
| `HideLastSignedIn` | Hide last signed-in username at logon. |
| `DisableAutoplay` | Disable automatic actions from removable media. |
| `DisableLLMNR` | Disable multicast name resolution; may affect networks that rely on it. |
| `PowerShellLogging` | Enable PowerShell script-block logging; collected events may contain sensitive details. |
| `RequireNTLMv2` | Require stronger NTLM behavior; **also needs `-AllowCompatibilityChanges`**. |
| `RestrictAnonymous` | Restrict anonymous access. On DC, compatibility preflight/flag required. |
| `PrintDriverAdminOnly` | Restrict Point-and-Print driver installation to admins; test printing. |
| `RequireRdpNLA` | Require RDP Network Level Authentication; verify `TermService` is declared required and connection still works. |
| `DisableRemoteAssistance` | Disable Remote Assistance (different from Remote Desktop). |
| `DisableUnencryptedWinRM` | Turn off unencrypted WinRM traffic, after verifying required remote management. |
| `DisableBasicWinRM` | Turn off WinRM Basic authentication; test your authorized remoting method. |

#### Step 9F — Complete example JSON (fictional standalone server)

Use the [complete standalone-server example JSON](EXAMPLE-CONFIG-DO-NOT-APPLY.json) as a reference for **every generated field**. The example pretends the lab needs a web server, a named file share, and RDP, but these are **not assumed requirements for your actual image**.

> [!WARNING]
> **Never Apply this example as-is.** The demo uses fictional `lab...` accounts and an assumed IIS website; both confirmation fields are `false` so the script will reject unreviewed Apply. The example password length and IIS settings are for illustrating correct JSON types, **not a recommended universal configuration**.

~~~json
{
  "ConfirmedReadme": false,
  "ConfirmedServerRole": false,
  "ForensicsComplete": false,
  "ExpectedRole": "StandaloneServer",
  "DomainName": "",
  "AuthorizedLocalUsers": [
    "labstudent"
  ],
  "AuthorizedLocalAdmins": [
    "labadmin"
  ],
  "AuthorizedDomainUsers": [],
  "AuthorizedDomainAdmins": [],
  "RequiredServiceAccounts": [],
  "RequiredServices": [
    "W3SVC",
    "TermService"
  ],
  "RequiredRoles": [
    "Web-Server"
  ],
  "RequiredShares": [
    "LabShare"
  ],
  "RequiredApplications": [
    "Mozilla Firefox"
  ],
  "RequiredPorts": [
    "80/tcp",
    "3389/tcp"
  ],
  "LocalUsers": {
    "Create": [],
    "Disable": [],
    "Delete": [],
    "DemoteAdmins": [],
    "PasswordExpires": [],
    "ResetPasswords": []
  },
  "LocalGroups": {
    "Create": [
      "LabReaders"
    ],
    "Members": {
      "LabReaders": [
        "labstudent"
      ]
    },
    "RemoveMembers": {}
  },
  "LocalPasswordPolicy": {
    "MinimumPasswordLength": 12,
    "PasswordComplexity": 1
  },
  "RemoveUserRights": {},
  "DomainChanges": {
    "Allowed": false,
    "DisableUsers": [],
    "NewUsers": [],
    "ExpirePasswords": [],
    "ResetPasswords": [],
    "NewGroups": [],
    "AddGroupMembers": {},
    "RemoveGroupMembers": {},
    "ChangeDefaultPasswordPolicy": false,
    "DefaultPasswordPolicy": {}
  },
  "Firewall": {
    "EnableProfiles": false,
    "DisableRules": []
  },
  "Defender": {
    "Enable": true,
    "UpdateSignatures": false,
    "QuickScan": false,
    "RemovePathExclusions": [],
    "RemoveProcessExclusions": [],
    "RemoveExtensionExclusions": []
  },
  "SMB": {
    "RequireServerSigning": false,
    "RequireClientSigning": false,
    "DisableSMB1": false
  },
  "Security": {
    "SmartScreen": false,
    "RestrictBlankPasswords": false,
    "EnableUAC": false,
    "HideLastSignedIn": false,
    "DisableAutoplay": false,
    "DisableLLMNR": false,
    "PowerShellLogging": false,
    "RequireNTLMv2": false,
    "RestrictAnonymous": false,
    "PrintDriverAdminOnly": false,
    "RequireRdpNLA": false,
    "DisableRemoteAssistance": false,
    "DisableUnencryptedWinRM": false,
    "DisableBasicWinRM": false
  },
  "AuditSubcategories": {},
  "DisableServices": [],
  "DisableFeatures": [],
  "UninstallWindowsFeatures": [],
  "DisableScheduledTasks": [],
  "RemoveStartupValues": [],
  "RemoveHostsEntries": [],
  "ClearAccessibilityDebuggers": [],
  "RemoveShares": [],
  "RemoveShareAccess": [],
  "RemoveFiles": [],
  "UpdatePrograms": [],
  "UninstallPrograms": [],
  "WindowsUpdate": "None",
  "IIS": {
    "DisableDirectoryBrowsingOnSites": [
      "Default Web Site"
    ]
  },
  "DNS": {
    "SecureDynamicUpdateZones": [],
    "DisableZoneTransfers": [],
    "RequiredSecondaryServers": []
  },
  "DHCP": {
    "EnableAuditLogging": false
  },
  "TLS": {
    "DisableServerProtocols": [],
    "CompatibilityConfirmed": false
  },
  "DiscoveryPaths": [
    "C:\\Users\\Public",
    "C:\\Temp"
  ]
}
~~~

**To change this example for a real VM:** Choose your detected `ExpectedRole`, replace all fictional names, copy only actually required services/roles/ports from the README, and leave every unknown action list empty. For a DC, follow Step 9C and keep AD writes disabled unless explicitly authorized. For a server without IIS, remove `"Web-Server"` from `RequiredRoles` and set `"IIS": {"DisableDirectoryBrowsingOnSites": []}`. **Verify firewall/remote connectivity before changing networking settings.**

Now save your edited **generated file**, not the teaching example. Continue with Step 10 to check the JSON format and Step 11 only when your configuration has been reviewed.

### Step 10 — Check JSON syntax (this does NOT apply changes)

~~~powershell
Get-Content .\server-config.json -Raw | ConvertFrom-Json | Out-Null
~~~

**Expected:** No error. If you see red text, reopen `server-config.json` and fix missing commas, quotes, or brackets. Passing this check only means the file is formatted correctly—it does **not** prove the server changes are safe.

### Step 11 — Apply only when you are ready

**Do this only with an authorized, reviewed config and working console access:**

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -Mode Apply -Config ".\server-config.json"
~~~

At the confirmation prompt, type **`APPLY`** exactly and press **Enter** to continue. If unsure, **do not type APPLY**. The script checks its configuration and detected server role, performs its configured tasks, and records before/after audit results.

**It does not reboot the server for you.** Some Windows changes may need a later restart, which you should schedule only if authorized and after testing role dependencies.

### Step 12 — Check results before making another change

On Desktop Experience:

~~~powershell
explorer.exe "$env:ProgramData\ServerSecurityWork"
~~~

Look at the latest `summary-...csv` and `changes-...txt`, plus `backups-...` and audit files. On Server Core, use `Get-ChildItem "$env:ProgramData\ServerSecurityWork"` to locate them.

| Status | Simple meaning |
|---|---|
| `CHANGED` | Action was reported as changed; **not a guarantee of points** |
| `OK` | The check did not need a change |
| `REVIEW` / `SKIPPED` | You or a teammate must inspect it manually |
| `FAILED` | The attempted action failed; read the details |
| `WOULD` | A proposed change; not confirmation that it was made |

**Verify real functionality:** authorized domain/local logins, DNS resolution, DHCP leases, IIS sites, FTP, shares, RDP/WinRM, and required databases **when those features are required by this image**. Compare the Scoring Report to your baseline. If a role or login stops working, **stop and restore the exact affected setting** using its recorded original value; do not indiscriminately undo/re-run the whole script. Some deletions cannot be fully undone.

## Advanced controls — read only if supervised

- **List section names (no fixes):** `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-server.ps1" -List`.
- **Run only specific sections:** append `-Only defender,firewall,updates` to the Apply command after reviewing the config.
- **Skip the initial confirmation:** `-Yes`. Not recommended for beginners; secure password prompts may be skipped.
- **Remove exact configured items:** `-AllowRemovals`. Potentially destructive; requires confirmed targets and forensic preservation.
- **Change AD objects on a DC:** requires both `DomainChanges.Allowed=true` in JSON **and** `-EnableDomainChanges`, with exact role/domain checks.
- **Allow compatibility-impacting security changes:** `-AllowCompatibilityChanges`. Can disrupt older clients, protocols, shares, and remote management. Use only after compatibility testing.

## Troubleshooting

| Problem | Exact next step |
|---|---|
| Script file missing | Confirm you are in the script's actual download/transfer folder. Run `Get-Item .\windows-server.ps1` |
| Download saved as HTML or TXT | Return to **Raw** and download the real `.ps1` script |
| Not an Administrator | Reopen **Windows PowerShell → Run as administrator** inside the VM |
| Wrong server type / `ExpectedRole` error | Re-read the role in the Audit output and confirm it with a coach; **do not change the JSON just to silence an error** |
| `DomainName` mismatch | Check the domain shown by the server, including exact spelling; do not guess |
| Config already exists | Edit the existing `server-config.json` instead of deleting it |
| JSON formatting error | Run `Get-Content .\server-config.json -Raw | ConvertFrom-Json | Out-Null` and correct Notepad errors |
| AD edit skipped | This is deliberate until authorized domain-change safeguards are met; never bypass them casually |
| Lost DNS/DHCP/IIS/remote access | **Stop applying changes**, inspect backups and the [role-specific recovery guide](../windows-server.md) before touching other settings |

**More help:** [Server manual tasks](MANUAL-TASKS.md) · [Complete Windows Server handbook](../windows-server.md) · [General script safety and rollback](../../General/script-safety.md).

*These instructions match the script's documented CLI options; an end-to-end run on a Windows Server VM was not performed as part of this documentation update.*
