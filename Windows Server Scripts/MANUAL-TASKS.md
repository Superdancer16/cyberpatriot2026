# Windows Server — manual checks after windows-server.ps1

Use this after [windows-server.ps1](windows-server.ps1). The current image README and the [Windows Server handbook](../Windows/windows-server.md) take priority. **Manual** means the action or authorization needs human judgement. **Verify** means the script may have changed a setting, but you must confirm the result and scoring.

## 1. Before changing anything

- [ ] **Read the image README.** Record authorized local/domain users, administrators, groups, service accounts, DNS/DHCP/IIS roles, shares, required ports and prohibited software. [Initial steps](../Windows/windows-server.md#0-before-you-touch-anything).
- [ ] **Save forensic answers and evidence first.** Never delete an account, file, service or log before preserving anything required by a question. [Forensics](../Windows/windows-server.md#ws1-forensics-questions-first).
- [ ] **Record the starting score and recovery method.** Keep an authorized administrator console and a VM recovery path. Make a snapshot only if the rules permit it.
- [ ] **Identify the server role.** In **Server Manager → Local Server**, check whether the VM is standalone, a domain member or a Domain Controller. On Server Core inspect the same facts with PowerShell. [Identify the role](../Windows/windows-server.md#11-find-out-what-kind-of-server-it-is).

## 2. Review results

- [ ] Open the newest `summary-*.csv` and `changes-*.txt` under **C:\ProgramData\ServerSecurityWork**. Investigate **FAILED** first, then **REVIEW** and **SKIPPED**; a **CHANGED** result does not mean points were awarded.
- [ ] Review the before/after role reports in the corresponding `backups-*` folder. Compare authorized users, services, firewall rules, listeners, installed roles, shares and security policies.
- [ ] Compare the Scoring Report to your initial score. If required services or scoring regressed, restore only the specific recorded change. [Recovery](../Windows/windows-server.md#12-role-aware-manual-procedures-and-recovery).

## 3. Local accounts and groups (standalone/member only)

- [ ] **Manual — create users or reset passwords skipped in `-Yes` mode:** **Win + R → `lusrmgr.msc` → Users → Action → New User** or right-click an existing authorized user → **Set Password**. Use exact README names and secure prompts; test a permitted login. [Local accounts](../Windows/windows-server.md#21-standalone-member-server-fully-documented-local-accounts).
- [ ] **Verify — administrators:** **`lusrmgr.msc` → Groups → Administrators**. Remove only unauthorized membership, retain a working administrator, and keep required standard users enabled. [Local groups](../Windows/windows-server.md#21-standalone-member-server-fully-documented-local-accounts).
- [ ] **Verify — required custom group creation:** **`lusrmgr.msc` → Groups → Action → New Group** if missing. Creating a group and adding its members are separate checks. [Local groups](../Windows/windows-server.md#21-standalone-member-server-fully-documented-local-accounts).
- [ ] **Verify — group members:** Double-click each required group → **Members → Add → Check Names** for exact authorized users. Reopen to confirm membership. [Local groups](../Windows/windows-server.md#21-standalone-member-server-fully-documented-local-accounts).
- [ ] **Verify — Guest and password flags:** Check Guest is disabled when required, and ordinary users have the correct **Password never expires** setting. Preserve required service identities. [User auditing](../Windows/windows-server.md#ws2-users-and-groups).

## 4. Active Directory (Domain Controller only)

- [ ] **Verify — domain accounts:** **Win + R → `dsa.msc` → Active Directory Users and Computers → View → Advanced Features**. Compare exact names, enabled flags, OUs and service identities. The script never deletes AD accounts. [AD users](../Windows/windows-server.md#22-domain-controller-domain-users-and-authorized-accounts).
- [ ] **Manual — privileged groups:** Review **Domain Admins, Enterprise Admins, Schema Admins, Administrators, Account Operators, Backup Operators, Server Operators and DnsAdmins**, including nested membership. The script protects these groups from automatic edits. [Privileged groups](../Windows/windows-server.md#23-domain-controller-powerful-groups).
- [ ] **Manual — GPO scope:** In **`gpmc.msc`**, inspect linked policies, precedence, unexpected settings and the relevant domain root. Do not delete or unlink a GPO to fix an individual policy. [GPO checks](../Windows/windows-server.md#43-look-for-planted-bad-group-policies).
- [ ] **Verify — explicit AD writes:** AD changes require the correct DC/domain, `DomainChanges.Allowed=true` and the `-EnableDomainChanges` option. Verify exact OU, user/group membership and authorized login after any change. [AD accounts](../Windows/windows-server.md#22-domain-controller-domain-users-and-authorized-accounts).

## 5. Passwords, audits and system policies

- [ ] **Verify — local password/lockout:** **Win + R → `secpol.msc` → Account Policies**, inspect the actual README-required numbers, complexity and reversible encryption. Member server local policy may be overridden by a domain GPO. [Local password rules](../Windows/windows-server.md#31-standalone-or-member-server-local-password-and-lockout-policies).
- [ ] **Verify — domain default and fine-grained password policies:** On a DC use **`gpmc.msc`** and AD Administrative Center or AD cmdlets. Check which policy applies to each user; the default policy alone may not determine effective requirements. [Domain password policies](../Windows/windows-server.md#32-domain-controller-domain-default-policy-and-fine-grained-policies).
- [ ] **Verify — advanced auditing:** Use **`secpol.msc` → Advanced Audit Policy Configuration** or the governing GPO. Confirm specified Success/Failure categories; do not enable every high-volume category blindly. [Audit and rights](../Windows/windows-server.md#4-audit-policy-user-rights-and-security-options).
- [ ] **Verify — user rights:** **`secpol.msc` → Local Policies → User Rights Assignment** or the effective DC policy. Check exact principals, service SIDs, audit rights and ownership; do not remove required built-ins. [Rights](../Windows/windows-server.md#41-standalonemember-server-audit-policy-user-rights-and-security-options).
- [ ] **Verify — UAC, NTLM and network policies:** Confirm the effective Security Options, administrator approval and required client compatibility before restricting legacy authentication. [Security options](../Windows/windows-server.md#ws43-security-options).

## 6. Defender, firewall and Windows updates

- [ ] **Verify — Defender:** Inspect **Windows Security → Virus & threat protection**, actual antivirus provider, exclusions and Protection History. Check that required executables were not quarantined. [Defender](../Windows/windows-server.md#51-microsoft-defender-antivirus-on-windows-server).
- [ ] **Verify — firewall profiles and role groups:** **Win + R → `wf.msc`**, inspect Domain/Private/Public and enabled inbound rules. Preserve all required AD/DNS/DHCP/IIS/SMB/remote management ports, and test from an authorized client. [Firewall](../Windows/windows-server.md#52-windows-server-firewall-role-aware-standalone-procedure).
- [ ] **Verify — server updates:** Open **Server Manager → Local Server → Windows Update** or the supported Core command. Check for failed/pending updates and restart requirements. The script never reboots. [Updates](../Windows/windows-server.md#53-windows-server-updates-and-security-maintenance).
- [ ] **Manual — printing:** If printing is required, preserve the spooler and inspect Point and Print driver restrictions, then test an authorized printer. [Print security](../Windows/windows-server.md#63-print-spooler-point-and-print-and-printnightmare).

## 7. Critical server roles

- [ ] **Verify — critical services/features:** Open **`services.msc`** and **Server Manager → Manage → Add Roles and Features** for inspection. Never remove AD DS, Kerberos, DNS, DHCP, IIS, DFSR, required file services or WinRM simply because a generic checklist suggests it. [Services](../Windows/windows-server.md#6-services) · [Roles](../Windows/windows-server.md#7-roles-and-features).
- [ ] **Verify — Domain Controller health:** Check domain login, `repadmin /replsummary`, `dcdiag`, SYSVOL/NETLOGON, DNS SRV records and time synchronization. The script reports health but does not fix replication automatically. [AD](../Windows/windows-server.md#94-active-directory).
- [ ] **Verify — DNS:** **Win + R → `dnsmgmt.msc` → zone Properties**, check secure updates where supported, authorized secondary transfers, suspicious records and actual client resolution. [DNS](../Windows/windows-server.md#93-dns-server).
- [ ] **Verify — DHCP:** **Win + R → `dhcpmgmt.msc`**, check scopes, authorization, reservations, audit logs and option 003 Router / 006 DNS Servers. Verify a real client receives a correct lease. [DHCP](../Windows/windows-server.md#95-dhcp-server).
- [ ] **Verify — IIS sites and pools:** **Win + R → `inetmgr`**. Test required sites, authentication, headers, directory browsing, request filtering, application pools and HTTP bindings. The script only changes configured site browsing settings. [IIS](../Windows/windows-server.md#91-iis-web-server).
- [ ] **Verify — IIS FTP:** Check exact FTP users, authentication, TLS, data/passive ports and file transfer with an authorized client. [FTP](../Windows/windows-server.md#92-iis-ftp-server).
- [ ] **Verify — file shares and NTFS ACLs:** **`fsmgmt.msc` → Shares → Properties**, then the backing folder **Properties → Security**. Required SYSVOL/NETLOGON and system shares must remain. Test user access. [File sharing](../Windows/windows-server.md#96-file-server-shares).

## 8. Remote management, TLS, software and persistence

- [ ] **Verify — RDP/NLA:** Inspect **System Properties → Remote** and test an authorized RDP login if required. Never cut off your only administrative session. [Remote access](../Windows/windows-server.md#81-remote-desktop-and-remote-assistance-server-specific-procedure).
- [ ] **Verify — WinRM:** Check `winrm get winrm/config/service` for Basic/unencrypted policies and test approved remote management. [WinRM](../Windows/windows-server.md#82-lock-down-winrm).
- [ ] **Verify — TLS settings:** Test IIS HTTPS, LDAPS, RDP, FTP and legacy SQL clients after an authorized protocol change and controlled restart. The script applies TLS changes only with explicit compatibility confirmation. [TLS](../Windows/windows-server.md#97-turn-off-ssl-30-tls-10-and-tls-11).
- [ ] **Manual — prohibited software and files:** Review Installed apps, portable tools and exact README-restricted folders. The script removes only explicitly listed targets; unknown files should be investigated before removal. [Software](../Windows/windows-server.md#10-prohibited-software-files-startup-persistence-browser-and-security-settings).
- [ ] **Manual — startup persistence and listeners:** Check the saved startup, IFEO debugger, task, listener and event reports. Verify executable paths, timestamps and signatures before disabling anything; never kill a process using a PID copied from another image. [Advanced investigations](../Windows/windows-server.md#ws21-advanced-windows-server-investigations-included-in-this-handbook).

## 9. Final verification

- [ ] The Scoring Report has no new penalties and required forensic answers are saved.
- [ ] All authorized local/domain accounts still authenticate; admin and group membership is correct.
- [ ] Every required AD, DNS, DHCP, IIS, FTP, SMB, database, printing and remote-management function works.
- [ ] Every **FAILED**, **REVIEW** and **SKIPPED** result has been checked; backups and change logs are retained.
- [ ] Restart only at an approved checkpoint, then re-test required services. [Final checklist](../Windows/windows-server.md#11-final-checks).

**Recovery:** Use the matching `C:\ProgramData\ServerSecurityWork` backup directory and [server recovery procedures](../Windows/windows-server.md#12-role-aware-manual-procedures-and-recovery). There is no guaranteed one-click undo for deleted users, files, roles or changed domain configuration.

This code has not been tested on a real competition Server VM in this session. Server Core requires console or supported PowerShell tools instead of desktop GUI directions.
