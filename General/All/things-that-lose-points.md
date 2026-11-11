# ⚠️ Things that lose points

> [!TIP]
> **🧭 Reading guide:** Use the quick links to jump between sections. **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution** are used consistently across the repository.

> [!WARNING]
> **Avoid broad changes.** Keep required services and administrator access; the image README overrides generic recommendations.

## 🧭 Quick links

[The README mistakes](#topic-1) · [Locking yourself out](#topic-2) · [Breaking the computer](#topic-3) · [Losing points you already earned](#topic-4) · [If your score goes down](#topic-5) · [A concrete penalty-recovery procedure](#topic-6)

---


The scoring engine gives **penalties** (negative points) when you make things worse. These are the mistakes teams make most. Each one is easy to avoid if you know about it.

---

<a id="topic-1"></a>
## The README mistakes

| Mistake | Instead |
|---|---|
| Deleting an **authorized user** (typo, or you skimmed the list) | Copy names from the README exactly. Check twice before deleting. |
| Removing admin rights from an **authorized admin** | Admins in the README stay admins, even if it looks like a lot of admins. |
| Stopping or uninstalling a **critical service** | Write the critical services down first. Harden them, never remove them. |
| Uninstalling **required software** | "Users need X" in the README means keep it (and update it). |
| Blocking a critical service with the **firewall** | Allow its port *before* turning the firewall on. |
| Ignoring special instructions ("don't change user X's password") | Read the README twice. Highlight anything unusual. |

---

<a id="topic-2"></a>
## Locking yourself out

| Mistake | What happens | Instead |
|---|---|---|
| Removing **yourself** from sudo / Administrators | You can't fix anything else | Never touch your own account's admin rights |
| Changing **your own password** and forgetting it | Screen lock and sudo lock you out | Leave your password alone unless told to |
| Locking the **root** account on Debian when sudo isn't set up | No way to become admin | Check `sudo -v` works first |
| A mistake in **PAM** files (`common-auth`) | Nobody can log in | Keep a root terminal open, back up the file, test with `su - user` |
| A mistake in **sudoers** | `sudo` stops working for everyone | Always edit with `visudo` |
| `PasswordAuthentication no` in SSH | Nobody can log in over SSH (no one has keys) | Leave it `yes` unless the README says otherwise |
| Disabling the built-in Administrator **while logged in as it** | You lose admin | Check `whoami` first |
| Turning on **BitLocker** | You may never get back into the VM | Don't |
| Disabling the network adapter | Scoring stops updating | Don't |

---

<a id="topic-3"></a>
## Breaking the computer

| Mistake | Instead |
|---|---|
| Disabling **NTDS / DNS / Netlogon / Kerberos** on a Domain Controller | Never touch these services on a DC |
| Resetting permissions on `C:\Windows` or `/etc` recursively | Fix individual files only |
| `apt purge` that also removes the desktop (it asks `Do you want to continue?`) | **Read the list of packages** apt will remove before answering Y |
| `apt autoremove` right after removing a big package | Read the list first |
| Deleting files in `/usr`, `/lib`, `C:\Windows` because they "look odd" | Look them up first (`dpkg -S file`) |
| Touching anything named **CyberPatriot** or the **scoring** service | Never. It's how you get points. |
| Rebooting in the middle of updates | Reboot at most once, near the end |
| Deleting the README, forensics files or the Scoring Report shortcut | Leave the desktop files alone |

---

<a id="topic-4"></a>
## Losing points you already earned

| Mistake | Instead |
|---|---|
| Undoing your own fix later (e.g. a second script run re-enabling something) | Check the Scoring Report after each big change. If it drops, undo the last change. |
| Answering forensics after deleting the evidence | Forensics first |
| Two teammates working on the same image | One person per image |

---

<a id="topic-5"></a>
## If your score goes down
1. **Stop.** What was the last thing you changed?
2. Undo that specific change using the backup/value you actually recorded. No external script backup is assumed.
3. Refresh the Scoring Report.
4. Still down? Revert to your last VMware snapshot. A rollback discards changes made after the snapshot; scoring may fall. Follow the round rules and recheck the report.

---

<a id="topic-6"></a>
## A concrete penalty-recovery procedure

- [ ] Done

**🎯 What:** Diagnose the most recent change instead of resetting the entire image.

**💡 Why it matters:** Reinstalling roles, deleting firewall rules or rolling back a VM can discard correct work and introduce new faults.

**🛑 Before changing anything:** Stop new edits. Record the report timestamp, penalty wording and last configuration change. Check the README and whether the application itself failed.

**🖱️ Clicking (GUI):** Reopen the last setting, compare it with your recorded value, and restore that one value if it contradicted the requirement. Check Event Viewer/system logs for an actual error. Do not clear the logs or reset the scoring system.

**🔎 Typing (check):** Repeat the procedure's inspection command and its syntax/client test. For example, an SSH config file needs `sshd -t` and a new client login, while an SMB permission change needs both share and NTFS checks; a generic ping cannot prove either works.

**🛠️ Typing (fix, only when appropriate):** Use that procedure's explicit rollback, including restoring any new-file absence or old runtime value. Restore before trying another theory.

**✅ Check it worked:** Required function returns, the queried setting matches the intended state and the report refreshes. Record what failed and why so another teammate does not reapply it.

**↩️ Undo:** If the attempted recovery itself was mistaken, return it to its recorded starting value. Escalate with the exact error and requirement, not a guess that every security setting should be disabled.

**⚠️ Warnings:** Account deletion, password reset and database migrations may not have a simple undo. Snapshot rules vary; no general claim that points survive reverting is reliable. Do not assume an account not listed among human users is unauthorized if a required service owns it.
