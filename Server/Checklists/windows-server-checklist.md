# 🪟 Windows Server — Printable Checklist & GitHub Progress Tracker

> **Source:** [Complete standalone Windows Server guide](../windows-server.md). This companion file **does not replace or modify** the main guide.
>
> **Print:** Use `windows-server-checklist.pdf` in this folder. Mark one box for each completed inspection, permitted fix or verification.
>
> **Track on GitHub:** Edit this Markdown tracker and change `[ ]` to `[x]` for each completed item; commit the edits. Annotate not-applicable items with `(N/A — reason)`. Viewing a rendered checkbox is not the same as saving the change.
>
> **Server safety:** Identify **standalone / domain member / Domain Controller** first. Do not disable AD, DNS, Kerberos, DHCP, IIS, SMB, WinRM or other README-required roles simply because they appear in a generic hardening list.

**Round/date:** ___________________  **Server role:** ___________________  **Team:** ___________________

**Starting score:** __________  **Final score:** __________  **Reviewer:** ___________________

## 01. Identify Server version, role and access  
*Full guide: [Part 1](../windows-server.md#stage-1)*

- [ ] **S001** — Read complete image README, role notes and forensics instructions
- [ ] **S002** — Record Windows Server version and build
- [ ] **S003** — Identify Desktop Experience or Server Core
- [ ] **S004** — Check whether this machine is standalone, domain member or Domain Controller
- [ ] **S005** — Confirm actual ProductType and DomainRole
- [ ] **S006** — Check whether AD DS binaries are installed
- [ ] **S007** — Confirm if the server is actually promoted as a DC
- [ ] **S008** — Record domain and computer name
- [ ] **S009** — Inventory installed Windows Server roles and features
- [ ] **S010** — Record required directory, DNS, DHCP, IIS, FTP and SMB roles
- [ ] **S011** — Record approved remote management methods
- [ ] **S012** — Confirm authorized administrator or console access
- [ ] **S013** — Record initial scoring report timestamp and points
- [ ] **S014** — Identify authorized snapshot or recovery option
- [ ] **S015** — Open elevated PowerShell and Server Manager when available

## 02. Forensics and role-aware backups  
*Full guide: [Part 2](../windows-server.md#stage-2)*

- [ ] **S016** — Find each Forensics Question file and required answer format
- [ ] **S017** — Preserve evidence before account or software cleanup
- [ ] **S018** — Inspect relevant System and Security event logs
- [ ] **S019** — Inspect role-specific Directory Service/DNS/DHCP events if present
- [ ] **S020** — Identify suspicious executable and record its hash if required
- [ ] **S021** — Record scheduled-task and service evidence before disabling
- [ ] **S022** — Save every forensic answer in the original file
- [ ] **S023** — Record original account and group memberships before edits
- [ ] **S024** — Record current local security and GPO settings
- [ ] **S025** — Record original firewall rules and relevant source scopes
- [ ] **S026** — Record critical role configuration and recovery location
- [ ] **S027** — Create an approved snapshot/backup only if rules permit
- [ ] **S028** — Verify a second authorized administrative login works
- [ ] **S029** — Maintain a private change log with old/new values

## 03. Standalone and domain member local accounts  
*Full guide: [Part 3](../windows-server.md#stage-3)*

- [ ] **S030** — Determine whether local SAM user tools apply
- [ ] **S031** — List local accounts with Get-LocalUser when applicable
- [ ] **S032** — Compare all local human users to README list
- [ ] **S033** — Check built-in Guest state and required exceptions
- [ ] **S034** — Check built-in Administrator recovery requirements
- [ ] **S035** — Inspect local Administrators group
- [ ] **S036** — Inspect local Remote Desktop Users group
- [ ] **S037** — Inspect local Backup Operators group
- [ ] **S038** — Check required domain-group membership in local groups
- [ ] **S039** — Check unauthorized local user Enabled state
- [ ] **S040** — Check PasswordRequired and PasswordNeverExpires
- [ ] **S041** — Disable a confirmed unauthorized local user after evidence preservation
- [ ] **S042** — Remove only confirmed unauthorized admin membership
- [ ] **S043** — Restore any missing authorized local administrator
- [ ] **S044** — Test permitted local login and admin elevation
- [ ] **S045** — Do not use local SAM cmdlets for DC domain users

## 04. Domain accounts, privileged groups and service users  
*Full guide: [Part 3](../windows-server.md#stage-3)*

- [ ] **S046** — Confirm ActiveDirectory module availability and permissions
- [ ] **S047** — Open ADUC and enable Advanced Features if DC/AD tools exist
- [ ] **S048** — Inventory domain human users across all OUs
- [ ] **S049** — Identify domain service accounts and managed service accounts
- [ ] **S050** — Preserve krbtgt and computer objects
- [ ] **S051** — Inspect built-in domain Administrator account
- [ ] **S052** — Review Domain Admins direct membership
- [ ] **S053** — Review Domain Admins nested membership
- [ ] **S054** — Review Enterprise Admins membership if applicable
- [ ] **S055** — Review Schema Admins membership if applicable
- [ ] **S056** — Review Builtin Administrators membership
- [ ] **S057** — Review Account Operators and Backup Operators
- [ ] **S058** — Review Server Operators and Print Operators where present
- [ ] **S059** — Review DnsAdmins and Group Policy Creator Owners
- [ ] **S060** — Inspect users with PasswordNeverExpires
- [ ] **S061** — Inspect users with PasswordNotRequired
- [ ] **S062** — Inspect users lacking required Kerberos preauthentication
- [ ] **S063** — Inspect risky account delegation only when assigned
- [ ] **S064** — Disable only a confirmed unauthorized domain login
- [ ] **S065** — Remove only a confirmed unauthorized privileged-group member
- [ ] **S066** — Verify group membership and a legitimate domain login
- [ ] **S067** — Check that needed service accounts still run tasks and apps

## 05. Local and domain password/account policies  
*Full guide: [Part 3](../windows-server.md#stage-3)*

- [ ] **S068** — Record net accounts output for local-account scope
- [ ] **S069** — Identify effective domain password policy owner
- [ ] **S070** — Check password minimum length requirement
- [ ] **S071** — Check password history count
- [ ] **S072** — Check password maximum and minimum age
- [ ] **S073** — Check password complexity policy
- [ ] **S074** — Check reversible encryption policy
- [ ] **S075** — Check account lockout threshold
- [ ] **S076** — Check lockout duration
- [ ] **S077** — Check reset-counter observation period
- [ ] **S078** — Inspect Default Domain Policy at the correct domain scope
- [ ] **S079** — Check Domain Controllers OU linked GPOs
- [ ] **S080** — Inspect fine-grained password policies if AD is present
- [ ] **S081** — Inspect resultant password policy for a representative account
- [ ] **S082** — Back up specific GPO before changes
- [ ] **S083** — Change only values explicitly required by the README
- [ ] **S084** — Verify final effective account policy and allowed logon
- [ ] **S085** — Restore only incorrectly changed policy values if needed

## 06. Defender, security updates and baseline  
*Full guide: [Part 3](../windows-server.md#stage-3)*

- [ ] **S086** — Identify active antivirus provider and any passive Defender state
- [ ] **S087** — Check Windows Defender Antivirus feature when applicable
- [ ] **S088** — Check Defender real-time protection
- [ ] **S089** — Check behavior and script monitoring
- [ ] **S090** — Check Defender signature version and freshness
- [ ] **S091** — Inspect Defender path exclusions
- [ ] **S092** — Inspect process and extension exclusions
- [ ] **S093** — Compare exclusions to required server workloads
- [ ] **S094** — Apply approved signature update if required
- [ ] **S095** — Scan only when forensics are preserved and workload permits
- [ ] **S096** — Inspect Windows Update and WSUS policy
- [ ] **S097** — Inspect approved installed security updates
- [ ] **S098** — Check pending/reboot-needed updates
- [ ] **S099** — Apply permitted updates without a forced release upgrade
- [ ] **S100** — Verify DNS/AD/IIS/database/other required roles after updates

## 07. Server firewall and management access  
*Full guide: [Part 3](../windows-server.md#stage-3)*

- [ ] **S101** — Identify active Domain/Private/Public firewall profile
- [ ] **S102** — Check each firewall profile Enabled state
- [ ] **S103** — Inspect default inbound and outbound actions
- [ ] **S104** — Inventory effective inbound allow rules
- [ ] **S105** — Check AD DS, Kerberos, LDAP, RPC rules if DC
- [ ] **S106** — Check required DNS rules
- [ ] **S107** — Check required DHCP rules
- [ ] **S108** — Check required IIS web/FTP rules
- [ ] **S109** — Check required SMB/file-server rules
- [ ] **S110** — Check authorized RDP rule and source scope
- [ ] **S111** — Check authorized WinRM rule and source scope
- [ ] **S112** — List listening TCP and UDP services
- [ ] **S113** — Record original firewall settings before edits
- [ ] **S114** — Disable only confirmed unauthorized rule(s)
- [ ] **S115** — Test each required network service from an authorized client
- [ ] **S116** — Verify effective firewall profile and rule state
- [ ] **S117** — Restore a specific changed rule if service access breaks

## 08. Group Policy, auditing and LDAP  
*Full guide: [Part 3](../windows-server.md#stage-3)*

- [ ] **S118** — Inventory applicable GPO links and precedence
- [ ] **S119** — Check whether the server is DC, member or standalone
- [ ] **S120** — Inspect local audit policy when applicable
- [ ] **S121** — Inspect account logon auditing
- [ ] **S122** — Inspect account management auditing
- [ ] **S123** — Inspect security logon/logoff auditing
- [ ] **S124** — Inspect policy change auditing
- [ ] **S125** — Inspect process creation auditing when required
- [ ] **S126** — Inspect User Rights Assignment at correct policy scope
- [ ] **S127** — Check Deny logon rights for unintended groups
- [ ] **S128** — Check network logon rights needed by DC clients
- [ ] **S129** — Back up the specific GPO before editing
- [ ] **S130** — Inspect LDAP signing current policy
- [ ] **S131** — Review Directory Service LDAP unsigned-bind events
- [ ] **S132** — Check legacy LDAP client compatibility before enforcement
- [ ] **S133** — Inspect LDAP channel-binding policy and compatibility
- [ ] **S134** — Check insecure Netlogon exception settings when applicable
- [ ] **S135** — Verify applied GPO and authorized domain client logon
- [ ] **S136** — Restore one scoped policy if services break

## 09. Domain Controller and DNS health  
*Full guide: [Part 4](../windows-server.md#stage-4)*

- [ ] **S137** — Confirm NTDS role and service health if this is a DC
- [ ] **S138** — Check KDC and Netlogon operational state
- [ ] **S139** — Check DNS role and service health when required
- [ ] **S140** — Check W32Time/domain clock status
- [ ] **S141** — Check SYSVOL and NETLOGON shares remain accessible
- [ ] **S142** — Check DFS replication health when applicable
- [ ] **S143** — Run dcdiag on appropriate DC if needed
- [ ] **S144** — Review replication summary if multiple DCs are present
- [ ] **S145** — Check domain DNS SRV records
- [ ] **S146** — Inspect DNS server zone list
- [ ] **S147** — Identify AD-integrated zones where relevant
- [ ] **S148** — Inspect secure dynamic update policy
- [ ] **S149** — Inspect DNS zone transfers and approved secondary servers
- [ ] **S150** — Inspect suspicious/unknown records without bulk deletion
- [ ] **S151** — Check DNS forwarders against authorized network design
- [ ] **S152** — Verify required host and SRV name resolution from a client
- [ ] **S153** — Verify permitted dynamic update or secondary transfer
- [ ] **S154** — Restore only a changed DNS zone/record setting if required

## 10. DHCP server configuration and clients  
*Full guide: [Part 4](../windows-server.md#stage-4)*

- [ ] **S155** — Verify DHCP server role is installed only if required
- [ ] **S156** — Inspect DHCP authorization in domain if applicable
- [ ] **S157** — Record all active IPv4 scopes
- [ ] **S158** — Inspect start/end ranges and subnet masks
- [ ] **S159** — Inspect excluded address ranges
- [ ] **S160** — Inspect reservations and device MAC mappings
- [ ] **S161** — Inspect scope Option 003 router
- [ ] **S162** — Inspect scope Option 006 DNS servers
- [ ] **S163** — Inspect scope Option 015 DNS domain
- [ ] **S164** — Inspect failover pairing if configured
- [ ] **S165** — Review lease utilization and conflicting addresses
- [ ] **S166** — Check DHCP audit logging policy
- [ ] **S167** — Back up DHCP role configuration before editing
- [ ] **S168** — Change only an unauthorized scope/option/reservation
- [ ] **S169** — Renew or inspect a noncritical approved client lease
- [ ] **S170** — Verify client address, gateway and DNS settings
- [ ] **S171** — Restore the exact prior DHCP option/reservation if wrong

## 11. IIS and FTP if the server requires them  
*Full guide: [Part 4](../windows-server.md#stage-4)*

- [ ] **S172** — Confirm IIS web role and required site list
- [ ] **S173** — Record IIS site bindings and hostname/port
- [ ] **S174** — Record IIS content directories and application data
- [ ] **S175** — Back up IIS configuration before edits
- [ ] **S176** — Check web server directory browsing policy
- [ ] **S177** — Check basic/anonymous authentication requirements
- [ ] **S178** — Check request filtering and extension rules
- [ ] **S179** — Check response header/version disclosure settings
- [ ] **S180** — Check WebDAV if installed
- [ ] **S181** — Check IIS logging configuration
- [ ] **S182** — Check app pool identities and least privilege
- [ ] **S183** — Inspect suspicious web files without executing them
- [ ] **S184** — Check IIS certificate/TLS requirements
- [ ] **S185** — Test required website via actual hostname and port
- [ ] **S186** — Test application login/API and database connections
- [ ] **S187** — Inspect required FTP site if installed
- [ ] **S188** — Check FTP authentication and user authorization
- [ ] **S189** — Check FTP passive data ports and firewall support
- [ ] **S190** — Test permitted FTP login and file transfer
- [ ] **S191** — Restore only a changed IIS/FTP setting if needed

## 12. SMB, roles, services and print spooler  
*Full guide: [Part 4](../windows-server.md#stage-4)*

- [ ] **S192** — List all SMB shares including special administrative shares
- [ ] **S193** — Preserve required SYSVOL and NETLOGON on DCs
- [ ] **S194** — Inspect authorized custom share paths
- [ ] **S195** — Inspect share-level permission entries
- [ ] **S196** — Inspect NTFS ACLs for required share folders
- [ ] **S197** — Check SMB1 server compatibility and installed state
- [ ] **S198** — Check SMB signing requirement and authorized clients
- [ ] **S199** — Test share read/write as a permitted ordinary user
- [ ] **S200** — Test denied share access for a disallowed user when approved
- [ ] **S201** — Inventory installed roles and features
- [ ] **S202** — Review legacy Telnet/TFTP/SNMP/SMB1/PowerShell2 features
- [ ] **S203** — Preview any role removal one feature at a time
- [ ] **S204** — Never remove AD DS/DNS/DHCP/IIS required by README
- [ ] **S205** — Inventory running and startup-configured services
- [ ] **S206** — Identify unexpected service executable paths
- [ ] **S207** — Inspect Print Spooler requirement and print-server role
- [ ] **S208** — Inspect Point and Print driver installation restrictions
- [ ] **S209** — Keep WinRM/management functionality if required
- [ ] **S210** — Disable only a confirmed unneeded service
- [ ] **S211** — Verify all required roles still work after changes

## 13. Remote access, persistence and miscellaneous  
*Full guide: [Part 5](../windows-server.md#stage-5)*

- [ ] **S212** — Check RDP allowed/denied state
- [ ] **S213** — Check Network Level Authentication when RDP is required
- [ ] **S214** — Check RDP authorization groups or DC logon rights
- [ ] **S215** — Check Remote Assistance only if installed/relevant
- [ ] **S216** — Inspect WinRM authentication and encryption policies
- [ ] **S217** — Inspect WinRM listeners and management firewall rules
- [ ] **S218** — Inspect installed remote-control applications
- [ ] **S219** — Inspect startup registry Run entries
- [ ] **S220** — Inspect scheduled tasks and task actions
- [ ] **S221** — Inspect service Log On As accounts
- [ ] **S222** — Inspect new services with unexpected executable paths
- [ ] **S223** — Inspect unknown inbound listening ports
- [ ] **S224** — Inspect file hashes/signatures of suspicious executables
- [ ] **S225** — Check required backup/scheduled tasks are preserved
- [ ] **S226** — Check UAC and relevant Security Options
- [ ] **S227** — Check browser updates if server browser access is required
- [ ] **S228** — Preserve event logs and forensic evidence
- [ ] **S229** — Restore specific unauthorized or mistakenly changed items

## 14. Final server-role validation  
*Full guide: [Part 6](../windows-server.md#stage-6)*

- [ ] **S230** — Verify all forensic answers saved and complete
- [ ] **S231** — Verify correct standalone/member/DC role
- [ ] **S232** — Verify authorized local and domain administrators
- [ ] **S233** — Verify correct effective password and lockout policies
- [ ] **S234** — Verify Defender and current approved updates
- [ ] **S235** — Verify applicable firewall profiles and required exceptions
- [ ] **S236** — Verify fresh authorized local/domain logon
- [ ] **S237** — Verify AD, DNS, Netlogon, time and replication if DC
- [ ] **S238** — Verify DHCP client obtains required configuration
- [ ] **S239** — Verify IIS/FTP required client transactions
- [ ] **S240** — Verify required SMB sharing and NTFS access
- [ ] **S241** — Verify authorized RDP/WinRM access if required
- [ ] **S242** — Verify unnecessary services/roles remain disabled or removed safely
- [ ] **S243** — Verify no unauthorized accounts or persistence remain
- [ ] **S244** — Refresh official scoring report and record final value
- [ ] **S245** — Record any N/A tasks with supporting rationale
- [ ] **S246** — Save rollback notes and finish without unplanned reboot

---

### Completion notes

**N/A task IDs / reasons:** ______________________________________________________________

**Critical services tested and results:** __________________________________________________

**Outstanding service or score problems:** ________________________________________________

**Reviewer initials / date:** ____________________________________________________________
