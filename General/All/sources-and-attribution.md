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


## Additional public research reviewed for the 2026–27 priority-order expansion

These are **supplemental topic inventories**, not authorities for unverified numeric point values or permission to run third-party scripts:

- [CyberPatriot official CP-19 challenges by round](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round): published lineups, module ranges and challenge maximums; not individual vulnerability scoring.
- [CyberPatriot official training materials](https://www.uscyberpatriot.org/competition/training-materials): quiz/Packet Tracer modules and the distinction between Content Course and Competition Course.
- [Minagera Windows CyberPatriot checklist](https://github.com/Minagera/CyberPatriot/blob/main/CyberPatriot/Checklists/Windows/README.md): local account and privilege, Defender, policy, startup and persistence categories.
- [Minagera Linux CyberPatriot checklist](https://github.com/Minagera/CyberPatriot/blob/main/CyberPatriot/Checklists/Linux/README.md): user/sudo, packages, SSH, file permission, persistence and service categories.
- [chessischess Windows/Server/Linux checklist collection](https://github.com/chessischess/cyberpatriot-checklist): student-friendly inspection sequence, service and troubleshooting topics.
- [Ripper1004 CyberPatriot Security Script checklists](https://github.com/Ripper1004/CyberPatriot-Security-Script): historical topic coverage; **scripts were not copied or run**.
- [Microsoft Security Baselines](https://learn.microsoft.com/windows/security/threat-protection/windows-security-configuration-framework/windows-security-baselines): vetted Windows and Server hardening context, subject to required-role exceptions.
- [Debian Bookworm LTS announcement (July 2026)](https://www.debian.org/News/2026/20260712): LTS support through June 2028 with package/architecture limits.
- [Debian Bullseye LTS end (August 2026)](https://www.debian.org/News/2026/20260831): historical Debian 11 support status.
- [Linux Mint LightDM settings project](https://github.com/linuxmint/lightdm-settings): Linux Mint-specific login window/autologin controls.

**Practice priority rationale:** Public checklist consensus frequently begins with image constraints, forensics, user/admin privilege, security tooling, system updates, firewall and required-service availability, then persistence and advanced configuration. **No source establishes that any particular generic fix is worth a stated number of competition points.** Disagreements are resolved by official vendor documentation and the actual competition image requirements.
