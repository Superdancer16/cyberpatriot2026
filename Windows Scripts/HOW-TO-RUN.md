# Windows 10/11 script — setup and use

The file `windows-10-11.ps1` can inspect the system and apply selected changes from the [Windows 10/11 guide](../Windows/windows-10-11.md). It does **not** know the image's scoring requirements. The image README takes priority over every suggestion in the script.

The script starts in a menu and changes nothing until you choose a fix and confirm it. `Audit` is read-only. `Quick` runs an audit, presents several common fixes one at a time, and asks for `YES` before each change. Some actions are irreversible; read the confirmation and check your original score before using them.

## 1. Get the file

1. Open the repository and go to **Windows Scripts → [windows-10-11.ps1](windows-10-11.ps1)**.
2. Click **Raw**, then press **Ctrl+S**. Save the file in the Windows VM's **Downloads** folder as `windows-10-11.ps1` (not `windows-10-11.ps1.txt`).
3. Open **File Explorer → Downloads**. Choose **View → Show → File name extensions** and confirm that the filename ends in `.ps1`.
4. Run the script **inside the Windows 10/11 VM**, not on the host computer. If moving a downloaded file into a competition image, first check the current round's resource rules; the fact that a file is on GitHub does not make its use automatically authorized.

## 2. Before running it

1. Open and read the image **README**. Write down authorized users, administrators, required groups, critical services, software to keep, and any prohibited items.
2. Save any required forensic answers **before** deleting files, changing users, or removing suspicious processes.
3. Open the Scoring Report and write down the current score. Keep the VM console accessible and take a snapshot only if the rules permit one.
4. Do **not** run the script if you are unsure whether a change would disable a required service or remove an authorized account. Use the [manual guide](../Windows/windows-10-11.md) first.

## 3. Open PowerShell and run an audit

1. Click **Start**, type **Windows PowerShell**, right-click it, and choose **Run as administrator**.
2. Click **Yes** if Windows asks whether to allow the application to make changes.
3. Enter the following commands, one line at a time:

```powershell
cd "$env:USERPROFILE\Downloads"
Get-Item .\windows-10-11.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Audit
```

The last command uses a process-specific execution-policy override; it does not permanently change your computer's execution policy. Only use it after reviewing the downloaded script and confirming its source.

4. Find the **Saved report:** path in the output. The report is stored under `Documents\WindowsSecurityWork` in the account that ran the script. Open the `audit-...txt` file in Notepad.
5. Compare the results with the README. A suspicious account, enabled service, installed tool, or open port is only a finding—not proof it should be removed.

If PowerShell says the file cannot be found, check the Downloads location and extension. If it says **Access denied** or an operation needs administrator rights, close that window and repeat **Run as administrator**.

## 4. Open the interactive menu

From the same Administrator PowerShell window, enter:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Menu
```

Type one of the menu numbers and press **Enter**. For most fixes, type **YES** exactly when prompted. Typing anything else cancels that fix. To exit, choose `X`.

Useful options:

| Menu | Task |
|---|---|
| `0` | Read-only audit of users, local groups, password settings, firewall, Defender, services, software, startup tasks, shares, and network listeners |
| `1`, `2`, `3` | Enable firewall, review/enable Defender protection, update Defender signatures |
| `4`, `5` | Disable Guest; configure explicit image-required local password and lockout values |
| `6`, `7` | Create a required local group and add **only** the specified group members |
| `8`, `9`, `10`, `20` | Create an authorized user, set a password, remove unauthorized admin privileges, allow password expiration |
| `11`, `12`, `16`, `29` | Review security registry options, require SMB client signing, enable Credential Validation success auditing, enable PowerShell logging |
| `13`, `14`, `15`, `28` | Disable RDP, selected unneeded services, SMB1, or Remote Assistance **only when permitted** |
| `17`, `18`, `19`, `21`, `22` | Disable/delete one confirmed unauthorized user, remove group member, remove custom share, or remove one Defender exclusion |
| `23`, `24`, `25`, `26`, `27` | Defender quick scan, update/uninstall one exact program via `winget` when available, delete one identified prohibited file, open Windows Update |
| `Q` | Review common quick fixes with a confirmation before each one |

For an example custom group task: select `6`, enter the exact group name, confirm its creation, then select `7` to enter that same group and the exact member usernames separated by commas or semicolons. Reopen **Win + R → `lusrmgr.msc` → Groups** to confirm the result. Those are separate actions.

## 5. Use it to address scoring items quickly

1. Run **Audit** and read the **README**. Check which requirements are actually unmet before making changes.
2. Select **Q** for a quick review. The script audits, then individually offers firewall, Defender, definition updates, Guest, registry security options, SMB signing, and two unneeded-service checks. **Only approve a step when you have confirmed it is appropriate.**
3. Look at the Scoring Report after each approved change and give it time to refresh. A score can change later; no fix is guaranteed to award points.
4. Use the menu for explicit README items, such as **password policy (`5`)**, **group creation (`6`)**, **group membership (`7`)**, **passwords (`9`)**, **password expiration (`20`)**, or **unwanted software (`25`)**. Never guess values or names based on another image.
5. Perform anything in [MANUAL-TASKS.md](MANUAL-TASKS.md) using the linked sections of the main guide. End with a final audit (`0`) and test every README-required application and user login.

## 6. Logs, mistakes, and limitations

Every run writes `changes-...txt` to `Documents\WindowsSecurityWork`. Audit mode writes `audit-...txt`; local password policy changes also preserve an exported `.inf` file. The log records some original settings, but **is not a full automatic rollback tool**. Password resets, user deletion, program removal, file deletion, and some policy changes may not be reversible without backups.

If the score falls, **stop**, open the latest log, identify the last approved change, and restore only that previous setting with the appropriate guide instructions. Do not use a whole-machine rollback unless permitted and necessary. Some Windows changes require a policy refresh or an approved reboot to take effect. Never restart the machine just to force a score refresh.

Domain-joined machines, Windows Home editions, protected Defender settings, missing `winget`, and Group Policy controls can limit functionality. The script is written for **Windows PowerShell 5.1 on Windows 10/11** and has not been executed against an actual competition VM. Treat any script error as a reason to investigate manually, not as permission to disable another service.

**Rules note:** CyberPatriot's published rules allow certain team-created scripts in online rounds but restrict sharing and publicly posting CyberPatriot-specific scripts. A public GitHub link is not team-private. Check your coach's current official rules before downloading, posting, or using this file in a scored round.
