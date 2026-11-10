# For mentors and teachers

How to run practice sessions with this toolkit in a class or club, even if your students have never touched Linux or a command line.

## What your students get

- **Lessons** (the "Start here" pages): seven short reads, about an hour in total, that explain how an image, the README and scoring work.
- **Checklists**, one per operating system. Every step says what to do, why it matters, how to do it by clicking and by typing, and how to check it worked. Students can print or copy the Markdown checkboxes into private practice notes; this repository does not provide progress tracking.
- **Manual references** for README interpretation, round timing, logs, file hashes, decoding, terminology and networking. Use the linked Markdown guides; there is no bundled tools website.
- **Manual procedures** with inspection, verification and rollback. External automation needs independent review and is not included here.

## Before the first session

1. **Install VMware Workstation** (or the VM software your images were made for) on every student computer. Make sure virtualization is enabled in the BIOS.
2. **Copy the practice images** onto each computer, or onto a share students can copy from. Old competition images work well.
3. **Take a snapshot called `clean`** of each image before students touch it. To reuse an image, revert to `clean`.
4. **Open the documentation index** on student computers and check that relative links work. Keep private progress/change notes separately.

> [!TIP]
> If school computers erase local data at logout, save permitted practice notes in an approved location. Do not include passwords, shadow files or private forensic samples.

## A suggested six-session plan

| Session | Goal | Use |
|---|---|---|
| 1 | Understand the game | Lessons 1–2 ([What is CyberPatriot?](what-is-cyberpatriot.md), [Things that lose points](things-that-lose-points.md)), then a verbal glossary exercise |
| 2 | Read a README, use a terminal | Lessons 3 and 5 ([Reading the README](reading-the-readme.md), [Linux terminal basics](../../Linux/linux-mint.md#22-complete-linux-terminal-basics-embedded)), a written requirement/verification sheet |
| 3 | First Linux image: users, passwords, firewall | [Linux Mint checklist](../../Linux/linux-mint.md) sections 0–4 |
| 4 | Linux, continued: services, software, files, backdoors, forensics | Mint checklist sections 5–17, [Forensics questions](forensics-questions.md) |
| 5 | Windows | Lesson 6 ([PowerShell basics](../../Windows/windows-10-11.md#20-complete-powershell-basics--included-in-this-windows-checklist)), [Windows 10 / 11 checklist](../../Windows/windows-10-11.md) |
| 6 | A full practice round | [Round game plan](round-game-plan.md), a permitted clock, manual inventories and checkpoint notes |

After that, rotate students through Windows Server and Debian, using their checklists. For the Cisco part of a round, use the [Cisco & Packet Tracer guide](../../Cisco/cisco-networking.md) and the worked subnetting examples in that guide.

## Running a session

- **One student per image.** Pairs work well if one person drives and the other reads the checklist aloud.
- **Projector:** display the round game plan and a permitted timer; never project real credentials.
- **Paper copies:** print the Markdown checklist using your viewer/browser; keep its source URL and revision.
- **Fresh start:** revert only an authorized practice VM, then start fresh progress notes and verify the baseline score.
- **Handing in work:** request a private change log with before/after evidence and recovery notes, without secrets or active-round answers.

## Making your own practice problems

If you're comfortable with Linux, you can plant problems in a throwaway VM yourself: add an unauthorized user, give someone sudo rights, install a "hacking tool", put an MP3 in a home folder, add a cron job. Take a snapshot first. Keep an instructor-only answer key with the exact original state and rollback for each exercise. This repository does not include vulnerability-planting scripts or tests; do not run such tools on school or production computers.

## Keeping the material up to date

Edit the existing Markdown under `docs/`, preserve relative links and review a pull request. This repository has no website build or deployment. Review version-sensitive commands against official references and identify any untested examples.

## Assess a complete procedure, not command memorization

- [ ] Done

**What:** Teach students to explain a requirement, inspect a state, make a justified change, verify the real function and recover.

**Why it matters:** A student who memorizes a disable command may break a required server. The same service can be prohibited on one image and critical on another.

**Before changing anything:** Use an isolated, authorized practice VM with no real personal data. Follow the actual competition rules for outside help; classroom coaching permissions do not automatically extend to a live round. Confirm instructor recovery access and backups before planting a reversible configuration error.

**Clicking (GUI):** Demonstrate one service's Properties screen, its dependency list and the application's client test. Ask students to record the original startup type and status before changing either. Let a student locate the matching native terminal inspection.

**Typing (check):** Have students use the relevant checklist's read-only query and explain every result column. Do not supply a bulk hardening command as the learning exercise. An empty result, hidden error and absent package mean different things.

**Typing (fix, only when appropriate):** Give one written scenario requirement and one reversible misconfiguration. The student chooses the corresponding exact procedure, backs up the setting and applies only that change. Rotate roles: operator, requirement reader, verifier and recorder, with one active operator per VM.

**Check it worked:** Require four pieces of evidence: the README rationale, before/after native output, an ordinary-user client test, and a demonstrated rollback. Forensics exercises require evidence preservation before any remediation. For Cisco require both the running configuration and saved startup configuration plus connectivity/ACL tests.

**Undo:** Have the student restore the recorded setting and prove the required function still works. Restore the clean practice baseline between students only after collecting permitted private notes. Reversion can discard all later changes.

**Warnings:** Avoid malware samples, real passwords, public scanning, or fake active-round answers in teaching materials. Keep instructor answer keys separate. Review procedures when OS/package versions change and record which platform/version was actually exercised; this handbook's examples are not a claim of execution on every image.
