# 🐧 Debian — Printable Checklist & GitHub Progress Tracker

> **Source:** [Complete Debian guide](../Linux/debian.md). This is a **new companion tracker**; no original guides are changed.
>
> **Print:** Use `debian-checklist.pdf` in this folder and mark each individual square.
>
> **Track on GitHub:** Edit this file and replace `[ ]` with `[x]` as each task is completed; commit your changes. For irrelevant tasks, annotate `(N/A — reason)`. Checkboxes viewed on GitHub are not automatically saved by clicking them.
>
> **Safety:** Use the actual image README, preserve forensic evidence, and check that required services/administrator access remain available. Not every task requires a configuration change.

**Round/date:** ___________________  **Debian release:** ______________  **Team:** __________________

**Starting score:** __________  **Final score:** __________  **Reviewer:** __________________

## 01. Identify Debian and establish recovery  
*Full guide: [Part 1](../Linux/debian.md#stage-1)*

- [ ] **D001** — Read the actual README and any special competition constraints
- [ ] **D002** — Check Debian version and codename in /etc/os-release
- [ ] **D003** — Record whether the system uses GNOME, another desktop, or no GUI
- [ ] **D004** — Confirm current user and UID/GID with id
- [ ] **D005** — Check whether sudo is installed and authorized
- [ ] **D006** — Confirm a working root or authorized sudo recovery path
- [ ] **D007** — Record system hostname and network interface addresses
- [ ] **D008** — Record default route and DNS behavior
- [ ] **D009** — Record starting scoring-report value and timestamp
- [ ] **D010** — List required human accounts and authorized administrators
- [ ] **D011** — List required services, server roles, shares and listening ports
- [ ] **D012** — Identify prohibited software and files listed by the README
- [ ] **D013** — Take an approved VM snapshot if allowed
- [ ] **D014** — Create private change notes and record original values

## 02. Forensic evidence before remediation  
*Full guide: [Part 2](../Linux/debian.md#stage-2)*

- [ ] **D015** — Open every forensic question and note the exact answer format
- [ ] **D016** — Locate requested files before deleting or updating anything
- [ ] **D017** — Inspect file metadata with stat where relevant
- [ ] **D018** — Identify actual file type with file when relevant
- [ ] **D019** — Calculate requested SHA-256 hash with sha256sum
- [ ] **D020** — Investigate suspicious service, task or process paths
- [ ] **D021** — Inspect current system journal without clearing it
- [ ] **D022** — Review relevant ssh, sudo and cron journal entries
- [ ] **D023** — Check login history when the question involves user activity
- [ ] **D024** — Decode requested encoded text only as data
- [ ] **D025** — Save every forensic answer in the original supplied file
- [ ] **D026** — Confirm evidence was preserved and unanswered questions are noted

## 03. Human accounts, root, and administrator groups  
*Full guide: [Part 3](../Linux/debian.md#stage-3)*

- [ ] **D027** — Inventory /etc/passwd entries and likely human users
- [ ] **D028** — Compare local human accounts with the README
- [ ] **D029** — Identify any additional UID 0 account
- [ ] **D030** — Inspect root account password-lock status
- [ ] **D031** — Confirm the system's root-versus-sudo administration design
- [ ] **D032** — Inspect sudo group members
- [ ] **D033** — Inspect adm group members
- [ ] **D034** — Inspect disk, shadow, docker, lxd and libvirt group members if present
- [ ] **D035** — Inspect sudoers and sudoers.d authorization rules
- [ ] **D036** — Check for NOPASSWD or unsafe wildcard sudo grants
- [ ] **D037** — Validate sudo policy syntax with visudo -c
- [ ] **D038** — Review each normal user's login shell
- [ ] **D039** — Identify unexpected human accounts with a service-like UID
- [ ] **D040** — Check missing README-authorized users
- [ ] **D041** — Lock only a confirmed unauthorized login after evidence is saved
- [ ] **D042** — Remove only confirmed unauthorized privileged membership
- [ ] **D043** — Verify authorized sudo/root administration still works
- [ ] **D044** — Open a second authorized login after privilege changes

## 04. Password aging, quality, and PAM  
*Full guide: [Part 3](../Linux/debian.md#stage-3)*

- [ ] **D045** — Inspect login.defs password-aging defaults
- [ ] **D046** — Inspect each authorized user's actual aging with chage -l
- [ ] **D047** — Check password-required/empty-password status when applicable
- [ ] **D048** — Inspect common-auth PAM lines
- [ ] **D049** — Inspect common-password PAM lines
- [ ] **D050** — Check which PAM modules and auth profiles are actually installed
- [ ] **D051** — Inspect pam_pwquality usage and settings
- [ ] **D052** — Inspect password history integration if required
- [ ] **D053** — Inspect failed-login/lockout module integration if required
- [ ] **D054** — Check for unexpected pam_exec or pam_permit entries
- [ ] **D055** — Check packaged PAM file integrity with dpkg -V when appropriate
- [ ] **D056** — Preserve original common-auth before changes
- [ ] **D057** — Preserve original common-password before changes
- [ ] **D058** — Set user password aging only to README-required values
- [ ] **D059** — Set an authorized user's password interactively if required
- [ ] **D060** — Validate PAM integration before ending the current root session
- [ ] **D061** — Test a new authorized normal-user login
- [ ] **D062** — Test sudo elevation in a second session
- [ ] **D063** — Verify final chage and PAM settings against the requirement
- [ ] **D064** — Restore the exact PAM backup if authentication fails

## 05. Signed APT sources, packages and updates  
*Full guide: [Part 3](../Linux/debian.md#stage-3)*

- [ ] **D065** — Record the installed Debian release codename
- [ ] **D066** — Inspect active .list and deb822 .sources entries
- [ ] **D067** — Check configured Debian security suite for the installed release
- [ ] **D068** — Check apt repository signatures and any Trusted=yes bypass
- [ ] **D069** — Check for mixed Ubuntu/Mint/testing/unstable sources
- [ ] **D070** — Identify unknown repositories and their owner/purpose
- [ ] **D071** — Inspect held packages using apt-mark showhold
- [ ] **D072** — Check incomplete packages with dpkg --audit
- [ ] **D073** — Run apt update and investigate errors
- [ ] **D074** — Preview upgrades before applying them
- [ ] **D075** — Check if approved security updates are outstanding
- [ ] **D076** — Check unattended-upgrades package if the image requires it
- [ ] **D077** — Inspect automatic update timer and periodic configuration
- [ ] **D078** — Inspect supported Debian LTS coverage for relevant packages
- [ ] **D079** — Apply approved updates without performing a release upgrade
- [ ] **D080** — Recheck package state and required application functionality

## 06. Firewall and exposed network services  
*Full guide: [Part 3](../Linux/debian.md#stage-3)*

- [ ] **D081** — Inventory listening TCP services with ss
- [ ] **D082** — Inventory listening UDP services with ss
- [ ] **D083** — Inspect native nftables ruleset
- [ ] **D084** — Check whether nftables.service controls the firewall
- [ ] **D085** — Check whether UFW is installed and active
- [ ] **D086** — Identify any other firewall manager already in use
- [ ] **D087** — List README-required inbound service ports
- [ ] **D088** — Identify required management source addresses
- [ ] **D089** — Back up the actual firewall configuration before edits
- [ ] **D090** — Validate nftables config syntax when applicable
- [ ] **D091** — Ensure required SSH access remains possible before deny rules
- [ ] **D092** — Add only necessary service exceptions
- [ ] **D093** — Apply reviewed firewall policy only with recovery access
- [ ] **D094** — Verify effective rules after changes
- [ ] **D095** — Test required service connections from an authorized client
- [ ] **D096** — Restore the old specific rule/config if access breaks

## 07. SSH authentication, ports and authorized keys  
*Full guide: [Part 4](../Linux/debian.md#stage-4)*

- [ ] **D097** — Check whether openssh-server is installed and required
- [ ] **D098** — Check ssh service status and startup state
- [ ] **D099** — Check ssh.socket status if used
- [ ] **D100** — Record actual SSH listening interface and port
- [ ] **D101** — Inspect sshd_config and included snippets
- [ ] **D102** — Check PermitRootLogin effective value
- [ ] **D103** — Check PermitEmptyPasswords effective value
- [ ] **D104** — Check PasswordAuthentication effective value
- [ ] **D105** — Check PubkeyAuthentication and authorized client need
- [ ] **D106** — Check Match blocks that change settings by user or host
- [ ] **D107** — Search authorized_keys files for unexpected entries
- [ ] **D108** — Check ownership and permissions of relevant SSH keys
- [ ] **D109** — Back up the specific config before a change
- [ ] **D110** — Validate config syntax with sshd -t
- [ ] **D111** — Reload only the applicable SSH service after approved edits
- [ ] **D112** — Test a second SSH login before closing the first
- [ ] **D113** — Verify final effective settings and port listener
- [ ] **D114** — Restore backup from VM console if SSH access breaks

## 08. Required and unnecessary services  
*Full guide: [Part 4](../Linux/debian.md#stage-4)*

- [ ] **D115** — Inventory running systemd services
- [ ] **D116** — Inventory enabled service units
- [ ] **D117** — Inspect failed systemd units
- [ ] **D118** — Inspect active socket units and activation paths
- [ ] **D119** — Identify service dependencies and required client operations
- [ ] **D120** — Check Apache or Nginx if README-required
- [ ] **D121** — Check MariaDB/MySQL or PostgreSQL if README-required
- [ ] **D122** — Check Samba sharing if README-required
- [ ] **D123** — Check DNS or DHCP servers if README-required
- [ ] **D124** — Check FTP, mail or printing if README-required
- [ ] **D125** — Check listening ports against required services
- [ ] **D126** — Inspect unwanted legacy Telnet/TFTP/VNC services if installed
- [ ] **D127** — Inspect suspicious service ExecStart and User fields
- [ ] **D128** — Preserve configuration and evidence before service changes
- [ ] **D129** — Disable only confirmed unauthorized services
- [ ] **D130** — Verify every README-required role still performs its function
- [ ] **D131** — Restore the original startup/running state if needed

## 09. Software, games, media and installed applications  
*Full guide: [Part 4](../Linux/debian.md#stage-4)*

- [ ] **D132** — Inventory installed packages for explicitly prohibited software
- [ ] **D133** — Inspect games installed as GNOME packages if present
- [ ] **D134** — Inspect unauthorized network, password-cracking or remote tools
- [ ] **D135** — Check Firefox ESR or other README-required browsers
- [ ] **D136** — Inspect portable executables outside APT package inventory
- [ ] **D137** — Check relevant files in home, tmp and var/tmp
- [ ] **D138** — Find potentially prohibited media files without mass deletion
- [ ] **D139** — Preserve user or forensic files associated with a question
- [ ] **D140** — Preview APT purge dependencies before removing a package
- [ ] **D141** — Remove only a confirmed prohibited package or file
- [ ] **D142** — Verify package state and required applications afterward
- [ ] **D143** — Restore a mistakenly removed app with its configuration

## 10. File ownership, permissions and capabilities  
*Full guide: [Part 4](../Linux/debian.md#stage-4)*

- [ ] **D144** — Inspect /etc/passwd owner/group and file permissions
- [ ] **D145** — Inspect /etc/group owner/group and file permissions
- [ ] **D146** — Inspect /etc/shadow and /etc/gshadow access restrictions
- [ ] **D147** — Inspect /etc/sudoers and sudoers.d permissions
- [ ] **D148** — Search for world-writable files in /etc
- [ ] **D149** — Search for suspicious writable files in /usr/local or /opt
- [ ] **D150** — Inventory unusual SUID executables in relevant directories
- [ ] **D151** — Inventory unusual SGID executables in relevant directories
- [ ] **D152** — Check capability-bearing binaries if getcap is installed
- [ ] **D153** — Check home directory exposure for required users
- [ ] **D154** — Compare suspicious binary ownership with dpkg package records
- [ ] **D155** — Record original owner/mode before any adjustment
- [ ] **D156** — Fix only a verified incorrect sensitive-file permission
- [ ] **D157** — Verify needed programs and normal login still work

## 11. Scheduled tasks, startup and persistence  
*Full guide: [Part 4](../Linux/debian.md#stage-4)*

- [ ] **D158** — Inspect root crontab
- [ ] **D159** — Inspect system crontab
- [ ] **D160** — Inspect scheduled entries in cron.d
- [ ] **D161** — Inspect user crontabs relevant to the question
- [ ] **D162** — Inspect enabled systemd units
- [ ] **D163** — Inspect systemd timers
- [ ] **D164** — Inspect suspicious unit file and ExecStart command
- [ ] **D165** — Check service logs and execution times
- [ ] **D166** — Inspect shell profile and profile.d startup entries
- [ ] **D167** — Inspect suspicious PATH modifications and aliases
- [ ] **D168** — Inspect /etc/hosts for unexpected redirects
- [ ] **D169** — Map unexpected network listeners to processes
- [ ] **D170** — Preserve task/unit configuration and forensic evidence
- [ ] **D171** — Disable only a confirmed malicious scheduled entry
- [ ] **D172** — Verify unwanted persistence no longer activates
- [ ] **D173** — Restore any required job or service mistakenly disabled

## 12. Logging, AppArmor and kernel security  
*Full guide: [Part 5](../Linux/debian.md#stage-5)*

- [ ] **D174** — Inspect journald boot history and log retention
- [ ] **D175** — Check relevant authentication events
- [ ] **D176** — Check journal error and warning events
- [ ] **D177** — Check whether rsyslog is installed and required
- [ ] **D178** — Check whether auditd is installed and required
- [ ] **D179** — Check audit rules and disk/log volume before new rules
- [ ] **D180** — Check AppArmor service and module status
- [ ] **D181** — Inspect AppArmor enforcing/complain profiles
- [ ] **D182** — Investigate relevant AppArmor DENIED events
- [ ] **D183** — Check kernel ASLR setting
- [ ] **D184** — Check forwarding policy when the machine is not a router
- [ ] **D185** — Check redirects/source-routing settings if required
- [ ] **D186** — Check IPv6 role before changing IPv6 sysctl
- [ ] **D187** — Back up actual sysctl/profile files before changes
- [ ] **D188** — Verify required services after AppArmor/sysctl changes

## 13. Critical-server role checks (when required)  
*Full guide: [Part 5](../Linux/debian.md#stage-5)*

- [ ] **D189** — Record required server roles before changing their configurations
- [ ] **D190** — Back up actual configuration for each required role
- [ ] **D191** — Check Apache site and directory browsing policy
- [ ] **D192** — Validate Apache syntax before reload
- [ ] **D193** — Test required Apache site from an authorized client
- [ ] **D194** — Check Nginx server_tokens and autoindex if installed
- [ ] **D195** — Validate Nginx syntax before reload
- [ ] **D196** — Test required Nginx site and hostname
- [ ] **D197** — Check PHP web SAPI settings if applicable
- [ ] **D198** — Check MariaDB authentication and database privileges if required
- [ ] **D199** — Test required database query/application operation
- [ ] **D200** — Check vsftpd anonymous access if FTP is required
- [ ] **D201** — Test authorized FTP login and data transfer
- [ ] **D202** — Check Samba share definitions and filesystem permissions
- [ ] **D203** — Validate Samba config with testparm if installed
- [ ] **D204** — Test authorized Samba client read/write
- [ ] **D205** — Check required DNS zone/records and query behavior
- [ ] **D206** — Check required DHCP pool and client leases
- [ ] **D207** — Check mail server authentication and relay restrictions if required
- [ ] **D208** — Restore only a changed service config if a client test fails

## 14. Desktop and final verification  
*Full guide: [Part 6](../Linux/debian.md#stage-6)*

- [ ] **D209** — Identify current display manager and desktop environment
- [ ] **D210** — Check GNOME or actual desktop automatic login setting
- [ ] **D211** — Check screen lock after inactivity
- [ ] **D212** — Check lock on resume if the desktop provides it
- [ ] **D213** — Check unauthorized remote desktop or sharing
- [ ] **D214** — Check normal user login and sudo elevation
- [ ] **D215** — Reopen every forensic question and verify saved answers
- [ ] **D216** — Recheck users and privileged groups against README
- [ ] **D217** — Recheck firewall and required service clients
- [ ] **D218** — Recheck failed services and security logs
- [ ] **D219** — Recheck installed updates and held packages
- [ ] **D220** — Confirm unauthorized programs and persistence were addressed
- [ ] **D221** — Refresh scoring report and record final value
- [ ] **D222** — Record N/A items and reasons
- [ ] **D223** — Save rollback notes and finish without unsafe reboot

---

### Completion notes

**N/A task IDs / reasons:** ______________________________________________________________

**Required services tested:** ___________________________________________________________

**Outstanding problems or score changes:** ______________________________________________

**Reviewer initials / date:** ___________________________________________________________
