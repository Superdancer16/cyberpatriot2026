# 🪟 Windows 10 / 11 — complete standalone CyberPatriot checklist

> [!TIP]
> **🧭 Jump to a stage:** [📘 Basics](#stage-1) · [🚀 First steps](#stage-2) · [🛡️ Priority checks](#stage-3) · [⚙️ Services](#stage-4) · [🧰 Advanced](#stage-5) · [✅ Final checks](#stage-6)
> **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution** — commands are for manual, scenario-aware use.

> [!CAUTION]
> **Read the image README before changing accounts, services, authentication, or network access.** Preserve forensic evidence and a recovery path; do not apply every example automatically.


**Version note (November 2026):** Windows 10 mainstream support ended October 14, 2025; use only the specific security-update/ESU support arrangements available to your image, and never substitute an OS upgrade for an authorized CyberPatriot task. Windows 11 editions, policy behavior, features and installed roles can differ; check `winver` and the actual README.

**How to use this page**
- Work through the phase order below.
- Each item has: **What** · **Why it matters** · **Clicking** · **Typing** (PowerShell **as Administrator**) · **Check it worked** · ⚠️ warnings.
- New to PowerShell? Read [PowerShell basics in Section 20](windows-10-11.md#20-complete-powershell-basics--included-in-this-windows-checklist) first.
- This repository contains documentation only. Follow the manual procedures below; do not skip verification.
- `alice`, `bob` etc. are examples. **Use the names in your README.**
- `secpol.msc`, `gpedit.msc` and `lusrmgr.msc` only exist on **Pro, Education and Enterprise** (competition images are one of these). To check, run `winver`. On **Home**, use the **Typing** commands instead.

---

**Priority is practical, not a guaranteed score ranking.** The README, forensics questions, permitted tools and actual required services override any generic checklist. Do not remove the only admin, delete evidence, or disable a critical role merely because it appears in a public checklist.


> [!NOTE]

---

<a id="stage-1"></a>
> [!IMPORTANT]
> **🎯 HOW TO USE:** Each **DO THIS** checkbox is the action to complete **only when applicable to the image README**. When present, **⭐ EASIEST WAY — GUI** is the recommended path. **🔁 ALTERNATE** commands are optional ways to do the same task; blue **NOTE** boxes hold explanations and extra context, while **CAUTION/WARNING** boxes explain safety/undo. **Never run both methods just to gain points.**

> [!TIP]

## Part 1 — Basics / Information Needed

> [!TIP]
> 📘 **Foundation:** Review the key terms and available tools before making changes.


### Windows terms and tools to understand first

- [ ] **🎯 DO THIS —** Identify the version/edition, local versus domain accounts, Administrators group, services and network profile.
- [ ] **🎯 DO THIS —** Know **Win+R → powershell**, **services.msc**, **lusrmgr.msc**, **secpol.msc**, **eventvwr.msc**, **taskschd.msc**, and **wf.msc**. Some tools are unavailable on Home editions.
- [ ] **🎯 DO THIS —** Understand read-only Get commands versus modifying Set, Remove and Disable commands.
- [ ] **🎯 DO THIS —** Keep authorized administrator access and a record of every original setting.

**⭐ EASIEST WAY — PowerShell/command line (run only applicable commands):**

~~~powershell
Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber
Get-CimInstance Win32_ComputerSystem | Select-Object PartOfDomain,Domain,DomainRole
whoami /groups
~~~

If the machine is a Domain Controller, use the Windows Server guide. Enterprise or domain policies may override a local registry edit. Full PowerShell basics are preserved later as a reference.

**Quick learning order:** README and forensics → users/admin privileges → Defender, firewall, updates and account policy → necessary services/software → advanced settings → final verification.

---

<a id="stage-2"></a>
## Part 2 — First Things to Do

> [!IMPORTANT]
> 🚀 **Start here:** Follow the image README, preserve forensics, and confirm administrative recovery.


Read the image README, preserve answers to forensic questions, confirm the initial score and retain authorized administrator access.

### 0. Before you touch anything

#### 0.1 Read the README
- [ ] **🎯 DO THIS — 0.1 Read the README**

Write down the admins, users, critical services, required software and prohibited items. See [Reading the README](../General/All/reading-the-readme.md).

#### 0.2 Take a VMware snapshot
- [ ] **🎯 DO THIS — 0.2 Take a VMware snapshot**

**VM → Snapshot → Take Snapshot…**

#### 0.3 Open PowerShell as Administrator
- [ ] **🎯 DO THIS — 0.3 Open PowerShell as Administrator**

**Start** → type `powershell` → **Run as administrator**. The title must say **Administrator**.

#### 0.4 Open the Scoring Report
- [ ] **🎯 DO THIS — 0.4 Open the Scoring Report**

Double-click it on the desktop and refresh it as you work.

---


### 1. Forensics questions (FIRST)

#### ✅ Investigate listening ports for a forensic question

- [ ] **Task:** Investigate listening ports for a forensic question.

**⭐ Recommended — Command Prompt:** Open **Start → Command Prompt → Run as administrator**, run `netstat -abno`, then match the question’s local port, process name and PID. Record the requested value without changing any process.


**✅ VERIFY:** Confirm the output corresponds to the actual asked-for process and local port.

> [!CAUTION]
> **⚠️ Caution:** Never use a sample PID or reported port as an answer for another image.

#### ✅ Inspect Windows network shares for forensics

- [ ] **Task:** Inspect Windows network shares for forensics.

**⭐ Recommended — GUI:** Press **Win + R → `fsmgmt.msc` → Shares**. Locate the requested share name, path and type.


**✅ VERIFY:** Record exactly what the forensic question asks for and save the question file.

> [!CAUTION]
> **⚠️ Caution:** Administrative/special shares may be legitimate; do not delete a share merely because it is hidden.

#### ✅ Recognize and decode layered text encodings

- [ ] **Task:** Recognize and decode layered text encodings.

**⭐ Recommended — Offline tool / approved decoder:** Read the question for clues such as ROT13, Base64 and reversing character order. Decode **one layer at a time** using an approved offline tool or permitted decoder.


**✅ VERIFY:** Check the final text makes sense and matches the required answer format.

> [!CAUTION]
> **⚠️ Caution:** Never upload private evidence to an unapproved website and never execute decoded text.


#### 1.1 Answer every forensics question before fixing things
- [ ] **🎯 DO THIS — 1.1 Answer every forensics question before fixing things**

Open each `Forensics Question N.txt` on the desktop, put your answer after `ANSWER:`, and save.

**Useful tools:**
```powershell
Get-FileHash C:\Users\bob\Documents\file.txt -Algorithm SHA256     # hash a file
Get-ChildItem C:\Users -Recurse -Force -Filter *secret* -ErrorAction SilentlyContinue   # find files by name
Get-ChildItem C:\Users -Recurse -File -Force -Include *.txt,*.csv,*.log,*.ps1,*.bat -ErrorAction SilentlyContinue | Select-String -Pattern "password"   # find text inside files
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aGVsbG8='))   # decode base64
```
More: [Forensics questions guide](../General/All/forensics-questions.md).

#### 1.2 Manual security baseline (no hardening script)
- [ ] **🎯 DO THIS — 1.2 Manual security baseline (no hardening script)**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Prepare a manual baseline. The upstream automation is not included in this repository.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** A status label cannot establish that a setting is correct on this particular image.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Read the README and preserve forensics evidence. Record your current administrator account, required users, services, ports, and initial score.

**⭐ EASIEST WAY — Click through the GUI:** Open the README and Scoring Report from the desktop. In your VM manager, create a practice snapshot only if the round rules permit it. Open the platform's account and service management screens described below.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
**✅ Check it worked:** Repeat each inspection, test the README-required function, then refresh the Scoring Report. A lack of new points does not prove the change failed.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Reverse the most recent change using the recorded value or the procedure's backup. A VM snapshot rollback can discard later fixes; use it only within the rules and verify the resulting score again.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Never use a guessed list of authorized users or bulk-delete files. See [Using the scripts safely](../Misc%20Softwares/using-the-scripts.md) for the limits of external tools.

---


<a id="stage-3"></a>
## Part 3 — Commonly Assessed High-Priority Checks

> [!IMPORTANT]
> 🛡️ **Priority checks:** Inspect the most common security categories first; actual scoring remains image-specific.


Accounts, password rules, Defender, firewall, updates and audit settings are frequent *topics* in public checklists; actual per-fix points are unknown.

### 2. Users and groups

#### ✅ Review and contain a confirmed unauthorized local user

- [ ] **Task:** Review and contain a confirmed unauthorized local user.

**⭐ Recommended — GUI:** Open **Win + R → `lusrmgr.msc` → Users**, compare the account with the README, and **disable** the confirmed unauthorized account before considering deletion.


**✅ VERIFY:** Confirm the account is disabled and your authorized admin still works.

> [!CAUTION]
> **⚠️ Caution:** Deleting a user can destroy its SID and permissions; if an explicit task requires deletion, preserve evidence and a supported recovery path first.

#### ✅ Set an authorized user's required password

- [ ] **Task:** Set an authorized user's required password.

**⭐ Recommended — GUI:** Open **Computer Management → Local Users and Groups → Users**, right-click the correct authorized account → **Set Password**, then choose a secure password following the image requirements.


**✅ VERIFY:** Check password sign-in using a separate authorized session.

> [!CAUTION]
> **⚠️ Caution:** Do not publish passwords or reset an unknown service account, and never lock out the only administrator.

#### ✅ Remove a user who should not be an administrator

- [ ] **Task:** Remove a user who should not be an administrator.

**⭐ Recommended — GUI:** Open **Settings → Accounts → Other users → choose account → Change account type → Standard User**, or **`lusrmgr.msc` → Groups → Administrators → Remove** only the unauthorized member.


**✅ VERIFY:** Verify the user remains enabled when required but no longer has local admin privileges.

> [!CAUTION]
> **⚠️ Caution:** Do not remove your own admin access or an authorized domain administration group.

#### ✅ Create a required custom local security group

- [ ] **Task:** Create a required custom local security group.

**⭐ Recommended — GUI:** Open **Computer Management → Local Users and Groups → Groups → Action → New Group** and enter the **exact README-specified group name**.


**✅ VERIFY:** Verify the group appears in `lusrmgr.msc` under Groups.

> [!CAUTION]
> **⚠️ Caution:** A group name from one example is not a universal requirement.

#### ✅ Add only specified members to a required local group

- [ ] **Task:** Add only specified members to a required local group.

**⭐ Recommended — GUI:** Open **`lusrmgr.msc` → Groups → required group → Add → enter exact README-authorized users → Check Names → OK**.


**✅ VERIFY:** Reopen the group and compare every listed member with the README.

> [!CAUTION]
> **⚠️ Caution:** Do not add all ordinary users or grant Administrators membership to a normal group.


#### 2.1 List every user
- [ ] **🎯 DO THIS — 2.1 List every user**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `lusrmgr.msc` → **Users**. (Or **Settings → Accounts → Other users**.)

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-LocalUser | Format-Table Name, Enabled, PasswordRequired, PasswordExpires, LastLogon
> ```

#### 2.2 Delete users who are not in the README
- [ ] **🎯 DO THIS (only if authorized) — 2.2 Delete users who are not in the README**

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Extra accounts are how attackers get back in.

**⭐ EASIEST WAY — Click through the GUI:** In `lusrmgr.msc` → **Users**, right-click the user → **Delete**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Remove-LocalUser -Name mallory
> ```

> [!CAUTION]
> Don't delete the built-in accounts (**Administrator, Guest, DefaultAccount, WDAGUtilityAccount**): *disable* them instead (2.6). Never delete yourself or anyone on the README.

#### 2.3 Create users the README says should exist
- [ ] **🎯 DO THIS — 2.3 Create users the README says should exist**

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → **Users** → **Action → New User…** → untick "User must change password" only if the README says so.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> New-LocalUser -Name erin -Password (Read-Host -AsSecureString "Password for erin")
> Add-LocalGroupMember -Group Users -Member erin
> ```

#### 2.4 Fix the Administrators group
- [ ] **🎯 DO THIS — 2.4 Fix the Administrators group**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Only the README's admins should be in **Administrators**.

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → **Groups** → double-click **Administrators** → remove the wrong people / **Add…** the right ones.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-LocalGroupMember Administrators
> Remove-LocalGroupMember -Group Administrators -Member bob
> Add-LocalGroupMember -Group Administrators -Member alice
> net localgroup Administrators      # use this if Get-LocalGroupMember shows an error
> ```

> [!CAUTION]
> Never remove **yourself** (the account you are logged in as) from Administrators. You would lose your admin rights.

#### 2.5 Check the other powerful groups
- [ ] **🎯 DO THIS — 2.5 Check the other powerful groups**

Open these groups in `lusrmgr.msc` and remove anyone the README doesn't say should be there:
**Backup Operators** (can read every file), **Power Users**, **Remote Desktop Users** (keep only if RDP is needed), **Remote Management Users**, **Hyper-V Administrators**, **Event Log Readers**, **Network Configuration Operators**.

```powershell
foreach ($g in 'Backup Operators','Power Users','Remote Desktop Users','Remote Management Users','Hyper-V Administrators','Event Log Readers','Network Configuration Operators') {
  "--- $g"; Get-LocalGroupMember $g -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name }
```

#### 2.6 Disable the Guest account (and the other built-ins)
- [ ] **🎯 DO THIS (only if authorized) — 2.6 Disable the Guest account (and the other built-ins)**

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → **Users** → right-click **Guest** → **Properties** → tick **Account is disabled**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Disable-LocalUser -Name Guest
> Get-LocalUser | Where-Object { $_.SID -match '-50[0134]$' } | Format-Table Name, Enabled, SID   # finds them even if renamed
> ```
> The built-in **Administrator** should usually be disabled too, **unless you're logged in as it** or the README says to keep it.

#### 2.7 Fix weak password settings on accounts
- [ ] **🎯 DO THIS — 2.7 Fix weak password settings on accounts**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** No account should have **Password never expires**, **User cannot change password**, or *no password required*.

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → double-click each user → untick **Password never expires** and **User cannot change password**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-LocalUser | Where-Object { $_.Enabled } | Format-Table Name, PasswordExpires, UserMayChangePassword, PasswordRequired
> Set-LocalUser -Name bob -PasswordNeverExpires $false
> Set-LocalUser -Name bob -UserMayChangePassword $true
> net user bob /passwordreq:yes
> ```

#### 2.8 Give users strong passwords
- [ ] **🎯 DO THIS — 2.8 Give users strong passwords**

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → right-click the user → **Set Password…**

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Set-LocalUser -Name bob -Password (Read-Host -AsSecureString "New password for bob")
> ```
> Use 12+ characters with upper case, lower case, a number and a symbol. **Don't change your own password** unless the README says so.

---


### 3. Account policies (passwords and lockout)

#### ✅ Inspect and set password history

- [ ] **Task:** Inspect and set password history.

**⭐ Recommended — GUI:** Press **Win + R → `secpol.msc` → Account Policies → Password Policy → Enforce password history**. Apply the **image-required** count.


**✅ VERIFY:** Reopen the policy and confirm it matches the scenario; record initial and final values.

> [!CAUTION]
> **⚠️ Caution:** The example uses a specific number; it is not a universal score threshold.

#### ✅ Require password complexity when assigned

- [ ] **Task:** Require password complexity when assigned.

**⭐ Recommended — GUI:** Press **Win + R → `secpol.msc` → Account Policies → Password Policy → Password must meet complexity requirements → Enabled** if required.


**✅ VERIFY:** Verify the effective policy, not merely a local setting overridden by domain Group Policy.

> [!CAUTION]
> **⚠️ Caution:** Do not force a domain-wide security policy change to fix one local account.

#### ✅ Set the assigned account lockout threshold

- [ ] **Task:** Set the assigned account lockout threshold.

**⭐ Recommended — GUI:** Press **Win + R → `secpol.msc` → Account Policies → Account Lockout Policy → Account lockout threshold** and set the exact image value; review duration and counter-reset options.


**✅ VERIFY:** Verify the configured threshold and related lockout duration and observation window.

> [!CAUTION]
> **⚠️ Caution:** A threshold from a example is not automatically correct for a live competition image; do not intentionally lock your last admin.


**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `secpol.msc` → **Account Policies**.

#### 3.1 Password Policy
- [ ] **🎯 DO THIS — 3.1 Password Policy**

| Setting | Set to |
|---|---|
| Enforce password history | **24** passwords remembered |
| Maximum password age | **90** days (or what the README says) |
| Minimum password age | **1** day |
| Minimum password length | **12** characters |
| Password must meet complexity requirements | **Enabled** |
| Store passwords using reversible encryption | **Disabled** |

**⭐ EASIEST WAY — PowerShell/command line (run only applicable commands):**
```powershell
net accounts /uniquepw:24 /maxpwage:90 /minpwage:1 /minpwlen:12
```

**⭐ EASIEST WAY — PowerShell/command line (run only applicable commands):**
```powershell
secedit /export /cfg $env:TEMP\secpol.inf /areas SECURITYPOLICY
(Get-Content $env:TEMP\secpol.inf) -replace 'PasswordComplexity = 0', 'PasswordComplexity = 1' -replace 'ClearTextPassword = 1', 'ClearTextPassword = 0' | Set-Content $env:TEMP\secpol.inf -Encoding Unicode
secedit /configure /db $env:TEMP\secpol.sdb /cfg $env:TEMP\secpol.inf /areas SECURITYPOLICY
secedit /export /cfg $env:TEMP\check.inf /areas SECURITYPOLICY; Select-String 'PasswordComplexity|ClearTextPassword' $env:TEMP\check.inf
```

**✅ Check it worked:** `net accounts` shows the numbers, and the last line above shows `PasswordComplexity = 1` and `ClearTextPassword = 0`.

#### 3.2 Account Lockout Policy
- [ ] **🎯 DO THIS — 3.2 Account Lockout Policy**

| Setting | Set to |
|---|---|
| Account lockout threshold | **5** invalid attempts (set this first) |
| Account lockout duration | **30** minutes |
| Reset account lockout counter after | **30** minutes |
| Allow Administrator account lockout (only on updated systems; skip it if it isn't in the list) | **Enabled** |

```powershell
net accounts /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30
net accounts                     # check everything
```

> [!CAUTION]
> Never set **Account lockout duration** to **0**: that means a locked account stays locked until an admin unlocks it. Don't set the threshold below 3 either: a few typos would lock real users out.

---


### 5. Microsoft Defender antivirus

#### 5.1 Turn every protection on
- [ ] **🎯 DO THIS — 5.1 Turn every protection on**

**⭐ EASIEST WAY — Click through the GUI:** **Start → Windows Security → Virus & threat protection → Manage settings**. Turn **on**: Real-time protection, Cloud-delivered protection, Automatic sample submission, **Tamper Protection**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-MpComputerStatus | Format-List AntivirusEnabled, RealTimeProtectionEnabled, IsTamperProtected, AntivirusSignatureAge
> Set-MpPreference -DisableRealtimeMonitoring $false -PUAProtection Enabled -MAPSReporting Advanced -SubmitSamplesConsent SendSafeSamples
> ```
**✅ Check it worked:** `RealTimeProtectionEnabled` and `IsTamperProtected` say `True`.

#### 5.2 Remove planted exclusions
- [ ] **🎯 DO THIS (only if authorized) — 5.2 Remove planted exclusions**

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why:** Attackers tell Defender to ignore their folder.

**⭐ EASIEST WAY — Click through the GUI:** **Manage settings → Exclusions → Add or remove exclusions**. Remove anything you didn't add.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-MpPreference | Format-List ExclusionPath, ExclusionExtension, ExclusionProcess
> Remove-MpPreference -ExclusionPath "C:\Users\Public\tools"
> ```

#### 5.3 No policy that turns Defender off
- [ ] **🎯 DO THIS — 5.3 No policy that turns Defender off**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → Microsoft Defender Antivirus** → **Turn off Microsoft Defender Antivirus** must be **Not configured** (or Disabled). Check **Real-time Protection** in the same place.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -ErrorAction SilentlyContinue                          # DisableAntiSpyware : 1 is bad
> Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -ErrorAction SilentlyContinue     # any Disable value of 1 is bad
> ```

#### 5.4 Update and scan
- [ ] **🎯 DO THIS — 5.4 Update and scan**

```powershell
Update-MpSignature
Start-MpScan -ScanType QuickScan
Get-MpThreatDetection           # anything found
```

---


### 6. Firewall

#### ✅ Enable required firewall profiles

- [ ] **Task:** Enable required firewall profiles.

**⭐ Recommended — GUI:** Open **Windows Security → Firewall & network protection** and check **Domain**, **Private** and **Public** profiles, switching on those required by the image.


**✅ VERIFY:** Verify all applicable profiles and ensure necessary service connections still work.

> [!CAUTION]
> **⚠️ Caution:** Keep task-required rules for file sharing, remote administration or web applications.


#### 6.1 Firewall on for every network type
- [ ] **🎯 DO THIS — 6.1 Firewall on for every network type**

**⭐ EASIEST WAY — Click through the GUI:** **Windows Security → Firewall & network protection**. **Domain**, **Private** and **Public** must all say *Firewall is on*.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Allow
> Get-NetFirewallProfile | Format-Table Name, Enabled, DefaultInboundAction, DefaultOutboundAction
> ```
>
**✅ Check it worked:** every profile shows `Enabled True`, `DefaultInboundAction Block`, and `DefaultOutboundAction` **Allow** or **NotConfigured**. **Block** there stops updates and can stop the Scoring Report updating; set it back with the first command unless the README asks for it.

#### 6.2 Check the inbound rules
- [ ] **🎯 DO THIS — 6.2 Check the inbound rules**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `wf.msc` → **Inbound Rules**. Sort by **Enabled**. Look for **allow** rules for strange programs (in `C:\Users\`, `C:\Temp`), strange ports (4444, 1337), or rules called something like "Windows Update Helper" that point at an odd program.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True | Where-Object { -not $_.DisplayGroup } |
>   ForEach-Object { "{0} -> {1}" -f $_.DisplayName, ($_ | Get-NetFirewallApplicationFilter).Program }
> Disable-NetFirewallRule -DisplayName "Evil Rule"
> ```

---


### 7. Windows Update

#### ✅ Configure approved automatic Windows updates

- [ ] **Task:** Configure approved automatic Windows updates.

**⭐ Recommended — GUI:** Press **Win + R → `gpedit.msc` → Computer Configuration → Administrative Templates → Windows Components → Windows Update → Manage end user experience → Configure Automatic Updates**. Use the image-required setting.


**✅ VERIFY:** Verify the effective update policy and check that update scanning is functional.

> [!CAUTION]
> **⚠️ Caution:** A domain/WSUS policy may take precedence; don't override an approved organization update source.


#### 7.1 Install all updates
- [ ] **🎯 DO THIS — 7.1 Install all updates**

**⭐ EASIEST WAY — Click through the GUI:** **Settings → Windows Update → Check for updates** → install everything. If updates are **paused**, click **Resume updates**.

#### 7.2 Automatic updates on
- [ ] **🎯 DO THIS — 7.2 Automatic updates on**

**⭐ EASIEST WAY — Click through the GUI:** `gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → Windows Update** (on Windows 11 it is inside **Manage end user experience**; look there if you don't see it) → **Configure Automatic Updates** → **Enabled**, option **4 – Auto download and schedule the install**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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

#### 7.3 Update the other programs
- [ ] **🎯 DO THIS — 7.3 Update the other programs**

Firefox (**≡ → Help → About Firefox**), Chrome (**⋮ → Help → About Google Chrome**), and anything the README lists (e.g. Notepad++, 7-Zip, VLC). Old versions are a scored problem.

---


### 4. Local policies

#### ✅ Enable the required Credential Validation audit

- [ ] **Task:** Enable the required Credential Validation audit.

**⭐ Recommended — GUI:** Press **Win + R → `secpol.msc` → Advanced Audit Policy Configuration → System Audit Policies → Account Logon → Audit Credential Validation** and enable the required Success/Failure options.


**✅ VERIFY:** Verify the requested audit category is enabled and relevant Security events are available.

> [!CAUTION]
> **⚠️ Caution:** Use the exact requested Success/Failure selection; logging does not automatically repair an authentication vulnerability.

#### ✅ Remove unauthorized Manage auditing and security log privilege

- [ ] **Task:** Remove unauthorized Manage auditing and security log privilege.

**⭐ Recommended — GUI:** Press **Win + R → `secpol.msc` → Local Policies → User Rights Assignment → Manage auditing and security log**. Remove only a confirmed unauthorized member.


**✅ VERIFY:** Reopen the right and confirm only authorized accounts/groups retain it.

> [!CAUTION]
> **⚠️ Caution:** Do not remove required Administrators or security-management principals.

#### ✅ Remove unauthorized Take ownership privilege

- [ ] **Task:** Remove unauthorized Take ownership privilege.

**⭐ Recommended — GUI:** Press **Win + R → `secpol.msc` → Local Policies → User Rights Assignment → Take ownership of files or other objects** and remove only unauthorized identities.


**✅ VERIFY:** Verify the selected right now matches approved membership.

> [!CAUTION]
> **⚠️ Caution:** This right is powerful, but legitimate administrators may require it; preserve recovery.

#### ✅ Limit network use of blank local passwords

- [ ] **Task:** Limit network use of blank local passwords.

**⭐ Recommended — GUI:** Press **Win + R → `secpol.msc` → Local Policies → Security Options → Accounts: Limit local account use of blank passwords to console logon only** and enable as required.


**✅ VERIFY:** Reopen the option and check the effective setting.

> [!CAUTION]
> **⚠️ Caution:** This restriction is not a substitute for assigning proper passwords to approved accounts.

#### ✅ Hide the last signed-in user on the logon screen

- [ ] **Task:** Hide the last signed-in user on the logon screen.

**⭐ Recommended — GUI:** Press **Win + R → `secpol.msc` → Local Policies → Security Options → Interactive logon: Don't display last signed-in** and enable if required.


**✅ VERIFY:** Confirm the effective policy and that authorized users can still sign in.

> [!CAUTION]
> **⚠️ Caution:** Settings/wording vary by edition and GPO; do not mistake local UI with resultant policy.

#### ✅ Disable administrator-account enumeration at elevation

- [ ] **Task:** Disable administrator-account enumeration at elevation.

**⭐ Recommended — GUI:** Press **Win + R → `gpedit.msc` → Computer Configuration → Administrative Templates → Windows Components → Credential User Interface → Enumerate administrator accounts on elevation** and set the approved value.


**✅ VERIFY:** Inspect the final effective policy and confirm authorized elevation still works.

> [!CAUTION]
> **⚠️ Caution:** This is a separate policy from UAC itself; only change the exact assigned setting.


#### 4.1 Audit Policy (record security events)
- [ ] **🎯 DO THIS — 4.1 Audit Policy (record security events)**

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why:** Without auditing there's no record of logins, account changes, or policy changes.

**⭐ EASIEST WAY — Click through the GUI:** `secpol.msc` → **Local Policies → Audit Policy**. Inspect the scenario-required categories. Prefer **Advanced Audit Policy Configuration → System Audit Policies**, selecting useful subcategories deliberately as described in [19.4](#194-audit-selectively-and-investigate-windows-events). Do not enable all high-volume auditing blindly.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> auditpol /set /subcategory:"Logon" /success:enable /failure:enable
> auditpol /get /category:*
> ```
> Also: **Security Options → Audit: Force audit policy subcategory settings… to override audit policy category settings → Enabled**.

#### 4.2 User Rights Assignment
- [ ] **🎯 DO THIS — 4.2 User Rights Assignment**

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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> secedit /export /areas USER_RIGHTS /cfg $env:TEMP\rights.inf
> Select-String '^Se' $env:TEMP\rights.inf
> ```
> Accounts show as SIDs: `*S-1-1-0` = Everyone, `*S-1-5-32-545` = Users, `*S-1-5-32-546` = Guests, `*S-1-5-32-544` = Administrators. A long SID that starts with `S-1-5-21-` is one user account.

> [!WARNING]
> Look carefully at the **Deny** rights. A planted "Deny log on locally: **Users**" locks every normal user out.
> Don't remove **LOCAL SERVICE**, **NETWORK SERVICE**, **SERVICE** or entries that start with `NT SERVICE\`: Windows needs them.

#### 4.3 Security Options
- [ ] **🎯 DO THIS — 4.3 Security Options**

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

#### 4.4 PowerShell logging
- [ ] **🎯 DO THIS — 4.4 PowerShell logging**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Windows records every PowerShell script and command that runs.
> [!NOTE]
> **ℹ️ Note:**
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

<a id="research-expansion-defender-exclusions-effective-firewall-and-smb-versions"></a>
### 🛡️ Defender exclusions, effective firewall and SMB versions

- [ ] **🎯 DO THIS —** Compare each finding to the README before changing it.

**⭐ EASIEST WAY — Click through the GUI:** Start → **Windows Security → Virus & threat protection**, verify protection provider and signature freshness; then **Firewall & network protection**. If settings are managed, inspect the applicable policy source rather than forcing the registry.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Get-MpComputerStatus | Select-Object AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled,AntivirusSignatureLastUpdated
> Get-MpPreference | Select-Object ExclusionPath,ExclusionExtension,ExclusionProcess
> Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction
> Get-Service wuauserv,EventLog,mpssvc -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> ~~~

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why:** Unexpected Defender exclusions and disabled protection can hide threats, but authorized applications may require an exclusion. Do **not** blindly remove all exclusions. The Windows Update service may be stopped while idle; Disabled startup type requires investigation.

**Read-only SMB checks, when available:**

~~~powershell
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,RequireSecuritySignature
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
~~~

SMB1 is legacy; do not disable SMB functionality that the scenario explicitly requires without verifying compatibility. **Do not enable BitLocker just to tick a generic security box:** loss of recovery credentials can make a VM inaccessible.

**✅ Check it worked:** Re-run the command, test the README-required client/service, and refresh the scoring report. Record how to restore only the affected policy.


<a id="research-report-expansion-w-r1--account-inventory-guest-password-flags-and-privilege-reconciliation"></a>
### 🔐 Account inventory, Guest, password flags and privilege reconciliation

- [ ] **🎯 DO THIS — 🔐 Account inventory, Guest, password flags and privilege reconciliation**

> [!NOTE]
> **ℹ️ Note:**
> **📚 Evidence:** Community/training categories with vendor-supported commands. **Do not infer an individual scoring point.**

> [!NOTE]
> **ℹ️ Note:**
> **What / why:** The research report emphasizes unauthorized accounts, built-in Guest, local Administrators/Backup Operators/Remote Desktop Users, and local password flags. Check the **actual image README** before disabling, deleting or rotating any identity.

**⭐ EASIEST WAY — Click through the GUI:** Press **Win + R → lusrmgr.msc → Users**. Select an account → **Properties** to inspect disabled state, password never expires and group memberships. Under **Groups**, open **Administrators**, **Remote Desktop Users**, **Backup Operators** and any README-required group. On Windows Home, local-users GUI may not exist; use the terminal and the installed edition's supported tools.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Get-LocalUser | Select-Object Name,Enabled,PasswordRequired,PasswordExpires,PasswordLastSet,LastLogon
> Get-LocalGroupMember -Group 'Administrators'
> Get-LocalGroupMember -Group 'Remote Desktop Users' -ErrorAction SilentlyContinue
> Get-LocalGroupMember -Group 'Backup Operators' -ErrorAction SilentlyContinue
> ~~~

> [!CAUTION]
> **ℹ️ Note:**
> **What to look for:** An extra human login, a seemingly unauthorized local admin, enabled Guest, or password-not-required / password-never-expires on an ordinary account. Check service principals, renamed built-ins, and domain membership before changing anything. A renamed built-in account retains its SID; a display name alone is insufficient.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Disable-LocalUser -Name 'EXAMPLE_UNAUTHORIZED_USER'
> ~~~
>
For a confirmed unauthorized administrator, remove **that exact member** rather than the whole group:

~~~powershell
Remove-LocalGroupMember -Group 'Administrators' -Member 'EXAMPLE_UNAUTHORIZED_USER'
~~~

For an authorized normal account with an inappropriate never-expiring setting:

~~~powershell
Set-LocalUser -Name 'EXAMPLE_AUTHORIZED_USER' -PasswordNeverExpires $false
~~~

If the account is required but has a weak password, set it interactively:

~~~powershell
Set-LocalUser -Name 'EXAMPLE_AUTHORIZED_USER' -Password (Read-Host -AsSecureString 'Enter new password')
~~~

**✅ Verification:**

~~~powershell
Get-LocalUser -Name 'EXAMPLE_UNAUTHORIZED_USER' | Select-Object Name,Enabled
Get-LocalGroupMember -Group 'Administrators'
Get-LocalUser -Name 'EXAMPLE_AUTHORIZED_USER' | Select-Object Name,PasswordNeverExpires,PasswordRequired
~~~

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Re-enable an account mistakenly disabled with **Enable-LocalUser -Name 'ACTUAL_USER'**, or add back its recorded group membership with **Add-LocalGroupMember**. Restore a changed never-expiring flag only if documented and required. **Deletion is different from disabling**: a recreated account has a new SID and may lose access to files/permissions; use a permitted backup if an authorized user was deleted.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Never disable your only working administrator, delete README-required service users, or automatically disable domain identities using local-only cmdlets. Preserve forensics questions before account changes.

<a id="research-report-expansion-w-r2--password-history-lockout-and-effective-local-policy"></a>
### 🔐 Password history, lockout and effective local policy

- [ ] **🎯 DO THIS — 🔐 Password history, lockout and effective local policy**

> [!NOTE]
> **ℹ️ Note:**
> **📚 Evidence:** Training/community categories; vendor-backed Windows account-policy settings. The report lists multiple historical example values (e.g., minimum length 10–14, maximum age 60 or 90, threshold 5 or 10). **These are not universal scoring values.**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → secpol.msc → Account Policies → Password Policy**, then **Account Lockout Policy**. Record each current number and the README-required value; also inspect complexity and reversible encryption. If domain joined, identify effective domain policy instead of assuming local secpol controls domain credentials.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> net accounts
> gpresult /r /scope computer
> ~~~
>
**Optional baseline export before editing, into a private accessible folder:**

~~~powershell
secedit /export /cfg "$env:TEMP\cp-local-policy-before.inf"
~~~

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~cmd
> net accounts /uniquepw:24
> net accounts /minpwlen:12
> net accounts /minpwage:1
> net accounts /maxpwage:90
> ~~~
>
These commands edit **local** numeric account settings; they do **not** configure complexity or reversible-encryption policy. Set those individually in secpol.msc only at the correct scope. A lockout example **only if required**:

~~~cmd
net accounts /lockoutthreshold:5
net accounts /lockoutduration:30
net accounts /lockoutwindow:30
~~~

**✅ Verification:** Run **net accounts** again and inspect the policy GUI and resultant policy. Test one authorized user login without intentionally locking out an administrator.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Re-run **net accounts** with the **actual recorded old values**, then restore any separately edited GUI setting. Importing the full secedit export can overwrite unrelated rights and is **not** a normal one-setting rollback.

<a id="research-report-expansion-w-r3--defender-cloudpua-exclusions-signatures-and-safe-scanning"></a>
### 🧰 Defender cloud/PUA, exclusions, signatures and safe scanning

- [ ] **🎯 DO THIS — 🧰 Defender cloud/PUA, exclusions, signatures and safe scanning**

> [!NOTE]
> **ℹ️ Note:**
> **📚 Evidence:** Community/vendor-backed. Some Windows Server / enterprise environments use another approved endpoint protection product; do not force Defender to active mode without checking.

**⭐ EASIEST WAY — Click through the GUI:** **Start → Windows Security → Virus & threat protection → Manage settings**. Check real-time protection, cloud-delivered protection, PUA protection where available and **Exclusions**. Open **Protection updates**, **Scan options**, and **Protection history**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Get-MpComputerStatus | Select-Object AMRunningMode,AntivirusEnabled,RealTimeProtectionEnabled,BehaviorMonitorEnabled,AntivirusSignatureLastUpdated
> Get-MpPreference | Select-Object DisableRealtimeMonitoring,DisableBehaviorMonitoring,DisableScriptScanning,PUAProtection,ExclusionPath,ExclusionExtension,ExclusionProcess
> ~~~

> [!NOTE]
> **ℹ️ Note:**
> **What to look for:** Real-time monitoring disabled without an approved replacement, unexpectedly broad folder/process exclusions, stale signatures, unauthorized antivirus, or an active threat. An exclusion can be legitimate for a required app—record and verify it first.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Set-MpPreference -DisableRealtimeMonitoring $false
> Set-MpPreference -DisableBehaviorMonitoring $false
> Set-MpPreference -DisableScriptScanning $false
> ~~~
>
~~~powershell
Set-MpPreference -PUAProtection Enabled
Update-MpSignature
~~~

When forensic evidence is preserved and a scan is appropriate:

~~~powershell
Start-MpScan -ScanType QuickScan
~~~

**✅ Verification:** Re-run **Get-MpComputerStatus** and **Get-MpPreference**, inspect protection/history and verify the README-required applications still function. A tamper-protection or policy-managed rejection is not an invitation to bypass protection.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Restore only a setting or exclusion mistakenly changed **if the original setting is authorized**. Do not disable antivirus broadly or release quarantined malicious files just to recover a score.

<a id="research-report-expansion-w-r4--firewall-baseline-rule-scope-and-safe-profile-recovery"></a>
### 🛡️ Firewall baseline, rule scope and safe profile recovery

- [ ] **🎯 DO THIS — 🛡️ Firewall baseline, rule scope and safe profile recovery**

> [!NOTE]
> **ℹ️ Note:**
> **📚 Evidence:** Training/community; vendor-backed firewall settings.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → wf.msc → Windows Defender Firewall Properties**. Inspect Domain, Private and Public profiles. Under **Inbound Rules**, open a specific rule and inspect **Program, Protocol/Port, Scope, Profile, Enabled/Action**; preserve known required remote-admin and application traffic.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction,DefaultOutboundAction
> Get-NetFirewallRule -PolicyStore ActiveStore -Enabled True -Direction Inbound | Select-Object Name,DisplayName,Action,Profile
> Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
> ~~~
>
**Back up the firewall policy to a private, existing folder** before high-risk edits:

~~~powershell
netsh advfirewall export "$env:TEMP\cp-firewall-before.wfw"
~~~

**Fix (only after confirming all required rule exceptions, scope and management access):**

~~~powershell
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
~~~

If the README requires typical inbound-block/outbound-allow defaults, set only the correctly scoped profiles:

~~~powershell
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block -DefaultOutboundAction Allow
~~~

**✅ Verification:** Repeat profile/rule queries and connect from an authorized separate client to every required service. A listening port does not prove external reachability; a firewall rule can be limited by profile and remote address.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Restore the precise prior profile values or a **single** modified rule. Full **netsh advfirewall import** replaces the entire policy and may erase later legitimate changes, so only use it after evaluating the current policy and recovery consequences.

---

<a id="stage-4"></a>
## Part 4 — Services, Software and Persistence

> [!TIP]
> ⚙️ **Service-aware work:** Check required applications and dependencies before adjusting settings.


Investigate required services and software before touching their configuration. Large service tables are intentionally below initial priority checks.

### 10. Remote access

#### ✅ Disable unneeded Remote Desktop access

- [ ] **Task:** Disable unneeded Remote Desktop access.

**⭐ Recommended — GUI:** If the README prohibits RDP, open **Settings → System → Remote Desktop** or the effective **`gpedit.msc` Remote Desktop Services** policy and disable incoming sessions.


**✅ VERIFY:** Verify unauthorized RDP is unavailable and approved management access remains.

> [!CAUTION]
> **⚠️ Caution:** On a required remote-access or Server image, disabling RDP may cause a scoring penalty.


#### 10.1 Remote Assistance off
- [ ] **🎯 DO THIS — 10.1 Remote Assistance off**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `SystemPropertiesRemote` → untick **Allow Remote Assistance connections to this computer**.

**✅ Check it worked:**
```powershell
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' | Select-Object fAllowToGetHelp   # 0 = off
```

#### 10.2 Remote Desktop off (or secured)
- [ ] **🎯 DO THIS — 10.2 Remote Desktop off (or secured)**

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


### 11. Shared folders

#### ✅ Stop sharing a confirmed unauthorized hidden custom share

- [ ] **Task:** Stop sharing a confirmed unauthorized hidden custom share.

**⭐ Recommended — GUI:** Press **Win + R → `fsmgmt.msc` → Shares**, find the **exact unapproved custom share** and select **Stop Sharing** after checking its path and owners.


**✅ VERIFY:** Verify that the unauthorized share is absent while all required shares work.

> [!CAUTION]
> **⚠️ Caution:** Do not remove administrative shares, SYSVOL/NETLOGON or an approved share merely because its name ends in `$`.


#### 11.1 Remove shares that aren't needed
- [ ] **🎯 DO THIS (only if authorized) — 11.1 Remove shares that aren't needed**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `fsmgmt.msc` → **Shares**. Right-click a share → **Stop Sharing**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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


### 12. Prohibited software

#### ✅ Uninstall a confirmed prohibited game bundle

- [ ] **Task:** Uninstall a confirmed prohibited game bundle.

**⭐ Recommended — GUI:** Open **Settings → Apps → Installed apps** or **Control Panel → Programs and Features**, select the exact unauthorized game bundle and follow its uninstall wizard.


**✅ VERIFY:** Verify uninstallation and check that required apps still work.

> [!CAUTION]
> **⚠️ Caution:** A game seen in one example isn't necessarily installed or prohibited on another.

#### ✅ Uninstall a confirmed prohibited disk-usage utility

- [ ] **Task:** Uninstall a confirmed prohibited disk-usage utility.

**⭐ Recommended — GUI:** Open **Control Panel → Programs and Features** and remove the actual unauthorized utility (such as WinDirStat) **only if the README prohibits it**.


**✅ VERIFY:** Verify the item is gone and no required software was affected.

> [!CAUTION]
> **⚠️ Caution:** A disk-analysis utility is often benign; the README controls whether it should be removed.

#### ✅ Uninstall a confirmed prohibited packet analyzer

- [ ] **Task:** Uninstall a confirmed prohibited packet analyzer.

**⭐ Recommended — GUI:** Open **Control Panel → Programs and Features**, select the actual disallowed packet analyzer (such as Wireshark), and uninstall only after checking the task requirements.


**✅ VERIFY:** Confirm it is removed, and make sure required network tools remain.

> [!CAUTION]
> **⚠️ Caution:** A packet analyzer can be legitimate in example environments; do not treat its presence alone as malicious.


#### 12.1 Uninstall hacking tools, games, torrent and remote-control programs
- [ ] **🎯 DO THIS (only if authorized) — 12.1 Uninstall hacking tools, games, torrent and remote-control programs**

**⭐ EASIEST WAY — Click through the GUI:** **Settings → Apps → Installed apps** (or **Win + R → appwiz.cpl**). Sort by name and read the **whole** list.

Look for:
- **Hacking:** Wireshark, Npcap/WinPcap, Nmap, Cain & Abel, John the Ripper, Hashcat, Cheat Engine, keyloggers, "password recovery" tools
- **Games:** Steam, Epic, Minecraft, Roblox, Solitaire, Candy Crush
- **File-sharing:** uTorrent, BitTorrent, qBittorrent, Vuze, FrostWire
- **Remote control:** TeamViewer, AnyDesk, VNC, RustDesk

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
>   Where-Object DisplayName | Sort-Object DisplayName | Format-Table DisplayName, DisplayVersion, Publisher
> ```

#### 12.2 Store apps and games
- [ ] **🎯 DO THIS — 12.2 Store apps and games**

```powershell
Get-AppxPackage -AllUsers | Where-Object Name -match 'Solitaire|CandyCrush|Minecraft|Roblox|king.com' | Select-Object Name
Get-AppxPackage -AllUsers *Solitaire* | Remove-AppxPackage -AllUsers
```

#### 12.3 "Portable" tools that aren't installed
- [ ] **🎯 DO THIS — 12.3 "Portable" tools that aren't installed**

Hacking tools are often just an `.exe` sitting in a folder: look in **Downloads**, **Desktop**, `C:\Users\Public`, `C:\Temp`, and `C:\` itself.
```powershell
Get-ChildItem C:\Users, C:\Temp -Recurse -Force -Include nc.exe,ncat.exe,nmap.exe,mimikatz*,*keylog*,psexec*,john*.exe,hashcat*.exe -ErrorAction SilentlyContinue
```

---


### 13. Prohibited files

#### ✅ Remove confirmed prohibited media while preserving evidence

- [ ] **Task:** Remove confirmed prohibited media while preserving evidence.

**⭐ Recommended — File Explorer:** Open **File Explorer → This PC → Users**, inspect the specified folder and file types, preserve any forensic evidence, then remove **only README-prohibited media**.


**✅ VERIFY:** Recheck the target folder and ensure required/media-forensics files were retained.

> [!CAUTION]
> **⚠️ Caution:** Never run a broad removal across all user folders or remove README-required files.


#### 13.1 Show hidden files first
- [ ] **🎯 DO THIS — 13.1 Show hidden files first**

**File Explorer → View → Show → Hidden items** (Windows 10: **View → Hidden items**). Also tick **File name extensions**.

#### 13.2 Find media files
- [ ] **🎯 DO THIS — 13.2 Find media files**

```powershell
Get-ChildItem C:\Users -Recurse -Force -Include *.mp3,*.mp4,*.wav,*.wma,*.wmv,*.avi,*.mkv,*.mov,*.flac,*.m4a,*.aac,*.ogg,*.torrent -ErrorAction SilentlyContinue |
  Select-Object FullName
Remove-Item "C:\Users\bob\Music\song.mp3"
```
Also look in other folders on `C:\` that aren't part of Windows (e.g. `C:\Media`, `C:\Share`), and **empty the Recycle Bin** when forensics is done.

#### 13.3 Password lists and other data
- [ ] **🎯 DO THIS — 13.3 Password lists and other data**

```powershell
Get-ChildItem C:\Users -Recurse -Force -Include *password*,*creditcard*,*.pcap,*.kdbx -ErrorAction SilentlyContinue | Select-Object FullName
```

---


### 14. Backdoors and malware

#### ✅ Investigate and contain a confirmed unauthorized backdoor

- [ ] **Task:** Investigate and contain a confirmed unauthorized backdoor.

**⭐ Recommended — Task Manager / File Explorer:** Open **Task Manager → Details** to identify the suspicious process, use **Open file location**, preserve path/hash/evidence, then stop/quarantine **only a confirmed malicious** process/file with the authorized defender.


**✅ VERIFY:** Verify the process and its persistence source are no longer active; check scoring and essential services.

> [!CAUTION]
> **⚠️ Caution:** Do not delete a similarly named Windows/system executable or blindly terminate a PID copied from an answer key.


#### 14.1 Programs that start at logon
- [ ] **🎯 DO THIS — 14.1 Programs that start at logon**

**⭐ EASIEST WAY — Click through the GUI:** **Task Manager (Ctrl+Shift+Esc) → Startup apps**. Also open these folders with **Win + R**: `shell:startup` and `shell:common startup`.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-CimInstance Win32_StartupCommand | Format-Table Name, Command, Location -AutoSize
> Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run, HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run, HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -ErrorAction SilentlyContinue
> Remove-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Run -Name "Updater"
> ```
> Red flags: `powershell -enc` followed by a long string, `-WindowStyle Hidden`, `nc.exe`, `mshta`, `.vbs`/`.bat`/`.ps1` files, anything in `C:\Users\Public` or `Temp`.

#### 14.2 Scheduled tasks
- [ ] **🎯 DO THIS — 14.2 Scheduled tasks**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `taskschd.msc` → **Task Scheduler Library**. Check each task's **Actions** tab. Non-Microsoft tasks are usually in the top folder.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-ScheduledTask | Where-Object TaskPath -notlike '\Microsoft\*' |
>   ForEach-Object { "{0}{1} -> {2} {3}" -f $_.TaskPath, $_.TaskName, $_.Actions.Execute, $_.Actions.Arguments }
> Unregister-ScheduledTask -TaskName "BadTask" -Confirm:$false
> ```

#### 14.3 Services that run strange programs
- [ ] **🎯 DO THIS — 14.3 Services that run strange programs**

```powershell
Get-CimInstance Win32_Service | Where-Object { $_.PathName -notmatch 'Windows\\|Program Files' } | Format-Table Name, State, PathName -AutoSize
Stop-Service -Name BadService -Force; Set-Service -Name BadService -StartupType Disabled   # BadService = the bad one's Name
sc.exe delete BadService            # only for a service you are sure is malware. Type sc.exe: in PowerShell, sc means something else
```

#### 14.4 Sticky Keys / Utility Manager backdoor
- [ ] **🎯 DO THIS — 14.4 Sticky Keys / Utility Manager backdoor**

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why:** Replacing `sethc.exe` (press Shift 5 times) or `utilman.exe` (the accessibility button) with `cmd.exe` gives anyone a SYSTEM command prompt **at the login screen**.

```powershell
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' |
  Where-Object { $_.GetValue('Debugger') } | ForEach-Object { "$($_.PSChildName) -> $($_.GetValue('Debugger'))" }
foreach ($f in 'sethc','utilman','osk','Magnify','Narrator') { "$f -> " + (Get-Item "C:\Windows\System32\$f.exe").VersionInfo.OriginalFilename }   # each must show its own name (.mui is fine), not Cmd.Exe
```
**🛠️ Fix:** delete the `Debugger` value. If the file itself was replaced, run `sfc /scanfile=C:\Windows\System32\sethc.exe`.

#### 14.5 The hosts file
- [ ] **🎯 DO THIS — 14.5 The hosts file**

```powershell
notepad C:\Windows\System32\drivers\etc\hosts
```
Comments, localhost entries and README-required internal host mappings can all be legitimate. Back up the file, then remove only confirmed unauthorized overrides; verify name resolution afterwards.

#### 14.6 Programs listening for connections
- [ ] **🎯 DO THIS — 14.6 Programs listening for connections**

```powershell
Get-NetTCPConnection -State Listen | Select-Object LocalPort, OwningProcess, @{n='Process';e={(Get-Process -Id $_.OwningProcess).ProcessName}} | Sort-Object LocalPort
```
`nc`, `ncat`, `powershell` or `python` listening on an unexpected port warrants investigation; development tools and required applications can legitimately listen too. Stop it with `Stop-Process -Id 4242 -Force` (use the number from the `OwningProcess` column), then find what starts it (14.1–14.3).

---


### 16. Web browsers

#### ✅ Update a required third-party application safely

- [ ] **Task:** Update a required third-party application safely.

**⭐ Recommended — GUI:** Open the application (for example Notepad++) → **Help / ? → About / Check for Updates**, then obtain a signed approved version from its **official vendor** and complete the installer.


**✅ VERIFY:** Verify the installed version, executable location and application launch.

> [!CAUTION]
> **⚠️ Caution:** Do not hardcode a example version or move a README-required application from its assigned default install location.

#### ✅ Enable SmartScreen warnings or blocking as required

- [ ] **Task:** Enable SmartScreen warnings or blocking as required.

**⭐ Recommended — GUI:** Press **Win + R → `gpedit.msc` → Computer Configuration → Administrative Templates → Windows Components → File Explorer → Configure Windows Defender SmartScreen** and enable the required protective behavior.


**✅ VERIFY:** Confirm the policy is applied and that approved downloads/applications continue working.

> [!CAUTION]
> **⚠️ Caution:** Policy location and available choices vary by Windows version; use current installed policy labels.

#### ✅ Check protected browser/application install locations

- [ ] **Task:** Check protected browser/application install locations.

**⭐ Recommended — File Explorer / installed apps:** Open installed-app details and File Explorer to confirm that **README-required Chrome, Notepad++ or other applications** remain installed at the expected authorized location.


**✅ VERIFY:** Confirm the required program launches from the approved path.

> [!CAUTION]
> **⚠️ Caution:** The supplied example includes penalties for missing/relocated software; do not uninstall or relocate required applications to chase generic cleanup points.


---


#### 16.1 Microsoft Edge
- [ ] **🎯 DO THIS — 16.1 Microsoft Edge**

**⋯ → Settings → Privacy, search, and services** → **Microsoft Defender SmartScreen: On**, **Block potentially unwanted apps: On**. **Cookies and site permissions → Pop-ups and redirects → Block**. **⋯ → Settings → Profiles → Passwords → Offer to save passwords: Off**. Update via **⋯ → Help and feedback → About Microsoft Edge**.

#### 16.2 Firefox (if installed)
- [ ] **🎯 DO THIS — 16.2 Firefox (if installed)**

**≡ → Settings → Privacy & Security**:
- **Block pop-up windows** ✔
- **Warn you when websites try to install add-ons** ✔
- **Block dangerous and deceptive content** ✔ (all three boxes)
- **HTTPS-Only Mode** → Enable in all windows
- **Passwords → Ask to save passwords** ✘ (untick it)

Then **≡ → Help → About Firefox** to update. Also check **Add-ons and themes** for extensions you don't recognise.

#### 16.3 Chrome (if installed)
- [ ] **🎯 DO THIS — 16.3 Chrome (if installed)**

**⋮ → Settings → Privacy and security → Security → Standard (or Enhanced) protection**. **Site settings → Pop-ups and redirects → Don't allow**. **Autofill and passwords → Google Password Manager → Settings → Offer to save passwords: Off**. Update via **Help → About Google Chrome**.

---


### 8. Services

#### ✅ Disable unnecessary Simple TCP/IP Services

- [ ] **Task:** Disable unnecessary Simple TCP/IP Services.

**⭐ Recommended — GUI:** Press **Win + R → `services.msc` → Simple TCP/IP Services** when installed. If specifically not required, stop it and set **Startup type: Disabled**.


**✅ VERIFY:** Verify the service remains stopped/disabled and other services continue working.

> [!CAUTION]
> **⚠️ Caution:** The service may be absent; that is not a vulnerability by itself.

#### ✅ Disable unnecessary Remote Registry service

- [ ] **Task:** Disable unnecessary Remote Registry service.

**⭐ Recommended — GUI:** Open **Win + R → `services.msc` → Remote Registry → Properties**. If the README doesn't require it, **Stop** and set **Startup type: Disabled**.


**✅ VERIFY:** Check the final status and required management functions.

> [!CAUTION]
> **⚠️ Caution:** Restore the original startup state if a required management tool loses access.


**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `services.msc`. To turn a service off: double-click it → **Startup type: Disabled** → **Stop** → **OK**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Stop-Service -Name RemoteRegistry
> Set-Service -Name RemoteRegistry -StartupType Disabled
> ```

#### 8.1 Turn off risky services (unless the README needs them)
- [ ] **🎯 DO THIS (only if authorized) — 8.1 Turn off risky services (unless the README needs them)**

| Service (name) | Usually |
|---|---|
| Remote Registry (`RemoteRegistry`) | **Disable** |
| Telnet server (`TlntSvr`, only on old images) | **Disable** |
| SNMP Service (`SNMP`) and SNMP Trap (`SNMPTRAP`) | **Disable** |
| SSDP Discovery (`SSDPSRV`) | Disable |
| UPnP Device Host (`upnphost`) | Disable |
| Microsoft FTP Service (`FTPSVC`) | Disable unless FTP is needed |
| World Wide Web Publishing (`W3SVC`) | Disable unless a website is needed |
| Remote Desktop Services (`TermService`) | Disable unless RDP is needed |
| Routing and Remote Access (`RemoteAccess`) | Disable |
| Internet Connection Sharing (`SharedAccess`) | Disable |
| Print Spooler (`Spooler`) | Disable unless printing is needed |
| Xbox services (`XblAuthManager`, `XblGameSave`, `XboxNetApiSvc`) | Disable |
| Simple TCP/IP Services (`simptcp`) | **Disable** |
| WebClient (`WebClient`) | Disable unless the README needs WebDAV |
| Windows Media Player Network Sharing (`WMPNetworkSvc`) | Disable |
| OpenSSH SSH Server (`sshd`) | Disable unless SSH is needed |
| Windows Remote Management (`WinRM`) | Disable unless remote PowerShell is needed |
| Remote-control tools (TeamViewer, AnyDesk, VNC) | Disable **and** uninstall |

> [!CAUTION]
> Never disable a service the README lists as critical, and leave services you don't recognise alone until you have looked them up. Disabling the wrong one (e.g. RPC, DCOM, Windows Event Log) can break the computer.

##### 8.1.1 Remote Registry

- [ ] **🎯 DO THIS — 8.1.1 Remote Registry**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Allows remote registry administration. Actual service name(s): `RemoteRegistry`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable if remote registry administration is not required.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Remote Registry** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'RemoteRegistry' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'RemoteRegistry' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'RemoteRegistry'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'RemoteRegistry' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'RemoteRegistry' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'RemoteRegistry' -StartupType Manual
Start-Service -Name 'RemoteRegistry'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Remote administrators may depend on this; do not alter RPC. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.2 Telnet

- [ ] **🎯 DO THIS — 8.1.2 Telnet**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Provides unencrypted remote terminal access on older Windows versions. Actual service name(s): `TlntSvr`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable an installed server unless the scenario explicitly requires Telnet; prefer SSH where permitted.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Telnet** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'TlntSvr' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'TlntSvr' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'TlntSvr'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'TlntSvr' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'TlntSvr' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'TlntSvr' -StartupType Manual
Start-Service -Name 'TlntSvr'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Telnet Client is a separate optional feature. A missing TlntSvr is normal on modern Windows. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.3 SNMP and SNMP Trap

- [ ] **🎯 DO THIS — 8.1.3 SNMP and SNMP Trap**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** SNMP exposes monitoring data; the trap service receives monitoring notifications. Actual service name(s): `SNMP`, `SNMPTRAP`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable each installed service unless monitoring is required.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **SNMP and SNMP Trap** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'SNMP','SNMPTRAP' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'SNMP','SNMPTRAP' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'SNMP'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'SNMP' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'SNMP','SNMPTRAP' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'SNMP' -StartupType Manual
Start-Service -Name 'SNMP'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Retained SNMP needs restricted managers, firewall sources and nondefault community strings; traps and polling have different dependencies. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.4 SSDP Discovery

- [ ] **🎯 DO THIS — 8.1.4 SSDP Discovery**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Discovers devices using SSDP multicast. Actual service name(s): `SSDPSRV`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable if network device discovery is not required.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **SSDP Discovery** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'SSDPSRV' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'SSDPSRV' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'SSDPSRV'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'SSDPSRV' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'SSDPSRV' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'SSDPSRV' -StartupType Manual
Start-Service -Name 'SSDPSRV'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Media and device discovery may stop; inspect DependentServices first. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.5 UPnP Device Host

- [ ] **🎯 DO THIS — 8.1.5 UPnP Device Host**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Hosts Universal Plug and Play devices. Actual service name(s): `upnphost`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable if UPnP hosting is not required.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **UPnP Device Host** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'upnphost' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'upnphost' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'upnphost'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'upnphost' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'upnphost' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'upnphost' -StartupType Manual
Start-Service -Name 'upnphost'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** UPnP-dependent applications can fail; do not disable unrelated networking services. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.6 FTP

- [ ] **🎯 DO THIS — 8.1.6 FTP**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Runs the Microsoft IIS FTP transfer service. Actual service name(s): `FTPSVC`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Keep and harden a required FTP server; otherwise disable.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **FTP** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'FTPSVC' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'FTPSVC' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'FTPSVC'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'FTPSVC' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'FTPSVC' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'FTPSVC' -StartupType Manual
Start-Service -Name 'FTPSVC'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** FTP authentication, TLS certificates and passive data ports must remain usable; see the Server FTP procedure. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.7 World Wide Web Publishing

- [ ] **🎯 DO THIS — 8.1.7 World Wide Web Publishing**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Serves IIS websites. Actual service name(s): `W3SVC`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Keep if the README requires a website; otherwise disable after checking sites.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **World Wide Web Publishing** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'W3SVC' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'W3SVC' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'W3SVC'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'W3SVC' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'W3SVC' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'W3SVC' -StartupType Manual
Start-Service -Name 'W3SVC'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Inspect IIS bindings and application pools; do not mistake an intentionally installed website for malware. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.8 Remote Desktop Services

- [ ] **🎯 DO THIS — 8.1.8 Remote Desktop Services**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Provides Remote Desktop sessions. Actual service name(s): `TermService`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Keep and secure if RDP is required; otherwise turn Remote Desktop off before considering disabling the service.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Remote Desktop Services** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'TermService' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'TermService' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'TermService'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'TermService' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'TermService' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'TermService' -StartupType Manual
Start-Service -Name 'TermService'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Never stop it from your only RDP connection. Use the VM console and test NLA and authorized users. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.9 Routing and Remote Access

- [ ] **🎯 DO THIS — 8.1.9 Routing and Remote Access**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Provides routing and VPN functions. Actual service name(s): `RemoteAccess`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable only on a machine that is not a required router or VPN server.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Routing and Remote Access** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'RemoteAccess' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'RemoteAccess' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'RemoteAccess'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'RemoteAccess' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'RemoteAccess' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'RemoteAccess' -StartupType Manual
Start-Service -Name 'RemoteAccess'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Record routes and VPN requirements first; disabling can disconnect entire subnets. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.10 Internet Connection Sharing

- [ ] **🎯 DO THIS — 8.1.10 Internet Connection Sharing**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Provides shared network access and NAT functions. Actual service name(s): `SharedAccess`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable only if ICS, hosted networking and dependent virtualization features are not needed.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Internet Connection Sharing** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'SharedAccess' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'SharedAccess' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'SharedAccess'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'SharedAccess' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'SharedAccess' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'SharedAccess' -StartupType Manual
Start-Service -Name 'SharedAccess'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Inspect VM networking dependencies; never disable the Windows Firewall service mpssvc in its place. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.11 Print Spooler

- [ ] **🎯 DO THIS — 8.1.11 Print Spooler**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Queues printing jobs and loads printer drivers. Actual service name(s): `Spooler`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable when no printing is required; otherwise patch and restrict driver installation.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Print Spooler** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'Spooler' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'Spooler' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'Spooler'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'Spooler' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'Spooler' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'Spooler' -StartupType Manual
Start-Service -Name 'Spooler'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Printing and some PDF workflows may stop. Keep required print-server roles; follow section 8.3. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.12 Xbox services

- [ ] **🎯 DO THIS — 8.1.12 Xbox services**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Supports Xbox authentication, saved games and networking. Actual service name(s): `XblAuthManager`, `XblGameSave`, `XboxNetApiSvc`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable installed members when gaming is not required.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Xbox services** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'XblAuthManager','XblGameSave','XboxNetApiSvc' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'XblAuthManager','XblGameSave','XboxNetApiSvc' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'XblAuthManager'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'XblAuthManager' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'XblAuthManager','XblGameSave','XboxNetApiSvc' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'XblAuthManager' -StartupType Manual
Start-Service -Name 'XblAuthManager'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Some builds omit these services. Do not use a wildcard to disable unrelated services. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.13 Simple TCP/IP Services

- [ ] **🎯 DO THIS — 8.1.13 Simple TCP/IP Services**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Hosts legacy echo, discard, daytime, quote and character-generator protocols. Actual service name(s): `simptcp`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable unless explicitly required for a lab task.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Simple TCP/IP Services** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'simptcp' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'simptcp' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'simptcp'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'simptcp' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'simptcp' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'simptcp' -StartupType Manual
Start-Service -Name 'simptcp'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** The optional component may be absent. Removing it and disabling it are separate changes. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.14 WebClient

- [ ] **🎯 DO THIS — 8.1.14 WebClient**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Lets applications access WebDAV resources. Actual service name(s): `WebClient`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable unless required WebDAV workflows need it.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **WebClient** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'WebClient' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'WebClient' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'WebClient'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'WebClient' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'WebClient' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'WebClient' -StartupType Manual
Start-Service -Name 'WebClient'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Mapped WebDAV drives and document workflows may fail; normal SMB shares are a different protocol. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.15 Windows Media Player Network Sharing

- [ ] **🎯 DO THIS — 8.1.15 Windows Media Player Network Sharing**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Shares media libraries over the network. Actual service name(s): `WMPNetworkSvc`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Disable unless media sharing is explicitly required.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **Windows Media Player Network Sharing** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'WMPNetworkSvc' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'WMPNetworkSvc' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'WMPNetworkSvc'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'WMPNetworkSvc' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'WMPNetworkSvc' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'WMPNetworkSvc' -StartupType Manual
Start-Service -Name 'WMPNetworkSvc'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Local playback and network sharing are different functions; do not remove required media files. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.16 OpenSSH SSH Server

- [ ] **🎯 DO THIS — 8.1.16 OpenSSH SSH Server**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Provides encrypted SSH and SFTP access. Actual service name(s): `sshd`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Keep and harden when required; otherwise disable the installed server.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **OpenSSH SSH Server** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'sshd' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'sshd' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'sshd'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'sshd' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'sshd' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'sshd' -StartupType Manual
Start-Service -Name 'sshd'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Back up C:\ProgramData\ssh\sshd_config, run sshd.exe -t if available, and test a second authorized connection before closing the first. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.17 WinRM

- [ ] **🎯 DO THIS — 8.1.17 WinRM**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Supports Windows Remote Management, PowerShell remoting and server administration. Actual service name(s): `WinRM`.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Every enabled network or privileged service increases the available attack surface. **Recommendation:** Keep when required by management tools; restrict authentication and firewall sources.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Check the README for this function, record the original startup type and running status for each installed service, and confirm you have a console session.

**⭐ EASIEST WAY — Click through the GUI:**

1. Press **Win + R**, enter `services.msc`, and press **Enter**.
2. Find **WinRM** (use the service names above if the display name differs). Double-click each installed entry.
3. Record **Service name**, **Startup type**, **Service status**, and the **Dependencies** tab.
4. Only if not required, select **Disabled**, click **Apply**, then **Stop**, then **OK**. If Stop fails, inspect dependencies and the error instead of forcing it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-Service -Name 'WinRM' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
> Get-Service -Name 'WinRM' -ErrorAction SilentlyContinue | Select-Object Name,DependentServices,ServicesDependedOn
> ```
>
`Name` is the stable identifier; `Status` is the current state; `StartType` controls future starts. No row means that name is not installed; confirm in Services rather than installing it to complete the checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name 'WinRM'
> ```
>
Stops the current instance. Do not add `-Force` to bypass dependencies.

```powershell
Set-Service -Name 'WinRM' -StartupType Disabled
```

Prevents normal future starts. Repeat individually for other installed names only after the same decision.

**✅ Check it worked:**

```powershell
Get-Service -Name 'WinRM' -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType
```

Changed entries should show `Stopped` and `Disabled`. Required entries should retain their recorded type and pass an actual client test. Refresh the Scoring Report.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** In Services restore the recorded startup type and click **Start** only if it was originally running. For an original Manual service:

```powershell
Set-Service -Name 'WinRM' -StartupType Manual
Start-Service -Name 'WinRM'
```

Use `Automatic` instead when that was recorded; restore delayed automatic start through the GUI. Leave an originally stopped service stopped.

> [!CAUTION]
> **ℹ️ Note:**
> **Warnings and troubleshooting:** Server Manager often depends on WinRM. Check winrm get winrm/config/service; Basic and AllowUnencrypted should normally be false. `Access is denied` usually means the shell is not elevated or the service is protected. `Cannot find any service` means the name is absent or mistyped. A policy that restores the setting needs investigation in Group Policy; repeated forced changes are not a fix.


##### 8.1.18 Remote-control applications

- [ ] **🎯 DO THIS — 8.1.18 Remote-control applications**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** TeamViewer, AnyDesk, VNC and RustDesk install vendor-specific services; no universal service name exists. Common names include `TeamViewer`, `AnyDesk`, `uvnc_service` and `tvnserver`, but verify the installed executable.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Unauthorized unattended access bypasses the expected administration path.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Preserve the executable path, signature, configuration and relevant logs for forensics. Keep a README-required remote-control application.

**⭐ EASIEST WAY — Click through the GUI:** Open `services.msc`; double-click the vendor service and record **Path to executable**, startup type and status. Open **Settings → Apps → Installed apps**; identify the same publisher. Stop and disable only a confirmed unauthorized entry, then use the vendor's uninstall option after evidence is saved.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Get-CimInstance Win32_Service | Where-Object { $_.Name -match 'TeamViewer|AnyDesk|VNC|RustDesk' -or $_.PathName -match 'TeamViewer|AnyDesk|VNC|RustDesk' } | Format-List Name,DisplayName,State,StartMode,PathName
> ```

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Stop-Service -Name AnyDesk
> Set-Service -Name AnyDesk -StartupType Disabled
> ```
>
**✅ Check it worked:** Repeat the inventory and verify the entry is stopped/disabled or gone after uninstall. Inspect the original listening port and startup entry too; portable tools may have no service.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Before uninstalling, preserve an authorized installer and license/configuration details privately. Restore the recorded service type and status if merely disabled; reinstall from the trusted vendor only if removal was mistaken.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Names and paths are clues, not proof. Do not run `sc.exe delete` as a substitute for an application uninstaller or remove a tool supporting your only access path.

#### 8.2 Make sure the security services are running
- [ ] **🎯 DO THIS — 8.2 Make sure the security services are running**

Windows Defender (`WinDefend`), Windows Defender Firewall (`mpssvc`), Windows Event Log (`EventLog`), Windows Update (`wuauserv`, Manual is fine), Security Center (`wscsvc`, not on Windows Server). None of these may be **Disabled**.

```powershell
Get-Service WinDefend, mpssvc, EventLog, wuauserv, wscsvc -ErrorAction SilentlyContinue | Format-Table Name, Status, StartType   # on Windows Server, wscsvc is simply missing from the list
```

#### 8.3 Printer drivers: PrintNightmare fixes
- [ ] **🎯 DO THIS — 8.3 Printer drivers: PrintNightmare fixes**

> [!CAUTION]
> **ℹ️ Note:**
> **🎯 What:** Only administrators may install printer drivers, and "Point and Print" must always show a warning and ask for an admin password.
> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** PrintNightmare (CVE-2021-34527) lets a normal user install a "printer driver" that runs as SYSTEM, the most powerful account. An image can plant the old, unsafe setting even when Windows is updated.

**⭐ EASIEST WAY — Click through the GUI:** `gpedit.msc` → **Computer Configuration → Administrative Templates → Printers**:
- **Limits print driver installation to Administrators**: **Enabled** (only on images updated since October 2021; skip it if it isn't in the list).
- **Point and Print Restrictions**: **Enabled**, and both "When installing drivers for a new connection" and "When updating drivers for an existing connection" set to **Show warning and elevation prompt**.

On Home, or if the first policy isn't in the list, use the Typing commands.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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


### 9. Windows features

#### 9.1 Turn off old, insecure features
- [ ] **🎯 DO THIS (only if authorized) — 9.1 Turn off old, insecure features**

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `optionalfeatures` → **untick**:
- **SMB 1.0/CIFS File Sharing Support** (the WannaCry hole)
- **Telnet Client**
- **TFTP Client**
- **Windows PowerShell 2.0**
- **Internet Information Services** (only if the README doesn't need a website/FTP)
- **Internet Explorer 11** (Windows 10)

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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

#### 9.2 Optional features (OpenSSH Server, SNMP)
- [ ] **🎯 DO THIS — 9.2 Optional features (OpenSSH Server, SNMP)**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Some extras are "optional features" instead of Windows features: **OpenSSH Server** and **SNMP** are the risky ones.
**⭐ EASIEST WAY — Click through the GUI:** **Settings → System → Optional features** (older versions: **Settings → Apps → Optional features**) → click the feature → **Remove**. Keep it if the README needs it.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
> ```powershell
> Get-WindowsCapability -Online | Where-Object State -eq Installed | Select-Object Name
> Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0   # skip if the README needs SSH
> Remove-WindowsCapability -Online -Name SNMP.Client~~~~0.0.1.0       # skip if the README needs SNMP
> ```
**✅ Check it worked:** run the first line again: the removed names are gone.

---


### 15. Other settings

#### 15.1 User Account Control
- [ ] **🎯 DO THIS — 15.1 User Account Control**

**Start** → type **Change User Account Control settings** → move the slider to the **top** (**Always notify**).

**✅ Check it worked:**
```powershell
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System | Format-List EnableLUA, ConsentPromptBehaviorAdmin, PromptOnSecureDesktop
```
Wanted: `1`, `2`, `1`. If `EnableLUA` was `0`, UAC only comes back after a restart.

#### 15.2 AutoPlay off
- [ ] **🎯 DO THIS — 15.2 AutoPlay off**

**Settings → Bluetooth & devices → AutoPlay** (Windows 10: **Devices → AutoPlay**) → **Use AutoPlay for all media and devices: Off**.

**Policy:** `gpedit.msc` → **Computer Configuration → Administrative Templates → Windows Components → AutoPlay Policies → Turn off Autoplay** → **Enabled**, **All drives**.

#### 15.3 Screen saver with password
- [ ] **🎯 DO THIS — 15.3 Screen saver with password**

**Settings → Personalization → Lock screen → Screen saver** → pick one, **Wait: 10 minutes**, tick **On resume, display logon screen**.

#### 15.4 Turn off LLMNR
- [ ] **🎯 DO THIS (only if authorized) — 15.4 Turn off LLMNR**

`gpedit.msc` → **Computer Configuration → Administrative Templates → Network → DNS Client → Turn off multicast name resolution → Enabled**.

**✅ Check it worked:**
```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' | Select-Object EnableMulticast   # must be 0
```

#### 15.5 SmartScreen on
- [ ] **🎯 DO THIS — 15.5 SmartScreen on**

**Windows Security → App & browser control → Reputation-based protection settings** → turn everything **on**.

> [!WARNING]
> **Do not turn on BitLocker** on a practice image. Without the recovery key you can lock yourself out of the whole VM.

#### 15.6 WDigest off (no plain-text passwords in memory)
- [ ] **🎯 DO THIS — 15.6 WDigest off (no plain-text passwords in memory)**

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** With WDigest on, Windows keeps logged-in users' passwords in memory as plain text, and tools like mimikatz can read them.

**⭐ EASIEST WAY — PowerShell/command line (run only applicable commands):**
```powershell
$k = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'
if (-not (Test-Path $k)) { New-Item -Path $k | Out-Null }
Set-ItemProperty $k -Name UseLogonCredential -Value 0 -Type DWord
Get-ItemProperty $k | Select-Object UseLogonCredential   # must be 0
```

#### 15.7 NetBIOS over TCP/IP off
- [ ] **🎯 DO THIS — 15.7 NetBIOS over TCP/IP off**

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Like LLMNR (15.4), attackers answer NetBIOS name lookups to steal password hashes.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R** → `ncpa.cpl` → right-click the network adapter → **Properties** → **Internet Protocol Version 4 (TCP/IPv4)** → **Properties** → **Advanced…** → **WINS** → **Disable NetBIOS over TCP/IP** → **OK**.

**✅ Check it worked:**
```powershell
Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE" | Select-Object Description, TcpipNetbiosOptions   # 2 = off
```

---


### 17. Critical services

If the README says this computer runs a website, FTP or file shares, harden them instead of removing them. See the IIS/FTP sections of the [Windows Server checklist](windows-server.md#9-critical-server-roles-only-if-the-readme-lists-them). They work the same on Windows 10/11.

---

<a id="research-expansion-startup-persistence-and-active-network-listeners"></a>
### 🛡️ startup persistence and active network listeners

- [ ] **🎯 DO THIS —** Check installed software, remote-access tools, services, tasks and ports without executing unknown files.

~~~powershell
Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location,User
Get-ScheduledTask | Select-Object TaskPath,TaskName,State
Get-CimInstance Win32_Service | Select-Object Name,State,StartMode,StartName,PathName
Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
~~~

> [!NOTE]
> **ℹ️ Note:**
> **🧠 Interpretation:** An unusual executable path or listener is an investigation lead, not proof of malware. Compare against signed publisher, files and service dependencies, and permitted software; preserve forensic evidence before removal. Confirm required remote assistance, IIS, SMB, SSH or RDP before changing firewall rules.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Restore the single authorized task, service startup type, or firewall rule from its recorded starting state. Avoid broad deletions.


<a id="research-report-expansion-w-r5--smbv1-required-smb-signing-share-permissions-and-fallback"></a>
### 🧰 SMBv1, required SMB signing, share permissions and fallback

- [ ] **🎯 DO THIS — 🧰 SMBv1, required SMB signing, share permissions and fallback**

> [!NOTE]
> **ℹ️ Note:**
> **📚 Evidence:** Community/vendor-backed. SMBv1 is obsolete and SMB signing protects message integrity, but legacy clients and specific file-sharing scenarios can change the safe action.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → optionalfeatures.exe → SMB 1.0/CIFS File Sharing Support** for optional SMB1 components; **secpol.msc → Local Policies → Security Options** for **Microsoft network client/server: Digitally sign communications (always)**; **Win + R → fsmgmt.msc → Shares** for sharing configuration.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
> Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,RequireSecuritySignature
> Get-SmbClientConfiguration | Select-Object RequireSecuritySignature
> Get-SmbShare | Select-Object Name,Path,Description,Special
> ~~~
>
For one **actual share**, substitute its name:

~~~powershell
Get-SmbShareAccess -Name 'EXAMPLE_SHARE'
~~~

**Fix (only if SMB1 is installed, not required, and removal is approved):**

~~~powershell
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
~~~

After validating compatibility, require signing for the correct side of the SMB connection as needed:

~~~powershell
Set-SmbServerConfiguration -RequireSecuritySignature $true
Set-SmbClientConfiguration -RequireSecuritySignature $true
~~~

**How to interpret:** Client signing covers outbound SMB; server signing covers inbound. SMB2/SMB3 signing is controlled by the *Require* setting, not legacy weak SMB1 behaviors. Do **not** remove all shares or disable the SMB server service if a README-required share, application or domain dependency exists.

**✅ Verification:** Repeat Get-Smb* commands and test normal share read/write and access denial with authorized sample users. Inspect whether a reboot is pending after SMB1 feature changes.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Restore **only recorded original** signing and feature settings if a required client breaks. Re-enabling SMB1 is a last-resort legacy compatibility measure, not a routine scoring workaround. For an accidentally deleted share, restore its original name/path, share ACL **and NTFS ACL** from backup; recreating the share alone may not restore access.

**Sources:** [Microsoft SMB signing overview](https://learn.microsoft.com/en-us/windows-server/storage/file-server/smb-signing-overview) and [Set-SmbServerConfiguration](https://learn.microsoft.com/en-us/powershell/module/smbshare/set-smbserverconfiguration).

<a id="research-report-expansion-w-r6--rdp-remote-registry-and-additional-service-checks"></a>
### 🛡️ RDP, Remote Registry and additional service checks

- [ ] **🎯 DO THIS — 🛡️ RDP, Remote Registry and additional service checks**

> [!NOTE]
> **ℹ️ Note:**
> **📚 Evidence:** Community/vendor-backed. A remote-management service is not automatically unauthorized; inspect the README and device role first.

**⭐ EASIEST WAY — Click through the GUI:** **Settings → System → Remote Desktop** (Windows 11; similar location on Windows 10); **Win + R → services.msc → Remote Registry**. Use **System Properties → Remote** and **Select Users** to inspect Remote Assistance/RDP access where available.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Get-Service -Name RemoteRegistry,TermService -ErrorAction SilentlyContinue | Select-Object Name,Status,StartType
> Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -ErrorAction SilentlyContinue
> Get-LocalGroupMember -Group 'Remote Desktop Users' -ErrorAction SilentlyContinue
> ~~~
>
fDenyTSConnections = **1** generally denies RDP; 0 generally allows RDP, subject to service/GPO/firewall controls. **Always record the original state**.

**Fix only if expressly unneeded/unauthorized:**

~~~powershell
Stop-Service -Name RemoteRegistry -ErrorAction Stop
Set-Service -Name RemoteRegistry -StartupType Disabled
~~~

For RDP, prefer the Remote Desktop GUI to disable an unauthorized listener. Do not lock yourself out of required remote access.

**✅ Verification:** Repeat the status/registry checks. Test RDP from an approved client **when required**, or confirm that it is unreachable if prohibited.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Restore the exact recorded Remote Registry startup type and RDP setting/allowed groups/firewall rules using authorized console access. A blanket **Remote Desktop off** recommendation is inappropriate for a required administration session.

<a id="research-report-expansion-w-r7--installed-software-scheduled-tasks-persistence-and-evidence"></a>
### 📦 Installed software, scheduled tasks, persistence and evidence

- [ ] **🎯 DO THIS — 📦 Installed software, scheduled tasks, persistence and evidence**

> [!NOTE]
> **ℹ️ Note:**
> **📚 Evidence:** Community. Common checks include Run/RunOnce, scheduled tasks, suspect services, executable signatures, installed apps and portable tools.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → appwiz.cpl**, **Task Manager → Startup apps**, **Win + R → taskschd.msc**, and **services.msc**. Inspect the exact executable and task action before disabling.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Get-Package | Select-Object Name,Version,ProviderName | Sort-Object Name
> Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
> Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
> Get-ScheduledTask | Select-Object TaskPath,TaskName,State
> Get-CimInstance Win32_Service | Select-Object Name,StartName,State,PathName
> ~~~
>
**Preserve a discovered file's metadata and hash (replace sample path):**

~~~powershell
Get-Item -LiteralPath 'C:\Users\Example\Documents\suspect.exe' | Select-Object FullName,Length,LastWriteTime
Get-FileHash -LiteralPath 'C:\Users\Example\Documents\suspect.exe' -Algorithm SHA256
Get-AuthenticodeSignature -LiteralPath 'C:\Users\Example\Documents\suspect.exe' | Select-Object Status,SignerCertificate
~~~

**🛠️ Fix:** After forensic answers are saved and the exact task/service/app is confirmed unauthorized, **disable one item at a time** using its GUI. Do not run a suspect task to investigate it, delete all registry Run entries, or purge all software matching a broad keyword.

**✅ Verify:** Recheck the same item and required applications. If persistence returns, investigate its owning process and launch mechanism; do not guess at an unrelated service.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Re-enable that exact task/service or restore its recorded registry entry. Uninstalling software can delete app data—restore both product **and configuration** if a required application was accidentally removed.

<a id="research-report-expansion-w-r8--uac-advanced-audit-policy-and-source-evidence"></a>
### 🔎 UAC, advanced audit policy and source evidence

- [ ] **🎯 DO THIS — 🔎 UAC, advanced audit policy and source evidence**

> [!NOTE]
> **ℹ️ Note:**
> **📚 Evidence:** Community/vendor-backed. These controls affect security event records, privilege prompts and visibility during investigations.

**⭐ EASIEST WAY — Click through the GUI:** Search **Change User Account Control settings**, then **Win + R → secpol.msc → Local Policies → Security Options** for detailed UAC settings. Review **Advanced Audit Policy Configuration** for account logon, account management, logon/logoff, policy change, privilege use and object access. On a domain-joined device inspect effective GPO.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ~~~powershell
> Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' | Select-Object EnableLUA,ConsentPromptBehaviorAdmin,PromptOnSecureDesktop
> auditpol /get /category:*
> gpresult /r /scope computer
> ~~~
>
**🛠️ Fix:** Apply only the UAC/audit subcategory explicitly required by the image or a vendor-recommended baseline compatible with installed software. A useful example **when the README specifies successful and failed logon events** is:

~~~cmd
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
~~~

**✅ Verification:** Repeat auditpol and review recent **Event Viewer → Security** entries with correct timestamp/user context. A 4688 process-create event requires process-creation auditing; the absence of an event is not proof nothing ran.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Record original auditpol subcategory status *before* changes and restore the exact previous Success/Failure state, instead of enabling or disabling all categories blindly. UAC changes may require restarting a process/reboot; preserve a rollback path.

---

<a id="stage-5"></a>
## Part 5 — Advanced Policies and Full Recovery Reference

> [!NOTE]
> 🧰 **Advanced reference:** Use these targeted procedures when the scenario calls for deeper investigation.


Use for detailed troubleshooting, PowerShell commands, audit events, effective policy and rollback.

### 19. Manual verification, recovery and missing investigation steps

#### 19.1 Record a recoverable Windows baseline

- [ ] **🎯 DO THIS — 19.1 Record a recoverable Windows baseline**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Save the original configuration before changing a table of settings.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** A screenshot of a target value is not a backup of the old value. Account deletion, password resets and registry merges have different recovery limits.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Use an authorized administrator at the VM console. Follow round rules on snapshots. Backups can contain sensitive policy and account information; keep them local and private.

**⭐ EASIEST WAY — Click through the GUI:** Open File Explorer, create `C:\CP-Backups`, then use **Properties → Security → Advanced** to restrict access to Administrators and SYSTEM. Do not remove access from your current administrator. Open `secpol.msc` and use **Action → Export Policy**; in `wf.msc`, right-click the root and choose **Export Policy**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
**✅ Check it worked:** Open each export as text where applicable and verify it is nonempty. Do not assume a CSV can recreate a deleted user with its old SID.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Prefer the individual setting's recorded value. A whole security-policy restore affects many settings:

```powershell
secedit /configure /db C:\CP-Backups\restore.sdb /cfg C:\CP-Backups\security-before.inf /areas SECURITYPOLICY USER_RIGHTS
```

Only use this after reviewing the backup and scope. For an audit-only restore:

```powershell
auditpol /restore /file:C:\CP-Backups\audit-before.csv
```

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Domain policy can override local changes. Password resets cannot recover the previous password and may make EFS files or stored credentials inaccessible. Preserve evidence before resets.

#### 19.2 Apply account and privileged-group table entries safely

- [ ] **🎯 DO THIS — 19.2 Apply account and privileged-group table entries safely**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Reconcile each account and each powerful group with the README.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Names alone do not reveal service-account dependencies, nested memberships or renamed built-in accounts.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Run `whoami /user` and keep a second tested administrator. Review the account's home directory, running services and scheduled tasks. On a Domain Controller use the Server AD procedure, not local-user commands.

**⭐ EASIEST WAY — Click through the GUI:** `lusrmgr.msc` → **Users** → double-click the exact account → **Member Of**. Compare every membership with section 2.5. For a confirmed unauthorized account, first tick **Account is disabled**. In **Groups**, open each powerful group individually, select the incorrect member and click **Remove → Apply**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **↩️ Undo:** `Enable-LocalUser -Name mallory` restores a mistakenly disabled account. `Add-LocalGroupMember -Group 'Backup Operators' -Member mallory` restores only a recorded membership. Deleted accounts need proper account/data recovery; creating the same name generates a different SID.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Do not disable every built-in account without checking its purpose. `PasswordExpires` from `Get-LocalUser` is a date or empty value, not simply a true/false policy flag. Service identities may have managed password behavior.

#### 19.3 Work through password, rights and security-option tables

- [ ] **🎯 DO THIS — 19.3 Work through password, rights and security-option tables**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Change each table row deliberately and check the effective policy.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** User rights are privileges, not ordinary group memberships. A **Deny** entry takes precedence over an allow entry. Compatibility-sensitive policies can break file sharing or authentication.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Export policy using 19.1. On domain members inspect policy precedence first:

```powershell
gpresult /h C:\CP-Backups\gpresult-before.html
net accounts
```

Open the HTML locally; note the winning GPO. `net accounts` reports local account limits; domain account policy is separate.

**⭐ EASIEST WAY — Click through the GUI:** Press **Win + R → secpol.msc**. For each password/lockout row open **Account Policies → Password Policy / Account Lockout Policy**; double-click the exact row, record its current value, enter the README value, and click **Apply → OK**. Set lockout threshold first, then its duration/window. Under **Local Policies → User Rights Assignment**, open one right, record every principal, and use **Add User or Group / Remove** only for that right. Under **Security Options**, open each named setting and choose its explicit option. Record units such as seconds, minutes or days.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> net accounts /uniquepw:24 /maxpwage:90 /minpwage:1 /minpwlen:12
> ```
>
History prevents immediate reuse, maximum age requires periodic changes, minimum age limits rapid cycling and minimum length rejects short future passwords. These settings do not retroactively strengthen existing passwords.

**✅ Check it worked:** Repeat `net accounts`, export the policy again, and test one noncritical authorized account from a separate session. Confirm legitimate network access still works. Do not intentionally lock out your administrator to test the threshold.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Restore the individual row's recorded principals/value. Use the reviewed policy backup only when necessary. A refresh that reverses your edit means the owning GPO needs correction by its authorized administrator.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** The tables are workstation starting points, not universal server baselines. Preserve service SIDs and required operators. Mandatory signing, NTLM restrictions, cached-logon settings and anonymous-access restrictions require client compatibility checks. Do not add your own admin account to a deny right.

#### 19.4 Audit selectively and investigate Windows events

- [ ] **🎯 DO THIS — 19.4 Audit selectively and investigate Windows events**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Record useful authentication, account and policy changes without blindly enabling every audit category.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** High-volume object/process auditing can fill logs quickly. A missing event does not establish that an action never occurred; the policy may not have recorded it.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Back up audit policy and export relevant logs before remediation. Do not clear logs or disable Windows Event Log.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → eventvwr.msc → Windows Logs → Security → Filter Current Log**. Enter `4624,4625,4720,4732,1102`. Use **Save All Events As** for an EVTX copy. In `secpol.msc` use **Advanced Audit Policy Configuration → System Audit Policies** to configure the required subcategory, not both competing legacy and advanced settings.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> auditpol /get /category:*
> Get-WinEvent -FilterHashtable @{LogName='Security';Id=4624,4625,4720,4732,1102;StartTime=(Get-Date).AddDays(-2)} -MaxEvents 100 | Format-List TimeCreated,Id,Message
> ```
>
4624 is a successful logon; 4625 is failure; 4720 creates a user; 4732 adds a member to a local security group; 1102 records clearing the Security audit log. Read the target account, source address and logon type, not just the event ID.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> auditpol /set /subcategory:"Logon" /success:enable /failure:enable
> ```
>
Use `auditpol /list /subcategory:*` to find localized names. Process creation events need their own policy; command-line capture may expose secrets.

**✅ Check it worked:** `auditpol /get /subcategory:"Logon"` should show Success and Failure. Test a normal permitted login and inspect its event. Confirm log retention and maximum size in **Security → Properties**.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Restore the original subcategory or the audit CSV from 19.1. Preserve existing events; reverting policy does not require deleting logs.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Timestamp display follows local time. Correlate with timezone and system clock before inferring event order.

#### 19.5 Firewall rule inspection and required ports

- [ ] **🎯 DO THIS — 19.5 Firewall rule inspection and required ports**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Enable host firewall profiles and permit only the required application traffic.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** An enabled firewall can still allow an unwanted inbound rule. A listener on localhost is different from a listener on every address.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Export the firewall, identify the current profile, service executable, protocol, local port and authorized source networks. Never reset the firewall as a first step.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → wf.msc**. Open **Windows Defender Firewall Properties**; enable the appropriate Domain, Private and Public profiles, normally block unmatched inbound and allow outbound. Under **Inbound Rules**, double-click a candidate rule and inspect **Programs and Services**, **Protocols and Ports**, **Scope**, **Advanced** and **General**. Disable only a confirmed unauthorized rule. For a required service, **New Rule → Custom**, scope it to the program/port and authorized remote IPs, choose the appropriate profiles, and give it a descriptive name.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **↩️ Undo:** Remove only the rule you created with `Remove-NetFirewallRule -Name 'CP-Required-HTTPS'`, or restore a disabled rule by its recorded Name. Whole-policy import (`netsh advfirewall import ...`) replaces policy and can remove later valid changes; review first and use the console.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Group Policy rules can override local behavior. Avoid broad `Any` source/port exceptions and disabling the whole firewall to troubleshoot one service.

#### 19.6 Defender, updates and application health

- [ ] **🎯 DO THIS — 19.6 Defender, updates and application health**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Check protection state, pending security updates and required applications.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** An installed antivirus product may be passive or have exclusions that defeat protection. Scan/remediation can modify evidence.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Answer relevant forensics questions. Record third-party antivirus, exclusions, update policy and required application versions. Windows 10's ordinary support ended in October 2025; check the image's edition/support arrangement instead of assuming all versions receive regular updates.

**⭐ EASIEST WAY — Click through the GUI:** **Windows Security → Virus & threat protection → Manage settings**; inspect real-time/cloud protection, exclusions and **Protection history**. Do not remove an exclusion merely because it exists; verify its purpose. Open **Settings → Windows Update → Update history** and each required application's **Help → About** page. On Server use its corresponding checklist.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **↩️ Undo:** Restore only a wrongly changed preference using its recorded value. Do not restore quarantined malware to the live image merely to recover points. If an update breaks a required function, investigate the exact update and supported recovery option; do not disable future updates wholesale.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Tamper Protection or organizational policy may reject PowerShell edits. Do not weaken those controls to force a setting. Updates can require more than one restart; do not interrupt an in-progress update to follow a rigid one-reboot rule.

#### 19.7 SMB share permissions and NTFS permissions

- [ ] **🎯 DO THIS — 19.7 SMB share permissions and NTFS permissions**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Validate both the network share ACL and the underlying NTFS ACL.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Effective network access is limited by both layers; denying a broad group can unintentionally block administrators too.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Record share name, path, description and authorized readers/writers. Preserve forensic files and original ACLs. Do not remove system shares or use recursive permission resets on Windows directories.

**⭐ EASIEST WAY — Click through the GUI:** `fsmgmt.msc` → **Shares** → required share **Properties → Share Permissions**. Then open its folder **Properties → Security → Advanced**; inspect inheritance and **Effective Access** for a representative user. Remove only the unintended grant; keep application identities.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
> ```powershell
> Grant-SmbShareAccess -Name Public -AccountName StaffReaders -AccessRight Read -Force
> ```
>
Then use the Security GUI to grant the matching folder read access and remove only confirmed excess write access. Grant authorized access before revoking an existing broad entry.

**✅ Check it worked:** Test reading and, where required, writing from a second machine as an ordinary authorized user. Test an unauthorized user separately. Administrator success does not prove ordinary users can connect.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** Restore the recorded share grants individually. For the saved ACL above use `icacls C:\Shares /restore C:\CP-Backups\public-acl.txt` after confirming the parent path. Do not recreate a deleted share from memory.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Share permissions do not protect local file access. Removing Everyone without providing the required replacement can break a legitimate share.

#### 19.8 Scheduled tasks, startup, registry and suspicious executables

- [ ] **🎯 DO THIS — 19.8 Scheduled tasks, startup, registry and suspicious executables**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Trace each suspicious process back to the mechanism that launches it.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Killing a process without addressing persistence lets it return. Encoded PowerShell, Python and unusual paths are leads, not proof of malware.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Record the task action, trigger, account, executable path, command line, signature and hash. Export the task/registry key. Never launch a suspicious executable to identify it.

**⭐ EASIEST WAY — Click through the GUI:** `taskschd.msc` → **Task Scheduler Library** → task → inspect **Actions**, **Triggers**, **General**, **History**; right-click **Export** to save XML, then **Disable** for reversible containment after evidence collection. **Task Manager → Startup apps → Disable** applies only to that entry. For registry changes, open `regedit`, select the exact key, choose **File → Export → Selected branch**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **↩️ Undo:** Re-enable the task with `Enable-ScheduledTask -TaskName 'BadTask'` only if it was misidentified. Restore a deleted task from its XML using Task Scheduler **Import Task**, checking the principal and credentials. A registry import merges values; restore the specific value when possible.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** Stop at evidence collection if a forensic question remains unresolved. `sc.exe delete`, `Unregister-ScheduledTask` and `Remove-Item` are destructive; use them only after positive identification and recovery planning. Preserve suspicious scripts as text, never execute decoded payloads.

#### 19.9 Final troubleshooting decision path

- [ ] **🎯 DO THIS — 19.9 Final troubleshooting decision path**

> [!NOTE]
> **ℹ️ Note:**
> **🎯 What:** Verify authentication, networking, security state and required functions after changes.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** Scoring can lag or fail to update when DNS, time, networking or a required service breaks.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Record the last successful test and last change. Use the VM console if remote access fails.

**⭐ EASIEST WAY — Click through the GUI:** Check the Scoring Report timestamp, Services, Event Viewer **System/Application**, and the application's own error page. Do not change the scoring agent or its files.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
>
>
**✅ Check it worked:** Test an ordinary user login, admin elevation, required website/share/remote session, and report freshness. Check pending restarts and save final forensics answers.

> [!WARNING]
> **ℹ️ Note:**
> **↩️ Undo:** If a proposed repair fails, return that repair to its recorded starting state before trying another theory.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** An error message is evidence. Record it exactly and investigate its source rather than hiding it with broad `-ErrorAction SilentlyContinue`.


---


### 20. Complete PowerShell basics — included in this Windows checklist

#### 20.0 PowerShell command and terminal primer

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
> **ℹ️ Note:**
> **🎯 What:** Learn how to inspect PowerShell output and edit a harmless file before modifying security settings.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why it matters:** PowerShell pipelines pass objects, not just printed text. Formatting is for display; it should normally come last in a pipeline.

> [!CAUTION]
> **ℹ️ Note:**
> **🛑 Before changing anything:** Use ordinary Windows PowerShell for this exercise; administrator rights are not needed. Most handbook examples target Windows PowerShell 5.1 on Windows. A module absent from PowerShell 7 is not proof the Windows role is missing.

**⭐ EASIEST WAY — Click through the GUI:** **Start → Windows PowerShell**. Use File Explorer to view your personal profile folder. Run as administrator only for procedures that require it; do not approve an unknown script merely because it requests elevation.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **↩️ Undo:**

```powershell
Copy-Item -LiteralPath "$practiceFile.before" -Destination $practiceFile
Get-Content -LiteralPath $practiceFile
```

Expected: `original value`. This file restore does not model account/password recovery; those have different limits.

> [!CAUTION]
> **ℹ️ Note:**
> **⚠️ Warnings:** `-WhatIf` exists only on commands that support it, and its preview does not test downstream dependencies. Use `Get-Help COMMAND -Full` to check support. Use `sc.exe` for Service Control; `sc` in Windows PowerShell is an alias for Set-Content. Never use `Invoke-Expression` to inspect a suspicious string.


---


### 21. Advanced Windows investigations — included in this checklist


> **Use after:** [Windows workstation checklist](windows-10-11.md) or [Windows Server checklist](windows-server.md). These are **manual procedures**—not a script. Commands below are examples for an authorized practice image. **Read its README and answer/preserve forensics questions first.**

This supplement draws topic ideas from public CyberPatriot checklists and verifies key methods with Microsoft documentation. A generic checklist cannot tell you which accounts, shares, or services are authorized on *your* image.

#### 21.1 Find the setting that actually applies (GPO versus local policy)

- [ ] **🎯 DO THIS —** Reviewed effective configuration and policy source.

> [!NOTE]
> **ℹ️ Note:**
> **💡 Why:** A value changed in \`secpol.msc\` or the registry can be replaced by a domain Group Policy. On a Domain Controller, editing an arbitrary local policy is not a substitute for checking domain-level policy.

**⭐ EASIEST WAY — Click through the GUI:** Press **Win + R** → \`rsop.msc\` (if available); review **Computer Configuration**. On domain-joined systems use **Group Policy Management** (\`gpmc.msc\`) **only if installed and authorized**. Do not disable a linked GPO merely to fix one setting.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **🧠 Interpretation:** \`PartOfDomain = True\` means domain policies may apply. The report's **Applied Group Policy Objects** and **Denied GPOs** help explain conflicts; a local-only or unconfigured policy may show less information. \`gpresult\` can report no RSoP data for the target scope—investigate context rather than assume a missing policy is a security failure.

**✅ Verification:** Compare the effective policy with the README and with the relevant **Local Security Policy** or **Group Policy** editor. If a setting changes after refresh, identify its **winning policy** before editing it.

**Recovery:** Revert the *specific* policy change at its actual policy source. Keep an export/screenshot of the original setting. Changing a domain GPO can affect many machines.

#### 21.2 Correlate suspicious services with their executable files

- [ ] **🎯 DO THIS —** Compared service names, binary paths, and required roles.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → services.msc** → double-click a service → note **Service name**, **Path to executable**, **Log On**, **Dependencies**. Do not stop it yet.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **What to look for:** Unexpected user-profile or temporary-directory paths, impersonated names, newly introduced binaries, unusual service accounts, or services inconsistent with the README. Some legitimate software uses nonstandard locations; **a strange path is a clue, not proof**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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

#### 21.3 Investigate events: service installation, login attempts and process creation

- [ ] **🎯 DO THIS —** Checked available logs without clearing them.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → eventvwr.msc** → **Windows Logs → System** or **Security** → **Filter Current Log**. Record timestamps with timezone, event IDs, provider, and the full message.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **🧠 Interpretation:** Errors such as **No events were found** do not prove an action never happened. Logging, retention, permissions, and audit policy affect visibility. To check the present policy:

~~~powershell
auditpol /get /category:*
~~~

**✅ Verification:** Tie a suspicious event to an account, timestamp, executable and known system change. Avoid relying on one isolated log entry.

**Recovery:** If auditing was intentionally changed, restore only its original documented configuration; **never clear logs** to “clean” the machine.

#### 21.4 Inspect persistence without executing unknown files

- [ ] **🎯 DO THIS —** Reviewed login-start items and task actions.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → taskschd.msc** → **Task Scheduler Library**; inspect **Triggers**, **Actions**, **Author** and **History**. Open **Task Manager → Startup apps** for login items.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **🧠 Interpretation:** A task with an obscure name or PowerShell arguments warrants inspection, but scheduled updates and enterprise management agents are legitimate too. Record the exact executable and arguments before taking action.

**✅ Verification:** Correlate task path, binary signature and Event Viewer findings. Do not run the task to see what happens.

**Recovery:** For a confirmed unauthorized task, prefer **Disable** before **Delete** (after preserving evidence). Record the original trigger and action; test whether required applications still work.

#### 21.5 SMB share + NTFS access: check both layers

- [ ] **🎯 DO THIS —** Checked authorized shares and effective paths.

**⭐ EASIEST WAY — Click through the GUI:** **Win + R → fsmgmt.msc** (when available) → **Shares**. Review share name, local path and active sessions. In File Explorer: folder → **Properties → Sharing / Security**.

> [!NOTE]
> **🔁 ALTERNATE METHOD — PowerShell/command line.** Use only if you prefer it or the GUI is unavailable; this is **not a second required task**.
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
> **ℹ️ Note:**
> **🧠 Interpretation:** Share permissions and NTFS permissions both matter. Hidden administrative shares (for example \`C$\`) are not by themselves proof of malware. A broad \`Everyone\` share right may be constrained by NTFS, but it still needs review.

**✅ Verification:** Test with a **legitimate non-admin** account that should read or write, and a separate account that should be denied. Protect required shared folders and server roles.

**Recovery:** Save both ACL layers before changing. Reverse only the particular group entry or share configuration changed; never recursively reset \`C:\Windows\` permissions.

#### 21.6 Firewall rules that look open—but aren't applicable

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
> **ℹ️ Note:**
> **🧠 Interpretation:** An allowed rule is not necessarily reachable: scope, profile, address filters, enabled state, underlying service and other policy conditions matter. A listening port may serve an explicitly required role.

**✅ Verification:** From an authorized client, test required application connectivity after any **narrow** firewall change. Avoid blanket removal of inbound rules.

#### 21.7 Final verification checklist

- [ ] **🎯 DO THIS —** Read and preserved forensic questions.
- [ ] **🎯 DO THIS —** Confirmed whether the machine is standalone, domain-joined or a Domain Controller.
- [ ] **🎯 DO THIS —** Found the **effective** source for changed policies.
- [ ] **🎯 DO THIS —** Correlated unknown services with executable paths and relevant logs.
- [ ] **🎯 DO THIS —** Reviewed scheduled tasks/startup entries without executing unknown payloads.
- [ ] **🎯 DO THIS —** Confirmed required shares, services and firewall connectivity remain operational.
- [ ] **🎯 DO THIS —** Recorded any modification, verification result and rollback information.

#### 21.8 Sources and further reading

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


Retest authorized login, required applications, services and the scoring report before finishing.

### 18. Final checks

- [ ] **🎯 DO THIS —** Critical services still running (`services.msc`)
- [ ] **🎯 DO THIS —** You can still log in and open an admin PowerShell
- [ ] **🎯 DO THIS —** Scoring Report shows **no penalties**
- [ ] **🎯 DO THIS —** Forensics answers saved
- [ ] **🎯 DO THIS —** Final snapshot
- [ ] **🎯 DO THIS —** Reboot **once** at the end only if updates or Windows features (9.1) need it, then check the Scoring Report again

