# 🐧 Linux and FreeBSD — Prioritized CyberPatriot Manuals

> [!TIP]
> **🧭 Quick orientation:** Use the links below to locate the right topic. Throughout the manuals, look for **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution**.


---

<a id="topic-1"></a>
## Begin with Basics, then First Things to Do

All three main Linux guides are now structured by learning stage and practical priority: **Basics / Info → README and Forensics → Common Security Checks → Services/Software → Advanced and Recovery → Final Verification**.

- [Debian — Comprehensive Standalone Handbook](Debian/debian.md) — root/sudo, PAM, apt/deb822 sources, nftables/UFW, required services and full advanced references.
- [Linux Mint — Comprehensive Standalone Handbook](Mint/linux-mint.md) — Cinnamon/LightDM, Update Manager, Flatpak, sudo/PAM, desktop/service security and advanced references.
- [Ubuntu — Comprehensive Standalone Handbook](Ubuntu/ubuntu.md) — **expanded** Ubuntu 22/24 guide covering APT vs Snap, GNOME, UFW, SSH socket activation, Netplan/NetworkManager, systemd, AppArmor and critical services.
- [FreeBSD](../Misc/FreeBSD/freebsd.md) — a separate BSD operating system, **not a Linux distribution**; use FreeBSD-specific commands.

**New searchable Linux forensics guide:** [Debian / Mint / Ubuntu — Ctrl+F index, Base64 → ROT13, HEX/ELF, UID owners, logs, PCAP](forensics.md), with CyberChef and offline commands.

**Do first:** [Read the image README](../Misc/General/reading-the-readme.md) and preserve [forensics answers](forensics.md). Check the exact OS release and required users/daemons before modifying accounts, packages, firewall, login or authentication.

**Debian 12/13 automation:** [debian.sh](Debian/Scripts/debian.sh) · [Beginner run instructions](Debian/Scripts/HOW-TO-RUN.md) · [Manual tasks after the script](Debian/Scripts/MANUAL-TASKS.md). Mint, Ubuntu and FreeBSD use their separate manual handbooks. The VM README takes priority.

[All categories](../README.md)

---

## Related resources in one place

[Linux forensic question finder](../Misc/Forensics/README.md) · [Debian printable checklist](Debian/Checklists/debian-checklist.pdf) · [Optional Debian script and manual tasks](../Misc/Scripts/README.md) · [Complete file index](../Misc/INDEX.md)
