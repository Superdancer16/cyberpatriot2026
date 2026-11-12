#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('Menu','Audit','Quick','Apply')][string]$Mode = 'Menu',
    [string]$Config,
    [switch]$InitConfig,
    [switch]$Yes,
    [switch]$AllowRemovals,
    [string[]]$Only
)

$ErrorActionPreference = 'Stop'
$root = Join-Path $env:USERPROFILE 'Documents\WindowsSecurityWork'
New-Item -ItemType Directory -Path $root -Force | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$log = Join-Path $root "changes-$stamp.txt"
$report = Join-Path $root "audit-$stamp.txt"
$script:domainJoined = (Get-CimInstance Win32_ComputerSystem).PartOfDomain
$script:admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Note([string]$message) {
    $line = "$(Get-Date -Format s)  $message"
    Add-Content -Path $log -Value $line
    Write-Host $message
}
function Confirm([string]$message) {
    Write-Host "`n$message" -ForegroundColor Yellow
    return (Read-Host 'Type YES to continue') -ceq 'YES'
}
function Run-Task([string]$name, [scriptblock]$body) {
    try { & $body; Note "Task reviewed: $name" }
    catch { Note "ERROR [$name]: $($_.Exception.Message)" }
    Write-Host 'Check the Scoring Report and required applications before another change.' -ForegroundColor Cyan
}
function Need-Admin { if (-not $script:admin) { throw 'Run PowerShell as Administrator.' } }
function Need-Local { if ($script:domainJoined) { throw 'Domain-joined computer: inspect the governing GPO instead of changing local policy.' } }
function Reg-Dword([string]$path,[string]$name,[int]$value) {
    $existed = Test-Path $path
    $previous = if ($existed) { (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue).$name } else { $null }
    Note "Before registry: $path / $name = $previous (path existed: $existed)"
    if (-not $existed) { New-Item -Path $path -Force | Out-Null }
    New-ItemProperty -Path $path -Name $name -Value $value -PropertyType DWord -Force | Out-Null
    Note "After registry: $path / $name = $((Get-ItemProperty -Path $path -Name $name).$name)"
}
function Audit {
    $items = New-Object System.Collections.Generic.List[string]
    $items.Add("Audit: $(Get-Date) / $env:COMPUTERNAME / $([Environment]::OSVersion.VersionString)")
    $items.Add("Domain joined: $script:domainJoined")
    $items.Add("Administrator session: $script:admin")
    $checks = @(
        @{name='Users'; cmd={Get-LocalUser | Select-Object Name,Enabled,PasswordExpires,PasswordRequired | Format-Table -AutoSize | Out-String}},
        @{name='Administrators'; cmd={Get-LocalGroupMember -SID 'S-1-5-32-544' | Select-Object Name,PrincipalSource | Format-Table -AutoSize | Out-String}},
        @{name='Local groups'; cmd={Get-LocalGroup | Select-Object Name,Description | Format-Table -AutoSize | Out-String}},
        @{name='Password policy'; cmd={net accounts | Out-String}},
        @{name='Firewall'; cmd={Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction | Format-Table -AutoSize | Out-String}},
        @{name='Defender'; cmd={Get-MpComputerStatus | Select-Object AntivirusEnabled,RealTimeProtectionEnabled,AntivirusSignatureAge | Format-List | Out-String}},
        @{name='Defender exclusions'; cmd={Get-MpPreference | Select-Object ExclusionPath,ExclusionProcess,ExclusionExtension | Format-List | Out-String}},
        @{name='RDP'; cmd={Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections | Out-String}},
        @{name='Windows services'; cmd={Get-Service -Name RemoteRegistry,simptcp,WinDefend,mpssvc,wuauserv -ErrorAction SilentlyContinue | Select-Object Name,Status,StartType | Format-Table -AutoSize | Out-String}},
        @{name='Shares'; cmd={Get-SmbShare | Select-Object Name,Path,Special | Format-Table -AutoSize | Out-String}},
        @{name='SMB client'; cmd={Get-SmbClientConfiguration | Select-Object RequireSecuritySignature | Format-List | Out-String}},
        @{name='SMB1'; cmd={Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue | Select-Object FeatureName,State | Format-List | Out-String}},
        @{name='Password flags'; cmd={Get-LocalUser | Select-Object Name,PasswordExpires,PasswordRequired,UserMayChangePassword | Format-Table -AutoSize | Out-String}},
        @{name='Windows updates'; cmd={Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 15 HotFixID,InstalledOn | Format-Table -AutoSize | Out-String}},
        @{name='Firewall inbound exceptions'; cmd={Get-NetFirewallRule -Direction Inbound -Enabled True -Action Allow -ErrorAction SilentlyContinue | Select-Object -First 120 DisplayName,Profile | Format-Table -Wrap | Out-String}},
        @{name='Installed software'; cmd={Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object DisplayName | Select-Object DisplayName,DisplayVersion | Sort-Object DisplayName | Format-Table -AutoSize | Out-String}},
        @{name='Startup'; cmd={Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location | Format-Table -Wrap | Out-String}},
        @{name='Scheduled tasks outside Microsoft'; cmd={Get-ScheduledTask | Where-Object TaskPath -NotLike '\Microsoft\*' | Select-Object -First 120 TaskName,TaskPath,State | Format-Table -AutoSize | Out-String}},
        @{name='Defender SmartScreen'; cmd={Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name EnableSmartScreen -ErrorAction SilentlyContinue | Out-String}},
        @{name='Listening ports'; cmd={Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select-Object LocalAddress,LocalPort,OwningProcess | Sort-Object LocalPort | Format-Table -AutoSize | Out-String}}
    )
    foreach ($item in $checks) {
        $items.Add("`r`n=== $($item.name) ===")
        try { $items.Add((& $item.cmd).ToString()) }
        catch { $items.Add("Unavailable: $($_.Exception.Message)") }
    }
    $items | Set-Content -Path $report -Encoding UTF8
    Write-Host "Saved report: $report" -ForegroundColor Green
    Note "Audit report: $report"
}
function Firewall {
    Need-Admin
    if (-not (Confirm 'Enable all Windows Firewall profiles? Review required inbound apps and remote access first.')) { return }
    Get-NetFirewallProfile | Select-Object Name,Enabled | Out-String | ForEach-Object { Note "Before: $_" }
    Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
    Note "After: $((Get-NetFirewallProfile | Select-Object Name,Enabled | Out-String).Trim())"
}
function Defender {
    Need-Admin
    if (-not (Confirm 'Turn on Defender real-time and unwanted-app protection? Required third-party antivirus may take precedence.')) { return }
    Set-MpPreference -DisableRealtimeMonitoring $false -PUAProtection Enabled
    $s = Get-MpComputerStatus
    Note "Defender: real-time=$($s.RealTimeProtectionEnabled); signatures age=$($s.AntivirusSignatureAge) days"
    Note 'Tamper Protection or organizational policy can prevent changes; do not bypass protection.'
}
function SignatureUpdate {
    Need-Admin
    if (-not (Confirm 'Update Microsoft Defender signatures now?')) { return }
    Update-MpSignature
    Note "Signature date: $((Get-MpComputerStatus).AntivirusSignatureLastUpdated)"
}
function Guest {
    Need-Admin; Need-Local
    $u = Get-LocalUser | Where-Object { $_.SID.Value -match '-501$' } | Select-Object -First 1
    if (-not $u) { Note 'No local Guest account found.'; return }
    if (-not (Confirm "Disable Guest account '$($u.Name)'? Check README first.")) { return }
    Note "Guest before: $($u.Name), enabled=$($u.Enabled)"
    Disable-LocalUser -Name $u.Name
    Note "Guest after: enabled=$((Get-LocalUser -Name $u.Name).Enabled)"
}
function PasswordPolicy {
    Need-Admin; Need-Local
    Write-Host 'Enter only values specifically required by your image. Leave a value blank to skip it.'
    $rules = [ordered]@{}
    foreach ($row in @(@('MinimumPasswordLength','Minimum length (0-14)'),@('PasswordHistorySize','Password history (0-24)'),@('MinimumPasswordAge','Minimum age days'),@('MaximumPasswordAge','Maximum age days'),@('LockoutBadCount','Account lockout threshold (0 disables)'),@('LockoutDuration','Lockout duration minutes'),@('ResetLockoutCount','Reset lockout count after minutes'))) {
        $raw = (Read-Host $row[1]).Trim()
        if ($raw) {
            $num = 0
            if (-not [int]::TryParse($raw,[ref]$num) -or $num -lt 0 -or $num -gt 999) { throw "Invalid value: $($row[0])" }
            $rules[$row[0]] = $num
        }
    }
    $complex = Read-Host 'Set password complexity and disable reversible encryption? (y/N)'
    if ($complex -match '^[yY]$') { $rules['PasswordComplexity']=1; $rules['ClearTextPassword']=0 }
    if ($rules.Count -eq 0) { Note 'No password policy changes selected.'; return }
    if ($rules.Contains('MinimumPasswordAge') -and $rules.Contains('MaximumPasswordAge') -and $rules['MinimumPasswordAge'] -gt $rules['MaximumPasswordAge']) { throw 'Minimum age cannot exceed maximum age.' }
    $backup = Join-Path $root "security-before-$stamp.inf"
    & secedit.exe /export /cfg $backup /areas SECURITYPOLICY | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Security policy export failed; no changes made.' }
    Note "Saved original policy: $backup"
    $values = ($rules.GetEnumerator() | ForEach-Object { "$($_.Key) = $($_.Value)" }) -join "`r`n"
    if (-not (Confirm "Apply these local policy values?`n$values`nDo not apply on a domain-managed machine.")) { return }
    $inf = Join-Path $root "security-changes-$stamp.inf"
    $db = Join-Path $root "security-changes-$stamp.sdb"
    @('[Unicode]','Unicode=yes','','[System Access]',($rules.GetEnumerator() | ForEach-Object { "$($_.Key) = $($_.Value)" }),'','[Version]','signature="$CHICAGO$"','Revision=1') | Set-Content -Path $inf -Encoding Unicode
    & secedit.exe /configure /db $db /cfg $inf /areas SECURITYPOLICY /quiet | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Policy import failed; inspect the saved original policy.' }
    Note "Requested local policy applied. Review secpol.msc and net accounts. Input file: $inf"
}
function LocalGroup {
    Need-Admin; Need-Local
    $name = (Read-Host 'Exact group name from README').Trim()
    if (-not $name) { return }
    if (Get-LocalGroup -Name $name -ErrorAction SilentlyContinue) { Note "Group already exists: $name"; return }
    if (-not (Confirm "Create local group '$name'?")) { return }
    New-LocalGroup -Name $name | Out-Null
    Note "Created group: $name"
}
function GroupMembers {
    Need-Admin; Need-Local
    $name = (Read-Host 'Exact existing group name').Trim()
    if (-not (Get-LocalGroup -Name $name -ErrorAction SilentlyContinue)) { throw "Group not found: $name" }
    $inputNames = Read-Host 'Enter exact usernames separated by commas or semicolons'
    $names = @($inputNames -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique)
    if ($names.Count -eq 0) { return }
    $existing = @(Get-LocalGroupMember -Group $name -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    if (-not (Confirm "Add $($names -join ', ') to '$name'?")) { return }
    foreach ($user in $names) {
        if (@($existing | Where-Object { $_ -eq $user -or $_ -like "*\$user" }).Count) { Note "Already a member: $user"; continue }
        try { Add-LocalGroupMember -Group $name -Member $user; Note "Added $user to $name" }
        catch { Note "Could not add $user : $($_.Exception.Message)" }
    }
    Get-LocalGroupMember -Group $name | Format-Table Name,PrincipalSource
}
function Add-User {
    Need-Admin; Need-Local
    $name = (Read-Host 'Exact missing authorized username').Trim()
    if (-not $name -or (Get-LocalUser -Name $name -ErrorAction SilentlyContinue)) { Note 'Name missing or account already exists.'; return }
    $password = Read-Host "Set a secure initial password for '$name'" -AsSecureString
    if (-not (Confirm "Create local account '$name'? Standard user is default.")) { return }
    New-LocalUser -Name $name -Password $password | Out-Null
    Note "Created local standard account $name"
    if (Confirm "Should '$name' be an administrator according to README?") {
        $g = Get-LocalGroup | Where-Object { $_.SID.Value -eq 'S-1-5-32-544' } | Select-Object -First 1
        Add-LocalGroupMember -Group $g.Name -Member $name
        Note "Added $name to local Administrators"
    }
}
function UserPassword {
    Need-Admin; Need-Local
    $name=(Read-Host 'Exact authorized username to change password').Trim()
    if (-not (Get-LocalUser -Name $name -ErrorAction SilentlyContinue)) { throw "Account not found: $name" }
    if (-not (Confirm "Change password for '$name'? This can break services using that account.")) { return }
    $password = Read-Host 'Type new password securely' -AsSecureString
    Set-LocalUser -Name $name -Password $password
    Note "Updated password for $name; test a legitimate login. Previous password cannot be recovered from this script."
}
function Remove-Admin {
    Need-Admin; Need-Local
    $name=(Read-Host 'Exact user who must remain standard').Trim()
    if (-not $name -or $name -eq $env:USERNAME) { throw 'Cannot remove your current admin account.' }
    $g = Get-LocalGroup | Where-Object { $_.SID.Value -eq 'S-1-5-32-544' } | Select-Object -First 1
    $members = @(Get-LocalGroupMember -Group $g.Name -ErrorAction SilentlyContinue)
    if ($members.Count -le 1) { throw 'Refusing to remove the only administrator.' }
    if (-not (Confirm "Remove '$name' from local Administrators while keeping the account?")) { return }
    Remove-LocalGroupMember -Group $g.Name -Member $name
    Note "Removed admin rights for $name; verify standard login and admin access."
}
function SecurityOptions {
    Need-Admin; Need-Local
    if (-not (Confirm 'Enable blank-password network restriction, SmartScreen, LLMNR restriction, and AutoPlay restriction? Inspect required software and networking first.')) { return }
    Reg-Dword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'LimitBlankPasswordUse' 1
    Reg-Dword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableSmartScreen' 1
    Reg-Dword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' 'EnableMulticast' 0
    Reg-Dword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 255
    Note 'Verify each effective policy and required networking; some policies need a refresh or restart.'
}
function SMBSigning {
    Need-Admin
    if (-not (Confirm 'Require SMB client signing? This can break legacy file shares.')) { return }
    $old = (Get-SmbClientConfiguration).RequireSecuritySignature
    Note "SMB client signing before: $old"
    Set-SmbClientConfiguration -RequireSecuritySignature $true -Confirm:$false
    Note "SMB client signing after: $((Get-SmbClientConfiguration).RequireSecuritySignature)"
}
function Disable-RDP {
    Need-Admin
    if ($env:SESSIONNAME -like 'RDP*') { throw 'Refusing while running from Remote Desktop.' }
    if (-not (Confirm 'Disable incoming Remote Desktop only if the README says it is NOT required?')) { return }
    Reg-Dword 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' 1
    Note 'RDP connection flag disabled. Verify authorized remote access requirements.'
}
function Disable-Services([switch]$QuickOnly) {
    Need-Admin
    $allowed = @('RemoteRegistry','simptcp','SNMP','SNMPTRAP','SSDPSRV','upnphost','FTPSVC','W3SVC','RemoteAccess','SharedAccess','Spooler','XblAuthManager','XblGameSave','XboxNetApiSvc','WebClient','WMPNetworkSvc','sshd','WinRM')
    if ($QuickOnly) { $names = @('RemoteRegistry','simptcp') }
    else {
        Write-Host "Review allowed service names: $($allowed -join ', ')" -ForegroundColor Cyan
        $names = @((Read-Host 'Type exact service names, separated by commas (blank skips)').Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }
    foreach ($name in $names) {
        if ($name -notin $allowed) { Note "Skipped unapproved service name: $name"; continue }
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $svc) { Note "$name absent; skipped"; continue }
        $dependencies = @($svc.DependentServices | Where-Object { $_.Status -eq 'Running' })
        if ($dependencies.Count -gt 0) { Note "Skipped $name because running services depend on it: $($dependencies.Name -join ', ')"; continue }
        if (-not (Confirm "Stop and disable '$name'? Check README and required application functionality.")) { continue }
        Note "Service before: $name status=$($svc.Status) start=$($svc.StartType)"
        if ($svc.Status -eq 'Running') { Stop-Service -Name $name -ErrorAction Stop }
        Set-Service -Name $name -StartupType Disabled
        $new = Get-Service -Name $name
        Note "Service after: $name status=$($new.Status) start=$($new.StartType). Restore the recorded old state if needed."
    }
}
function Disable-SMB1 {
    Need-Admin
    $f = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
    if (-not $f -or $f.State -ne 'Enabled') { Note 'SMB1 not enabled; no change.'; return }
    if (-not (Confirm 'Disable legacy SMB1? A required older file share or application could stop working.')) { return }
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart | Out-Null
    Note 'SMB1 disable requested; verify after an approved restart and test required shares.'
}
function CredentialAudit {
    Need-Admin
    if (-not (Confirm 'Enable success auditing for Credential Validation? This can increase Security logs.')) { return }
    & auditpol.exe /get /subcategory:'Credential Validation' | Out-String | ForEach-Object { Note "Before: $_" }
    & auditpol.exe /set /subcategory:'Credential Validation' /success:enable | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'auditpol failed (check OS language and policy).' }
    & auditpol.exe /get /subcategory:'Credential Validation' | Out-String | ForEach-Object { Note "After: $_" }
}
function Disable-User {
    Need-Admin; Need-Local
    $name = (Read-Host 'Exact unauthorized username').Trim()
    $u = Get-LocalUser -Name $name -ErrorAction Stop
    if ($name -eq $env:USERNAME -or $u.SID.Value -match '-(500|501|503|504)$') { throw 'Built-in or current account: use the manual guide.' }
    if (-not (Confirm "Disable '$name' (do not delete)?")) { return }
    Note "User before: $name enabled=$($u.Enabled) SID=$($u.SID.Value)"
    Disable-LocalUser -Name $name
    Note "User after: $name enabled=$((Get-LocalUser -Name $name).Enabled); undo: Enable-LocalUser -Name '$name'"
}
function Delete-User {
    Need-Admin; Need-Local
    $name = (Read-Host 'Exact user that the README says REMOVE').Trim()
    $u = Get-LocalUser -Name $name -ErrorAction Stop
    if ($name -eq $env:USERNAME -or $u.SID.Value -match '-(500|501|503|504)$') { throw 'Refusing to delete a built-in or current account.' }
    $g = Get-LocalGroup | Where-Object { $_.SID.Value -eq 'S-1-5-32-544' } | Select-Object -First 1
    $admins = @(Get-LocalGroupMember -Group $g.Name -ErrorAction SilentlyContinue)
    if ($admins.Count -le 1 -and @($admins | Where-Object { $_.SID.Value -eq $u.SID.Value }).Count -gt 0) { throw 'Refusing to delete the only administrator.' }
    Write-Host "Account: $($u.Name)  SID: $($u.SID.Value)  Enabled: $($u.Enabled)" -ForegroundColor Yellow
    if ((Read-Host "Type DELETE $name to permanently remove this account (not its profile)") -cne "DELETE $name") { return }
    Note "Removing user $name, SID=$($u.SID.Value). Account deletion is not reversible by re-creating the name."
    Remove-LocalUser -Name $name
    Note "Account removed: $name. Verify the image README and scoring report."
}
function Remove-GroupMember {
    Need-Admin; Need-Local
    $group = (Read-Host 'Exact local group').Trim()
    $user = (Read-Host 'Exact member to remove').Trim()
    if (-not $group -or -not $user) { return }
    $g = Get-LocalGroup -Name $group -ErrorAction Stop
    if ($g.SID.Value -eq 'S-1-5-32-544' -and $user -eq $env:USERNAME) { throw 'Cannot remove your current administrator account.' }
    if (-not (Confirm "Remove only '$user' from '$group'?")) { return }
    Remove-LocalGroupMember -Group $group -Member $user
    Note "Removed member $user from $group; undo: Add-LocalGroupMember -Group '$group' -Member '$user'"
}
function ExpiringPassword {
    Need-Admin; Need-Local
    $name=(Read-Host 'Exact authorized user whose password must expire').Trim()
    $u = Get-LocalUser -Name $name -ErrorAction Stop
    if (-not (Confirm "Allow password expiration for '$name'? Check service dependencies first.")) { return }
    Note "Before user password expiration: $name PasswordExpires=$($u.PasswordExpires)"
    Set-LocalUser -Name $name -PasswordNeverExpires $false
    Note "PasswordNeverExpires disabled for $name. Verify in lusrmgr.msc; restore original setting only if needed."
}
function Remove-Share {
    Need-Admin
    $name=(Read-Host 'Exact unauthorized share name, including $ if applicable').Trim()
    $share=Get-SmbShare -Name $name -ErrorAction Stop
    if ($share.Special -or $name -in @('ADMIN$','C$','IPC$','print$')) { throw 'System/administrative share: manual review required.' }
    Write-Host "Share: $($share.Name) Path: $($share.Path)" -ForegroundColor Yellow
    if ((Read-Host "Type REMOVE SHARE to remove only '$name'") -cne 'REMOVE SHARE') { return }
    Note "Removing share $name; path=$($share.Path); description=$($share.Description). Record permissions separately."
    Remove-SmbShare -Name $name -Force -Confirm:$false
    Note "Removed share $name. This does not delete files; restore path and original ACL manually if mistaken."
}
function DefenderExclusion {
    Need-Admin
    $path=(Read-Host 'Exact unauthorized Defender exclusion PATH').Trim()
    if (-not $path) { return }
    $all=@((Get-MpPreference).ExclusionPath)
    if ($path -cnotin $all) { throw 'That exact exclusion path was not found. Review Defender settings.' }
    if (-not (Confirm "Remove the exact Defender exclusion '$path'?")) { return }
    Remove-MpPreference -ExclusionPath $path
    Note "Removed Defender exclusion: $path; undo if required: Add-MpPreference -ExclusionPath '$path'"
}
function Start-Scan {
    Need-Admin
    if (-not (Confirm 'Start a Microsoft Defender quick scan? This may take time and quarantine files.')) { return }
    Start-MpScan -ScanType QuickScan
    Note 'Defender quick scan requested. Check Windows Security protection history for any detection and required-file impact.'
}
function Program-Update {
    Need-Admin
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) { Note 'winget is not installed; use the application Help > About updater or Windows Update.'; return }
    & winget.exe list
    $id=(Read-Host 'Exact installed application ID to UPDATE (blank cancels)').Trim()
    if (-not $id) { return }
    if (-not (Confirm "Update only package ID '$id' using winget? Verify the README-required install location.")) { return }
    & winget.exe upgrade --id $id --exact --source winget
    Note "winget upgrade finished for $id, exit code $LASTEXITCODE. Verify version, path, and required application functionality."
}
function Program-Remove {
    Need-Admin
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) { Note 'winget is unavailable; uninstall the exact program in Settings > Installed apps.'; return }
    & winget.exe list
    $id=(Read-Host 'Exact installed application ID to UNINSTALL (blank cancels)').Trim()
    if (-not $id) { return }
    if ((Read-Host "Type UNINSTALL $id only if specifically prohibited") -cne "UNINSTALL $id") { return }
    & winget.exe uninstall --id $id --exact
    Note "winget uninstall finished for $id, exit code $LASTEXITCODE. Verify required applications were not removed."
}
function TargetFile {
    Need-Admin
    $path=(Read-Host 'Full path to one prohibited file (blank cancels)').Trim().Trim('"')
    if (-not $path) { return }
    $f=Get-Item -LiteralPath $path -ErrorAction Stop
    if ($f.PSIsContainer) { throw 'Folders cannot be removed by this option.' }
    $protected=@($env:WINDIR,$env:ProgramFiles,${env:ProgramFiles(x86)},$root,(Join-Path $env:SystemDrive 'CyberPatriot')) | Where-Object { $_ }
    foreach($p in $protected) { if ($f.FullName.StartsWith($p.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Refusing to delete under a protected application, Windows, or log folder.' } }
    if ($f.FullName -match '(?i)\\CyberPatriot(\\|$)') { throw 'Refusing to modify CyberPatriot competition files.' }
    $hash=(Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash
    Write-Host "$($f.FullName)   $($f.Length) bytes   SHA256 $hash" -ForegroundColor Yellow
    if ((Read-Host 'Type DELETE FILE only after preserving forensic evidence') -cne 'DELETE FILE') { return }
    Note "Delete target: $($f.FullName) SHA256=$hash. File deletion is not automatically reversible."
    Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop
    Note "File removed: $($f.FullName)."
}
function WindowsUpdate {
    Note 'Opening Windows Update. Select Check for updates and install only approved updates; do not force an unapproved reboot.'
    Start-Process 'ms-settings:windowsupdate'
}
function RemoteAssistance {
    Need-Admin
    if (-not (Confirm 'Disable Remote Assistance (not Remote Desktop) when not required?')) { return }
    Reg-Dword 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowToGetHelp' 0
    Note 'Remote Assistance disabled. Verify with SystemPropertiesRemote and restore original value from the change log if needed.'
}
function ScriptLogging {
    Need-Admin
    if (-not (Confirm 'Enable PowerShell Script Block Logging? Events may contain sensitive command text.')) { return }
    Reg-Dword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' 'EnableScriptBlockLogging' 1
    Note 'Script Block Logging enabled; verify applicable GPO and Event Viewer. Review log retention and privacy.'
}


function Get-Value($Object, [string]$Key, $Fallback = $null) {
    if ($null -eq $Object) { return $Fallback }
    $property = $Object.PSObject.Properties[$Key]
    if ($null -ne $property) { return $property.Value }
    return $Fallback
}
function Names($Value) {
    if ($null -eq $Value) { return @() }
    return @($Value | ForEach-Object { [string]$_ } | Where-Object { $_.Trim() } | Select-Object -Unique)
}
function Is-Listed([string]$Name, $List) {
    foreach ($entry in (Names $List)) {
        if ($entry -ieq $Name -or $entry -ieq ($Name -split '\\')[-1]) { return $true }
    }
    return $false
}
function Write-Result([string]$State, [string]$Message) {
    if ($null -eq $script:Results) { $script:Results = New-Object System.Collections.ArrayList }
    [void]$script:Results.Add([pscustomobject]@{ State=$State; Message=$Message })
    Note "[$State] $Message"
}
function Initialize-ReadmeConfig {
    $dest = if ($Config) { $Config } else { Join-Path $PSScriptRoot 'image-config.json' }
    if (Test-Path -LiteralPath $dest) { throw "File already exists: $dest. It will not be overwritten." }
    $sample = [ordered]@{
        ConfirmedReadme = $false
        AuthorizedUsers = @()
        AuthorizedAdmins = @()
        RequiredServices = @()
        RequiredSoftware = @()
        RequiredShares = @()
        DisableUsers = @()
        RemoveUsers = @()
        DemoteAdmins = @()
        PasswordExpiresUsers = @()
        NewUsers = @()
        ResetPasswords = @()
        Groups = [ordered]@{}
        RemoveGroupMembers = [ordered]@{}
        DisableServices = @('RemoteRegistry','simptcp')
        DisableFeatures = @()
        RemoveShares = @()
        RemoveDefenderExclusions = @()
        DisableScheduledTasks = @()
        RemovePrograms = @()
        RemoveFiles = @()
        UpdatePrograms = @()
        PasswordPolicy = [ordered]@{}
        Security = [ordered]@{
            Firewall = $true
            Defender = $true
            DefenderSignatures = $true
            DefenderQuickScan = $false
            SMBClientSigning = $false
            CredentialAuditSuccess = $true
            SmartScreen = $true
            DisableAutoPlay = $true
            DisableLLMNR = $false
            DisableRemoteAssistance = $true
            DisableRDP = $false
            DisableSMB1 = $false
            DisableWDigest = $true
            HideLastSignedIn = $false
            RestrictBlankPasswordNetwork = $true
            PowerShellLogging = $false
            LockScreenSeconds = $null
            WindowsUpdate = 'Scan'
        }
    }
    $sample | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $dest -Encoding UTF8
    Write-Host "Created $dest" -ForegroundColor Green
    Write-Host 'Edit it using the image README. Set ConfirmedReadme to true after checking all lists.'
}
function Load-ReadmeConfig {
    if (-not $Config) { throw 'Apply mode requires -Config with an image-specific JSON file. Run -InitConfig first.' }
    if (-not (Test-Path -LiteralPath $Config -PathType Leaf)) { throw "Configuration file not found: $Config" }
    $script:Cfg = Get-Content -LiteralPath $Config -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
    if (-not [bool](Get-Value $script:Cfg 'ConfirmedReadme' $false)) {
        throw 'Set ConfirmedReadme=true only after reading the actual image README and checking authorized accounts/services.'
    }
    $script:Authorized = @(Names (Get-Value $script:Cfg 'AuthorizedUsers')) + @(Names (Get-Value $script:Cfg 'AuthorizedAdmins'))
    $script:RequiredServices = @(Names (Get-Value $script:Cfg 'RequiredServices'))
    $script:RequiredSoftware = @(Names (Get-Value $script:Cfg 'RequiredSoftware'))
    $script:RequiredShares = @(Names (Get-Value $script:Cfg 'RequiredShares'))
    $script:Sec = Get-Value $script:Cfg 'Security'
    if ($null -eq $script:Sec) { throw 'Configuration requires a Security object.' }
    $conflicts = New-Object System.Collections.ArrayList
    foreach ($user in (Names (Get-Value $script:Cfg 'RemoveUsers'))) {
        if ((Is-Listed $user $script:Authorized) -or $user -ieq $env:USERNAME) {
            [void]$conflicts.Add("RemoveUsers includes an authorized/current user: $user")
        }
    }
    foreach ($service in (Names (Get-Value $script:Cfg 'DisableServices'))) {
        if (Is-Listed $service $script:RequiredServices) {
            [void]$conflicts.Add("DisableServices includes a required service: $service")
        }
    }
    foreach ($share in (Names (Get-Value $script:Cfg 'RemoveShares'))) {
        if (Is-Listed $share $script:RequiredShares) {
            [void]$conflicts.Add("RemoveShares includes a required share: $share")
        }
    }
    foreach ($name in (Names (Get-Value $script:Cfg 'RemovePrograms'))) {
        if (Is-Listed $name $script:RequiredSoftware) {
            [void]$conflicts.Add("RemovePrograms includes required software: $name")
        }
    }
    if ($conflicts.Count) { throw ($conflicts -join '; ') }
}
function Check-Workstation {
    Need-Admin
    $os = Get-CimInstance Win32_OperatingSystem
    if ($os.ProductType -ne 1) { throw 'This script is for Windows 10/11 workstations, not Windows Server or a Domain Controller.' }
    if ($script:domainJoined) { Write-Result 'REVIEW' 'Domain-joined: account policy and local-group edits may be governed by domain policy.' }
}
function Decide([string]$Name, [bool]$NeedsChange, [scriptblock]$Fix) {
    if (-not $NeedsChange) { Write-Result 'OK' $Name; return }
    if ($Mode -eq 'Audit') { Write-Result 'WOULD' $Name; return }
    try {
        & $Fix
        Write-Result 'CHANGED' $Name
    } catch {
        Write-Result 'FAILED' ($Name + ': ' + $_.Exception.Message)
    }
}
function Exec-Native([string]$Name, [scriptblock]$Call) {
    & $Call | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "$Name failed (exit $LASTEXITCODE)" }
}
function Save-RegKey([string]$Path) {
    $reg = $Path -replace '^HKLM:\\','HKEY_LOCAL_MACHINE\' -replace '^HKCU:\\','HKEY_CURRENT_USER\'
    if (-not (Test-Path -Path $Path)) { return }
    $filename = 'registry-' + [Guid]::NewGuid().ToString('N') + '.reg'
    $destination = Join-Path $script:BackupDir $filename
    & reg.exe export $reg $destination /y | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Could not back up registry key $Path" }
    Note "Registry backup: $Path -> $destination"
}
function Put-RegDword([string]$Path, [string]$Key, [int]$Wanted) {
    $current = $null
    if (Test-Path -Path $Path) {
        $current = (Get-ItemProperty -Path $Path -Name $Key -ErrorAction SilentlyContinue).$Key
    }
    Decide ("Registry " + $Path + "\" + $Key + " -> " + $Wanted) ($null -eq $current -or [int]$current -ne $Wanted) {
        Save-RegKey $Path
        if (-not (Test-Path -Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Key -Value $Wanted -PropertyType DWord -Force | Out-Null
        $actual = (Get-ItemProperty -Path $Path -Name $Key).$Key
        if ([int]$actual -ne $Wanted) { throw 'Value did not persist; check effective Group Policy.' }
    }
}
function Show-AutomationSummary {
    Write-Host ''
    Write-Host 'Windows hardening summary' -ForegroundColor Cyan
    foreach ($state in @('CHANGED','OK','WOULD','SKIPPED','REVIEW','FAILED')) {
        $n = @($script:Results | Where-Object { $_.State -eq $state }).Count
        Write-Host "$state : $n"
    }
    $file = Join-Path $root "summary-$stamp.csv"
    $script:Results | Export-Csv -LiteralPath $file -NoTypeInformation -Encoding UTF8
    Write-Host "Summary: $file"
    Write-Host "Audit: $report"
    Write-Host "Changes: $log"
    Write-Host "Backups: $script:BackupDir"
}

function Quick {
    Run-Task 'Baseline audit' { Audit }
    Run-Task 'Firewall' { Firewall }
    Run-Task 'Defender' { Defender }
    Run-Task 'Defender signatures' { SignatureUpdate }
    Run-Task 'Guest' { Guest }
    Run-Task 'Security options' { SecurityOptions }
    Run-Task 'SMB signing' { SMBSigning }
    Run-Task 'Unneeded services' { Disable-Services -QuickOnly }
    Run-Task 'Final audit' { Audit }
}
function Menu {
    do {
        Write-Host "`nWindows 10/11 Security Menu" -ForegroundColor Cyan
        Write-Host '0 Audit only          Q Quick review (asks before each fix)'
        Write-Host '1 Firewall            2 Defender                3 Update Defender signatures'
        Write-Host '4 Disable Guest       5 Local password policy    6 Create group'
        Write-Host '7 Add group members   8 Create authorized user  9 Change user password'
        Write-Host '10 Demote admin       11 Security options        12 SMB client signing'
        Write-Host '13 Disable RDP        14 Disable services        15 Disable SMB1'
        Write-Host '16 Credential audit   17 Disable a user          18 Delete a user'
        Write-Host '19 Remove group member  20 Password expiration   21 Remove share'
        Write-Host '22 Remove Defender exclusion   23 Defender quick scan'
        Write-Host '24 Update exact program        25 Uninstall exact program'
        Write-Host '26 Delete exact prohibited file  27 Open Windows Update'
        Write-Host '28 Disable Remote Assistance  29 PowerShell logging'
        Write-Host 'X Exit'
        $choice = (Read-Host 'Choose').Trim().ToUpperInvariant()
        switch ($choice) {
            '0'  { Run-Task 'Audit' { Audit } }
            'Q'  { Quick }
            '1'  { Run-Task 'Firewall' { Firewall } }
            '2'  { Run-Task 'Defender' { Defender } }
            '3'  { Run-Task 'Defender signatures' { SignatureUpdate } }
            '4'  { Run-Task 'Guest' { Guest } }
            '5'  { Run-Task 'Password policy' { PasswordPolicy } }
            '6'  { Run-Task 'Local group' { LocalGroup } }
            '7'  { Run-Task 'Group members' { GroupMembers } }
            '8'  { Run-Task 'New user' { Add-User } }
            '9'  { Run-Task 'Password reset' { UserPassword } }
            '10' { Run-Task 'Admin membership' { Remove-Admin } }
            '11' { Run-Task 'Security options' { SecurityOptions } }
            '12' { Run-Task 'SMB signing' { SMBSigning } }
            '13' { Run-Task 'RDP' { Disable-RDP } }
            '14' { Run-Task 'Services' { Disable-Services } }
            '15' { Run-Task 'SMB1' { Disable-SMB1 } }
            '16' { Run-Task 'Credential Validation audit' { CredentialAudit } }
            '17' { Run-Task 'Disable user' { Disable-User } }
            '18' { Run-Task 'Delete user' { Delete-User } }
            '19' { Run-Task 'Remove group member' { Remove-GroupMember } }
            '20' { Run-Task 'Password expiration' { ExpiringPassword } }
            '21' { Run-Task 'Remove share' { Remove-Share } }
            '22' { Run-Task 'Remove Defender exclusion' { DefenderExclusion } }
            '23' { Run-Task 'Defender quick scan' { Start-Scan } }
            '24' { Run-Task 'Software update' { Program-Update } }
            '25' { Run-Task 'Uninstall program' { Program-Remove } }
            '26' { Run-Task 'Delete prohibited file' { TargetFile } }
            '27' { Run-Task 'Open Windows Update' { WindowsUpdate } }
            '28' { Run-Task 'Remote Assistance' { RemoteAssistance } }
            '29' { Run-Task 'PowerShell logging' { ScriptLogging } }
            'X'  { Note 'Exiting.' }
            default { Write-Host 'Choose a listed number, Q, or X.' }
        }
    } until ($choice -eq 'X')
}

Note "Started: $env:COMPUTERNAME, mode=$Mode, domainJoined=$script:domainJoined"
switch ($Mode) {
    'Audit' { Audit }
    'Quick' { Quick }
    'Apply' { Run-Automation }
    default { if ($InitConfig) { Initialize-ReadmeConfig } else { Menu } }
}
Write-Host "Change log: $log" -ForegroundColor Green

