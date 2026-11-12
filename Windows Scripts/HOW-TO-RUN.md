# Windows 10/11 — one-run hardening

`windows-10-11.ps1` runs the supported checks and configured fixes from the [Windows handbook](../Windows/windows-10-11.md) in a single pass. You do not have to choose 30 menu items. The image README determines authorized users, required groups, services, applications and policy values.

## 1. Put the files inside the Windows VM

1. In GitHub open [windows-10-11.ps1](windows-10-11.ps1), select **Raw**, then save it inside the VM's **Downloads** folder. The file must end in `.ps1`, not `.ps1.txt`.
2. Use the VM's own desktop, not your personal host computer. If Windows warns that the file came from the internet, verify that you downloaded the reviewed version from your repository.
3. Before changing the VM, read its README and save any required forensic answers. Record the original score and working administrator account. Keep the VM console available; make a snapshot only if round rules permit it.

## 2. Open an Administrator PowerShell window

Click **Start**, search **Windows PowerShell**, right-click **Run as administrator**, and select **Yes** for the Windows elevation prompt. Then enter:

```powershell
cd "$env:USERPROFILE\Downloads"
Get-Item .\windows-10-11.ps1
```

Do not run it until the exact file appears. The script supports Windows 10/11 with Windows PowerShell 5.1; it refuses to harden Windows Server or Domain Controllers automatically.

## 3. Create the README-specific configuration once

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -InitConfig -Config ".\image-config.json"
notepad .\image-config.json
```

The JSON template is generated automatically and must be edited before Apply mode works. Use the image README to fill in:

| Field | What it controls |
|---|---|
| `AuthorizedUsers`, `AuthorizedAdmins` | People who must remain active; never guess these lists |
| `RequiredServices`, `RequiredShares`, `RequiredSoftware` | Items the script must protect |
| `Groups`, `RemoveGroupMembers`, `RemoveUserRights` | Required groups/members plus exact unauthorized privilege assignments, such as `SeSecurityPrivilege` or `SeTakeOwnershipPrivilege` |
| `NewUsers`, `DemoteAdmins`, `PasswordExpiresUsers` | Named user/group changes |
| `DisableUsers`, `RemoveUsers` | Exact unauthorized accounts, not a guessed list |
| `PasswordPolicy` | Only the numeric/password fields the image actually requires |
| `DisableServices`, `DisableFeatures`, `DisableScheduledTasks` | Only verified unnecessary components |
| `RemoveShares`, `RemovePrograms`, `RemoveFiles` | Exact prohibited items |
| `UpdatePrograms` | Exact installed `winget` IDs to update |
| `Security` | Firewall, Defender, SMB, browser policies, automatic Windows Update, RDP, audit, elevation policy |

Example group object inside the generated JSON: ``"Groups": { "SpiderVerse": ["esther", "wyatt", "turner", "tina"] }`. This would create the specified group and add the four users automatically if they already exist. Replace these examples with names from the current README.

Only after reviewing **every applicable field**, change `"ConfirmedReadme": false` to `"ConfirmedReadme": true`. Do not set it to true just to make the script start. The sample template does not invent unauthorized users or prohibited files.

**Password policy:** You can leave ``"PasswordPolicy": {}` empty if the README has no confirmed requirements. To set a required 12-character minimum and enable complexity, use ``"PasswordPolicy": {"MinimumPasswordLength": 12, "PasswordComplexity": 1}` within the existing JSON. Only use values confirmed for that image.

## 4. Run the whole workflow with one command

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Apply -Config ".\image-config.json" -Yes
```

**That is the all-in-one command.** It performs an initial audit, processes all 16 sections in order, runs the final audit, and writes a summary. `-Yes` skips the initial confirmation; it does **not** bypass protections for required services, built-in users, or missing passwords.

For exact names/files/apps that the README explicitly requires you to **remove**, and only after preserving necessary evidence, use:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\windows-10-11.ps1" -Mode Apply -Config ".\image-config.json" -Yes -AllowRemovals
```

Without `-AllowRemovals`, permanent account/file/share/software removals are listed as **REVIEW** instead. This flag does not trigger broad or automatic discovery-based deletions: it only allows the exact entries in the JSON.

## 5. What runs in one pass

1. Account and group reconciliation: Guest, required local groups, members, specifically named unauthorized users/admin rights, password-expiry flags and authorized-user creation when a secure password can be entered.
2. Configured local password and lockout policy plus specified User Rights Assignment removals, with original security-policy exports for recovery.
3. Windows security options: SmartScreen, blank-password network restriction, AutoPlay, optional LLMNR, remote assistance, WDigest, automatic-update policy, optional administrator enumeration restrictions, and screen lock controls.
4. Defender protection/signature updates, firewall profiles, SMB signing/SMB1 and Credential Validation success auditing.
5. Named unnecessary services and Windows features, selected scheduled tasks and custom SMB shares.
6. Installed software inventory, exact `winget` application updates/removals, and exact prohibited files.
7. Optional Chrome/Edge pop-up policies and Windows Update scan or installation (without a forced restart).
8. Final audit and summary of changed, unchanged, skipped, failed and human-review items.

On a normal `-Yes` run, new-user creation and password resets requiring a password are **not** silently performed, because the script never stores plaintext passwords in the JSON. Run again without `-Yes` for secure prompts, or use [the manual guide](MANUAL-TASKS.md).

## 6. Results and quick competition review

The script saves reports under **Documents → WindowsSecurityWork** for the administrator account. Every Apply run creates a timestamped `backups-...` folder containing available original policy exports, registry exports, service states, audit snapshots, and inventory; `summary-...csv` lists outcomes.

| Result | Meaning |
|---|---|
| `CHANGED` | A requested setting/change was attempted and the module reported success |
| `OK` | Already satisfied / not installed / absent |
| `REVIEW` | Human decision or verification is still required |
| `SKIPPED` | Protected, unspecified, incompatible or not permitted |
| `FAILED` | The command failed; investigate before continuing |

Open the Scoring Report **after** the full run, compare the before/after audit, then finish [MANUAL-TASKS.md](MANUAL-TASKS.md). If scoring drops or a critical application stops working, restore only the documented setting using the original value and the [recovery guide](../Windows/windows-10-11.md#19-manual-verification-recovery-and-missing-investigation-steps). Password resets and deletions are not automatically reversible.

To run only selected sections after fixing the JSON, add ``-Only users,passwords,firewall` to the Apply command. Audit without changes remains available with ``-Mode Audit`. The old ``-Mode Menu` and ``-Mode Quick` are retained as alternatives.

**Limits:** No script can infer image-specific scoring rules, identify every backdoor with certainty, preserve every required application dependency, or guarantee points. There is no automatic reboot. This code has not been run against an actual CyberPatriot VM; verify its operation on a disposable practice VM first. A public GitHub repo is not team-private, so check the current competition rules on sharing and using scripts before a scored round.
