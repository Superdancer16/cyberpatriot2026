#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('Menu','Audit','Apply')][string]$Mode = 'Menu',
    [string]$Config,
    [switch]$InitConfig,
    [switch]$List,
    [switch]$Yes,
    [switch]$AllowRemovals,
    [switch]$EnableDomainChanges,
    [switch]$AllowCompatibilityChanges,
    [string[]]$Only
)
$ErrorActionPreference = 'Stop'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$root = Join-Path $env:ProgramData 'ServerSecurityWork'
$backups = Join-Path $root ("backups-" + $stamp)
$log = Join-Path $root ("changes-" + $stamp + ".txt")
$summary = Join-Path $root ("summary-" + $stamp + ".csv")
$report = Join-Path $root ("audit-" + $stamp + ".txt")
$script:Results = New-Object System.Collections.ArrayList
$script:Cfg = $null
$script:IsDC = $false
$script:IsDomainJoined = $false
$script:ActualRole = ''
$script:DomainName = ''
$script:RequiredServices = @()
$script:RequiredRoles = @()
$script:RequiredShares = @()
$script:RequiredApps = @()
$script:RequiredAccounts = @()

function Value($Object, [string]$Name, $Fallback = $null) {
    if ($null -eq $Object) { return $Fallback }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -ne $property) { return $property.Value }
    return $Fallback
}
function Values($InputValue) {
    if ($null -eq $InputValue) { return @() }
    return @($InputValue | ForEach-Object { [string]$_ } | Where-Object { $_.Trim() } | Select-Object -Unique)
}
function Listed([string]$Name, $Items) {
    foreach ($item in (Values $Items)) {
        if ($item -ieq $Name -or $item -ieq ($Name -split '\\')[-1]) { return $true }
    }
    return $false
}
function Init-Workspace {
    New-Item -Path $backups -ItemType Directory -Force | Out-Null
    $acl = Get-Acl -Path $root
    if (-not $acl.AreAccessRulesProtected) {
        Write-Warning 'Check access controls on ProgramData\ServerSecurityWork: reports can contain sensitive account, share and role information.'
    }
    if (-not (Test-Path $log)) { "" | Set-Content -LiteralPath $log -Encoding UTF8 }
}
function Record([string]$State, [string]$Message) {
    [void]$script:Results.Add([pscustomobject]@{Time=(Get-Date -Format 'HH:mm:ss');State=$State;Message=$Message})
    $entry = "$(Get-Date -Format s) [$State] $Message"
    Write-Host $entry
    Add-Content -LiteralPath $log -Value $entry -Encoding UTF8
}
function Change([string]$Name, [bool]$Required, [scriptblock]$Action) {
    if (-not $Required) { Record 'OK' $Name; return }
    if ($Mode -eq 'Audit') { Record 'WOULD' $Name; return }
    try {
        & $Action
        Record 'CHANGED' $Name
    } catch { Record 'FAILED' ($Name + ': ' + $_.Exception.Message) }
}
function Check-Admin {
    $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run PowerShell as Administrator within the Windows Server VM.'
    }
}
function Detect-Server {
    $os = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem
    if ($os.ProductType -eq 1) { throw 'Workstation detected. Use Windows Scripts/windows-10-11.ps1 instead.' }
    if ($os.ProductType -notin @(2,3)) { throw 'Unable to identify Windows Server role.' }
    $script:IsDC = ($os.ProductType -eq 2 -or $computer.DomainRole -ge 4)
    $script:IsDomainJoined = [bool]$computer.PartOfDomain
    $script:DomainName = [string]$computer.Domain
    $script:ActualRole = if ($script:IsDC) { 'DomainController' } elseif ($script:IsDomainJoined) { 'MemberServer' } else { 'StandaloneServer' }
    Record 'INFO' ("OS: " + $os.Caption + "; role: " + $script:ActualRole + "; domain: " + $script:DomainName)
}
function New-Config {
    $out = if ($Config) { $Config } else { Join-Path $PSScriptRoot 'server-config.json' }
    if (Test-Path -LiteralPath $out) { throw "Refusing to overwrite existing file: $out" }
    $template = [ordered]@{
        ConfirmedReadme = $false
        ConfirmedServerRole = $false
        ForensicsComplete = $false
        ExpectedRole = 'StandaloneServer'
        DomainName = ''
        AuthorizedLocalUsers = @()
        AuthorizedLocalAdmins = @()
        AuthorizedDomainUsers = @()
        AuthorizedDomainAdmins = @()
        RequiredServiceAccounts = @()
        RequiredServices = @()
        RequiredRoles = @()
        RequiredShares = @()
        RequiredApplications = @()
        RequiredPorts = @()
        LocalUsers = [ordered]@{Create=@();Disable=@();Delete=@();DemoteAdmins=@();PasswordExpires=@();ResetPasswords=@()}
        LocalGroups = [ordered]@{Create=@();Members=[ordered]@{};RemoveMembers=[ordered]@{}}
        LocalPasswordPolicy = [ordered]@{}
        DomainChanges = [ordered]@{
            Allowed=$false
            DisableUsers=@()
            NewUsers=@()
            ExpirePasswords=@()
            ResetPasswords=@()
            NewGroups=@()
            AddGroupMembers=[ordered]@{}
            RemoveGroupMembers=[ordered]@{}
            ChangeDefaultPasswordPolicy=$false
            DefaultPasswordPolicy=[ordered]@{}
        }
        Firewall = [ordered]@{EnableProfiles=$true;DisableRules=@()}
        Defender = [ordered]@{Enable=$true;UpdateSignatures=$true;QuickScan=$false;RemovePathExclusions=@();RemoveProcessExclusions=@();RemoveExtensionExclusions=@()}
        SMB = [ordered]@{RequireServerSigning=$false;RequireClientSigning=$false;DisableSMB1=$false}
        Security = [ordered]@{
            SmartScreen=$false;RestrictBlankPasswords=$false;EnableUAC=$false
            HideLastSignedIn=$false;DisableAutoplay=$false;DisableLLMNR=$false
            PowerShellLogging=$false;RequireNTLMv2=$false;RestrictAnonymous=$false
            PrintDriverAdminOnly=$false;RequireRdpNLA=$false;DisableRemoteAssistance=$false
            DisableUnencryptedWinRM=$false;DisableBasicWinRM=$false
        }
        AuditSubcategories = [ordered]@{}
        DisableServices = @()
        DisableFeatures = @()
        UninstallWindowsFeatures = @()
        DisableScheduledTasks = @()
        RemoveStartupValues = @()
        ClearAccessibilityDebuggers = @()
        RemoveShares = @()
        RemoveShareAccess = @()
        RemoveFiles = @()
        UpdatePrograms = @()
        UninstallPrograms = @()
        WindowsUpdate = 'Scan'
        IIS = [ordered]@{DisableDirectoryBrowsingOnSites=@()}
        DNS = [ordered]@{SecureDynamicUpdateZones=@();DisableZoneTransfers=@()}
        DHCP = [ordered]@{EnableAuditLogging=$false}
        TLS = [ordered]@{DisableServerProtocols=@();CompatibilityConfirmed=$false}
        DiscoveryPaths = @('C:\Users\Public','C:\Temp')
    }
    $template | ConvertTo-Json -Depth 16 | Set-Content -LiteralPath $out -Encoding UTF8
    Write-Host "Created $out. Fill it from the actual server README; do not just flip the confirmation switches."
}
function Read-Config {
    if (-not $Config -or -not (Test-Path -LiteralPath $Config -PathType Leaf)) { throw 'Apply mode requires -Config pointing to a JSON file.' }
    $script:Cfg = Get-Content -LiteralPath $Config -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not [bool](Value $script:Cfg 'ConfirmedReadme' $false)) { throw 'Read the image README and complete the JSON before ConfirmedReadme=true.' }
    if (-not [bool](Value $script:Cfg 'ConfirmedServerRole' $false)) { throw 'Inspect Server Manager / winver and confirm the server role before Apply.' }
    if ((Value $script:Cfg 'ExpectedRole' '') -cne $script:ActualRole) { throw "Configured ExpectedRole does not match detected $script:ActualRole" }
    if ($script:IsDC -and ((Value $script:Cfg 'DomainName' '') -ine $script:DomainName)) { throw 'DomainName must exactly match the current Active Directory domain.' }
    $script:RequiredServices = @(Values (Value $script:Cfg 'RequiredServices'))
    $script:RequiredRoles = @(Values (Value $script:Cfg 'RequiredRoles'))
    $script:RequiredShares = @(Values (Value $script:Cfg 'RequiredShares'))
    $script:RequiredApps = @(Values (Value $script:Cfg 'RequiredApplications'))
    $script:RequiredAccounts = @(Values (Value $script:Cfg 'AuthorizedLocalUsers')) + @(Values (Value $script:Cfg 'AuthorizedLocalAdmins')) + @(Values (Value $script:Cfg 'AuthorizedDomainUsers')) + @(Values (Value $script:Cfg 'AuthorizedDomainAdmins')) + @(Values (Value $script:Cfg 'RequiredServiceAccounts'))
    if (-not (Values (Value $script:Cfg 'AuthorizedLocalAdmins')).Count -and -not $script:IsDC) { throw 'AuthorizedLocalAdmins must contain the actual authorized local admin(s).' }
    if ($script:IsDC -and -not (Values (Value $script:Cfg 'AuthorizedDomainAdmins')).Count) { throw 'AuthorizedDomainAdmins cannot be empty on a Domain Controller.' }
    foreach ($name in (Values (Value (Value $script:Cfg 'LocalUsers') 'Delete'))) {
        if (Listed $name $script:RequiredAccounts) { throw "A required/authorized account is selected for deletion: $name" }
    }
    foreach ($name in (Values (Value $script:Cfg 'DisableServices'))) {
        if (Listed $name $script:RequiredServices) { throw "Required service selected for disabling: $name" }
    }
    foreach ($name in (Values (Value $script:Cfg 'UninstallPrograms'))) {
        if (Listed $name $script:RequiredApps) { throw "Required application selected for removal: $name" }
    }
    foreach ($name in (Values (Value $script:Cfg 'RemoveShares'))) {
        if (Listed $name $script:RequiredShares) { throw "Required share selected for removal: $name" }
    }
}
function Save-Registry([string]$Key) {
    if (-not (Test-Path -LiteralPath $Key)) {
        ("Originally absent: " + $Key) | Add-Content -LiteralPath (Join-Path $backups 'absent-registry-keys.txt')
        return
    }
    $path = $Key -replace '^HKLM:\\','HKEY_LOCAL_MACHINE\' -replace '^HKCU:\\','HKEY_CURRENT_USER\'
    $file = Join-Path $backups ("registry-" + [guid]::NewGuid().ToString('N') + ".reg")
    & reg.exe export $path $file /y | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Could not export registry path $Key" }
    Record 'INFO' "Registry backup: $Key -> $file"
}
function Set-Dword([string]$Key,[string]$Name,[int]$Wanted) {
    $now = $null
    if (Test-Path $Key) { $now=(Get-ItemProperty -Path $Key -Name $Name -ErrorAction SilentlyContinue).$Name }
    Change ("Registry $Key\$Name = $Wanted") ($null -eq $now -or [int]$now -ne $Wanted) {
        Save-Registry $Key
        if (-not (Test-Path $Key)) { New-Item -Path $Key -Force | Out-Null }
        New-ItemProperty -Path $Key -Name $Name -Value $Wanted -PropertyType DWord -Force | Out-Null
        $check = (Get-ItemProperty -Path $Key -Name $Name).$Name
        if ([int]$check -ne $Wanted) { throw 'Registry value verification failed' }
    }
}
function Save-Review([string]$Name,[scriptblock]$Query) {
    $dest = Join-Path $backups ("review-" + $Name + ".csv")
    try {
        $rows = @(& $Query)
        if ($rows.Count -gt 0) { $rows | Export-Csv -LiteralPath $dest -NoTypeInformation -Encoding UTF8 }
        else { 'No results found' | Set-Content -LiteralPath $dest }
        Record 'REVIEW' ("Review " + $dest + " (" + $rows.Count + " entries)")
    } catch { Record 'REVIEW' ("Review unavailable (" + $Name + "): " + $_.Exception.Message) }
}
function Save-Summary {
    if ($script:Results.Count -gt 0) { $script:Results | Export-Csv -LiteralPath $summary -NoTypeInformation -Encoding UTF8 }
    Write-Host ''
    Write-Host 'Windows Server security summary'
    foreach ($state in @('CHANGED','OK','WOULD','REVIEW','SKIPPED','FAILED')) {
        $count = @($script:Results | Where-Object { $_.State -eq $state }).Count
        Write-Host ("  " + $state + ": " + $count)
    }
    Write-Host "Reports: $root"
    Write-Host "Backups: $backups"
    Write-Host 'Review the Scoring Report and test all required server roles before rebooting.'
}
