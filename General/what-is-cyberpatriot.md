# 🌟 What is CyberPatriot?

> [!TIP]
> **🧭 Quick orientation:** Use the links below to locate the right topic. Throughout the manuals, look for **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution**.

> [!IMPORTANT]
> **Competition requirements come first.** Always use the actual image README and official rules; generic checklists cannot promise individual points.

## 🧭 Quick links

[How a practice image works](#topic-1) · [What gets scored (the usual categories)](#topic-2) · [This season's images (CyberPatriot 19, 2026-27)](#topic-3) · [How a round works](#topic-4) · [Where to go next](#topic-5) · [Your first safe practice session](#topic-6)

---


CyberPatriot is a cyber **defense** competition for middle and high school students. You are not hacking anything. You are the IT person who has been handed a computer that was set up badly and maybe broken into, and your job is to **find and fix the security problems**.

---

<a id="topic-1"></a>
## How a practice image works

1. You get a **virtual machine** (VM): a whole computer running inside a program like VMware. It is called an **image**.
2. On the desktop there is a **README**. It describes the "company", who is allowed to use the computer, and what it must keep doing (for example, "this is the company web server").
3. On the desktop there are **Forensics Questions**: small puzzles about the computer, each worth points.
4. Somewhere on the image a **scoring engine** is running. Every time you fix a problem it checks, your score goes up and the **Scoring Report** on the desktop shows it.
5. If you make the computer *less* secure, or break something the README needs, you get a **penalty** (points taken away).

You don't know in advance which problems are scored. The checklists in this toolkit cover the problems that show up again and again.

---

<a id="topic-2"></a>
## What gets scored (the usual categories)

After each round CyberPatriot publishes the general categories of problems. They are almost always these:

| Category | Examples |
|---|---|
| Forensics questions | "What is the SHA-256 hash of the file in Bob's Documents?" |
| User auditing | Delete users who aren't in the README. Remove admin rights from people who shouldn't have them. |
| Account policies | Password length and complexity. Lock accounts after failed logins. |
| Local policies | Audit logging. Security options like "don't show the last user name". |
| Defensive countermeasures | Firewall on. Antivirus on. |
| Uncategorized OS settings | Screen lock. Secure boot settings. Remote Desktop off. |
| Service auditing | Turn off services the README doesn't need (FTP, Telnet...). |
| Operating system updates | Install updates and turn on automatic updates. |
| Application updates | Update Firefox, Chrome, and the programs the README mentions. |
| Prohibited files | Delete music, videos, password lists and hacking tools. |
| Unwanted software | Uninstall games, hacking tools, torrent programs. |
| Malware | Find backdoors, bad scheduled tasks, fake programs. |
| Application security | Harden the critical services: web server, database, FTP, SSH settings. |

---

<a id="topic-3"></a>
## This season's images (CyberPatriot 19, 2026-27)

| Round | Images |
|---|---|
| Round 1 | Windows 11, Linux Mint 21 |
| Round 2 | Windows 11, Windows Server 2022, Debian 12 |
| State | Windows Server 2022, Linux Mint 21, Debian 12 |
| Semifinals | Linux Mint 21, Windows Server 2022, Debian 12 or FreeBSD |

Older practice images may also be Windows 10, Windows Server 2019, or Ubuntu. There is a checklist for each.

---

<a id="topic-4"></a>
## How a round works

- Each team gets **one 4-hour block**. The clock starts when the first image is powered on.
- Up to 5 people work at once. Usually each person takes one image or one task.
- There is also a **Cisco networking** part (a quiz and a Packet Tracer activity). Study it with the [Cisco & Packet Tracer guide](../Cisco/packet-tracer.md) and the worked subnetting examples in that guide.

---

<a id="topic-5"></a>
## Where to go next

Open lesson 2, [Things that lose points](things-that-lose-points.md), then keep going through the lessons in order.

Already know the basics and want to start on an image? Open your checklist: [Windows 10 / 11](../Windows/windows-10-11.md) · [Windows Server](../Server/windows-server.md) · [Linux Mint](../Linux/Mint/linux-mint.md) · [Debian](../Linux/Debian/debian.md) · [FreeBSD](../Misc/FreeBSD/freebsd.md) · [Ubuntu](../Linux/Ubuntu/ubuntu.md). If a word confuses you, look it up in the [Glossary](glossary.md).

---

<a id="topic-6"></a>
## Your first safe practice session

- [ ] Done

**🎯 What:** Learn to inspect and verify one setting in an authorized practice VM.

**💡 Why it matters:** The goal is a secure computer that still performs its assigned job. The score is feedback, not a complete security audit.

**🛑 Before changing anything:** Confirm the VM is a permitted practice image, read current rules and the desktop README, and keep the host computer separate from the guest. The season/round table above is inherited reference material; confirm the current official announcement and round packet rather than treating it as a guaranteed lineup or schedule.

**🖱️ Clicking (GUI):** Open the guest VM, then its README, forensic questions and scoring report. Identify which OS checklist applies. Keep host settings and the VM's virtual network unchanged unless the exercise explicitly instructs otherwise.

**🔎 Typing (check):** In a guest Linux terminal use `id`; in guest Windows PowerShell use `whoami /user`. Compare that identity with the README's administrator list. No account change is needed just to identify yourself.

**🛠️ Typing (fix, only when appropriate):** Choose one reversible setting from the appropriate checklist and follow its exact GUI/terminal procedure after recording the original state. Do not begin with user deletion, PAM edits, role removal or disk encryption.

**✅ Check it worked:** Repeat the native inspection, test the required function and observe a current scoring report. Explain to a teammate what changed and how you would undo it before moving on.

**↩️ Undo:** Follow that setting's rollback instructions. If you cannot identify the original value or a recovery path, stop before applying it and practice inspection instead.

**⚠️ Warnings:** Never scan outside authorized lab systems, share active competition answers, modify the scoring agent or assume a practice-tool permission applies to a live round. Resources and assistance rules depend on the actual round.
