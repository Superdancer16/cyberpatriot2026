# Windows Server checklist (2016 / 2019 / 2022)

Windows Server 2022 is in **Round 2, the State round and the Semifinals** this season.

Most of the [Windows 10/11 checklist](windows-10-11.md) also applies to servers. This page covers **what's different** and the **server roles** (Active Directory, DNS, IIS, FTP, file shares) that make servers harder.

**How to use this page:** work top to bottom. When a step says "same as Windows 10/11", follow that section of the other checklist. Identify the server role manually before applying settings; automation is not included here.

---

## 0. Before you touch anything

- [ ] **Read the README twice.** Servers usually have **critical services** (AD, DNS, IIS, FTP, file shares). Write every one down. See [Reading the README](../General/All/reading-the-readme.md).
- [ ] **Take a VMware snapshot.**
- [ ] **Open PowerShell as Administrator.**
- [ ] **Open the Scoring Report.**
- [ ] **Answer the forensics questions** ([guide](../General/All/forensics-questions.md)).

---

## 1. Is this a Domain Controller?

### 1.1 Find out what kind of server it is
- [ ] Done

**Why it matters:** On a **Domain Controller** (DC), users and password rules live in **Active Directory** and **Group Policy**, not on the local computer. If you change the local settings on a DC, nothing happens.

**Clicking:** **Server Manager → Dashboard**. If **AD DS** appears in the left list, it's a Domain Controller. **Server Manager → Local Server** also shows **Domain:** if the computer is in a domain.

**Typing:**
```powershell
(Get-CimInstance Win32_OperatingSystem).ProductType    # 1 = workstation, 2 = DOMAIN CONTROLLER, 3 = server
Get-WindowsFeature | Where-Object Installed | Select-Object Name, DisplayName     # every installed role
```

| ProductType | Users are in | Password policy is in |
|---|---|---|
| **2 (Domain Controller)** | Active Directory Users and Computers (`dsa.msc`) | **Default Domain Policy** (Group Policy, `gpmc.msc`) |
| **3 (member or standalone server)** | Local accounts in `lusrmgr.msc`; domain accounts remain in AD | Local policy for local accounts; domain policy for domain accounts |

The `*-AD*`, `*-GPO` and `*-DnsServer*` commands on this page come with the AD DS and DNS roles, so they work on a Domain Controller. On other servers they fail unless those tools are installed; use the "Standalone / member server" steps there.

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

**Warnings:** Never use a guessed list of authorized users or bulk-delete files. See [Using the scripts safely](../Misc%20Softwares/using-the-scripts.md) for the limits of external tools.

---

## 2. Users and groups

### 2.1 Standalone / member server
- [ ] Done

Same as [Windows 10/11 section 2](windows-10-11.md#2-users-and-groups).

### 2.2 Domain Controller: domain users
- [ ] Done

**Clicking:** **Win + R** → `dsa.msc` (**Active Directory Users and Computers**). Users are usually in the **Users** folder, but check **every OU** (folder). Turn on **View → Advanced Features** to see everything.
- Delete a user: right-click → **Delete**.
- Disable a user: right-click → **Disable Account**.
- New user: right-click the folder → **New → User**.

**Typing:**
```powershell
Get-ADUser -Filter * -Properties Enabled, LastLogonDate | Format-Table SamAccountName, Enabled, DistinguishedName -AutoSize
Remove-ADUser -Identity mallory
New-ADUser -Name erin -SamAccountName erin -AccountPassword (Read-Host -AsSecureString "Password") -Enabled $true
Disable-ADAccount -Identity Guest
```

> [!CAUTION]
> **Never delete or change these built-in accounts:** `Administrator` (unless the README says so), `krbtgt` (Active Directory breaks without it), and computer accounts (names ending in `$`). Disable `Guest`.

### 2.3 Domain Controller: powerful groups
- [ ] Done

Check the members of each group. Remove anyone the README doesn't say should be an admin.

| Group | Can… |
|---|---|
| **Domain Admins** | Control every computer in the domain |
| **Enterprise Admins** | Control the whole forest |
| **Schema Admins** | Change the structure of AD |
| **Administrators** (Builtin folder) | Control the Domain Controllers |
| **Account Operators** | Create and change most users |
| **Backup Operators** | Read every file, log on to DCs |
| **Server Operators** | Log on to DCs, change services |
| **Print Operators** | Load drivers on DCs |
| **DnsAdmins** | Can make the DNS server run any program (easy path to domain admin) |
| **Group Policy Creator Owners** | Create Group Policies |

**Typing:**
```powershell
foreach ($g in 'Domain Admins','Enterprise Admins','Schema Admins','Administrators','Account Operators','Backup Operators','Server Operators','Print Operators','DnsAdmins','Group Policy Creator Owners') {
  "--- $g"; (Get-ADGroupMember $g -ErrorAction SilentlyContinue).SamAccountName }
Remove-ADGroupMember -Identity 'Domain Admins' -Members bob -Confirm:$false
Add-ADGroupMember -Identity 'Domain Admins' -Members alice
Get-ADGroupMember 'Domain Admins' -Recursive | Select-Object SamAccountName   # also shows people hidden inside a nested group
```

> [!CAUTION]
> Some members are there by default: leave them. **Administrators** contains the groups **Domain Admins** and **Enterprise Admins** and the built-in **Administrator**; **Domain Admins**, **Enterprise Admins** and **Schema Admins** contain **Administrator**. Remove only *people* (and planted groups) the README doesn't list as admins.

### 2.4 Domain Controller: risky account settings
- [ ] Done

**Clicking:** in `dsa.msc`, double-click a user → **Account** tab → **Account options**. These should all be **unticked**:
- Password never expires
- Store password using reversible encryption
- Do not require Kerberos preauthentication (lets attackers crack the password offline)
- Password not required (not shown here; use PowerShell)

**Typing:**
```powershell
Get-ADUser -Filter 'Enabled -eq $true' -Properties PasswordNeverExpires, PasswordNotRequired, AllowReversiblePasswordEncryption, DoesNotRequirePreAuth |
  Where-Object { $_.PasswordNeverExpires -or $_.PasswordNotRequired -or $_.AllowReversiblePasswordEncryption -or $_.DoesNotRequirePreAuth } |
  Format-Table SamAccountName, PasswordNeverExpires, PasswordNotRequired, AllowReversiblePasswordEncryption, DoesNotRequirePreAuth
Set-ADUser bob -PasswordNeverExpires $false -PasswordNotRequired $false -AllowReversiblePasswordEncryption $false
Set-ADAccountControl bob -DoesNotRequirePreAuth $false
```

### 2.5 Strong passwords
- [ ] Done

```powershell
Set-ADAccountPassword -Identity bob -Reset -NewPassword (Read-Host -AsSecureString "New password")
```

---

## 3. Password and lockout policy

### 3.1 Standalone / member server
- [ ] Done

Same as [Windows 10/11 section 3](windows-10-11.md#3-account-policies-passwords-and-lockout).

### 3.2 Domain Controller: edit the Default Domain Policy
- [ ] Done

**Clicking:**
1. **Win + R** → `gpmc.msc` (**Group Policy Management**).
2. Open **Forest → Domains → (your domain) → Group Policy Objects**.
3. Right-click **Default Domain Policy → Edit**.
4. Go to **Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies**.
5. Set **Password Policy** and **Account Lockout Policy** with the same values as [Windows 10/11 section 3](windows-10-11.md#3-account-policies-passwords-and-lockout) (history 24, max age 90, min age 1, length 12, complexity on, reversible off; lockout 5 / 30 / 30).
6. Close the editor and run `gpupdate /force`.

**Check it worked:**
```powershell
Get-ADDefaultDomainPasswordPolicy
net accounts /domain
```

> [!NOTE]
> `Get-ADFineGrainedPasswordPolicy -Filter *` lists **fine-grained password policies**. These override the domain policy for some users. A planted weak one is a sneaky problem.

---

## 4. Audit policy, user rights and security options

### 4.1 Standalone / member server
- [ ] Done

Same as [Windows 10/11 section 4](windows-10-11.md#4-local-policies).

### 4.2 Domain Controller: Default Domain Controllers Policy
- [ ] Done

On a DC, these come from the **Default Domain Controllers Policy** GPO. In `gpmc.msc`, right-click it → **Edit** → **Computer Configuration → Policies → Windows Settings → Security Settings → Local Policies** (Audit Policy, User Rights Assignment, Security Options). Use the tables in the Windows 10/11 checklist, plus these DC settings:

**Back up every GPO before you edit one** (to undo: `Restore-GPO -Name 'Default Domain Controllers Policy' -Path C:\gpo-backup`):
```powershell
New-Item -ItemType Directory -Path C:\gpo-backup -Force | Out-Null
Backup-GPO -All -Path C:\gpo-backup
```

| Security Option | Set to |
|---|---|
| Domain controller: LDAP server signing requirements | **Require signing** |
| Domain controller: LDAP server channel binding token requirements | Inspect client compatibility and current Microsoft guidance before requiring **Always**; see 12.3 |
| Domain controller: Allow server operators to schedule tasks | **Disabled** |
| Domain controller: Refuse machine account password changes | **Disabled** |
| Domain member: Digitally encrypt or sign secure channel data (always) | **Enabled** |
| Network security: LDAP client signing requirements | **Negotiate signing** |

**User rights on a DC are different.** Use these rows instead of the Windows 10/11 ones:

| User right (on a DC) | Should be |
|---|---|
| Access this computer from the network | Administrators, **Authenticated Users**, **ENTERPRISE DOMAIN CONTROLLERS** (remove Everyone) |
| Allow log on locally | Administrators. Removing the Operator groups is fine. Never add Users or Domain Users |
| Allow log on through Remote Desktop Services | Administrators |
| Deny access to this computer from the network | Guests |

> [!CAUTION]
> A GPO change on a DC applies to **every computer in the domain** and is copied to every other DC. Removing **Authenticated Users** or **ENTERPRISE DOMAIN CONTROLLERS** from "Access this computer from the network", or adding a big group to a **Deny** right, stops users logging on and computers getting Group Policy. If the score drops or logons break, restore the backup.

Detailed audit settings are under **Security Settings → Advanced Audit Policy Configuration**. Set the account logon, account management, logon/logoff, policy change, privilege use, DS access and system categories to **Success and Failure**.

### 4.3 Look for planted bad Group Policies
- [ ] Done

**Why:** An attacker can create or change a GPO to turn off the firewall, add an admin, or run a script on every computer.

**Clicking:** In `gpmc.msc`, click each GPO → **Settings** tab (it shows a report). Look for anything that weakens security. Check the **Scope** tab to see where it's linked.

**Typing:**
```powershell
Get-GPO -All | Sort-Object ModificationTime -Descending | Format-Table DisplayName, ModificationTime
Get-GPOReport -All -ReportType Html -Path C:\gpo-report.html; Start-Process C:\gpo-report.html
```

### 4.4 Domain Controller: Zerologon protection
- [ ] Done

**Why it matters:** Zerologon (CVE-2020-1472) lets anyone on the network take over a Domain Controller without a password. Windows updates since February 2021 always block it, but a planted policy can let chosen accounts use the weak connection again, and an un-updated image is wide open.

**Clicking:** In the **Default Domain Controllers Policy** (4.2) → **Security Options** → **Domain controller: Allow vulnerable Netlogon secure channel connections** must be **Not Defined** (no accounts listed). Install updates too (5.3).

**Typing:**
```powershell
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name FullSecureChannelProtection -Value 1 -PropertyType DWord -Force
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' | Format-List FullSecureChannelProtection, RequireSignOrSeal, RequireStrongKey
```
**Check it worked:** `FullSecureChannelProtection` shows `1`. `RequireSignOrSeal` and `RequireStrongKey` are normally `1` too; if one of them is missing, that is fine, it follows the policy default.

---

## 5. Defender, firewall and updates

### 5.1 Microsoft Defender
- [ ] Done

Same as [Windows 10/11 section 5](windows-10-11.md#5-microsoft-defender-antivirus). If Defender isn't installed: **Server Manager → Add Roles and Features → Features → Microsoft Defender Antivirus** (called **Windows Defender Features** on Server 2016), or `Install-WindowsFeature Windows-Defender`, then restart. Server 2016 and 2019 don't show **Tamper Protection** in the Defender settings; skip that part there.

### 5.2 Firewall
- [ ] Done

Same as [Windows 10/11 section 6](windows-10-11.md#6-firewall).

> [!CAUTION]
> On a Domain Controller, **don't disable** the built-in rule groups **Active Directory Domain Services**, **DNS Service**, **Kerberos Key Distribution Center**, **Netlogon Service** or **DFS Replication**. Clients need them.

### 5.3 Windows Update
- [ ] Done

**Server Manager → Local Server → Windows Update** (or **Settings → Update & Security**). On Server Core: run `sconfig` and choose **Install updates**.

### 5.4 IE Enhanced Security Configuration
- [ ] Done

**Server Manager → Local Server → IE Enhanced Security Configuration** must be **On** for Administrators and Users.

---

## 6. Services

### 6.1 Turn off what the README doesn't need
- [ ] Done

Same list as [Windows 10/11 section 8](windows-10-11.md#8-services), plus:
- **Print Spooler**: disable on Domain Controllers unless this is the print server (PrintNightmare).
- **Windows Remote Management (WinRM)**: Server Manager uses it, so keep it on servers unless the README says otherwise, and lock it down (section 8).

Windows Server has no **Security Center** (`wscsvc`) service, so skip that name in Windows 10/11 step 8.2.

### 6.2 Never touch these on a Domain Controller
- [ ] Done

| Service | Name |
|---|---|
| Active Directory Domain Services | `NTDS` |
| DNS Server | `DNS` |
| Kerberos Key Distribution Center | `Kdc` |
| Netlogon | `Netlogon` |
| DFS Replication | `DFSR` |
| Windows Time | `W32Time` |
| Active Directory Web Services | `ADWS` |
| Intersite Messaging | `IsmServ` |

```powershell
Get-Service NTDS, DNS, Kdc, Netlogon, DFSR, W32Time, ADWS, IsmServ | Format-Table Name, Status, StartType
```
All should be **Running** and **Automatic**.

### 6.3 Print Spooler: PrintNightmare fixes
- [ ] Done

**Why it matters:** PrintNightmare (CVE-2021-34527) lets a normal user install a "printer driver" that runs as SYSTEM. If the spooler must keep running, make sure only admins can install drivers.

**Clicking:** `gpedit.msc` (on a DC: the **Default Domain Controllers Policy** in `gpmc.msc`) → **Computer Configuration → Administrative Templates → Printers**:
- **Limits print driver installation to Administrators**: **Enabled**.
- **Point and Print Restrictions**: **Enabled**, and both "When installing drivers for a new connection" and "When updating drivers for an existing connection" set to **Show warning and elevation prompt**.

**Typing:**
```powershell
$pp = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'
if (-not (Test-Path $pp)) { New-Item -Path $pp -Force | Out-Null }
New-ItemProperty -Path $pp -Name RestrictDriverInstallationToAdministrators -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path $pp -Name NoWarningNoElevationOnInstall -Value 0 -PropertyType DWord -Force
New-ItemProperty -Path $pp -Name UpdatePromptSettings -Value 0 -PropertyType DWord -Force
Get-Service Spooler | Format-Table Name, Status, StartType     # Disabled on a DC unless it's the print server
```
**Check it worked:** `Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'` shows `RestrictDriverInstallationToAdministrators : 1` and the other two `0`.

---

## 7. Roles and features

### 7.1 Remove roles and features that aren't needed
- [ ] Done

**Clicking:** **Server Manager → Manage → Remove Roles and Features**. Untick unneeded **features**: Telnet Client, TFTP Client, SMB 1.0/CIFS File Sharing Support, Windows PowerShell 2.0 Engine, SNMP Service, Simple TCP/IP Services. Remove **roles** only if the README clearly doesn't need them (e.g. Web Server (IIS) on a plain DC).

**Typing:**
```powershell
Get-WindowsFeature | Where-Object Installed | Format-Table Name, DisplayName
Uninstall-WindowsFeature -Name Telnet-Client, TFTP-Client, FS-SMB1, PowerShell-V2, Simple-TCPIP
Uninstall-WindowsFeature -Name SNMP-Service      # only if the README doesn't need SNMP
```
Restart once when it says a restart is needed (SMBv1 removal needs one).

> [!CAUTION]
> **Never** remove **AD DS**, **DNS Server**, or any role the README mentions.

---

## 8. Remote access

### 8.1 Remote Desktop and Remote Assistance
- [ ] Done

Same as [Windows 10/11 section 10](windows-10-11.md#10-remote-access). Servers often **need** RDP; if so, keep it on with Network Level Authentication, and control who's in **Remote Desktop Users**.

### 8.2 Lock down WinRM
- [ ] Done

```powershell
winrm get winrm/config/service       # AllowUnencrypted = false, Basic = false
```
Or with `gpedit.msc` → **Administrative Templates → Windows Components → Windows Remote Management (WinRM) → WinRM Service**: **Allow Basic authentication: Disabled**, **Allow unencrypted traffic: Disabled**.

---

## 9. Critical server roles (only if the README lists them)

### 9.1 IIS web server
- [ ] Done

**Clicking:** **Win + R** → `inetmgr` (IIS Manager). For the server **and each site**:
- **Directory Browsing** → **Disable** (Actions pane).
- **HTTP Response Headers** → remove **X-Powered-By**.
- **Request Filtering** → check nothing dangerous is allowed. **Edit Feature Settings** → untick **Allow unlisted file name extensions** only if the site still works afterwards.
- **Logging** → enabled.
- **Authentication** → **Basic Authentication** disabled unless the site uses HTTPS and needs it. **Anonymous Authentication** only if the site is public.
- **Application Pools** → **Advanced Settings → Identity**: should be **ApplicationPoolIdentity**, not **LocalSystem**.
- Look in the site folder (`C:\inetpub\wwwroot` or wherever **Basic Settings** points) for web shells: `.aspx`, `.asp` or `.php` files you don't recognise, e.g. `cmd.aspx` or `shell.aspx`.

```powershell
Import-Module WebAdministration      # if this fails: Install-WindowsFeature Web-Scripting-Tools
Get-Website | Format-Table Name, State, PhysicalPath
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter system.webServer/directoryBrowse -Name enabled -Value $false
Remove-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter system.webServer/httpProtocol/customHeaders -Name . -AtElement @{name='X-Powered-By'}
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter system.webServer/security/requestFiltering -Name removeServerHeader -Value $true   # Server 2019/2022 only
Get-ChildItem C:\inetpub -Recurse -Include *.aspx,*.asp,*.php | Select-String -Pattern 'cmd.exe|Process.Start|eval\(|exec\(' | Select-Object Path -Unique
```
If the X-Powered-By header is already gone, that line may print an error; that's fine.

### 9.2 IIS FTP server
- [ ] Done

In `inetmgr`, click the FTP site:
- **FTP Authentication** → **Anonymous Authentication: Disabled** (unless the README needs anonymous FTP).
- **FTP Authorization Rules** → no "Allow All Users / Anonymous Read, Write" unless needed.
- **FTP SSL Settings** → **Require SSL connections** (only if a certificate is selected).
- **FTP User Isolation** → isolate users (so they can't see each other's files).
- **FTP Logging** → enabled.

```powershell
Import-Module WebAdministration
Get-Website | Where-Object { $_.Bindings.Collection.protocol -contains 'ftp' } | Format-Table Name, PhysicalPath   # your FTP site names
Set-ItemProperty 'IIS:\Sites\Default FTP Site' -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value $false   # use your site's name from the line above
```

### 9.3 DNS server
- [ ] Done

**Clicking:** **Win + R** → `dnsmgmt.msc`. For each **Forward Lookup Zone**, right-click → **Properties**:
- **General → Dynamic updates:** **Secure only** (for AD-integrated zones).
- **Zone Transfers:** untick **Allow zone transfers**, or choose **Only to the following servers** if the README mentions a secondary DNS server.

Look through the records for anything suspicious, e.g. a record for `update.microsoft.com` or `www.bank.com` pointing to a strange IP.

**Typing:**
```powershell
Get-DnsServerZone | Format-Table ZoneName, ZoneType, DynamicUpdate, SecureSecondaries, IsDsIntegrated
Set-DnsServerPrimaryZone -Name corp.local -SecureSecondaries NoTransfer -DynamicUpdate Secure   # change corp.local to your zone name
Get-DnsServerResourceRecord -ZoneName corp.local | Format-Table HostName, RecordType, RecordData
```
`-DynamicUpdate Secure` works only when **IsDsIntegrated** is `True`. For a zone that isn't, use `-DynamicUpdate None` (unless the README needs dynamic updates).

### 9.4 Active Directory
- [ ] Done

- **AD Recycle Bin:** **Active Directory Administrative Center (`dsac.exe`)** → click the domain → **Enable Recycle Bin…** (it can't be turned off later, which is fine).
- **Protected Users group:** admins in it get extra protection. Add only if the README doesn't forbid it.
- **Logon scripts in SYSVOL:** look in `C:\Windows\SYSVOL\domain\scripts` and `C:\Windows\SYSVOL\domain\Policies\*\Machine\Scripts` / `User\Scripts` for scripts you don't recognise.
- **Unconstrained delegation:** `Get-ADComputer -Filter 'TrustedForDelegation -eq $true'`. Only DCs should be listed.
- **Who can add computers:** `Get-ADObject (Get-ADDomain).DistinguishedName -Properties ms-DS-MachineAccountQuota`. Setting it to 0 stops normal users joining computers (optional).

### 9.5 DHCP server
- [ ] Done

`dhcpmgmt.msc`: check the scopes and reservations against the README, and make sure **Enable DHCP audit logging** is ticked (server → **Properties**). Look at **Scope Options** too: a planted **006 DNS Servers** or **003 Router** pointing at a strange IP sends every client to the attacker.

```powershell
Get-DhcpServerv4Scope | Format-Table ScopeId, Name, StartRange, EndRange, State
Get-DhcpServerv4Scope | Get-DhcpServerv4Reservation          # every reservation
Get-DhcpServerv4OptionValue                                  # server options (006 = DNS servers, 003 = router)
Get-DhcpServerv4Scope | Get-DhcpServerv4OptionValue          # options set on each scope
Set-DhcpServerAuditLog -Enable $true
Get-DhcpServerAuditLog
```

### 9.6 File server shares
- [ ] Done

**Clicking:** `fsmgmt.msc` → **Shares**. For each share the README needs: **Properties → Share Permissions** shouldn't give **Everyone: Full Control**, and on the **Security** tab (NTFS), only the right groups should have **Modify / Full control**.

```powershell
Get-SmbShare | ForEach-Object { "--- $($_.Name) $($_.Path)"; Get-SmbShareAccess $_.Name | Format-Table AccountName, AccessRight }
Grant-SmbShareAccess -Name Data -AccountName 'Authenticated Users' -AccessRight Read -Force   # "Data" = your share; use Change only if the README says users must save files here
Revoke-SmbShareAccess -Name Data -AccountName Everyone -Force
Get-SmbServerConfiguration | Format-List EnableSMB1Protocol, RequireSecuritySignature   # want False and True
```
On a Domain Controller, leave **NETLOGON** and **SYSVOL** alone.

### 9.7 Turn off SSL 3.0, TLS 1.0 and TLS 1.1

**Compatibility preflight:** Record protocol settings and export the exact SCHANNEL key before editing. Check required clients, application/.NET versions, certificates and patches support modern TLS. Apply changes at a recoverable checkpoint; some need service/system restart. Use [12.5](#125-iis-ftp-and-file-and-storage-services-recovery) for backup/client tests. If a legacy required client fails, restore the recorded per-protocol values, including absence of values that did not previously exist, and investigate a supported compatibility path rather than applying a blanket protocol template.
- [ ] Done

**Why it matters:** These old encryption versions have known breaks. Websites (IIS), FTP over SSL, Remote Desktop and LDAPS should all use TLS 1.2 or newer. Server 2016-2022 still allow TLS 1.0 and 1.1 unless you turn them off.

**Typing:**
```powershell
foreach ($p in 'SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1') {
  $k = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$p\Server"
  if (-not (Test-Path $k)) { New-Item -Path $k -Force | Out-Null }
  New-ItemProperty -Path $k -Name Enabled -Value 0 -PropertyType DWord -Force | Out-Null
  New-ItemProperty -Path $k -Name DisabledByDefault -Value 1 -PropertyType DWord -Force | Out-Null }
```
This changes only what the server *accepts* (the `Server` keys), not how the server connects out, so programs on it that talk to the internet keep working. Restart the server once (near the end, after saving your work) so every service picks it up.

**Check it worked:** `Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server'` shows `Enabled : 0`. Then open the website / connect with RDP to make sure the critical services still work, and refresh the Scoring Report: if it stops updating, undo this step.

> [!CAUTION]
> Very old programs (for example an old SQL Server or FTP server) may only speak TLS 1.0. If a README service stops working after the restart, set `Enabled` back to `1` for the version it needs and restart again.

---

## 10. The rest

Use the [Windows 10/11 checklist](windows-10-11.md) for:
- [ ] Prohibited software (section 12)
- [ ] Prohibited files (section 13)
- [ ] Backdoors and malware (section 14)
- [ ] Other settings (section 15)
- [ ] Browsers (section 16)

---

## 11. Final checks

- [ ] Every critical role still works (e.g. `nslookup corp.local` with your domain name for DNS, open the website for IIS)
- [ ] On a DC: `dcdiag /q` prints no errors (no output = good)
- [ ] Scoring Report shows **no penalties**
- [ ] Forensics answers saved
- [ ] Final snapshot

## 12. Role-aware manual procedures and recovery

Use **Windows PowerShell as Administrator on the server**, not a workstation, for these commands. Substitute the actual domain, scope, site and share names. A missing role cmdlet normally means its role/module is absent; do not install a server role just to satisfy a checklist. The [Windows manual verification section](windows-10-11.md#19-manual-verification-recovery-and-missing-investigation-steps) supplies shared backup, account, firewall, audit, malware and recovery procedures.

### 12.1 Identify version, roles and management dependencies

- [ ] Done

**What:** Determine whether this is a Domain Controller, member server or standalone server, and identify installed roles.

**Why it matters:** A DC stores domain identities and requires DNS, Kerberos, replication and time services. Removing a role is much more disruptive than stopping a workstation application.

**Before changing anything:** Record required services and client tests from the README. Keep VM console access and an authorized administrator. A practice VM snapshot is not an AD-aware production backup; follow round rules and do not casually revert a replicated DC.

**Clicking (GUI):** **Start → Server Manager → Local Server** shows domain membership, remote management and version. **Manage → Remove Roles and Features** can display installed roles; cancel after inspection. Do not click Remove merely because a role was not named explicitly in a short README.

**Typing (check):**

```powershell
Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,ProductType
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain
Get-WindowsFeature | Where-Object Installed | Format-Table Name,DisplayName
```

ProductType 2 means DC; 3 means another server. A **member server has local accounts plus domain accounts**: local policy governs local accounts, while domain account passwords are governed by domain policy even when logging on to that member server.

| Version | Important distinction |
|---|---|
| Server 2016 | Older IIS/Defender capabilities and policy templates; do not assume newer cmdlet parameters or `removeServerHeader` support |
| Server 2019 | Newer role/security capabilities, but patch level still determines which policies exist |
| Server 2022 | Newer defaults/features; client compatibility and installed role remain more important than copying a 2016 baseline |
| Server Core | No full desktop; use PowerShell, `sconfig` where available, and authorized remote management |

**Typing (fix, only when appropriate):** Update and harden the installed required role using its procedure below. If a role is confirmed prohibited, first record its dependencies and data. Preview removal with `Uninstall-WindowsFeature -Name ROLE -WhatIf`, replacing ROLE with the actual installed feature name. Prefer the Server Manager wizard's dependency review before carrying out approved removal.

**Check it worked:** Compare the role list and test each required client function after each change. Keep AD DS, DNS, Netlogon, KDC, time and replication functions operational where required.

**Undo:** Restore a mistakenly removed role only with its recorded configuration, data and supported recovery method; installing binaries alone does not restore a deleted directory/database. Use a pre-change role-specific backup.

**Warnings:** Server Manager itself relies on remote management features. Disabling WinRM on a server because it is often disabled on workstations can break management.

### 12.2 AD users, nested groups and service identities

- [ ] Done

**What:** Reconcile domain users and privileged group membership with the README.

**Why it matters:** A nested group can confer Domain Admin access even when a user is not a direct member. Service accounts may run databases, scheduled tasks and IIS pools.

**Before changing anything:** Preserve forensics and record distinguished names, SIDs, group memberships and service dependencies. Never use local-user cmdlets as an AD substitute.

**Clicking (GUI):** **Server Manager → Tools → Active Directory Users and Computers** (`dsa.msc`). Enable **View → Advanced Features**. Find the exact account/OU, open **Properties → Member Of / Account** and inspect privileges, expiration, delegation and password options. Open each group from the earlier powerful-group table and inspect **Members**; nested groups require inspection too. Prefer **Disable Account** before irreversible deletion of a confirmed unauthorized user.

**Typing (check):**

```powershell
Import-Module ActiveDirectory
Get-ADUser -Filter * -Properties Enabled,PasswordNeverExpires,PasswordNotRequired,ServicePrincipalName | Select-Object SamAccountName,Enabled,PasswordNeverExpires,PasswordNotRequired,ServicePrincipalName
Get-ADGroupMember -Identity 'Domain Admins'
Get-ADGroupMember -Identity 'Domain Admins' -Recursive
```

A recursive query finds effective nested members but hides the membership path; inspect direct group members to locate the offending link. Record an individual user:

```powershell
Get-ADUser bob -Properties MemberOf,AccountExpirationDate,ServicePrincipalName,TrustedForDelegation | Format-List
Get-CimInstance Win32_Service | Select-Object Name,StartName,State
Get-ScheduledTask | Select-Object TaskName,TaskPath,Principal
```

**Typing (fix, only when appropriate):** Remove the specific unauthorized direct member, preserving legitimate nested structure:

```powershell
Remove-ADGroupMember -Identity 'Domain Admins' -Members bob -Confirm
```

Reversible account containment:

```powershell
Disable-ADAccount -Identity mallory
```

Do not rotate a required service account password without coordinating each dependent service/application. Managed service accounts have separate lifecycle and password management.

**Check it worked:** Repeat direct/recursive queries, test a new permitted login and verify dependent services. Existing tokens can retain privileges until a new logon; disabling an account does not terminate every existing session automatically.

**Undo:** `Add-ADGroupMember -Identity 'Domain Admins' -Members bob` or `Enable-ADAccount -Identity mallory` restores only a mistakenly changed original state. Deleted AD objects need a supported AD recovery method, not name recreation.

**Warnings:** Do not remove all operator/service identities from a DC using a workstation rights table. Do not change your only working administrator or krbtgt credentials as a routine checklist step.

### 12.3 Domain password policy and Group Policy precedence

- [ ] Done

**What:** Apply account policy at the scope that actually governs the account, and inspect the winning GPO.

**Why it matters:** A local policy does not control domain user passwords. Fine-grained password policies can override the default for selected users/groups. A deny user right can block logon despite an allow grant.

**Before changing anything:** Record the current default/resultant policy and back up the specific GPO before editing it. Keep the Default Domain Policy and Default Domain Controllers Policy roles distinct.

**Clicking (GUI):** `gpmc.msc` → **Forest → Domains → actual domain**. Select the GPO, inspect **Scope**, links, security filtering and **Settings**; right-click **Back Up** to a private folder. Edit domain account policy in the domain-root-linked account-policy GPO, commonly **Default Domain Policy → Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies**. For DC-specific audit/rights/options inspect the GPO linked to the **Domain Controllers OU**, not the workstation baseline. Use **Group Policy Results** for a specific machine/user.

**Typing (check):**

```powershell
Get-ADDefaultDomainPasswordPolicy | Format-List
Get-ADUserResultantPasswordPolicy -Identity bob
Get-GPO -All | Select-Object DisplayName,Id,GpoStatus
```

A null resultant fine-grained policy can mean the domain default applies. Save a report:

```powershell
gpresult /h C:\CP-Backups\server-gpresult.html
```

Create and restrict that backup folder using Windows 19.1 first. A GPO report can contain sensitive infrastructure details.

**Typing (fix, only when appropriate):** Use the policy GUI row-by-row, or, for a confirmed domain and README values:

```powershell
Set-ADDefaultDomainPasswordPolicy -Identity 'example.test' -MinPasswordLength 12 -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false -LockoutThreshold 5 -LockoutDuration (New-TimeSpan -Minutes 30) -LockoutObservationWindow (New-TimeSpan -Minutes 30)
```

Replace the domain and all policy values. Length/complexity affect future password changes; lockout threshold counts invalid attempts within the observation window. Do not infer that updating a policy fixed all existing passwords.

**Check it worked:** Re-query default and resultant policies; inspect Group Policy Results for the affected computer. If appropriate, run `gpupdate /target:computer /force` and read its errors; some settings require logoff/restart. Test ordinary authorized access without deliberately locking the active admin.

**Undo:** Restore the individual recorded setting or specific GPO backup via GPMC **Manage Backups → Restore** after reviewing scope. GPO deletion is not a normal way to undo one planted setting. Changing a domain policy does not undo a password reset.

**Warnings:** Requiring LDAP signing/channel binding, restricting NTLM, or removing network-logon principals can break older required clients. Stage compatibility inspection and consult the applicable Microsoft policy documentation; do not apply `Always` blindly to every environment.

### 12.4 DNS, DHCP and DC health

- [ ] Done

**What:** Validate required name resolution, leases, replication and time after hardening.

**Why it matters:** AD relies on internal DNS SRV records and reasonably synchronized time. Using a public resolver as the DC's primary DNS can break domain discovery.

**Before changing anything:** Record DNS zones/forwarders, DHCP scopes/options/reservations, authorized servers and expected DC topology. Back up the affected role, not just a screenshot.

**Clicking (GUI):** **Server Manager → Tools → DNS**; open the server and each zone **Properties → Zone Transfers**. Permit transfers only to required secondary servers rather than blindly disallowing required replication. For AD-integrated zones inspect the appropriate secure dynamic-update setting. **Tools → DHCP → IPv4 → scope** shows range, exclusions, reservations, leases and **Scope Options** (003 Router, 006 DNS Servers, 015 DNS Domain Name). Record each before editing.

**Typing (check):**

```powershell
Get-DnsServerZone
Get-DnsServerForwarder
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.example.test
Get-DhcpServerv4Scope
Get-DhcpServerv4OptionValue -ScopeId 192.168.10.0
```

Use actual domain/scope. Required DNS SRV answers should identify the expected DC. DHCP range must exclude static server addresses. Role cmdlets are available only with the relevant modules.

**Typing (backup/fix, only when appropriate):** Before DHCP edits:

```powershell
Backup-DhcpServer -Path C:\CP-Backups\DHCP
```

Use the GUI to correct the exact wrong scope option, unauthorized transfer destination or dynamic-update setting. Do not delete a working zone/scope to rebuild it from memory. Do not change NIC DNS to a public resolver to bypass internal-DNS errors.

**Check it worked:**

```powershell
dcdiag /test:dns
repadmin /replsummary
w32tm /query /status
```

Use these on the appropriate DC; no replication partners can be normal for a single-DC lab. Investigate errors rather than assuming they are all scoring issues. Renew a noncritical authorized client's DHCP lease and test internal hostname lookup and domain login.

**Undo:** Restore the recorded specific zone/scope option or use the role's reviewed backup procedure. Restore AD-integrated data with AD-aware recovery; arbitrary file copying into DNS/NTDS directories is unsafe.

**Warnings:** Never disable DNS, Kdc, NTDS, Netlogon, DFSR or W32Time on a required DC. DHCP failover and approved secondary DNS servers may be implicit dependencies even if the README does not enumerate every service name.

### 12.5 IIS, FTP and File and Storage Services recovery

- [ ] Done

**What:** Secure required published content and file access while preserving application identities.

**Why it matters:** Server-wide IIS edits affect all sites. Share and NTFS ACLs jointly control network access. TLS without a usable certificate/client can stop a required service.

**Before changing anything:** Record site bindings, certificates, application pool identities, content paths, FTP users/data ports and share ACLs. Back up IIS configuration:

```powershell
& "$env:windir\system32\inetsrv\appcmd.exe" add backup BeforeCP
```

Choose a unique name on subsequent runs. Separately back up content and databases; IIS config backup does not preserve them.

**Clicking (GUI):** `inetmgr` → site → **Bindings**, **Authentication**, **Directory Browsing**, **Logging** and **Application Pools → Advanced Settings → Identity**. Apply the earlier section's settings at the intended site, considering inheritance. For FTP inspect **FTP Authentication**, **Authorization Rules**, **SSL Settings**, **User Isolation** and **Firewall Support**. In **Server Manager → File and Storage Services → Shares**, inspect required shares; then inspect each folder's NTFS Security tab as in Windows 19.7.

**Typing (check):**

```powershell
Import-Module WebAdministration
Get-Website | Format-Table Name,State,PhysicalPath
Get-WebBinding | Format-Table protocol,bindingInformation
Get-ChildItem IIS:\AppPools | Select-Object Name,State,processModel
Get-SmbShare | Format-Table Name,Path,Description
```

**Typing (fix, only when appropriate):** Prefer a scoped site change; for an actual site named `Company`:

```powershell
Set-WebConfigurationProperty -PSPath 'IIS:\Sites\Company' -Filter system.webServer/directoryBrowse -Name enabled -Value $false
```

Only disable browsing if directory listing is not required. Preserve the intended site authentication; public anonymous access is normal for many websites. Apply least privilege to an app pool without breaking access to its content/database/certificates. Do not deny all unlisted extensions without an application inventory.

**Check it worked:** Test the actual hostname/port from an authorized client, including required login, static/dynamic pages, upload and database-backed behavior. For FTP, test both authentication and a data transfer; passive data ports must match firewall/server configuration. For shares, test read/write under an ordinary authorized user, not only an admin.

**Undo:** Restore the exact site setting or, if needed and after reviewing other sites' changes:

```powershell
& "$env:windir\system32\inetsrv\appcmd.exe" restore backup BeforeCP
```

This affects the saved IIS server configuration. Restore content/database/ACL changes separately from their specific backups.

**Warnings:** Do not disable TLS protocols until required clients have been checked and patches/certificates are ready. Hide-version settings do not substitute for updates. A web shell investigation must preserve evidence and compare files with trusted application sources before deletion.

### 12.6 Remote management, firewall, updates and audit completion

- [ ] Done

**What:** Preserve secure remote administration, installed roles and useful logs through updates.

**Why it matters:** Broad firewall blocks can break RPC-dependent AD/management even when obvious ports are open. A workstation port list is insufficient for a DC.

**Before changing anything:** Export firewall/audit policy using Windows 19.1. Record required management source networks and installed antivirus/WSUS configuration. Keep console access.

**Clicking (GUI):** **Server Manager → Local Server → Remote management / Remote Desktop**. Use NLA and authorized RDP membership. `wf.msc` → inspect built-in **role-specific** rules and their scopes; keep required AD/DNS/DHCP/SMB/RPC traffic. **Settings → Update & Security / Windows Update** varies by version; on Core use supported `sconfig` update options. In Event Viewer inspect **Security**, **System**, **Directory Service**, **DNS Server** and **DFS Replication** as applicable.

**Typing (check):**

```powershell
winrm get winrm/config/service
winrm enumerate winrm/config/listener
Get-NetFirewallProfile
Get-Service WinRM,EventLog,mpssvc,wuauserv | Format-Table Name,Status,StartType
Get-MpComputerStatus | Select-Object AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled
```

WinRM should normally reject Basic authentication and unencrypted traffic. HTTP transport with Kerberos can still encrypt messages; do not equate every port-5985 session with plaintext. Do not expand TrustedHosts to `*` to bypass name/authentication problems.

**Typing (fix, only when appropriate):** In the WinRM policy GUI disable Basic and unencrypted traffic at the correct scope. Restrict the corresponding built-in firewall rules to authorized management sources after confirming the management connection will remain allowed. Apply approved security/role updates, preserving a legitimate organizational WSUS configuration.

**Check it worked:** From an authorized management host test `Test-WSMan server-name`, an authorized RDP login if required, role-specific client transactions, then DC health commands from 12.4. Confirm new audit events and no relevant new service errors. Use selective advanced audit subcategories as described in Windows 19.4.

**Undo:** Restore the exact changed listener/authentication/rule scope from its record, using the console. For an update regression use the supported recovery method for that exact update; do not disable all updates or the firewall.

**Warnings:** Never remove role-required ports based solely on a short generic list. Do not clear server logs, forcibly stop package installation, or automatically reboot while database/AD recovery is unresolved.
