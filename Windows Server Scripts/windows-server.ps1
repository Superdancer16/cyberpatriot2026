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

function Invoke-Audit {
    $section = @()
    $section += "Windows Server audit — $(Get-Date -Format s)"
    $section += "Hostname: $env:COMPUTERNAME"
    $section += "Detected role: $script:ActualRole"
    $section += "Domain: $script:DomainName"
    $section += "Windows PowerShell: $($PSVersionTable.PSVersion)"
    $section | Set-Content -LiteralPath $report -Encoding UTF8
    Save-Review 'operating-system' {
        Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,ProductType,InstallDate,LastBootUpTime
    }
    Save-Review 'computer-domain' {
        Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain,DomainRole
    }
    Save-Review 'installed-server-roles' {
        if (Get-Command Get-WindowsFeature -ErrorAction SilentlyContinue) {
            Get-WindowsFeature | Where-Object Installed | Select-Object Name,DisplayName,FeatureType
        }
    }
    Save-Review 'services' {
        Get-CimInstance Win32_Service | Select-Object Name,DisplayName,State,StartMode,StartName,PathName
    }
    Save-Review 'listeners' {
        foreach ($item in @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue)) {
            $process = Get-Process -Id $item.OwningProcess -ErrorAction SilentlyContinue
            [pscustomobject]@{Address=$item.LocalAddress;Port=$item.LocalPort;PID=$item.OwningProcess;Process=$process.ProcessName}
        }
    }
    Save-Review 'firewall-profiles' {
        Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction
    }
    Save-Review 'firewall-inbound-allow' {
        Get-NetFirewallRule -Direction Inbound -Enabled True -Action Allow -ErrorAction SilentlyContinue |
            Select-Object Name,DisplayName,DisplayGroup,Profile,PolicyStoreSource,Enabled
    }
    Save-Review 'local-password-policy' {
        $data = & net.exe accounts 2>&1 | Out-String
        [pscustomobject]@{Output=$data.Trim()}
    }
    Save-Review 'audit-policy' {
        [pscustomobject]@{Text=((& auditpol.exe /get /category:* 2>&1) | Out-String).Trim()}
    }
    Save-Review 'shares' {
        Get-SmbShare -ErrorAction SilentlyContinue | Select-Object Name,Path,Special,Description
    }
    Save-Review 'share-permissions' {
        foreach ($share in @(Get-SmbShare -ErrorAction SilentlyContinue)) {
            foreach ($entry in @(Get-SmbShareAccess -Name $share.Name -ErrorAction SilentlyContinue)) {
                [pscustomobject]@{Share=$share.Name;Path=$share.Path;Account=$entry.AccountName;Right=$entry.AccessRight;Type=$entry.AccessControlType}
            }
        }
    }
    Save-Review 'defender' {
        if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
            Get-MpComputerStatus | Select-Object AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,AntivirusSignatureAge,IsTamperProtected
        }
    }
    Save-Review 'defender-exclusions' {
        if (Get-Command Get-MpPreference -ErrorAction SilentlyContinue) {
            Get-MpPreference | Select-Object ExclusionPath,ExclusionExtension,ExclusionProcess,PUAProtection
        }
    }
    Save-Review 'startup' {
        Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location,User
    }
    Save-Review 'tasks' {
        Get-ScheduledTask -ErrorAction SilentlyContinue |
            Where-Object TaskPath -NotLike '\Microsoft\*' |
            Select-Object -First 200 TaskPath,TaskName,State
    }
    Save-Review 'installed-apps' {
        Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
            Where-Object DisplayName |
            Select-Object DisplayName,DisplayVersion,Publisher,InstallLocation
    }
    Save-Review 'ifeo-debuggers' {
        $base = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
        foreach ($key in @(Get-ChildItem $base -ErrorAction SilentlyContinue)) {
            $debugger = (Get-ItemProperty -Path $key.PSPath -Name Debugger -ErrorAction SilentlyContinue).Debugger
            if ($debugger) { [pscustomobject]@{Executable=$key.PSChildName;Debugger=$debugger;Registry=$key.Name} }
        }
    }
    Save-Review 'hosts' {
        $hosts = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'
        $n = 0
        foreach ($row in @(Get-Content -LiteralPath $hosts -ErrorAction SilentlyContinue)) {
            $n++
            if ($row.Trim() -and -not $row.Trim().StartsWith('#')) { [pscustomobject]@{Line=$n;Entry=$row.Trim()} }
        }
    }
    Save-Review 'recent-service-installations' {
        Get-WinEvent -FilterHashtable @{LogName='System';Id=7045} -MaxEvents 50 -ErrorAction Stop |
            Select-Object TimeCreated,Id,ProviderName,Message
    }
    Save-Review 'recent-security-events' {
        Get-WinEvent -FilterHashtable @{LogName='Security';Id=4625,4720,4726,4732,1102} -MaxEvents 80 -ErrorAction Stop |
            Select-Object TimeCreated,Id,ProviderName,Message
    }
    if ($script:IsDC) {
        Save-Review 'domain-users' {
            Import-Module ActiveDirectory -ErrorAction Stop
            Get-ADUser -Filter * -Properties Enabled,PasswordNeverExpires,LastLogonDate |
                Select-Object SamAccountName,Enabled,PasswordNeverExpires,LastLogonDate,DistinguishedName
        }
        Save-Review 'domain-privileged-groups' {
            Import-Module ActiveDirectory -ErrorAction Stop
            foreach ($name in @('Domain Admins','Enterprise Admins','Schema Admins','Administrators','Account Operators','Backup Operators','Server Operators','DnsAdmins','Group Policy Creator Owners')) {
                try {
                    Get-ADGroupMember -Identity $name -Recursive -ErrorAction Stop |
                        ForEach-Object { [pscustomobject]@{Group=$name;Member=$_.SamAccountName;Class=$_.ObjectClass} }
                } catch { Record 'REVIEW' "Cannot list group $name: $($_.Exception.Message)" }
            }
        }
        Save-Review 'domain-password-policies' {
            Import-Module ActiveDirectory -ErrorAction Stop
            Get-ADDefaultDomainPasswordPolicy | Select-Object *
        }
        Save-Review 'domain-fine-grained-policies' {
            Import-Module ActiveDirectory -ErrorAction Stop
            Get-ADFineGrainedPasswordPolicy -Filter * | Select-Object Name,Precedence,MinPasswordLength,ComplexityEnabled
        }
        Save-Review 'domain-replication-status' {
            [pscustomobject]@{Text=((& repadmin.exe /replsummary 2>&1) | Out-String).Trim()}
        }
        Save-Review 'domain-controller-status' {
            [pscustomobject]@{Text=((& dcdiag.exe /test:Advertising /test:Services /test:NetLogons 2>&1) | Out-String).Trim()}
        }
        Save-Review 'gpo-inventory' {
            if (Get-Module -ListAvailable GroupPolicy) {
                Import-Module GroupPolicy -ErrorAction Stop
                Get-GPO -All | Select-Object DisplayName,Id,GpoStatus,ModificationTime
            }
        }
    } elseif ($script:ActualRole -ne 'DomainController') {
        Save-Review 'local-users' {
            if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
                Get-LocalUser | Select-Object Name,Enabled,SID,PasswordExpires,PasswordRequired
            } else {
                [pscustomobject]@{Output=((& net.exe user) | Out-String).Trim()}
            }
        }
        Save-Review 'local-administrators' {
            if (Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue) {
                Get-LocalGroupMember -SID 'S-1-5-32-544' | Select-Object Name,SID,ObjectClass,PrincipalSource
            }
        }
    }
    if (Get-Module -ListAvailable DnsServer) {
        Save-Review 'dns-zones' {
            Import-Module DnsServer -ErrorAction Stop
            Get-DnsServerZone | Select-Object ZoneName,ZoneType,DynamicUpdate,IsDsIntegrated,SecureSecondaries
        }
    }
    if (Get-Module -ListAvailable DhcpServer) {
        Save-Review 'dhcp-scopes' {
            Import-Module DhcpServer -ErrorAction Stop
            Get-DhcpServerv4Scope | Select-Object ScopeId,Name,StartRange,EndRange,State
        }
        Save-Review 'dhcp-options' {
            Get-DhcpServerv4OptionValue | Select-Object OptionId,Name,Value,VendorClass
        }
    }
    if (Get-Module -ListAvailable WebAdministration) {
        Save-Review 'iis-sites' {
            Import-Module WebAdministration -ErrorAction Stop
            Get-Website | Select-Object Name,State,PhysicalPath,Bindings
        }
        Save-Review 'iis-app-pools' {
            Get-ChildItem 'IIS:\AppPools' | Select-Object Name,State,ManagedRuntimeVersion
        }
    }
    if (Get-Command Get-WinEvent -ErrorAction SilentlyContinue) {
        Record 'REVIEW' 'Use Event Viewer or the saved CSV reports for evidence; do not clear logs.'
    }
    Record 'INFO' "Audit records saved under $backups"
}

function Get-AdminGroup {
    $item = Get-LocalGroup | Where-Object { $_.SID.Value -eq 'S-1-5-32-544' } | Select-Object -First 1
    if (-not $item) { throw 'Could not identify local Administrators group by SID.' }
    return $item
}
function LocalUserProtected([string]$Name) {
    if (Listed $Name $script:RequiredAccounts) { return $true }
    if ($Name -ieq $env:USERNAME) { return $true }
    $user = Get-LocalUser -Name $Name -ErrorAction SilentlyContinue
    if ($user -and $user.SID.Value -match '-(500|501|503|504)$') { return $true }
    return $false
}
function Invoke-LocalAccounts {
    if ($script:IsDC) { Record 'SKIPPED' 'Local SAM changes skipped on a Domain Controller; use AD-specific checks.'; return }
    if (-not (Get-Command Get-LocalUser -ErrorAction SilentlyContinue)) {
        Record 'REVIEW' 'LocalAccounts cmdlets unavailable; use Computer Management/local users GUI.'
        return
    }
    $cfg = Value $script:Cfg 'LocalUsers'
    $admin = Get-AdminGroup
    $authorized = @(Values (Value $script:Cfg 'AuthorizedLocalUsers')) + @(Values (Value $script:Cfg 'AuthorizedLocalAdmins'))
    foreach ($name in (Values (Value $cfg 'Create'))) {
        if (-not (Listed $name $authorized)) { Record 'SKIPPED' "New user $name missing from README-authorized lists."; continue }
        if ($name -notmatch '^[A-Za-z][A-Za-z0-9_.-]{0,19}$') { Record 'REVIEW' "Invalid requested local username $name"; continue }
        if (Get-LocalUser -Name $name -ErrorAction SilentlyContinue) { Record 'OK' "Local user exists: $name"; continue }
        if ($Yes) { Record 'REVIEW' "Create $name with an interactive password; unattended mode does not store secrets."; continue }
        if ($Mode -eq 'Audit') { Record 'WOULD' "Create local user $name"; continue }
        $password = Read-Host "New initial password for $name" -AsSecureString
        Change "Create README-authorized local user $name" $true {
            New-LocalUser -Name $name -Password $password -ErrorAction Stop | Out-Null
            if (Listed $name (Value $script:Cfg 'AuthorizedLocalAdmins')) {
                Add-LocalGroupMember -Group $admin.Name -Member $name -ErrorAction Stop
            }
            if (-not (Get-LocalUser -Name $name -ErrorAction SilentlyContinue)) { throw 'New user not found after creation' }
        }
    }
    foreach ($name in (Values (Value $cfg 'ResetPasswords'))) {
        if (-not (Listed $name $authorized)) { Record 'SKIPPED' "Password reset for unlisted user $name"; continue }
        $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
        if (-not $user) { Record 'REVIEW' "Password user missing: $name"; continue }
        if ($Yes) { Record 'REVIEW' "Reset $name password interactively (no secret stored in JSON)."; continue }
        if ($Mode -eq 'Audit') { Record 'WOULD' "Reset password for $name"; continue }
        $pw = Read-Host "New password for $name" -AsSecureString
        Change "Reset authorized user password $name" $true {
            Set-LocalUser -Name $name -Password $pw -ErrorAction Stop
        }
    }
    foreach ($name in (Values (Value $cfg 'PasswordExpires'))) {
        if (-not (Listed $name $authorized)) { Record 'SKIPPED' "User not authorized for password expiry change: $name"; continue }
        $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
        if (-not $user) { Record 'REVIEW' "Password expiry user not found: $name"; continue }
        Change "Require password expiry for $name" $true {
            Set-LocalUser -Name $name -PasswordNeverExpires $false -ErrorAction Stop
        }
    }
    foreach ($name in (Values (Value $cfg 'DemoteAdmins'))) {
        if (LocalUserProtected $name) {
            if (Listed $name (Value $script:Cfg 'AuthorizedLocalUsers')) {
                # Authorized standard users can be removed from Administrators without deleting accounts.
            } else { Record 'SKIPPED' "Cannot demote protected administrator $name"; continue }
        }
        $members = @(Get-LocalGroupMember -Group $admin.Name -ErrorAction SilentlyContinue)
        $found = @($members | Where-Object { $_.Name -ieq $name -or $_.Name -like ("*\" + $name) })
        if (-not $found.Count) { Record 'OK' "Not an administrator: $name"; continue }
        if ($members.Count -le 1) { Record 'SKIPPED' "Refusing to remove the last local administrator: $name"; continue }
        if (Listed $name (Value $script:Cfg 'AuthorizedLocalAdmins')) { Record 'SKIPPED' "README-authorized admin cannot be demoted: $name"; continue }
        Change "Remove unauthorized administrator right from $name" $true {
            Remove-LocalGroupMember -Group $admin.Name -Member $name -ErrorAction Stop
        }
    }
    foreach ($name in (Values (Value $cfg 'Disable'))) {
        $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
        if (-not $user) { Record 'OK' "Unauthorized account already missing: $name"; continue }
        if (LocalUserProtected $name) { Record 'SKIPPED' "Protected account cannot be disabled: $name"; continue }
        Change "Disable exact unauthorized local account $name" ([bool]$user.Enabled) {
            $user | Select-Object Name,Enabled,SID | Export-Clixml (Join-Path $backups ("user-" + $name + "-before.xml"))
            Disable-LocalUser -Name $name -ErrorAction Stop
            if ((Get-LocalUser -Name $name).Enabled) { throw 'Account is still enabled' }
        }
    }
    foreach ($name in (Values (Value $cfg 'Delete'))) {
        if (-not $AllowRemovals -or -not [bool](Value $script:Cfg 'ForensicsComplete' $false)) {
            Record 'REVIEW' "Deletion of $name needs -AllowRemovals and preserved forensic evidence."
            continue
        }
        $user = Get-LocalUser -Name $name -ErrorAction SilentlyContinue
        if (-not $user) { Record 'OK' "Unauthorized account already absent: $name"; continue }
        if (LocalUserProtected $name) { Record 'SKIPPED' "Protected account cannot be deleted: $name"; continue }
        $members = @(Get-LocalGroupMember -Group $admin.Name -ErrorAction SilentlyContinue)
        if ($members.Count -le 1 -and @($members | Where-Object { $_.SID.Value -eq $user.SID.Value }).Count) {
            Record 'SKIPPED' "Deleting $name would eliminate the last local admin."
            continue
        }
        Change "Delete explicitly unauthorized local account $name (profile retained)" $true {
            $user | Select-Object Name,SID,Enabled | Export-Clixml (Join-Path $backups ("deleted-user-" + $name + ".xml"))
            Remove-LocalUser -Name $name -ErrorAction Stop
        }
    }
}
function Invoke-LocalGroups {
    if ($script:IsDC) { Record 'SKIPPED' 'Local group changes skipped on Domain Controller.'; return }
    if (-not (Get-Command Get-LocalGroup -ErrorAction SilentlyContinue)) { Record 'REVIEW' 'Local group cmdlets not installed.'; return }
    $groups = Value $script:Cfg 'LocalGroups'
    foreach ($name in (Values (Value $groups 'Create'))) {
        if ($name -notmatch '^[A-Za-z][A-Za-z0-9 _.-]{0,63}$') { Record 'REVIEW' "Invalid group name $name"; continue }
        if (Get-LocalGroup -Name $name -ErrorAction SilentlyContinue) { Record 'OK' "Local group exists: $name"; continue }
        Change "Create specified local group $name" $true {
            New-LocalGroup -Name $name -ErrorAction Stop | Out-Null
        }
    }
    foreach ($entry in @((Value $groups 'Members').PSObject.Properties)) {
        $group = [string]$entry.Name
        if (-not (Get-LocalGroup -Name $group -ErrorAction SilentlyContinue)) { Record 'REVIEW' "Group missing: $group"; continue }
        foreach ($name in (Values $entry.Value)) {
            if (-not (Listed $name $script:RequiredAccounts)) { Record 'SKIPPED' "Group member not authorized: $name"; continue }
            $exists = @(Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ieq $name -or $_.Name -like ("*\" + $name) }).Count -gt 0
            Change "Add $name to local group $group" (-not $exists) {
                Add-LocalGroupMember -Group $group -Member $name -ErrorAction Stop
            }
        }
    }
    $admin = Get-AdminGroup
    foreach ($entry in @((Value $groups 'RemoveMembers').PSObject.Properties)) {
        $group = [string]$entry.Name
        if (-not (Get-LocalGroup -Name $group -ErrorAction SilentlyContinue)) { Record 'OK' "Group absent: $group"; continue }
        foreach ($name in (Values $entry.Value)) {
            if (Listed $name (Value $script:Cfg 'AuthorizedLocalAdmins')) { Record 'SKIPPED' "Authorized admin membership protected: $name"; continue }
            if ($name -ieq $env:USERNAME) { Record 'SKIPPED' 'Current administrator membership protected.'; continue }
            $members = @(Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue)
            $exists = @($members | Where-Object { $_.Name -ieq $name -or $_.Name -like ("*\" + $name) }).Count -gt 0
            if ($group -ieq $admin.Name -and $members.Count -le 1) { Record 'SKIPPED' 'Cannot empty Administrators group.'; continue }
            Change "Remove exact unauthorized member $name from $group" $exists {
                Remove-LocalGroupMember -Group $group -Member $name -ErrorAction Stop
            }
        }
    }
}

function Check-DomainWrites {
    $cfg = Value $script:Cfg 'DomainChanges'
    if (-not $script:IsDC) { Record 'SKIPPED' 'Active Directory writes are for confirmed Domain Controllers only.'; return $false }
    if (-not $EnableDomainChanges -or -not [bool](Value $cfg 'Allowed' $false)) {
        Record 'REVIEW' 'AD changes disabled. Both -EnableDomainChanges and DomainChanges.Allowed=true are required.'
        return $false
    }
    if ((Value $script:Cfg 'DomainName' '') -ine $script:DomainName) {
        Record 'FAILED' 'Configured AD domain does not match detected domain.'
        return $false
    }
    if (-not (Get-Module -ListAvailable ActiveDirectory)) { Record 'FAILED' 'Active Directory PowerShell module is unavailable.'; return $false }
    Import-Module ActiveDirectory -ErrorAction Stop
    return $true
}
function ProtectedADUser($User) {
    if (-not $User) { return $true }
    if ($User.SamAccountName -in @('krbtgt','Administrator')) { return $true }
    if ($User.SID.Value -match '-(500|501|502)$') { return $true }
    if ($User.adminCount -eq 1) { return $true }
    if (@($User.ServicePrincipalName).Count) { return $true }
    if (Listed $User.SamAccountName $script:RequiredAccounts) { return $true }
    return $false
}
function Check-ADGroup([string]$Name) {
    $group = Get-ADGroup -Identity $Name -Properties adminCount,IsCriticalSystemObject -ErrorAction Stop
    if ($group.adminCount -eq 1 -or $group.IsCriticalSystemObject) { return $null }
    if ($group.SID.Value -match '-(512|518|519|520|544|548|549|550|551|552)$') { return $null }
    if ($group.Name -in @('Domain Admins','Enterprise Admins','Schema Admins','Administrators','Account Operators','Backup Operators','Server Operators','Print Operators','DnsAdmins','Group Policy Creator Owners')) { return $null }
    return $group
}
function Invoke-ADAccounts {
    if (-not $script:IsDC) { Record 'SKIPPED' 'AD account module not applicable to a non-DC server.'; return }
    if (-not (Check-DomainWrites)) { return }
    $settings = Value $script:Cfg 'DomainChanges'
    $domainSuffix = 'DC=' + ($script:DomainName -split '\.' -join ',DC=')
    foreach ($name in (Values (Value $settings 'DisableUsers'))) {
        if ($name -notmatch '^[A-Za-z][A-Za-z0-9._-]{0,63}$') { Record 'REVIEW' "Invalid AD username $name"; continue }
        try {
            $user = Get-ADUser -Identity $name -Properties adminCount,ServicePrincipalName -ErrorAction Stop
            if (ProtectedADUser $user) { Record 'SKIPPED' "Protected AD user $name cannot be disabled."; continue }
            Change "Disable confirmed unauthorized AD account $name" ([bool]$user.Enabled) {
                $user | Select-Object SamAccountName,DistinguishedName,SID,Enabled | Export-Clixml (Join-Path $backups ("ad-user-" + $name + "-before.xml"))
                Disable-ADAccount -Identity $user -ErrorAction Stop
                if ((Get-ADUser -Identity $user).Enabled) { throw 'AD account remains enabled' }
            }
        } catch { Record 'REVIEW' "AD user $name could not be reviewed: $($_.Exception.Message)" }
    }
    foreach ($entry in @(Value $settings 'NewUsers' @())) {
        $sam = [string](Value $entry 'SamAccountName' '')
        $ou = [string](Value $entry 'OU' '')
        $name = [string](Value $entry 'Name' $sam)
        if ($sam -notmatch '^[A-Za-z][A-Za-z0-9._-]{0,63}$' -or -not $ou.EndsWith($domainSuffix,[StringComparison]::OrdinalIgnoreCase)) {
            Record 'REVIEW' "New AD user $sam requires exact SamAccountName and an OU inside the current domain."
            continue
        }
        if (-not (Listed $sam (Value $script:Cfg 'AuthorizedDomainUsers')) -and -not (Listed $sam (Value $script:Cfg 'AuthorizedDomainAdmins'))) {
            Record 'SKIPPED' "New AD user $sam is not in authorized domain account lists."; continue
        }
        if (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) { Record 'OK' "Domain user already exists: $sam"; continue }
        try { Get-ADOrganizationalUnit -Identity $ou -ErrorAction Stop | Out-Null }
        catch { Record 'REVIEW' "OU for new AD user not found: $ou"; continue }
        if ($Yes) { Record 'REVIEW' "Create AD user $sam interactively: secret password is required."; continue }
        if ($Mode -eq 'Audit') { Record 'WOULD' "Create authorized domain user $sam in $ou"; continue }
        $password = Read-Host "Initial AD password for $sam" -AsSecureString
        Change "Create authorized domain account $sam in $ou" $true {
            New-ADUser -Name $name -SamAccountName $sam -Path $ou -AccountPassword $password -Enabled $true -ErrorAction Stop
            Get-ADUser -Identity $sam -ErrorAction Stop | Out-Null
        }
        Record 'REVIEW' "Verify the new AD user's OU, UPN, group memberships, resultant password policy and authorized login."
    }
    foreach ($name in (Values (Value $settings 'ExpirePasswords'))) {
        if (-not (Listed $name (Value $script:Cfg 'AuthorizedDomainUsers')) -and -not (Listed $name (Value $script:Cfg 'AuthorizedDomainAdmins'))) {
            Record 'SKIPPED' "AD password-expiry user not in authorized list: $name"; continue
        }
        try {
            $user = Get-ADUser -Identity $name -Properties adminCount,ServicePrincipalName -ErrorAction Stop
            if (ProtectedADUser $user) { Record 'SKIPPED' "Protected service/privileged AD account cannot be changed: $name"; continue }
            Change "Require AD password change at next logon: $name" $true {
                Set-ADUser -Identity $user -ChangePasswordAtLogon $true -ErrorAction Stop
            }
        } catch { Record 'REVIEW' "AD user $name not available for expiry: $($_.Exception.Message)" }
    }
    foreach ($name in (Values (Value $settings 'ResetPasswords'))) {
        if (-not (Listed $name (Value $script:Cfg 'AuthorizedDomainUsers'))) { Record 'SKIPPED' "AD reset user not in authorized ordinary-user list: $name"; continue }
        try {
            $user = Get-ADUser -Identity $name -Properties adminCount,ServicePrincipalName -ErrorAction Stop
            if (ProtectedADUser $user) { Record 'SKIPPED' "Cannot reset protected AD account $name"; continue }
            if ($Yes) { Record 'REVIEW' "Reset AD password for $name interactively; unattended secret storage disabled."; continue }
            if ($Mode -eq 'Audit') { Record 'WOULD' "Reset password for AD user $name"; continue }
            $pw = Read-Host "New AD password for $name" -AsSecureString
            Change "Reset authorized domain user's password: $name" $true {
                Set-ADAccountPassword -Identity $user -Reset -NewPassword $pw -ErrorAction Stop
            }
        } catch { Record 'REVIEW' "AD password reset for $name: $($_.Exception.Message)" }
    }
}
function Invoke-ADGroups {
    if (-not $script:IsDC) { return }
    if (-not (Check-DomainWrites)) { return }
    $cfg = Value $script:Cfg 'DomainChanges'
    $domainSuffix = 'DC=' + ($script:DomainName -split '\.' -join ',DC=')
    foreach ($item in @(Value $cfg 'NewGroups' @())) {
        $name = [string](Value $item 'Name' '')
        $ou = [string](Value $item 'OU' '')
        $scope = [string](Value $item 'Scope' 'Global')
        if ($name -notmatch '^[A-Za-z][A-Za-z0-9 _.-]{0,63}$' -or $scope -notin @('Global','DomainLocal','Universal') -or -not $ou.EndsWith($domainSuffix,[StringComparison]::OrdinalIgnoreCase)) {
            Record 'REVIEW' "New AD group must have exact Name/OU/Scope in the current domain: $name"; continue
        }
        try { if (Get-ADGroup -Identity $name -ErrorAction SilentlyContinue) { Record 'OK' "AD group already exists: $name"; continue } }
        catch { Record 'REVIEW' "AD group lookup failed for $name"; continue }
        Change "Create specifically authorized AD group $name" $true {
            New-ADGroup -Name $name -SamAccountName $name -GroupCategory Security -GroupScope $scope -Path $ou -ErrorAction Stop
        }
    }
    foreach ($entry in @((Value $cfg 'AddGroupMembers').PSObject.Properties)) {
        $name = [string]$entry.Name
        try { $group = Check-ADGroup $name } catch { Record 'REVIEW' "AD group not found $name"; continue }
        if (-not $group) { Record 'SKIPPED' "Privileged or system AD group requires manual review: $name"; continue }
        foreach ($userName in (Values $entry.Value)) {
            if (-not (Listed $userName (Value $script:Cfg 'AuthorizedDomainUsers')) -and -not (Listed $userName (Value $script:Cfg 'AuthorizedDomainAdmins'))) {
                Record 'SKIPPED' "AD group member not authorized: $userName"; continue
            }
            try {
                $user = Get-ADUser -Identity $userName -ErrorAction Stop
                $existing = @($user | Get-ADPrincipalGroupMembership | Where-Object { $_.DistinguishedName -eq $group.DistinguishedName }).Count
                Change "Add authorized AD user $userName to $name" ($existing -eq 0) {
                    Add-ADGroupMember -Identity $group -Members $user -ErrorAction Stop
                }
            } catch { Record 'REVIEW' "AD membership change $name/$userName: $($_.Exception.Message)" }
        }
    }
    foreach ($entry in @((Value $cfg 'RemoveGroupMembers').PSObject.Properties)) {
        $name = [string]$entry.Name
        try { $group = Check-ADGroup $name } catch { Record 'REVIEW' "AD group not found $name"; continue }
        if (-not $group) { Record 'SKIPPED' "Privileged AD group must be reviewed manually: $name"; continue }
        foreach ($userName in (Values $entry.Value)) {
            if (Listed $userName $script:RequiredAccounts) { Record 'SKIPPED' "Protected account membership cannot be removed: $userName"; continue }
            try {
                $user = Get-ADUser -Identity $userName -ErrorAction Stop
                $member = @($user | Get-ADPrincipalGroupMembership | Where-Object { $_.DistinguishedName -eq $group.DistinguishedName }).Count
                Change "Remove exact unauthorized AD group member $userName from $name" ($member -gt 0) {
                    Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false -ErrorAction Stop
                }
            } catch { Record 'REVIEW' "AD member removal $name/$userName: $($_.Exception.Message)" }
        }
    }
}

function Invoke-LocalPasswordPolicy {
    if ($script:IsDC) { Record 'SKIPPED' 'Local SAM password policy is not the domain password policy on a DC.'; return }
    $settings = Value $script:Cfg 'LocalPasswordPolicy'
    if (-not $settings -or -not @($settings.PSObject.Properties).Count) { Record 'SKIPPED' 'No exact local password rules in JSON.'; return }
    $names = @('MinimumPasswordLength','PasswordHistorySize','MinimumPasswordAge','MaximumPasswordAge','PasswordComplexity','ClearTextPassword','LockoutBadCount','LockoutDuration','ResetLockoutCount')
    $updates = @()
    foreach ($prop in $settings.PSObject.Properties) {
        if ($prop.Name -notin $names) { Record 'REVIEW' "Unknown local policy key $($prop.Name)"; continue }
        $value = 0
        if (-not [int]::TryParse([string]$prop.Value,[ref]$value) -or $value -lt 0 -or $value -gt 9999) {
            Record 'REVIEW' "Invalid local password policy value: $($prop.Name)"; continue
        }
        if ($prop.Name -in @('PasswordComplexity','ClearTextPassword') -and $value -notin @(0,1)) {
            Record 'REVIEW' "$($prop.Name) must be 0 or 1"; continue
        }
        $updates += "$($prop.Name) = $value"
    }
    if (-not $updates.Count) { return }
    if ($script:IsDomainJoined) { Record 'REVIEW' 'Local policy may be superseded by domain GPO; verify resultant policy.' }
    Change ("Configure explicitly requested local account policy: " + ($updates -join '; ')) $true {
        $original = Join-Path $backups 'local-account-policy-before.inf'
        & secedit.exe /export /cfg $original /areas SECURITYPOLICY | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Could not back up local security policy.' }
        $file = Join-Path $backups 'local-account-policy-requested.inf'
        $db = Join-Path $backups 'local-account-policy.sdb'
        @('[Unicode]','Unicode=yes','','[System Access]') + $updates +
            @('','[Version]','signature="$CHICAGO$"','Revision=1') |
            Set-Content -LiteralPath $file -Encoding Unicode
        & secedit.exe /configure /db $db /cfg $file /areas SECURITYPOLICY /quiet | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Local account policy import failed; inspect secedit logs.' }
    }
}
function Invoke-DomainPasswordPolicy {
    if (-not $script:IsDC) { return }
    $settings = Value $script:Cfg 'DomainChanges'
    if (-not [bool](Value $settings 'ChangeDefaultPasswordPolicy' $false)) { Record 'SKIPPED' 'Domain password policy remains manual.'; return }
    if (-not (Check-DomainWrites)) { return }
    $requested = Value $settings 'DefaultPasswordPolicy'
    if (-not $requested -or -not @($requested.PSObject.Properties).Count) {
        Record 'REVIEW' 'No explicit domain password policy fields supplied.'
        return
    }
    $known = @('MinPasswordLength','PasswordHistoryCount','ComplexityEnabled','ReversibleEncryptionEnabled','LockoutThreshold','LockoutDurationMinutes','LockoutObservationWindowMinutes','MinPasswordAgeDays','MaxPasswordAgeDays')
    $args = @{Identity=$script:DomainName;ErrorAction='Stop'}
    foreach ($prop in $requested.PSObject.Properties) {
        $name = $prop.Name
        if ($name -notin $known) { Record 'REVIEW' "Unsupported AD policy field $name"; continue }
        if ($name -in @('ComplexityEnabled','ReversibleEncryptionEnabled')) {
            if ($prop.Value -isnot [bool]) { Record 'REVIEW' "AD policy $name must be true/false"; continue }
            $args[$name] = [bool]$prop.Value
            continue
        }
        $value = 0
        if (-not [int]::TryParse([string]$prop.Value,[ref]$value) -or $value -lt 0 -or $value -gt 3650) {
            Record 'REVIEW' "Invalid AD policy value: $name"; continue
        }
        switch ($name) {
            'LockoutDurationMinutes' { $args['LockoutDuration'] = [TimeSpan]::FromMinutes($value) }
            'LockoutObservationWindowMinutes' { $args['LockoutObservationWindow'] = [TimeSpan]::FromMinutes($value) }
            'MinPasswordAgeDays' { $args['MinPasswordAge'] = [TimeSpan]::FromDays($value) }
            'MaxPasswordAgeDays' { $args['MaxPasswordAge'] = [TimeSpan]::FromDays($value) }
            default { $args[$name] = $value }
        }
    }
    if ($args.Count -le 2) { return }
    Change "Update explicitly requested AD default password policy for $script:DomainName" $true {
        $old = Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop
        $old | Export-Clixml -LiteralPath (Join-Path $backups 'domain-password-policy-before.xml')
        Set-ADDefaultDomainPasswordPolicy @args
        Get-ADDefaultDomainPasswordPolicy | Export-Clixml -LiteralPath (Join-Path $backups 'domain-password-policy-after.xml')
    }
    Record 'REVIEW' 'Check GPMC/domain-root GPO and fine-grained resultant policy; verify authorized domain login.'
}
function Invoke-UserRights {
    if ($script:IsDC) { Record 'REVIEW' 'DC user rights come from domain-linked GPO; review in GPMC instead of local secedit.'; return }
    $wanted = Value $script:Cfg 'RemoveUserRights'
    if (-not $wanted -or -not @($wanted.PSObject.Properties).Count) { return }
    $allowed = @('SeSecurityPrivilege','SeTakeOwnershipPrivilege','SeDebugPrivilege','SeBackupPrivilege','SeRestorePrivilege')
    $original = Join-Path $backups 'user-rights-before.inf'
    & secedit.exe /export /cfg $original /areas USER_RIGHTS | Out-Null
    if ($LASTEXITCODE -ne 0) { Record 'FAILED' 'Could not export user rights; no changes made'; return }
    foreach ($entry in $wanted.PSObject.Properties) {
        if ($entry.Name -notin $allowed) { Record 'REVIEW' "Unsupported user right $($entry.Name)"; continue }
        foreach ($name in (Values $entry.Value)) {
            if (Listed $name $script:RequiredAccounts) { Record 'SKIPPED' "Protected user right: $name"; continue }
            try { $sid = (New-Object Security.Principal.NTAccount -ArgumentList $name).Translate([Security.Principal.SecurityIdentifier]).Value }
            catch { Record 'REVIEW' "Unresolvable user-rights principal: $name"; continue }
            if ($sid -match '^S-1-5-32-' -or $sid -match '-(500|501|502|503|504)$') { Record 'SKIPPED' "Built-in right protected: $name"; continue }
            $raw = Get-Content -LiteralPath $original -Raw
            $pattern = '(?m)^\s*' + [regex]::Escape($entry.Name) + '\s*=\s*(.*)$'
            $match = [regex]::Match($raw,$pattern)
            if (-not $match.Success) { Record 'REVIEW' "Right not in exported policy: $($entry.Name)"; continue }
            $current = @($match.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            $after = @($current | Where-Object { $_ -ne ("*" + $sid) -and $_ -ne $sid -and $_ -ine $name })
            if ($after.Count -eq $current.Count) { Record 'OK' "Right $($entry.Name) does not list $name"; continue }
            if (-not $after.Count) { Record 'SKIPPED' "Cannot empty right $($entry.Name)"; continue }
            Change "Remove exact $name from $($entry.Name)" $true {
                $file = Join-Path $backups ("rights-" + [guid]::NewGuid().ToString('N') + ".inf")
                $db = Join-Path $backups ("rights-" + [guid]::NewGuid().ToString('N') + ".sdb")
                @('[Unicode]','Unicode=yes','','[Privilege Rights]',($entry.Name + ' = ' + ($after -join ',')),'','[Version]','signature="$CHICAGO$"','Revision=1') |
                    Set-Content -LiteralPath $file -Encoding Unicode
                & secedit.exe /configure /db $db /cfg $file /areas USER_RIGHTS /quiet | Out-Null
                if ($LASTEXITCODE -ne 0) { throw 'User rights change failed' }
            }
        }
    }
}
function Invoke-AdvancedAuditing {
    $requested = Value $script:Cfg 'AuditSubcategories'
    if (-not $requested -or -not @($requested.PSObject.Properties).Count) { return }
    if ($script:IsDC -and -not $EnableDomainChanges) { Record 'REVIEW' 'DC advanced auditing is domain-managed; use GPMC or explicit domain authorization.'; return }
    $original = Join-Path $backups 'audit-before.csv'
    & auditpol.exe /backup ("/file:" + $original) | Out-Null
    if ($LASTEXITCODE -ne 0) { Record 'FAILED' 'Could not back up audit policy; skipping.'; return }
    foreach ($entry in $requested.PSObject.Properties) {
        $name = [string]$entry.Name
        $value = [string]$entry.Value
        if ($name -notmatch '^[A-Za-z0-9 ._-]{3,80}$' -or $value -notin @('Success','Failure','SuccessAndFailure')) {
            Record 'REVIEW' "Unsupported audit subcategory/value $name = $value"; continue
        }
        $arguments = @('/set',("/subcategory:" + $name))
        if ($value -in @('Success','SuccessAndFailure')) { $arguments += '/success:enable' }
        if ($value -in @('Failure','SuccessAndFailure')) { $arguments += '/failure:enable' }
        Change "Audit $name : $value" $true {
            & auditpol.exe @arguments | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'auditpol exited with an error (check localization and GPO)' }
        }
    }
}

