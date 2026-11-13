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
5. In the VM, open **File Explorer → Downloads**. Turn on filename extensions:
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
