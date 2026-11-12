# 🪟 Windows — Prioritized CyberPatriot Manuals

> [!TIP]
> **🧭 Quick orientation:** Use the links below to locate the right topic. Throughout the manuals, look for **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution**.


Choose one self-contained guide. Each starts with **Basics / Info**, then **First Things to Do**, followed by **Commonly Assessed Checks**, **Services/Software**, **Advanced Investigation**, and **Final Verification**.

- [Windows 10 / 11 — Complete Workstation Handbook](windows-10-11.md) — PowerShell basics, forensics, authorized users, password policies, Defender, firewall, updates, services, remote access, startup persistence, audit/event evidence and recovery.
- [Windows Server — Complete Role-Aware Handbook](../Server/windows-server.md) — Domain Controller versus member server, Active Directory, DNS/DHCP, IIS, SMB/NTFS, domain policy, server-only security, and full embedded workstation procedures.

**Forensics first (Ctrl+F question finder):** [Windows 10/11 — ciphers, decoding, files, ports and events](forensics.md) · [Windows Server — AD, DNS, DHCP, IIS and certificates](../Server/forensics.md). Includes CyberChef/Cryptii and offline procedures.

**Automated Windows 10/11 review:** [One-run PowerShell script](Scripts/windows-10-11.ps1) · [Beginner setup and run guide](Scripts/HOW-TO-RUN.md) · [Remaining manual tasks](Scripts/MANUAL-TASKS.md). The standalone Windows Server guide does not use this script.

**Windows Server automation (separate script):** [One-run Server PowerShell](../Server/Scripts/windows-server.ps1) · [Beginner setup and role selection](../Server/Scripts/HOW-TO-RUN.md) · [AD/DNS/DHCP/IIS manual checks](../Server/Scripts/MANUAL-TASKS.md). Use only on Server 2016/2019/2022 and verify the standalone/member/DC role first.

**Top priorities:** Read [the image README](../Misc/General/reading-the-readme.md), preserve [forensic evidence](../Misc/Forensics/README.md), keep admin access, and verify services before any changes. A score increase is never guaranteed by any particular generic setting.

[All categories](../README.md)

---

## Related resources in one place

[Windows-specific forensics](forensics.md) · [Windows Server / AD forensics](../Server/forensics.md) · [Windows 10/11 printable checklist](Checklists/windows-10-11-checklist.pdf) · [Windows Server printable checklist](../Server/Checklists/windows-server-checklist.pdf) · [All optional script instructions](../Misc/Scripts/README.md) · [Complete file index](../Misc/INDEX.md)
