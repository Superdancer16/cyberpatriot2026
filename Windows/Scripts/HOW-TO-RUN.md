# 🪟 Windows 10/11 script — beginner's step-by-step guide

**Never used PowerShell before? Start here.** Follow the numbered steps in order. This guide is for the [Windows 10/11 workstation script](windows-10-11.ps1) and **not** the [Windows Server script](../../Server/Scripts/HOW-TO-RUN.md).

> [!IMPORTANT]
> **Run everything INSIDE your Windows 10/11 virtual machine (VM), never on your own computer.** A VM is the practice/scoring Windows computer opened in VMware or similar software. The VM's desktop **README** and the current competition rules decide what is allowed. Do not run/download a script if the rules prohibit it.
>
> **Start with Audit.** `-Mode Audit` inspects settings and writes report files; it does not apply hardening fixes. **Apply changes the system** and requires carefully filling in a JSON configuration file. It is fine to stop after the audit and use the [manual checklist](MANUAL-TASKS.md).

## What the words mean

| Word on this page | Plain-English meaning |
|---|---|
| **VM** | The Windows computer inside your virtualization program, separate from your personal computer |
| **PowerShell** | A window where you type commands to Windows |
| **Script** | A saved file of commands; this one is named `windows-10-11.ps1` |
| **Audit** | Look at current settings and save a report without applying hardening fixes |
| **Apply** | Run actions that may change accounts, security settings, services, or software |
| **JSON config** | A text file named `image-config.json` telling the script which *specific* changes and protections are intended |
| **Administrator** | A Windows account/window allowed to manage system settings |

**How to type commands:** Copy **one command at a time** from the gray code blocks, paste into PowerShell, and press **Enter**. Do **not** type the word `powershell` or the `PS C:\...>` prompt you might see in the window.

## ✅ Part A — First run: download, check, and AUDIT (no hardening changes)

### Step 1 — Open the correct Windows computer

1. Open your Windows **10 or 11 VM** and sign into its assigned account.
2. Confirm you are looking at the **VM desktop**, not your personal PC desktop.
3. Read the **README file on the VM desktop**. Write down which users, programs, services, and remote-access functions must stay working.
4. Read and answer any forensic questions **before modifying or removing evidence**. Note the starting score if the VM has a Scoring Report.
5. Keep console/admin access available. Create a practice snapshot **only if the exercise rules permit it**.

### Step 2 — Download the correct script inside the VM

1. In the **VM**, open **Edge** or another installed browser. You do **not** need a GitHub account for this public repository.
2. Open this exact page: [windows-10-11.ps1 on GitHub](https://github.com/Superdancer16/cyberpatriot2026/blob/main/Windows/Scripts/windows-10-11.ps1).
3. Click **Raw** (above the code). You should see **plain text beginning with `#requires -Version 5.1`**, not a regular webpage.
4. Save the raw file: press **Ctrl+S**, choose **Downloads**, and name it **`windows-10-11.ps1`**. If you see **Save as type**, select **All files**. Alternatively, right-click **Raw** and use **Save link as** if the browser offers it.
5. If you cannot find the download, press **Ctrl+J** in your browser to open its Downloads list, then use **Show in folder**. In the VM, open **File Explorer → Downloads**. Turn on filename extensions:
   - Windows 11: **View → Show → File name extensions**
   - Windows 10: **View → File name extensions**
6. Confirm the exact name is **`windows-10-11.ps1`** — not `windows-10-11.ps1.txt`, `.html`, or a webpage.

> [!CAUTION]
> **Do not rename an HTML page to `.ps1`.** If you downloaded a webpage, return to GitHub and save the **Raw** file instead. Never enter your personal GitHub password into a competition VM; because this repo is public, signing in isn't needed.

### Step 3 — Open the correct PowerShell window

1. Still **inside the VM**, click **Start**.
2. Type **Windows PowerShell**. Select **Windows PowerShell** (the built-in Windows PowerShell 5.1), not an unrelated terminal or PowerShell 7 installation.
3. Right-click it → **Run as administrator** → click **Yes** when Windows asks.
4. A blue or dark command window should appear. It may begin with `PS C:\Windows\system32>`. That is normal.
5. Make sure you are using the **same Windows user account** that downloaded the file. If you used a different administrator account, its Downloads folder may be different.

### Step 4 — Point PowerShell at Downloads

Type this **one line** and press Enter:

~~~powershell
cd "$env:USERPROFILE\Downloads"
~~~

Check where PowerShell is now:

~~~powershell
Get-Location
~~~

**Expected:** A path ending in `\Downloads`. Next, check whether the saved file exists:

~~~powershell
Get-Item .\windows-10-11.ps1
~~~

**Expected:** Information about `windows-10-11.ps1` (name, size, date). Verify it is script text:

~~~powershell
Get-Content .\windows-10-11.ps1 -TotalCount 1
~~~

**Expected first line:** `#requires -Version 5.1`. If you get **Cannot find path**, return to Step 2. If the first line looks like `<!DOCTYPE html>` or `<html>`, re-download the **Raw** file.

### Step 5 — Run the FIRST and safest command: AUDIT

Copy this **exact line** (you are still in Downloads):

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Audit
~~~

Press **Enter**. This launches the script in its **Audit** mode. It will inspect Windows settings and write audit/log files, but it **does not apply the configured hardening changes**. The command's execution-policy option applies to this child PowerShell process; it is **not** permission to trust an unreviewed script.

**What success looks like:** You should see an audit/report path, typically under your Windows account's Documents folder. Some individual inspections may say **Unavailable** if a Windows feature is missing; that is a finding, not a reason to run Apply immediately.

### Step 6 — Open your audit report

In the same PowerShell window:

~~~powershell
explorer.exe "$env:USERPROFILE\Documents\WindowsSecurityWork"
~~~

File Explorer opens the report folder. Look for the newest **`audit-...txt`** file (the numbers are its date/time); double-click to read it.

Record the issues you recognize, but **compare them with the VM README**. For example, an unfamiliar service might be required. Audit can also write a change log; a log existing **does not mean any security fixes were applied**.

**🎉 You have successfully run the script's audit. You may stop here.** Open [MANUAL-TASKS.md](MANUAL-TASKS.md) or the [full Windows handbook](../windows-10-11.md) to inspect any findings manually.

---

## ⚠️ Part B — Only after Audit: configure and APPLY changes

**Apply is not a beginner one-click fix.** It can disable services, change firewall/security settings, create or modify users, and affect required programs. Ask a coach or experienced teammate to review your planned changes if you do not know what the VM README requires.

### Step 7 — Create the configuration file (once)

In the **same Downloads PowerShell window**, run:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -InitConfig -Config ".\image-config.json"
~~~

**Expected:** A message saying it created `image-config.json`. The script **refuses to overwrite** a file of that name; if it already exists, open the existing file instead of deleting your work.

Open it in Notepad:

~~~powershell
notepad .\image-config.json
~~~

If Windows asks to create a missing file, click **No** and return to the previous command to find out why it did not generate the template.

### Step 8 — Fill in the actual VM information

The file has lines such as these (illustrations only; **edit the existing file**, do not paste a second copy of these keys):

~~~json
"ConfirmedReadme": false,
"AuthorizedAdmins": [],
"AuthorizedUsers": [],
"RequiredServices": [],
"ForensicsComplete": false
~~~

**What the symbols mean:** `[]` = list of names; `false` = off/not yet confirmed; `true` = on/confirmed. JSON needs **double quotes** around names and **commas** between list items. It must not contain comments.

Use the **actual VM desktop README** to fill in:

1. **`AuthorizedAdmins`:** every user the README authorizes as an administrator (required; cannot be empty).
2. **`AuthorizedUsers`:** normal authorized users.
3. **`RequiredServices`, `RequiredSoftware`, `RequiredShares`, `RequiredPorts`:** things that must keep working (especially remote access).
4. **Other action lists:** only **exact, verified** users, programs, tasks, services, and files you intentionally want changed. Leave unknown removals empty.
5. **`ForensicsComplete`:** change to `true` **only after** saving the required answers and evidence.
6. **`ConfirmedReadme`:** change to `true` **last**, only after verifying the *whole file* against the README.

> [!WARNING]
> The generated workstation template already contains **some enabled security actions** and a short default `DisableServices` list. **It is not a no-op template.** Review **every** field, especially `Security` and `DisableServices`, before Apply. Do **not** just fill in an admin name and flip `ConfirmedReadme` to `true`. Do not copy example usernames, passwords, or settings from another image.

In Notepad, press **Ctrl+S**, then close it.


#### Step 8A — Find exact Windows names (read-only checks)

The **VM desktop README**, not a generic checklist, determines which accounts and services are authorized. Use these commands in the VM's elevated PowerShell window to verify exact names. Run them one at a time:

~~~powershell
whoami
Get-LocalUser | Select-Object Name,Enabled
Get-LocalGroupMember -Group Administrators
Get-Service | Select-Object Name,DisplayName,Status | Sort-Object Name
Get-SmbShare | Select-Object Name,Path
Get-NetTCPConnection -State Listen | Select-Object LocalPort,OwningProcess
~~~

- `Name` in `Get-Service` (for example `Spooler` or `TermService`) is a **service name**; `DisplayName` (e.g. **Print Spooler**) is *not* the right value for `RequiredServices` or `DisableServices`.
- `Get-LocalUser` lists accounts, but **does not tell you who the README authorizes**. Compare every username to the desktop README.
- `Get-SmbShare` shows local share **names**, not just folder paths; do not remove system shares.
- A listening port is **not automatically approved or required**. Record only what the README and required applications demand.
- Installed software can be checked in **Settings → Apps → Installed apps** or **Control Panel → Programs and Features**. `UpdatePrograms` and `RemovePrograms` require **exact winget package IDs**, not friendly titles.

#### Step 8B — Full top-level JSON field reference

**JSON types:** `["alice", "bob"]` is a string list; `{}` is an object; `true`/`false` are switches. Every array listed below should be `[]` until you have a specific, approved target. Do **not** put commands, passwords, or explanations inside JSON.

| Field | What to enter — common exact structure |
|---|---|
| `ConfirmedReadme` | `false` until every intended change has been compared against the **current VM README**; set `true` last. |
| `ForensicsComplete` | `false` until required questions and evidence are safely preserved; set `true` only afterward. |
| `AuthorizedAdmins` | **Exact authorized admin account names**, e.g. `["labadmin"]`. Required and may not be empty when applying. |
| `AuthorizedUsers` | **Exact authorized ordinary usernames**, e.g. `["labstudent", "labviewer"]`. Do not use display names or add an unapproved user. |
| `RequiredServices` | Exact service names, e.g. `["Spooler", "TermService"]` **only when printing/RDP are required**. Protects them from configured service disabling. |
| `RequiredSoftware` | Names of *required installed applications*, e.g. `["Mozilla Firefox"]`. Compare the installed-app display name. If you later use a winget remove ID, separately verify it is not required and list/protect the exact ID as appropriate. |
| `RequiredShares` | Exact required SMB share names, e.g. `["LabShare"]`, not paths like `C:\Share`. |
| `RequiredPorts` | **Port numbers as strings**, e.g. `["3389", "80"]` when RDP/web access is actually required. Here the script compares them to firewall-rule port filters; **this field does not open ports or prove connectivity**. |
| `ScanPaths` | Extra folders for **candidate-file discovery** only, e.g. `["C:\\Users\\Public"]`. Use double backslashes inside JSON Windows paths. |
| `NewUsers` | Missing, expressly authorized local user names to create, e.g. `["labnewuser"]`. Must also appear in an authorized list; passwords are entered interactively. |
| `DisableUsers` | Verified unauthorized existing account names to **disable**, e.g. `["unapproveduser"]`; do not include current/authorized/built-in users. |
| `RemoveUsers` | Exact unauthorized local accounts to **delete**. Destructive and requires `-AllowRemovals`; home/profile contents are not automatically restored. |
| `DemoteAdmins` | Exact users who must remain accounts but **no longer be administrators**. Validate against the authorized-admin list. |
| `PasswordExpiresUsers` | Existing users whose `PasswordNeverExpires` flag needs clearing, e.g. `["labstudent"]`. This does **not** force a next-logon password reset. |
| `ResetPasswords` | Existing authorized users for an interactive password reset. The password **never goes into JSON**; `-Yes` skips password prompts. |
| `Groups` | An object of **group name → array of authorized usernames**, e.g. `{"LabReaders": ["labstudent"]}`. Creates missing group and adds existing users. |
| `RemoveGroupMembers` | Object of **existing group → users to remove**, e.g. `{"LabReaders": ["unapproveduser"]}`. Never blindly remove privileged or service-required members. |
| `PasswordPolicy` | Object of supported **numeric** settings, e.g. `{"MinimumPasswordLength": 12, "PasswordHistorySize": 5, "PasswordComplexity": 1}` only if the README requires them. Other supported keys: `MinimumPasswordAge`, `MaximumPasswordAge`, `ClearTextPassword`, `LockoutBadCount`, `LockoutDuration`, `ResetLockoutCount`. Values `PasswordComplexity` and `ClearTextPassword` must be **0 or 1**. |
| `RemoveUserRights` | Object of **security-right identifier → array of exact principals to remove**, e.g. `{"SeDebugPrivilege": ["unapproveduser"]}`. Supported: `SeSecurityPrivilege`, `SeTakeOwnershipPrivilege`, `SeDebugPrivilege`, `SeBackupPrivilege`, `SeRestorePrivilege`, `SeLoadDriverPrivilege`, `SeRemoteInteractiveLogonRight`. High-impact; leave `{}` unless inspected in `secpol.msc`. |
| `DisableServices` | Array of exact service **Names** to stop/disable. The generated script template includes `["RemoteRegistry","simptcp"]` by default: **review and change this**, not just the admin lists. In the teaching example this is deliberately `[]`. |
| `DisableFeatures` | Exact installed Windows optional-feature names (not a friendly label), e.g. `["SMB1Protocol"]` only after verifying it isn't required. May affect compatibility/restarts. |
| `DisableScheduledTasks` | Array of fully qualified task paths, e.g. `["\\LabTasks\\UnwantedTask"]` only for a confirmed unauthorized *non-Microsoft* task. |
| `DisableFirewallRules` | Exact internal **`Get-NetFirewallRule -Name`** value for an unnecessary inbound Allow rule. Do **not** use a display name, wildcard, or required port. |
| `AuditSubcategories` | Object of an exact `auditpol` subcategory → one of `"Success"`, `"Failure"`, `"SuccessAndFailure"`, e.g. `{"Logon": "SuccessAndFailure"}`, subject to OS language and effective GPO. |
| `RemoveStartupValues` | Array of objects with `Path` and `Name`: `[{"Path":"HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run","Name":"UnwantedEntry"}]`. Exact Run/RunOnce registry value; script restricts allowed paths. |
| `ClearIFEO` | Array of supported accessibility executable names, e.g. `["sethc.exe"]` only when an unwanted debugger override is verified. The script also accepts `utilman.exe`, `osk.exe`, `magnify.exe`, `narrator.exe`. |
| `RemoveShares` | Exact non-system SMB share names to remove. Destructive and requires `-AllowRemovals`; don't include required shares. |
| `RemoveShareAccess` | Array of `{"Share":"LabShare","Account":"unapproveduser"}` objects to remove a **specific SMB share permission**, not a file's NTFS permissions. Requires `-AllowRemovals`. |
| `RemoveDefenderExclusions` | Array of exact unwanted **path** exclusions shown by `Get-MpPreference`, e.g. a suspicious folder path; do not guess. |
| `RemoveDefenderExclusionProcesses` | Array of exact process-name/path exclusions to remove after checking their legitimate purpose. |
| `RemoveDefenderExclusionExtensions` | Array of exact Defender extension exclusions to remove, e.g. a verified unwanted `".exe"` exclusion. |
| `RemoveAppxPackages` | Exact installed **Microsoft Store package Names** (not friendly app titles or globs). Removals require `-AllowRemovals`; core packages are protected. |
| `RemovePrograms` | Array of exact installed **winget IDs** for expressly prohibited software, not the app's display name. Requires `-AllowRemovals`. |
| `UpdatePrograms` | Array of exact **winget IDs** to upgrade, e.g. `["Mozilla.Firefox"]` **only if winget lists that ID and the update is permitted**. |
| `RemoveFiles` | Array of exact full paths to confirmed prohibited **files**, e.g. `["C:\\Users\\Public\\Downloads\\unapproved.exe"]`. No folders/globs. Deletion may be irreversible and requires `-AllowRemovals`. |
| `Security` | A nested object of security switches and values, explained **one by one below**; the script requires this object. |

**Common shape examples (these are fragments, not complete JSON files):**

~~~json
"Groups": {"LabReaders": ["labstudent"]},
"RemoveStartupValues": [
  {"Path": "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", "Name": "UnwantedEntry"}
],
"RemoveShareAccess": [
  {"Share": "LabShare", "Account": "unapproveduser"}
],
"AuditSubcategories": {"Logon": "SuccessAndFailure"}
~~~

These latter three actions can modify the system. **Do not paste them just because the keys appear here.** Leave their arrays/objects empty unless the current README and your inspection require the exact change.

#### Step 8C — Every setting inside `Security`

All switches below live **inside `"Security": { ... }`**. Unless noted, values are **`true` or `false`**, and `true` requests the described action. Treat a setting as an **opt-in** after inspecting required functions; "common" does not mean universally safe.

| `Security` subkey | What `true` does / how to choose it |
|---|---|
| `Firewall` | Enable Windows Firewall profiles. Check actual required inbound rules and remote access. |
| `Defender` | Request Defender real-time/PUA protection. Confirm it is the required/active antivirus. |
| `DefenderSignatures` | Request Defender security-intelligence update; may need allowed network access. |
| `DefenderQuickScan` | Start a malware quick scan (may quarantine evidence); wait until forensics is preserved. |
| `SMBClientSigning` | Require SMB signing when acting as an SMB client; test required shares/legacy clients. |
| `SMBServerSigning` | Require SMB signing for hosted shares; test clients. |
| `RequireRdpNla` | Require Network Level Authentication for RDP; confirm RDP remains usable. |
| `EnableUAC` | Enable User Account Control prompts; may require restarting and testing admin elevation. |
| `RestrictAnonymous` | Restrict anonymous account/share enumeration; verify dependencies. |
| `DisableLMHash` | Disable storage of legacy LM password hashes. |
| `RequireNTLMv2` | Restrict legacy NTLM behavior; can break older clients/SMB authentication. |
| `ProtectPrintDrivers` | Require admin rights for Point-and-Print driver installs; verify printing. |
| `DisableNetBIOS` | Disable NetBIOS-over-TCP/IP on adapters; check legacy name resolution. |
| `CredentialAuditSuccess` | Enable successful Credential Validation auditing; logs more events. |
| `SmartScreen` | Request SmartScreen protection. |
| `DisableAutoPlay` | Disable automatic actions from removable-media autoplay. |
| `DisableLLMNR` | Disable Link-Local Multicast Name Resolution; check local network dependencies. |
| `DisableRemoteAssistance` | Disable **Remote Assistance** (not the same thing as Remote Desktop). |
| `DisableRDP` | Disable inbound Remote Desktop; **never enable this option if RDP is required**. |
| `DisableSMB1` | Disable legacy SMBv1 optional feature; test required old file-sharing clients. |
| `DisableWDigest` | Disable WDigest plaintext-credential caching. |
| `HideLastSignedIn` | Hide last signed-in username on the sign-in screen. |
| `DisableAdminEnumeration` | Stop Windows credential UI from enumerating admin accounts. |
| `AutomaticWindowsUpdates` | Configure Windows automatic-update policy; distinct from the `WindowsUpdate` action. |
| `RestrictBlankPasswordNetwork` | Block use of local blank-password accounts over the network. |
| `PowerShellLogging` | Enable PowerShell Script Block Logging; logs may include sensitive command text. |
| `LockScreenSeconds` | **Integer 60–86400 or `null`**, e.g. `900` for 15 minutes; don't enter `"15 minutes"`. |
| `WindowsUpdate` | Exactly `"None"`, `"Scan"`, or `"Install"`. `"Install"` downloads/installs updates and may create reboot requirements; `"Scan"` searches without installing. |
| `ChromeBlockPopups` | Set Chrome managed popup-blocking policy; verify required sites. |
| `EdgeBlockPopups` | Set Edge managed popup-blocking policy; verify required sites. |

**Critical difference:** `RequiredPorts` **does not enable** a firewall rule. It is used to avoid disabling a rule that appears necessary. Firewall and application access must still be tested manually.

#### Step 8D — Complete JSON reference (fictional Windows practice VM)

The [complete reference JSON](EXAMPLE-CONFIG-DO-NOT-APPLY.json) includes **all fields** the script generates and demonstrates multiple value types. It describes a **fictional** lab with `labadmin`, `labstudent`, a required printer/RDP service, and a made-up share.

> [!WARNING]
> **Never run Apply directly with the example file.** `ConfirmedReadme` is intentionally `false`. There is no universal Windows CyberPatriot config: the sample password length, group, required ports, and enabled security settings are **not instructions** for your VM. Use the script-generated `image-config.json`, transfer only relevant values after verification, and set `ConfirmedReadme` to `true` **last**.

~~~json
{
  "ConfirmedReadme": false,
  "AuthorizedUsers": [
    "labstudent",
    "labviewer"
  ],
  "AuthorizedAdmins": [
    "labadmin"
  ],
  "RequiredServices": [
    "Spooler",
    "TermService"
  ],
  "RequiredSoftware": [
    "Mozilla Firefox"
  ],
  "RequiredShares": [
    "LabShare"
  ],
  "RequiredPorts": [
    "3389"
  ],
  "ForensicsComplete": false,
  "ScanPaths": [
    "C:\\Users\\Public"
  ],
  "DisableFirewallRules": [],
  "RemoveAppxPackages": [],
  "RemoveStartupValues": [],
  "ClearIFEO": [],
  "RemoveShareAccess": [],
  "AuditSubcategories": {},
  "DisableUsers": [],
  "RemoveUsers": [],
  "DemoteAdmins": [],
  "PasswordExpiresUsers": [
    "labstudent"
  ],
  "NewUsers": [],
  "ResetPasswords": [],
  "Groups": {
    "LabReaders": [
      "labstudent"
    ]
  },
  "RemoveGroupMembers": {},
  "RemoveUserRights": {},
  "DisableServices": [],
  "DisableFeatures": [],
  "RemoveShares": [],
  "RemoveDefenderExclusions": [],
  "RemoveDefenderExclusionProcesses": [],
  "RemoveDefenderExclusionExtensions": [],
  "DisableScheduledTasks": [],
  "RemovePrograms": [],
  "RemoveFiles": [],
  "UpdatePrograms": [],
  "PasswordPolicy": {
    "MinimumPasswordLength": 12,
    "PasswordHistorySize": 5,
    "PasswordComplexity": 1
  },
  "Security": {
    "Firewall": true,
    "Defender": true,
    "DefenderSignatures": true,
    "DefenderQuickScan": false,
    "SMBClientSigning": false,
    "SMBServerSigning": false,
    "RequireRdpNla": false,
    "EnableUAC": false,
    "RestrictAnonymous": false,
    "DisableLMHash": false,
    "RequireNTLMv2": false,
    "ProtectPrintDrivers": false,
    "DisableNetBIOS": false,
    "CredentialAuditSuccess": true,
    "SmartScreen": true,
    "DisableAutoPlay": true,
    "DisableLLMNR": false,
    "DisableRemoteAssistance": false,
    "DisableRDP": false,
    "DisableSMB1": false,
    "DisableWDigest": true,
    "HideLastSignedIn": false,
    "DisableAdminEnumeration": false,
    "AutomaticWindowsUpdates": false,
    "RestrictBlankPasswordNetwork": true,
    "PowerShellLogging": false,
    "LockScreenSeconds": null,
    "WindowsUpdate": "None",
    "ChromeBlockPopups": false,
    "EdgeBlockPopups": false
  }
}
~~~

**How to adjust:** If RDP is not required, do not list `TermService` or `3389`. If printing is not required, remove `Spooler`. If no local group should be created, use `"Groups": {}`. If your README has no stated password policy, use `"PasswordPolicy": {}`. If a security change could break a required app, leave its option `false` and review it manually. Keep account-removal and file-removal fields empty until the exact need is verified.

Save the edited **generated file** in Notepad. Continue to **Step 9** to check JSON syntax; that test does not check whether the choices are authorized.

### Step 9 — Check JSON formatting without applying anything

Paste into PowerShell:

~~~powershell
Get-Content .\image-config.json -Raw | ConvertFrom-Json | Out-Null
~~~

**Expected:** No output means PowerShell could parse the JSON. If you see a red error, reopen with `notepad .\image-config.json`, correct the formatting, and check again. **Valid JSON does not mean safe choices** — the README review still matters.

### Step 10 — Apply ONLY your reviewed configuration

**Do this only when the image rules permit scripts, your forensics are safe, and the JSON has been checked.** Keep console access open.

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Apply -Config ".\image-config.json"
~~~

At the prompt, type **`APPLY`** in capitals and press **Enter**. If you have any doubt about the settings, **do not type APPLY**; you can cancel the run at that prompt.

The script runs an initial audit, the selected/configured tasks, then a final audit. **It does not automatically reboot the VM.**

### Step 11 — Review the results and verify normal operation

Open the same folder as Step 6:

~~~powershell
explorer.exe "$env:USERPROFILE\Documents\WindowsSecurityWork"
~~~

Look for the newest `summary-...csv`, `changes-...txt`, `audit-...txt` and `backups-...` folder. Here is how to read common results:

| Result | Meaning |
|---|---|
| `CHANGED` | The script reports a modification; **not proof of CyberPatriot points** |
| `OK` | The inspected item was already acceptable to the script |
| `REVIEW` / `SKIPPED` | You need to decide manually or the script intentionally skipped it |
| `FAILED` | The action did not complete as intended; read the error |
| `WOULD` | Proposed action, not evidence it was applied |

Compare your **Scoring Report** to the score before Apply. Check that authorized users can sign in and required services, networking, shares, RDP, printers, and applications still function. Use the [remaining manual checks](MANUAL-TASKS.md). If you break something, **stop and restore the specific change** from your recorded before-state/backup; some deletions are irreversible.

## Optional advanced commands (do not start with these)

- **Run just selected sections** after reviewing the JSON: `-Only accounts,passwords,firewall` appended to the Apply command.
- **Skip the initial APPLY confirmation:** `-Yes`. This also skips interactive password prompts; **not recommended for a beginner**.
- **Allow configured removals:** `-AllowRemovals`. This may remove data or accounts; use only for exact authorized targets after preserving evidence.
- **Manual menu:** launching the script without `-Mode Audit` can open a menu that includes change-making actions. **Use the explicit Audit command above instead.**

## Troubleshooting — if a step does not work

| What you see | What to do |
|---|---|
| `Cannot find path` / script not recognized | Verify you are inside the VM, run `cd "$env:USERPROFILE\Downloads"`, check the actual filename, then run `Get-Item .\windows-10-11.ps1` |
| First line shows HTML or filename ends in `.txt` | Download **Raw** again as **All files**; do not rename HTML |
| Windows asks for Administrator permission | Close the window; reopen **Windows PowerShell → Run as administrator** in the VM |
| Execution is blocked | Check file provenance and the competition rules; this command already uses process-scoped `-ExecutionPolicy Bypass`. Do not disable system-wide protections |
| `image-config.json` already exists | The script is preventing accidental overwrite; edit your existing file |
| `ConvertFrom-Json` reports an error | Look for extra/missing commas, quotes, or brackets in Notepad |
| Apply refuses to start | Check `ConfirmedReadme`, `AuthorizedAdmins`, protected services, and the *actual* README; never bypass validation |
| A required service fails or score drops | **Stop**, review logs/backups, and undo only the affected action; ask a mentor before rebooting or deleting anything |

**Reference:** [Complete Windows 10/11 handbook](../windows-10-11.md) · [Manual tasks](MANUAL-TASKS.md) · [General script safety and rollback](../../General/script-safety.md).

*Documentation has been checked against the script's command options, but this update does not claim an end-to-end test on a Windows VM.*
