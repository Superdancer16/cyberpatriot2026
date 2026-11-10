# Sources, attribution and maintenance

## Existing documentation and reuse scope

The repository's original README states that documentation was reproduced **with permission** from [Ripper1004/CyberPatriot-Toolkit documentation](https://github.com/Ripper1004/CyberPatriot-Toolkit/tree/main/docs). That attribution is retained. The permission statement predates this expansion; the repository does not contain a separate permission instrument defining broader redistribution rights.

Reference checkout reviewed: Ripper1004/CyberPatriot-Toolkit revision `5761e54b98840d73aebaebbc42e372871ec02beb`. No LICENSE/COPYING file was found in that checkout. Do not infer an open-source license or permission for unrelated scripts/assets from public visibility. Keep existing attribution when sharing these guides; seek clarification from the rights holder before assuming broader reuse terms. No upstream scripts or website assets are added by this expansion.

[BiermanM/CyberPatriot-Scripts](https://github.com/BiermanM/CyberPatriot-Scripts), revision `0efbe1e4bfeddab867a16c8554115c2f454b24ca`, was reviewed for defensive topics: user/group inventory, backups, startup/cron review, SSH, services, repositories, permissions and kernel policy. Its README and Ubuntu/Mint/Debian script content informed topic selection. No LICENSE/COPYING file was found there either. The new procedures are original explanations of native administration techniques, not reproduced script implementations or historical baseline files.

The old scripts date from a substantially older Linux ecosystem. Do not adopt their world-readable shadow permissions, logged/shared passwords, bulk deletion, release-specific repository replacements, obsolete PAM modules or global cron removal. This handbook instead requires private backups, release-aware configuration, explicit scenario exceptions and client verification.

## Official references for version-sensitive settings

Consult the documentation matching the **installed version**, especially when a command/property is absent. A reference's current version may differ from an older competition image.

| Area | Authoritative starting point |
|---|---|
| Windows service state/startup and dependencies | [Microsoft Set-Service](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-service) |
| AD Group Policy scope/inheritance | [Microsoft Group Policy overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview) |
| Windows security policy and audit options | [Microsoft security policy settings](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/security-policy-settings) and installed `auditpol /?` |
| Ubuntu OpenSSH config and verification | [Ubuntu Server OpenSSH](https://documentation.ubuntu.com/server/how-to/security/openssh-server/) and installed `man sshd_config` |
| Ubuntu firewall administration | [Ubuntu Server firewall](https://documentation.ubuntu.com/server/how-to/security/firewalls/) |
| Debian security and release maintenance | [Debian security information](https://www.debian.org/security/) and [Debian Reference](https://www.debian.org/doc/manuals/debian-reference/) |
| Mint release-specific desktop/software tools | [Linux Mint documentation](https://linuxmint.com/documentation.php) |
| PAM module integration | Installed `man pam-auth-update`, `man pam_faillock`, `man pam_pwhistory`, `man pam_pwquality` |
| FreeBSD pf/ipfw and rc administration | [FreeBSD Handbook firewalls](https://docs.freebsd.org/en/books/handbook/firewalls/), [configuration](https://docs.freebsd.org/en/books/handbook/config/) and installed `man rc.conf`, `man login.conf`, `man pw` |
| Cisco ACL ordering, direction and wildcard examples | [Cisco commonly used IP ACLs](https://www.cisco.com/c/en/us/support/docs/ip/access-lists/26448-ACLsamples.html) and the device's IOS configuration guide/context help |
| PostgreSQL client authentication | [PostgreSQL pg_hba.conf](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html) and documentation for the installed major version |

## Maintaining an actionable procedure

- [ ] Confirm the exact OS/release, package and required role before editing.
- [ ] Preserve the existing headings, checklists, tables and relative navigation.
- [ ] Distinguish shell commands from configuration excerpts and example placeholders.
- [ ] Include before-state collection, private backup, exact editing path, syntax checks where supported, apply/reload behavior, ordinary-client verification and targeted undo.
- [ ] Check missing-feature and compatibility cases rather than installing unnecessary roles.
- [ ] Keep forensic collection before remediation; never publish active competition answers or secrets.
- [ ] Record whether commands were reviewed from documentation or actually exercised on a matching lab system. This documentation expansion was reviewed statically; its Windows, Linux, FreeBSD and IOS examples were not executed against competition images.

Round schedules, resource rules, team limits and scoring behavior come from the current official round materials. The inherited season tables are reference context, not an authoritative schedule or guarantee of a particular image.
