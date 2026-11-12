# Windows 10/11 — download and run inside the VM

The [PowerShell script](windows-10-11.ps1) checks and changes Windows settings based on the [complete handbook](../windows-10-11.md). One Apply command runs all configured sections. The **image README determines which accounts, services, applications and files are authorized**.

## 1. Sign in to GitHub inside the virtual machine

1. **Start the Windows 10/11 VM** in VMware or your competition VM software, and log into the assigned Windows account. Everything below happens **inside the VM**, not on your personal computer.
2. On the VM desktop, open **Microsoft Edge** or the installed browser.
3. In the address bar, go to **https://github.com/login**. Sign in to your GitHub account and complete any requested verification. The repository is **public**, so signing in is optional; you can open it without an account if permitted.
4. Open **https://github.com/Superdancer16/cyberpatriot2026**. Check that the repository name is correct and the branch selector says **main**.
5. Click **Windows → Scripts → windows-10-11.ps1**.
6. Click **Raw** above the file. If it opens as text, press **Ctrl+S**. If it downloads automatically, open the browser's **Downloads** panel.
7. In the VM's **Save As** dialog, choose **Downloads**, set **Save as type: All files** if necessary, and name it **windows-10-11.ps1**. Do not save the GitHub preview as an HTML page.
8. Open **File Explorer → Downloads**. In Windows 11 choose **View → Show → File name extensions**; in Windows 10 choose **View → File name extensions**. Make sure the file is **windows-10-11.ps1**, not **windows-10-11.ps1.txt**.
9. **Sign out of GitHub in the VM** afterward and decline any offer to save your GitHub password. Avoid leaving personal login credentials in a competition VM.

If your competition rules prohibit web browsing or downloading outside resources, use a transfer method your coach has approved instead. You may also download [HOW-TO-RUN.md](HOW-TO-RUN.md) and [MANUAL-TASKS.md](MANUAL-TASKS.md) for offline reading.

## 2. Open PowerShell as Administrator in the VM

1. In the VM, open **Start**, search **Windows PowerShell**, then right-click and select **Run as administrator → Yes**.
2. Enter:

```powershell
cd "$env:USERPROFILE\Downloads"
Get-Item .\windows-10-11.ps1
Get-Content .\windows-10-11.ps1 -TotalCount 4
```

Check that the file exists and starts with `#requires -Version 5.1`, rather than displaying HTML. The script is for **Windows 10/11 workstations**; do not apply it to Windows Server or a Domain Controller.

## 3. Run the read-only audit first

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Audit
```

The audit produces a report under **Documents → WindowsSecurityWork**. Compare its findings with the image README, record the original score, and preserve any required forensic answers. Audit mode does not apply hardening fixes.

## 4. Create the image-specific configuration

Enter:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -InitConfig -Config ".\image-config.json"
notepad .\image-config.json
```

The generated JSON is only a template. Before Apply mode, fill in:

- `AuthorizedAdmins` with **every authorized administrator from this VM's README** (the script refuses an empty list), and `AuthorizedUsers` with authorized ordinary users.
- `RequiredServices`, `RequiredSoftware`, `RequiredShares` and `RequiredPorts` to protect the VM's required functions.
- Any exact accounts/groups/files/software requiring changes. Never copy names or numeric settings from a different scoring image.
- `ForensicsComplete: true` **only after** the necessary forensic answers and evidence are saved.
- Set `"ConfirmedReadme": true` only after reviewing the completed configuration against the README. Save with **Ctrl+S** and close Notepad.

### Important JSON fields

| Field | Meaning |
|---|---|
| `Groups` | Create required local groups and add the exact users |
| `NewUsers`, `DemoteAdmins`, `PasswordExpiresUsers`, `ResetPasswords` | Named account changes; passwords require secure prompts |
| `DisableUsers`, `RemoveUsers`, `RemoveGroupMembers`, `RemoveUserRights` | Specifically identified unauthorized accounts/privileges |
| `PasswordPolicy` | Explicit password and lockout requirements; leave `{}` when unknown |
| `DisableServices`, `DisableFeatures`, `DisableScheduledTasks` | Named unnecessary components only |
| `DisableFirewallRules`, `RequiredPorts` | Turn off exact unwanted inbound firewall rules, checking required ports |
| `AuditSubcategories` | Enable specified auditing categories without clearing unrelated audit settings |
| `RemoveStartupValues`, `ClearIFEO` | Targeted registry startup values and accessibility debugger overrides |
| `RemoveShares`, `RemoveShareAccess` | Exact custom shares and share permission entries |
| `RemovePrograms`, `UpdatePrograms`, `RemoveAppxPackages`, `RemoveFiles` | Exact package IDs, Store app names or file paths |
| `ScanPaths` | Extra folders for read-only file candidate discovery |
| `RemoveDefenderExclusions`, `RemoveDefenderExclusionProcesses`, `RemoveDefenderExclusionExtensions` | Specific Defender exclusions |
| `Security` | Defender, firewall, SMB, RDP/NLA, UAC, NTLM, print, Windows Update and other opt-in settings |

For example, a required group can be entered in the existing `Groups` field:

```json
"Groups": {
  "EXAMPLE_REQUIRED_GROUP": ["EXAMPLE_USER_A", "EXAMPLE_USER_B"]
}
```

Use the names from your own image and keep the rest of the generated JSON intact. In JSON, registry paths need double backslashes—for example `"HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"`.

If the image requires a 12-character password minimum and complexity enabled, an example is `"PasswordPolicy": {"MinimumPasswordLength": 12, "PasswordComplexity": 1}`. **Do not assume these example values apply to another image.** Options that may disrupt remote access, print drivers or old clients default to `false` unless you enable them deliberately.

## 5. Run everything in one pass

After completing the JSON:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Apply -Config ".\image-config.json"
```

Type **APPLY** at the confirmation prompt. This runs the initial audit, all configured hardening sections and the final audit, without selecting every menu task.

After you have reviewed the JSON, this command skips the one initial prompt:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Apply -Config ".\image-config.json" -Yes
```

**Only if the image explicitly requires removal** of named accounts, custom shares, applications, Store apps or files, add `-AllowRemovals`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Apply -Config ".\image-config.json" -Yes -AllowRemovals
```

`-AllowRemovals` permits only the **exact entries configured in JSON**; it does not delete files because a scan found a suspicious name.

For a selected rerun, use comma-separated section names:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Apply -Config ".\image-config.json" -Only accounts,passwords,firewall
```

Available names: `discovery`, `accounts`, `passwords`, `rights`, `security`, `defender`, `firewall`, `firewallrules`, `smb`, `audit`, `auditdetails`, `services`, `features`, `tasks`, `startup`, `shares`, `shareaccess`, `browsers`, `apps`, `storeapps`, `files`, `updates`.

`-Yes` does **not** enter passwords. New users and password resets needing secret passwords are marked **REVIEW**. Rerun without `-Yes` for the secure prompts or follow the manual account section.

## 6. Check your results

Open **File Explorer → Documents → WindowsSecurityWork**. Inspect the latest:

- `audit-...txt`: general system audit.
- `changes-...txt`: results and failures.
- `summary-...csv`: status per attempted item.
- `backups-...`: exported original settings plus `review-...csv` reports for startup entries, firewall rules, services, processes, Store apps, hosts entries, file candidates and events.

`CHANGED` means the command reported a change, **not** that CyberPatriot awarded points. Review every `REVIEW` and `FAILED` result and compare the Scoring Report to your original score. Confirm authorized administrative login, required apps, RDP/SSH, printers, shares and networking still work.

Some settings need a restart, but **the script does not reboot the VM**. If a necessary service fails or the score drops, restore only the changed setting using the original value or exported backup; deleted users/files may not be recoverable. Use [MANUAL-TASKS.md](MANUAL-TASKS.md) and the [handbook recovery steps](../windows-10-11.md#19-manual-verification-recovery-and-missing-investigation-steps).

## Troubleshooting

- **PowerShell can't find the script:** Check the actual file name and path in File Explorer and rerun `Get-Item .\windows-10-11.ps1`.
- **It downloaded as HTML or `.txt`:** Go back to GitHub, click **Raw**, then save with **All files** selected.
- **Execution blocked by Windows:** Inspect the trusted source before using `Unblock-File .\windows-10-11.ps1`. The run command already uses a process-scoped execution policy.
- **Apply refuses to start:** Check `ConfirmedReadme`, `AuthorizedAdmins`, the JSON syntax and the current VM's README.
- **A setting fails or reverts:** See the detailed result and check whether Group Policy, protection settings, missing software or service dependencies are responsible.

**Testing status:** The code has not been executed inside a Windows VM in this session. Test on an authorized disposable practice VM first and follow the current competition rules for downloaded scripts and outside resources.
