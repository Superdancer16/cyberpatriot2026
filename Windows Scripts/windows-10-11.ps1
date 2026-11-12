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
        RequiredPorts = @()
        ForensicsComplete = $false
        ScanPaths = @()
        DisableFirewallRules = @()
        RemoveAppxPackages = @()
        RemoveStartupValues = @()
        ClearIFEO = @()
        RemoveShareAccess = @()
        AuditSubcategories = [ordered]@{}
        DisableUsers = @()
        RemoveUsers = @()
        DemoteAdmins = @()
        PasswordExpiresUsers = @()
        NewUsers = @()
        ResetPasswords = @()
        Groups = [ordered]@{}
        RemoveGroupMembers = [ordered]@{}
        RemoveUserRights = [ordered]@{}
        DisableServices = @('RemoteRegistry','simptcp')
        DisableFeatures = @()
        RemoveShares = @()
        RemoveDefenderExclusions = @()
        RemoveDefenderExclusionProcesses = @()
        RemoveDefenderExclusionExtensions = @()
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
            SMBServerSigning = $false
            RequireRdpNla = $false
            EnableUAC = $false
            RestrictAnonymous = $false
            DisableLMHash = $false
            RequireNTLMv2 = $false
            ProtectPrintDrivers = $false
            DisableNetBIOS = $false
            CredentialAuditSuccess = $true
            SmartScreen = $true
            DisableAutoPlay = $true
            DisableLLMNR = $false
            DisableRemoteAssistance = $true
            DisableRDP = $false
            DisableSMB1 = $false
            DisableWDigest = $true
            HideLastSignedIn = $false
            DisableAdminEnumeration = $false
            AutomaticWindowsUpdates = $true
            RestrictBlankPasswordNetwork = $true
            PowerShellLogging = $false
            LockScreenSeconds = $null
            WindowsUpdate = 'Scan'
            ChromeBlockPopups = $false
            EdgeBlockPopups = $false
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


function Invoke-AutoAccounts {
    if ($script:domainJoined) {
        Write-Result 'REVIEW' 'Domain-joined: review local/domain accounts with the Windows handbook.'
        return
    }
    $guest = Get-LocalUser | Where-Object { $_.SID.Value -match '-501$' } | Select-Object -First 1
    if ($guest) {
        if (Is-Listed $guest.Name $script:Authorized) {
            Write-Result 'SKIPPED' "Guest is listed as required in the configuration; do not disable automatically."
        } else {
            Decide ("Disable built-in Guest " + $guest.Name) ([bool]$guest.Enabled) {
                Disable-LocalUser -Name $guest.Name
            }
        }
    }
    $adminGroup = Get-LocalGroup | Where-Object { $_.SID.Value -eq 'S-1-5-32-544' } | Select-Object -First 1
    if (-not $adminGroup) { throw 'Built-in Administrators group not found.' }
    foreach ($name in (Names (Get-Value $script:Cfg 'NewUsers'))) {
        if (-not (Is-Listed $name $script:Authorized)) {
            Write-Result 'SKIPPED' "New user $name is not in AuthorizedUsers/AuthorizedAdmins."
            continue
        }
        if (Get-LocalUser -Name $name -ErrorAction SilentlyContinue) {
            Write-Result 'OK' "User already exists: $name"
            continue
        }
        if ($Yes) {
            Write-Result 'REVIEW' "Create $name manually: a password is required and is never stored in JSON."
            continue
        }
        $pass = Read-Host "New secure initial password for $name" -AsSecureString
        Decide "Create authorized user $name" $true {
            New-LocalUser -Name $name -Password $pass -ErrorAction Stop | Out-Null
            if (Is-Listed $name (Get-Value $script:Cfg 'AuthorizedAdmins')) {
                Add-LocalGroupMember -Group $adminGroup.Name -Member $name
            }
        }
    }
    $groups = Get-Value $script:Cfg 'Groups'
    if ($groups) {
        foreach ($entry in $groups.PSObject.Properties) {
            $group = [string]$entry.Name
            if ([string]::IsNullOrWhiteSpace($group)) { continue }
            if (-not (Get-LocalGroup -Name $group -ErrorAction SilentlyContinue)) {
                Decide "Create local group $group" $true {
                    New-LocalGroup -Name $group | Out-Null
                }
            }
            foreach ($name in (Names $entry.Value)) {
                if (-not (Get-LocalUser -Name $name -ErrorAction SilentlyContinue)) {
                    Write-Result 'REVIEW' "Group $group: member $name does not exist."
                    continue
                }
                $members = @()
                try { $members = @(Get-LocalGroupMember -Group $group -ErrorAction Stop | ForEach-Object { $_.Name }) }
                catch { Write-Result 'REVIEW' "Group $group contains an unresolved member; check lusrmgr.msc." }
                $present = @($members | Where-Object { $_ -ieq $name -or $_ -like ("*\" + $name) }).Count -gt 0
                Decide "Add $name to $group" (-not $present) {
                    Add-LocalGroupMember -Group $group -Member $name
                }
            }
        }
    }
    foreach ($name in (Names (Get-Value $script:Cfg 'DemoteAdmins'))) {
        if ((Is-Listed $name (Get-Value $script:Cfg 'AuthorizedAdmins')) -or $name -ieq $env:USERNAME) {
            Write-Result 'SKIPPED' "Refusing to demote an authorized or current administrator: $name"
            continue
        }
        $members = @(Get-LocalGroupMember -Group $adminGroup.Name -ErrorAction SilentlyContinue)
        $target = @($members | Where-Object { $_.Name -ieq $name -or $_.Name -like ("*\" + $name) })
        if ($target.Count -eq 0) { Write-Result 'OK' "Not an administrator: $name"; continue }
        if ($members.Count -le 1) { Write-Result 'SKIPPED' 'Refusing to remove last administrator'; continue }
        Decide "Remove admin membership: $name" $true {
            Remove-LocalGroupMember -Group $adminGroup.Name -Member $name
        }
    }
    $removeMembers = Get-Value $script:Cfg 'RemoveGroupMembers'
    if ($removeMembers) {
        foreach ($entry in $removeMembers.PSObject.Properties) {
            $group = [string]$entry.Name
            foreach ($name in (Names $entry.Value)) {
                if (($group -ieq $adminGroup.Name) -and ($name -ieq $env:USERNAME)) {
                    Write-Result 'SKIPPED' "Cannot remove current administrator $name"
                    continue
                }
                $members = @(Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
                $exists = @($members | Where-Object { $_ -ieq $name -or $_ -like ("*\" + $name) }).Count -gt 0
                Decide "Remove $name from $group" $exists {
                    Remove-LocalGroupMember -Group $group -Member $name
                }
            }
        }
    }
    foreach ($name in (Names (Get-Value $script:Cfg 'PasswordExpiresUsers'))) {
        if (-not (Get-LocalUser -Name $name -ErrorAction SilentlyContinue)) {
            Write-Result 'REVIEW' "Password expiry: user not found: $name"
            continue
        }
        Decide "Require password expiration for $name" $true {
            Set-LocalUser -Name $name -PasswordNeverExpires $false
        }
    }
    foreach ($name in (Names (Get-Value $script:Cfg 'ResetPasswords'))) {
        if (-not (Get-LocalUser -Name $name -ErrorAction SilentlyContinue)) {
            Write-Result 'REVIEW' "Password reset: user not found: $name"
            continue
        }
        if ($Yes) {
            Write-Result 'REVIEW' "Reset password for $name manually; script will not store or generate a shared plaintext password."
            continue
        }
        $pass = Read-Host "Enter new secure password for $name" -AsSecureString
        Decide "Reset authorized password for $name" $true {
            Set-LocalUser -Name $name -Password $pass
        }
    }
    foreach ($name in (Names (Get-Value $script:Cfg 'DisableUsers'))) {
        $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
        if (-not $user) { Write-Result 'OK' "Disable user: absent $name"; continue }
        if ((Is-Listed $name $script:Authorized) -or $name -ieq $env:USERNAME -or $user.SID.Value -match '-(500|501|503|504)$') {
            Write-Result 'SKIPPED' "Refusing to disable protected/authorized account $name"
            continue
        }
        Decide "Disable unauthorized user $name" ([bool]$user.Enabled) {
            Note "Original user state: $name SID=$($user.SID.Value) enabled=$($user.Enabled)"
            Disable-LocalUser -Name $name
        }
    }
    foreach ($name in (Names (Get-Value $script:Cfg 'RemoveUsers'))) {
        if (-not $AllowRemovals) { Write-Result 'REVIEW' "User removal pending -AllowRemovals: $name"; continue }
        $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
        if (-not $user) { Write-Result 'OK' "User already absent: $name"; continue }
        if ((Is-Listed $name $script:Authorized) -or $name -ieq $env:USERNAME -or $user.SID.Value -match '-(500|501|503|504)$') {
            Write-Result 'SKIPPED' "Refusing to delete protected/authorized account $name"
            continue
        }
        $members = @(Get-LocalGroupMember -Group $adminGroup.Name -ErrorAction SilentlyContinue)
        if ($members.Count -le 1 -and @($members | Where-Object { $_.SID.Value -eq $user.SID.Value }).Count) {
            Write-Result 'SKIPPED' "Cannot remove last administrator: $name"
            continue
        }
        Decide "Delete unauthorized user $name (profile stays)" $true {
            Note "Deleting user $name SID=$($user.SID.Value); account deletion is not reversible."
            Remove-LocalUser -Name $name
        }
    }
}
function Invoke-AutoPasswordPolicy {
    if ($script:domainJoined) { Write-Result 'REVIEW' 'Password policy belongs to effective domain GPO. Skipped local import.'; return }
    $obj = Get-Value $script:Cfg 'PasswordPolicy'
    if (-not $obj) { Write-Result 'SKIPPED' 'No image-specific password policy set in JSON.'; return }
    $allowed = @('MinimumPasswordLength','PasswordHistorySize','MinimumPasswordAge','MaximumPasswordAge','PasswordComplexity','ClearTextPassword','LockoutBadCount','LockoutDuration','ResetLockoutCount')
    $wanted = @()
    foreach ($prop in $obj.PSObject.Properties) {
        if ($prop.Name -notin $allowed) { Write-Result 'REVIEW' "Unknown password policy key $($prop.Name)"; continue }
        $n = 0
        if (-not [int]::TryParse(([string]$prop.Value),[ref]$n)) { Write-Result 'REVIEW' "Invalid policy number: $($prop.Name)"; continue }
        if ($n -lt 0 -or $n -gt 9999) { Write-Result 'REVIEW' "Out of range policy number: $($prop.Name)"; continue }
        if ($prop.Name -in @('PasswordComplexity','ClearTextPassword') -and $n -notin @(0,1)) {
            Write-Result 'REVIEW' "Binary policy must be 0 or 1: $($prop.Name)"
            continue
        }
        $wanted += "$($prop.Name) = $n"
    }
    if (-not $wanted.Count) { Write-Result 'SKIPPED' 'No valid numeric password settings supplied.'; return }
    if ($Mode -eq 'Audit') { Write-Result 'WOULD' ('Set password policy: ' + ($wanted -join '; ')); return }
    try {
        $before = Join-Path $script:BackupDir 'account-policy-before.inf'
        & secedit.exe /export /cfg $before /areas SECURITYPOLICY | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Could not export current account policy' }
        $file = Join-Path $script:BackupDir 'account-policy-requested.inf'
        $db = Join-Path $script:BackupDir 'account-policy.sdb'
        $content = @('[Unicode]','Unicode=yes','','[System Access]') + $wanted +
            @('','[Version]','signature="$CHICAGO$"','Revision=1')
        $content | Set-Content -LiteralPath $file -Encoding Unicode
        & secedit.exe /configure /db $db /cfg $file /areas SECURITYPOLICY /quiet | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'secedit reported failure; consult secedit log' }
        Write-Result 'CHANGED' ('Requested password policy applied; confirm in secpol.msc: ' + ($wanted -join ', '))
    } catch { Write-Result 'FAILED' ('Password policy: ' + $_.Exception.Message) }
}

function Invoke-AutoUserRights {
    if ($script:domainJoined) { Write-Result 'REVIEW' 'User-rights policy may be managed by domain GPO; skipped.'; return }
    $desired = Get-Value $script:Cfg 'RemoveUserRights'
    if (-not $desired) { return }
    $allowed = @('SeSecurityPrivilege','SeTakeOwnershipPrivilege','SeDebugPrivilege','SeBackupPrivilege','SeRestorePrivilege','SeLoadDriverPrivilege','SeRemoteInteractiveLogonRight')
    $currentPolicy = Join-Path $script:BackupDir 'user-rights-before.inf'
    & secedit.exe /export /cfg $currentPolicy /areas USER_RIGHTS | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Result 'FAILED' 'User rights export failed; no changes made.'; return }
    foreach ($entry in $desired.PSObject.Properties) {
        $rightName = [string]$entry.Name
        if ($rightName -notin $allowed) {
            Write-Result 'REVIEW' "Unsupported user right $rightName; use secpol.msc."
            continue
        }
        foreach ($name in (Names $entry.Value)) {
            if ($name -ieq $env:USERNAME -or (Is-Listed $name $script:Authorized)) {
                Write-Result 'SKIPPED' "Refusing to remove rights from current or authorized user $name"
                continue
            }
            $sid = $null
            try {
                $sid = (New-Object System.Security.Principal.NTAccount -ArgumentList $name).Translate(
                    [System.Security.Principal.SecurityIdentifier]).Value
            } catch {
                Write-Result 'REVIEW' "Cannot resolve user-rights principal: $name"
                continue
            }
            if ($sid -match '^S-1-5-32-' -or $sid -match '-(500|501|503|504)$') {
                Write-Result 'SKIPPED' "Refusing built-in user or group right change: $name"
                continue
            }
            $current = Join-Path $script:BackupDir 'user-rights-current.inf'
            & secedit.exe /export /cfg $current /areas USER_RIGHTS | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Result 'FAILED' 'Cannot inspect effective user rights.'
                continue
            }
            $body = Get-Content -LiteralPath $current -Raw
            $pattern = '(?m)^\s*' + [regex]::Escape($rightName) + '\s*=\s*(.*)$'
            $match = [regex]::Match($body,$pattern)
            if (-not $match.Success) {
                Write-Result 'REVIEW' "User-rights entry not found: $rightName"
                continue
            }
            $members = @($match.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            $remaining = @($members | Where-Object {
                $_ -ne ('*' + $sid) -and $_ -ne $sid -and $_ -ine $name -and $_ -notlike ('*\' + $name)
            })
            if ($remaining.Count -eq $members.Count) { Write-Result 'OK' "User $name does not have right $rightName"; continue }
            if (-not $remaining.Count) {
                Write-Result 'SKIPPED' "Refusing to leave $rightName with no principals."
                continue
            }
            $inf = Join-Path $script:BackupDir ('rights-' + [Guid]::NewGuid().ToString('N') + '.inf')
            $db = Join-Path $script:BackupDir ('rights-' + [Guid]::NewGuid().ToString('N') + '.sdb')
            @('[Unicode]','Unicode=yes','','[Privilege Rights]',($rightName + ' = ' + ($remaining -join ',')),
                '','[Version]','signature="$CHICAGO$"','Revision=1') |
                Set-Content -LiteralPath $inf -Encoding Unicode
            & secedit.exe /configure /db $db /cfg $inf /areas USER_RIGHTS /quiet | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Result 'FAILED' "Could not remove $name from $rightName. See exported backup."
            } else {
                Write-Result 'CHANGED' "Removed $name from $rightName; verify in secpol.msc."
            }
        }
    }
}

function Invoke-AutoSecurity {
    $sec = $script:Sec
    if ([bool](Get-Value $sec 'RestrictBlankPasswordNetwork' $false)) {
        Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'LimitBlankPasswordUse' 1
    }
    if ([bool](Get-Value $sec 'SmartScreen' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableSmartScreen' 1
    }
    if ([bool](Get-Value $sec 'DisableAutoPlay' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 255
    }
    if ([bool](Get-Value $sec 'DisableLLMNR' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' 'EnableMulticast' 0
    }
    if ([bool](Get-Value $sec 'HideLastSignedIn' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'DontDisplayLastUserName' 1
    }
    if ([bool](Get-Value $sec 'DisableAdminEnumeration' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI' 'EnumerateAdministrators' 0
    }
    if ([bool](Get-Value $sec 'AutomaticWindowsUpdates' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoUpdate' 0
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'AUOptions' 4
    }
    if ([bool](Get-Value $sec 'DisableWDigest' $false)) {
        Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' 'UseLogonCredential' 0
    }
    $seconds = Get-Value $sec 'LockScreenSeconds'
    if ($null -ne $seconds) {
        if ([int]$seconds -lt 60 -or [int]$seconds -gt 86400) {
            Write-Result 'REVIEW' 'LockScreenSeconds must be between 60 and 86400.'
        } else {
            Put-RegDword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'InactivityTimeoutSecs' ([int]$seconds)
        }
    }
    if ([bool](Get-Value $sec 'DisableRemoteAssistance' $false)) {
        Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowToGetHelp' 0
    }
    if ([bool](Get-Value $sec 'PowerShellLogging' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' 'EnableScriptBlockLogging' 1
    }
    if ([bool](Get-Value $sec 'EnableUAC' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'EnableLUA' 1
        Put-RegDword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'ConsentPromptBehaviorAdmin' 2
        Put-RegDword 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'PromptOnSecureDesktop' 1
        Write-Result 'REVIEW' 'UAC may require restarting Windows; test administrative elevation.'
    }
    if ([bool](Get-Value $sec 'RestrictAnonymous' $false)) {
        Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymousSAM' 1
        Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymous' 1
    }
    if ([bool](Get-Value $sec 'DisableLMHash' $false)) {
        Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'NoLMHash' 1
    }
    if ([bool](Get-Value $sec 'RequireNTLMv2' $false)) {
        Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'LmCompatibilityLevel' 5
        Write-Result 'REVIEW' 'NTLMv2-only may break legacy clients; test required file shares/authentication.'
    }
    if ([bool](Get-Value $sec 'ProtectPrintDrivers' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint' 'RestrictDriverInstallationToAdministrators' 1
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint' 'NoWarningNoElevationOnInstall' 0
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint' 'UpdatePromptSettings' 0
        Write-Result 'REVIEW' 'Print-driver policy changed; verify required printers and driver installs.'
    }
    if ([bool](Get-Value $sec 'RequireRdpNla' $false)) {
        if (Is-Listed 'TermService' $script:RequiredServices) {
            Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' 'UserAuthentication' 1
            Write-Result 'REVIEW' 'Verify authorized RDP clients still connect using NLA.'
        } else {
            Write-Result 'REVIEW' 'RDP NLA was requested, but TermService is not marked required in JSON.'
        }
    }
    if ([bool](Get-Value $sec 'DisableNetBIOS' $false)) {
        if ($script:RequiredShares.Count -gt 0 -or (Is-Listed 'LanmanServer' $script:RequiredServices)) {
            Write-Result 'SKIPPED' 'NetBIOS change skipped because file sharing is listed as required.'
        } else {
            $adapters = @(Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
            $adapters | Select-Object Description,Index,TcpipNetbiosOptions |
                Export-Csv -LiteralPath (Join-Path $script:BackupDir 'netbios-before.csv') -NoTypeInformation
            foreach ($adapter in $adapters) {
                if ($adapter.TcpipNetbiosOptions -eq 2) { continue }
                Decide "Disable NetBIOS on adapter $($adapter.Index)" $true {
                    $result = Invoke-CimMethod -InputObject $adapter -MethodName SetTcpipNetbios -Arguments @{TcpipNetbiosOptions=2}
                    if ($result.ReturnValue -notin @(0,1)) { throw "NetBIOS adapter result $($result.ReturnValue)" }
                }
            }
            Write-Result 'REVIEW' 'Verify required connectivity after NetBIOS changes.'
        }
    }
    if ([bool](Get-Value $sec 'DisableRDP' $false)) {
        if ($env:SESSIONNAME -like 'RDP*' -or (Is-Listed 'TermService' $script:RequiredServices)) {
            Write-Result 'SKIPPED' 'Remote Desktop required or script running from RDP; cannot disable.'
        } else {
            Put-RegDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' 1
        }
    }
}
function Invoke-AutoDefender {
    if (-not (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue)) {
        Write-Result 'REVIEW' 'Microsoft Defender cmdlets unavailable; check Windows Security.'
        return
    }
    if ([bool](Get-Value $script:Sec 'Defender' $false)) {
        $status = Get-MpComputerStatus
        Decide 'Enable Microsoft Defender realtime protection' (-not $status.RealTimeProtectionEnabled) {
            Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
        }
        $pref = Get-MpPreference
        Decide 'Enable Defender potentially unwanted application blocking' ($pref.PUAProtection -ne 1) {
            Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
        }
    }
    if ([bool](Get-Value $script:Sec 'DefenderSignatures' $false)) {
        try {
            Update-MpSignature -ErrorAction Stop
            Write-Result 'CHANGED' 'Defender signature update requested; verify antivirus age.'
        } catch { Write-Result 'REVIEW' ('Defender signatures could not update: ' + $_.Exception.Message) }
    }
    if ([bool](Get-Value $script:Sec 'DefenderQuickScan' $false)) {
        Write-Result 'REVIEW' 'Defender quick scan can quarantine evidence; execute separately after forensics are saved.'
    }
    foreach ($name in (Names (Get-Value $script:Cfg 'RemoveDefenderExclusions'))) {
        $paths = @(Get-MpPreference).ExclusionPath
        Decide "Remove exact Defender path exclusion $name" ($name -in $paths) {
            Remove-MpPreference -ExclusionPath $name -ErrorAction Stop
        }
    }
}
function Invoke-AutoFirewall {
    if (-not [bool](Get-Value $script:Sec 'Firewall' $false)) { return }
    $profiles = @(Get-NetFirewallProfile)
    $off = @($profiles | Where-Object { -not $_.Enabled })
    Decide 'Enable Domain, Private and Public firewall profiles' ($off.Count -gt 0) {
        $profiles | Export-Clixml -LiteralPath (Join-Path $script:BackupDir 'firewall-profiles-before.xml')
        Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
        $remaining = @(Get-NetFirewallProfile | Where-Object { -not $_.Enabled })
        if ($remaining.Count) { throw "Firewall remains disabled on $($remaining.Name -join ', ')" }
    }
    Write-Result 'REVIEW' 'Firewall allow rules and required inbound application connectivity still need per-image review.'
}
function Invoke-AutoSMB {
    if ([bool](Get-Value $script:Sec 'SMBClientSigning' $false)) {
        $old = (Get-SmbClientConfiguration).RequireSecuritySignature
        Decide 'Require SMB client signing' (-not $old) {
            $old | Set-Content -LiteralPath (Join-Path $script:BackupDir 'smb-client-signing-before.txt')
            Set-SmbClientConfiguration -RequireSecuritySignature $true -Confirm:$false
        }
    }
    if ([bool](Get-Value $script:Sec 'SMBServerSigning' $false)) {
        $current = (Get-SmbServerConfiguration).RequireSecuritySignature
        Decide 'Require SMB server signing' (-not $current) {
            $current | Set-Content -LiteralPath (Join-Path $script:BackupDir 'smb-server-signing-before.txt')
            Set-SmbServerConfiguration -RequireSecuritySignature $true -Confirm:$false
        }
        Write-Result 'REVIEW' 'Verify authorized SMB clients and file shares after requiring server signing.'
    }
    if ([bool](Get-Value $script:Sec 'DisableSMB1' $false)) {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
        if ($feature -and $feature.State -eq 'Enabled') {
            Decide 'Disable legacy SMB1 (may need restart)' $true {
                $feature | Export-Clixml -LiteralPath (Join-Path $script:BackupDir 'smb1-before.xml')
                Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart | Out-Null
            }
        } else { Write-Result 'OK' 'SMB1 is already absent/disabled.' }
    }
}
function Invoke-AutoAudit {
    if (-not [bool](Get-Value $script:Sec 'CredentialAuditSuccess' $false)) { return }
    try {
        $before = (& auditpol.exe /get /subcategory:'Credential Validation' | Out-String)
        $before | Set-Content -LiteralPath (Join-Path $script:BackupDir 'credential-audit-before.txt')
        & auditpol.exe /set /subcategory:'Credential Validation' /success:enable | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'auditpol failed; check OS language or domain GPO.' }
        Write-Result 'CHANGED' 'Credential Validation Success audit enabled; verify policy.'
    } catch { Write-Result 'REVIEW' ('Credential Validation audit: ' + $_.Exception.Message) }
}


function Invoke-AutoFirewallRules {
    $names = Names (Get-Value $script:Cfg 'DisableFirewallRules')
    if (-not $names.Count) { return }
    $backup = Join-Path $script:BackupDir 'firewall-policy-before.wfw'
    & netsh.exe advfirewall export $backup | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Result 'FAILED' 'Firewall policy backup failed; no rules will be disabled.'
        return
    }
    foreach ($name in $names) {
        if ($name.Contains('*') -or $name.Contains('?')) {
            Write-Result 'REVIEW' "Use the exact internal firewall rule Name, not a wildcard: $name"
            continue
        }
        $rules = @(Get-NetFirewallRule -Name $name -ErrorAction SilentlyContinue)
        if ($rules.Count -ne 1) {
            Write-Result 'REVIEW' "Firewall rule $name was not uniquely found (count=$($rules.Count))."
            continue
        }
        $rule = $rules[0]
        if ($rule.Action -ne 'Allow' -or $rule.Direction -ne 'Inbound') {
            Write-Result 'REVIEW' "Not an inbound Allow rule: $name"
            continue
        }
        if ($rule.DisplayGroup -match 'Remote Desktop|File and Printer|Windows Remote Management' -and
            ((Is-Listed 'TermService' $script:RequiredServices) -or $script:RequiredShares.Count -gt 0)) {
            Write-Result 'SKIPPED' "Rule belongs to a potentially required service group: $name"
            continue
        }
        $filters = @(Get-NetFirewallPortFilter -AssociatedNetFirewallRule $rule -ErrorAction SilentlyContinue)
        $requiredPorts = Names (Get-Value $script:Cfg 'RequiredPorts')
        $needed = $false
        foreach ($filter in $filters) {
            foreach ($p in $requiredPorts) {
                if ([string]$filter.LocalPort -eq $p -or [string]$filter.RemotePort -eq $p) { $needed = $true }
            }
        }
        if ($needed) { Write-Result 'SKIPPED' "Firewall rule $name includes a configured required port."; continue }
        Decide "Disable exact inbound firewall rule $name ($($rule.DisplayName))" ($rule.Enabled -eq 'True') {
            $rule | Export-Clixml -LiteralPath (Join-Path $script:BackupDir ("firewall-rule-" + [Guid]::NewGuid().ToString('N') + ".xml"))
            Disable-NetFirewallRule -Name $name -ErrorAction Stop
            if ((Get-NetFirewallRule -Name $name).Enabled -ne 'False') { throw 'Firewall rule still enabled' }
        }
    }
    Write-Result 'REVIEW' 'Retest all README-required network services after firewall-rule changes.'
}


function Invoke-AutoAuditSubcategories {
    $requested = Get-Value $script:Cfg 'AuditSubcategories'
    if (-not $requested) { return }
    $entries = @($requested.PSObject.Properties)
    if (-not $entries.Count) { return }
    if ($script:domainJoined) {
        Write-Result 'REVIEW' 'Domain policy can override advanced auditing; skipped local edits.'
        return
    }
    $backup = Join-Path $script:BackupDir 'audit-policy-before.csv'
    & auditpol.exe /backup "/file:$backup" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Result 'FAILED' 'Audit-policy backup failed; no advanced audit changes made.'
        return
    }
    foreach ($entry in $entries) {
        $name = [string]$entry.Name
        $value = [string]$entry.Value
        if ($name -notmatch '^[a-zA-Z0-9 ._-]{3,80}$') {
            Write-Result 'REVIEW' "Invalid audit subcategory: $name"
            continue
        }
        if ($value -notin @('Success','Failure','SuccessAndFailure')) {
            Write-Result 'REVIEW' "Audit $name value must be Success, Failure or SuccessAndFailure."
            continue
        }
        $success = if ($value -in @('Success','SuccessAndFailure')) { 'enable' } else { 'disable' }
        $failure = if ($value -in @('Failure','SuccessAndFailure')) { 'enable' } else { 'disable' }
        try {
            & auditpol.exe /set "/subcategory:$name" "/success:$success" "/failure:$failure" | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'auditpol returned error; check policy scope and localization' }
            Write-Result 'CHANGED' "Audit $name set to $value; verify effective policy."
        } catch {
            Write-Result 'FAILED' ("Audit " + $name + ": " + $_.Exception.Message)
        }
    }
}


function Save-Discovery([string]$Name, [scriptblock]$Command) {
    $file = Join-Path $script:BackupDir ("review-" + $Name + ".csv")
    try {
        $rows = @(& $Command)
        if ($rows.Count) {
            $rows | Export-Csv -LiteralPath $file -NoTypeInformation -Encoding UTF8
        } else {
            "No entries found for $Name" | Set-Content -LiteralPath $file -Encoding UTF8
        }
        Write-Result 'REVIEW' "Inspection saved: $file ($($rows.Count) entries)"
    } catch {
        Write-Result 'REVIEW' ("Inspection unavailable ($Name): " + $_.Exception.Message)
    }
}
function Invoke-AutoDiscovery {
    Save-Discovery 'startup-registry' {
        foreach ($path in @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
            'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
            'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
        )) {
            if (-not (Test-Path -LiteralPath $path)) { continue }
            $obj = Get-ItemProperty -LiteralPath $path
            foreach ($prop in $obj.PSObject.Properties) {
                if ($prop.Name -match '^PS(Path|ParentPath|ChildName|Drive|Provider)$') { continue }
                [pscustomobject]@{Path=$path;Name=$prop.Name;Command=[string]$prop.Value}
            }
        }
    }
    Save-Discovery 'ifeo-debuggers' {
        $base = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
        foreach ($key in (Get-ChildItem $base -ErrorAction SilentlyContinue)) {
            $debugger = (Get-ItemProperty -LiteralPath $key.PSPath -Name Debugger -ErrorAction SilentlyContinue).Debugger
            if ($debugger) { [pscustomobject]@{Executable=$key.PSChildName;Debugger=$debugger;Key=$key.Name} }
        }
    }
    Save-Discovery 'services-and-paths' {
        Get-CimInstance Win32_Service | Select-Object Name,DisplayName,State,StartMode,StartName,PathName
    }
    Save-Discovery 'listening-processes' {
        foreach ($conn in @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue)) {
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            [pscustomobject]@{
                Address=$conn.LocalAddress;Port=$conn.LocalPort;Pid=$conn.OwningProcess
                Process=if($process){$process.ProcessName}else{''}
                Executable=if($process){try{$process.Path}catch{''}}else{''}
            }
        }
    }
    Save-Discovery 'inbound-firewall-allow' {
        Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True -ErrorAction SilentlyContinue |
            Select-Object Name,DisplayName,DisplayGroup,Profile,Enabled
    }
    Save-Discovery 'installed-store-apps' {
        Get-AppxPackage -AllUsers -ErrorAction Stop |
            Select-Object Name,PackageFullName,Publisher,NonRemovable
    }
    Save-Discovery 'share-permissions' {
        foreach ($share in (Get-SmbShare -ErrorAction SilentlyContinue)) {
            foreach ($access in @(Get-SmbShareAccess -Name $share.Name -ErrorAction SilentlyContinue)) {
                [pscustomobject]@{Share=$share.Name;Path=$share.Path;Account=$access.AccountName;Access=$access.AccessRight;Control=$access.AccessControlType}
            }
        }
    }
    Save-Discovery 'hosts-file' {
        $hosts = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'
        $n = 0
        foreach ($entry in (Get-Content -LiteralPath $hosts -ErrorAction Stop)) {
            $n++
            if ($entry.Trim() -and $entry.Trim() -notmatch '^#') {
                [pscustomobject]@{Line=$n;Entry=$entry.Trim()}
            }
        }
    }
    Save-Discovery 'recent-security-events' {
        Get-WinEvent -FilterHashtable @{LogName='Security';Id=4624,4625,4720,4732,1102} -MaxEvents 75 -ErrorAction Stop |
            Select-Object TimeCreated,Id,ProviderName,LevelDisplayName,Message
    }
    Save-Discovery 'recent-service-installations' {
        Get-WinEvent -FilterHashtable @{LogName='System';Id=7045} -MaxEvents 40 -ErrorAction Stop |
            Select-Object TimeCreated,Id,ProviderName,Message
    }
    $roots = @(
        (Join-Path $env:PUBLIC 'Downloads'),
        (Join-Path $env:PUBLIC 'Desktop'),
        (Join-Path $env:PUBLIC 'Documents'),
        (Join-Path $env:USERPROFILE 'Downloads'),
        (Join-Path $env:USERPROFILE 'Desktop'),
        'C:\Temp'
    ) + @(Names (Get-Value $script:Cfg 'ScanPaths'))
    Save-Discovery 'suspicious-file-candidates' {
        $extensions = @('.mp3','.mp4','.torrent','.zip','.7z','.rar','.pcap','.kdbx','.exe','.ps1','.bat')
        $seen = @{}
        foreach ($path in $roots) {
            if (-not (Test-Path -LiteralPath $path -PathType Container)) { continue }
            $folder = (Resolve-Path -LiteralPath $path).Path
            if ($folder -match '(?i)\\Windows\\|\\Program Files') { continue }
            if ($seen.ContainsKey($folder)) { continue }
            $seen[$folder] = $true
            Get-ChildItem -LiteralPath $folder -File -Recurse -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.Extension -in $extensions } |
                Select-Object -First 250 FullName,Length,LastWriteTime,Extension
        }
    }
    Write-Result 'REVIEW' 'Discovery findings are leads, not proof of malware. Confirm against the active image README.'
}
function Invoke-AutoStartupAndIFEO {
    $allowed = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
    )
    foreach ($item in @(Get-Value $script:Cfg 'RemoveStartupValues' @())) {
        $path = [string](Get-Value $item 'Path' '')
        $name = [string](Get-Value $item 'Name' '')
        if ($path -notin $allowed -or [string]::IsNullOrWhiteSpace($name)) {
            Write-Result 'REVIEW' "Invalid startup entry; supply exact allowed Run/RunOnce path and value Name."
            continue
        }
        if ($name -match '^(SecurityHealth|WindowsDefender|OneDrive)' -or $name.Contains('*')) {
            Write-Result 'SKIPPED' "Protected or wildcard startup entry: $name"
            continue
        }
        $value = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
        if (-not $value) { Write-Result 'OK' "Startup value absent: $path $name"; continue }
        Decide "Remove confirmed unauthorized startup value $name" $true {
            Save-RegKey $path
            Remove-ItemProperty -Path $path -Name $name -ErrorAction Stop
            if (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue) {
                throw 'Startup entry still exists'
            }
        }
    }
    $base = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
    $allowedExecutables = @('sethc.exe','utilman.exe','osk.exe','magnify.exe','narrator.exe')
    foreach ($file in (Names (Get-Value $script:Cfg 'ClearIFEO'))) {
        if ($file -notin $allowedExecutables) {
            Write-Result 'REVIEW' "IFEO target $file not in the guarded accessibility-executable allowlist."
            continue
        }
        $path = Join-Path $base $file
        $debugger = (Get-ItemProperty -Path $path -Name Debugger -ErrorAction SilentlyContinue).Debugger
        if (-not $debugger) { Write-Result 'OK' "No IFEO Debugger for $file"; continue }
        Decide "Remove configured IFEO debugger from $file" $true {
            Save-RegKey $path
            Remove-ItemProperty -Path $path -Name Debugger -ErrorAction Stop
        }
    }
}


function Invoke-AutoAppx {
    foreach ($name in (Names (Get-Value $script:Cfg 'RemoveAppxPackages'))) {
        if (-not $AllowRemovals) {
            Write-Result 'REVIEW' "Store app removal requires -AllowRemovals: $name"
            continue
        }
        if ($name.Contains('*') -or $name.Contains('?') -or $name -match '^Microsoft\.(Windows|VCLibs|NET|UI|DesktopAppInstaller)') {
            Write-Result 'SKIPPED' "Protected or wildcard Store app: $name"
            continue
        }
        if (Is-Listed $name $script:RequiredSoftware) {
            Write-Result 'SKIPPED' "Required Store app: $name"
            continue
        }
        $packages = @(Get-AppxPackage -AllUsers -Name $name -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ieq $name })
        if (-not $packages.Count) { Write-Result 'OK' "Store app absent: $name"; continue }
        foreach ($package in $packages) {
            if ($package.NonRemovable) { Write-Result 'SKIPPED' "Non-removable Store app: $name"; continue }
            Decide "Remove explicitly prohibited Store app $($package.PackageFullName)" $true {
                $package | Export-Clixml -LiteralPath (Join-Path $script:BackupDir ("appx-" + [Guid]::NewGuid().ToString('N') + ".xml"))
                Remove-AppxPackage -AllUsers -Package $package.PackageFullName -ErrorAction Stop
            }
        }
        Write-Result 'REVIEW' "Check provisioned versions and per-user registration of $name separately."
    }
}
function Invoke-AutoShareAccess {
    foreach ($item in @(Get-Value $script:Cfg 'RemoveShareAccess' @())) {
        $shareName = [string](Get-Value $item 'Share' '')
        $account = [string](Get-Value $item 'Account' '')
        if ([string]::IsNullOrWhiteSpace($shareName) -or [string]::IsNullOrWhiteSpace($account)) {
            Write-Result 'REVIEW' 'RemoveShareAccess needs exact Share and Account properties.'
            continue
        }
        if ($shareName -in @('ADMIN$','C$','IPC$','print$') -or $account -match '^(SYSTEM|Administrators)$') {
            Write-Result 'SKIPPED' "Protected share or principal: $shareName / $account"
            continue
        }
        if (-not $AllowRemovals) {
            Write-Result 'REVIEW' "Share permission removal needs -AllowRemovals: $shareName / $account"
            continue
        }
        $share = Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue
        if (-not $share -or $share.Special) { Write-Result 'SKIPPED' "Share missing/protected: $shareName"; continue }
        $acl = @(Get-SmbShareAccess -Name $shareName -ErrorAction Stop)
        $target = @($acl | Where-Object { $_.AccountName -ieq $account })
        if (-not $target.Count) { Write-Result 'OK' "No share permission found: $account on $shareName"; continue }
        Decide "Revoke exact share permission $shareName / $account" $true {
            $acl | Export-Clixml -LiteralPath (Join-Path $script:BackupDir ("share-acl-" + [Guid]::NewGuid().ToString('N') + ".xml"))
            Revoke-SmbShareAccess -Name $shareName -AccountName $account -Force -Confirm:$false -ErrorAction Stop | Out-Null
        }
        Write-Result 'REVIEW' "Verify required users can still access share $shareName, and inspect NTFS ACL separately."
    }
}

function Invoke-AutoServices {
    $protected = @('RpcSs','DcomLaunch','EventLog','BFE','mpssvc','WinDefend','Winmgmt','Schedule','Appinfo','ProfSvc','CryptSvc','PlugPlay','LanmanWorkstation','LanmanServer','SamSs','LSM','gpsvc','W32Time')
    foreach ($name in (Names (Get-Value $script:Cfg 'DisableServices'))) {
        if ($name -in $protected -or (Is-Listed $name $script:RequiredServices)) {
            Write-Result 'SKIPPED' "Service $name protected or required by README."
            continue
        }
        if ($name -in @('TermService','WinRM','W3SVC','FTPSVC','Spooler','sshd','RemoteAccess','SharedAccess')) {
            Write-Result 'REVIEW' "High-impact service $name needs manual dependency/role verification; not stopped automatically."
            continue
        }
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $svc) { Write-Result 'OK' "Service not installed: $name"; continue }
        $dependents = @($svc.DependentServices | Where-Object { $_.Status -eq 'Running' })
        if ($dependents.Count) {
            Write-Result 'SKIPPED' ("Service $name has running dependencies: " + ($dependents.Name -join ', '))
            continue
        }
        $unneeded = $svc.Status -ne 'Stopped' -or $svc.StartType -ne 'Disabled'
        Decide "Stop and disable unneeded service $name" $unneeded {
            $detail = Get-CimInstance Win32_Service -Filter ("Name='" + $name.Replace("'","''") + "'")
            $detail | Select-Object Name,State,StartMode,StartName,PathName |
                Export-Clixml -LiteralPath (Join-Path $script:BackupDir ("service-" + $name + ".xml"))
            if ($svc.Status -eq 'Running') { Stop-Service -Name $name -ErrorAction Stop }
            Set-Service -Name $name -StartupType Disabled -ErrorAction Stop
        }
    }
    foreach ($name in (Names (Get-Value $script:Cfg 'RequiredServices'))) {
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $svc) { Write-Result 'REVIEW' "README-required service is absent: $name"; continue }
        if ($svc.Status -ne 'Running') {
            Write-Result 'REVIEW' "README-required service $name is $($svc.Status); check expected start mode/dependencies."
        } else { Write-Result 'OK' "Required service running: $name" }
    }
}
function Invoke-AutoFeatures {
    $allowed = @('SMB1Protocol','MicrosoftWindowsPowerShellV2','TelnetClient','TFTP','SimpleTCP','SNMP','WindowsMediaPlayer')
    foreach ($name in (Names (Get-Value $script:Cfg 'DisableFeatures'))) {
        if ($name -notin $allowed) { Write-Result 'REVIEW' "Optional feature $name not on supported disable list."; continue }
        if (Is-Listed $name $script:RequiredServices) { Write-Result 'SKIPPED' "Feature required: $name"; continue }
        $item = Get-WindowsOptionalFeature -Online -FeatureName $name -ErrorAction SilentlyContinue
        if (-not $item) { Write-Result 'OK' "Optional feature absent: $name"; continue }
        Decide "Disable optional feature $name (restart may be needed)" ($item.State -eq 'Enabled') {
            $item | Export-Clixml -LiteralPath (Join-Path $script:BackupDir ("feature-" + $name + ".xml"))
            Disable-WindowsOptionalFeature -Online -FeatureName $name -NoRestart -ErrorAction Stop | Out-Null
        }
    }
}
function Invoke-AutoTasks {
    foreach ($full in (Names (Get-Value $script:Cfg 'DisableScheduledTasks'))) {
        if (-not $full.StartsWith('\')) {
            Write-Result 'REVIEW' "Task path must begin with a backslash: $full"
            continue
        }
        $index = $full.LastIndexOf('\')
        if ($index -lt 0 -or $index -eq $full.Length - 1) {
            Write-Result 'REVIEW' "Invalid task name: $full"
            continue
        }
        $taskName = $full.Substring($index + 1)
        $taskPath = $full.Substring(0, $index + 1)
        if ($taskPath -like '\Microsoft\Windows\*') {
            Write-Result 'SKIPPED' "Protected Microsoft scheduled task: $full"
            continue
        }
        $task = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue
        if (-not $task) { Write-Result 'OK' "Scheduled task absent: $full"; continue }
        Decide "Disable confirmed unauthorized scheduled task $full" ($task.State -ne 'Disabled') {
            $xml = Export-ScheduledTask -TaskName $taskName -TaskPath $taskPath
            $xml | Set-Content -LiteralPath (Join-Path $script:BackupDir ("task-" + [Guid]::NewGuid().ToString('N') + '.xml'))
            Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName | Out-Null
        }
    }
    $other = @(Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
        $_.TaskPath -notlike '\Microsoft\*' -and $_.State -ne 'Disabled'
    } | Select-Object -First 50 TaskPath,TaskName,State)
    $other | Export-Csv -Path (Join-Path $script:BackupDir 'task-inventory.csv') -NoTypeInformation
    Write-Result 'REVIEW' "Review non-Microsoft scheduled tasks ($($other.Count) sampled) for unauthorized persistence."
}
function Invoke-AutoShares {
    foreach ($name in (Names (Get-Value $script:Cfg 'RemoveShares'))) {
        if (-not $AllowRemovals) { Write-Result 'REVIEW' "Share removal needs -AllowRemovals: $name"; continue }
        if (Is-Listed $name $script:RequiredShares) { Write-Result 'SKIPPED' "Required share: $name"; continue }
        $share = Get-SmbShare -Name $name -ErrorAction SilentlyContinue
        if (-not $share) { Write-Result 'OK' "Share already absent: $name"; continue }
        if ($share.Special -or $name -in @('ADMIN$','C$','IPC$','print$')) {
            Write-Result 'SKIPPED' "System/administrative share is protected: $name"
            continue
        }
        Decide "Remove unauthorized custom share $name" $true {
            $backup = Join-Path $script:BackupDir ("share-" + $name.Replace('$','_') + ".txt")
            ($share | Format-List * | Out-String) | Set-Content -LiteralPath $backup
            (Get-SmbShareAccess -Name $name | Format-Table -AutoSize | Out-String) | Add-Content -LiteralPath $backup
            Remove-SmbShare -Name $name -Force -Confirm:$false
        }
    }
}


function Invoke-AutoApps {
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    $installed = @()
    try {
        $paths = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                   'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                   'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
        $installed = @(Get-ItemProperty -Path $paths -ErrorAction SilentlyContinue |
            Where-Object DisplayName | Select-Object DisplayName,DisplayVersion,Publisher,InstallLocation)
        $installed | Export-Csv -LiteralPath (Join-Path $script:BackupDir 'installed-programs-before.csv') -NoTypeInformation
    } catch { Write-Result 'REVIEW' 'Installed-app inventory unavailable.' }
    foreach ($name in (Names (Get-Value $script:Cfg 'RequiredSoftware'))) {
        if (-not @($installed | Where-Object { $_.DisplayName -ilike ("*" + $name + "*") }).Count) {
            Write-Result 'REVIEW' "README-required software not found in standard uninstall list: $name"
        }
    }
    if (-not $winget) {
        if ((Names (Get-Value $script:Cfg 'UpdatePrograms')).Count -or (Names (Get-Value $script:Cfg 'RemovePrograms')).Count) {
            Write-Result 'REVIEW' 'winget is unavailable; use the approved installer or Installed apps UI.'
        }
        return
    }
    foreach ($id in (Names (Get-Value $script:Cfg 'UpdatePrograms'))) {
        if ($id -notmatch '^[A-Za-z0-9_.+-]+$') { Write-Result 'REVIEW' "Invalid winget package id: $id"; continue }
        try {
            & winget.exe upgrade --id $id --exact --source winget --accept-source-agreements --accept-package-agreements
            if ($LASTEXITCODE -ne 0) { throw "winget exit $LASTEXITCODE" }
            Write-Result 'CHANGED' "winget update attempted for $id; verify installed version and path."
        } catch { Write-Result 'REVIEW' ("Update $id: " + $_.Exception.Message) }
    }
    foreach ($id in (Names (Get-Value $script:Cfg 'RemovePrograms'))) {
        if (-not $AllowRemovals) { Write-Result 'REVIEW' "Package removal needs -AllowRemovals: $id"; continue }
        if (Is-Listed $id $script:RequiredSoftware) { Write-Result 'SKIPPED' "Required software: $id"; continue }
        if ($id -notmatch '^[A-Za-z0-9_.+-]+$') { Write-Result 'REVIEW' "Invalid winget package id: $id"; continue }
        try {
            & winget.exe uninstall --id $id --exact --source winget --accept-source-agreements
            if ($LASTEXITCODE -ne 0) { throw "winget exit $LASTEXITCODE" }
            Write-Result 'CHANGED' "winget uninstall attempted for $id; confirm exact package is gone."
        } catch { Write-Result 'REVIEW' ("Remove $id: " + $_.Exception.Message) }
    }
}
function Invoke-AutoFiles {
    foreach ($path in (Names (Get-Value $script:Cfg 'RemoveFiles'))) {
        if (-not $AllowRemovals) { Write-Result 'REVIEW' "File removal needs -AllowRemovals: $path"; continue }
        $file = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
        if (-not $file) { Write-Result 'OK' "File not found: $path"; continue }
        if ($file.PSIsContainer) { Write-Result 'SKIPPED' "Refusing to delete directory: $path"; continue }
        $protectedRoots = @($env:WINDIR,$env:ProgramFiles,([Environment]::GetEnvironmentVariable('ProgramFiles(x86)')),$root) | Where-Object { $_ }
        $blocked = $false
        foreach ($folder in $protectedRoots) {
            if ($file.FullName.StartsWith(($folder.TrimEnd('\') + '\'),[StringComparison]::OrdinalIgnoreCase)) { $blocked=$true }
        }
        if ($file.FullName -match '(?i)\\CyberPatriot(\\|$)' -or $file.FullName -eq $PSCommandPath) { $blocked=$true }
        if ($blocked) { Write-Result 'SKIPPED' "Protected path requires manual review: $($file.FullName)"; continue }
        Decide "Delete confirmed prohibited file $($file.FullName)" $true {
            $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            Note "Deleting $($file.FullName) SHA256=$hash (not automatically reversible)."
            Remove-Item -LiteralPath $file.FullName -Force
            if (Test-Path -LiteralPath $file.FullName) { throw 'File remained after deletion.' }
        }
    }
}
function Invoke-AutoBrowsers {
    if ([bool](Get-Value $script:Sec 'ChromeBlockPopups' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Google\Chrome' 'DefaultPopupsSetting' 2
    }
    if ([bool](Get-Value $script:Sec 'EdgeBlockPopups' $false)) {
        Put-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'DefaultPopupsSetting' 2
    }
    Write-Result 'REVIEW' 'Verify Chrome, Edge, Firefox and required application updates in Help > About and site settings.'
}
function Invoke-AutoWindowsUpdate {
    $choice = [string](Get-Value $script:Sec 'WindowsUpdate' 'Scan')
    if ($choice -eq 'None') { Write-Result 'SKIPPED' 'Windows Update configured as None'; return }
    if ($choice -notin @('Scan','Install')) { Write-Result 'REVIEW' 'WindowsUpdate must be Scan, Install, or None'; return }
    try {
        $session = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $found = $searcher.Search("IsInstalled=0 and IsHidden=0 and Type='Software'")
        Write-Result 'REVIEW' ("Windows Update: $($found.Updates.Count) software update(s) detected.")
        if ($choice -ne 'Install') { return }
        $updates = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($item in $found.Updates) {
            if ($item.InstallationBehavior.CanRequestUserInput) { continue }
            if (-not $item.EulaAccepted) { $item.AcceptEula() }
            [void]$updates.Add($item)
        }
        if (-not $updates.Count) { Write-Result 'OK' 'No unattended updates eligible for install.'; return }
        $downloader = $session.CreateUpdateDownloader()
        $downloader.Updates = $updates
        $downloadResult = $downloader.Download()
        if ($downloadResult.ResultCode -notin @(2,3)) { throw "Download result $($downloadResult.ResultCode)" }
        $installer = $session.CreateUpdateInstaller()
        $installer.Updates = $updates
        $result = $installer.Install()
        if ($result.ResultCode -notin @(2,3)) { throw "Install result $($result.ResultCode)" }
        Write-Result 'CHANGED' "Windows Update installed or partially installed $($updates.Count) updates; verify in Settings."
        if ($result.RebootRequired) { Write-Result 'REVIEW' 'Restart pending; the script will not reboot automatically.' }
    } catch {
        Write-Result 'REVIEW' ('Windows Update unavailable or incomplete: ' + $_.Exception.Message)
    }
}


function Run-Automation {
    Load-ReadmeConfig
    Check-Workstation
    $script:Results = New-Object System.Collections.ArrayList
    $script:BackupDir = Join-Path $root "backups-$stamp"
    New-Item -ItemType Directory -Path $script:BackupDir -Force | Out-Null

    if (-not $Yes) {
        Write-Host 'This performs all applicable steps from image-config.json in one run.' -ForegroundColor Yellow
        Write-Host 'Read the README and preserve forensics before changing anything.'
        Write-Host 'Account, file, share and program deletion also requires -AllowRemovals.'
        $answer = Read-Host 'Type APPLY to start, or anything else to cancel'
        if ($answer -cne 'APPLY') { Note 'Canceled before changing the system.'; return }
    }
    $modules = @(
        @{ Name='discovery'; Fn='Invoke-AutoDiscovery' },
        @{ Name='accounts';  Fn='Invoke-AutoAccounts' },
        @{ Name='passwords'; Fn='Invoke-AutoPasswordPolicy' },
        @{ Name='rights';    Fn='Invoke-AutoUserRights' },
        @{ Name='security';  Fn='Invoke-AutoSecurity' },
        @{ Name='defender';  Fn='Invoke-AutoDefender' },
        @{ Name='firewall';  Fn='Invoke-AutoFirewall' },
        @{ Name='firewallrules'; Fn='Invoke-AutoFirewallRules' },
        @{ Name='smb';       Fn='Invoke-AutoSMB' },
        @{ Name='audit';     Fn='Invoke-AutoAudit' },
        @{ Name='auditdetails'; Fn='Invoke-AutoAuditSubcategories' },
        @{ Name='services';  Fn='Invoke-AutoServices' },
        @{ Name='features';  Fn='Invoke-AutoFeatures' },
        @{ Name='tasks';     Fn='Invoke-AutoTasks' },
        @{ Name='startup';   Fn='Invoke-AutoStartupAndIFEO' },
        @{ Name='shares';    Fn='Invoke-AutoShares' },
        @{ Name='shareaccess'; Fn='Invoke-AutoShareAccess' },
        @{ Name='browsers';  Fn='Invoke-AutoBrowsers' },
        @{ Name='apps';      Fn='Invoke-AutoApps' },
        @{ Name='storeapps'; Fn='Invoke-AutoAppx' },
        @{ Name='files';     Fn='Invoke-AutoFiles' },
        @{ Name='updates';   Fn='Invoke-AutoWindowsUpdate' }
    )
    Write-Host ''
    Write-Host ("Starting full run: " + $env:COMPUTERNAME) -ForegroundColor Cyan
    Write-Host ("Selected sections: " + $(if ($Only) { $Only -join ', ' } else { 'all' }))
    Write-Host ("Authorized admins: " + (($script:Cfg.AuthorizedAdmins) -join ', '))
    Write-Host ("Required services: " + (($script:RequiredServices) -join ', '))
    Write-Host ''
    try {
        Audit
        Copy-Item -LiteralPath $report -Destination (Join-Path $script:BackupDir 'audit-before.txt') -Force
    } catch { Write-Result 'REVIEW' ('Initial audit unavailable: ' + $_.Exception.Message) }
    foreach ($entry in $modules) {
        if ($Only -and $entry.Name -notin $Only) { continue }
        Write-Host ("---- " + $entry.Name.ToUpper() + " ----") -ForegroundColor Cyan
        try { & $entry.Fn }
        catch { Write-Result 'FAILED' ($entry.Name + ' section failed: ' + $_.Exception.Message) }
    }
    try {
        Audit
        Copy-Item -LiteralPath $report -Destination (Join-Path $script:BackupDir 'audit-after.txt') -Force
    } catch { Write-Result 'REVIEW' ('Final audit unavailable: ' + $_.Exception.Message) }
    Write-Result 'REVIEW' 'Check Scoring Report, forensic answers, working admin login, required apps and remote access.'
    Show-AutomationSummary
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
if ($InitConfig) {
    Initialize-ReadmeConfig
} else {
    switch ($Mode) {
        'Audit' { Audit }
        'Quick' { Quick }
        'Apply' { Run-Automation }
        default { Menu }
    }
}
Write-Host "Change log: $log" -ForegroundColor Green

