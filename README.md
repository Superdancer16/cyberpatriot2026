# 🛡️ CyberPatriot 2026–2027 — Complete Security Handbook

**One README. Four platform areas. One shared General library.** Choose the image you are working on below, then use **Ctrl+F** within its guide. Every platform guide emphasizes **🔎 Check → 🛠️ Fix → ✅ Verify → ↩️ Undo** and clearly flags risky changes.

> [!IMPORTANT]
> **The active competition image README and current round rules take priority.** Identify authorized accounts and required services, preserve forensic evidence, retain administrative access, and verify the scoring report after changes. Sample settings are not guaranteed scoring items. Only use automation or external sites when permitted.

## 🚀 Start here — choose your platform

| Image / activity | Complete handbook | Searchable forensics | Optional scripts / tracking |
|---|---|---|---|
| 🪟 **Windows 10 / 11** | [Windows workstation](Windows/windows-10-11.md) | [Windows forensics](Windows/forensics.md) | [Script HOW-TO](Windows/Scripts/HOW-TO-RUN.md) · [Manual tasks](Windows/Scripts/MANUAL-TASKS.md) · [Checklist PDF](Windows/Checklists/windows-10-11-checklist.pdf) |
| 🖥️ **Windows Server / AD** | [Standalone Server guide](Server/windows-server.md) | [Server forensics](Server/forensics.md) | [Server script HOW-TO](Server/Scripts/HOW-TO-RUN.md) · [Manual tasks](Server/Scripts/MANUAL-TASKS.md) · [Checklist PDF](Server/Checklists/windows-server-checklist.pdf) |
| 🌐 **Cisco Packet Tracer / quiz** | [Packet Tracer](Cisco/packet-tracer.md) · [Networking quiz](Cisco/cisco-quiz.md) | Use activity tasks / topology first | [Cisco checklist PDF](Cisco/Checklists/cisco-packet-tracer-checklist.pdf) |
| 🐧 **Debian 12/13** | [Debian handbook](Linux/Debian/debian.md) | [Linux forensics](Linux/forensics.md) | [Debian script HOW-TO](Linux/Debian/Scripts/HOW-TO-RUN.md) · [Manual tasks](Linux/Debian/Scripts/MANUAL-TASKS.md) · [Checklist PDF](Linux/Debian/Checklists/debian-checklist.pdf) |
| 🌿 **Linux Mint** | [Linux Mint handbook](Linux/Mint/linux-mint.md) | [Linux forensics](Linux/forensics.md) | Manual guide (Debian automation is not Mint automation) |
| 🟠 **Ubuntu** | [Ubuntu handbook](Linux/Ubuntu/ubuntu.md) | [Linux forensics](Linux/forensics.md) | Manual guide (Debian automation is not Ubuntu automation) |
| 🐡 **FreeBSD** | [FreeBSD handbook](Misc/FreeBSD/freebsd.md) | [BSD-specific forensic quick reference](General/forensics-workflows.md#freebsd-quick-reference) | FreeBSD commands differ from Linux |

## 🗂️ Repository layout

```text
README.md                              ← The only README / master directory
Windows/
  windows-10-11.md
  forensics.md
  Scripts/      HOW-TO-RUN.md · MANUAL-TASKS.md · windows-10-11.ps1
  Checklists/   windows-10-11-checklist.md · windows-10-11-checklist.pdf
Server/
  windows-server.md
  forensics.md
  Scripts/      HOW-TO-RUN.md · MANUAL-TASKS.md · windows-server.ps1
  Checklists/   windows-server-checklist.md · windows-server-checklist.pdf
Cisco/
  packet-tracer.md · cisco-quiz.md
  Checklists/   cisco-packet-tracer-checklist.md · cisco-packet-tracer-checklist.pdf
Linux/
  forensics.md
  Debian/
    debian.md
    Scripts/    HOW-TO-RUN.md · MANUAL-TASKS.md · debian.sh
    Checklists/ debian-checklist.md · debian-checklist.pdf
  Mint/         linux-mint.md
  Ubuntu/       ubuntu.md
General/                             ← Cross-platform study, safety and reference
  what-is-cyberpatriot.md · reading-the-readme.md
  round-game-plan.md · glossary.md · things-that-lose-points.md
  forensics-workflows.md · script-safety.md · checklist-printing.md
Misc/
  FreeBSD/      freebsd.md
.github/workflows/                    ← Automated script checks
```

## 📚 General — shared instructions

- **Getting started:** [What is CyberPatriot?](General/what-is-cyberpatriot.md) · [How to read the image README](General/reading-the-readme.md) · [Round game plan](General/round-game-plan.md)
- **Common reference:** [Security glossary](General/glossary.md) · [Things that lose points](General/things-that-lose-points.md)
- **Evidence and questions:** [Cross-platform forensics workflows](General/forensics-workflows.md) — safe preservation, hashes, logs, process correlation and FreeBSD-specific commands
- **Automation:** [Script safety, historical references and rollback](General/script-safety.md) — current scripts, review precautions, and warnings about unrelated upstream scripts
- **Printing:** [Printable checklist instructions](General/checklist-printing.md) — how to track progress on paper and in Markdown

## 📝 Editable checklist trackers

The checklist PDFs above are for printing; use the matching Markdown when you want to record checkboxes in a branch.

[Windows 10/11](Windows/Checklists/windows-10-11-checklist.md) · [Windows Server](Server/Checklists/windows-server-checklist.md) · [Debian](Linux/Debian/Checklists/debian-checklist.md) · [Cisco](Cisco/Checklists/cisco-packet-tracer-checklist.md)

## ⚙️ Optional script source and validation

The three script entrypoints are [Windows 10/11 PowerShell](Windows/Scripts/windows-10-11.ps1), [Windows Server PowerShell](Server/Scripts/windows-server.ps1), and [Debian Bash](Linux/Debian/Scripts/debian.sh). **Do not run a platform's script on a different operating system.** Read the matching HOW-TO, run Audit mode first, and apply only image-specific, authorized changes.

GitHub Actions: [Debian syntax workflow](.github/workflows/debian-script-syntax.yml) · [Windows Server syntax workflow](.github/workflows/windows-server-script.yml).

## 📜 Reference and reuse notice

Some original documentation was reproduced with permission from [Ripper1004/CyberPatriot-Toolkit](https://github.com/Ripper1004/CyberPatriot-Toolkit/tree/main/docs). That permission should not be presumed to cover unrelated scripts or assets. Earlier source research and removed files remain in this repository's Git history. Official competition rules and vendor documentation, not community checklists, govern current requirements.
