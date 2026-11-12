# 🪟 Windows Server 2016 / 2019 / 2022 — Complete Standalone CyberPatriot Hardening Handbook

> [!TIP]
> **🧭 Jump to a stage:** [📘 Basics](#stage-1) · [🚀 First steps](#stage-2) · [🛡️ Priority checks](#stage-3) · [⚙️ Services](#stage-4) · [🧰 Advanced](#stage-5) · [✅ Final checks](#stage-6)
> **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution** — commands are for manual, scenario-aware use.

> [!CAUTION]
> **Read the image README before changing accounts, services, authentication, or network access.** Preserve forensic evidence and a recovery path; do not apply every example automatically.

Windows Server 2022 appears in multiple CyberPatriot XIX rounds; use the competition's actual image README and official round materials. **Version and support (November 2026):** Server 2016 extended support ends in January 2027, Server 2019 in January 2029, and Server 2022 in October 2031. Confirm the exact lifecycle date for the installed edition in Microsoft's current lifecycle documentation. Server 2022 moved to extended support in October 2026 but still receives monthly security updates. Never perform a release upgrade to earn speculative points. See [Microsoft's Windows Server release information](https://learn.microsoft.com/en-us/windows-server/get-started/windows-server-release-info).

**This is a self-contained Windows Server guide.** It includes the local-server, domain-member and Domain Controller procedures, plus a complete server-adapted Windows security reference in Part 5. You do **not** need to open the Windows workstation guide. Domain/role requirements take precedence over generic workstation hardening.

**How to use this page:** work through Basics → First Things → Accounts/Password/Defender/Firewall → Required Roles/Remote Access → Advanced Verification → Final Checks. Every major step below includes checks and Server-specific instructions. No scripts or automation are required.

---

**Priority is practical, not a guaranteed score ranking.** The README, forensics questions, permitted tools and actual required services override any generic checklist. Do not remove the only admin, delete evidence, or disable a critical role merely because it appears in a public checklist.

## At-a-glance task map — everything in this one guide

| Need to do | Read this section inside THIS file | Do not overlook |
|---|---|---|
| Determine version, DC/member/standalone, GUI/Core | Part 1 and **1.1** | AD DS installed does not prove the machine is promoted |
| README, forensic questions, initial score and backups | **0**, **0.1**, **1.2** | Preserve evidence before cleanup |
| Standalone/member local users and administrators | **2.1**; **WS.2** | Do not treat domain users as local |
| Active Directory users, privileged groups and service accounts | **2.2–2.5**, **12.2** | krbtgt, computer accounts, managed service accounts |
| Local passwords, domain policy and FGPP | **3.1–3.2**, **12.3** | Account scope and GPO precedence |
| Defender, Firewall, Updates, audit and security options | **5.1–5.4**, **4.1–4.4** | Role-required ports, WSUS and effective policies |
| Services, features, spooler, remote access | **6.1–6.3**, **7.1**, **8.1–8.2** | WinRM, RDP and DC dependency services |
| AD DS, DNS, DHCP, IIS, FTP, SMB and TLS | **9.1–9.7**, **12.4–12.5** | Verify actual client transactions |
| Unwanted software/files, scheduled tasks and persistence | **10**, **WS.12–WS.16**, **WS.19.8**, **WS.21** | Signed/authorized software versus malware |
| PowerShell basics, local permissions, audit and recovery | **WS.19–WS.21** | All present directly below |
| Final cross-role validation | Part 6 | Check score only after functionality |

**Read this document from start to finish for a full image**, or jump to the numbered task for a quick repair. The "WS" reference sections are **embedded in this file**; they are not an external Windows guide. The service, account and policy exceptions for Domain Controllers always take precedence.

---


---

<a id="stage-1"></a>
> [!IMPORTANT]
> **🎯 HOW TO USE:** Each **DO THIS** checkbox is the action to complete **only when applicable to the image README**. When present, **⭐ EASIEST WAY — GUI** is the recommended path. **🔁 ALTERNATE** commands are optional ways to do the same task; blue **NOTE** boxes hold explanations and extra context, while **CAUTION/WARNING** boxes explain safety/undo. **Never run both methods just to gain points.**

## Part 1 — Basics / Information Needed

> [!TIP]
> 📘 **Foundation:** Review the key terms and available tools before making changes.

### Identify what kind of Windows Server this is

A Windows Server can be standalone, a domain member, or a Domain Controller. **Domain Controller services and directory/GPO policies must not be treated like optional workstation services.**

**⭐ EASIEST WAY — Click through the GUI:** Open **Server Manager → Local Server**; inspect **Manage → Add Roles and Features** without making changes. ADUC, DNS, DHCP, IIS and Group Policy consoles are available only when the relevant roles/tools exist.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber
> Get-CimInstance Win32_ComputerSystem | Select-Object DomainRole,Domain,PartOfDomain
> Get-WindowsFeature | Where-Object InstallState -eq Installed | Select-Object Name,DisplayName
> ~~~
>
DomainRole 4 or 5 indicates a domain controller. Domain role and README requirements take precedence over the embedded workstation appendix. Keep console access before changing RDP/WinRM/firewall.

---

<a id="stage-2"></a>
## Part 2 — First Things to Do

> [!IMPORTANT]
> 🚀 **Start here:** Follow the image README, preserve forensics, and confirm administrative recovery.

Read the README, preserve forensics and determine the server's exact domain role before any account or firewall changes.

### 0. Before you touch anything

- [ ] **🎯 DO THIS —** Done — Read the image README fully; record authorized **domain/local users**, administrators, required roles, hostnames, shares, web sites, DNS zones, DHCP scopes, service accounts, and prohibited items.
- [ ] **🎯 DO THIS —** Done — Open the scoring report and note initial score/time. Do not modify scoring-engine files.
- [ ] **🎯 DO THIS —** Done — Open **Windows PowerShell as Administrator** through Start → type PowerShell → right-click → Run as administrator. On Server Core, use the console or supported sconfig/PowerShell.
- [ ] **🎯 DO THIS —** Done — Preserve the evidence and answer **all forensics questions** before user deletion, malware cleanup, log changes, or installation.
- [ ] **🎯 DO THIS —** Done — Record a recovery/VM-console path and create a snapshot only if competition rules permit. A rollback loses later changes.

**⭐ EASIEST WAY — GUI (Desktop Experience):** Open **Server Manager → Local Server** to identify Windows version/domain/remote-management status; **Manage → Add Roles and Features** (inspect only) for server roles; **Tools → Computer Management → Services** for running dependencies; **Event Viewer** for recent errors. Do not make changes during inventory.

> [!NOTE]
> **🔁 ALTERNATE — PowerShell diagnostics (or Server Core):**

~~~powershell
Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,ProductType
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain,DomainRole
whoami /all
Get-WindowsFeature | Where-Object Installed | Select-Object Name,DisplayName
Get-Service | Where-Object Status -eq Running | Select-Object Name,DisplayName
~~~

These commands identify OS role, logged-on security principal, installed Windows Server roles and running services. They do not prove a service is authorized or required; compare everything with the README.

**Forensics (read-only examples, use the actual file path):**

~~~powershell
Get-ChildItem C:\Users -Recurse -Force -Filter '*secret*' -ErrorAction SilentlyContinue
Get-FileHash -LiteralPath 'C:\Users\Example\Documents\evidence.dat' -Algorithm SHA256
Get-WinEvent -FilterHashtable @{LogName='System';StartTime=(Get-Date).AddDays(-2)} -MaxEvents 25
~~~

Never run suspicious executables or clear event logs to investigate them. Record file names, hashes, timestamps and full event messages. Save each answer to the original question file in the required format.

**Where to click:** Server Manager → Local Server; Tools → Computer Management / Event Viewer; Server Manager → File and Storage Services for shares. Actual tools depend on installed roles.

**✅ Check it worked:** You can still log on as an authorized administrator, know the original roles/services/score, and have saved forensic answers. After each later change, verify both the changed setting **and** a required application or domain function. Use the recorded baseline for undo.

### 0.1 Learn the Server GUI, Core and PowerShell conventions

- [ ] **🎯 DO THIS — 0.1 Learn the Server GUI, Core and PowerShell conventions**

| Task | Desktop Experience | Server Core |
|---|---|---|
| Version/role | Server Manager → Local Server | PowerShell, sconfig, systeminfo |
| Services | services.msc and Server Manager | Get-Service, Get-CimInstance Win32_Service |
| Users | Computer Management (non-DC); ADUC (DC) | Get-LocalUser on member/standalone; AD tools on DC |
| Policy | secpol.msc (local); gpmc.msc (domain) | secedit, auditpol, gpresult, role-specific PowerShell |
| Firewall | wf.msc (when GUI installed) | Get-NetFirewallProfile, Get-NetFirewallRule |
| Updates | Server Manager/Settings (version dependent) | sconfig and supported servicing commands |

**PowerShell basics:** Run each command separately and inspect its output. Get-* normally reads; Set-*, Remove-*, Disable-*, New-* and Install-* can change the system. Use Get-Help COMMAND -Full for exact supported parameters. In PowerShell, run **sc.exe**, not sc (which may be an alias).

**Server-only safety:** The Domain Controller has no normal local SAM user database for domain accounts. Do not treat domain accounts as local, do not edit a domain-wide GPO for a local-only problem, and never disable AD/DNS/Kerberos/Netlogon/replication on a required DC. The complete reference material in Part 5 is **inside this file**.

### 1. Is this a Domain Controller?

#### 1.1 Find out what kind of server it is

- [ ] **🎯 DO THIS — 1.1 Find out what kind of server it is**

> [!NOTE]
> **🎯 What:** Distinguish standalone/member server from a promoted Domain Controller **before** using account or Group Policy commands.

> [!NOTE]
> **💡 Why:** Simply seeing the **AD DS** role installed does not prove the machine was promoted to a Domain Controller. Likewise, being **domain-joined** does not make a server a Domain Controller.

**⭐ EASIEST WAY — Click through the GUI:** Open Server Manager → **Local Server** (look at Domain and roles). On an actual Domain Controller, Server Manager → Tools may offer **Active Directory Users and Computers (dsa.msc)**, **Group Policy Management (gpmc.msc)**, **DNS** and other management consoles. The presence of a management console alone is not proof the local machine is a DC.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> (Get-CimInstance Win32_OperatingSystem).ProductType
> (Get-CimInstance Win32_ComputerSystem).DomainRole
> Get-WindowsFeature AD-Domain-Services
> Get-Service NTDS -ErrorAction SilentlyContinue
> ~~~
>
| Check | Interpretation | Correct account/policy location |
|---|---|---|
| OS ProductType = 2; DomainRole = 4 or 5 | Promoted Domain Controller | Domain users in Active Directory; domain policy and DC-linked GPOs |
| ProductType = 3; DomainRole = 3 | Member server | Local SAM + domain users; local policies for local users, domain policies for domain users |
| ProductType = 3; DomainRole = 2 | Standalone server | Local users and local policies |
| AD DS role installed but ProductType still 3 | AD binaries exist, promotion not proven | Do not apply DC-only changes yet |

A server's exact DomainRole, installed role, and running NTDS service are complementary evidence. Treat all domain tools as optional on non-DCs.

**🔎 Check:** Record domain name, primary services and whether this machine must provide AD, DNS, DHCP, IIS or file shares.

> [!WARNING]
> **↩️ Undo:** No changes occur in this step. If a role is not active, do not install/promote it as a quick fix without an explicit task.

#### 1.2 Make a manual baseline (no hardening scripts)

- [ ] **🎯 DO THIS — 1.2 Make a manual baseline (no hardening scripts)**

**Before:** Complete forensics, record necessary user logins and each required role. Confirm management access from VM console if remote access changes fail.

**⭐ EASIEST WAY — GUI:** **Server Manager → Local Server** for network/status, **Win + R → `wf.msc`** for firewall profiles, **Win + R → `services.msc`** for service states and startup types, **Win + R → `taskschd.msc`** for tasks. Write down each original state before any change.

> [!NOTE]
> **🔁 ALTERNATE — PowerShell inventory:**

~~~powershell
Get-NetIPConfiguration
Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction
Get-CimInstance Win32_Service | Select-Object Name,State,StartMode,StartName | Sort-Object Name
Get-ScheduledTask | Select-Object TaskName,TaskPath,State
~~~

**🛠️ Action:** For each task below, note **original value → requested README value → action → verification → rollback**. Do **not** download a generic Windows hardening script or skip steps because a copied checklist contains a "script completed" label.

**🔎 Check:** Verify with the corresponding Get-* command, role/client functional test and fresh scoring report.

> [!WARNING]
> **↩️ Undo:** Restore the single prior policy/group membership/firewall or service setting from your notes; do not reset or reinstall the entire server to undo one step.

> [!CAUTION]
> **⚠️ Warnings:** A server role may have dependencies not explicitly listed in the README (e.g. AD uses DNS and time). Ask what the server is actually serving before changing listener or startup state.

---

<a id="stage-3"></a>
## Part 3 — Commonly Assessed High-Priority Checks

> [!IMPORTANT]
> 🛡️ **Priority checks:** Inspect the most common security categories first; actual scoring remains image-specific.

Prioritize authorized users, domain/local privilege, passwords, Defender/firewall and applicable audit policy without breaking domain authentication.

### 2. Users and groups

#### 2.1 Standalone / member server — fully documented local accounts

- [ ] **🎯 DO THIS — 2.1 Standalone / member server — fully documented local accounts**

> [!NOTE]
> **🎯 What:** Reconcile the *local* accounts and Administrators group on a standalone/member server. Domain accounts are still administered in Active Directory at the proper domain scope.

**⭐ EASIEST WAY — Click through the GUI:** Win + R → **lusrmgr.msc** (or Computer Management → Local Users and Groups → Users/Groups). Review **Users** and then double-click **Administrators**, **Remote Desktop Users**, **Backup Operators** and any other privileged groups.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-LocalUser | Format-Table Name,Enabled,PasswordRequired,PasswordExpires,LastLogon
> Get-LocalGroupMember -Group 'Administrators'
> Get-LocalGroupMember -Group 'Remote Desktop Users' -ErrorAction SilentlyContinue
> ~~~
>
If Get-LocalGroupMember fails due to unresolved SIDs or availability, inspect built-in command output:

~~~powershell
net user
net localgroup Administrators
~~~

Compare members with the README. On a domain member, authorized domain users/groups can be intentionally present in the **local** Administrators group.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> Create a named local user without putting the password in shell history:
>
> ~~~powershell
> New-LocalUser -Name 'exampleuser' -Password (Read-Host -AsSecureString 'Choose password')
> ~~~
>
Add the specifically authorized local/domain identity to the local Administrators group:

~~~powershell
Add-LocalGroupMember -Group 'Administrators' -Member 'exampleuser'
~~~

Remove one **confirmed unauthorized** account from local Administrators, but don't remove your only admin or a required domain group:

~~~powershell
Remove-LocalGroupMember -Group 'Administrators' -Member 'exampleuser'
~~~

Disable one confirmed unauthorized local login (prefer disabling until forensic evidence is preserved):

~~~powershell
Disable-LocalUser -Name 'exampleuser'
~~~

Only when the README specifically requires resetting an authorized local user's password:

~~~powershell
Set-LocalUser -Name 'exampleuser' -Password (Read-Host -AsSecureString 'New local password')
~~~

**✅ Check it worked:** Repeat Get-LocalUser and Get-LocalGroupMember; test a new permitted admin login and required local software or file sharing.

> [!WARNING]
> **↩️ Undo:** Use Enable-LocalUser, Add-LocalGroupMember or Remove-LocalGroupMember to reverse only the original exact account/group change; a deleted account or home directory is not reliably restored by simply creating a new user.

> [!CAUTION]
> **⚠️** Never delete Administrator, Guest, DefaultAccount, or other built-in identities. Disable the Guest account unless the actual README requires it; built-in Administrator may be needed for recovery and should not be disabled blindly. Do not remove domain service accounts or domain groups based on local-only naming assumptions. Account deletion is irreversible without suitable backups.

#### 2.2 Domain Controller — domain users and authorized accounts

- [ ] **🎯 DO THIS — 2.2 Domain Controller — domain users and authorized accounts**

**⭐ EASIEST WAY — Click through the GUI:** Win + R → **dsa.msc** → Active Directory Users and Computers. Enable **View → Advanced Features**, expand every OU and Users container, and examine users, service identities, computers and group membership. Right-click the exact user → **Properties → Account / Member Of**; prefer **Disable Account** before irreversible removal for an unauthorized account.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Import-Module ActiveDirectory
> Get-ADUser -Filter * -Properties Enabled,LastLogonDate,PasswordNeverExpires |
>   Select-Object SamAccountName,Enabled,PasswordNeverExpires,DistinguishedName |
>   Format-Table -AutoSize
> Get-ADComputer -Filter * | Select-Object Name,Enabled
> ~~~
>
**Compare to README:** Built-in Administrator, krbtgt, computer accounts and required service/managed service accounts must remain. A service may rely on an account not listed among human students; investigate its role.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Disable-ADAccount -Identity 'exampleuser'
> ~~~
>
Create a specifically required user with a secure prompt and the appropriate existing OU, then inspect it:

~~~powershell
New-ADUser -Name 'exampleuser' -SamAccountName 'exampleuser' -AccountPassword (Read-Host -AsSecureString 'Password for authorized user') -Enabled $true
Get-ADUser -Identity 'exampleuser'
~~~

Before running create, ensure the user doesn't already exist and choose the **exact OU/UPN** required by the README. Never use a generic name on a live image. For a necessary password reset:

~~~powershell
Set-ADAccountPassword -Identity 'exampleuser' -Reset -NewPassword (Read-Host -AsSecureString 'New password')
~~~

**🔎 Check:** Query the exact user again and confirm a fresh authorized login. Password changes to service identities can break scheduled tasks, IIS pools, databases and other services.

> [!WARNING]
> **↩️ Undo:** Enable-ADAccount restores a mistakenly disabled account when permitted; deleted AD objects require AD-aware backup/recycle-bin restoration and are **not** equivalent to creating another user with the same name.

**Never:** Blindly run Remove-ADUser, clear user profiles, change krbtgt, delete computer objects or rotate a service credential without explicit justification and recovery.

#### 2.3 Domain Controller: powerful groups
- [ ] **🎯 DO THIS — 2.3 Domain Controller: powerful groups**

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

**⭐ EASIEST WAY — GUI:** **Win + R → `dsa.msc` → Active Directory Users and Computers → View → Advanced Features** → expand **Users** and the relevant OUs → double-click each privileged group (**Domain Admins**, **Enterprise Admins**, **Schema Admins**, **Administrators**, **DNSAdmins**, etc.) → **Members**. Review nested groups as well. Remove only a **confirmed unauthorized** member → Apply → OK; preserve all built-in, service and authorized roles.

**✅ VERIFY:** Reopen the group, check the direct/nested members and test necessary directory/domain services. **↩️ UNDO:** Re-add only a mistakenly removed member based on its recorded original membership.

> [!NOTE]
> **🔁 ALTERNATE — PowerShell (also for Server Core or remote administration):**
```powershell
foreach ($g in 'Domain Admins','Enterprise Admins','Schema Admins','Administrators','Account Operators','Backup Operators','Server Operators','Print Operators','DnsAdmins','Group Policy Creator Owners') {
  "--- $g"; (Get-ADGroupMember $g -ErrorAction SilentlyContinue).SamAccountName }
Remove-ADGroupMember -Identity 'Domain Admins' -Members 'exampleuser' -Confirm
# Add-ADGroupMember -Identity 'Domain Admins' -Members 'authorizeduser'  # only if README specifically requires that privilege
Get-ADGroupMember 'Domain Admins' -Recursive | Select-Object SamAccountName   # also shows people hidden inside a nested group
```

> [!CAUTION]
> Some members are there by default: leave them. **Administrators** contains the groups **Domain Admins** and **Enterprise Admins** and the built-in **Administrator**; **Domain Admins**, **Enterprise Admins** and **Schema Admins** contain **Administrator**. Remove only *people* (and planted groups) the README doesn't list as admins.

#### 2.4 Domain Controller: risky account settings
- [ ] **🎯 DO THIS — 2.4 Domain Controller: risky account settings**

**⭐ EASIEST WAY — Click through the GUI:** in `dsa.msc`, double-click a user → **Account** tab → **Account options**. These should all be **unticked**:
- Password never expires
- Store password using reversible encryption
- Do not require Kerberos preauthentication (lets attackers crack the password offline)
- Password not required (not shown here; use PowerShell)

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-ADUser -Filter 'Enabled -eq $true' -Properties PasswordNeverExpires, PasswordNotRequired, AllowReversiblePasswordEncryption, DoesNotRequirePreAuth |
>   Where-Object { $_.PasswordNeverExpires -or $_.PasswordNotRequired -or $_.AllowReversiblePasswordEncryption -or $_.DoesNotRequirePreAuth } |
>   Format-Table SamAccountName, PasswordNeverExpires, PasswordNotRequired, AllowReversiblePasswordEncryption, DoesNotRequirePreAuth
> Set-ADUser bob -PasswordNeverExpires $false -PasswordNotRequired $false -AllowReversiblePasswordEncryption $false
> Set-ADAccountControl bob -DoesNotRequirePreAuth $false
> ```

#### 2.5 Strong passwords
- [ ] **🎯 DO THIS — 2.5 Strong passwords**

```powershell
Set-ADAccountPassword -Identity bob -Reset -NewPassword (Read-Host -AsSecureString "New password")
```

---

### 3. Password and lockout policy

#### 3.1 Standalone or member server — local password and lockout policies

- [ ] **🎯 DO THIS — 3.1 Standalone or member server — local password and lockout policies**

**⭐ EASIEST WAY — Click through the GUI:** Win + R → **secpol.msc** → **Account Policies → Password Policy**, then **Account Lockout Policy**. For a member server, also inspect effective domain Group Policy: a domain account's password policy is not controlled by this local setting.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> net accounts
> gpresult /r /scope computer
> ~~~
>
The exact password and lockout requirements must come from the README. An **illustrative** commonly used policy is:

| Policy | Example only — follow actual image requirements |
|---|---|
| Password history | 24 previous passwords |
| Maximum age | 90 days |
| Minimum age | 1 day |
| Minimum length | 12 characters |
| Complexity | Enabled |
| Reversible encryption | Disabled |
| Lockout threshold | 5 failed attempts |
| Lockout duration | 30 minutes |
| Reset lockout counter | 30 minutes |

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> net accounts /uniquepw:24 /maxpwage:90 /minpwage:1 /minpwlen:12
> net accounts /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30
> ~~~
>
Complexity and reversible encryption are **not set by net accounts**. Use **secpol.msc → Password Policy** or the effective organizational policy. Never import a complete secedit template that overwrites unrelated rights merely to adjust complexity.

**✅ Check it worked:** Rerun net accounts, inspect the corresponding effective security setting, test a noncritical authorized local login, and refresh the score.

> [!WARNING]
> **↩️ Undo:** Restore the individual documented starting policy values using secpol.msc/net accounts. A configured threshold of 0 disables lockout; a lockout duration of 0 means administrative unlock is required on many systems—do not choose them accidentally. Domain account rules belong in the actual domain policy section below.

#### 3.2 Domain Controller — domain default policy and fine-grained policies

- [ ] **🎯 DO THIS — 3.2 Domain Controller — domain default policy and fine-grained policies**

> [!NOTE]
> **🎯 What:** Apply account policy to the **domain**, not a nonexistent DC local account database. The domain-root-linked account policy GPO (commonly **Default Domain Policy**) controls domain default account policy; **fine-grained password policies (FGPP)** can provide different effective settings for chosen users/groups.

**⭐ EASIEST WAY — Click through the GUI:**
1. Win + R → **gpmc.msc** → Forest → Domains → **actual domain**.
2. Select **Group Policy Objects → Default Domain Policy** (or the actual domain-root-linked account-policy GPO); inspect **Scope**, links and existing settings.
3. Back up the specific GPO before modifying it. In Group Policy Management right-click **Back Up** to a private existing folder.
4. Click **Edit → Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies**.
5. Compare **Password Policy** and **Account Lockout Policy** with the exact image README. Example values are in **3.1**; do not treat those numbers as universal requirements.
6. Inspect any resultant fine-grained policy before concluding a domain user inherited the default.
7. Close the editor and allow policy processing. If authorized and useful, run gpupdate /target:computer /force; review errors instead of assuming immediate effect.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-ADDefaultDomainPasswordPolicy | Format-List *
> Get-ADFineGrainedPasswordPolicy -Filter * | Format-Table Name,Precedence,MinPasswordLength,ComplexityEnabled
> Get-ADUserResultantPasswordPolicy -Identity 'exampleuser'
> net accounts /domain
> ~~~
>
**PowerShell change example, ONLY if the README matches and the target domain is correct:**

~~~powershell
Set-ADDefaultDomainPasswordPolicy -Identity 'example.test' -MinPasswordLength 12 -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false -LockoutThreshold 5 -LockoutDuration (New-TimeSpan -Minutes 30) -LockoutObservationWindow (New-TimeSpan -Minutes 30)
~~~

This illustrative command does **not** set maximum/minimum password age; verify those separately and don't assume a partial update satisfied the entire rubric. Replace the domain and all values with the actual required settings.

**🔎 Check:** Repeat the default and resultant policies; inspect RSoP/Group Policy results and test an authorized fresh domain login. Password policy changes generally affect future password changes, not automatically the strength of every existing password.

> [!WARNING]
> **↩️ Undo:** Restore the individual recorded setting or a specific GPO backup after reviewing its intended scope. Do not delete the Default Domain Policy to correct one entry. Domain account lockout may be influenced by FGPP; investigate before editing default values.

### 5. Defender, firewall and updates

#### 5.1 Microsoft Defender Antivirus on Windows Server

- [ ] **🎯 DO THIS — 5.1 Microsoft Defender Antivirus on Windows Server**

> [!NOTE]
> **💡 Why:** Servers 2016, 2019 and 2022 have Windows Defender Antivirus capabilities, but feature availability, security UI, other antivirus modes and management policies differ. The absence of a Windows 11-style GUI on **Server Core** is not proof antivirus protection is missing.

**⭐ EASIEST WAY — Click through the GUI:** On Desktop Experience, use **Windows Security → Virus & threat protection** when available (on Server 2016 the Defender GUI may need a separate feature). In Server Manager inspect **Add Roles and Features → Features → Microsoft Defender Antivirus** without installing anything yet.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-WindowsFeature Windows-Defender*
> Get-MpComputerStatus | Select-Object AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled,AntivirusSignatureVersion,AntivirusSignatureLastUpdated
> Get-MpPreference | Select-Object ExclusionPath,ExclusionExtension,ExclusionProcess
> Get-Service WinDefend -ErrorAction SilentlyContinue
> ~~~

> [!NOTE]
> **🧠 Interpret:** Another enterprise antivirus may put Defender in a passive mode. Existing exclusions may be required for IIS, SQL, AD, backup or other approved workloads; investigate each before removing. A service not continuously running can be normal for some protective components; confirm effective provider and policies.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Update-MpSignature
> ~~~
>
An approved targeted scan can use Start-MpScan with appropriate parameters. A full scan may disrupt a busy server; avoid indiscriminate scans while required roles are already under load. If the antivirus **feature is actually uninstalled**, and the image requires it, review dependencies and installation sources before using:

~~~powershell
Install-WindowsFeature -Name Windows-Defender
~~~

The above changes server features and may require a reboot; do **not** run solely because a GUI page is missing. Windows Server 2016 Defender GUI can be an optional feature separate from the actual engine. On Server Core use PowerShell/enterprise management.

**✅ Verify:** Repeat Get-MpComputerStatus, review protection/error events and required workloads, and refresh the score.

> [!WARNING]
> **↩️ Undo:** Restore only a changed antivirus setting/exclusion/feature from its approved baseline. Never disable antivirus broadly to work around one application error.

**Vendor reference:** [Microsoft Defender Antivirus on Windows Server](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows-server-configure).

#### 5.2 Windows Server Firewall — role-aware, standalone procedure

- [ ] **🎯 DO THIS — 5.2 Windows Server Firewall — role-aware, standalone procedure**

> [!NOTE]
> **🎯 What:** Keep the host firewall enabled on all required profiles while allowing **only the necessary authorized sources** to reach Active Directory, DNS, DHCP, IIS, SMB, remote management and other installed roles.

**⭐ EASIEST WAY — Click through the GUI:** Win + R → **wf.msc** → Windows Defender Firewall with Advanced Security. Review **Properties → Domain, Private and Public Profile**, then **Inbound Rules** and the existing built-in role-specific groups. On Server Core use the PowerShell method below.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction,DefaultOutboundAction
> Get-NetFirewallRule -PolicyStore ActiveStore -Direction Inbound -Enabled True |
>   Select-Object DisplayName,Action,Profile | Format-Table -AutoSize
> Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess | Sort-Object LocalPort
> ~~~
>
**Explain:** Enabled does not mean a rule is actually applicable to that client's profile/source/destination. A listening socket is not necessarily reachable from another host. The effective firewall may be centrally managed by Group Policy.

**Server role dependencies — preserve these if required:**

| Role | Example network functions to verify | Avoid blindly disabling |
|---|---|---|
| AD Domain Controller | Kerberos, LDAP, DNS, RPC endpoint mapping/dynamic RPC, SYSVOL/NETLOGON, time, replication | Built-in AD/DNS/Kerberos/Netlogon/DFS groups and required dynamic RPC paths |
| DNS server | Queries on UDP and TCP 53 | DNS Service |
| DHCP server | Client lease/relay exchanges | DHCP Server and relay/authorization paths |
| IIS | Expected TCP HTTP/HTTPS and application-specific ports | Required web listener/site |
| File server | SMB TCP 445 and authorized access | Needed shares/SMB |
| Remote administration | Authorized RDP/WinRM/SSH and management source ranges | Required remote-console path |

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
> ~~~
>
Never run a blanket disable command for all role-specific rules. For a specific suspicious inbound rule, inspect exact name, filters, group, owner and authorized clients **before** disabling it via the GUI.

**✅ Check it worked:** Repeat profile/rule inspections and test approved DNS, AD logon, DHCP lease, IIS page, share and remote admin from a proper client. Preserve at least one management recovery path.

> [!WARNING]
> **↩️ Undo:** Revert only the explicitly changed profile or rule to its original documented state and retest. Restoring a firewall profile blindly to Disabled can expose the server; investigate the original intended policy and actual failure.

#### 5.3 Windows Server updates and security maintenance

- [ ] **🎯 DO THIS — 5.3 Windows Server updates and security maintenance**

**⭐ EASIEST WAY — Click through the GUI:** Server Manager → Local Server → Windows Update (or **Settings → Update & Security**, depending on version). On Server Core use **sconfig** and its update workflow. Check whether the machine uses a legitimate **WSUS** or domain-managed update policy first.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-Service wuauserv,BITS,EventLog -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 12 HotFixID,InstalledOn
> gpresult /r /scope computer
> ~~~
>
**Meaning:** Windows Update's service can be Stopped when idle without being disabled. Get-HotFix lists some installed updates, **not every missing or pending update**. Check Windows Update or the organization's approved update tool for pending updates.

**Change:** Install only the approved security/role updates via the system's supported UI/sconfig/WSUS. Don't force a release upgrade, remove update policy keys, disable WSUS or reboot a required Domain Controller or database server without checking the image's instructions and application health.

**✅ Verify:** Review Windows Update history, failures, pending reboot, service functionality and the scoring report. If a specific patch causes a regression, follow the supported recovery for that exact update; do not broadly disable updates.

#### 5.4 Internet Explorer Enhanced Security Configuration (IE ESC)

- [ ] **🎯 DO THIS — 5.4 Internet Explorer Enhanced Security Configuration (IE ESC)**

**⭐ EASIEST WAY — Click through the GUI:** Server Manager → Local Server → **IE Enhanced Security Configuration**. Inspect Administrators and Users. On legacy Server installations it is a protective setting; leave it enabled unless the scenario or a required application expressly needs a different setting. **Server Core may not have the UI**.

**🔎 Check:** Record the actual intended role of IE/legacy components; don't enable an obsolete browser or disable modern protections for scoring. No configuration change is required if the setting is already compliant.

> [!WARNING]
> **↩️ Undo:** Restore the recorded original setting using Server Manager if the change breaks a required legacy application.

---

### 4. Audit policy, user rights and security options

#### 4.1 Standalone/member server — audit policy, user rights and security options

- [ ] **🎯 DO THIS — 4.1 Standalone/member server — audit policy, user rights and security options**

**⭐ EASIEST WAY — Click through the GUI:** Win + R → **secpol.msc → Local Policies → Audit Policy**, **User Rights Assignment** and **Security Options**. For newer systems also inspect **Advanced Audit Policy Configuration → System Audit Policies**. If domain-joined, use **gpresult /h** or Group Policy Results to find policy source—local edits can be overridden.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> auditpol /get /category:*
> secedit /export /cfg "$env:TEMP\server-security-policy.inf" /areas SECURITYPOLICY USER_RIGHTS
> Select-String -Path "$env:TEMP\server-security-policy.inf" -Pattern 'PasswordComplexity|ClearTextPassword|SeRemoteInteractiveLogonRight|SeDenyInteractiveLogonRight'
> gpresult /r /scope computer
> ~~~
>
**Check rights for:** local logon, network access, Remote Desktop logon, Backup/Restore privileges, Debug programs, Load drivers, audit/security log management, Deny logon rights, and impersonation rights. Determine roles **before** removing anyone: built-in system principals, services and authorized domain groups may be required.

**Audit policy:** Favor role-appropriate account logon, account management, logon/logoff, policy change, process creation and directory-related events where supported. **Do not enable every Success/Failure audit subcategory blindly**; excessive events can obscure evidence and consume log storage.

**Windows Security Options to inspect (not arbitrary universal values):**

| Option family | Defensive check |
|---|---|
| Guest and empty passwords | Disabled guest or policy-required access |
| UAC and administrative approval | No unauthorized bypass; preserve management |
| SMB client/server signing | Compatible required share/client policy |
| NTLM/LM protocol | Disable legacy modes only after required-auth compatibility check |
| Anonymous enumeration and shares | No unapproved anonymous access |
| Interactive logon inactivity/message | Follow README, avoid locking out necessary console |
| Cached logons and domain fallback | Role-specific policy, not a blanket 0 |

**How to change:** Open the single identified item in secpol.msc/GPO and record old/new values; do not paste a generic all-settings secedit template that overwrites unrelated privileges.

**✅ Verify:** Re-export the relevant security policy, run auditpol /get, inspect effective GPO, perform an authorized login, test required file/network access, and check fresh Security log events.

> [!WARNING]
> **↩️ Undo:** Restore the precise original right/audit/option from notes or a valid scoped backup; do not remove NT SERVICE, LOCAL SERVICE or NETWORK SERVICE principals as a blanket restriction.

#### 4.2 Domain Controller — DC-specific Group Policy, auditing and user rights

- [ ] **🎯 DO THIS — 4.2 Domain Controller — DC-specific Group Policy, auditing and user rights**

**Critical distinction:** The **Default Domain Policy** or domain-root-linked policy ordinarily controls **domain password/account policy**. The **Default Domain Controllers Policy** or another GPO linked to the **Domain Controllers OU** commonly controls DC-specific security rights, audit and options. GPO links and precedence matter: never assume a particular GPO wins without checking.

**⭐ EASIEST WAY — Click through the GUI:**
1. Win + R → **gpmc.msc** → Forest → Domains → **your domain**.
2. Open the **Domain Controllers OU** and inspect linked GPOs, enforcement/inheritance and the winning DC policy.
3. Right-click the specific GPO → **Back Up** before making any changes.
4. Right-click → **Edit → Computer Configuration → Policies → Windows Settings → Security Settings**.
5. Inspect **Local Policies → User Rights Assignment / Security Options** and **Advanced Audit Policy Configuration**. Only apply the exact approved policy change at the scope that owns it.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-GPO -All | Sort-Object ModificationTime -Descending | Select-Object DisplayName,Id,ModificationTime
> Get-GPOReport -All -ReportType Html -Path "$env:TEMP\dc-gpo-report.html"
> auditpol /get /category:*
> ~~~
>
Use the **GPMC Backup** command to save only the actual GPO(s) you intend to change to a private folder. Don't bulk-overwrite domain policies as a first step.

**DC Security Options and compatibility checks:**

| Policy/role | What to verify before enforcing |
|---|---|
| LDAP server signing requirements | Authorized LDAP clients can sign or use secured mechanisms; inspect modern baseline guidance |
| LDAP channel binding | Required LDAPS/TLS clients support selected binding mode; stage before strict Always |
| Domain Controller Netlogon secure channel | Modern patched Netlogon enforcement, no unnecessary vulnerable exceptions |
| Anonymous network access | Preserve Authenticated Users, required DC principals, and legitimate trusts |
| Machine-account passwords and secure channel | Never deny legitimate computer password rotation |
| Remote Desktop access | Only approved administrators/management accounts |
| Advanced audit policy | Role-specific account logon, DS access, account changes and policy events with workable retention |

**DC user rights require extra caution:** **Access this computer from the network** includes principals needed for member computers/AD functionality; blindly removing Authenticated Users or Enterprise Domain Controllers can break the domain. **Allow log on locally**, **Deny log on** and **Remote Desktop Services** rights are not identical to workstation defaults. Do not add Domain Users to local DC console access or deny an entire service group.

**🔎 Check:** Use the Group Policy Results wizard or:

~~~powershell
gpresult /r /scope computer
auditpol /get /category:*
~~~

Review actual DC audit events and test fresh domain user logon, DC DNS, SYSVOL/NETLOGON access and any other README-required role.

> [!WARNING]
> **↩️ Undo:** Restore the **specific** GPO backup/setting after verifying the affected scope, not every GPO. Re-run policy and required-client tests; never delete the Default Domain Controllers Policy to undo one change.

#### 4.3 Look for planted bad Group Policies
- [ ] **🎯 DO THIS — 4.3 Look for planted bad Group Policies**

> [!NOTE]
> **💡 Why:** An attacker can create or change a GPO to turn off the firewall, add an admin, or run a script on every computer.

**⭐ EASIEST WAY — Click through the GUI:** In `gpmc.msc`, click each GPO → **Settings** tab (it shows a report). Look for anything that weakens security. Check the **Scope** tab to see where it's linked.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-GPO -All | Sort-Object ModificationTime -Descending | Format-Table DisplayName, ModificationTime
> Get-GPOReport -All -ReportType Html -Path C:\gpo-report.html; Start-Process C:\gpo-report.html
> ```

#### 4.4 Domain Controller: Zerologon protection
- [ ] **🎯 DO THIS — 4.4 Domain Controller: Zerologon protection**

> [!NOTE]
> **💡 Why it matters:** Zerologon (CVE-2020-1472) lets anyone on the network take over a Domain Controller without a password. Windows updates since February 2021 always block it, but a planted policy can let chosen accounts use the weak connection again, and an un-updated image is wide open.

**⭐ EASIEST WAY — Click through the GUI:** In the **Default Domain Controllers Policy** (4.2) → **Security Options** → **Domain controller: Allow vulnerable Netlogon secure channel connections** must be **Not Defined** (no accounts listed). Install updates too (5.3).

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name FullSecureChannelProtection -Value 1 -PropertyType DWord -Force
> Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' | Format-List FullSecureChannelProtection, RequireSignOrSeal, RequireStrongKey
> ```
**✅ Check it worked:** `FullSecureChannelProtection` shows `1`. `RequireSignOrSeal` and `RequireStrongKey` are normally `1` too; if one of them is missing, that is fine, it follows the policy default.

---

<a id="research-expansion-check-directory-dns-time-and-replication-safely"></a>
### 🧰 check directory, DNS, time and replication safely

- [ ] **🎯 DO THIS —** Confirmed whether AD DS, DNS, DHCP or other required server roles are installed and functioning.

~~~powershell
Get-Service NTDS,DNS,Netlogon,DFSR,W32Time -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
Get-Command Get-ADUser,Get-DnsServerZone,Get-DhcpServerv4Scope,Get-Website -ErrorAction SilentlyContinue
~~~

**Only on a Domain Controller or authorized DC diagnostic environment:**

~~~powershell
dcdiag /q
repadmin /replsummary
w32tm /query /status
~~~

> [!NOTE]
> **What to look for:** Directory authentication, SYSVOL/DFSR, DNS, replication and clock health. A single-controller lab may have no replication partners; investigate output instead of "repairing" imaginary peers.

**Domain privilege review (only when AD PowerShell is available):**

~~~powershell
Get-ADGroupMember -Identity 'Domain Admins' -ErrorAction SilentlyContinue | Select-Object Name,ObjectClass
Get-ADUser -Filter * -Properties Enabled,PasswordNeverExpires | Select-Object SamAccountName,Enabled,PasswordNeverExpires
~~~

**Safety:** Do not disable necessary built-in principals, domain service identities or krbtgt. These commands require appropriate domain privileges and management modules. Confirm effective GPO scope and role dependencies before changing policy.

<a id="research-report-expansion-ws-r1--ad-privileged-groups-service-accounts-and-safe-reversibility"></a>
### 🔐 AD privileged groups, service accounts and safe reversibility

- [ ] **🎯 DO THIS — 🔐 AD privileged groups, service accounts and safe reversibility**

> [!NOTE]
> **📚 Evidence:** Community/training categories with vendor-backed Active Directory management commands. Not a guarantee of actual scoring.

> [!NOTE]
> **💡 Why:** Domain Admins, Enterprise Admins, Schema Admins and nested membership can confer privileges beyond a user's visible OU. Service identities and computer objects may be required.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → dsa.msc → View → Advanced Features**. Examine all OUs, the group **Members** and each user's **Member Of / Account** tabs; identify built-in, managed service and computer accounts.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-ADUser -Filter * -Properties Enabled,PasswordNeverExpires,PasswordNotRequired,DoesNotRequirePreAuth |
>  Select-Object SamAccountName,Enabled,PasswordNeverExpires,PasswordNotRequired,DoesNotRequirePreAuth
> Get-ADGroupMember -Identity 'Domain Admins'
> Get-ADGroupMember -Identity 'Domain Admins' -Recursive
> Get-ADGroupMember -Identity 'Enterprise Admins' -ErrorAction SilentlyContinue
> Get-ADGroupMember -Identity 'Schema Admins' -ErrorAction SilentlyContinue
> ~~~
>
Enterprise/Schema Admins groups may not be in the current domain; determine the forest root and effective role rather than treating a missing group as an error.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Remove-ADGroupMember -Identity 'Domain Admins' -Members 'EXAMPLE_USER' -Confirm
> ~~~
>
For confirmed unauthorized domain login containment, after preserving evidence:

~~~powershell
Disable-ADAccount -Identity 'EXAMPLE_USER'
~~~

**✅ Verification:** Re-run both direct and recursive group queries; verify a new legitimate domain logon and required IIS/task/service identity functions. Existing sessions may retain old group tokens until reauthentication.

> [!WARNING]
> **↩️ Undo:** Restore **only** the mistakenly removed direct membership with **Add-ADGroupMember** or re-enable a mistakenly disabled account using **Enable-ADAccount**. Never delete or reset **krbtgt**, domain built-in Administrator, computer objects or required service accounts during routine checklist hardening.

<a id="research-report-expansion-ws-r2--domain-password-policy-fgpp-and-resultant-policy"></a>
### 🔐 Domain password policy, FGPP and resultant policy

- [ ] **🎯 DO THIS — 🔐 Domain password policy, FGPP and resultant policy**

> [!NOTE]
> **📚 Evidence:** Community/vendor-backed. Domain password and lockout settings are not interchangeable with member-server local policy.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → gpmc.msc → Forest → Domains → your domain**. Inspect the **domain-root-linked** account policy GPO (often Default Domain Policy) → Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies. Check OU links and GPO precedence, and back up the specific GPO before editing.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-ADDefaultDomainPasswordPolicy | Format-List *
> Get-ADFineGrainedPasswordPolicy -Filter * | Select-Object Name,Precedence,MinPasswordLength,ComplexityEnabled,LockoutThreshold
> Get-ADUserResultantPasswordPolicy -Identity 'EXAMPLE_USER'
> gpresult /r /scope computer
> ~~~

> [!NOTE]
> **What to look for:** A weak *effective* policy for a user because of fine-grained precedence, password-not-required flags or missing complexity settings; use exact values from the README. The report records conflicting historical community settings (minimum lengths 10–14; maximum ages 60–90 days). These are **examples, not fixed competition scores**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Set-ADDefaultDomainPasswordPolicy -Identity 'example.test' -MinPasswordLength 12 -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false
> ~~~
>
Replace example.test and numbers; this is a *partial illustrative* change and doesn't set every account-policy field. Use GPMC for the exact complete policy or the appropriate FGPP tool if a specific user policy is at fault.

**✅ Verify:** Re-query domain default/resultant policy for affected users and test a normal authorized login. Test required applications that depend on service credentials before considering a password reset.

> [!WARNING]
> **↩️ Undo:** Restore exact old values or scoped GPO backup; account password resets are not reversed by restoring policy. Never delete Default Domain Policy or change the entire forest password policy for one misunderstood workstation issue.

<a id="research-report-expansion-ws-r3--ldap-signingchannel-binding-with-compatibility-checks"></a>
### 🧰 LDAP signing/channel binding with compatibility checks

- [ ] **🎯 DO THIS — 🧰 LDAP signing/channel binding with compatibility checks**

> [!NOTE]
> **📚 Evidence:** Community/vendor-backed; Microsoft has dedicated guidance. Strict enforcement can break old required applications.

> [!NOTE]
> **💡 Why:** Unsigned LDAP binds and absent channel-binding protections can permit credential-relay and downgrade risks. However, a required application may have legacy LDAP behavior; you must identify clients before enforcing stricter settings.

**⭐ EASIEST WAY — Click through the GUI:** **Event Viewer → Applications and Services Logs → Directory Service** (or **Windows Logs** when the platform uses that provider) and **gpmc.msc → appropriate DC-linked GPO → Computer Configuration → Policies → Windows Settings → Security Settings → Local Policies → Security Options**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-WinEvent -FilterHashtable @{LogName='Directory Service';Id=2887,2888,2889} -MaxEvents 40 -ErrorAction SilentlyContinue |
>  Select-Object TimeCreated,Id,Message
> gpresult /r /scope computer
> Get-Service NTDS,Netlogon,Kdc -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> ~~~

> [!NOTE]
> **🧠 Interpretation:** Event 2887 can summarize unsigned LDAP binds when logging is configured. Individual client events such as 2889 may require extra diagnostic logging; **absence of events does not demonstrate that all clients support enforcement**. Channel-binding diagnostics may include other Directory Service event IDs depending on OS and policy.

**Fix only when clients have been inventoried and requirements permit:** Under **Domain controller: LDAP server signing requirements**, choose **Require signing** when compatible. Review the separately configured LDAP channel binding policy according to the installed Server release and client capabilities rather than setting **Always** blindly.

**✅ Verification:** Confirm effective GPO; test LDAP/LDAPS from every required client/application and inspect new Directory Service events. Check normal domain logon and DNS SRV resolution.

> [!WARNING]
> **↩️ Undo:** Restore only the documented policy value from the prior GPO backup if a required legacy client fails. Do not disable LDAP signing globally as a reflexive repair or alter domain-wide NTLM settings blindly.

**Vendor reference:** [Microsoft LDAP signing guidance](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/ldap-signing) and current Windows Server security baselines.

<a id="research-report-expansion-ws-r4--smb1-signing-and-domain-critical-shares"></a>
### 🧰 SMB1, signing and domain-critical shares

- [ ] **🎯 DO THIS — 🧰 SMB1, signing and domain-critical shares**

> [!NOTE]
> **📚 Evidence:** Community/vendor-backed; SMB signing and SMB1 support are separately configurable.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,RequireSecuritySignature
> Get-SmbClientConfiguration | Select-Object RequireSecuritySignature
> Get-SmbShare | Select-Object Name,Path,Special,Description
> ~~~

> [!NOTE]
> **What to look for:** Unauthorized SMB1 compatibility, weak signing if the role requires it, unapproved custom shares and overly broad share rights. **SYSVOL, NETLOGON, administrative shares, and required data shares must not be removed indiscriminately.**

**⭐ EASIEST WAY — Click through the GUI:** Server Manager → **File and Storage Services → Shares**, then the backing folder's **Properties → Security → Advanced**; inspect **both** share permissions and NTFS ACLs.

**Change only when legacy compatibility is ruled out:**

~~~powershell
Set-SmbServerConfiguration -RequireSecuritySignature $true
~~~

To disable SMB1 on Server where it is confirmed unnecessary:

~~~powershell
Set-SmbServerConfiguration -EnableSMB1Protocol $false
~~~

These changes can affect active sessions, GPO and older clients; retain a console path and test clients. Avoid copying a **-Confirm:$false** variant that hides an important safety prompt.

**✅ Verification:** Repeat Get-SmbServerConfiguration, check Get-SmbShareAccess for actual required shares and test SMB read/write from an authorized ordinary user plus an explicitly denied user.

> [!WARNING]
> **↩️ Undo:** Restore only the known old protocol/signing value if the README explicitly requires legacy compatibility. Do not re-enable SMB1 simply to chase points; address compatible client migration where permitted. A removed share must be restored with both the correct share and original NTFS permissions.

**Sources:** [Microsoft SMB signing](https://learn.microsoft.com/en-us/windows-server/storage/file-server/smb-signing-overview) and [SMB server cmdlets](https://learn.microsoft.com/en-us/powershell/module/smbshare/set-smbserverconfiguration).

---

<a id="stage-4"></a>
## Part 4 — Required Server Roles and Remote Access

> [!TIP]
> ⚙️ **Service-aware work:** Check required applications and dependencies before adjusting settings.

Prove required web, directory, DNS, DHCP, SMB and management functions work before hardening them.

### 9. Critical server roles (only if the README lists them)

#### 9.1 IIS web server
- [ ] **🎯 DO THIS — 9.1 IIS web server**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `inetmgr` (IIS Manager). For the server **and each site**:
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

#### 9.2 IIS FTP server
- [ ] **🎯 DO THIS — 9.2 IIS FTP server**

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

#### 9.3 DNS server
- [ ] **🎯 DO THIS — 9.3 DNS server**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `dnsmgmt.msc`. For each **Forward Lookup Zone**, right-click → **Properties**:
- **General → Dynamic updates:** **Secure only** (for AD-integrated zones).
- **Zone Transfers:** untick **Allow zone transfers**, or choose **Only to the following servers** if the README mentions a secondary DNS server.

Look through the records for anything suspicious, e.g. a record for `update.microsoft.com` or `www.bank.com` pointing to a strange IP.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-DnsServerZone | Format-Table ZoneName, ZoneType, DynamicUpdate, SecureSecondaries, IsDsIntegrated
> Set-DnsServerPrimaryZone -Name corp.local -SecureSecondaries NoTransfer -DynamicUpdate Secure   # change corp.local to your zone name
> Get-DnsServerResourceRecord -ZoneName corp.local | Format-Table HostName, RecordType, RecordData
> ```
> `-DynamicUpdate Secure` works only when **IsDsIntegrated** is `True`. For a zone that isn't, use `-DynamicUpdate None` (unless the README needs dynamic updates).

#### 9.4 Active Directory
- [ ] **🎯 DO THIS — 9.4 Active Directory**

- **AD Recycle Bin:** **Active Directory Administrative Center (`dsac.exe`)** → click the domain → **Enable Recycle Bin…** (it can't be turned off later, which is fine).
- **Protected Users group:** admins in it get extra protection. Add only if the README doesn't forbid it.
- **Logon scripts in SYSVOL:** look in `C:\Windows\SYSVOL\domain\scripts` and `C:\Windows\SYSVOL\domain\Policies\*\Machine\Scripts` / `User\Scripts` for scripts you don't recognise.
- **Unconstrained delegation:** `Get-ADComputer -Filter 'TrustedForDelegation -eq $true'`. Only DCs should be listed.
- **Who can add computers:** `Get-ADObject (Get-ADDomain).DistinguishedName -Properties ms-DS-MachineAccountQuota`. Setting it to 0 stops normal users joining computers (optional).

#### 9.5 DHCP server
- [ ] **🎯 DO THIS — 9.5 DHCP server**

`dhcpmgmt.msc`: check the scopes and reservations against the README, and make sure **Enable DHCP audit logging** is ticked (server → **Properties**). Look at **Scope Options** too: a planted **006 DNS Servers** or **003 Router** pointing at a strange IP sends every client to the attacker.

```powershell
Get-DhcpServerv4Scope | Format-Table ScopeId, Name, StartRange, EndRange, State
Get-DhcpServerv4Scope | Get-DhcpServerv4Reservation          # every reservation
Get-DhcpServerv4OptionValue                                  # server options (006 = DNS servers, 003 = router)
Get-DhcpServerv4Scope | Get-DhcpServerv4OptionValue          # options set on each scope
Set-DhcpServerAuditLog -Enable $true
Get-DhcpServerAuditLog
```

#### 9.6 File server shares
- [ ] **🎯 DO THIS — 9.6 File server shares**

**⭐ EASIEST WAY — Click through the GUI:** `fsmgmt.msc` → **Shares**. For each share the README needs: **Properties → Share Permissions** shouldn't give **Everyone: Full Control**, and on the **Security** tab (NTFS), only the right groups should have **Modify / Full control**.

```powershell
Get-SmbShare | ForEach-Object { "--- $($_.Name) $($_.Path)"; Get-SmbShareAccess $_.Name | Format-Table AccountName, AccessRight }
Grant-SmbShareAccess -Name Data -AccountName 'Authenticated Users' -AccessRight Read -Force   # "Data" = your share; use Change only if the README says users must save files here
Revoke-SmbShareAccess -Name Data -AccountName Everyone -Force
Get-SmbServerConfiguration | Format-List EnableSMB1Protocol, RequireSecuritySignature   # want False and True
```
On a Domain Controller, leave **NETLOGON** and **SYSVOL** alone.

#### 9.7 Turn off SSL 3.0, TLS 1.0 and TLS 1.1

**Compatibility preflight:** Record protocol settings and export the exact SCHANNEL key before editing. Check required clients, application/.NET versions, certificates and patches support modern TLS. Apply changes at a recoverable checkpoint; some need service/system restart. Use [12.5](#125-iis-ftp-and-file-and-storage-services-recovery) for backup/client tests. If a legacy required client fails, restore the recorded per-protocol values, including absence of values that did not previously exist, and investigate a supported compatibility path rather than applying a blanket protocol template.
- [ ] **🎯 DO THIS (only if authorized) — 9.7 Turn off SSL 3.0, TLS 1.0 and TLS 1.1**

> [!NOTE]
> **💡 Why it matters:** These old encryption versions have known breaks. Websites (IIS), FTP over SSL, Remote Desktop and LDAPS should all use TLS 1.2 or newer. Server 2016-2022 still allow TLS 1.0 and 1.1 unless you turn them off.

**⭐ EASIEST WAY — GUI (Desktop Experience, only if explicitly required and compatible):** **Win + R → `regedit` → `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols`**. **Export the existing Protocols key** first. For a specifically prohibited legacy protocol, open its **Server** subkey and set/create **DWORD `Enabled` = 0** and **`DisabledByDefault` = 1**. Preserve other protocol keys and verify required clients support TLS 1.2+. Do not blanket-disable a protocol used by a required server role.

**✅ VERIFY:** Inspect only the changed key; test approved HTTPS/LDAPS/FTP/RDP clients after an authorized restart. **↩️ UNDO:** Restore original registry values or their absence from backup, then retest.

> [!NOTE]
> **🔁 ALTERNATE — PowerShell (use only for supported, explicitly-required changes or Server Core):**
```powershell
foreach ($p in 'SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1') {
  $k = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$p\Server"
  if (-not (Test-Path $k)) { New-Item -Path $k -Force | Out-Null }
  New-ItemProperty -Path $k -Name Enabled -Value 0 -PropertyType DWord -Force | Out-Null
  New-ItemProperty -Path $k -Name DisabledByDefault -Value 1 -PropertyType DWord -Force | Out-Null }
```
This changes only what the server *accepts* (the `Server` keys), not how the server connects out, so programs on it that talk to the internet keep working. Restart the server once (near the end, after saving your work) so every service picks it up.

**✅ Check it worked:** `Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server'` shows `Enabled : 0`. Then open the website / connect with RDP to make sure the critical services still work, and refresh the Scoring Report: if it stops updating, undo this step.

> [!CAUTION]
> Very old programs (for example an old SQL Server or FTP server) may only speak TLS 1.0. If a README service stops working after the restart, set `Enabled` back to `1` for the version it needs and restart again.

---

### 6. Services

#### 6.1 Inventory and safely disable only unauthorized services

- [ ] **🎯 DO THIS (only if authorized) — 6.1 Inventory and safely disable only unauthorized services**

> [!NOTE]
> **🎯 What:** Review services by their **real Windows service name**, executable path and dependencies. This section contains the Server-specific service table directly; no workstation checklist is necessary.

**⭐ EASIEST WAY — Click through the GUI:** Win + R → services.msc → select the exact service → Properties. Record **Service name, Display name, Service status, Startup type, Log On As, Dependencies, Path to executable**. If Server Core lacks services.msc, use PowerShell below.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-CimInstance Win32_Service |
>   Select-Object Name,DisplayName,State,StartMode,StartName,PathName |
>   Sort-Object Name | Format-Table -Wrap
> ~~~
>
For **one identified service**:

~~~powershell
Get-Service -Name 'RemoteRegistry' -ErrorAction SilentlyContinue | Format-List *
sc.exe qc RemoteRegistry
~~~

**Choose by README and role.** Services may not be installed on every Server build.

| Service / feature | Internal name / package (typical) | When to leave enabled |
|---|---|---|
| Remote Registry | RemoteRegistry | Required remote registry administration only |
| Telnet Server | TlntSvr (legacy, if installed) | Extremely rare authorized legacy need; consider secured alternatives |
| SNMP / SNMP Trap | SNMP, SNMPTRAP | Authorized legacy monitoring only |
| SSDP Discovery | SSDPSRV | Required discovery workflows only |
| UPnP Device Host | upnphost | Device discovery workflows that truly need it |
| FTP Server | FTPSVC / IIS FTP feature | **Keep** if a required FTP site or client transfer exists |
| IIS / WWW Publishing | W3SVC / Web-Server | **Keep** for any required web/application role |
| Remote Desktop Services | TermService | **Keep** for required RDP administration or RDS role |
| Routing and Remote Access | RemoteAccess | **Keep** for an assigned VPN/RRAS/router role |
| Internet Connection Sharing | SharedAccess | Rare role-specific need; confirm before disabling |
| Print Spooler | Spooler | Required print server/printing only; DC risk needs separate check |
| WebClient | WebClient | Required WebDAV or associated application |
| OpenSSH SSH Server | sshd | Keep when README requires SSH management/file transfer |
| Windows Remote Management | WinRM | **Often required** by Server Manager/PowerShell remoting; restrict access, not automatically disable |
| Simple TCP/IP Services | simptcp | Legacy and generally unneeded unless explicitly required |
| Xbox / media sharing | varies, may be absent | Typically unnecessary on Server, but absence is normal |
| Remote-control software | TeamViewer/AnyDesk/VNC product services | Only if explicitly authorized; inspect executable/product first |

**Domain Controller — do not disable required infrastructure:** NTDS, Kdc, Netlogon, DNS (if DC hosts DNS), DFSR (if used), W32Time, ADWS, RPCSS, DcomLaunch, EventLog, Dnscache, LanmanServer, and other role-dependent services. WinRM also supports many administrative workflows. Do not assume every listed DC-related service has to show Running all the time; inspect configured dependencies and actual client behavior.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Stop-Service -Name 'RemoteRegistry' -ErrorAction Stop
> Set-Service -Name 'RemoteRegistry' -StartupType Disabled
> ~~~
>
**✅ Verification:**

~~~powershell
Get-Service -Name 'RemoteRegistry' | Format-Table Name,Status,StartType
~~~

> [!WARNING]
> **↩️ Undo:** Restore the *recorded original* startup type using Set-Service; start the service only if it had been running and is required. A stopped service can be appropriate even when startup is Manual. Do not apply blanket Stop-Service -Force, bulk disable lists or mass uninstalls to required roles.

**Warn:** Services may depend on each other; disabling a listed generic desktop service on a server may break printing, IIS FTP, remote management, backups or an app. Confirm dependencies via the GUI or Get-Service -DependentServices and actual required-client test.

#### 6.2 Never touch these on a Domain Controller
- [ ] **🎯 DO THIS — 6.2 Never touch these on a Domain Controller**

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
**Do not require every service in this list to be Running and Automatic on every DC.** Some are Manual/trigger-start or absent depending on installed role and topology (for example Intersite Messaging). Compare installed dependencies, expected operational state and the README. Required **NTDS, Kdc, Netlogon, DNS when hosted, time and SYSVOL replication** need role-specific health tests; a generic StartType column is not the full test.

#### 6.3 Print Spooler, Point and Print and PrintNightmare

- [ ] **🎯 DO THIS — 6.3 Print Spooler, Point and Print and PrintNightmare**

> [!NOTE]
> **💡 Why:** Print Spooler has been involved in serious privilege-escalation/remote-code-execution vulnerabilities. Whether it should be disabled depends on whether this machine is a required print server and the installed update/policy state.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-Service Spooler -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint' -ErrorAction SilentlyContinue |
>   Select-Object RestrictDriverInstallationToAdministrators,NoWarningNoElevationOnInstall,UpdatePromptSettings
> ~~~
>
**⭐ EASIEST WAY — Click through the GUI:** Server Manager → Local Server → identify **Print and Document Services** if installed. Win + R → services.msc → Print Spooler. For GPO, open the correct linked GPO in gpmc.msc (DC) or local gpedit.msc (standalone/member) → Computer Configuration → Administrative Templates → Printers and inspect Point and Print Restrictions / Limits print driver installation to Administrators.

**Server-specific decision:**
1. If **no printing is required** and the README permits it, consider disabling only Spooler after identifying dependencies and recording its original startup state.
2. If this is a **required print server**, keep Spooler functional, install approved security patches and apply compatible driver-installation restrictions; confirm legitimate printers and administrator installation workflows still work.
3. For a Domain Controller, the spooler is usually not required, but confirm the actual assigned role before stopping it.
4. Review Point-and-Print policies in the effective GPO; an explicit **NoWarningNoElevationOnInstall=1** can be a dangerous bypass. A missing registry value is not by itself proof of insecurity; inspect inherited policy and defaults.

**Change (ONLY when policy and role require the restriction):** In the applicable Printers policy enable **Limits print driver installation to Administrators**; inspect user elevation prompts. Avoid blindly creating several registry values in one command because the effective GPO can override them.

**✅ Verify:** Confirm expected policy, installed update status and required printer client functionality. Test from an authorized printer/client context if this is a print server.

> [!WARNING]
> **↩️ Undo:** Restore exactly the prior documented service state or policy if a needed printer application breaks, while maintaining the strongest feasible protective controls.

### 7. Roles and features

#### 7.1 Inspect and safely remove **only specifically prohibited** roles/features

- [ ] **🎯 DO THIS (only if authorized) — 7.1 Inspect and safely remove **only specifically prohibited** roles/features**

> [!NOTE]
> **💡 Why:** An unauthorized feature can expose attack surface, but deleting a role may break domain authentication, a required website/share or application data. Removing role binaries often does **not** restore required configuration if later reinstalled.

**⭐ EASIEST WAY — Click through the GUI:** Server Manager → **Manage → Add Roles and Features** to review installed roles/features, or **Remove Roles and Features** to inspect candidates/dependencies **without confirming removal**. Note installed AD DS, DNS, DHCP, IIS, file services and Windows Defender.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-WindowsFeature | Where-Object Installed | Format-Table Name,DisplayName,InstallState
> Get-WindowsFeature | Where-Object Name -match 'Telnet|TFTP|SMB1|PowerShell-V2|SNMP|Simple-TCPIP' | Format-Table Name,InstallState
> ~~~
>
**Candidate table:**

| Legacy feature | Typical risk | Keep if... |
|---|---|---|
| Telnet Client/Server | Unencrypted legacy remote terminal access | Specifically required for a legitimate lab task |
| TFTP Client/Server | Unauthenticated file transfer (legacy) | An approved boot/provisioning function requires it |
| SMB 1.0 / CIFS | Obsolete, weak file-sharing protocol | Explicit legacy client/service compatibility is necessary |
| PowerShell 2.0 engine | Legacy scripting engine with fewer modern security protections | A strictly required legacy application needs it |
| SNMP Service | Legacy monitoring can use weak community strings | Required monitoring is present and protected |

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-WindowsFeature -Name 'Telnet-Client'
> Uninstall-WindowsFeature -Name 'Telnet-Client' -WhatIf
> ~~~
>
This is only an example if Telnet Client is **installed and prohibited**. Do not execute an unconditional comma-separated removal list. Certain features vary by Windows Server release, and some removals need a restart.

**Change only if justified:** Through the wizard or a targeted Uninstall-WindowsFeature -Name 'ACTUAL-FEATURE' command **after** reviewing the role's services, installed dependencies and necessary data. Never remove AD DS or DNS on a required DC; never strip IIS/FTP/SMB/DHCP from a server whose README needs it.

**✅ Verify:** Repeat feature inspection and test the exact required role functions from an authorized client. Review pending reboot requirements.

> [!WARNING]
> **↩️ Undo:** Reinstalling a role's binaries may not restore its prior data and configuration. Use a valid role-specific backup and supported recovery procedure, not blanket reinstallation.

---

### 8. Remote access

#### 8.1 Remote Desktop and Remote Assistance — Server-specific procedure

- [ ] **🎯 DO THIS — 8.1 Remote Desktop and Remote Assistance — Server-specific procedure**

> [!NOTE]
> **🎯 What:** Determine whether RDP, Remote Assistance or an RDS role is required. Do **not** turn off RDP if it is an approved management path or the system is an RDS Session Host.

**⭐ EASIEST WAY — Click through the GUI:** Server Manager → Local Server → **Remote Desktop**. If enabled, require **Network Level Authentication (NLA)** when compatible with the authorized clients. Inspect **Select Users** / Remote Desktop Users group and effective GPO. On a DC, members and logon rights come from **domain groups and domain policy**, not local Get-LocalGroupMember.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -ErrorAction SilentlyContinue
> Get-Service TermService -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue |
>   Select-Object Name,DisplayName,Enabled,Profile,Direction,Action
> ~~~
>
fDenyTSConnections = 0 usually permits incoming RDP subject to other controls; 1 denies it. **Service state alone** does not prove remote RDP reachability. A role-specific GPO can override local configuration.

**⭐ EASIEST WAY — Click through the GUI:**
1. Confirm console/alternate management access, authorized users and client requirements.
2. Server Manager → Local Server → Remote Desktop.
3. Choose the README-required enabled/disabled state. If RDP is required, enable NLA if supported and restrict users/source firewall rules to approved management hosts.
4. Recheck **User Rights Assignment → Allow log on through Remote Desktop Services / Deny log on through Remote Desktop Services** in the applicable local or DC GPO; a deny right overrides an allow.
5. Validate from an authorized separate RDP client; on a DC ensure administrators retain required access.

**Remote Assistance:** Inspect the installed policy in system remote settings or applicable GPO; disable unsolicited/unapproved invitations only if the scenario does not require it. Do not confuse Remote Assistance with RDP.

**✅ Verify:** Check effective GPO, firewall profile/rules, NLA/login restrictions, authorized RDP connection (if required), and other required service functions. For disabled RDP, verify it is not listening or reachable from an unauthorized client **without** breaking the VM console.

> [!WARNING]
> **↩️ Undo:** Restore only the original documented Remote Desktop/Assistance value, group membership, GPO or firewall scope using console access. Avoid blindly editing multiple registry values, which can be overridden by policy.

#### 8.2 Lock down WinRM
- [ ] **🎯 DO THIS (only if authorized) — 8.2 Lock down WinRM**

```powershell
winrm get winrm/config/service       # AllowUnencrypted = false, Basic = false
```
Or with `gpedit.msc` → **Administrative Templates → Windows Components → Windows Remote Management (WinRM) → WinRM Service**: **Allow Basic authentication: Disabled**, **Allow unencrypted traffic: Disabled**.

---

### 10. Prohibited software, files, startup persistence, browser and security settings

These tasks are **fully supported here** by the role-aware commands below and the complete Server OS security reference in Part 5 (**WS.12 through WS.21**). No separate Windows guide is needed.

- [ ] **🎯 DO THIS —** Done — Compare installed applications and portable binaries to the README's prohibited list; preserve evidence before uninstall.
- [ ] **🎯 DO THIS —** Done — Check suspicious desktop files and media in the named user profiles; do not mass-delete user data.
- [ ] **🎯 DO THIS —** Done — Inspect startup entries, Run/RunOnce keys, scheduled tasks, services, network listeners and file hashes.
- [ ] **🎯 DO THIS —** Done — Check browsers used by required IIS/app management tools and their approved updates/extension policies.
- [ ] **🎯 DO THIS —** Done — Review role-compatible UAC, SMB signing, anonymous access, NTLM/LM, auditing, PowerShell logging, screen locking and removable-media policies.

**⭐ EASIEST WAY — GUI:** **Win + R → `appwiz.cpl`** (installed applications), **Ctrl+Shift+Esc → Startup apps**, **Win + R → `taskschd.msc`**, **`services.msc`** and **`fsmgmt.msc`** (shares). On a DC, preserve service accounts, SYSVOL, directory and DNS dependencies. Inspect and remove only the README-confirmed prohibited items.

> [!NOTE]
> **🔁 ALTERNATE — PowerShell investigation:**

~~~powershell
Get-Package | Select-Object Name,Version,ProviderName | Sort-Object Name
Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location,User
Get-ScheduledTask | Select-Object TaskPath,TaskName,State
Get-CimInstance Win32_Service | Select-Object Name,StartName,State,PathName
Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
~~~

**Forensic file investigation (replace with the actual discovered path):**

~~~powershell
Get-Item -LiteralPath 'C:\Users\Example\Documents\suspect.exe' | Format-List FullName,Length,CreationTime,LastWriteTime
Get-FileHash -LiteralPath 'C:\Users\Example\Documents\suspect.exe' -Algorithm SHA256
Get-AuthenticodeSignature -LiteralPath 'C:\Users\Example\Documents\suspect.exe' | Select-Object Status,SignerCertificate
~~~

> [!NOTE]
> **🧠 Interpret:** A suspicious name/signature/listener is only an investigation lead. Required service accounts, scheduled backup jobs and remote-management tools can be legitimate. On a Domain Controller, preserve NTDS/AD/DNS/Kerberos, authorized SYSVOL content, event logs and necessary service identities.

**Verify/undo:** After any narrowly approved remediation, test ordinary login and all required IIS/FTP/SMB/DNS/DHCP/AD functions, check system/service events, and restore only the changed item from its baseline.

---

<a id="research-expansion-required-server-role-dependency-checklist"></a>
### 🧰 required server-role dependency checklist

| Role | Inspection tool | Verify with an authorized client |
|---|---|---|
| Active Directory | Server Manager, ADUC, dcdiag | Domain user login and directory lookup |
| DNS | DNS console, Get-DnsServerZone | Required hostname resolves correctly |
| DHCP | DHCP console, Get-DhcpServerv4Scope | Client receives correct subnet/gateway/DNS |
| IIS | IIS Manager, Get-Website | Required website responds on correct host/port |
| SMB file server | File and Storage Services, Get-SmbShare | Correct user can access required share |
| RDP / WinRM | Remote Desktop settings / winrm config | Approved management connection still works |

**⭐ EASIEST WAY — GUI:** Use **Server Manager → Tools** for **Active Directory Users and Computers**, **DNS**, **DHCP**, **IIS Manager**, and **File and Storage Services → Shares** as installed. For each required role, verify an authorized client transaction before changing settings.

> [!NOTE]
> **🔁 ALTERNATE — PowerShell read-only inspection:**

~~~powershell
Get-SmbShare | Select-Object Name,Path,Special
Get-NetFirewallProfile
~~~

**Do not** install missing roles merely to run checklist commands. Review any zone transfer, DHCP scope, IIS authentication, file ACL or remote-management change against required functionality. Preserve original configuration and test application login/shares/website after modifications.

<a id="research-report-expansion-ws-r5--dns-zone-transfers-updates-and-ad-integrated-records"></a>
### 📦 DNS zone transfers, updates and AD-integrated records

- [ ] **🎯 DO THIS — 📦 DNS zone transfers, updates and AD-integrated records**

> [!NOTE]
> **📚 Evidence:** Community/vendor-backed DNS hardening; depends on whether this server actually hosts DNS.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → dnsmgmt.msc → Forward Lookup Zones → actual zone → Properties**. Inspect **General → Dynamic Updates** and **Zone Transfers**. AD-integrated zones can support **Secure only** dynamic updates when appropriate; a secondary DNS server may require tightly restricted zone transfers.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-DnsServerZone | Select-Object ZoneName,IsDsIntegrated,DynamicUpdate,IsReverseLookupZone
> Get-DnsServerForwarder
> Get-DnsServerResourceRecord -ZoneName 'example.test' -RRType SRV -ErrorAction SilentlyContinue
> ~~~

> [!CAUTION]
> **🛑 Before changing anything:** Record the original zone type, AD replication scope, allowed secondaries, clients and SRV records. **Do not delete unfamiliar SRV records** or redirect domain DNS to a public resolver.

**🛠️ Fix:** On the exact zone, use its GUI to restrict unwanted zone transfers to approved secondary servers, and set dynamic updates to the appropriate secure mode only for an AD-integrated zone whose clients support it. Do not use a blanket change across all zones.

**✅ Verification:** Test client A/AAAA and required SRV records, DC name resolution, and authorized dynamic updates. If an approved secondary exists, verify its transfer still succeeds.

> [!WARNING]
> **↩️ Undo:** Restore the recorded per-zone setting or role-aware DNS backup. A DNS zone deletion is not fixed by simply adding one A record.

<a id="research-report-expansion-ws-r6--dhcp-scopes-reservations-authorization-and-auditing"></a>
### 🔎 DHCP scopes, reservations, authorization and auditing

- [ ] **🎯 DO THIS — 🔎 DHCP scopes, reservations, authorization and auditing**

> [!NOTE]
> **📚 Evidence:** Community; vendor-supported DHCP configuration inventory.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → dhcpmgmt.msc → Server → IPv4 → Scope**. Review address ranges, exclusions, **Reservations**, **Address Leases**, and **Scope Options** (003 Router, 006 DNS Servers, 015 Domain Name). Check server authorization and any configured failover pair.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-DhcpServerv4Scope | Select-Object ScopeId,Name,StartRange,EndRange,State
> Get-DhcpServerv4Reservation -ScopeId 192.0.2.0 -ErrorAction SilentlyContinue
> Get-DhcpServerInDC -ErrorAction SilentlyContinue
> ~~~
>
**Replace 192.0.2.0 with the real scope ID**; documentation address is not a universal example scope. For a real scope:

~~~powershell
Get-DhcpServerv4OptionValue -ScopeId 192.0.2.0
~~~

**Before change:** Record the correct subnet, default gateway, DNS server and reserved/static addresses. Where supported, back up the DHCP server configuration to a private folder using **Backup-DhcpServer -Path** after verifying the path exists and is protected.

**🛠️ Fix:** Correct one unauthorized option, reservation or scope through the GUI only after the README and required-client topology are verified. Enabling auditing is an appropriate policy step **only if the logging path/disk budget permits**.

**✅ Verification:** On an approved test client, renew or inspect the lease, confirm actual gateway/DNS/domain suffix and reach required services. Then re-run DHCP scope/option queries and check relevant audit records.

> [!WARNING]
> **↩️ Undo:** Restore the one altered option/reservation, or use a reviewed DHCP-specific backup procedure for larger changes. Never delete a scope or reauthorize arbitrary servers to silence one lease error.

<a id="research-report-expansion-ws-r7--iis-directory-browsing-webdav-app-pools-and-web-shell-triage"></a>
### 🧰 IIS directory browsing, WebDAV, app pools and web-shell triage

- [ ] **🎯 DO THIS — 🧰 IIS directory browsing, WebDAV, app pools and web-shell triage**

> [!NOTE]
> **📚 Evidence:** Community/vendor-backed, applies only to an installed/required IIS web/FTP role.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → inetmgr → Sites → required site**. Review **Basic Settings → Physical path**, **Bindings**, **Directory Browsing**, **Authentication**, **Request Filtering**, **Modules**, **WebDAV Authoring Rules** (if installed), **Logging** and **Application Pools → Identity**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Import-Module WebAdministration
> Get-Website | Select-Object Name,State,PhysicalPath
> Get-WebBinding | Select-Object protocol,bindingInformation
> Get-ChildItem IIS:\AppPools | Select-Object Name,State
> ~~~

> [!CAUTION]
> **🛑 Before edits:** Export/back up the effective IIS configuration, bindings and relevant content; record any application pool identity and required login/upload/database operations. An IIS configuration backup alone does not save its content/database.

**Fix only if the required site must forbid directory listings:**

~~~powershell
Set-WebConfigurationProperty -PSPath 'IIS:\Sites\Default Web Site' -Filter system.webServer/directoryBrowse -Name enabled -Value $false
~~~

Replace **Default Web Site** with the actual site; do not apply to every site by default. If WebDAV is enabled but unused, inspect installed module/authorization and disable it only for the correct site after client compatibility checks. Avoid disabling Basic Authentication where the task requires it over HTTPS.

> [!NOTE]
> **Evidence check (read-only, replace actual site directory):**

~~~powershell
Get-ChildItem 'C:\inetpub\wwwroot' -Recurse -File -Include *.asp,*.aspx,*.php,*.exe -ErrorAction SilentlyContinue |
 Select-Object FullName,LastWriteTime,Length
~~~

> [!NOTE]
> **🧠 Interpret:** Script files may be legitimate; unknown scripts need metadata, publisher/source comparison and forensic preservation. Do not execute or delete files purely because of their extension.

**✅ Verification:** Load the actual hostname/HTTPS binding from an authorized client, test required login/upload/API/database behavior, and check IIS error/request logs. A successful local homepage does not prove the required virtual host works.

> [!WARNING]
> **↩️ Undo:** Restore the one site setting/permission from the recorded original or a reviewed IIS backup; restore file content and DB separately if removed.

<a id="research-report-expansion-ws-r8--required-service-recovery-before-removing-any-role"></a>
### 🧰 Required service recovery before removing any role

- [ ] **🎯 DO THIS — 🧰 Required service recovery before removing any role**

> [!NOTE]
> **📚 Evidence:** Official scenario/service-preservation principle; role-specific command behavior is vendor-backed.

**⭐ EASIEST WAY — GUI:** **Server Manager → Local Server / Tools → Services** (or **Win + R → `services.msc`**) → inspect exact required service and record its original **Startup type**, **Status** and **Dependencies**. If it was wrongly disabled, restore **Properties → Startup type**, click **Start** only if previously running, and test the role.

> [!NOTE]
> **🔁 ALTERNATE — PowerShell service inspection (or Server Core):**

~~~powershell
Get-Service NTDS,Kdc,DNS,Netlogon,DFSR,W32Time,W3SVC,DHCPServer,LanmanServer -ErrorAction SilentlyContinue |
 Select-Object Name,Status,StartType
Get-WindowsFeature | Where-Object Installed | Select-Object Name,DisplayName
~~~

> [!NOTE]
> **What to look for:** A required role unexpectedly Disabled/Stopped or a suspicious role added. **Some healthy services are demand-start or absent**; never force the entire list to Automatic.

**Change ONLY if the exact required service was accidentally disabled and its original startup was Automatic (replace placeholder):**

~~~powershell
Set-Service -Name 'EXAMPLE_REQUIRED_SERVICE' -StartupType Automatic
Start-Service -Name 'EXAMPLE_REQUIRED_SERVICE'
~~~

**✅ Verification:** Recheck status and the application-level operation: domain login, required DNS SRV query, DHCP lease, IIS page, authorized SMB file access or other README-specified transaction. On a DC also verify directory, time and replication health as relevant.

> [!WARNING]
> **↩️ Undo:** Restore the original recorded service startup and running state if a change was incorrect. Do not disable a role only because a generic checklist labels it risky; do not re-create a deleted directory/database with a blank role installation.

---

<a id="stage-5"></a>
## Part 5 — Advanced Server Investigation and Embedded Windows Reference

> [!NOTE]
> 🧰 **Advanced reference:** Use these targeted procedures when the scenario calls for deeper investigation.

Use role-specific recovery first. The in-file Windows security reference covers common settings, but **the earlier Server roles and domain-specific instructions override generic workstation defaults**.

### 12. Role-aware manual procedures and recovery

Use **Windows PowerShell as Administrator on the server**, not a workstation, for these commands. Substitute the actual domain, scope, site and share names. A missing role cmdlet normally means its role/module is absent; do not install a server role just to satisfy a checklist. The complete **server-local backup, account, firewall, audit, malware and recovery procedures are included in Part 5, WS.19.1–WS.19.9 below**; there is no need to consult a workstation guide.

#### 12.1 Identify version, roles and management dependencies

- [ ] **🎯 DO THIS — 12.1 Identify version, roles and management dependencies**

> [!NOTE]
> **🎯 What:** Determine whether this is a Domain Controller, member server or standalone server, and identify installed roles.

> [!NOTE]
> **💡 Why it matters:** A DC stores domain identities and requires DNS, Kerberos, replication and time services. Removing a role is much more disruptive than stopping a workstation application.

> [!CAUTION]
> **🛑 Before changing anything:** Record required services and client tests from the README. Keep VM console access and an authorized administrator. A practice VM snapshot is not an AD-aware production backup; follow round rules and do not casually revert a replicated DC.

**⭐ EASIEST WAY — Click through the GUI:** **Start → Server Manager → Local Server** shows domain membership, remote management and version. **Manage → Remove Roles and Features** can display installed roles; cancel after inspection. Do not click Remove merely because a role was not named explicitly in a short README.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,ProductType
> Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain
> Get-WindowsFeature | Where-Object Installed | Format-Table Name,DisplayName
> ```
>
ProductType 2 means DC; 3 means another server. A **member server has local accounts plus domain accounts**: local policy governs local accounts, while domain account passwords are governed by domain policy even when logging on to that member server.

| Version | Important distinction |
|---|---|
| Server 2016 | Older IIS/Defender capabilities and policy templates; do not assume newer cmdlet parameters or `removeServerHeader` support |
| Server 2019 | Newer role/security capabilities, but patch level still determines which policies exist |
| Server 2022 | Newer defaults/features; client compatibility and installed role remain more important than copying a 2016 baseline |
| Server Core | No full desktop; use PowerShell, `sconfig` where available, and authorized remote management |

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
**✅ Check it worked:** Compare the role list and test each required client function after each change. Keep AD DS, DNS, Netlogon, KDC, time and replication functions operational where required.

> [!WARNING]
> **↩️ Undo:** Restore a mistakenly removed role only with its recorded configuration, data and supported recovery method; installing binaries alone does not restore a deleted directory/database. Use a pre-change role-specific backup.

> [!CAUTION]
> **⚠️ Warnings:** Server Manager itself relies on remote management features. Disabling WinRM on a server because it is often disabled on workstations can break management.

#### 12.2 AD users, nested groups and service identities

- [ ] **🎯 DO THIS — 12.2 AD users, nested groups and service identities**

> [!NOTE]
> **🎯 What:** Reconcile domain users and privileged group membership with the README.

> [!NOTE]
> **💡 Why it matters:** A nested group can confer Domain Admin access even when a user is not a direct member. Service accounts may run databases, scheduled tasks and IIS pools.

> [!CAUTION]
> **🛑 Before changing anything:** Preserve forensics and record distinguished names, SIDs, group memberships and service dependencies. Never use local-user cmdlets as an AD substitute.

**⭐ EASIEST WAY — Click through the GUI:** **Server Manager → Tools → Active Directory Users and Computers** (`dsa.msc`). Enable **View → Advanced Features**. Find the exact account/OU, open **Properties → Member Of / Account** and inspect privileges, expiration, delegation and password options. Open each group from the earlier powerful-group table and inspect **Members**; nested groups require inspection too. Prefer **Disable Account** before irreversible deletion of a confirmed unauthorized user.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Import-Module ActiveDirectory
> Get-ADUser -Filter * -Properties Enabled,PasswordNeverExpires,PasswordNotRequired,ServicePrincipalName | Select-Object SamAccountName,Enabled,PasswordNeverExpires,PasswordNotRequired,ServicePrincipalName
> Get-ADGroupMember -Identity 'Domain Admins'
> Get-ADGroupMember -Identity 'Domain Admins' -Recursive
> ```
>
A recursive query finds effective nested members but hides the membership path; inspect direct group members to locate the offending link. Record an individual user:

```powershell
Get-ADUser bob -Properties MemberOf,AccountExpirationDate,ServicePrincipalName,TrustedForDelegation | Format-List
Get-CimInstance Win32_Service | Select-Object Name,StartName,State
Get-ScheduledTask | Select-Object TaskName,TaskPath,Principal
```

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Remove-ADGroupMember -Identity 'Domain Admins' -Members bob -Confirm
> ```
>
Reversible account containment:

```powershell
Disable-ADAccount -Identity mallory
```

Do not rotate a required service account password without coordinating each dependent service/application. Managed service accounts have separate lifecycle and password management.

**✅ Check it worked:** Repeat direct/recursive queries, test a new permitted login and verify dependent services. Existing tokens can retain privileges until a new logon; disabling an account does not terminate every existing session automatically.

> [!WARNING]
> **↩️ Undo:** `Add-ADGroupMember -Identity 'Domain Admins' -Members bob` or `Enable-ADAccount -Identity mallory` restores only a mistakenly changed original state. Deleted AD objects need a supported AD recovery method, not name recreation.

> [!CAUTION]
> **⚠️ Warnings:** Do not remove all operator/service identities from a DC using a workstation rights table. Do not change your only working administrator or krbtgt credentials as a routine checklist step.

#### 12.3 Domain password policy and Group Policy precedence

- [ ] **🎯 DO THIS — 12.3 Domain password policy and Group Policy precedence**

> [!NOTE]
> **🎯 What:** Apply account policy at the scope that actually governs the account, and inspect the winning GPO.

> [!NOTE]
> **💡 Why it matters:** A local policy does not control domain user passwords. Fine-grained password policies can override the default for selected users/groups. A deny user right can block logon despite an allow grant.

> [!CAUTION]
> **🛑 Before changing anything:** Record the current default/resultant policy and back up the specific GPO before editing it. Keep the Default Domain Policy and Default Domain Controllers Policy roles distinct.

**⭐ EASIEST WAY — Click through the GUI:** `gpmc.msc` → **Forest → Domains → actual domain**. Select the GPO, inspect **Scope**, links, security filtering and **Settings**; right-click **Back Up** to a private folder. Edit domain account policy in the domain-root-linked account-policy GPO, commonly **Default Domain Policy → Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies**. For DC-specific audit/rights/options inspect the GPO linked to the **Domain Controllers OU**, not the workstation baseline. Use **Group Policy Results** for a specific machine/user.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-ADDefaultDomainPasswordPolicy | Format-List
> Get-ADUserResultantPasswordPolicy -Identity bob
> Get-GPO -All | Select-Object DisplayName,Id,GpoStatus
> ```
>
A null resultant fine-grained policy can mean the domain default applies. Save a report:

```powershell
gpresult /h C:\CP-Backups\server-gpresult.html
```

Create and restrict that backup folder using the **WS.19.1 baseline procedure below** first. A GPO report can contain sensitive infrastructure details.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Set-ADDefaultDomainPasswordPolicy -Identity 'example.test' -MinPasswordLength 12 -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false -LockoutThreshold 5 -LockoutDuration (New-TimeSpan -Minutes 30) -LockoutObservationWindow (New-TimeSpan -Minutes 30)
> ```
>
Replace the domain and all policy values. Length/complexity affect future password changes; lockout threshold counts invalid attempts within the observation window. Do not infer that updating a policy fixed all existing passwords.

**✅ Check it worked:** Re-query default and resultant policies; inspect Group Policy Results for the affected computer. If appropriate, run `gpupdate /target:computer /force` and read its errors; some settings require logoff/restart. Test ordinary authorized access without deliberately locking the active admin.

> [!WARNING]
> **↩️ Undo:** Restore the individual recorded setting or specific GPO backup via GPMC **Manage Backups → Restore** after reviewing scope. GPO deletion is not a normal way to undo one planted setting. Changing a domain policy does not undo a password reset.

> [!CAUTION]
> **⚠️ Warnings:** Requiring LDAP signing/channel binding, restricting NTLM, or removing network-logon principals can break older required clients. Stage compatibility inspection and consult the applicable Microsoft policy documentation; do not apply `Always` blindly to every environment.

#### 12.4 DNS, DHCP and DC health

- [ ] **🎯 DO THIS — 12.4 DNS, DHCP and DC health**

> [!NOTE]
> **🎯 What:** Validate required name resolution, leases, replication and time after hardening.

> [!NOTE]
> **💡 Why it matters:** AD relies on internal DNS SRV records and reasonably synchronized time. Using a public resolver as the DC's primary DNS can break domain discovery.

> [!CAUTION]
> **🛑 Before changing anything:** Record DNS zones/forwarders, DHCP scopes/options/reservations, authorized servers and expected DC topology. Back up the affected role, not just a screenshot.

**⭐ EASIEST WAY — Click through the GUI:** **Server Manager → Tools → DNS**; open the server and each zone **Properties → Zone Transfers**. Permit transfers only to required secondary servers rather than blindly disallowing required replication. For AD-integrated zones inspect the appropriate secure dynamic-update setting. **Tools → DHCP → IPv4 → scope** shows range, exclusions, reservations, leases and **Scope Options** (003 Router, 006 DNS Servers, 015 DNS Domain Name). Record each before editing.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-DnsServerZone
> Get-DnsServerForwarder
> Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.example.test
> Get-DhcpServerv4Scope
> Get-DhcpServerv4OptionValue -ScopeId 192.168.10.0
> ```
>
Use actual domain/scope. Required DNS SRV answers should identify the expected DC. DHCP range must exclude static server addresses. Role cmdlets are available only with the relevant modules.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Backup-DhcpServer -Path C:\CP-Backups\DHCP
> ```
>
Use the GUI to correct the exact wrong scope option, unauthorized transfer destination or dynamic-update setting. Do not delete a working zone/scope to rebuild it from memory. Do not change NIC DNS to a public resolver to bypass internal-DNS errors.

**✅ Check it worked:**

```powershell
dcdiag /test:dns
repadmin /replsummary
w32tm /query /status
```

Use these on the appropriate DC; no replication partners can be normal for a single-DC lab. Investigate errors rather than assuming they are all scoring issues. Renew a noncritical authorized client's DHCP lease and test internal hostname lookup and domain login.

> [!WARNING]
> **↩️ Undo:** Restore the recorded specific zone/scope option or use the role's reviewed backup procedure. Restore AD-integrated data with AD-aware recovery; arbitrary file copying into DNS/NTDS directories is unsafe.

> [!CAUTION]
> **⚠️ Warnings:** Never disable DNS, Kdc, NTDS, Netlogon, DFSR or W32Time on a required DC. DHCP failover and approved secondary DNS servers may be implicit dependencies even if the README does not enumerate every service name.

#### 12.5 IIS, FTP and File and Storage Services recovery

- [ ] **🎯 DO THIS — 12.5 IIS, FTP and File and Storage Services recovery**

> [!NOTE]
> **🎯 What:** Secure required published content and file access while preserving application identities.

> [!NOTE]
> **💡 Why it matters:** Server-wide IIS edits affect all sites. Share and NTFS ACLs jointly control network access. TLS without a usable certificate/client can stop a required service.

> [!CAUTION]
> **🛑 Before changing anything:** Record site bindings, certificates, application pool identities, content paths, FTP users/data ports and share ACLs. Back up IIS configuration:

```powershell
& "$env:windir\system32\inetsrv\appcmd.exe" add backup BeforeCP
```

Choose a unique name on subsequent runs. Separately back up content and databases; IIS config backup does not preserve them.

**⭐ EASIEST WAY — Click through the GUI:** `inetmgr` → site → **Bindings**, **Authentication**, **Directory Browsing**, **Logging** and **Application Pools → Advanced Settings → Identity**. Apply the earlier section's settings at the intended site, considering inheritance. For FTP inspect **FTP Authentication**, **Authorization Rules**, **SSL Settings**, **User Isolation** and **Firewall Support**. In **Server Manager → File and Storage Services → Shares**, inspect required shares; then inspect each folder's NTFS Security tab as described in **WS.19.7 below**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Import-Module WebAdministration
> Get-Website | Format-Table Name,State,PhysicalPath
> Get-WebBinding | Format-Table protocol,bindingInformation
> Get-ChildItem IIS:\AppPools | Select-Object Name,State,processModel
> Get-SmbShare | Format-Table Name,Path,Description
> ```

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Set-WebConfigurationProperty -PSPath 'IIS:\Sites\Company' -Filter system.webServer/directoryBrowse -Name enabled -Value $false
> ```
>
Only disable browsing if directory listing is not required. Preserve the intended site authentication; public anonymous access is normal for many websites. Apply least privilege to an app pool without breaking access to its content/database/certificates. Do not deny all unlisted extensions without an application inventory.

**✅ Check it worked:** Test the actual hostname/port from an authorized client, including required login, static/dynamic pages, upload and database-backed behavior. For FTP, test both authentication and a data transfer; passive data ports must match firewall/server configuration. For shares, test read/write under an ordinary authorized user, not only an admin.

> [!WARNING]
> **↩️ Undo:** Restore the exact site setting or, if needed and after reviewing other sites' changes:

```powershell
& "$env:windir\system32\inetsrv\appcmd.exe" restore backup BeforeCP
```

This affects the saved IIS server configuration. Restore content/database/ACL changes separately from their specific backups.

> [!CAUTION]
> **⚠️ Warnings:** Do not disable TLS protocols until required clients have been checked and patches/certificates are ready. Hide-version settings do not substitute for updates. A web shell investigation must preserve evidence and compare files with trusted application sources before deletion.

#### 12.6 Remote management, firewall, updates and audit completion

- [ ] **🎯 DO THIS — 12.6 Remote management, firewall, updates and audit completion**

> [!NOTE]
> **🎯 What:** Preserve secure remote administration, installed roles and useful logs through updates.

> [!NOTE]
> **💡 Why it matters:** Broad firewall blocks can break RPC-dependent AD/management even when obvious ports are open. A workstation port list is insufficient for a DC.

> [!CAUTION]
> **🛑 Before changing anything:** Export firewall/audit policy using **WS.19.1 below**. Record required management source networks and installed antivirus/WSUS configuration. Keep console access.

**⭐ EASIEST WAY — Click through the GUI:** **Server Manager → Local Server → Remote management / Remote Desktop**. Use NLA and authorized RDP membership. `wf.msc` → inspect built-in **role-specific** rules and their scopes; keep required AD/DNS/DHCP/SMB/RPC traffic. **Settings → Update & Security / Windows Update** varies by version; on Core use supported `sconfig` update options. In Event Viewer inspect **Security**, **System**, **Directory Service**, **DNS Server** and **DFS Replication** as applicable.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> winrm get winrm/config/service
> winrm enumerate winrm/config/listener
> Get-NetFirewallProfile
> Get-Service WinRM,EventLog,mpssvc,wuauserv | Format-Table Name,Status,StartType
> Get-MpComputerStatus | Select-Object AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled
> ```
>
WinRM should normally reject Basic authentication and unencrypted traffic. HTTP transport with Kerberos can still encrypt messages; do not equate every port-5985 session with plaintext. Do not expand TrustedHosts to `*` to bypass name/authentication problems.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
**✅ Check it worked:** From an authorized management host test `Test-WSMan server-name`, an authorized RDP login if required, role-specific client transactions, then DC health commands from 12.4. Confirm new audit events and no relevant new service errors. Use selective advanced audit subcategories as described in **WS.19.4 below**.

> [!WARNING]
> **↩️ Undo:** Restore the exact changed listener/authentication/rule scope from its record, using the console. For an update regression use the supported recovery method for that exact update; do not disable all updates or the firewall.

> [!CAUTION]
> **⚠️ Warnings:** Never remove role-required ports based solely on a short generic list. Do not clear server logs, forcibly stop package installation, or automatically reboot while database/AD recovery is unresolved.

---

### 13. Complete Windows Server operating-system security procedures (self-contained reference)

> **Server-first precedence:** The following in-file security reference provides detailed commands for Server hosts. Where an original example was written for a Windows desktop, the **Server role and Domain Controller instructions in Parts 1–4 take precedence**. Local-user cmdlets apply only to standalone/member servers; Active Directory users require AD tools. Never disable required print/web/AD/DNS/SMB/FTP, RDP/WinRM or domain policy merely to follow a general example.

**Windows Server version note (November 2026):** Server 2016, 2019 and 2022 differ in features and management tools. Verify installed edition/build and support lifecycle using the command in Part 1. Server Core lacks many Windows GUI tools, so use PowerShell and Server Manager from an authorized management host when relevant. Local SAM commands in WS.2 are **not for domain user accounts on a DC**.

**How to use this embedded reference**
- Work by role and task; check Parts 1–4 for priority and exceptions.
- For each applicable task, use the easiest method and verify the result; alternate commands and deeper explanations are optional.
- New to PowerShell? Read **WS.20: Complete PowerShell basics** below (in this same file).
- This repository contains documentation only. Follow the manual procedures below; do not skip verification.
- `alice`, `bob` etc. are examples. **Use the names in your README.**
- **Windows Server Desktop Experience** generally offers local policy editors and Server Manager tools; **Server Core** uses CLI/remote administration. `lusrmgr.msc` / `Get-LocalUser` do **not** administer domain accounts on a Domain Controller.

---

#### WS.0. Before you touch anything

##### WS.0.1 Read the README
- [ ] **🎯 DO THIS — WS.0.1 Read the README**

Write down the admins, users, critical services, required software and prohibited items. See [Reading the README](../General/All/reading-the-readme.md).

##### WS.0.2 Take a VMware snapshot
- [ ] **🎯 DO THIS — WS.0.2 Take a VMware snapshot**

**VM → Snapshot → Take Snapshot…**

##### WS.0.3 Open PowerShell as Administrator
- [ ] **🎯 DO THIS — WS.0.3 Open PowerShell as Administrator**

**Start** → type `powershell` → **Run as administrator**. The title must say **Administrator**.

##### WS.0.4 Open the Scoring Report
- [ ] **🎯 DO THIS — WS.0.4 Open the Scoring Report**

Double-click it on the desktop and refresh it as you work.

---

#### WS.1. Forensics questions (FIRST)

##### WS.1.1 Answer every forensics question before fixing things
- [ ] **🎯 DO THIS — WS.1.1 Answer every forensics question before fixing things**

Open each `Forensics Question N.txt` on the desktop, put your answer after `ANSWER:`, and save.

**Useful tools:**
```powershell
Get-FileHash C:\Users\bob\Documents\file.txt -Algorithm SHA256     # hash a file
Get-ChildItem C:\Users -Recurse -Force -Filter *secret* -ErrorAction SilentlyContinue   # find files by name
Get-ChildItem C:\Users -Recurse -File -Force -Include *.txt,*.csv,*.log,*.ps1,*.bat -ErrorAction SilentlyContinue | Select-String -Pattern "password"   # find text inside files
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aGVsbG8='))   # decode base64
```
More: [Forensics questions guide](../General/All/forensics-questions.md).

##### WS.1.2 Manual security baseline (no hardening script)
- [ ] **🎯 DO THIS — WS.1.2 Manual security baseline (no hardening script)**

> [!NOTE]
> **🎯 What:** Prepare a manual baseline. The upstream automation is not included in this repository.

> [!NOTE]
> **💡 Why it matters:** A status label cannot establish that a setting is correct on this particular image.

> [!CAUTION]
> **🛑 Before changing anything:** Read the README and preserve forensics evidence. Record your current administrator account, required users, services, ports, and initial score.

**⭐ EASIEST WAY — Click through the GUI:** Open the README and Scoring Report from the desktop. In your VM manager, create a practice snapshot only if the round rules permit it. Open the platform's account and service management screens described below.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
**✅ Check it worked:** Repeat each inspection, test the README-required function, then refresh the Scoring Report. A lack of new points does not prove the change failed.

> [!WARNING]
> **↩️ Undo:** Reverse the most recent change using the recorded value or the procedure's backup. A VM snapshot rollback can discard later fixes; use it only within the rules and verify the resulting score again.

> [!CAUTION]
> **⚠️ Warnings:** Never use a guessed list of authorized users or bulk-delete files. See [Using the scripts safely](../Misc%20Softwares/using-the-scripts.md) for the limits of external tools.

---

#### WS.2. Users and groups

##### WS.2.1 List every user
- [ ] **🎯 DO THIS — WS.2.1 List every user**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `lusrmgr.msc` → **Users**. (Or **Settings → Accounts → Other users**.)

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-LocalUser | Format-Table Name, Enabled, PasswordRequired, PasswordExpires, LastLogon
> ```

##### WS.2.2 Reconcile unauthorized local users
- [ ] **🎯 DO THIS — WS.2.2 Reconcile unauthorized local users**

> [!NOTE]
> **💡 Why it matters:** Extra accounts are how attackers get back in.

**⭐ EASIEST WAY — GUI (non-DC only):** In `lusrmgr.msc` → **Users**, confirm the user is unauthorized, preserve evidence, then **Properties → Account is disabled** for reversible containment. If the image explicitly requires account **removal**, use **Delete** after validating the identity; disabling alone may not meet a removal task.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Disable-LocalUser -Name EXAMPLE_UNAUTHORIZED_USER
> # If removal is specifically required after preserving evidence:
> # Remove-LocalUser -Name EXAMPLE_UNAUTHORIZED_USER
> ```

> [!CAUTION]
> **Verify:** Reopen the account and check the scored task, required logins and services. Never delete built-in identities, your only admin, a README-authorized user or a service account. On Domain Controllers, use the **AD-specific** user procedures, not local SAM cmdlets.

##### WS.2.3 Create users the README says should exist
- [ ] **🎯 DO THIS — WS.2.3 Create users the README says should exist**

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → **Users** → **Action → New User…** → untick "User must change password" only if the README says so.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> New-LocalUser -Name erin -Password (Read-Host -AsSecureString "Password for erin")
> Add-LocalGroupMember -Group Users -Member erin
> ```

##### WS.2.4 Fix the Administrators group
- [ ] **🎯 DO THIS — WS.2.4 Fix the Administrators group**

> [!NOTE]
> **🎯 What:** Only the README's admins should be in **Administrators**.

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → **Groups** → double-click **Administrators** → remove the wrong people / **Add…** the right ones.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-LocalGroupMember Administrators
> Remove-LocalGroupMember -Group Administrators -Member bob
> Add-LocalGroupMember -Group Administrators -Member alice
> net localgroup Administrators      # use this if Get-LocalGroupMember shows an error
> ```

> [!CAUTION]
> Never remove **yourself** (the account you are logged in as) from Administrators. You would lose your admin rights.

##### WS.2.5 Check the other powerful groups
- [ ] **🎯 DO THIS — WS.2.5 Check the other powerful groups**

Open these groups in `lusrmgr.msc` and remove anyone the README doesn't say should be there:
**Backup Operators** (can read every file), **Power Users**, **Remote Desktop Users** (keep only if RDP is needed), **Remote Management Users**, **Hyper-V Administrators**, **Event Log Readers**, **Network Configuration Operators**.

```powershell
foreach ($g in 'Backup Operators','Power Users','Remote Desktop Users','Remote Management Users','Hyper-V Administrators','Event Log Readers','Network Configuration Operators') {
  "--- $g"; Get-LocalGroupMember $g -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name }
```

##### WS.2.6 Disable the Guest account (and the other built-ins)
- [ ] **🎯 DO THIS (only if authorized) — WS.2.6 Disable the Guest account (and the other built-ins)**

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → **Users** → right-click **Guest** → **Properties** → tick **Account is disabled**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Disable-LocalUser -Name Guest
> Get-LocalUser | Where-Object { $_.SID -match '-50[0134]$' } | Format-Table Name, Enabled, SID   # finds them even if renamed
> ```
> The built-in **Administrator** should usually be disabled too, **unless you're logged in as it** or the README says to keep it.

##### WS.2.7 Fix weak password settings on accounts
- [ ] **🎯 DO THIS — WS.2.7 Fix weak password settings on accounts**

> [!NOTE]
> **🎯 What:** No account should have **Password never expires**, **User cannot change password**, or *no password required*.

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → double-click each user → untick **Password never expires** and **User cannot change password**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-LocalUser | Where-Object { $_.Enabled } | Format-Table Name, PasswordExpires, UserMayChangePassword, PasswordRequired
> Set-LocalUser -Name bob -PasswordNeverExpires $false
> Set-LocalUser -Name bob -UserMayChangePassword $true
> net user bob /passwordreq:yes
> ```

##### WS.2.8 Give users strong passwords
- [ ] **🎯 DO THIS — WS.2.8 Give users strong passwords**

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → right-click the user → **Set Password…**

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Set-LocalUser -Name bob -Password (Read-Host -AsSecureString "New password for bob")
> ```
> Use 12+ characters with upper case, lower case, a number and a symbol. **Don't change your own password** unless the README says so.

---

#### WS.3. Account policies (passwords and lockout)

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `secpol.msc` → **Account Policies**.

##### WS.3.1 Password Policy (standalone/member-server reference)
- [ ] **🎯 Configure only the required local password policy (not a Domain Controller's domain policy).**

**⭐ EASIEST WAY — GUI (Desktop Experience):** **Win + R → \`secpol.msc\` → Account Policies → Password Policy** → double-click **Minimum password length**, **Password must meet complexity requirements**, **Store passwords using reversible encryption**, **Enforce password history** and any image-required password ages → enter the exact requested value → **Apply → OK**.

| Item | Intended action when applicable |
|---|---|
| [ ] Minimum length | Match the README; 12 is only one example |
| [ ] Complexity | Enable if required |
| [ ] Reversible encryption | Disable unless a critical documented dependency requires otherwise |
| [ ] Password history | Match the README; **do not assume 24** |
| [ ] Age | Match the scenario for minimum / maximum |

**✅ VERIFY:** Reopen each field, test permitted login/password changes, and check for an overriding domain GPO. **↩️ UNDO:** Restore only the original recorded values.

> [!NOTE]
> **🔁 ALTERNATE — read-only PowerShell/CMD, or Server Core where GUI is unavailable:**
>
> \`\`\`powershell
> net accounts
> secedit /export /cfg "$env:TEMP\cp-server-policy.inf" /areas SECURITYPOLICY
> Select-String 'MinimumPasswordLength|PasswordComplexity|ClearTextPassword|PasswordHistorySize' "$env:TEMP\cp-server-policy.inf"
> \`\`\`
>
> **On a Domain Controller**, use **\`gpmc.msc\`** to edit the appropriate domain-root-linked password policy or use AD Administrative Center for fine-grained policy; local \`secpol.msc\` is not the correct control for domain users.

##### WS.3.2 Account Lockout Policy
- [ ] **🎯 DO THIS — WS.3.2 Account Lockout Policy**

| Setting | Set to |
|---|---|
| Account lockout threshold | **5** invalid attempts (set this first) |
| Account lockout duration | **30** minutes |
| Reset account lockout counter after | **30** minutes |
| Allow Administrator account lockout (only on updated systems; skip it if it isn't in the list) | **Enabled** |

**⭐ EASIEST WAY — GUI:** **Win + R → `secpol.msc` → Account Policies → Account Lockout Policy** → open **Account lockout threshold**, **duration** and **reset account lockout counter after**, set the values required by the image, then **Apply → OK**. On a Domain Controller, review the domain GPO instead.

**✅ VERIFY:** Reopen each entry, confirm the effective policy and that a permitted administrator can still log in.

> [!NOTE]
> **🔁 ALTERNATE — command-line inspection only:**
>
> ```powershell
> net accounts
> ```


> [!CAUTION]
> Never set **Account lockout duration** to **0**: that means a locked account stays locked until an admin unlocks it. Don't set the threshold below 3 either: a few typos would lock real users out.

---

#### WS.4. Local policies

##### WS.4.1 Audit Policy (record security events)
- [ ] **🎯 DO THIS — WS.4.1 Audit Policy (record security events)**

> [!NOTE]
> **💡 Why:** Without auditing there's no record of logins, account changes, or policy changes.

**⭐ EASIEST WAY — Click through the GUI:** `secpol.msc` → **Local Policies → Audit Policy**. Inspect the scenario-required categories. Prefer **Advanced Audit Policy Configuration → System Audit Policies**, selecting useful subcategories deliberately as described in [19.4](#194-audit-selectively-and-investigate-windows-events). Do not enable all high-volume auditing blindly.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> auditpol /set /subcategory:"Logon" /success:enable /failure:enable
> auditpol /get /category:*
> ```
> Also: **Security Options → Audit: Force audit policy subcategory settings… to override audit policy category settings → Enabled**.

##### WS.4.2 User Rights Assignment
- [ ] **🎯 DO THIS — WS.4.2 User Rights Assignment**

**⭐ EASIEST WAY — Click through the GUI:** `secpol.msc` → **Local Policies → User Rights Assignment**. Double-click a right to see who has it.

| Right | Should be |
|---|---|
| Access Credential Manager as a trusted caller | **No one** |
| Access this computer from the network | Administrators, Users (**remove Everyone and Guest**) |
| Act as part of the operating system | **No one** |
| Allow log on locally | Administrators, Users |
| Allow log on through Remote Desktop Services | Administrators, Remote Desktop Users (or nobody if RDP isn't needed) |
| Back up files and directories | Administrators, Backup Operators |
| Create a token object | **No one** |
| Create permanent shared objects | **No one** |
| Debug programs | **Administrators** only |
| Deny access to this computer from the network | **Guests** |
| Deny log on locally | **Guests** |
| Deny log on through Remote Desktop Services | **Guests** |
| Force shutdown from a remote system | Administrators |
| Impersonate a client after authentication | Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE |
| Load and unload device drivers | Administrators |
| Lock pages in memory | **No one** |
| Manage auditing and security log | Administrators |
| Modify firmware environment values | Administrators |
| Restore files and directories | Administrators, Backup Operators |
| Take ownership of files or other objects | Administrators |

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> secedit /export /areas USER_RIGHTS /cfg $env:TEMP\rights.inf
> Select-String '^Se' $env:TEMP\rights.inf
> ```
> Accounts show as SIDs: `*S-1-1-0` = Everyone, `*S-1-5-32-545` = Users, `*S-1-5-32-546` = Guests, `*S-1-5-32-544` = Administrators. A long SID that starts with `S-1-5-21-` is one user account.

> [!WARNING]
> Look carefully at the **Deny** rights. A planted "Deny log on locally: **Users**" locks every normal user out.
> Don't remove **LOCAL SERVICE**, **NETWORK SERVICE**, **SERVICE** or entries that start with `NT SERVICE\`: Windows needs them.

##### WS.4.3 Security Options
- [ ] **🎯 DO THIS — WS.4.3 Security Options**

**⭐ EASIEST WAY — Click through the GUI:** `secpol.msc` → **Local Policies → Security Options**.

| Setting | Set to |
|---|---|
| Accounts: Guest account status | **Disabled** |
| Accounts: Limit local account use of blank passwords to console logon only | **Enabled** |
| Interactive logon: Do not require CTRL+ALT+DEL | **Disabled** |
| Interactive logon: Don't display last signed-in | **Enabled** |
| Interactive logon: Machine inactivity limit | **900** seconds |
| Interactive logon: Message title / text for users attempting to log on | A warning, e.g. "Authorized users only" |
| Interactive logon: Number of previous logons to cache (in case domain controller is not available) | **4** or fewer |
| Microsoft network client: Digitally sign communications (always) | **Enabled** |
| Microsoft network client: Digitally sign communications (if server agrees) | **Enabled** |
| Microsoft network client: Send unencrypted password to third-party SMB servers | **Disabled** |
| Microsoft network server: Digitally sign communications (always) | **Enabled** |
| Microsoft network server: Digitally sign communications (if client agrees) | **Enabled** |
| Network access: Allow anonymous SID/Name translation | **Disabled** |
| Network access: Do not allow anonymous enumeration of SAM accounts | **Enabled** |
| Network access: Do not allow anonymous enumeration of SAM accounts and shares | **Enabled** |
| Network access: Do not allow storage of passwords and credentials for network authentication | **Enabled** |
| Network access: Let Everyone permissions apply to anonymous users | **Disabled** |
| Network access: Restrict anonymous access to Named Pipes and Shares | **Enabled** |
| Network access: Restrict clients allowed to make remote calls to SAM | **Administrators** only |
| Network security: Do not store LAN Manager hash value on next password change | **Enabled** |
| Network security: LAN Manager authentication level | **Send NTLMv2 response only. Refuse LM & NTLM** |
| Shutdown: Allow system to be shut down without having to log on | **Disabled** |
| System objects: Strengthen default permissions of internal system objects (e.g. Symbolic Links) | **Enabled** |
| User Account Control: Admin Approval Mode for the Built-in Administrator account | **Enabled** |
| User Account Control: Behavior of the elevation prompt for administrators… | **Prompt for consent on the secure desktop** |
| User Account Control: Behavior of the elevation prompt for standard users | **Prompt for credentials on the secure desktop** |
| User Account Control: Detect application installations and prompt for elevation | **Enabled** |
| User Account Control: Only elevate UIAccess applications that are installed in secure locations | **Enabled** |
| User Account Control: Run all administrators in Admin Approval Mode | **Enabled** |
| User Account Control: Switch to the secure desktop when prompting for elevation | **Enabled** |
| User Account Control: Virtualize file and registry write failures to per-user locations | **Enabled** |
| Network security: Minimum session security for NTLM SSP based (including secure RPC) clients | **Require NTLMv2 session security** and **Require 128-bit encryption** (tick both) |
| Network security: Minimum session security for NTLM SSP based (including secure RPC) servers | **Require NTLMv2 session security** and **Require 128-bit encryption** (tick both) |

**Check it worked (a few of them):**
```powershell
Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa | Format-List LimitBlankPasswordUse, RestrictAnonymous, RestrictAnonymousSAM, NoLMHash, LmCompatibilityLevel
```
Wanted: `1`, `1`, `1`, `1`, `5`. A blank means the setting was never changed from the Windows default: set it in `secpol.msc`.
```powershell
Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0 | Format-List NTLMMinClientSec, NTLMMinServerSec   # both 537395200 = the two NTLM rows ticked
```

##### WS.4.4 PowerShell logging
- [ ] **🎯 DO THIS — WS.4.4 PowerShell logging**

> [!NOTE]
> **🎯 What:** Windows records every PowerShell script and command that runs.
> [!NOTE]
> **💡 Why it matters:** Attackers love PowerShell. With logging on, their commands end up in the event log.

**⭐ EASIEST WAY — Click through the GUI:** `gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → Windows PowerShell**:
- **Turn on PowerShell Script Block Logging** → **Enabled**
- **Turn on Module Logging** → **Enabled** → **Show…** → add `*` as a module name

**✅ Check it worked:**
```powershell
Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -ErrorAction SilentlyContinue   # EnableScriptBlockLogging : 1
Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging -ErrorAction SilentlyContinue        # EnableModuleLogging : 1
```

---

#### WS.5. Microsoft Defender antivirus

##### WS.5.1 Turn every protection on
- [ ] **🎯 DO THIS — WS.5.1 Turn every protection on**

**⭐ EASIEST WAY — Click through the GUI:** **Start → Windows Security → Virus & threat protection → Manage settings**. Turn **on**: Real-time protection, Cloud-delivered protection, Automatic sample submission, **Tamper Protection**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-MpComputerStatus | Format-List AntivirusEnabled, RealTimeProtectionEnabled, IsTamperProtected, AntivirusSignatureAge
> Set-MpPreference -DisableRealtimeMonitoring $false -PUAProtection Enabled -MAPSReporting Advanced -SubmitSamplesConsent SendSafeSamples
> ```
**✅ Check it worked:** `RealTimeProtectionEnabled` and `IsTamperProtected` say `True`.

##### WS.5.2 Remove planted exclusions
- [ ] **🎯 DO THIS (only if authorized) — WS.5.2 Remove planted exclusions**

> [!NOTE]
> **💡 Why:** Attackers tell Defender to ignore their folder.

**⭐ EASIEST WAY — Click through the GUI:** **Manage settings → Exclusions → Add or remove exclusions**. Remove anything you didn't add.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-MpPreference | Format-List ExclusionPath, ExclusionExtension, ExclusionProcess
> Remove-MpPreference -ExclusionPath "C:\Users\Public\tools"
> ```

##### WS.5.3 No policy that turns Defender off
- [ ] **🎯 DO THIS — WS.5.3 No policy that turns Defender off**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → Microsoft Defender Antivirus** → **Turn off Microsoft Defender Antivirus** must be **Not configured** (or Disabled). Check **Real-time Protection** in the same place.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -ErrorAction SilentlyContinue                          # DisableAntiSpyware : 1 is bad
> Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -ErrorAction SilentlyContinue     # any Disable value of 1 is bad
> ```

##### WS.5.4 Update and scan
- [ ] **🎯 DO THIS — WS.5.4 Update and scan**

```powershell
Update-MpSignature
Start-MpScan -ScanType QuickScan
Get-MpThreatDetection           # anything found
```

---

#### WS.6. Firewall

##### WS.6.1 Firewall on for every network type
- [ ] **🎯 DO THIS — WS.6.1 Firewall on for every network type**

**⭐ EASIEST WAY — Click through the GUI:** **Windows Security → Firewall & network protection**. **Domain**, **Private** and **Public** must all say *Firewall is on*.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Allow
> Get-NetFirewallProfile | Format-Table Name, Enabled, DefaultInboundAction, DefaultOutboundAction
> ```
>
**✅ Check it worked:** every profile shows `Enabled True`, `DefaultInboundAction Block`, and `DefaultOutboundAction` **Allow** or **NotConfigured**. **Block** there stops updates and can stop the Scoring Report updating; set it back with the first command unless the README asks for it.

##### WS.6.2 Check the inbound rules
- [ ] **🎯 DO THIS — WS.6.2 Check the inbound rules**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `wf.msc` → **Inbound Rules**. Sort by **Enabled**. Look for **allow** rules for strange programs (in `C:\Users\`, `C:\Temp`), strange ports (4444, 1337), or rules called something like "Windows Update Helper" that point at an odd program.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True | Where-Object { -not $_.DisplayGroup } |
>   ForEach-Object { "{0} -> {1}" -f $_.DisplayName, ($_ | Get-NetFirewallApplicationFilter).Program }
> Disable-NetFirewallRule -DisplayName "Evil Rule"
> ```

---

#### WS.7. Windows Update

##### WS.7.1 Install all updates
- [ ] **🎯 DO THIS — WS.7.1 Install all updates**

**⭐ EASIEST WAY — Click through the GUI:** **Settings → Windows Update → Check for updates** → install everything. If updates are **paused**, click **Resume updates**.

##### WS.7.2 Automatic updates on
- [ ] **🎯 DO THIS — WS.7.2 Automatic updates on**

**⭐ EASIEST WAY — Click through the GUI:** `gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → Windows Update** (on Windows 11 it is inside **Manage end user experience**; look there if you don't see it) → **Configure Automatic Updates** → **Enabled**, option **4 – Auto download and schedule the install**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-Service wuauserv | Format-Table Name, Status, StartType        # StartType must not be Disabled
> Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -ErrorAction SilentlyContinue
> ```
> `NoAutoUpdate : 1` there means updates are switched off. Fix it (and a disabled service) with:
> ```powershell
> Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name NoAutoUpdate -Value 0
> Set-Service wuauserv -StartupType Manual
> ```

##### WS.7.3 Update the other programs
- [ ] **🎯 DO THIS — WS.7.3 Update the other programs**

Firefox (**≡ → Help → About Firefox**), Chrome (**⋮ → Help → About Google Chrome**), and anything the README lists (e.g. Notepad++, 7-Zip, VLC). Old versions are a scored problem.

---

#### WS.8. Services

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `services.msc`. To turn a service off: double-click it → **Startup type: Disabled** → **Stop** → **OK**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Stop-Service -Name RemoteRegistry
> Set-Service -Name RemoteRegistry -StartupType Disabled
> ```

##### WS.8.1 Turn off risky services (unless the README needs them)
- [ ] **🎯 DO THIS (only if authorized) — WS.8.1 Turn off risky services (unless the README needs them)**

| Service / stable name | If **not required** | Preserve / verify before changing |
|---|---|---|
| Remote Registry `RemoteRegistry` | Disable | Remote administration may need it; **never disable RPC** |
| Telnet Server `TlntSvr` | Disable if installed | Telnet *Client* is separate; absent on many versions |
| SNMP / Trap `SNMP`, `SNMPTRAP` | Disable | If monitoring is required, restrict managers, community strings and firewall sources |
| SSDP `SSDPSRV` / UPnP `upnphost` | Disable | Check multimedia/device discovery dependencies |
| IIS FTP `FTPSVC` | Disable | If FTP required, retain authentication, TLS and passive data-port access |
| IIS web `W3SVC` | Disable | Preserve README-required sites, IIS bindings and app pools |
| Remote Desktop `TermService` | Disable RDP via Settings | **Never stop your only RDP connection**; keep NLA, approved users and console recovery |
| Routing/VPN `RemoteAccess` | Disable | Preserve required VPN, routes and entire subnet connectivity |
| Internet Connection Sharing `SharedAccess` | Disable | Check VM/ICS/NAT dependencies; **do not disable** firewall `mpssvc` |
| Print Spooler `Spooler` | Disable | Keep if print or print-server functions are required; otherwise patch/restrict drivers |
| Xbox `XblAuthManager`, `XblGameSave`, `XboxNetApiSvc` | Disable | Services vary by Windows version; no wildcard disabling |
| Simple TCP/IP `simptcp` | Disable | Legacy optional component often absent; removal ≠ service disabling |
| WebClient `WebClient` | Disable | Required WebDAV/mapped-drive workflows may depend on it |
| Media network sharing `WMPNetworkSvc` | Disable | Local playback is separate; preserve required media |
| OpenSSH Server `sshd` | Disable | If required: back up `C:\ProgramData\ssh\sshd_config`, validate with `sshd.exe -t`, test second SSH client |
| WinRM `WinRM` | Disable only if not used | **Server Manager/remote PowerShell may require it**; check `winrm get winrm/config/service` and authentication policy |
| Remote-control apps (TeamViewer, AnyDesk, VNC, RustDesk) | Investigate; uninstall only if prohibited | Service names vary; preserve installer/evidence and required unattended management |

> [!CAUTION]
> Never disable a service the README lists as critical, and leave services you don't recognise alone until you have looked them up. Disabling the wrong one (e.g. RPC, DCOM, Windows Event Log) can break the computer.

**⭐ EASIEST WAY — GUI (one workflow for all listed services)**

1. **Read the image README first.** In **Win + R → `services.msc`**, find the exact **installed** service. Missing entries are normal; do not install a service just to check it.
2. **Before changing:** Record its *Service name*, *Startup type* (Automatic, Delayed, Manual or Disabled), *running status* and **Dependencies**. Confirm the service is not required by a user, app or server role.
3. **If genuinely unneeded:** Open **Properties → Startup type: Disabled → Apply → Stop → OK**. If stopping fails or warns about dependencies, investigate rather than force it. For RDP, disable remote access in **System settings** first; do not kill your only session.
4. **Verify:** Reopen Services (or use PowerShell below), confirm only the intended service changed, test required website/FTP/printing/remote/network functions, and recheck the scoring report.
5. **↩️ Undo:** Restore the **recorded** startup type using Services; start the service only if it was originally running. Re-test required functions. A stopped service is not the same as a disabled service.

> [!NOTE]
> **🔁 Alternate (optional) — elevated PowerShell, one named service at a time:**
>
> ```powershell
> Get-Service -Name 'RemoteRegistry' -ErrorAction SilentlyContinue | Select-Object Name,Status,StartType,DependentServices
> Stop-Service -Name 'RemoteRegistry'   # only after dependencies/README check
> Set-Service -Name 'RemoteRegistry' -StartupType Disabled
> Get-Service -Name 'RemoteRegistry' | Select-Object Name,Status,StartType
> # Undo: Set-Service -Name 'RemoteRegistry' -StartupType Manual  # use the recorded old setting
> # Undo: Start-Service -Name 'RemoteRegistry'  # only if it was previously running
> ```
>
> Substitute only an **exact name from the table** after confirming it exists; do not run both GUI and PowerShell just to repeat a fix.

> [!CAUTION]
> **Important:** Do not disable protected or core services such as RPC, DCOM or Windows Event Log. If access is denied, check elevation, protection and effective Group Policy; never use force to bypass dependencies. Delayed Automatic start must be restored in the GUI. Removing a remote-control *application* is a separate, less reversible decision and needs explicit authorization.

##### WS.8.2 Make sure the security services are running
- [ ] **🎯 DO THIS — WS.8.2 Make sure the security services are running**

Windows Defender (`WinDefend`), Windows Defender Firewall (`mpssvc`), Windows Event Log (`EventLog`), Windows Update (`wuauserv`, Manual is fine), Security Center (`wscsvc`, not on Windows Server). None of these may be **Disabled**.

```powershell
Get-Service WinDefend, mpssvc, EventLog, wuauserv, wscsvc -ErrorAction SilentlyContinue | Format-Table Name, Status, StartType   # on Windows Server, wscsvc is simply missing from the list
```

##### WS.8.3 Printer drivers: PrintNightmare fixes
- [ ] **🎯 DO THIS — WS.8.3 Printer drivers: PrintNightmare fixes**

> [!CAUTION]
> **🎯 What:** Only administrators may install printer drivers, and "Point and Print" must always show a warning and ask for an admin password.
> [!NOTE]
> **💡 Why it matters:** PrintNightmare (CVE-2021-34527) lets a normal user install a "printer driver" that runs as SYSTEM, the most powerful account. An image can plant the old, unsafe setting even when Windows is updated.

**⭐ EASIEST WAY — Click through the GUI:** `gpedit.msc` → **Computer Configuration → Administrative Templates → Printers**:
- **Limits print driver installation to Administrators**: **Enabled** (only on images updated since October 2021; skip it if it isn't in the list).
- **Point and Print Restrictions**: **Enabled**, and both "When installing drivers for a new connection" and "When updating drivers for an existing connection" set to **Show warning and elevation prompt**.

On Home, or if the first policy isn't in the list, use the Typing commands.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> $pp = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'
> if (-not (Test-Path $pp)) { New-Item -Path $pp -Force | Out-Null }
> New-ItemProperty -Path $pp -Name RestrictDriverInstallationToAdministrators -Value 1 -PropertyType DWord -Force
> New-ItemProperty -Path $pp -Name NoWarningNoElevationOnInstall -Value 0 -PropertyType DWord -Force
> New-ItemProperty -Path $pp -Name UpdatePromptSettings -Value 0 -PropertyType DWord -Force
> ```
>
**✅ Check it worked:** `Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'` shows `RestrictDriverInstallationToAdministrators : 1` and the other two `0`. If the README doesn't need printing, also turn off the Print Spooler (8.1).

---

#### WS.9. Windows features

##### WS.9.1 Turn off old, insecure features
- [ ] **🎯 DO THIS (only if authorized) — WS.9.1 Turn off old, insecure features**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `optionalfeatures` → **untick**:
- **SMB 1.0/CIFS File Sharing Support** (the WannaCry hole)
- **Telnet Client**
- **TFTP Client**
- **Windows PowerShell 2.0**
- **Internet Information Services** (only if the README doesn't need a website/FTP)
- **Internet Explorer 11** (Windows 10)

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
> Disable-WindowsOptionalFeature -Online -FeatureName TelnetClient -NoRestart
> Disable-WindowsOptionalFeature -Online -FeatureName TFTP -NoRestart
> Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart
> Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
> Get-WindowsOptionalFeature -Online | Where-Object State -eq Enabled | Select-Object FeatureName
> ```
> An error saying a feature is unknown just means it isn't on this version (PowerShell 2.0 is gone from up-to-date Windows 11 24H2). Turning a feature off finishes at the next restart, so restart once near the end (see Final checks).
>
**✅ Check it worked:** `Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol` says `False`, and the features above are not in the Enabled list.

##### WS.9.2 Optional features (OpenSSH Server, SNMP)
- [ ] **🎯 DO THIS — WS.9.2 Optional features (OpenSSH Server, SNMP)**

> [!NOTE]
> **🎯 What:** Some extras are "optional features" instead of Windows features: **OpenSSH Server** and **SNMP** are the risky ones.
**⭐ EASIEST WAY — Click through the GUI:** **Settings → System → Optional features** (older versions: **Settings → Apps → Optional features**) → click the feature → **Remove**. Keep it if the README needs it.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-WindowsCapability -Online | Where-Object State -eq Installed | Select-Object Name
> Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0   # skip if the README needs SSH
> Remove-WindowsCapability -Online -Name SNMP.Client~~~~0.0.1.0       # skip if the README needs SNMP
> ```
**✅ Check it worked:** run the first line again: the removed names are gone.

---

#### WS.10. Remote access

##### WS.10.1 Remote Assistance off
- [ ] **🎯 DO THIS — WS.10.1 Remote Assistance off**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `SystemPropertiesRemote` → untick **Allow Remote Assistance connections to this computer**.

**✅ Check it worked:**
```powershell
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' | Select-Object fAllowToGetHelp   # 0 = off
```

##### WS.10.2 Remote Desktop off (or secured)
- [ ] **🎯 DO THIS — WS.10.2 Remote Desktop off (or secured)**

> [!CAUTION]
> If the README lists Remote Desktop as a critical service, **don't turn it off**: you lose points for breaking it.

**🔎 Check:**
```powershell
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' | Select-Object fDenyTSConnections   # 1 = off, 0 = on
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -ErrorAction SilentlyContinue | Select-Object fDenyTSConnections, UserAuthentication
```
The second line shows Group Policy values. If they are there, they **win** over the first line and over the Settings switch: fix them in `gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → Remote Desktop Services → Remote Desktop Session Host → Connections → Allow users to connect remotely by using Remote Desktop Services** (and **Security → Require user authentication for remote connections by using Network Level Authentication**).

**Not needed:** **Settings → System → Remote Desktop → Off**, or:
```powershell
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 1
```

**Needed (README says so):** keep it on, but tick **Require devices to use Network Level Authentication to connect**, and make sure only the right users are in **Remote Desktop Users**. Or:
```powershell
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value 1
```

---

#### WS.11. Shared folders

##### WS.11.1 Remove shares that aren't needed
- [ ] **🎯 DO THIS (only if authorized) — WS.11.1 Remove shares that aren't needed**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `fsmgmt.msc` → **Shares**. Right-click a share → **Stop Sharing**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-SmbShare
> Remove-SmbShare -Name Secret -Force
> Get-SmbShareAccess -Name Public                                    # for a share you keep: who can use it
> Revoke-SmbShareAccess -Name Public -AccountName Everyone -Force   # take Everyone off it
> ```
> [!CAUTION]
> Leave the built-in shares alone: **ADMIN$, C$, IPC$** (and **print$**).

---

#### WS.12. Prohibited software

##### WS.12.1 Uninstall hacking tools, games, torrent and remote-control programs
- [ ] **🎯 DO THIS (only if authorized) — WS.12.1 Uninstall hacking tools, games, torrent and remote-control programs**

**⭐ EASIEST WAY — Click through the GUI:** **Settings → Apps → Installed apps** (or **Win + R → appwiz.cpl**). Sort by name and read the **whole** list.

Look for:
- **Hacking:** Wireshark, Npcap/WinPcap, Nmap, Cain & Abel, John the Ripper, Hashcat, Cheat Engine, keyloggers, "password recovery" tools
- **Games:** Steam, Epic, Minecraft, Roblox, Solitaire, Candy Crush
- **File-sharing:** uTorrent, BitTorrent, qBittorrent, Vuze, FrostWire
- **Remote control:** TeamViewer, AnyDesk, VNC, RustDesk

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
>   Where-Object DisplayName | Sort-Object DisplayName | Format-Table DisplayName, DisplayVersion, Publisher
> ```

##### WS.12.2 Store apps and games
- [ ] **🎯 DO THIS — WS.12.2 Store apps and games**

```powershell
Get-AppxPackage -AllUsers | Where-Object Name -match 'Solitaire|CandyCrush|Minecraft|Roblox|king.com' | Select-Object Name
Get-AppxPackage -AllUsers *Solitaire* | Remove-AppxPackage -AllUsers
```

##### WS.12.3 "Portable" tools that aren't installed
- [ ] **🎯 DO THIS — WS.12.3 "Portable" tools that aren't installed**

Hacking tools are often just an `.exe` sitting in a folder: look in **Downloads**, **Desktop**, `C:\Users\Public`, `C:\Temp`, and `C:\` itself.
```powershell
Get-ChildItem C:\Users, C:\Temp -Recurse -Force -Include nc.exe,ncat.exe,nmap.exe,mimikatz*,*keylog*,psexec*,john*.exe,hashcat*.exe -ErrorAction SilentlyContinue
```

---

#### WS.13. Prohibited files

##### WS.13.1 Show hidden files first
- [ ] **🎯 DO THIS — WS.13.1 Show hidden files first**

**File Explorer → View → Show → Hidden items** (Windows 10: **View → Hidden items**). Also tick **File name extensions**.

##### WS.13.2 Find media files
- [ ] **🎯 DO THIS — WS.13.2 Find media files**

```powershell
Get-ChildItem C:\Users -Recurse -Force -Include *.mp3,*.mp4,*.wav,*.wma,*.wmv,*.avi,*.mkv,*.mov,*.flac,*.m4a,*.aac,*.ogg,*.torrent -ErrorAction SilentlyContinue |
  Select-Object FullName
Remove-Item "C:\Users\bob\Music\song.mp3"
```
Also look in other folders on `C:\` that aren't part of Windows (e.g. `C:\Media`, `C:\Share`), and **empty the Recycle Bin** when forensics is done.

##### WS.13.3 Password lists and other data
- [ ] **🎯 DO THIS — WS.13.3 Password lists and other data**

```powershell
Get-ChildItem C:\Users -Recurse -Force -Include *password*,*creditcard*,*.pcap,*.kdbx -ErrorAction SilentlyContinue | Select-Object FullName
```

---

#### WS.14. Backdoors and malware

##### WS.14.1 Programs that start at logon
- [ ] **🎯 DO THIS — WS.14.1 Programs that start at logon**

**⭐ EASIEST WAY — Click through the GUI:** **Task Manager (Ctrl+Shift+Esc) → Startup apps**. Also open these folders with **Win + R**: `shell:startup` and `shell:common startup`.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-CimInstance Win32_StartupCommand | Format-Table Name, Command, Location -AutoSize
> Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run, HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run, HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -ErrorAction SilentlyContinue
> Remove-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Run -Name "Updater"
> ```
> Red flags: `powershell -enc` followed by a long string, `-WindowStyle Hidden`, `nc.exe`, `mshta`, `.vbs`/`.bat`/`.ps1` files, anything in `C:\Users\Public` or `Temp`.

##### WS.14.2 Scheduled tasks
- [ ] **🎯 DO THIS — WS.14.2 Scheduled tasks**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `taskschd.msc` → **Task Scheduler Library**. Check each task's **Actions** tab. Non-Microsoft tasks are usually in the top folder.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
> ```powershell
> Get-ScheduledTask | Where-Object TaskPath -notlike '\Microsoft\*' |
>   ForEach-Object { "{0}{1} -> {2} {3}" -f $_.TaskPath, $_.TaskName, $_.Actions.Execute, $_.Actions.Arguments }
> Unregister-ScheduledTask -TaskName "BadTask" -Confirm:$false
> ```

##### WS.14.3 Services that run strange programs
- [ ] **🎯 DO THIS — WS.14.3 Services that run strange programs**

```powershell
Get-CimInstance Win32_Service | Where-Object { $_.PathName -notmatch 'Windows\\|Program Files' } | Format-Table Name, State, PathName -AutoSize
Stop-Service -Name BadService -Force; Set-Service -Name BadService -StartupType Disabled   # BadService = the bad one's Name
sc.exe delete BadService            # only for a service you are sure is malware. Type sc.exe: in PowerShell, sc means something else
```

##### WS.14.4 Sticky Keys / Utility Manager backdoor
- [ ] **🎯 DO THIS — WS.14.4 Sticky Keys / Utility Manager backdoor**

> [!NOTE]
> **💡 Why:** Replacing `sethc.exe` (press Shift 5 times) or `utilman.exe` (the accessibility button) with `cmd.exe` gives anyone a SYSTEM command prompt **at the login screen**.

```powershell
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' |
  Where-Object { $_.GetValue('Debugger') } | ForEach-Object { "$($_.PSChildName) -> $($_.GetValue('Debugger'))" }
foreach ($f in 'sethc','utilman','osk','Magnify','Narrator') { "$f -> " + (Get-Item "C:\Windows\System32\$f.exe").VersionInfo.OriginalFilename }   # each must show its own name (.mui is fine), not Cmd.Exe
```
**🛠️ Fix:** delete the `Debugger` value. If the file itself was replaced, run `sfc /scanfile=C:\Windows\System32\sethc.exe`.

##### WS.14.5 The hosts file
- [ ] **🎯 DO THIS — WS.14.5 The hosts file**

```powershell
notepad C:\Windows\System32\drivers\etc\hosts
```
Comments, localhost entries and README-required internal host mappings can all be legitimate. Back up the file, then remove only confirmed unauthorized overrides; verify name resolution afterwards.

##### WS.14.6 Programs listening for connections
- [ ] **🎯 DO THIS — WS.14.6 Programs listening for connections**

```powershell
Get-NetTCPConnection -State Listen | Select-Object LocalPort, OwningProcess, @{n='Process';e={(Get-Process -Id $_.OwningProcess).ProcessName}} | Sort-Object LocalPort
```
`nc`, `ncat`, `powershell` or `python` listening on an unexpected port warrants investigation; development tools and required applications can legitimately listen too. Stop it with `Stop-Process -Id 4242 -Force` (use the number from the `OwningProcess` column), then find what starts it (14.1–14.3).

---

#### WS.15. Other settings

##### WS.15.1 User Account Control
- [ ] **🎯 DO THIS — WS.15.1 User Account Control**

**Start** → type **Change User Account Control settings** → move the slider to the **top** (**Always notify**).

**✅ Check it worked:**
```powershell
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System | Format-List EnableLUA, ConsentPromptBehaviorAdmin, PromptOnSecureDesktop
```
Wanted: `1`, `2`, `1`. If `EnableLUA` was `0`, UAC only comes back after a restart.

##### WS.15.2 AutoPlay off
- [ ] **🎯 DO THIS — WS.15.2 AutoPlay off**

**Settings → Bluetooth & devices → AutoPlay** (Windows 10: **Devices → AutoPlay**) → **Use AutoPlay for all media and devices: Off**.

**Policy:** `gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → AutoPlay Policies → Turn off Autoplay** → **Enabled**, **All drives**.

##### WS.15.3 Screen saver with password
- [ ] **🎯 DO THIS — WS.15.3 Screen saver with password**

**Settings → Personalization → Lock screen → Screen saver** → pick one, **Wait: 10 minutes**, tick **On resume, display logon screen**.

##### WS.15.4 Turn off LLMNR
- [ ] **🎯 DO THIS (only if authorized) — WS.15.4 Turn off LLMNR**

`gpedit.msc` → **Computer Configuration → Administrative Templates → Network → DNS Client → Turn off multicast name resolution → Enabled**.

**✅ Check it worked:**
```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' | Select-Object EnableMulticast   # must be 0
```

##### WS.15.5 SmartScreen on
- [ ] **🎯 DO THIS — WS.15.5 SmartScreen on**

**Windows Security → App & browser control → Reputation-based protection settings** → turn everything **on**.

> [!WARNING]
> **Do not turn on BitLocker** on a practice image. Without the recovery key you can lock yourself out of the whole VM.

###### WS.15.6 WDigest off (avoid plaintext password caching)
- [ ] **🎯 Inspect the \`UseLogonCredential\` policy if appropriate to the installed Server release.**

**⭐ EASIEST WAY — GUI (Desktop Experience):** **Win + R → \`regedit\` → \`HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest\`**. If the DWORD **\`UseLogonCredential\`** exists and equals **1**, export the key and set it to **0**. If absent, verify default behavior before adding any value.

**✅ VERIFY:** Value is **0** if configured, and legitimate logon still works. **↩️ UNDO:** Restore only an accidental registry change from the saved key.

> [!NOTE]
> **🔁 ALTERNATE — PowerShell read-only check (Server Core):**
>
> \`\`\`powershell
> Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' -Name UseLogonCredential -ErrorAction SilentlyContinue
> \`\`\`

##### WS.15.7 NetBIOS over TCP/IP off
- [ ] **🎯 DO THIS — WS.15.7 NetBIOS over TCP/IP off**

> [!NOTE]
> **💡 Why it matters:** Like LLMNR (15.4), attackers answer NetBIOS name lookups to steal password hashes.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `ncpa.cpl` → right-click the network adapter → **Properties** → **Internet Protocol Version 4 (TCP/IPv4)** → **Properties** → **Advanced…** → **WINS** → **Disable NetBIOS over TCP/IP** → **OK**.

**✅ Check it worked:**
```powershell
Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE" | Select-Object Description, TcpipNetbiosOptions   # 2 = off
```

---

#### WS.16. Web browsers

##### WS.16.1 Microsoft Edge
- [ ] **🎯 DO THIS — WS.16.1 Microsoft Edge**

**⋯ → Settings → Privacy, search, and services** → **Microsoft Defender SmartScreen: On**, **Block potentially unwanted apps: On**. **Cookies and site permissions → Pop-ups and redirects → Block**. **⋯ → Settings → Profiles → Passwords → Offer to save passwords: Off**. Update via **⋯ → Help and feedback → About Microsoft Edge**.

##### WS.16.2 Firefox (if installed)
- [ ] **🎯 DO THIS — WS.16.2 Firefox (if installed)**

**≡ → Settings → Privacy & Security**:
- **Block pop-up windows** ✔
- **Warn you when websites try to install add-ons** ✔
- **Block dangerous and deceptive content** ✔ (all three boxes)
- **HTTPS-Only Mode** → Enable in all windows
- **Passwords → Ask to save passwords** ✘ (untick it)

Then **≡ → Help → About Firefox** to update. Also check **Add-ons and themes** for extensions you don't recognise.

##### WS.16.3 Chrome (if installed)
- [ ] **🎯 DO THIS — WS.16.3 Chrome (if installed)**

**⋮ → Settings → Privacy and security → Security → Standard (or Enhanced) protection**. **Site settings → Pop-ups and redirects → Don't allow**. **Autofill and passwords → Google Password Manager → Settings → Offer to save passwords: Off**. Update via **Help → About Google Chrome**.

---

#### WS.17. Critical services

If the README says this server runs a website, FTP or file shares, harden those **required server roles** instead of removing them. The full IIS/FTP/share procedures are already in **9.1–9.6 and 12.5** above.

---

#### WS.18. Final checks

- [ ] **🎯 DO THIS —** Critical services still running (`services.msc`)
- [ ] **🎯 DO THIS —** You can still log in and open an admin PowerShell
- [ ] **🎯 DO THIS —** Scoring Report shows **no penalties**
- [ ] **🎯 DO THIS —** Forensics answers saved
- [ ] **🎯 DO THIS —** Final snapshot
- [ ] **🎯 DO THIS —** Reboot **once** at the end only if updates or Windows features (9.1) need it, then check the Scoring Report again

#### WS.19. Manual verification, recovery and missing investigation steps

##### WS.19.1 Record a recoverable Windows baseline

- [ ] **🎯 DO THIS — WS.19.1 Record a recoverable Windows baseline**

> [!NOTE]
> **🎯 What:** Save the original configuration before changing a table of settings.

> [!NOTE]
> **💡 Why it matters:** A screenshot of a target value is not a backup of the old value. Account deletion, password resets and registry merges have different recovery limits.

> [!CAUTION]
> **🛑 Before changing anything:** Use an authorized administrator at the VM console. Follow round rules on snapshots. Backups can contain sensitive policy and account information; keep them local and private.

**⭐ EASIEST WAY — Click through the GUI:** Open File Explorer, create `C:\CP-Backups`, then use **Properties → Security → Advanced** to restrict access to Administrators and SYSTEM. Do not remove access from your current administrator. Open `secpol.msc` and use **Action → Export Policy**; in `wf.msc`, right-click the root and choose **Export Policy**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> New-Item -ItemType Directory -Path C:\CP-Backups -ErrorAction Stop
> ```
>
If it already exists, use that folder and unique filenames rather than overwriting previous backups.

```powershell
secedit /export /cfg C:\CP-Backups\security-before.inf
```

Exports security policy, including rights and account settings. A successful export reports completion; check the file exists.

```powershell
auditpol /backup /file:C:\CP-Backups\audit-before.csv
```

Saves audit subcategories separately.

```powershell
netsh advfirewall export C:\CP-Backups\firewall-before.wfw
```

Saves firewall policy. Also record account and service state:

```powershell
Get-LocalUser | Select-Object Name,Enabled,SID | Export-Csv C:\CP-Backups\users-before.csv -NoTypeInformation
Get-CimInstance Win32_Service | Select-Object Name,StartMode,State,PathName | Export-Csv C:\CP-Backups\services-before.csv -NoTypeInformation
```

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
**✅ Check it worked:** Open each export as text where applicable and verify it is nonempty. Do not assume a CSV can recreate a deleted user with its old SID.

> [!WARNING]
> **↩️ Undo:** Prefer the individual setting's recorded value. A whole security-policy restore affects many settings:

```powershell
secedit /configure /db C:\CP-Backups\restore.sdb /cfg C:\CP-Backups\security-before.inf /areas SECURITYPOLICY USER_RIGHTS
```

Only use this after reviewing the backup and scope. For an audit-only restore:

```powershell
auditpol /restore /file:C:\CP-Backups\audit-before.csv
```

> [!CAUTION]
> **⚠️ Warnings:** Domain policy can override local changes. Password resets cannot recover the previous password and may make EFS files or stored credentials inaccessible. Preserve evidence before resets.

##### WS.19.2 Apply account and privileged-group table entries safely

- [ ] **🎯 DO THIS — WS.19.2 Apply account and privileged-group table entries safely**

> [!NOTE]
> **🎯 What:** Reconcile each account and each powerful group with the README.

> [!NOTE]
> **💡 Why it matters:** Names alone do not reveal service-account dependencies, nested memberships or renamed built-in accounts.

> [!CAUTION]
> **🛑 Before changing anything:** Run `whoami /user` and keep a second tested administrator. Review the account's home directory, running services and scheduled tasks. On a Domain Controller use the Server AD procedure, not local-user commands.

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → **Users** → double-click the exact account → **Member Of**. Compare every membership with section 2.5. For a confirmed unauthorized account, first tick **Account is disabled**. In **Groups**, open each powerful group individually, select the incorrect member and click **Remove → Apply**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-LocalUser -Name mallory | Format-List Name,Enabled,SID,Description,LastLogon
> Get-CimInstance Win32_Service | Where-Object StartName -match 'mallory' | Select-Object Name,StartName
> Get-ScheduledTask | Where-Object { $_.Principal.UserId -match 'mallory' } | Select-Object TaskPath,TaskName,Principal
> ```
>
No task/service results only means these queries found none; inspect application configuration too.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Disable-LocalUser -Name mallory
> ```
>
For an unauthorized membership, remove that membership rather than the whole account:

```powershell
Remove-LocalGroupMember -Group 'Backup Operators' -Member mallory
```

**✅ Check it worked:** Repeat `Get-LocalUser` or `Get-LocalGroupMember 'Backup Operators'`. The disabled account shows `Enabled : False`; a removed member no longer appears. Test an authorized user's ordinary and administrator workflows.

> [!WARNING]
> **↩️ Undo:** `Enable-LocalUser -Name mallory` restores a mistakenly disabled account. `Add-LocalGroupMember -Group 'Backup Operators' -Member mallory` restores only a recorded membership. Deleted accounts need proper account/data recovery; creating the same name generates a different SID.

> [!CAUTION]
> **⚠️ Warnings:** Do not disable every built-in account without checking its purpose. `PasswordExpires` from `Get-LocalUser` is a date or empty value, not simply a true/false policy flag. Service identities may have managed password behavior.

##### WS.19.3 Work through password, rights and security-option tables

- [ ] **🎯 DO THIS — WS.19.3 Work through password, rights and security-option tables**

> [!NOTE]
> **🎯 What:** Change each table row deliberately and check the effective policy.

> [!NOTE]
> **💡 Why it matters:** User rights are privileges, not ordinary group memberships. A **Deny** entry takes precedence over an allow entry. Compatibility-sensitive policies can break file sharing or authentication.

> [!CAUTION]
> **🛑 Before changing anything:** Export policy using 19.1. On domain members inspect policy precedence first:

```powershell
gpresult /h C:\CP-Backups\gpresult-before.html
net accounts
```

Open the HTML locally; note the winning GPO. `net accounts` reports local account limits; domain account policy is separate.

**⭐ EASIEST WAY — Click through the GUI:** Press **Win + R → secpol.msc**. For each password/lockout row open **Account Policies → Password Policy / Account Lockout Policy**; double-click the exact row, record its current value, enter the README value, and click **Apply → OK**. Set lockout threshold first, then its duration/window. Under **Local Policies → User Rights Assignment**, open one right, record every principal, and use **Add User or Group / Remove** only for that right. Under **Security Options**, open each named setting and choose its explicit option. Record units such as seconds, minutes or days.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> secedit /export /cfg C:\CP-Backups\security-after.inf /areas SECURITYPOLICY USER_RIGHTS
> Select-String -Path C:\CP-Backups\security-after.inf -Pattern '^Se|PasswordComplexity|ClearTextPassword|MinimumPasswordLength|Lockout'
> ```
>
Compare the before/after files. `SeDebugPrivilege` corresponds to **Debug programs**, `SeServiceLogonRight` to **Log on as a service**, and `SeDenyInteractiveLogonRight` to **Deny log on locally**. Resolve an unfamiliar SID before removing it:

```powershell
([System.Security.Principal.SecurityIdentifier]'S-1-5-32-544').Translate([System.Security.Principal.NTAccount]).Value
```

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> net accounts /uniquepw:24 /maxpwage:90 /minpwage:1 /minpwlen:12
> ```
>
History prevents immediate reuse, maximum age requires periodic changes, minimum age limits rapid cycling and minimum length rejects short future passwords. These settings do not retroactively strengthen existing passwords.

**✅ Check it worked:** Repeat `net accounts`, export the policy again, and test one noncritical authorized account from a separate session. Confirm legitimate network access still works. Do not intentionally lock out your administrator to test the threshold.

> [!WARNING]
> **↩️ Undo:** Restore the individual row's recorded principals/value. Use the reviewed policy backup only when necessary. A refresh that reverses your edit means the owning GPO needs correction by its authorized administrator.

> [!CAUTION]
> **⚠️ Warnings:** The tables are workstation starting points, not universal server baselines. Preserve service SIDs and required operators. Mandatory signing, NTLM restrictions, cached-logon settings and anonymous-access restrictions require client compatibility checks. Do not add your own admin account to a deny right.

##### WS.19.4 Audit selectively and investigate Windows events

- [ ] **🎯 DO THIS — WS.19.4 Audit selectively and investigate Windows events**

> [!NOTE]
> **🎯 What:** Record useful authentication, account and policy changes without blindly enabling every audit category.

> [!NOTE]
> **💡 Why it matters:** High-volume object/process auditing can fill logs quickly. A missing event does not establish that an action never occurred; the policy may not have recorded it.

> [!CAUTION]
> **🛑 Before changing anything:** Back up audit policy and export relevant logs before remediation. Do not clear logs or disable Windows Event Log.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → eventvwr.msc → Windows Logs → Security → Filter Current Log**. Enter `4624,4625,4720,4732,1102`. Use **Save All Events As** for an EVTX copy. In `secpol.msc` use **Advanced Audit Policy Configuration → System Audit Policies** to configure the required subcategory, not both competing legacy and advanced settings.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> auditpol /get /category:*
> Get-WinEvent -FilterHashtable @{LogName='Security';Id=4624,4625,4720,4732,1102;StartTime=(Get-Date).AddDays(-2)} -MaxEvents 100 | Format-List TimeCreated,Id,Message
> ```
>
4624 is a successful logon; 4625 is failure; 4720 creates a user; 4732 adds a member to a local security group; 1102 records clearing the Security audit log. Read the target account, source address and logon type, not just the event ID.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> auditpol /set /subcategory:"Logon" /success:enable /failure:enable
> ```
>
Use `auditpol /list /subcategory:*` to find localized names. Process creation events need their own policy; command-line capture may expose secrets.

**✅ Check it worked:** `auditpol /get /subcategory:"Logon"` should show Success and Failure. Test a normal permitted login and inspect its event. Confirm log retention and maximum size in **Security → Properties**.

> [!WARNING]
> **↩️ Undo:** Restore the original subcategory or the audit CSV from 19.1. Preserve existing events; reverting policy does not require deleting logs.

> [!CAUTION]
> **⚠️ Warnings:** Timestamp display follows local time. Correlate with timezone and system clock before inferring event order.

##### WS.19.5 Firewall rule inspection and required ports

- [ ] **🎯 DO THIS — WS.19.5 Firewall rule inspection and required ports**

> [!NOTE]
> **🎯 What:** Enable host firewall profiles and permit only the required application traffic.

> [!NOTE]
> **💡 Why it matters:** An enabled firewall can still allow an unwanted inbound rule. A listener on localhost is different from a listener on every address.

> [!CAUTION]
> **🛑 Before changing anything:** Export the firewall, identify the current profile, service executable, protocol, local port and authorized source networks. Never reset the firewall as a first step.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → wf.msc**. Open **Windows Defender Firewall Properties**; enable the appropriate Domain, Private and Public profiles, normally block unmatched inbound and allow outbound. Under **Inbound Rules**, double-click a candidate rule and inspect **Programs and Services**, **Protocols and Ports**, **Scope**, **Advanced** and **General**. Disable only a confirmed unauthorized rule. For a required service, **New Rule → Custom**, scope it to the program/port and authorized remote IPs, choose the appropriate profiles, and give it a descriptive name.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-NetConnectionProfile
> Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction,DefaultOutboundAction
> Get-NetFirewallRule -Enabled True -Direction Inbound | Select-Object Name,DisplayName,Action,Profile
> Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
> Get-NetUDPEndpoint | Select-Object LocalAddress,LocalPort,OwningProcess
> ```
>
`0.0.0.0` and `::` generally mean all local addresses; `127.0.0.1` and `::1` mean loopback. Rule listing needs the port/address filters to explain scope:

```powershell
Get-NetFirewallRule -Name 'CP-Required-HTTPS' -ErrorAction SilentlyContinue | Get-NetFirewallPortFilter
```

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> New-NetFirewallRule -Name 'CP-Required-HTTPS' -DisplayName 'CP Required HTTPS from lab' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443 -RemoteAddress 192.168.10.0/24 -Profile Private
> ```
>
Create and verify required exceptions before enabling a previously disabled profile.

```powershell
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
```

**✅ Check it worked:** Repeat the profile query. From an authorized second machine run `Test-NetConnection server-name -Port 443` in PowerShell, then open the actual HTTPS site. `TcpTestSucceeded : True` proves TCP establishment, not application correctness. Test an unauthorized path only in the permitted lab.

> [!WARNING]
> **↩️ Undo:** Remove only the rule you created with `Remove-NetFirewallRule -Name 'CP-Required-HTTPS'`, or restore a disabled rule by its recorded Name. Whole-policy import (`netsh advfirewall import ...`) replaces policy and can remove later valid changes; review first and use the console.

> [!CAUTION]
> **⚠️ Warnings:** Group Policy rules can override local behavior. Avoid broad `Any` source/port exceptions and disabling the whole firewall to troubleshoot one service.

##### WS.19.6 Defender, updates and application health

- [ ] **🎯 DO THIS — WS.19.6 Defender, updates and application health**

> [!NOTE]
> **🎯 What:** Check protection state, pending security updates and required applications.

> [!NOTE]
> **💡 Why it matters:** An installed antivirus product may be passive or have exclusions that defeat protection. Scan/remediation can modify evidence.

> [!CAUTION]
> **🛑 Before changing anything:** Answer relevant forensics questions. Record third-party antivirus, exclusions, update policy and required application versions. Windows 10's ordinary support ended in October 2025; check the image's edition/support arrangement instead of assuming all versions receive regular updates.

**⭐ EASIEST WAY — Click through the GUI:** **Windows Security → Virus & threat protection → Manage settings**; inspect real-time/cloud protection, exclusions and **Protection history**. Do not remove an exclusion merely because it exists; verify its purpose. Open **Settings → Windows Update → Update history** and each required application's **Help → About** page. On this Server, use the Server Manager, Server Core/sconfig or organizational update tool procedure in **5.3** above.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-MpComputerStatus | Select-Object AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled,AntivirusSignatureLastUpdated
> Get-MpPreference | Select-Object DisableRealtimeMonitoring,ExclusionPath,ExclusionProcess,ExclusionExtension
> Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10
> ```
>
Passive mode may be intentional with another antivirus. `Get-HotFix` is not a complete update inventory; Windows Update remains the main pending-update check.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Update-MpSignature
> ```
>
After evidence collection, a quick scan:

```powershell
Start-MpScan -ScanType QuickScan
```

Use the GUI to install offered OS updates and trusted vendor updates; do not install an unreviewed PowerShell module just to update Windows.

**✅ Check it worked:** Recheck signature time, Protection history and the update page. Open each required application and test the README function. Reboot only at an appropriate checkpoint after installers finish.

> [!WARNING]
> **↩️ Undo:** Restore only a wrongly changed preference using its recorded value. Do not restore quarantined malware to the live image merely to recover points. If an update breaks a required function, investigate the exact update and supported recovery option; do not disable future updates wholesale.

> [!CAUTION]
> **⚠️ Warnings:** Tamper Protection or organizational policy may reject PowerShell edits. Do not weaken those controls to force a setting. Updates can require more than one restart; do not interrupt an in-progress update to follow a rigid one-reboot rule.

##### WS.19.7 SMB share permissions and NTFS permissions

- [ ] **🎯 DO THIS — WS.19.7 SMB share permissions and NTFS permissions**

> [!NOTE]
> **🎯 What:** Validate both the network share ACL and the underlying NTFS ACL.

> [!NOTE]
> **💡 Why it matters:** Effective network access is limited by both layers; denying a broad group can unintentionally block administrators too.

> [!CAUTION]
> **🛑 Before changing anything:** Record share name, path, description and authorized readers/writers. Preserve forensic files and original ACLs. Do not remove system shares or use recursive permission resets on Windows directories.

**⭐ EASIEST WAY — Click through the GUI:** `fsmgmt.msc` → **Shares** → required share **Properties → Share Permissions**. Then open its folder **Properties → Security → Advanced**; inspect inheritance and **Effective Access** for a representative user. Remove only the unintended grant; keep application identities.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-SmbShare -Name Public | Format-List Name,Path,Description
> Get-SmbShareAccess -Name Public
> icacls C:\Shares\Public
> icacls C:\Shares\Public /save C:\CP-Backups\public-acl.txt /t /c
> ```
>
`F` means Full control, `M` Modify, `RX` Read/execute, and `(I)` inherited. Errors during the recursive backup mean some ACLs were not saved; investigate before relying on it.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Grant-SmbShareAccess -Name Public -AccountName StaffReaders -AccessRight Read -Force
> ```
>
Then use the Security GUI to grant the matching folder read access and remove only confirmed excess write access. Grant authorized access before revoking an existing broad entry.

**✅ Check it worked:** Test reading and, where required, writing from a second machine as an ordinary authorized user. Test an unauthorized user separately. Administrator success does not prove ordinary users can connect.

> [!WARNING]
> **↩️ Undo:** Restore the recorded share grants individually. For the saved ACL above use `icacls C:\Shares /restore C:\CP-Backups\public-acl.txt` after confirming the parent path. Do not recreate a deleted share from memory.

> [!CAUTION]
> **⚠️ Warnings:** Share permissions do not protect local file access. Removing Everyone without providing the required replacement can break a legitimate share.

##### WS.19.8 Scheduled tasks, startup, registry and suspicious executables

- [ ] **🎯 DO THIS — WS.19.8 Scheduled tasks, startup, registry and suspicious executables**

> [!NOTE]
> **🎯 What:** Trace each suspicious process back to the mechanism that launches it.

> [!NOTE]
> **💡 Why it matters:** Killing a process without addressing persistence lets it return. Encoded PowerShell, Python and unusual paths are leads, not proof of malware.

> [!CAUTION]
> **🛑 Before changing anything:** Record the task action, trigger, account, executable path, command line, signature and hash. Export the task/registry key. Never launch a suspicious executable to identify it.

**⭐ EASIEST WAY — Click through the GUI:** `taskschd.msc` → **Task Scheduler Library** → task → inspect **Actions**, **Triggers**, **General**, **History**; right-click **Export** to save XML, then **Disable** for reversible containment after evidence collection. **Task Manager → Startup apps → Disable** applies only to that entry. For registry changes, open `regedit`, select the exact key, choose **File → Export → Selected branch**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-CimInstance Win32_Process | Select-Object ProcessId,ParentProcessId,ExecutablePath,CommandLine
> Get-ScheduledTask -TaskName 'BadTask' | Select-Object TaskName,TaskPath,State,Actions,Triggers,Principal
> Export-ScheduledTask -TaskName 'BadTask' | Set-Content C:\CP-Backups\BadTask.xml -Encoding Unicode
> ```
>
Use the actual task path with `-TaskPath` if it is in a subfolder. For an identified file:

```powershell
Get-FileHash -LiteralPath 'C:\Users\Public\suspect.exe' -Algorithm SHA256
Get-AuthenticodeSignature -LiteralPath 'C:\Users\Public\suspect.exe'
```

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Disable-ScheduledTask -TaskName 'BadTask'
> ```
>
For a confirmed malicious registry startup value, export its parent first, then remove only that value:

```powershell
reg.exe export 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run' C:\CP-Backups\run-before.reg
```

```powershell
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Updater'
```

**✅ Check it worked:** Query the task state again (expected `Disabled`), inspect the precise registry value, and check whether the process/listener returns after an authorized restart or login. Verify required updater/backup tasks still work.

> [!WARNING]
> **↩️ Undo:** Re-enable the task with `Enable-ScheduledTask -TaskName 'BadTask'` only if it was misidentified. Restore a deleted task from its XML using Task Scheduler **Import Task**, checking the principal and credentials. A registry import merges values; restore the specific value when possible.

> [!CAUTION]
> **⚠️ Warnings:** Stop at evidence collection if a forensic question remains unresolved. `sc.exe delete`, `Unregister-ScheduledTask` and `Remove-Item` are destructive; use them only after positive identification and recovery planning. Preserve suspicious scripts as text, never execute decoded payloads.

##### WS.19.9 Final troubleshooting decision path

- [ ] **🎯 DO THIS — WS.19.9 Final troubleshooting decision path**

> [!NOTE]
> **🎯 What:** Verify authentication, networking, security state and required functions after changes.

> [!NOTE]
> **💡 Why it matters:** Scoring can lag or fail to update when DNS, time, networking or a required service breaks.

> [!CAUTION]
> **🛑 Before changing anything:** Record the last successful test and last change. Use the VM console if remote access fails.

**⭐ EASIEST WAY — Click through the GUI:** Check the Scoring Report timestamp, Services, Event Viewer **System/Application**, and the application's own error page. Do not change the scoring agent or its files.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> Get-NetIPConfiguration
> Resolve-DnsName example.org
> Get-Date
> Get-Service EventLog,mpssvc,wuauserv | Format-Table Name,Status,StartType
> Get-WinEvent -FilterHashtable @{LogName='System';Level=2;StartTime=(Get-Date).AddHours(-1)} -MaxEvents 20 | Format-List TimeCreated,ProviderName,Message
> ```
>
Replace the DNS target with the README-required internal hostname; internet DNS failure on an offline lab is not automatically a fault. An update service can be stopped while idle, but should not be Disabled.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
**✅ Check it worked:** Test an ordinary user login, admin elevation, required website/share/remote session, and report freshness. Check pending restarts and save final forensics answers.

> [!WARNING]
> **↩️ Undo:** If a proposed repair fails, return that repair to its recorded starting state before trying another theory.

> [!CAUTION]
> **⚠️ Warnings:** An error message is evidence. Record it exactly and investigate its source rather than hiding it with broad `-ErrorAction SilentlyContinue`.

---

#### WS.20. Complete PowerShell basics — included in this Windows Server handbook

##### WS.20.0 PowerShell command and terminal primer

**PowerShell** is Windows' command window. You can do most CyberPatriot fixes by clicking, but PowerShell is much faster for checking things, like listing every user or every service at once.

#### Open it as Administrator (important!)
1. Click **Start** and type `powershell`.
2. Click **Run as administrator** and say **Yes**.
3. The title bar should say **Administrator: Windows PowerShell**. Without that, most fixes fail with "Access denied".

#### How a command looks
```powershell
Get-LocalUser
```
PowerShell commands are **Verb-Noun**: `Get-` reads things, `Set-` changes them, `Remove-` deletes them, `Disable-` turns them off.

```powershell
Disable-LocalUser -Name "Guest"
```
`-Name "Guest"` is a **parameter**: it tells the command what to work on.

#### Keys that save time
| Key | What it does |
|---|---|
| **Tab** | Auto-complete commands, parameters and file names. Press again to cycle. |
| **↑ / ↓** | Earlier commands. |
| **Ctrl + C** | Stop the running command. |
| Right-click | Paste (in the classic console). |
| `cls` | Clear the screen. |

#### Commands you'll actually use
| Command | What it does |
|---|---|
| `Get-LocalUser` | List users (Enabled = True/False) |
| `Get-LocalGroupMember Administrators` | Who is an admin |
| `Remove-LocalUser -Name bob` | Delete a user |
| `Remove-LocalGroupMember -Group Administrators -Member bob` | Take away admin rights |
| `net accounts` | Show the password and lockout policy |
| `Get-Service \| Where-Object Status -eq Running` | Running services |
| `Stop-Service -Name Spooler` | Stop a service |
| `Set-Service -Name Spooler -StartupType Disabled` | Stop it from starting again |
| `Get-NetFirewallProfile` | Is the firewall on? |
| `Get-MpComputerStatus` | Is Defender on? |
| `Get-SmbShare` | Shared folders |
| `Get-ScheduledTask \| Where-Object TaskPath -notlike '\Microsoft\*'` | Scheduled tasks that aren't from Microsoft |
| `Get-NetTCPConnection -State Listen` | Ports that are listening |
| `Get-ChildItem C:\Users -Recurse -Include *.mp3,*.mp4 -Force -ErrorAction SilentlyContinue` | Find media files |
| `Get-FileHash .\file.txt -Algorithm SHA256` | Hash a file (forensics) |
| `Get-Help Get-LocalUser -Examples` | Examples for any command |

#### The `|` (pipe)
`|` sends the output of one command into the next:
```powershell
Get-Service | Where-Object Status -eq Running | Sort-Object DisplayName
```
Read it as: get services → keep the running ones → sort them by name.

#### Useful "run" shortcuts (Win + R)
Press **Windows key + R**, type one of these, press Enter:

| Type | Opens |
|---|---|
| `lusrmgr.msc` | Local Users and Groups |
| `secpol.msc` | Local Security Policy (passwords, audit, user rights, security options) |
| `gpedit.msc` | Group Policy Editor |
| `services.msc` | Services |
| `wf.msc` | Windows Firewall (advanced) |
| `taskschd.msc` | Task Scheduler |
| `eventvwr.msc` | Event Viewer (logs) |
| `compmgmt.msc` | Computer Management (users, shares, disks...) |
| `fsmgmt.msc` | Shared Folders |
| `appwiz.cpl` | Uninstall programs |
| `optionalfeatures` | Turn Windows features on or off |
| `regedit` | Registry Editor (be careful!) |
| `SystemPropertiesRemote` | Remote Desktop / Remote Assistance settings |

#### Safety tips
- PowerShell does what you ask **immediately**. There's no undo for `Remove-` commands.
- Before changing the registry, export the key: in regedit, right-click the key → **Export**.
- If you're not sure what a command does, add `-WhatIf` to see what *would* happen: `Remove-LocalUser -Name bob -WhatIf`

#### Practice objects, paths and reversible changes

- [ ] **🎯 DO THIS — Practice objects, paths and reversible changes**

> [!NOTE]
> **🎯 What:** Learn how to inspect PowerShell output and edit a harmless file before modifying security settings.

> [!NOTE]
> **💡 Why it matters:** PowerShell pipelines pass objects, not just printed text. Formatting is for display; it should normally come last in a pipeline.

> [!CAUTION]
> **🛑 Before changing anything:** Use ordinary Windows PowerShell for this exercise; administrator rights are not needed. Most handbook examples target Windows PowerShell 5.1 on Windows. A module absent from PowerShell 7 is not proof the Windows role is missing.

**⭐ EASIEST WAY — Click through the GUI:** **Start → Windows PowerShell**. Use File Explorer to view your personal profile folder. Run as administrator only for procedures that require it; do not approve an unknown script merely because it requests elevation.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> $PSVersionTable.PSVersion
> Get-Location
> Get-Service | Get-Member
> Get-Service | Select-Object -First 5 Name,Status,StartType
> ```
>
`Get-Member` describes available properties/methods. `Select-Object` keeps properties; `Format-Table` displays them. For CSV export, select properties then `Export-Csv`, without `Format-Table` in between.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ```powershell
> $practiceFolder = Join-Path $env:USERPROFILE 'CP PowerShell Practice'
> New-Item -ItemType Directory -Path $practiceFolder -ErrorAction Stop
> ```
>
If it exists, inspect it and choose a new folder rather than overwriting work.

```powershell
$practiceFile = Join-Path $practiceFolder 'example notes.txt'
'original value' | Set-Content -LiteralPath $practiceFile
Copy-Item -LiteralPath $practiceFile -Destination "$practiceFile.before"
notepad.exe $practiceFile
```

Edit and save the file. `-LiteralPath` treats wildcard characters literally; quote paths containing spaces. A backtick is PowerShell's escape/continuation character; copying a broken continuation can change a command.

**✅ Check it worked:**

```powershell
Get-Content -LiteralPath $practiceFile
Test-Path -LiteralPath "$practiceFile.before"
```

Expected: your changed text and `True`. For cmdlets inspect the full red error and `$Error[0]`; for native programs inspect `$LASTEXITCODE` immediately after that program. ErrorAction SilentlyContinue hides errors and can make incomplete searches look empty.

> [!WARNING]
> **↩️ Undo:**

```powershell
Copy-Item -LiteralPath "$practiceFile.before" -Destination $practiceFile
Get-Content -LiteralPath $practiceFile
```

Expected: `original value`. This file restore does not model account/password recovery; those have different limits.

> [!CAUTION]
> **⚠️ Warnings:** `-WhatIf` exists only on commands that support it, and its preview does not test downstream dependencies. Use `Get-Help COMMAND -Full` to check support. Use `sc.exe` for Service Control; `sc` in Windows PowerShell is an alias for Set-Content. Never use `Invoke-Expression` to inspect a suspicious string.

---

#### WS.21. Advanced Windows Server investigations — included in this handbook

> **Use after:** Server roles and required services are identified in Parts 1–4. These are **manual Windows Server procedures inside this document**, not a script. Read the README, preserve forensic evidence, and retain a working admin/management path first.

This supplement draws topic ideas from public CyberPatriot checklists and verifies key methods with Microsoft documentation. A generic checklist cannot tell you which accounts, shares, or services are authorized on *your* image.

##### WS.21.1 Find the setting that actually applies (GPO versus local policy)

- [ ] **🎯 DO THIS —** Reviewed effective configuration and policy source.

> [!NOTE]
> **💡 Why:** A value changed in \`secpol.msc\` or the registry can be replaced by a domain Group Policy. On a Domain Controller, editing an arbitrary local policy is not a substitute for checking domain-level policy.

**⭐ EASIEST WAY — Click through the GUI:** Press **Win + R** → \`rsop.msc\` (if available); review **Computer Configuration**. On domain-joined systems use **Group Policy Management** (\`gpmc.msc\`) **only if installed and authorized**. Do not disable a linked GPO merely to fix one setting.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> (Get-CimInstance Win32_ComputerSystem) | Select-Object Name,PartOfDomain,Domain,DomainRole
> gpresult /r /scope computer
> ~~~
>
On a system with applicable policies, save an **HTML report locally**, then open it:

~~~powershell
gpresult /h "$env:TEMP\cp-rsop.html" /f
Start-Process "$env:TEMP\cp-rsop.html"
~~~

> [!NOTE]
> **🧠 Interpretation:** \`PartOfDomain = True\` means domain policies may apply. The report's **Applied Group Policy Objects** and **Denied GPOs** help explain conflicts; a local-only or unconfigured policy may show less information. \`gpresult\` can report no RSoP data for the target scope—investigate context rather than assume a missing policy is a security failure.

**✅ Verification:** Compare the effective policy with the README and with the relevant **Local Security Policy** or **Group Policy** editor. If a setting changes after refresh, identify its **winning policy** before editing it.

**Recovery:** Revert the *specific* policy change at its actual policy source. Keep an export/screenshot of the original setting. Changing a domain GPO can affect many machines.

##### WS.21.2 Correlate suspicious services with their executable files

- [ ] **🎯 DO THIS —** Compared service names, binary paths, and required roles.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → services.msc** → double-click a service → note **Service name**, **Path to executable**, **Log On**, **Dependencies**. Do not stop it yet.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-CimInstance Win32_Service |
>   Select-Object Name,DisplayName,State,StartMode,StartName,PathName |
>   Sort-Object Name | Format-Table -Wrap
> ~~~
>
To examine **one** service without guessing its executable:

~~~powershell
Get-CimInstance Win32_Service -Filter "Name='RemoteRegistry'" |
  Format-List Name,DisplayName,PathName,StartName,State,StartMode
~~~

> [!NOTE]
> **What to look for:** Unexpected user-profile or temporary-directory paths, impersonated names, newly introduced binaries, unusual service accounts, or services inconsistent with the README. Some legitimate software uses nonstandard locations; **a strange path is a clue, not proof**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-Item -LiteralPath 'C:\Path\To\Suspect.exe' |
>   Select-Object FullName,Length,CreationTime,LastWriteTime
> Get-FileHash -LiteralPath 'C:\Path\To\Suspect.exe' -Algorithm SHA256
> Get-AuthenticodeSignature -LiteralPath 'C:\Path\To\Suspect.exe' |
>   Format-List Status,SignerCertificate
> ~~~
>
**✅ Verification:** Compare publisher, path, hash, and service need against trusted vendor information and the README. A missing signature does not automatically prove malware.

**Recovery:** If a change is authorized, document the original \`StartMode\`, stop/disabling only that confirmed unwanted service using the existing checklist, and recheck required applications and the score. Never delete the executable before recording relevant forensic answers.

##### WS.21.3 Investigate events: service installation, login attempts and process creation

- [ ] **🎯 DO THIS —** Checked available logs without clearing them.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → eventvwr.msc** → **Windows Logs → System** or **Security** → **Filter Current Log**. Record timestamps with timezone, event IDs, provider, and the full message.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-WinEvent -FilterHashtable @{
>   LogName='System'; Id=7045; StartTime=(Get-Date).AddDays(-7)
> } -MaxEvents 30 | Select-Object TimeCreated,Id,ProviderName,Message |
>   Format-List
> ~~~
>
Event **7045** in the System log can record a service installation. Security event **4697** also describes service installation **when the relevant auditing is enabled**.

~~~powershell
Get-WinEvent -FilterHashtable @{
  LogName='Security'; Id=4624,4625,4720,4732,4688,4697
  StartTime=(Get-Date).AddDays(-3)
} -MaxEvents 80 | Select-Object TimeCreated,Id,Message |
  Format-List
~~~

| Event | Meaning and limitation |
|---|---|
| 4624 / 4625 | Successful / failed logon; interpret logon type and account |
| 4720 | A user account was created, when auditing is present |
| 4732 | A member was added to a security-enabled local group |
| 4688 | New process created **only if process-creation auditing was active** |
| 4697 | Service installation recorded in Security if configured |
| 7045 | Service installed, shown in System |

> [!NOTE]
> **🧠 Interpretation:** Errors such as **No events were found** do not prove an action never happened. Logging, retention, permissions, and audit policy affect visibility. To check the present policy:

~~~powershell
auditpol /get /category:*
~~~

**✅ Verification:** Tie a suspicious event to an account, timestamp, executable and known system change. Avoid relying on one isolated log entry.

**Recovery:** If auditing was intentionally changed, restore only its original documented configuration; **never clear logs** to “clean” the machine.

##### WS.21.4 Inspect persistence without executing unknown files

- [ ] **🎯 DO THIS —** Reviewed login-start items and task actions.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → taskschd.msc** → **Task Scheduler Library**; inspect **Triggers**, **Actions**, **Author** and **History**. Open **Task Manager → Startup apps** for login items.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-CimInstance Win32_StartupCommand |
>   Select-Object Name,Command,Location,User | Format-List
> ~~~
>
~~~powershell
Get-ScheduledTask |
  Select-Object TaskPath,TaskName,State,
    @{Name='Actions';Expression={($_.Actions | ForEach-Object {
      "$($_.Execute) $($_.Arguments)"
    }) -join '; '}} | Format-List
~~~

~~~powershell
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
~~~

> [!NOTE]
> **🧠 Interpretation:** A task with an obscure name or PowerShell arguments warrants inspection, but scheduled updates and enterprise management agents are legitimate too. Record the exact executable and arguments before taking action.

**✅ Verification:** Correlate task path, binary signature and Event Viewer findings. Do not run the task to see what happens.

**Recovery:** For a confirmed unauthorized task, prefer **Disable** before **Delete** (after preserving evidence). Record the original trigger and action; test whether required applications still work.

##### WS.21.5 SMB share + NTFS access: check both layers

- [ ] **🎯 DO THIS —** Checked authorized shares and effective paths.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → fsmgmt.msc** (when available) → **Shares**. Review share name, local path and active sessions. In File Explorer: folder → **Properties → Sharing / Security**.

> [!NOTE]
> **🔁 Alternate (optional) — PowerShell:**
>
>
> ~~~powershell
> Get-SmbShare | Select-Object Name,Path,Description,Special
> ~~~
>
For one **known** required share, substitute its actual name and path:

~~~powershell
Get-SmbShareAccess -Name 'ExampleShare'
Get-Acl -LiteralPath 'C:\ExampleFolder' | Format-List Path,Owner,Access
~~~

> [!NOTE]
> **🧠 Interpretation:** Share permissions and NTFS permissions both matter. Hidden administrative shares (for example \`C$\`) are not by themselves proof of malware. A broad \`Everyone\` share right may be constrained by NTFS, but it still needs review.

**✅ Verification:** Test with a **legitimate non-admin** account that should read or write, and a separate account that should be denied. Protect required shared folders and server roles.

**Recovery:** Save both ACL layers before changing. Reverse only the particular group entry or share configuration changed; never recursively reset \`C:\Windows\` permissions.

##### WS.21.6 Firewall rules that look open—but aren't applicable

- [ ] **🎯 DO THIS —** Checked effective profiles, rules, ports, and service ownership.

~~~powershell
Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction,DefaultOutboundAction
Get-NetTCPConnection -State Listen |
  Select-Object LocalAddress,LocalPort,OwningProcess |
  Sort-Object LocalPort
~~~

Identify the process for a suspicious PID shown by the preceding command:

~~~powershell
Get-Process -Id 1234
~~~

Replace \`1234\` with the observed PID; if it already exited, the command fails.

~~~powershell
Get-NetFirewallRule -PolicyStore ActiveStore -Enabled True -Direction Inbound |
  Select-Object DisplayName,Action,Profile |
  Format-Table -AutoSize
~~~

> [!NOTE]
> **🧠 Interpretation:** An allowed rule is not necessarily reachable: scope, profile, address filters, enabled state, underlying service and other policy conditions matter. A listening port may serve an explicitly required role.

**✅ Verification:** From an authorized client, test required application connectivity after any **narrow** firewall change. Avoid blanket removal of inbound rules.

##### WS.21.7 Final verification checklist

- [ ] **🎯 DO THIS —** Read and preserved forensic questions.
- [ ] **🎯 DO THIS —** Confirmed whether the machine is standalone, domain-joined or a Domain Controller.
- [ ] **🎯 DO THIS —** Found the **effective** source for changed policies.
- [ ] **🎯 DO THIS —** Correlated unknown services with executable paths and relevant logs.
- [ ] **🎯 DO THIS —** Reviewed scheduled tasks/startup entries without executing unknown payloads.
- [ ] **🎯 DO THIS —** Confirmed required shares, services and firewall connectivity remain operational.
- [ ] **🎯 DO THIS —** Recorded any modification, verification result and rollback information.

##### WS.21.8 Sources and further reading

- [Microsoft: gpresult and Resultant Set of Policy](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/gpresult)
- [Microsoft: Advanced Audit Policy Configuration](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/advanced-audit-policy-configuration)
- [Microsoft: Event 4688 (process creation)](https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4688)
- [Microsoft: Event 4697 (service installation)](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4697)
- Topic cross-checks: [chessischess CyberPatriot checklists](https://github.com/chessischess/cyberpatriot-checklist), [Minagera Windows checklist](https://github.com/Minagera/CyberPatriot/blob/main/CyberPatriot/Checklists/Windows/README.md).

---

<a id="stage-6"></a>
## Part 6 — Final Verification

> [!TIP]
> ✅ **Finish strong:** Verify the final configuration, required functionality, and saved evidence.

Retest authorized domain/local login, critical role transactions, management access and scoring status.

### 11. Final checks

- [ ] **🎯 DO THIS —** Every critical role still works (e.g. `nslookup corp.local` with your domain name for DNS, open the website for IIS)
- [ ] **🎯 DO THIS —** On a DC: `dcdiag /q` prints no errors (no output = good)
- [ ] **🎯 DO THIS —** Scoring Report shows **no penalties**
- [ ] **🎯 DO THIS —** Forensics answers saved
- [ ] **🎯 DO THIS —** Final snapshot
