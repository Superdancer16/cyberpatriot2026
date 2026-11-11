# 📚 CyberPatriot 2026–2027 Handbook — General / All

> [!TIP]
> **🧭 Quick start:** Follow the category links and open the most relevant guide. Look for **🔎 Check**, **🛠️ Fix**, **✅ Verify**, **↩️ Undo**, and **⚠️ Caution** throughout.

## 🧭 Quick links

[Basics / Information Needed](#topic-1) · [First Things to Do](#topic-2) · [Choose Your Platform Guide](#topic-3) · [Commonly Assessed Concepts — Where to Start](#topic-4) · [Advanced Investigations, Recovery and Sources](#topic-5)

---


**Read this before selecting an operating-system guide.** Each revised platform guide now follows the same order: **Basics / Information Needed → First Things to Do → Commonly Assessed High-Priority Checks → Services and Software → Advanced Topics → Final Verification.**

---

<a id="topic-1"></a>
## Basics / Information Needed

- [What is CyberPatriot?](what-is-cyberpatriot.md) — competition concepts and scoring
- [Reading the image README](reading-the-readme.md) — authorized users, admins, required services, prohibited items
- [Common security terms and acronyms](glossary.md)
- [Things that lose points](things-that-lose-points.md)

**Priority is not a published scoring rubric.** The actual image README and current competition instructions override public checklists.

---

<a id="topic-2"></a>
## First Things to Do

1. Open the image README and record required users, roles, server services, ports, passwords or accounts that **must not be changed**.
2. Open and answer [Forensics Questions](forensics-questions.md) before changing potential evidence.
3. Establish working administrative and VM recovery access, and record the initial scoring report.
4. Start the **platform-specific priority guide** below. Use its inspection commands before modifications.
5. After every change, verify both the security setting and required application/service behavior.
6. Finish with the guide's final checklist and a recorded score/report timestamp.

For team coordination use the [Round Game Plan](round-game-plan.md) and [Mentor/teacher resources](for-mentors-and-teachers.md).

---

<a id="topic-3"></a>
## Choose Your Platform Guide

| Guide | Content | CP-19 (2026–27) published scope |
|---|---|---|
| [Windows 10 / 11](../../Windows/windows-10-11.md) | Workstation users, Defender, firewall, policies, persistence | Windows 11 in scored Round 1 and Round 2; Windows 10 training |
| [Windows Server](../../Windows/windows-server.md) | AD, DNS, DHCP, IIS, file shares and role-aware security | Server 2022 in Round 2, State, Semifinals; Server 2019 in some later/training images |
| [Linux Mint](../../Linux/linux-mint.md) | Cinnamon/LightDM, APT/Flatpak, sudo, services | Mint 21 in Round 1, Round 2, State, Semifinals |
| [Ubuntu](../../Linux/ubuntu.md) | Ubuntu 22/24, GNOME, Snap, SSH sockets, Netplan | Ubuntu 24 State; Ubuntu 22 training |
| [Debian](../../Linux/debian.md) | Debian PAM, root/sudo, signed APT, nftables, critical services | Primarily legacy/practice reference; do not assume listed as a scored image in CP-19 |
| [FreeBSD](../../Linux/freebsd.md) | FreeBSD-native accounts, rc services, pf/ipfw | Legacy/advanced reference; verify the active round |
| [Cisco Packet Tracer](../../Cisco/packet-tracer.md) | Lab setup, VLANs, routing, DHCP, ACLs, SSH, troubleshooting | Module coverage varies by round |
| [Cisco Quiz](../../Cisco/cisco-quiz.md) | **385 original short-answer study questions** and vocabulary | Official NetAcad Content Course modules vary by round |

**Official round lineup and point totals:** [CyberPatriot CP-19 challenges by round](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round). The schedule is subject to change; the coach's instructions are authoritative.

---

<a id="topic-4"></a>
## Commonly Assessed Concepts — Where to Start

- **Windows:** authorized accounts/admin groups, passwords, Defender, firewall, updates, policies, startup/tasks, required software and services.
- **Windows Server:** determine Domain Controller role first; preserve AD/DNS/DHCP/IIS/share functionality before hardening.
- **Debian/Mint/Ubuntu:** root/sudo and PAM, apt sources/updates, required SSH, firewall, service units, cron/timers, file permissions and prohibited programs.
- **Cisco:** identify topology; verify link/IP/gateway → VLANs/trunks → routes → DHCP/DNS → ACLs/SSH → full end-to-end task tests.

These categories are **prioritization aids inferred from educational checklists**, not guaranteed scoring items.

---

<a id="topic-5"></a>
## Advanced Investigations, Recovery and Sources

- [Forensics investigation procedures](forensics-questions.md#repeatable-investigation-procedures)
- [Windows effective policy, events, persistence and recovery](../../Windows/windows-10-11.md#21-advanced-windows-investigations--included-in-this-checklist)
- [Windows Server role-aware investigation](../../Windows/windows-server.md#12-role-aware-manual-procedures-and-recovery)
- [Debian complete service hardening](../../Linux/debian.md#16-critical-services-complete-manual-procedures)
- [Linux Mint advanced investigation reference](../../Linux/linux-mint.md#21-advanced-linux-manual-investigations-embedded)
- [Cisco Packet Tracer detailed CLI references](../../Cisco/packet-tracer.md#21-expanded-original-configuration-reference)
- [Sources, attribution and maintenance](sources-and-attribution.md)

**Documentation only:** No scripts, test infrastructure or web applications are included. External scripts are separate and not required for the manuals: [historical tool reference](../../Misc%20Softwares/using-the-scripts.md).
