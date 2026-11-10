# Windows deeper investigations: effective policy, persistence, shares and event evidence

> **Use after:** [Windows workstation checklist](../checklists/windows-10-11.md) or [Windows Server checklist](../checklists/windows-server.md). These are **manual procedures**—not a script. Commands below are examples for an authorized practice image. **Read its README and answer/preserve forensics questions first.**

This supplement draws topic ideas from public CyberPatriot checklists and verifies key methods with Microsoft documentation. A generic checklist cannot tell you which accounts, shares, or services are authorized on *your* image.

## W1. Find the setting that actually applies (GPO versus local policy)

- [ ] Reviewed effective configuration and policy source.

**Why:** A value changed in \`secpol.msc\` or the registry can be replaced by a domain Group Policy. On a Domain Controller, editing an arbitrary local policy is not a substitute for checking domain-level policy.

**Clicking:** Press **Win + R** → \`rsop.msc\` (if available); review **Computer Configuration**. On domain-joined systems use **Group Policy Management** (\`gpmc.msc\`) **only if installed and authorized**. Do not disable a linked GPO merely to fix one setting.

**Typing (check, elevated Command Prompt or PowerShell):**

~~~powershell
(Get-CimInstance Win32_ComputerSystem) | Select-Object Name,PartOfDomain,Domain,DomainRole
gpresult /r /scope computer
~~~

On a system with applicable policies, save an **HTML report locally**, then open it:

~~~powershell
gpresult /h "$env:TEMP\cp-rsop.html" /f
Start-Process "$env:TEMP\cp-rsop.html"
~~~

**Interpretation:** \`PartOfDomain = True\` means domain policies may apply. The report's **Applied Group Policy Objects** and **Denied GPOs** help explain conflicts; a local-only or unconfigured policy may show less information. \`gpresult\` can report no RSoP data for the target scope—investigate context rather than assume a missing policy is a security failure.

**Verification:** Compare the effective policy with the README and with the relevant **Local Security Policy** or **Group Policy** editor. If a setting changes after refresh, identify its **winning policy** before editing it.

**Recovery:** Revert the *specific* policy change at its actual policy source. Keep an export/screenshot of the original setting. Changing a domain GPO can affect many machines.

## W2. Correlate suspicious services with their executable files

- [ ] Compared service names, binary paths, and required roles.

**Clicking:** **Win + R → services.msc** → double-click a service → note **Service name**, **Path to executable**, **Log On**, **Dependencies**. Do not stop it yet.

**Typing (check, elevated PowerShell):**

~~~powershell
Get-CimInstance Win32_Service |
  Select-Object Name,DisplayName,State,StartMode,StartName,PathName |
  Sort-Object Name | Format-Table -Wrap
~~~

To examine **one** service without guessing its executable:

~~~powershell
Get-CimInstance Win32_Service -Filter "Name='RemoteRegistry'" |
  Format-List Name,DisplayName,PathName,StartName,State,StartMode
~~~

**What to look for:** Unexpected user-profile or temporary-directory paths, impersonated names, newly introduced binaries, unusual service accounts, or services inconsistent with the README. Some legitimate software uses nonstandard locations; **a strange path is a clue, not proof**.

**Typing (investigate a known file, replace the sample path):**

~~~powershell
Get-Item -LiteralPath 'C:\Path\To\Suspect.exe' |
  Select-Object FullName,Length,CreationTime,LastWriteTime
Get-FileHash -LiteralPath 'C:\Path\To\Suspect.exe' -Algorithm SHA256
Get-AuthenticodeSignature -LiteralPath 'C:\Path\To\Suspect.exe' |
  Format-List Status,SignerCertificate
~~~

**Verification:** Compare publisher, path, hash, and service need against trusted vendor information and the README. A missing signature does not automatically prove malware.

**Recovery:** If a change is authorized, document the original \`StartMode\`, stop/disabling only that confirmed unwanted service using the existing checklist, and recheck required applications and the score. Never delete the executable before recording relevant forensic answers.

## W3. Investigate events: service installation, login attempts and process creation

- [ ] Checked available logs without clearing them.

**Clicking:** **Win + R → eventvwr.msc** → **Windows Logs → System** or **Security** → **Filter Current Log**. Record timestamps with timezone, event IDs, provider, and the full message.

**Typing (check):**

~~~powershell
Get-WinEvent -FilterHashtable @{
  LogName='System'; Id=7045; StartTime=(Get-Date).AddDays(-7)
} -MaxEvents 30 | Select-Object TimeCreated,Id,ProviderName,Message |
  Format-List
~~~

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

**Interpretation:** Errors such as **No events were found** do not prove an action never happened. Logging, retention, permissions, and audit policy affect visibility. To check the present policy:

~~~powershell
auditpol /get /category:*
~~~

**Verification:** Tie a suspicious event to an account, timestamp, executable and known system change. Avoid relying on one isolated log entry.

**Recovery:** If auditing was intentionally changed, restore only its original documented configuration; **never clear logs** to “clean” the machine.

## W4. Inspect persistence without executing unknown files

- [ ] Reviewed login-start items and task actions.

**GUI:** **Win + R → taskschd.msc** → **Task Scheduler Library**; inspect **Triggers**, **Actions**, **Author** and **History**. Open **Task Manager → Startup apps** for login items.

**Typing (check):**

~~~powershell
Get-CimInstance Win32_StartupCommand |
  Select-Object Name,Command,Location,User | Format-List
~~~

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

**Interpretation:** A task with an obscure name or PowerShell arguments warrants inspection, but scheduled updates and enterprise management agents are legitimate too. Record the exact executable and arguments before taking action.

**Verification:** Correlate task path, binary signature and Event Viewer findings. Do not run the task to see what happens.

**Recovery:** For a confirmed unauthorized task, prefer **Disable** before **Delete** (after preserving evidence). Record the original trigger and action; test whether required applications still work.

## W5. SMB share + NTFS access: check both layers

- [ ] Checked authorized shares and effective paths.

**GUI:** **Win + R → fsmgmt.msc** (when available) → **Shares**. Review share name, local path and active sessions. In File Explorer: folder → **Properties → Sharing / Security**.

**Typing (check):**

~~~powershell
Get-SmbShare | Select-Object Name,Path,Description,Special
~~~

For one **known** required share, substitute its actual name and path:

~~~powershell
Get-SmbShareAccess -Name 'ExampleShare'
Get-Acl -LiteralPath 'C:\ExampleFolder' | Format-List Path,Owner,Access
~~~

**Interpretation:** Share permissions and NTFS permissions both matter. Hidden administrative shares (for example \`C$\`) are not by themselves proof of malware. A broad \`Everyone\` share right may be constrained by NTFS, but it still needs review.

**Verification:** Test with a **legitimate non-admin** account that should read or write, and a separate account that should be denied. Protect required shared folders and server roles.

**Recovery:** Save both ACL layers before changing. Reverse only the particular group entry or share configuration changed; never recursively reset \`C:\Windows\` permissions.

## W6. Firewall rules that look open—but aren't applicable

- [ ] Checked effective profiles, rules, ports, and service ownership.

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

**Interpretation:** An allowed rule is not necessarily reachable: scope, profile, address filters, enabled state, underlying service and other policy conditions matter. A listening port may serve an explicitly required role.

**Verification:** From an authorized client, test required application connectivity after any **narrow** firewall change. Avoid blanket removal of inbound rules.

## Final verification checklist

- [ ] Read and preserved forensic questions.
- [ ] Confirmed whether the machine is standalone, domain-joined or a Domain Controller.
- [ ] Found the **effective** source for changed policies.
- [ ] Correlated unknown services with executable paths and relevant logs.
- [ ] Reviewed scheduled tasks/startup entries without executing unknown payloads.
- [ ] Confirmed required shares, services and firewall connectivity remain operational.
- [ ] Recorded any modification, verification result and rollback information.

## Sources and further reading

- [Microsoft: gpresult and Resultant Set of Policy](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/gpresult)
- [Microsoft: Advanced Audit Policy Configuration](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/advanced-audit-policy-configuration)
- [Microsoft: Event 4688 (process creation)](https://learn.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4688)
- [Microsoft: Event 4697 (service installation)](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4697)
- Topic cross-checks: [chessischess CyberPatriot checklists](https://github.com/chessischess/cyberpatriot-checklist), [Minagera Windows checklist](https://github.com/Minagera/CyberPatriot/blob/main/CyberPatriot/Checklists/Windows/README.md).
