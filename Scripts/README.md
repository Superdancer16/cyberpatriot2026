# 🧰 Optional Automation — Existing Script Directory

> [!WARNING]
> These scripts may change users, policies, services, software, network access, or files when configured to apply changes. **Read the competition rules and VM README, complete necessary forensics, inspect the code, and run Audit mode before any Apply mode.** Do not assume a script is permitted or safe for every image.

The script source files **remain in their original directories**. This folder provides one shared navigation page only; no scripts have been moved, removed, renamed, or combined.

## Select the matching operating system

| Target | Source script | Beginner HOW-TO | After-script manual checks | Complete handbook |
|---|---|---|---|---|
| Windows 10/11 workstation | [windows-10-11.ps1](../Windows%20Scripts/windows-10-11.ps1) | [Run instructions](../Windows%20Scripts/HOW-TO-RUN.md) | [Manual tasks](../Windows%20Scripts/MANUAL-TASKS.md) | [Windows manual](../Windows/windows-10-11.md) |
| Windows Server 2016/2019/2022 | [windows-server.ps1](../Windows%20Server%20Scripts/windows-server.ps1) | [Role-aware run instructions](../Windows%20Server%20Scripts/HOW-TO-RUN.md) | [AD/roles manual tasks](../Windows%20Server%20Scripts/MANUAL-TASKS.md) | [Server manual](../Windows/windows-server.md) |
| Debian 12/13 | [debian.sh](../Linux%20Scripts/debian.sh) | [Bash run instructions](../Linux%20Scripts/HOW-TO-RUN.md) | [Manual tasks](../Linux%20Scripts/MANUAL-TASKS.md) | [Debian manual](../Linux/debian.md) |

**Mint, Ubuntu, and FreeBSD:** Use their [manual guides](../Linux/README.md); do not assume the Debian script supports these operating systems.

## Safe order of work

1. Read the image README for required accounts, services, ports, software, and restrictions.
2. Preserve and answer relevant [forensics questions](../Forensics/README.md) before modifying evidence.
3. Review the script and its matching HOW-TO; verify the operating system and role.
4. Run the documented **Audit** mode if permitted; inspect the findings.
5. Configure only explicitly authorized changes. Do not copy assumptions from a different image.
6. Check every action and verify required functions after any permitted Apply operation.
7. Use the linked MANUAL-TASKS file and original comprehensive guide for anything not safely automated.

The older [Using the scripts safely](../Misc%20Softwares/using-the-scripts.md) page also describes **external upstream script names** that are *not* the local script filenames. Use the table above for actual files in this repository.

[Complete file index](../INDEX.md) · [Repository home](../README.md)
