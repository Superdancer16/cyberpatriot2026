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
