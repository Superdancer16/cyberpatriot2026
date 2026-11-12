# 📖 Glossary

> [!TIP]
> **🧭 Reading guide:** Use the quick links to jump between sections. **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution** are used consistently across the repository.

> [!IMPORTANT]
> **Follow the actual image README and competition instructions.** Preserve forensic evidence and record rollback details before making system changes.


Short explanations of words you'll see in the checklists and scripts.

| Word | Meaning |
|---|---|
| **Active Directory (AD)** | Microsoft's system for managing all the users and computers of a company from one server (the Domain Controller). |
| **Admin / Administrator** | A user who can change anything on the computer. On Linux: identities granted elevation through the actual sudo or other privilege policy. On Windows: the `Administrators` group. |
| **AppArmor** | A Linux feature that limits what each program may do, so a hacked program can't touch everything. |
| **Audit policy** | Rules for what Windows writes to the Security log (logins, account changes…). |
| **Authorized user** | A user the README says should have an account. |
| **Backdoor** | A hidden way for an attacker to get back in: an extra account, a scheduled task, a program listening on a port… |
| **Base64** | A way of writing any data using letters, numbers, `+` and `/`. Not encryption, because anyone can decode it. |
| **Cron / crontab** | Linux's scheduler: runs commands at set times. Attackers use it to restart backdoors. |
| **Critical service** | A service the README says must keep running (e.g. web server, SSH). Never disable these. |
| **Daemon** | Linux word for a background service (`sshd`, `auditd`…). |
| **Defender** | Microsoft Defender Antivirus, built into Windows. |
| **Domain Controller (DC)** | The Windows Server that runs Active Directory. |
| **Firewall** | Blocks network connections that aren't allowed. Linux: UFW / nftables. FreeBSD: pf / ipfw. Windows: Windows Defender Firewall. |
| **Forensics question** | A question file on the desktop asking you to investigate something on the image. |
| **GPO (Group Policy Object)** | A bundle of Windows settings pushed from a Domain Controller to computers. |
| **Hash** | A fingerprint of a file (e.g. SHA-256). Change one byte and the hash completely changes. |
| **IIS** | Microsoft's web (and FTP) server. |
| **Image** | The virtual machine you're securing. |
| **LLMNR / NetBIOS** | Old ways Windows finds other computers by name. Attackers abuse them to steal password hashes. |
| **Lockout policy** | Locks an account after too many wrong passwords. |
| **Malware** | Malicious software: viruses, backdoors, keyloggers, miners… |
| **NTLM / LM** | Old Windows password-checking protocols. LM and NTLMv1 are easy to crack; NTLMv2 is required. |
| **PAM** | "Pluggable Authentication Modules": the Linux system that checks passwords for every login. Files in `/etc/pam.d/`. |
| **Penalty** | Points lost for making the computer less secure or breaking something the README needs. |
| **Port** | A numbered "door" for network connections (22 = SSH, 80 = web, 3389 = Remote Desktop). |
| **Privilege escalation** | A normal user becoming admin/root through a mistake in the system. |
| **Prohibited software / files** | Programs and files the company policy (README) bans: hacking tools, games, music… |
| **RDP** | Remote Desktop Protocol: log in to a Windows computer's screen over the network. |
| **README** | The file on the desktop describing the company, the users, and what the computer must do. |
| **Registry** | Windows' big settings database (`regedit`). |
| **Root** | The all-powerful admin account on Linux / FreeBSD (UID 0). |
| **Samba / SMB** | File sharing between computers. SMBv1 is old and dangerous. |
| **Scoring Report** | The page on the desktop showing your points and penalties. |
| **Scoring engine** | The program on the image that checks your fixes and awards points. Never touch it. |
| **secpol.msc** | Windows Local Security Policy: passwords, audit, user rights, security options. |
| **Service** | A program that runs in the background (web server, SSH, Print Spooler…). |
| **Share** | A folder other computers can open over the network. |
| **Snapshot** | A saved copy of the VM's state you can go back to. |
| **SSH** | Secure Shell: log in to a Linux computer's terminal over the network. |
| **sudo** | "Do as admin" on Linux. `sudo` group members can use it. |
| **SUID** | A Linux file permission that makes a program run as its owner (usually root). Dangerous on the wrong program. |
| **sysctl** | Linux/FreeBSD kernel settings (network and memory protections). |
| **UAC** | User Account Control: the Windows "Do you want to allow this app to make changes?" prompt. |
| **UFW** | Uncomplicated Firewall: the easy firewall tool on Ubuntu, Mint and Debian. |
| **UID** | User ID number. 0 = root. 1000+ = normal people on Linux. |
| **Unauthorized user** | A human account not authorized by the scenario, after excluding required service/built-in identities. Preserve evidence and prefer reversible containment before deletion. |
| **Updates** | Fixes for security holes. Install them, and turn on automatic updates. |
| **VM (virtual machine)** | A whole computer running inside a program like VMware. |
| **Web shell** | A malicious web page that lets an attacker run commands on the server. |
| **World-writable** | A file anyone on the system can change. Almost always a mistake. |

---

<a id="topic-1"></a>
## Terms used in verification and recovery

| Word | Meaning and practical implication |
|---|---|
| **ACL (access control list)** | Ordered permissions/rules. File ACLs and router packet ACLs are different systems; inspect the relevant effective permissions or rule binding. |
| **Authentication / authorization** | Authentication proves an identity; authorization decides what it may do. Successful login does not prove the user should be an administrator. |
| **Effective policy** | The configuration that actually applies after defaults, includes, GPOs and scope rules. Verify it instead of trusting one edited file. |
| **GPO / OU** | Group Policy Object / organizational unit in AD. Links, inheritance and filtering determine which computers/users receive settings. |
| **Fine-grained password policy** | AD password/lockout policy for selected users/groups that may differ from the domain default. Check a user's resultant policy. |
| **PAM** | Pluggable Authentication Modules. Module order and control flags determine login/password behavior; a valid-looking line in the wrong position can fail dangerously. |
| **Socket activation** | A service manager listens and starts a daemon on demand. Stopping the daemon alone may not close the listening socket permanently. |
| **Reload / restart / daemon-reload** | Reload asks an application to reread supported config; restart stops/starts it; systemd daemon-reload rereads unit definitions and does not itself restart applications. |
| **nftables / pf** | nftables is a Linux packet-filter framework; pf is used on FreeBSD and other BSD systems. Neither is interchangeable with UFW commands. |
| **SUID / SGID / capability** | Mechanisms granting special execution privileges. Some are required; investigate ownership/package baselines before removing them. |
| **Sticky bit** | On directories such as `/tmp`, limits who may remove another user's files. Mode 1777 can be intentional for a shared temporary directory. |
| **First match / implicit deny** | Many ACL/authentication systems use the first matching rule. Router ACLs deny unmatched traffic; ordering and application point matter. |
| **VLAN / trunk / SVI** | VLAN separates Layer 2 broadcast domains; trunk carries multiple VLANs; SVI gives a switch a VLAN interface for management/routing where supported. |
| **STP / BPDU Guard** | Spanning Tree prevents switching loops; BPDU Guard protects true edge ports by reacting to unexpected switch control frames. |
| **OSPF** | A link-state routing protocol. Neighbor relationships and learned routes must be checked on both ends; return paths still matter. |
| **Hash / encoding / encryption** | Hash summarizes bytes, encoding changes representation, encryption requires a key to recover plaintext. Base64 is not encryption; a hash is not automatically a trust guarantee. |
| **Rollback / backup** | Rollback returns a change to a prior state; backups contain particular data/settings. A config backup does not recover deleted users, old passwords or a database migration. |
| **Read-only investigation** | Intended not to change the target directly, but live access can still create events/history or update access times. Record limitations. |
| **Least privilege** | Give identities only the access needed for required work. It requires understanding the role, not removing every unfamiliar permission. |

For an unfamiliar command, read its installed help before executing it: Linux/FreeBSD `man COMMAND`, PowerShell `Get-Help COMMAND -Full`, Cisco context-sensitive `?`. Example values are placeholders, never competition requirements.
