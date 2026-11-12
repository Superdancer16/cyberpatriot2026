# 🧭 Round game plan

> [!TIP]
> **🧭 Reading guide:** Use the quick links to jump between sections. **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution** are used consistently across the repository.

> [!IMPORTANT]
> **Follow the actual image README and competition instructions.** Preserve forensic evidence and record rollback details before making system changes.

## 🧭 Quick links

[Before the round (the day before)](#topic-1) · [The 4 hours](#topic-2) · [How to use the Scoring Report](#topic-3) · [Team rules](#topic-4) · [Using the scripts in a practice round](#topic-5) · [Use checkpoints instead of bulk changes](#topic-6)

---


A good plan matters more than speed. Teams lose the most points by rushing and breaking something the README needed.

---

<a id="topic-1"></a>
## Before the round (the day before)

- [ ] Everyone knows which image they own (e.g. Alex → Windows, Sam → Linux, Jordan → Cisco).
- [ ] VMware Workstation works on every computer, and virtualization is enabled in the BIOS.
- [ ] Everyone has read [Things that lose points](things-that-lose-points.md).
- [ ] Printed or downloaded copies of the checklists for your OS.

---

<a id="topic-2"></a>
## The 4 hours

| Time | What to do |
|---|---|
| **0:00–0:15** | Open your image. **Read the README twice** and write down admins, users, critical services and prohibited items ([how](reading-the-readme.md)). **Take a VMware snapshot** (VM menu → Snapshot → Take Snapshot). |
| **0:15–0:45** | **Forensics questions.** Answer as many as you can *before* changing anything ([how](../../Forensics/README.md)). Skip any that take more than 10 minutes and come back later. |
| **0:45–1:00** | **Start updates** (they're slow, so let them run in the background). Use native read-only inventories, then make reviewed manual changes. Check the Scoring Report. |
| **1:00–2:30** | Work through the checklist from the top: users → passwords → firewall → services → software → files → OS settings → critical services. Verify every checklist item manually. **Check the Scoring Report after every few fixes.** |
| **2:30–3:30** | Backdoor hunting, the harder checklist items, the leftover forensics questions, and application updates (Firefox etc.). |
| **3:30–3:50** | Final checks: critical services still working? Any **penalties** on the Scoring Report? Fix them. |
| **3:50–4:00** | Stop making risky changes. Make sure your score is saved (the scoring report shows the latest time). |

---

<a id="topic-3"></a>
## How to use the Scoring Report

- Open it from the desktop. It refreshes every minute or two.
- It shows **how many** problems you've fixed and their point values, not which ones are left.
- If your score **goes down**, you just caused a penalty. Undo your last change.
- If a fix you made doesn't add points, it might not be scored on this image. That's normal, so move on.

---

<a id="topic-4"></a>
## Team rules

- **One person per image.** Two people changing the same computer causes chaos.
- **Say it out loud** before you do something risky ("I'm going to delete user mallory").
- **Write down what you change**, so you can undo it if the score drops.
- **Don't get stuck.** If something takes more than 10 minutes, skip it and come back.
- **Ask a teammate** before uninstalling anything the README might need.

---

<a id="topic-5"></a>
## Using the scripts in a practice round

Optional Windows, Windows Server and Debian scripts are included in the [script hub](../../Scripts/README.md), but they may only be used when competition rules and the image README permit them. Run the documented audit first and verify every outcome against the manual handbook.

1. Inspect native OS settings first and preserve relevant evidence.
2. Apply manual changes only after relevant forensic questions and README requirements have been reviewed.
3. Open the manual checklist and verify every effective setting and required client function. Do not skip an item based on an external tool's status.

See [Script safety, verification and rollback](../../Scripts/README.md#review-external-or-historical-tools-before-running).

---

<a id="topic-6"></a>
## Use checkpoints instead of bulk changes

- [ ] Done

**🎯 What:** Make one coherent change, verify it, and keep a small recovery record.

**💡 Why it matters:** A score change after ten unrelated edits is hard to diagnose. Some legitimate security improvements are unscored; continually changing a correct setting wastes time.

**🛑 Before changing anything:** Treat the four-hour schedule above as a practice template. Follow the actual round's time, team-size, resource and snapshot rules. Assign one operator per image; a second person may read/check instructions if permitted.

**🖱️ Clicking (GUI):** Keep the README and Scoring Report open. Before an account/service/firewall change open the relevant management screen and record the old value. Refresh the report after function checks, allowing its normal update delay.

**🔎 Typing (check):** Use the read-only command from the procedure you are about to perform. Record the time, exact target, old value and expected result in private notes. Do not put passwords or shadow contents in the log.

**🛠️ Typing (fix, only when appropriate):** Change one related set of settings from the manual checklist. Run updates with time for review/restarts, not blindly while forensic evidence is still needed. Do not run a hardening script merely to keep to the schedule.

**✅ Check it worked:** Native setting query passes, required client transaction passes, report is fresh and no new penalty appears. Mark done only after those checks. Revisit skipped forensic questions before destructive cleanup.

**↩️ Undo:** Reverse the last specific change using its backup. If the score/function does not recover, verify report freshness and the exact error before changing something else. A full snapshot rollback can lose later fixes and may be restricted by the rules.

**⚠️ Warnings:** Stop speculative changes near the end, save answers and permitted files, and leave required services functioning. A stale score report can reflect network/time issues; do not edit the scoring agent to repair it.
