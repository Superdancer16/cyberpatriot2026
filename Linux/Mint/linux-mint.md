# 🐧 Linux Mint checklist (Mint 20 / 21 / 22, Cinnamon)

> [!TIP]
> **🧭 Jump to a stage:** [📘 Basics](#stage-1) · [🚀 First steps](#stage-2) · [🛡️ Priority checks](#stage-3) · [⚙️ Services](#stage-4) · [🧰 Advanced](#stage-5) · [✅ Final checks](#stage-6)
> **🔎 Check · 🛠️ Fix · ✅ Verify · ↩️ Undo · ⚠️ Caution** — commands are for manual, scenario-aware use.

> [!CAUTION]
> **Read the image README before changing accounts, services, authentication, or network access.** Preserve forensic evidence and a recovery path; do not apply every example automatically.

**Forensics first — searchable question solver:** [Linux forensic guide](../forensics.md) — Ctrl+F question index, Base64/ROT13, hex/XOR/decryption, evidence commands, and optional CyberChef/decoder websites.

Linux Mint is in **Round 1, the State round, and the Semifinals** this season. It is built on Ubuntu, so almost everything here also works on Ubuntu (see the [Ubuntu checklist](../Ubuntu/ubuntu.md) for the few differences).

**How to use this page**
- Work **top to bottom**. The order matches where points usually are.
- For each applicable task, use the easiest method and verify the result; alternate commands and deeper explanations are optional.
- `alice`, `bob` etc. are example names. **Use the names from your README.**
- New to the terminal? Read [Linux terminal basics](linux-mint.md#22-complete-linux-terminal-basics-embedded) first (10 minutes).
- Follow the manual procedures and verify every item; automation is not included in this repository.

---

**Prioritization reflects recurring topics in public checklists, not published per-fix score values.** The competition README, required accounts/services and evidence-preservation rules take precedence. Inspect first; change only what is allowed; verify and record rollback.


---

<a id="stage-1"></a>
> [!IMPORTANT]
> **🎯 TASK = do/check only what applies to the README.** **⭐ EASIEST WAY** shows the recommended GUI if one exists; otherwise use the Terminal commands. Blue **NOTE** boxes contain alternate methods and background information. Yellow/orange **CAUTION/WARNING** boxes contain safe-rollback reminders. **Do not run both GUI and Terminal procedures just to tick a checkbox.**

## Part 1 — Basics / Information Needed

> [!TIP]
> 📘 **Foundation:** Review the key terms and available tools before making changes.

### Linux Mint information to know before starting

- [ ] **🎯 DO THIS —** Identify Mint version, Ubuntu base, **Cinnamon/MATE/Xfce** desktop, display manager and available login recovery.
- [ ] **🎯 DO THIS —** Understand sudo, APT packages, Flatpak apps, systemd, UFW, SSH, desktop lock and LightDM-specific settings.
- [ ] **🎯 DO THIS —** Know that Linux Mint GUI paths differ from Ubuntu GNOME, especially **Users and Groups**, **Update Manager** and **Login Window**.
- [ ] **🎯 DO THIS —** Read the image README for authorized users, required services and prohibited software before changes.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ~~~bash
> cat /etc/os-release
> id
> systemctl status display-manager --no-pager
> command -v ufw
> command -v flatpak
> ~~~
>
**⭐ EASIEST WAY — GUI (when available):** Cinnamon Menu → Administration / Preferences, and the installed login/desktop tools. Only edit the display manager actually installed. Full terminal training remains in the advanced appendix.

---

<a id="stage-2"></a>
## Part 2 — First Things to Do

> [!IMPORTANT]
> 🚀 **Start here:** Follow the image README, preserve forensics, and confirm administrative recovery.

Open the README, record users/required services, preserve forensics answers and maintain administrator access.

### 0. Before you touch anything

#### 0.1 Read the README
- [ ] **🎯 DO THIS — 0.1 Read the README**

Write down the admins, users, critical services, required software and prohibited items. See [Reading the README](../../Misc/General/reading-the-readme.md).

#### 0.2 Take a snapshot
- [ ] **🎯 DO THIS — 0.2 Take a snapshot**

> [!NOTE]
> **🎯 What:** Save the current state of the VM so you can go back if you break it.

**⭐ EASIEST WAY — GUI (when available):** In VMware: **VM → Snapshot → Take Snapshot…**, name it "start".

> [!TIP]
> Take another snapshot whenever your score goes up a lot. If something breaks, **VM → Snapshot → Revert**. You lose the changes since that snapshot, but the scoring engine keeps the points you already earned.

#### 0.3 Open a terminal and check you have admin rights
- [ ] **🎯 DO THIS — 0.3 Open a terminal and check you have admin rights**

**⭐ EASIEST WAY — Terminal command(s):** press **Ctrl + Alt + T**, then:
```bash
sudo -v        # asks for YOUR password; no error = you are an admin
whoami         # shows which user you are logged in as
```

#### 0.4 Open the Scoring Report
- [ ] **🎯 DO THIS — 0.4 Open the Scoring Report**

Double-click **Scoring Report** on the desktop. Keep it open in a browser tab and refresh it as you work.

---

### 1. Forensics questions (do these FIRST)

#### 1.1 Answer every forensics question before changing anything
- [ ] **🎯 DO THIS — 1.1 Answer every forensics question before changing anything**

> [!NOTE]
> **🎯 What:** Open each `Forensics Question N.txt` on the desktop, find the answer, and type it after `ANSWER:` in the file, then save.

> [!NOTE]
> **💡 Why it matters:** They're often worth the most points, and fixing things (deleting users, files) can destroy the evidence you need.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo find / -iname "*secret*" 2>/dev/null          # find a file by name
sudo grep -rIl "password" /home 2>/dev/null        # find files that contain a word
sha256sum /path/to/file                            # hash of a file
echo 'aGVsbG8=' | base64 -d                        # decode base64
sudo grep -E 'Accepted|Failed' /var/log/auth.log   # who logged in / failed to
```
More techniques: [Linux forensics guide](../forensics.md).

> [!WARNING]
> Answers must be **exact**: right spelling, capitals, and full paths when asked. Don't delete the "ANSWER:" line.

#### 1.2 Fast path: run the hardening script
- [ ] **🎯 DO THIS — 1.2 Fast path: run the hardening script**

> [!NOTE]
> **🎯 What:** Prepare a manual baseline. The upstream automation is not included in this repository.

> [!NOTE]
> **💡 Why it matters:** A status label cannot establish that a setting is correct on this particular image.

> [!CAUTION]
> **🛑 Before changing anything:** Read the README and preserve forensics evidence. Record your current administrator account, required users, services, ports, and initial score.

**⭐ EASIEST WAY — GUI (when available):** Open the README and Scoring Report from the desktop. In your VM manager, create a practice snapshot only if the round rules permit it. Open the platform's account and service management screens described below.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
**✅ Check it worked:** Repeat each inspection, test the README-required function, then refresh the Scoring Report. A lack of new points does not prove the change failed.

> [!WARNING]
> **↩️ Undo:** Reverse the most recent change using the recorded value or the procedure's backup. A VM snapshot rollback can discard later fixes; use it only within the rules and verify the resulting score again.

> [!CAUTION]
> **⚠️ Warnings:** Never use a guessed list of authorized users or bulk-delete files. See [Using the scripts safely](../../Misc/Scripts/README.md) for the limits of external tools.

---

<a id="stage-3"></a>
## Part 3 — Commonly Assessed High-Priority Checks

> [!IMPORTANT]
> 🛡️ **Priority checks:** Inspect the most common security categories first; actual scoring remains image-specific.

Prioritize account privileges, password policy, firewall and signed updates before lengthy service configuration.

### 2. Users and groups

#### 2.1 See every user on the computer
- [ ] **🎯 DO THIS — 2.1 See every user on the computer**

> [!NOTE]
> **🎯 What:** Get the list of real (human) users and compare it with the README.

**⭐ EASIEST WAY — GUI (when available):** **Menu → Administration → Users and Groups**. Enter your password. Every user is listed on the left with their account type (Administrator / Standard).

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd
> ```
> This prints every user with a user ID (UID) of 1000 or more, which means the real people.

#### 2.2 Reconcile unauthorized users
- [ ] **🎯 DO THIS — 2.2 Reconcile unauthorized users**

> [!NOTE]
> **🎯 What:** Identify any login not authorized by the README; preserve forensic evidence before disabling or removing it.

> [!NOTE]
> **💡 Why it matters:** An extra account is the easiest way for an attacker to get back in.

**⭐ EASIEST WAY — Terminal:** Confirm the identity, record `sudo chage -l EXAMPLE_USER`, then use `sudo usermod --expiredate 1970-01-02 EXAMPLE_USER` to contain access reversibly. If the README/scoring task requires the account **removed**, delete only after preserving evidence; an expired account may not satisfy a removal task.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> sudo chage -l EXAMPLE_USER              # record original expiry
> sudo usermod --expiredate 1970-01-02 EXAMPLE_USER  # disable
> # If explicit account removal is required and evidence is preserved:
> # sudo userdel EXAMPLE_USER
> ```
>
**✅ Verify:** `sudo chage -l EXAMPLE_USER` shows expiry; if removed, `id EXAMPLE_USER` reports no such user. Verify an authorized admin can still sign in. Undo a mistaken expiry by restoring the original value.

> [!CAUTION]
> Check the spelling against the README **three times**. Deleting an authorized user is a penalty. Never delete yourself, `root`, or system accounts (UID below 1000 like `www-data`, `syslog`, `messagebus`).

#### 2.3 Create users the README says should exist
- [ ] **🎯 DO THIS — 2.3 Create users the README says should exist**

**⭐ EASIEST WAY — GUI (when available):** **Users and Groups → Add** (the "+" button), choose Standard or Administrator, enter the name, then set a password.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> sudo adduser erin             # asks for a password and details
> ```

#### 2.3a Create an authorized administrator account
- [ ] **🎯 Create a new admin only if the README requires one:** **Menu → Administration → Users and Groups → Add (+)** → enter the exact new username, set a secure password, and choose **Administrator** as the account type.
- **✅ VERIFY:** New account appears; open it and confirm **Administrator**. In Terminal, `id EXAMPLE_ADMIN` should show `sudo` membership. Keep at least one previously authorized working admin account.
> [!NOTE]
> **🔁 ALTERNATE — Terminal if GUI is unavailable:** `sudo adduser EXAMPLE_ADMIN` then `sudo usermod -aG sudo EXAMPLE_ADMIN`. Verify with `id EXAMPLE_ADMIN`. Do not run both methods or append the same membership twice.

#### 2.3b Require the new administrator to change password at next login
- [ ] **🎯 Require first-login password change:** After creating the **README-required** administrator and assigning an initial secure password, run **`sudo passwd -e EXAMPLE_ADMIN`** in Terminal. This expires the **password**, not the account. The Mint account-management GUI may not expose this specific flag.
- **✅ VERIFY:** Run `sudo chage -l EXAMPLE_ADMIN` and confirm password change is required at the next successful login; test a new authorized login when safe. **↩️ UNDO:** To reverse a mistaken change, restore the recorded prior password-aging state with `chage`, never guess.
> [!NOTE]
> **🔁 ALTERNATE — Terminal:** `sudo chage -d 0 EXAMPLE_ADMIN` has the same first-login password-change intent. Use **only one** method.

#### 2.4 Fix who is an administrator
- [ ] **🎯 DO THIS — 2.4 Fix who is an administrator**

> [!NOTE]
> **🎯 What:** Only the README's admins should be in the `sudo` group (that's what "Administrator" means on Mint).

**⭐ EASIEST WAY — GUI (when available):** In **Users and Groups**, click the user, then set **Account type** to *Administrator* or *Standard*.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> getent group sudo                       # who has sudo now
> sudo deluser bob sudo                   # take admin away from bob
> sudo usermod -aG sudo alice             # give admin to alice
> getent group adm                        # 'adm' can read logs - normally admins only
> ```
>
**✅ Check it worked:** `getent group sudo` lists only the README admins.

- [ ] **🎯 Demote a user who should remain Standard:** **Users and Groups → select the exact user → Account type → Standard**. **✅ VERIFY:** Reopen account and check `id EXAMPLE_USER` no longer shows `sudo`. **↩️ UNDO:** Restore prior group only if README-authorized. This does not delete the user.

#### 2.5 Look for hidden root accounts and hidden users
- [ ] **🎯 DO THIS — 2.5 Look for hidden root accounts and hidden users**

> [!NOTE]
> **🎯 What:** Find accounts with UID 0 (secret root copies), and accounts with a low UID that can still log in.

> [!NOTE]
> **💡 Why it matters:** `useradd -o -u 0 toor` makes a second root that doesn't show up in Users and Groups.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
awk -F: '$3 == 0 {print $1}' /etc/passwd                          # should print ONLY: root
awk -F: '$3 < 1000 && $7 !~ /(nologin|false|sync)$/ {print $1, $3, $7}' /etc/passwd
```
The second command lists low-UID accounts that have a real shell. Normally that's only `root` (and maybe `postgres` if PostgreSQL is installed).

**🛠️ Fix:**
```bash
sudo usermod --expiredate 1970-01-02 toor       # only after confirming this account is unauthorized; preserve evidence first
sudo usermod -s /usr/sbin/nologin mallory       # stop a hidden user from logging in
```

#### 2.6 Check other powerful groups
- [ ] **🎯 DO THIS — 2.6 Check other powerful groups**

**⭐ EASIEST WAY — Terminal command(s):**
```bash
for g in root shadow disk lxd docker sambashare; do getent group $g; done
```
`shadow` can read password hashes. `disk` can read the raw hard drive. `lxd` and `docker` can become root. Normal users shouldn't be in them:
```bash
sudo gpasswd -d carol shadow
```

#### 2.7 Give users strong passwords
- [ ] **🎯 DO THIS — 2.7 Give users strong passwords**

> [!NOTE]
> **🎯 What:** Change every authorized user's password (except your own, unless the README says so) to something strong.

> [!NOTE]
> **💡 Why it matters:** Planted users often have passwords like `password` or `123456`.

**⭐ EASIEST WAY — GUI (when available):** **Users and Groups** → click the user → click the password field → set a new one.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> sudo passwd bob
> ```
> Use 12+ characters with upper case, lower case, a number and a symbol, e.g. `Blue-Train-42!x`. **Write it down.**

> [!WARNING]
> **Don't change your own password** unless the README asks. If you do, you must remember it, because the screen lock and `sudo` will ask for it.

- [ ] **🎯 Correct a weak authorized password:** **Users and Groups → select the specified person → Password → set and confirm a strong unique password**, then verify a fresh authorized login. **🔁 Alternate:** `sudo passwd EXAMPLE_USER`; never publish or reuse an example credential.

#### 2.8 Lock the root account
- [ ] **🎯 DO THIS (only if authorized) — 2.8 Lock the root account**

> [!NOTE]
> **🎯 What:** Make sure nobody can log in directly as `root`. Admins use `sudo` instead.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo passwd -S root      # "root L ..." = locked (good). "root P ..." = has a password
sudo passwd -l root      # lock it
```

**✅ Check it worked:** `sudo passwd -S root` shows `L` after the name.

> [!CAUTION]
> Only do this if **you** can use `sudo` (step 0.3 worked). Otherwise you lock yourself out of admin.

#### 2.9 Accounts with no password
- [ ] **🎯 DO THIS — 2.9 Accounts with no password**

> [!NOTE]
> **🎯 What:** Find accounts that have **no password at all**, so anyone can log in as them by just pressing Enter.

> [!NOTE]
> **💡 Why it matters:** An empty password is a common planted problem. Removing `nullok` (step 3.5) blocks these logins, but the account should still get a real password or be locked.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo passwd -S -a | awk '$2 == "NP" {print $1}'   # NP = no password; should print nothing
sudo passwd bob                                    # README user: give them a strong password
sudo passwd -l mallory                             # account that shouldn't log in: lock it
```

**✅ Check it worked:** the first command prints nothing.

---

### 3. Password and lockout policy

#### 3.1 Password aging (how long passwords last)
- [ ] **🎯 DO THIS — 3.1 Password aging (how long passwords last)**

> [!CAUTION]
> **🎯 What:** Passwords expire after 90 days, can't be changed again for 7 days, and users get 14 days' warning.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo nano /etc/login.defs
```
Find these lines (Ctrl+W searches) and change them to:
```
PASS_MAX_DAYS   90
PASS_MIN_DAYS   7
PASS_WARN_AGE   14
```
Save with **Ctrl+O, Enter**, exit with **Ctrl+X**.

**✅ Check it worked:** `grep ^PASS_ /etc/login.defs`

- [ ] **🎯 Minimum password age (when required):** Record the initial `PASS_MIN_DAYS` from `/etc/login.defs`, then set it to the **image-required** number. **7 days is an example, not universal.** Reopen the file to verify. This default applies only to **new** accounts; section 3.2 covers existing users. **↩️ UNDO:** Restore the original recorded setting.

#### 3.2 Apply aging to the users who already exist
- [ ] **🎯 DO THIS — 3.2 Apply aging to the users who already exist**

> [!NOTE]
> **💡 Why:** `login.defs` only affects **new** users.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo chage -M 90 -m 7 -W 14 bob
sudo chage -l bob            # check: "Maximum number of days" = 90
```

#### 3.3 Password complexity (pwquality)
- [ ] **🎯 DO THIS — 3.3 Password complexity (pwquality)**

> [!NOTE]
> **🎯 What:** Make Linux reject weak passwords when someone changes theirs.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo apt install libpam-pwquality
sudo nano /etc/security/pwquality.conf
```
Set (remove the `#` at the start of each line):
```
minlen = 12
ucredit = -1
lcredit = -1
dcredit = -1
ocredit = -1
difok = 3
maxrepeat = 3
usercheck = 1
dictcheck = 1
enforce_for_root
```
`-1` means "at least one" (upper case, lower case, digit, other symbol).

Also check the PAM line exists:
```bash
grep pwquality /etc/pam.d/common-password
```
It should look like: `password requisite pam_pwquality.so retry=3 ...`. You can add the same options to the end of that line (`minlen=12 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1`).

#### 3.4 Password history (no re-using old passwords)
- [ ] **🎯 DO THIS — 3.4 Password history (no re-using old passwords)**

Use the supported `pam_pwhistory` procedure in [17.2](#172-password-aging-pam-and-lockout-without-breaking-login). Do not copy an old `pam_unix remember=` line across releases or append a duplicate module. Preserve the current PAM stack and test with an ordinary user before closing the recovery console.

#### 3.5 No logins with an empty password
- [ ] **🎯 DO THIS — 3.5 No logins with an empty password**

> [!NOTE]
> **🎯 What:** Remove the word `nullok` from `/etc/pam.d/common-auth`.

> [!NOTE]
> **💡 Why:** `nullok` lets an account with an empty password log in without typing anything.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
grep nullok /etc/pam.d/common-auth
sudo sed -i 's/ nullok//' /etc/pam.d/common-auth
```

**✅ Check it worked:** `grep -c nullok /etc/pam.d/common-auth` prints `0`.

#### 3.6 Account lockout after failed logins (careful!)
- [ ] **🎯 DO THIS — 3.6 Account lockout after failed logins (careful!)**

> [!NOTE]
> **🎯 What:** Limit repeated invalid authentication attempts using a module supported by the installed release.

> [!NOTE]
> **💡 Why it matters:** Incorrect PAM control flow can deny all users or bypass policy. Package versions and authentication providers determine integration; release age alone is not a reliable module test.

Use [17.2's complete PAM backup, module discovery, lockout verification and recovery procedure](#172-password-aging-pam-and-lockout-without-breaking-login). Never replace the primary PAM block with a generic example or add obsolete pam_tally2 rules based solely on a version name. Keep a root console and test a separate ordinary user's actual password login.

---

### 4. Firewall (UFW)

#### 4.1 Turn on the firewall
- [ ] **🎯 DO THIS — 4.1 Turn on the firewall**

> [!NOTE]
> **🎯 What:** Block every incoming connection except the ones the README needs.

**⭐ EASIEST WAY — GUI (when available):** **Menu → Preferences → Firewall Configuration** (or type `firewall` in the menu's search box). Switch **Status** on, set **Incoming: Deny** and **Outgoing: Allow**.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> sudo ufw default deny incoming
> sudo ufw default allow outgoing
> sudo ufw allow ssh              # ONLY if SSH is a critical service in the README
> sudo ufw enable
> sudo ufw logging on
> ```
>
**✅ Check it worked:** `sudo ufw status verbose` shows `Status: active` and `Default: deny (incoming)`.

#### 4.2 Allow the critical services (and nothing else)
- [ ] **🎯 DO THIS — 4.2 Allow the critical services (and nothing else)**

| README needs | Command |
|---|---|
| SSH | `sudo ufw allow 22/tcp` |
| Web server (Apache/Nginx) | `sudo ufw allow 80/tcp` and `sudo ufw allow 443/tcp` |
| FTP | `sudo ufw allow 21/tcp` |
| Samba (file sharing) | `sudo ufw allow samba` |
| MySQL from other computers | `sudo ufw allow 3306/tcp` |
| DNS server | `sudo ufw allow 53` |

#### 4.3 Remove rules an attacker added
- [ ] **🎯 DO THIS (only if authorized) — 4.3 Remove rules an attacker added**

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo ufw status numbered
sudo ufw delete 3            # delete rule number 3 (check the number first!)
```
Look for odd ports like 4444, 1337, 31337, 6667, or "ALLOW Anywhere" on a port no critical service uses.

---

### 5. Updates

> [!TIP]
> Start updates early: they can take 20+ minutes. You can keep working in another window while they run.

#### 5.1 Install all updates
- [ ] **🎯 DO THIS — 5.1 Install all updates**

**⭐ EASIEST WAY — GUI (when available):** **Menu → Administration → Update Manager** → **Refresh** → **Install Updates**. If it asks to update itself first, say yes.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> sudo apt update
> sudo apt full-upgrade -y
> ```

- [ ] **🎯 Install required security updates:** **Update Manager → Refresh → Install Updates**, including the important security packages listed for this image. Review prompts and do not accept removal of required apps.
- [ ] **🎯 Update systemd when listed:** In **Update Manager**, look for the **systemd** package and apply its approved update through the GUI. **✅ VERIFY:** Refresh again; no approved systemd update remains pending, and required login/network/services work. **🔁 Alternate terminal check:** `apt-cache policy systemd` / `dpkg-query -W systemd`. Do not force a release upgrade or reboot without an approved checkpoint.

#### 5.2 Turn on automatic updates
- [ ] **🎯 DO THIS — 5.2 Turn on automatic updates**

**⭐ EASIEST WAY — GUI (when available):** **Update Manager → Edit → Preferences → Automation** → turn on **Apply updates automatically**. On the **Options** tab, make sure **Refresh the list of updates automatically** is on.

The same switch from the terminal:
```bash
sudo mintupdate-automation upgrade enable                  # "Apply updates automatically"
systemctl is-enabled mintupdate-automation-upgrade.timer   # prints "enabled" when it's on
```

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> sudo apt install unattended-upgrades
> sudo nano /etc/apt/apt.conf.d/20auto-upgrades
> ```
> Make it contain:
> ```
> APT::Periodic::Update-Package-Lists "1";
> APT::Periodic::Unattended-Upgrade "1";
> APT::Periodic::Download-Upgradeable-Packages "1";
> APT::Periodic::AutocleanInterval "7";
> ```

- [ ] **🎯 Ensure the system automatically refreshes available updates:** **Update Manager → Edit → Preferences → Options / Automation** (labels vary) → enable **Refresh the list of updates automatically**. If using APT periodic configuration, verify `APT::Periodic::Update-Package-Lists "1";` in the installed configuration.
  - **✅ VERIFY:** Reopen Update Manager settings or inspect `/etc/apt/apt.conf.d/20auto-upgrades`. Enabling scheduled refresh is distinct from installing pending security updates.

#### 5.3 Check the software sources
- [ ] **🎯 DO THIS — 5.3 Check the software sources**

> [!NOTE]
> **🎯 What:** Make sure updates come from the official Mint and Ubuntu servers only.

**⭐ EASIEST WAY — GUI (when available):** **Menu → Administration → Software Sources**. Look at **PPAs** and **Additional repositories**. Remove anything you don't recognise. Make sure the official repositories are enabled.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> grep -rhv '^#' /etc/apt/sources.list /etc/apt/sources.list.d/ | grep .
> ```
> Official addresses: `packages.linuxmint.com`, `archive.ubuntu.com`, `security.ubuntu.com` (or a country mirror). `[trusted=yes]` on a line is a **red flag**: it turns off signature checking.

#### 5.4 Packages "held" back from updating
- [ ] **🎯 DO THIS — 5.4 Packages "held" back from updating**

```bash
apt-mark showhold              # anything listed will never update
sudo apt-mark unhold firefox   # change firefox to each name the line above printed
```

**✅ Check it worked:** `apt-mark showhold` prints nothing.

#### 5.5 Update the apps the README mentions
- [ ] **🎯 DO THIS — 5.5 Update the apps the README mentions**

Firefox, Thunderbird, LibreOffice and any critical service are updated by 5.1. Check Firefox with **Menu (≡) → Help → About Firefox**.

On Mint, Firefox is a normal `apt` package from the Mint servers (not a snap), so this shows anything still out of date:
```bash
apt list --upgradable 2>/dev/null | grep -Ei 'firefox|thunderbird|libreoffice'   # anything listed is out of date
```
If Update Manager never offers an update for a program, open **Update Manager → Edit → Preferences → Packages**. A package listed there is blocked from updating: select it and remove it from the list.

---

<a id="research-expansion-flatpak-desktop-login-and-cinnamon-security"></a>

- [ ] **🎯 Update required Chromium:** **Update Manager → Refresh → available updates** → select the installed Chromium browser package and install the approved update. Mint package labels differ by release; inspect the actual installed package before assuming it is `chromium`.
  - **✅ VERIFY:** Open **Chromium → ⋮ → Help → About Chromium** to inspect its version, confirm it launches and remains the required browser. **🔁 Alternate:** `apt-cache policy chromium chromium-browser` (inspection only); update through the installed package manager, not an unrelated binary.
- [ ] **🎯 Update OpenSSH (when required):** **Update Manager → Refresh** → install the available **openssh-client / openssh-server** security updates for the installed packages. **✅ VERIFY:** `dpkg-query -W openssh-server openssh-client`, then confirm a working authorized SSH login. **⚠️** Preserve README-required SSH, host keys, custom config and remote access; a daemon update is not permission to disable SSH.

### 🧰 Flatpak, desktop login and Cinnamon security

- [ ] **🎯 DO THIS —** Review installed software through **both APT and Flatpak** when applicable.

~~~bash
dpkg -l | grep -Ei 'firefox|ssh|vnc|steam|torrent|remote'
command -v flatpak
~~~

If Flatpak is present, separately run:

~~~bash
flatpak list --app
flatpak remotes --show-details
~~~

Do not uninstall apps because they have unusual names. Compare each with required/prohibited software and preserve forensic evidence. Preview dependencies before removing a Debian package.

- [ ] **🎯 DO THIS —** Verify the actual login manager and allowed autologin/guest settings.

~~~bash
systemctl status display-manager --no-pager
sudo grep -RnsE '^[[:space:]]*(autologin-user|autologin-user-timeout|allow-guest)' /etc/lightdm 2>/dev/null
~~~

On a Mint/LightDM image, use the installed **Login Window** GUI or the correct config file/override. On other display managers, these LightDM paths may be irrelevant. Back up an edited file and test login in a second session; **do not restart the display manager** while forensic answers are unsaved.

**Cinnamon screen locking:** Preferences → Screensaver / Screen Lock. Check available schemas as the desktop user (not sudo):

~~~bash
gsettings list-schemas | grep -E 'cinnamon|gnome.desktop.screensaver'
~~~

Record a setting before changing it; only use a schema and key that actually exist.

<a id="research-expansion-common-missed-persistence-and-update-checks"></a>
### 📦 common missed persistence and update checks

~~~bash
apt-mark showhold
apt list --upgradable 2>/dev/null
systemctl --failed
systemctl list-timers --all
sudo ss -lntup
~~~

**Read-only scoped file searches:**

~~~bash
sudo find /home /tmp /var/tmp -type f -mtime -2 -print 2>/dev/null
sudo find /usr/local/bin /usr/local/sbin -type f -perm /4000 -ls 2>/dev/null
~~~

> [!NOTE]
> **💡 Why:** Suspicious scheduled jobs, unexpected listeners, software installations and SUID changes may indicate unauthorized persistence. However, some SUID files and timers are legitimate. Do not automatically delete all of them or purge desktop metapackages.

**✅ Verify:** Browser, authorized user login, screen lock, sudo, required SSH/web/share traffic, updated score and saved forensic files. Restore only the specific changed setting if a normal task breaks.

<a id="research-report-expansion-m-r1--users-sudo-uid-0-and-pam-integrity"></a>
### 🔐 Users, sudo, UID 0 and PAM integrity

- [ ] **🎯 DO THIS — 🔐 Users, sudo, UID 0 and PAM integrity**

> [!NOTE]
> **📚 Evidence:** Community/training, verified against native Linux tools. This is not an official scoring list.

**⭐ EASIEST WAY — GUI (when available):** Cinnamon **Menu → Administration → Users and Groups**; for service identities use Terminal. Read the image README before disabling users.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ~~~bash
> getent passwd
> getent group sudo
> awk -F: '$3 == 0 {print $1, $3, $7}' /etc/passwd
> sudo passwd -S -a
> sudo grep -RnsE 'NOPASSWD|!authenticate|pam_exec|pam_permit|pam_debug' /etc/sudoers /etc/sudoers.d /etc/pam.d 2>/dev/null
> ~~~

> [!NOTE]
> **What to look for:** An unapproved human login, a second UID 0 account, a sudo rule granting unauthorized privileges, or a modified PAM module line. Service users and unusual installed policies may be legitimate; do not infer malice from a name alone.

**Fix only after verifying the exact unauthorized sudo membership:**

~~~bash
sudo gpasswd -d EXAMPLE_USER sudo
~~~

For an unauthorized login, after preserving its forensic evidence:

~~~bash
sudo usermod -L EXAMPLE_USER
sudo usermod -s /usr/sbin/nologin EXAMPLE_USER
~~~

**✅ Verification:** Repeat **id EXAMPLE_USER**, **getent group sudo**, **sudo passwd -S EXAMPLE_USER**, and validate sudoers with **sudo visudo -c**. Test a second authorized admin login.

> [!WARNING]
> **↩️ Undo:** Restore recorded shell, lock status and group memberships (only if previously authorized). A password lock can leave SSH-key access or existing sessions possible—inspect them. Do not delete the only sudo account or root.

<a id="research-report-expansion-m-r2--password-aging-quality-and-lockout-without-breaking-login"></a>
### 🔐 Password aging, quality and lockout without breaking login

- [ ] **🎯 DO THIS — 🔐 Password aging, quality and lockout without breaking login**

**⭐ EASIEST WAY — Terminal command(s):**

~~~bash
grep -E '^PASS_(MAX_DAYS|MIN_DAYS|WARN_AGE)' /etc/login.defs
sudo chage -l EXAMPLE_USER
sudo grep -nEv '^[[:space:]]*(#|$)' /etc/pam.d/common-auth /etc/pam.d/common-password
dpkg-query -W libpam-pwquality libpam-runtime libpam-modules 2>/dev/null
~~~

**Before PAM changes:** Keep a working root/console recovery path; preserve actual config files:

~~~bash
sudo cp -a /etc/pam.d/common-auth /etc/pam.d/common-auth.before-cp
sudo cp -a /etc/pam.d/common-password /etc/pam.d/common-password.before-cp
~~~

**Fix only if the README specifies the illustrative 90-day maximum, 1-day minimum and 7-day warning:**

~~~bash
sudo chage -M 90 -m 1 -W 7 EXAMPLE_USER
~~~

For complexity/history/failed-login controls, inspect the actual installed module and supported **pam-auth-update** profiles. Never paste a new full PAM stack from Debian or a historical GitHub script; module order mistakes can lock out all logins.

**✅ Verification:** Re-run **chage -l** and test a new normal-user login, sudo, and an authorized password change from a separate terminal/session before closing the original administrator session.

> [!WARNING]
> **↩️ Undo:** Restore the original per-user aging settings or the specific PAM files from backups using your retained root/console access.

<a id="research-report-expansion-m-r3--mint-repository-integrity-ppas-updates-and-snap-preference"></a>
### 📦 Mint repository integrity, PPAs, updates and Snap preference

- [ ] **🎯 DO THIS — 📦 Mint repository integrity, PPAs, updates and Snap preference**

> [!NOTE]
> **📚 Evidence:** Mint-specific community/vender topics; package managers vary by Mint release.

**⭐ EASIEST WAY — GUI (when available):** **Menu → Administration → Software Sources**. Inspect **Official Repositories, PPAs, Additional Repositories**; compare against the README and installed release. Then use **Update Manager → Refresh**.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ~~~bash
> cat /etc/os-release
> cat /etc/upstream-release/lsb-release 2>/dev/null
> apt-cache policy
> sudo grep -RHE '^(deb |Types:|URIs:|Suites:|Components:|Signed-By:|Trusted:)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
> apt-mark showhold
> sudo dpkg --audit
> ~~~
>
**Mint version note:** Mint 21 commonly uses Ubuntu **jammy**, Mint 22 uses **noble**; do not copy release names without checking actual installed OS/base. Unknown PPAs and Trusted: yes sources merit inspection but may be intentionally required.

**Check Snap preference if relevant:**

~~~bash
dpkg-query -W snapd 2>/dev/null
cat /etc/apt/preferences.d/nosnap.pref 2>/dev/null
~~~

**🛠️ Fix:** Back up the **specific** confirmed malicious repository/PPAs file and disable only that source using Software Sources or careful editor changes. Never delete all PPAs, remove snapd automatically, or disable APT signature checks to silence errors.

**✅ Verification:**

~~~bash
sudo apt update
apt -s upgrade
~~~

Check no unexpected sources/signature errors remain and all required software works. **↩️ Undo:** Restore the changed source/preference file backup; reverting sources does not revert installed package versions.

---

<a id="stage-4"></a>
## Part 4 — Services, Desktop, Software and Threat Investigation

> [!TIP]
> ⚙️ **Service-aware work:** Check required applications and dependencies before adjusting settings.

Inspect services, software, screen lock, SSH, permissions, privileged groups and persistent threats.

### 6. Services

#### 6.1 See what's running and listening
- [ ] **🎯 DO THIS — 6.1 See what's running and listening**

**⭐ EASIEST WAY — Terminal command(s):**
```bash
systemctl list-units --type=service --state=running
sudo ss -tulpn             # programs listening on network ports
```

#### 6.2 Turn off services the README doesn't need
- [ ] **🎯 DO THIS — 6.2 Turn off services the README doesn't need**

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo systemctl disable --now vsftpd        # stop it now AND at boot
sudo apt purge vsftpd                      # remove it completely (if the README doesn't need it)
```

| Service | Package | Usually… |
|---|---|---|
| Telnet server | `telnetd`, `inetutils-telnetd` | **Remove** (sends passwords in plain text) |
| FTP server | `vsftpd`, `proftpd-core`, `pure-ftpd` | Remove unless the README needs FTP |
| Web server | `apache2`, `nginx` | Remove unless the README needs it |
| Database | `mysql-server`, `mariadb-server`, `postgresql` | Remove unless needed |
| Samba | `samba` | Remove unless file sharing is needed |
| SNMP | `snmpd` | Remove |
| NFS | `nfs-kernel-server`, `rpcbind` | Remove unless needed |
| Printing | `cups` | Disable unless printing is needed |
| Avahi (network discovery) | `avahi-daemon` | Disable |
| VNC / remote desktop | `x11vnc`, `vino`, `xrdp` | Remove unless needed |
| DNS server | `bind9` | Remove unless the README needs DNS |
| Mail server | `postfix`, `dovecot-core` | Remove unless the README needs mail |
| Web proxy | `squid` | Remove unless needed |
| Old insecure servers | `tftpd-hpa`, `xinetd`, `openbsd-inetd`, `rsh-server`, `nis` | **Remove** |
| SSH server | `openssh-server` | Keep **only** if the README mentions SSH |

> [!CAUTION]
> **Never** turn off a service the README lists as critical. Disabling a critical service is a penalty on almost every image.

- [ ] **🎯 Disable unneeded Apache2 (only if README says it is not required):** **Menu → Administration → Services** if the installed Mint desktop provides a service manager; otherwise use Terminal: `systemctl is-enabled apache2` and `systemctl is-active apache2` to record the old state, then `sudo systemctl disable --now apache2`.
  - **✅ VERIFY:** `systemctl is-enabled apache2` / `systemctl is-active apache2` show disabled/inactive, and all required sites still work. **↩️ UNDO:** Restore only the previously recorded enable/start state (`sudo systemctl enable --now apache2` if it was both enabled and running). Do not purge a critical web server.

#### 6.3 Make sure the critical services are running
- [ ] **🎯 DO THIS — 6.3 Make sure the critical services are running**

```bash
systemctl status ssh             # "active (running)" in green = good
sudo systemctl enable --now ssh  # start it if it isn't
```

---

### 7. Prohibited software and files

#### 7.1 Hacking tools
- [ ] **🎯 DO THIS — 7.1 Hacking tools**

**⭐ EASIEST WAY — GUI (when available):** **Menu → Administration → Synaptic Package Manager**. Search each name, right-click → **Mark for Complete Removal** → **Apply**.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> dpkg -l | grep -Ei 'nmap|wireshark|john|hydra|aircrack|ophcrack|hashcat|nikto|sqlmap|ettercap|metasploit|netcat|ncat|medusa|kismet|dsniff'
> sudo apt purge nmap wireshark john hydra
> sudo apt autoremove
> ```

**Two explicit prohibited-software checks (not universal removal instructions):**
- [ ] **🎯 Remove prohibited Nmap:** **Menu → Administration → Synaptic Package Manager** → search **nmap** → confirm exact installed package and absence from required README software → **Mark for Complete Removal → Apply**. 
- [ ] **🎯 Remove prohibited ophcrack:** Same Synaptic workflow → search **ophcrack** → remove only if explicitly prohibited.
  - **✅ VERIFY:** Synaptic shows neither targeted package installed; alternative check `dpkg-query -W nmap ophcrack 2>/dev/null`. **↩️ UNDO:** Reinstall an erroneously removed required package using its approved repository; preserve dependencies.
> [!CAUTION]
> Never run a mass `apt purge` of every program listed in a generic security-tool search. Scan the README for required diagnostic utilities first.

#### 7.2 Games
- [ ] **🎯 DO THIS — 7.2 Games**

```bash
dpkg -l | grep -Ei 'aisleriot|gnome-mines|gnome-sudoku|mahjongg|minetest|supertux|freeciv|0ad|wesnoth|bsdgames|steam'
sudo apt purge aisleriot gnome-mines
```

#### 7.3 File-sharing and remote-access programs
- [ ] **🎯 DO THIS — 7.3 File-sharing and remote-access programs**

```bash
dpkg -l | grep -Ei 'transmission|qbittorrent|deluge|frostwire|teamviewer|anydesk|x11vnc|tightvnc|vino'
flatpak list 2>/dev/null       # Mint's own app store installs flatpaks
snap list 2>/dev/null          # Mint has no snap unless someone added it
```
> [!NOTE]
> Mint installs **Transmission** (a torrent program) by default. Remove it unless the README needs it: `sudo apt purge transmission-gtk transmission-common`

#### 7.4 Media files (music and video)
- [ ] **🎯 DO THIS — 7.4 Media files (music and video)**

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo find /home /root /tmp /srv /opt /var/www -type f \( -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.wav' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.flac' -o -iname '*.ogg' -o -iname '*.wma' -o -iname '*.m4a' \) 2>/dev/null
sudo rm "/home/bob/Music/song.mp3"
```

> [!WARNING]
> Check the forensics questions first. A question might ask about one of these files.

#### 7.5 Other files that break policy
- [ ] **🎯 DO THIS — 7.5 Other files that break policy**

Password lists, credit card or social security number files, packet captures (`.pcap`), and hacking scripts:
```bash
sudo find /home /root /tmp /opt -type f \( -iname '*password*' -o -iname '*.pcap' -o -iname '*creditcard*' -o -iname '*.kdbx' \) 2>/dev/null
sudo ls -la /home/*/ /tmp /var/tmp /opt     # look for anything odd, including hidden .files
```

---

### 8. Login screen and desktop

#### 8.1 No guest sessions and no automatic login
- [ ] **🎯 DO THIS — 8.1 No guest sessions and no automatic login**

**⭐ EASIEST WAY — GUI (when available):** **Menu → Administration → Login Window → Users** tab. Turn **Allow guest sessions** off (this switch only appears if guest sessions are installed). Clear the **Automatic login** username. Turn **Hide the user list** and **Allow manual login** on, so the login screen doesn't show everyone's name.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> sudo nano /etc/lightdm/lightdm.conf
> ```
> Under `[Seat:*]` (if the file is new or empty, type the `[Seat:*]` line too):
> ```
> [Seat:*]
> allow-guest=false
> autologin-user=
> greeter-hide-users=true
> greeter-show-manual-login=true
> ```
> Also check the other LightDM files, because they can turn these back on. A section called `[SeatDefaults]` is the old name for `[Seat:*]` and counts the same:
> ```bash
> grep -rE 'autologin|allow-guest|hide-users' /etc/lightdm/ /etc/xdg/lightdm/ /usr/share/lightdm/lightdm.conf.d/
> ```
>
**✅ Check it worked:** the `grep` shows no user name after `autologin-user=` and no `allow-guest=true`. The changes show on the login screen after the next restart.

#### 8.2 Lock the screen when idle
- [ ] **🎯 DO THIS (only if authorized) — 8.2 Lock the screen when idle**

**⭐ EASIEST WAY — GUI (when available):** **Menu → System Settings → Screensaver**:
- **Delay before starting the screensaver:** 5 minutes
- **Lock the computer after the screensaver starts:** on
- **Delay before locking:** Lock immediately

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> gsettings set org.cinnamon.desktop.session idle-delay 300           # 300 seconds = 5 minutes
> gsettings set org.cinnamon.desktop.screensaver lock-enabled true
> gsettings set org.cinnamon.desktop.screensaver lock-delay 0         # lock as soon as it starts
> ```
> If it says **The key is not writable**, inspect dconf/organizational policy and verify the effective setting; do not assume it is correct.
>
**✅ Check it worked:** `gsettings get org.cinnamon.desktop.session idle-delay` prints `uint32 300` and `gsettings get org.cinnamon.desktop.screensaver lock-enabled` prints `true`. (The lock is on by default; the 15-minute delay is what usually needs fixing.)

#### 8.3 Don't open USB drives and CDs automatically
- [ ] **🎯 DO THIS — 8.3 Don't open USB drives and CDs automatically**

> [!NOTE]
> **🎯 What:** Stop Mint from mounting, opening and running programs from a USB stick or CD the moment it is plugged in.

> [!NOTE]
> **💡 Why it matters:** A planted USB stick can start malware on its own if autorun is on.

**⭐ EASIEST WAY — GUI (when available):** **Menu → Preferences → Preferred Applications → Removable media** tab → turn **Prompt or start programs on media insertion** off.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
> ```bash
> gsettings set org.cinnamon.desktop.media-handling autorun-never true     # never run programs from media
> gsettings set org.cinnamon.desktop.media-handling automount false        # don't mount drives by themselves
> gsettings set org.cinnamon.desktop.media-handling automount-open false   # don't open a window for them
> ```
>
**✅ Check it worked:** `gsettings get org.cinnamon.desktop.media-handling autorun-never` prints `true`.

> [!NOTE]
> With automount off, a USB stick still works: click it in the file manager's side bar to open it.

#### 8.4 Ctrl + Alt + Delete doesn't restart the computer
- [ ] **🎯 DO THIS (only if authorized) — 8.4 Ctrl + Alt + Delete doesn't restart the computer**

> [!NOTE]
> **🎯 What:** Stop **Ctrl + Alt + Delete** on a text console (Ctrl + Alt + F3 and similar) from rebooting the machine straight away.

> [!NOTE]
> **💡 Why it matters:** Anyone at the keyboard could restart the computer without logging in.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo systemctl mask ctrl-alt-del.target
```

**✅ Check it worked:** `systemctl is-enabled ctrl-alt-del.target` prints `masked`. (Inside your desktop, Ctrl + Alt + Delete still opens Cinnamon's log-out window; that's normal.)

---

### 9. SSH server (only if installed)

```bash
dpkg -l openssh-server       # "ii" at the start = installed
```

#### 9.1 Not needed? Remove it.
- [ ] **🎯 DO THIS (only if authorized) — 9.1 Not needed? Remove it.**

If the README doesn't mention SSH or remote logins:
```bash
sudo systemctl disable --now ssh
sudo apt purge openssh-server
```
On **Mint 22**, SSH can also be started on demand by `ssh.socket`; if you keep the package, turn that off too (see [SSH on Ubuntu 22.10 and newer](../Ubuntu/ubuntu.md#ssh-on-ubuntu-2210-and-newer)).

#### 9.2 Needed? Make it safe.
- [ ] **🎯 DO THIS — 9.2 Needed? Make it safe.**

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo nano /etc/ssh/sshd_config
```

| Setting | Value | Why |
|---|---|---|
| `PermitRootLogin` | `no` | Nobody logs in directly as root |
| `PermitEmptyPasswords` | `no` | No logins without a password |
| `MaxAuthTries` | `4` | Fewer password guesses per connection |
| `X11Forwarding` | `no` | Don't forward the desktop |
| `LoginGraceTime` | `60` | Drop slow, half-finished logins |
| `ClientAliveInterval` | `300` | Probe whether the encrypted client connection is responsive |
| `ClientAliveCountMax` | `3` | (with the line above) |
| `HostbasedAuthentication` | `no` | Old, weak login method |
| `IgnoreRhosts` | `yes` | Old, weak login method |
| `PermitUserEnvironment` | `no` | Users can't change SSH's environment |
| `AllowTcpForwarding` | `no` | No tunnelling through this computer |
| `LogLevel` | `VERBOSE` | Better logs |
| `Banner` | `/etc/issue.net` | Show a warning before login |

Then test and reload:
```bash
sudo sshd -t && sudo systemctl reload ssh       # sshd -t prints nothing if the file is OK
```
If `sshd -t` says **Missing privilege separation directory: /run/sshd**, SSH is stopped right now: run `sudo mkdir -p /run/sshd` and test again.

**✅ Check it worked:** `sudo sshd -T | grep -Ei 'permitrootlogin|permitemptypasswords|maxauthtries'` shows `permitrootlogin no`, `permitemptypasswords no` and `maxauthtries 4`.

> [!WARNING]
> Leave `PasswordAuthentication yes` unless the README says otherwise. First prove that each required user has a working permitted authentication method in a separate connection; otherwise disabling passwords can lock them out.

#### 9.3 Check for override files
- [ ] **🎯 DO THIS — 9.3 Check for override files**

Files in `/etc/ssh/sshd_config.d/` are read **first**, and for SSH the first value wins, so they override everything above:
```bash
grep -r . /etc/ssh/sshd_config.d/ 2>/dev/null
sudo sshd -T | grep -Ei 'permitrootlogin|permitemptypasswords|passwordauthentication'   # the settings actually in use
```

#### 9.4 Planted SSH keys
- [ ] **🎯 DO THIS — 9.4 Planted SSH keys**

```bash
sudo find / -name 'authorized_keys*' 2>/dev/null -exec ls -la {} \; -exec cat {} \;
```
Record key fingerprints and compare them with the README and known administrators. Root keys can be legitimate management credentials. Back up the file and remove only the confirmed unauthorized key line, then test required users again.

---

### 11. File permissions

#### 11.1 Password files
- [ ] **🎯 DO THIS — 11.1 Password files**

```bash
ls -l /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo chmod 644 /etc/passwd /etc/group
sudo chmod 640 /etc/shadow /etc/gshadow
sudo chown root:shadow /etc/shadow /etc/gshadow
```

**✅ Check it worked:** run the `ls -l` line again: `passwd` and `group` show `-rw-r--r-- root root`, `shadow` and `gshadow` show `-rw-r----- root shadow`.

#### 11.2 SUID programs (run as root for anyone)
- [ ] **🎯 DO THIS — 11.2 SUID programs (run as root for anyone)**

> [!NOTE]
> **💡 Why:** If `find`, `vim`, `bash` or `python3` has the SUID bit, any user can become root with one command.

```bash
sudo find / -xdev -perm -4000 -type f 2>/dev/null
sudo chmod u-s /usr/bin/find
```
Normal SUID programs include `passwd`, `sudo`, `su`, `mount`, `umount`, `chsh`, `chfn`, `gpasswd`, `newgrp`, `pkexec`, `fusermount3` and `ssh-keysign`. Look up anything else.

#### 11.3 Files anyone can change
- [ ] **🎯 DO THIS — 11.3 Files anyone can change**

```bash
sudo find / -xdev -type f -perm -0002 ! -path '/proc/*' ! -path '/sys/*' 2>/dev/null
sudo chmod o-w /path/to/file
```

**✅ Check it worked:** the `find` line prints nothing (files inside `/tmp` are OK).

#### 11.4 Home folders
- [ ] **🎯 DO THIS — 11.4 Home folders**

```bash
ls -ld /home/*
sudo chmod 750 /home/bob        # other users can't look inside
```

**✅ Check it worked:** in `ls -ld /home/*` every folder ends in `---`, e.g. `drwxr-x--- bob bob`. Each folder should also belong to its own user (`sudo chown bob: /home/bob` fixes one that doesn't).

---

### 12. Sudo rules

#### 12.1 Check /etc/sudoers and /etc/sudoers.d/
- [ ] **🎯 DO THIS — 12.1 Check /etc/sudoers and /etc/sudoers.d/**

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo cat /etc/sudoers
sudo ls -la /etc/sudoers.d/ && sudo cat /etc/sudoers.d/*
```
Look for:
- `NOPASSWD`: sudo without a password. Remove it.
- Lines giving a **normal user** `ALL=(ALL) ALL`.
- `Defaults !authenticate`. Remove it.

**Edit only with visudo** (it checks for mistakes before saving):
```bash
sudo visudo                          # main file
sudo visudo -f /etc/sudoers.d/90-bob # a file in sudoers.d
```

> [!CAUTION]
> A typo in sudoers can break `sudo` for everyone. That's why you **always** use `visudo`.

---

### 13. Backdoors and malware

#### 13.1 Scheduled jobs (cron)
- [ ] **🎯 DO THIS — 13.1 Scheduled jobs (cron)**

```bash
sudo ls -la /var/spool/cron/crontabs/                  # one file per user
for u in $(cut -d: -f1 /etc/passwd); do sudo crontab -l -u $u 2>/dev/null | grep -v '^#' | sed "s/^/$u: /"; done
cat /etc/crontab; ls -la /etc/cron.d /etc/cron.hourly /etc/cron.daily
sudo atq 2>/dev/null                                   # one-off "at" jobs (remove one: sudo atrm 3)
systemctl list-timers --all                            # systemd timers: another kind of scheduled job
```
Red flags: `nc`, `ncat`, `bash -i`, `/dev/tcp/`, `curl ... | bash`, `wget`, `base64 -d`, `python -c`, files in `/tmp`.

**🛠️ Fix:** `sudo crontab -e -u bob` (delete the line), or `sudo rm /etc/cron.d/badfile`.

#### 13.2 Services that start a backdoor at boot
- [ ] **🎯 DO THIS — 13.2 Services that start a backdoor at boot**

```bash
systemctl list-unit-files --type=service --state=enabled
ls -la /etc/systemd/system/ | grep -v '\.wants'
```
For any unit you don't recognise: `systemctl cat name.service` shows what it runs. Remove a bad one:
```bash
sudo systemctl disable --now evil.service && sudo rm /etc/systemd/system/evil.service && sudo systemctl daemon-reload
```

#### 13.3 Programs listening for connections
- [ ] **🎯 DO THIS — 13.3 Programs listening for connections**

```bash
sudo ss -tulpn
```
`nc`, `ncat`, `socat`, `python`, `perl` or `bash` listening on a port is almost always a backdoor. Note the PID, stop it (`sudo kill -9 PID`), **then find what starts it** (13.1, 13.2, 13.4).

#### 13.4 Start-up files and fake commands
- [ ] **🎯 DO THIS — 13.4 Start-up files and fake commands**

```bash
cat /etc/rc.local 2>/dev/null
ls /etc/profile.d/
grep -n 'alias' /home/*/.bashrc /root/.bashrc /etc/bash.bashrc
```
Watch for aliases that hijack commands, e.g. `alias sudo='...'` or `alias ls='...'`. Also check `/usr/local/bin` for programs named like system commands (a fake `ls` or `sudo`).

#### 13.5 The hosts file
- [ ] **🎯 DO THIS — 13.5 The hosts file**

```bash
cat /etc/hosts
```
Localhost, hostname and README-required internal mappings can all be legitimate. Back up `/etc/hosts`, compare each mapping with the scenario, and comment only confirmed unauthorized overrides using `sudo nano /etc/hosts`. Test the actual required hostname afterwards; an unfamiliar address alone is not proof of an attacker.

**✅ Check it worked:** `grep -v '^#' /etc/hosts` shows only the normal lines.

#### 13.6 Hidden root-kit tricks
- [ ] **🎯 DO THIS — 13.6 Hidden root-kit tricks**

```bash
cat /etc/ld.so.preload 2>/dev/null          # should not exist or be empty
grep -n 'pam_permit' /etc/pam.d/common-auth # "auth sufficient pam_permit.so" = anyone can log in
```

#### 13.7 Programs that start when someone logs in
- [ ] **🎯 DO THIS — 13.7 Programs that start when someone logs in**

**⭐ EASIEST WAY — GUI (when available):** **Menu → Preferences → Startup Applications**.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>

#### 13.8 Tampered system programs
- [ ] **🎯 DO THIS — 13.8 Tampered system programs**

```bash
sudo dpkg --verify | grep -v ' c '           # takes a minute or two; lines with a 5 = changed file
```
Fix by reinstalling the package that owns it: `dpkg -S /usr/bin/ls`, then `sudo apt install --reinstall coreutils`.

#### 13.9 Malware scanners (optional, slow)
- [ ] **🎯 DO THIS — 13.9 Malware scanners (optional, slow)**

```bash
sudo apt install clamav rkhunter chkrootkit
sudo systemctl stop clamav-freshclam      # the updater service blocks a manual update while it runs
sudo freshclam                            # download the newest virus list
sudo systemctl start clamav-freshclam
sudo clamscan -ri /home                   # -r = every subfolder, -i = list only infected files
sudo rkhunter --check --sk                # --sk = don't stop for Enter after each part
sudo chkrootkit | grep INFECTED           # nothing printed = nothing found
```
These tools only **report**. Look at each file they name (forensics first!) before you delete it. Warnings from `rkhunter` and `chkrootkit` are often false alarms (for example `Linux.Xor.DDoS` for a harmless script in `/tmp`); `sudo less /var/log/rkhunter.log` shows the details.

---

### 14. Logging and auditing

#### 14.1 System logs and the audit daemon
- [ ] **🎯 DO THIS — 14.1 System logs and the audit daemon**

```bash
sudo apt install auditd rsyslog
sudo systemctl enable --now auditd rsyslog
```
Add audit rules that record changes to the password files:
```bash
echo '-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/sudoers -p wa -k sudoers' | sudo tee /etc/audit/rules.d/50-practice.rules
sudo augenrules --load
```

**✅ Check it worked:** `systemctl is-active auditd rsyslog` prints `active` twice, and `sudo auditctl -l` lists the `-w /etc/passwd` rules.

---

### 15. AppArmor

#### 15.1 Make sure AppArmor is on
- [ ] **🎯 DO THIS — 15.1 Make sure AppArmor is on**

```bash
sudo aa-status
sudo systemctl enable --now apparmor
```
If a profile is in **complain** mode for no reason, enforce it (needs `sudo apt install apparmor-utils`):
```bash
sudo aa-enforce /usr/bin/man      # change /usr/bin/man to the name aa-status listed under "complain mode"
```

**✅ Check it worked:** `sudo aa-status` starts with `apparmor module is loaded` and lists profiles `in enforce mode`; `systemctl is-enabled apparmor` prints `enabled`.

---

### 17. Web browser (Firefox)

#### 17.1 Firefox security settings
- [ ] **🎯 DO THIS — 17.1 Firefox security settings**

> [!NOTE]
> **🎯 What:** Turn on Firefox's built-in protections. Images often switch them off.

> [!NOTE]
> **💡 Why it matters:** Pop-ups, add-on installs and fake websites are how malware gets onto a desktop.

**⭐ EASIEST WAY — GUI (when available):** open Firefox → **≡ → Settings → Privacy & Security**. Labels move between Firefox versions, so if you can't find one, type a word from it (`pop-up`, `add-ons`, `deceptive`, `HTTPS`) into the **Find in Settings** box at the top.
- **Block pop-up windows** ✔
- **Warn you when websites try to install add-ons** ✔
- **Block dangerous and deceptive content** ✔ (and the boxes under it)
- **HTTPS-Only Mode** → on in all windows
- **Passwords:** untick saving passwords unless the README needs it, and check **Saved passwords** for any that shouldn't be there

Then open **≡ → Add-ons and themes → Extensions** and remove any you don't recognise.

**✅ Check it worked:** close and reopen Firefox, then look at the same page again: the boxes are still ticked. If a box is greyed out with "Your browser is being managed by your organization", look at `about:policies` to see which rule sets it.

> [!NOTE]
> Do this in the Firefox of the user you are logged in as. Each user has their own Firefox settings.

---

<a id="research-report-expansion-m-r4--lightdm-guest-sessions-and-automatic-login"></a>
#### 17.2 Chromium security settings (if installed or README-required)
- [ ] **🎯 Block Chromium pop-ups and redirects:** Open **Chromium → ⋮ → Settings → Privacy and security → Site settings → Pop-ups and redirects** → choose **Don't allow sites to send pop-ups or use redirects**. Remove unauthorized sites from any "Allowed" exception list; retain explicitly necessary exceptions.
- **✅ VERIFY:** Reopen the same settings page; blocking remains selected and there are no unauthorized allowed sites. Test README-required websites and login flows. **↩️ UNDO:** Restore only documented required exceptions if they were removed.
> [!NOTE]
> **ℹ️ This is a per-browser setting.** Firefox's pop-up blocker does not configure Chromium. Use the GUI; command-line policy overrides are only needed when the browser is centrally managed.

### 🧰 LightDM guest sessions and automatic login

- [ ] **🎯 DO THIS — 🧰 LightDM guest sessions and automatic login**

**⭐ EASIEST WAY — GUI (when available):** Cinnamon **Menu → Administration → Login Window** (when installed). Inspect permitted autologin/guest options and actual active display manager.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ~~~bash
> systemctl status display-manager --no-pager
> sudo grep -RnsE '^[[:space:]]*(allow-guest|autologin-user|autologin-user-timeout)' /etc/lightdm /usr/share/lightdm/lightdm.conf.d 2>/dev/null
> ~~~

> [!NOTE]
> **What to look for:** Unauthorized guest login or auto-login. LightDM can load multiple configuration snippets; vendor defaults may be overridden by user local settings. If installed manager is not LightDM, use that manager's actual controls.

**Fix only if the README prohibits guest sessions and LightDM is active:** Inspect existing override first. If a new local override is appropriate:

~~~bash
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo nano /etc/lightdm/lightdm.conf.d/50-cp-security.conf
~~~

Configuration file contents:

~~~text
[Seat:*]
allow-guest=false
~~~

Do not overwrite an existing file without a private backup. Avoid duplicate options/sections.

**✅ Verification:** Recheck the actual effective config and test a **new** authorized login at a safe checkpoint; do not restart LightDM mid-round while unsaved forensic work exists.

> [!WARNING]
> **↩️ Undo:** Restore an existing file's exact backup, or remove only your newly created override after checking its path and contents. Verify the original login workflow.

<a id="research-report-expansion-m-r5--cinnamon-screen-lock-and-user-settings"></a>
### 🔐 Cinnamon screen-lock and user settings

- [ ] **🎯 DO THIS (only if authorized) — 🔐 Cinnamon screen-lock and user settings**

**⭐ EASIEST WAY — GUI (when available):** **System Settings → Screensaver**. Inspect auto-lock and lock-on-resume rules for the *actual* logged-in user.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ~~~bash
> printf '%s\n' "$XDG_CURRENT_DESKTOP"
> gsettings list-schemas | grep -E 'cinnamon.desktop.screensaver|gnome.desktop.screensaver'
> ~~~
>
If installed:

~~~bash
gsettings list-recursively org.cinnamon.desktop.screensaver
~~~

**🛠️ Fix:** Change only the policy-required setting in the GUI; if using gsettings first record the actual schema/key/type and old value. Cinnamon, MATE and Xfce are different; don't copy GNOME keys blindly.

**✅ Verification:** Recheck the relevant key with **gsettings get** and test lock/unlock/resume. **↩️ Undo:** Restore exact old user-specific value and test login again.

<a id="research-report-expansion-m-r6--software-flatpak-files-timers-and-suid-investigation"></a>
### 📦 Software, Flatpak, files, timers and SUID investigation

- [ ] **🎯 DO THIS — 📦 Software, Flatpak, files, timers and SUID investigation**

> [!NOTE]
> **📚 Evidence:** Community/training inventory topics; a potentially risky filename is not itself a confirmed vulnerability.

**⭐ EASIEST WAY — Terminal command(s):**

~~~bash
dpkg -l | grep -Ei 'nmap|wireshark|netcat|steam|transmission|qbittorrent|hydra|john'
command -v flatpak
~~~

If Flatpak is installed:

~~~bash
flatpak list --app
~~~

~~~bash
sudo find /home -type f \( -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.avi' -o -iname '*.torrent' \) -print 2>/dev/null
sudo crontab -l
systemctl list-timers --all
systemctl list-unit-files --type=service --state=enabled
sudo ss -lntup
~~~

~~~bash
sudo find /etc /usr/local /opt -xdev -type f -perm /0002 -ls 2>/dev/null
sudo find /usr/local/bin /usr/local/sbin -type f \( -perm /4000 -o -perm /2000 \) -ls 2>/dev/null
cat /etc/hosts
~~~

**🛠️ Fix:** For a truly prohibited APT package preview dependency removals first using **apt -s purge ACTUAL_PACKAGE**, then remove only when authorized. For a verified malicious cron/unit/hosts mapping, back up the exact file and disable/remove only that entry **after forensic evidence is saved**.

**✅ Verification:** Re-run the relevant single inspection and test the expected browser, SSH, file share, database, user login and scoring report.

> [!WARNING]
> **↩️ Undo:** Restore the one package with its original configuration, the backed-up cron/hosts line, the recorded service state, or file permissions. Do not run a blanket rm, chmod -R or mass package purge.

<a id="research-report-expansion-m-r7--ssh-ufw-apparmor-and-required-service-rollback"></a>
### 🛡️ SSH, UFW, AppArmor and required-service rollback

- [ ] **🎯 DO THIS — 🛡️ SSH, UFW, AppArmor and required-service rollback**

**⭐ EASIEST WAY — Terminal command(s):**

~~~bash
systemctl status ssh --no-pager
sudo /usr/sbin/sshd -T 2>/dev/null | grep -Ei '^(permitrootlogin|permitemptypasswords|passwordauthentication)'
sudo ufw status verbose
sudo aa-status
systemctl status unattended-upgrades --no-pager
~~~

Missing units/tools can be normal on an image. Before editing SSH, back up the exact config, check README-required auth/port, run **sudo /usr/sbin/sshd -t**, reload only if supported, and **test a second authorized SSH login** while the old session remains open. Do not disable password auth when required.

Before turning on UFW's default inbound deny, add exact allow rules for required SSH/web/file-share services and retain console access. Do not run **ufw reset** as a repair. Investigate AppArmor DENIED events instead of globally disabling the framework. Use Mint Update Manager and signed APT sources for updates.

**✅ Verify:** Active required service connections and scoring report, user login and privilege elevation. **↩️ Undo:** Reverse the last specific change (firewall rule, SSH config, AppArmor profile, service unit) from its recorded state; never delete score data or restore malicious files casually.

---

<a id="stage-5"></a>
## Part 5 — Advanced Kernel and Reference Procedures

> [!NOTE]
> 🧰 **Advanced reference:** Use these targeted procedures when the scenario calls for deeper investigation.

Retain all detailed service, investigation, terminal and kernel procedures for later targeted use.

### 10. Kernel and network settings (sysctl)

#### 10.1 Turn on network and memory protections
- [ ] **🎯 DO THIS — 10.1 Turn on network and memory protections**

**⭐ EASIEST WAY — Terminal command(s):**
```bash
sudo nano /etc/sysctl.conf
```
Add (or fix) these lines:
```
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv6.conf.all.accept_redirects = 0
kernel.randomize_va_space = 2
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
```
Apply them now:
```bash
sudo sysctl -p
```

**🔎 Check:** `sysctl kernel.randomize_va_space` prints `= 2`. Also look for files in `/etc/sysctl.d/` that set the opposite (for example `ip_forward=1`): `grep -r . /etc/sysctl.d/`

#### 10.2 Turn off core dumps
- [ ] **🎯 DO THIS — 10.2 Turn off core dumps**

> [!NOTE]
> **🎯 What:** Stop crashing programs from writing a "core dump" (a copy of everything in their memory) to disk.

> [!NOTE]
> **💡 Why it matters:** A core dump can contain passwords and keys that were in the program's memory. `fs.suid_dumpable = 0` in 10.1 covers programs that run as root; this line covers everyone else.

**⭐ EASIEST WAY — Terminal command(s):**
```bash
echo '* hard core 0' | sudo tee -a /etc/security/limits.conf
grep -rs core /etc/security/limits.conf /etc/security/limits.d/ | grep -v ':#'   # any other "core" line (e.g. "bob - core unlimited") overrides it: delete it
```

**✅ Check it worked:** `sudo su - bob -c 'ulimit -Hc'` prints `0` (new logins pick it up; your open terminal keeps the old value). Don't check with `sudo -u bob`: `sudo` sets this limit by itself, so it can print `0` even when the setting is wrong.

---

### 16. Critical services (only what the README lists)

If the README needs a web server, database, FTP, Samba or similar, **harden it instead of removing it**. Step-by-step: [Linux service hardening guide](linux-mint.md#20-complete-linux-critical-service-hardening-procedures-embedded).

---

### 17. Detailed manual safety and verification procedures

These procedures supplement every earlier checklist table. Ubuntu and Debian use the same underlying APT/systemd tools where stated; their own checklists describe differences. Open **Menu → Terminal** or press **Ctrl+Alt+T**. Configuration blocks marked `text` are file contents, not commands. Examples use `bob`; substitute the README's actual account. Do not paste placeholders such as `<PID>` literally.

#### 17.1 Users, root and privilege recovery

- [ ] **🎯 DO THIS — 17.1 Users, root and privilege recovery**

> [!NOTE]
> **🎯 What:** Reconcile people, service identities and powerful groups without losing administrator access.

> [!NOTE]
> **💡 Why it matters:** A low UID or an unfamiliar name is not proof of an attacker. Locking a password does not revoke SSH keys, an existing session or a sudo grant.

> [!CAUTION]
> **🛑 Before changing anything:** Record authorized users and service dependencies. Keep a working root terminal open while testing authentication. Protect backups:

```bash
sudo install -d -m 700 /root/cp-backups
sudo cp -a /etc/passwd /etc/group /etc/shadow /etc/gshadow /root/cp-backups/
```

Never copy shadow files to a world-readable desktop directory. Account files form a related database; blindly restoring an old copy can conflict with users created by later package installations.

**⭐ EASIEST WAY — GUI (when available):** **Menu → Administration → Users and Groups**; select each person, inspect account type and group membership, compare with the README. Do not delete a home directory while forensics remains unresolved. GUI absence means use the terminal; do not install another desktop.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> whoami
> id
> sudo -v
> getent passwd
> getent group sudo
> sudo awk -F: '$3 == 0 { print $1, $3, $6, $7 }' /etc/passwd
> ```
>
`sudo -v` validates the current user's sudo access. Normally only root has UID 0, but investigate any exception before editing. `getent` can include directory-service accounts that are not in local files. Inspect an account:

```bash
id bob
sudo passwd -S bob
sudo chage -l bob
sudo -l -U bob
```

`P` means a usable password hash, `L` a locked password, `NP` no password. None proves the password is strong. `sudo -l -U` lists policy, including grants outside the sudo group.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo usermod -aG sudo bob
> ```
>
Remove one unauthorized membership:

```bash
sudo gpasswd -d bob sudo
```

For a confirmed unauthorized account, after evidence collection use account expiration for reversible denial of normal new logins:

```bash
sudo usermod --expiredate 1970-01-02 mallory
```

Investigate existing sessions, processes, keys and services separately. If deletion is explicitly required, preserve its UID, groups and home first, then use `sudo userdel mallory` without `-r`; delete the preserved data only after evidence review and authorization.

**✅ Check it worked:** Log into a **new** permitted session as the authorized user and run `id` and `sudo -l`. Group changes do not alter existing sessions. Check an expired account with `sudo chage -l mallory`.

> [!WARNING]
> **↩️ Undo:** Re-add a removed group with `sudo usermod -aG sudo bob` only if it was originally authorized. Restore the recorded account expiry with `sudo chage -E YYYY-MM-DD mallory`, or `sudo chage -E -1 mallory` only if it originally had no expiration. Do not unlock an account that was originally locked. Account deletion cannot be undone just by recreating a name.

> [!CAUTION]
> **⚠️ Warnings:** Never use `usermod -G sudo` without `-a` to add membership; it replaces supplementary groups. Do not lock root on Debian until a separate administrator and recovery path work. Service identities such as postgres may legitimately use a shell for maintenance.

#### 17.2 Password aging, PAM and lockout without breaking login

- [ ] **🎯 DO THIS — 17.2 Password aging, PAM and lockout without breaking login**

> [!NOTE]
> **🎯 What:** Set password policy and validate the actual PAM stack used for login/password changes.

> [!NOTE]
> **💡 Why it matters:** Incorrect PAM ordering can allow weak passwords or deny every login. `/etc/login.defs` defaults do not change existing users. `pam_tally`/`pam_tally2` examples from older scripts are obsolete on modern releases.

> [!CAUTION]
> **🛑 Before changing anything:** Keep a root console open and back up all affected files:

```bash
sudo cp -a /etc/pam.d /root/cp-backups/pam.d.before-policy
sudo cp -a /etc/security /root/cp-backups/security.before-policy
sudo cp -a /etc/login.defs /root/cp-backups/login.defs.before-policy
```

Use unique backup names if repeating. Record `sudo chage -l bob` before modifying that user.

**⭐ EASIEST WAY — GUI (when available):** Use **Users and Groups** to change only approved user passwords. Standard desktop settings do not expose the complete PAM stack or aging policy; use the terminal for those.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> grep -nE 'pam_unix|pam_pwquality|pam_pwhistory|pam_faillock|nullok' /etc/pam.d/common-auth /etc/pam.d/common-account /etc/pam.d/common-password
> ls /usr/share/pam-configs
> find /usr/lib -name pam_faillock.so -o -name pam_pwhistory.so -o -name pam_pwquality.so 2>/dev/null
> ```
>
Do not insert a module that is absent. Read the installed `man pam_pwquality`, `man pam_pwhistory`, `man pam_faillock` and `man pam-auth-update`; capabilities vary with release and package version.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo chage -M 90 -m 1 -W 14 bob
> ```
>
This means maximum age 90 days, minimum age 1 day, warning 14 days. Use scenario values rather than blindly applying these to service accounts. Inspect/edit defaults for future accounts:

```bash
sudo nano /etc/login.defs
```

For complexity, install only the applicable policy package if absent and permitted:

```bash
sudo apt install libpam-pwquality
```

Use its supplied profile through `sudo pam-auth-update`, selecting password quality without deselecting the required Unix authentication profile. Edit `/etc/security/pwquality.conf` using the settings in section 3.3. A root user can bypass quality unless enforcement is configured; test as an ordinary user.

For history, prefer `pam_pwhistory` when supported. Inspect the existing common-password sequence: quality must obtain the new token, history must check it, and pam_unix must consume it via `use_authtok`. A typical history module line is:

```text
password required pam_pwhistory.so remember=5 use_authtok
```

This is **not** a complete PAM stack. Place it after the active quality module and before the password-writing module, accounting for numeric jump controls already present. Do not append a module after `pam_deny` and assume it executes. Do not duplicate `remember` mechanisms.

For supported faillock, `/etc/security/faillock.conf` can specify:

```text
deny = 5
fail_interval = 900
unlock_time = 900
```

These values alone do not enable lockout: the distribution's PAM stack needs correctly ordered preauth/authfail/account integration. Prefer a supplied distribution profile if present. If none exists, do not paste a generic replacement stack; review the installed module's example and existing control flow with a mentor before changing authentication. Do not lock root or your only administrator to test it.

**✅ Check it worked:** Keep the root console open. From a **separate ordinary user session**, run `passwd` and confirm a deliberately weak test password is rejected before choosing a unique strong one. A root `su - bob` can bypass the password and is not proof authentication works. Test a normal new login and sudo. Inspect errors:

```bash
sudo journalctl _COMM=sudo -n 30 --no-pager
sudo chage -l bob
sudo faillock --user bob
```

Use `faillock` only if installed/configured. An empty record can mean no failures, not successful integration.

> [!WARNING]
> **↩️ Undo:** From the root console, restore the specific modified PAM/config files from backup (preserving metadata), then test a separate login again before exiting root. To clear a mistakenly locked test account's faillock counter:

```bash
sudo faillock --user bob --reset
```

Restore the user's recorded `chage` values individually. A password reset is not reversible to the unknown old plaintext password.

> [!CAUTION]
> **⚠️ Warnings:** Never expose hashes, use one shared password, or test repeated failed logins against the active administrator. Do not restart the desktop display manager while unsaved work is open.

#### 17.3 SSH: effective configuration and a second-session test

- [ ] **🎯 DO THIS — 17.3 SSH: effective configuration and a second-session test**

> [!NOTE]
> **🎯 What:** Secure an installed required SSH server while retaining permitted users.

> [!NOTE]
> **💡 Why it matters:** Included files, Match blocks and socket activation can make the effective configuration differ from the file you edited.

> [!CAUTION]
> **🛑 Before changing anything:** Record the required port, authentication methods, source networks and any SFTP/forwarding requirements. Keep your existing remote connection and console open.

**⭐ EASIEST WAY — GUI (when available):** Use the VM console for recovery. A desktop's sharing panel may configure remote desktop rather than OpenSSH; do not treat them as the same service.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> dpkg-query -W openssh-server
> systemctl status ssh.service ssh.socket --no-pager
> sudo /usr/sbin/sshd -T | grep -Ei 'port |listenaddress|permitrootlogin|passwordauthentication|pubkeyauthentication|permitemptypasswords|allowusers|allowgroups'
> sudo ss -ltnp
> ```
>
`sshd -T` parses effective defaults. Match-dependent rules need a connection-specific inspection, using real values:

```bash
sudo /usr/sbin/sshd -T -C user=bob,host=client.example,addr=192.168.10.20
```

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo cp -a /etc/ssh /root/cp-backups/ssh.before-cp
> sudo nano /etc/ssh/sshd_config
> ```
>
Inspect section 9's table and actual included files. Set `PermitRootLogin no` and `PermitEmptyPasswords no` if compatible with the scenario; retain a tested authentication method for each required user. A first parsed value generally wins for a given context; inspect where Include appears rather than assuming all drop-ins always override all main-file lines. `ClientAliveInterval`/`ClientAliveCountMax` detect unresponsive clients; a responsive idle client can stay connected.

Validate:

```bash
sudo /usr/sbin/sshd -t
```

No output and exit 0 is expected. Then, for ordinary config changes:

```bash
sudo systemctl reload ssh.service
```

For socket-managed port/listen changes follow the Ubuntu-specific procedure; a daemon reload alone might not change the listening socket.

**✅ Check it worked:** In a second terminal on an authorized client, use `ssh bob@server-name` with the actual hostname and port. Confirm login and the required sudo/SFTP function, then repeat `sshd -T`, `ss -ltnp` and the journal check. Close the old connection only after success.

> [!WARNING]
> **↩️ Undo:** Restore the particular edited SSH config/drop-in from `/root/cp-backups/ssh.before-cp`, remove only newly created drop-ins, run `sshd -t`, and reload/restart the appropriate unit from the console. Restore firewall port/source changes too.

> [!CAUTION]
> **⚠️ Warnings:** Do not delete all authorized_keys files. Inspect fingerprints with `ssh-keygen -lf FILE` and remove only confirmed unauthorized keys after preserving them privately. A root key may be legitimate recovery access.

#### 17.4 UFW and nftables: one firewall owner

- [ ] **🎯 DO THIS — 17.4 UFW and nftables: one firewall owner**

> [!NOTE]
> **🎯 What:** Inspect the active firewall and permit required inbound services before imposing default deny.

> [!NOTE]
> **💡 Why it matters:** UFW can use nftables through compatibility tools. Mixing independent policies or flushing rules can break both access and scoring.

> [!CAUTION]
> **🛑 Before changing anything:** Use the console. Record actual server ports, UDP services, IPv6 use and source networks. Do not change `/etc/ufw/before.rules` to copy legacy anti-spoofing snippets without understanding existing defaults.

**⭐ EASIEST WAY — GUI (when available):** If installed, **Menu → Firewall Configuration** (GUFW) → unlock → inspect profiles and existing rules. Create the required allow rule before switching the firewall on. GUFW configures UFW; it is not a separate firewall engine.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo ufw status verbose
> sudo nft list ruleset
> sudo iptables-save
> sudo cp -a /etc/ufw /root/cp-backups/ufw.before-cp
> ```
>
Inactive UFW does not prove no firewall exists. Save native nftables rules if that is the owner's tool:

```bash
sudo nft list ruleset | sudo tee /root/cp-backups/nft-before.nft > /dev/null
```

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo ufw allow from 192.168.10.0/24 to any port 22 proto tcp
> ```
>
Then:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

Use actual required ports. FTP may need passive data ports, DNS both TCP/UDP 53, DHCP its interface-specific UDP path. Do not guess these from the process name.

If the image already uses native nftables, preserve that policy and edit `/etc/nftables.conf` instead of enabling UFW. Back it up first. In the **existing** input base chain, preserve loopback, established/related traffic and required ICMP/ICMPv6, add source-scoped service rules before any matching drop, then validate:

```bash
sudo nft -c -f /etc/nftables.conf
```

Only after reviewing the entire ruleset from the console:

```bash
sudo nft -f /etc/nftables.conf
```

Do not paste a second generic input chain. Stateful IPv6 operation needs ICMPv6 neighbor discovery; blanket blocking it breaks networking.

**✅ Check it worked:** Query the owner's rules and test a fresh permitted connection from another machine. Verify required remote services and IPv4/IPv6 as applicable, not merely `ping` or an old established SSH session.

> [!WARNING]
> **↩️ Undo:** For a newly created UFW rule use `sudo ufw status numbered`, identify its exact number and `sudo ufw delete NUMBER` (replace NUMBER). Restore recorded defaults only if changed. For native nftables restore the reviewed full policy from the console; understand whether the file flushes existing tables before loading. Do not run `nft flush ruleset` remotely as a shortcut.

> [!CAUTION]
> **⚠️ Warnings:** Do not add a broad allow-all rule to make one service work. Keep required outbound traffic and DNS; never disable IPv6 merely because an old script did.

#### 17.5 Package sources, updates and vulnerability triage

- [ ] **🎯 DO THIS — 17.5 Package sources, updates and vulnerability triage**

> [!NOTE]
> **🎯 What:** Verify release-matched signed repositories and update installed required software.

> [!NOTE]
> **💡 Why it matters:** Mixed releases, obsolete PPAs and untrusted keys can introduce malicious or incompatible packages. Historical 2016 repository lists are unsuitable for current images.

> [!CAUTION]
> **🛑 Before changing anything:** Record release and repositories; keep a working desktop and network.

**⭐ EASIEST WAY — GUI (when available):** Mint **Menu → Administration → Software Sources**; inspect official repositories and each additional repository/PPA. Use **Update Manager → Refresh**, review updates, then install supported security updates. Do not select a major release upgrade during a timed round.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> cat /etc/os-release
> apt-cache policy
> sudo grep -RHE '^(deb |Types:|URIs:|Suites:|Components:|Signed-By:)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
> apt-mark showhold
> ```
>
DEB822 `.sources` files and traditional `.list` files are both valid. A trusted `Signed-By` key is repository-specific; never bypass signature validation with `trusted=yes` or `--allow-unauthenticated` to suppress an error.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo cp -a /etc/apt /root/cp-backups/apt.before-cp
> ```
>
Use the GUI or `sudo nano` on that specific file. Preserve the matching Mint and Ubuntu base suites; Linux Mint Debian Edition follows Debian instead. Then:

```bash
sudo apt update
```

Stop on signature, release or 404 errors and investigate the specific source. After success preview the proposed upgrade:

```bash
apt -s upgrade
```

Review changes, then:

```bash
sudo apt upgrade
```

Do not blindly purge held packages or run autoremove. Preview any targeted removal with `apt -s remove PACKAGE` using the actual name; preserve required dependencies and desktop metapackages.

**✅ Check it worked:** `apt list --upgradable` reports remaining upgrades; some may be phased, held or require a reviewed dependency transition. Run `sudo dpkg --audit` for incomplete package configuration and open required applications after updating. There is no universal APT command that proves every installed package has no vulnerability; consult distribution security advisories for the exact installed release/version.

> [!WARNING]
> **↩️ Undo:** Restore the one source file you changed, then `apt update`. Package updates are not undone by restoring sources: use a supported package rollback or allowed practice snapshot only after checking dependencies and preserving later work.

> [!CAUTION]
> **⚠️ Warnings:** On interruption inspect the real package-manager error. Do not delete lock files while another package manager is active. If no manager is running and configuration was interrupted, `sudo dpkg --configure -a` can finish pending configuration; review its output before proceeding.

#### 17.6 Ownership, permissions, SUID and capabilities

- [ ] **🎯 DO THIS — 17.6 Ownership, permissions, SUID and capabilities**

> [!NOTE]
> **🎯 What:** Find dangerous permissions without recursively changing the whole OS.

> [!NOTE]
> **💡 Why it matters:** Some SUID/SGID files and capabilities are intentional; removing all privileged bits breaks tools such as passwd and sudo.

> [!CAUTION]
> **🛑 Before changing anything:** Preserve path, owner, group and octal mode with `stat`. Do not print `/etc/shadow` contents into a shared log.

**⭐ EASIEST WAY — GUI (when available):** File manager → exact file **Properties → Permissions**. Compare owner/group/access with the package or required application's expected state. The GUI may omit ACLs and capabilities.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo stat -c '%a %U:%G %n' /etc/passwd /etc/group /etc/shadow /etc/gshadow
> sudo find / -xdev -type f -perm /6000 -ls 2>/dev/null
> sudo find /home /tmp /var/tmp -xdev -type f -perm -0002 -ls 2>/dev/null
> sudo getcap -r /usr /opt 2>/dev/null
> ```
>
Mint/Ubuntu/Debian commonly use root:shadow mode 640 for `/etc/shadow`; compare the distribution's baseline rather than applying it on FreeBSD. World-writable temporary directories often legitimately use sticky mode 1777. Check package ownership and modifications:

```bash
dpkg-query -S /usr/bin/passwd
sudo dpkg -V passwd
```

Verification output is a lead; local configuration can legitimately differ, and package metadata on a compromised machine is not an independent trusted baseline.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo chown root:shadow /etc/shadow
> sudo chmod 640 /etc/shadow
> ```
>
For a confirmed unauthorized SUID copy only, remove that bit from the exact path:

```bash
sudo chmod u-s /opt/unauthorized-tool
```

**✅ Check it worked:** Repeat `stat` and the targeted listing. Test authorized password changes and sudo from a separate session. Inspect ACLs with `getfacl PATH` if available; mode bits alone may not explain effective access.

> [!WARNING]
> **↩️ Undo:** Restore the recorded owner/group/mode on that exact file. For package-owned executables prefer a trusted package repair after evidence collection, rather than copying an unknown binary.

> [!CAUTION]
> **⚠️ Warnings:** Never `chmod -R 777`, recursively chown system directories, remove all SUID files, or overwrite file ACLs simply because a scanner flags them.

#### 17.7 Cron, systemd and malicious persistence

- [ ] **🎯 DO THIS — 17.7 Cron, systemd and malicious persistence**

> [!NOTE]
> **🎯 What:** Review scheduled and boot/login execution paths.

> [!NOTE]
> **💡 Why it matters:** Legitimate backup, update and service tasks also run as root. Deleting all cron jobs destroys required operations and evidence.

> [!CAUTION]
> **🛑 Before changing anything:** Record command, user, schedule, file path and package owner. Keep copies in `/root/cp-backups`, outside executable startup locations.

**⭐ EASIEST WAY — GUI (when available):** Mint **Menu → Preferences → Startup Applications**; inspect each entry and disable only an unauthorized one. This does not cover systemd, root cron or every user's desktop startup.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo crontab -l
> sudo crontab -u bob -l
> sudo ls -la /etc/cron.d /etc/cron.daily /etc/cron.hourly
> systemctl list-timers --all
> systemctl list-unit-files --state=enabled
> systemctl --user list-unit-files --state=enabled
> ```
>
“No crontab” is not an error requiring a new job. Inspect a suspicious system unit:

```bash
systemctl cat example.service
systemctl show example.service -p FragmentPath -p DropInPaths -p User -p ExecStart
```

Also inspect `/etc/rc.local`, `/etc/profile.d`, `/etc/ld.so.preload`, `/etc/systemd/system`, user shell profiles and `~/.config/autostart`. Do not run referenced suspicious scripts.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo crontab -u bob -l | sudo tee /root/cp-backups/bob-crontab.before-cp > /dev/null
> ```
>
Only use the backup if the listing succeeded. Edit that user's crontab with `sudo crontab -u bob -e`, removing just the unauthorized line. For a confirmed unauthorized unit:

```bash
sudo systemctl disable --now example.timer
sudo systemctl disable --now example.service
```

Inspect any socket/path activation too; disabling one unit may not prevent another from starting it. Do not disable real system units named by the README.

**✅ Check it worked:** Re-list the crontab, unit state and timers, inspect the process/listener and test required scheduled jobs. `systemctl daemon-reload` is needed after unit-file changes, but is not itself a service restart.

> [!WARNING]
> **↩️ Undo:** Reinstall a valid saved crontab with `sudo crontab -u bob /root/cp-backups/bob-crontab.before-cp`. Restore the recorded enabled/running states individually; do not enable every unit you inspected. A copied startup file must return to its original owner and mode.

> [!CAUTION]
> **⚠️ Warnings:** Do not `crontab -r`, blanket-remove `.desktop` files, or restrict all cron access to root unless the scenario actually requires it. User timers run in the user's manager; root's `systemctl --user` is not the desktop user's manager.

#### 17.8 Kernel, AppArmor and logging

- [ ] **🎯 DO THIS — 17.8 Kernel, AppArmor and logging**

> [!NOTE]
> **🎯 What:** Apply supported kernel controls, keep mandatory-access controls active and preserve investigation logs.

> [!NOTE]
> **💡 Why it matters:** Linux kernel settings differ from FreeBSD, and routers/VPNs/containers may require forwarding. AppArmor denials can explain an otherwise confusing service failure.

> [!CAUTION]
> **🛑 Before changing anything:** Record current values and inspect existing drop-ins. Do not disable AppArmor or forwarding without checking the role.

**⭐ EASIEST WAY — GUI (when available):** System Monitor can show processes/resources; use **Logs** if installed for system errors. Kernel and AppArmor policy normally require terminal inspection.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sysctl net.ipv4.ip_forward net.ipv4.tcp_syncookies kernel.randomize_va_space
> sudo grep -RHE 'ip_forward|accept_redirects|randomize_va_space' /etc/sysctl.conf /etc/sysctl.d 2>/dev/null
> sudo aa-status
> sudo journalctl -k -g 'apparmor="DENIED"' --no-pager
> sudo journalctl --since '1 hour ago' -p warning --no-pager
> ```
>
No `aa-status` command means inspect whether apparmor utilities are installed before assuming the security mechanism is absent. Do not replace a working LSM configuration blindly.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo nano /etc/sysctl.d/60-cp-local.conf
> ```
>
Example supported workstation settings (file contents):

```text
net.ipv4.tcp_syncookies = 1
kernel.randomize_va_space = 2
```

Syncookies help during a TCP SYN backlog overflow; ASLR makes memory layout less predictable. They are not a firewall or malware detector. Do not add unknown keys or disable IPv6 globally. Apply just this file:

```bash
sudo sysctl -p /etc/sysctl.d/60-cp-local.conf
```

If a required service is denied by AppArmor, inspect the named profile and denied operation, confirm the operation is legitimate, and update only the relevant local profile rule using distribution guidance. Do not put every profile in complain mode.

**✅ Check it worked:** Query the two sysctl values again, test the required service and review fresh kernel denials. Check `systemctl status systemd-journald`; rsyslog/auth.log may not be installed on every Debian-based image. `journalctl --list-boots` shows retained boots, not a guarantee all historical logs were preserved.

> [!WARNING]
> **↩️ Undo:** Restore the old drop-in or remove only your newly created file, then explicitly restore the recorded runtime values using `sudo sysctl -w KEY=OLDVALUE` with real values. Removing a file alone does not undo its live settings. Restore only the changed AppArmor rule and reload its individual profile after validation.

> [!CAUTION]
> **⚠️ Warnings:** Do not clear journals, truncate logs, or install a logging daemon merely to force one filename to exist. Log output can contain personal data and secrets; keep it private.

#### 17.9 Service and desktop completion checks

- [ ] **🎯 DO THIS — 17.9 Service and desktop completion checks**

> [!NOTE]
> **🎯 What:** Verify required services, desktop login and ordinary-user workflows after hardening.

> [!NOTE]
> **💡 Why it matters:** A daemon can be running while its application is unreachable, its database is down or its permissions deny required users.

> [!CAUTION]
> **🛑 Before changing anything:** Note the original display manager with `systemctl status display-manager`; Cinnamon, MATE, Xfce and GNOME use different settings schemas.

**⭐ EASIEST WAY — GUI (when available):** In the logged-in user's **Screensaver / Privacy → Screen Lock**, set an appropriate timeout and require a password. In login settings disable unauthorized autologin. In the browser review extensions, protection settings and **Help → About** updates. Test locking and unlocking before logging out.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> gsettings list-schemas | grep -E 'cinnamon|gnome.desktop.screensaver|gnome.desktop.session'
> ```
>
Use only the schema that exists. Record `gsettings get SCHEMA KEY` before each earlier desktop change; the exact schema/key in section 8 applies to Cinnamon, not every Mint flavor. For system health:

```bash
systemctl --failed
ip -br address
ip route
sudo ss -tulpn
```

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
**✅ Check it worked:** New authorized login, screen lock/unlock, sudo, hostname resolution, required web/database/share/SSH transactions, all saved forensic answers, current score timestamp, no new service failures. Check package operations have completed before any necessary reboot.

> [!WARNING]
> **↩️ Undo:** Restore the recorded desktop key with `gsettings set` or its GUI value. Restore the exact display-manager config from backup if login fails, using console access. Do not restart the display manager to test while unsaved work remains.

> [!CAUTION]
> **⚠️ Warnings:** A reboot can lose unsaved work and remote access. Finish updates and preserve recovery access first; the rules and actual update state determine whether/when to reboot.

---

### 20. Complete Linux critical-service hardening procedures (embedded)

##### Shared service editing and recovery

**Shared service workflow (applies to each service below):** Read the image README; identify the installed package, **actual** systemd unit, configuration path, required users/ports and working client behavior. Do not install or remove a required server merely to match an example.

1. **Inspect:** `systemctl status UNIT --no-pager`, `systemctl cat UNIT`, `sudo ss -lntup`; preserve forensic evidence and console/authorized recovery access.
2. **Back up:** `sudo cp -a ACTUAL_CONFIG ACTUAL_CONFIG.before-cp` (choose a fresh suffix if one exists). The example paths below apply **only when they exist**; use the correct package/version path.
3. **Fix:** Use the service's existing configuration sections and included files; make one required change. In `nano`: **Ctrl+W** search, **Ctrl+O → Enter** save, **Ctrl+X** exit.
4. **Verify:** Run that service's syntax check **before** reloading/restarting; confirm `systemctl status UNIT`, `sudo journalctl -u UNIT -n 50 --no-pager`, an actual client transaction, and the scoring report.
5. **↩️ Undo:** Restore the exact saved file(s), validate again, reload/restart if needed, and retest the required client. Do not use a purge/reinstall as a first repair or assume a green daemon status proves application access.

> [!CAUTION]
> **Avoid downtime:** Preserve required websites, shares, DNS/DHCP, FTP, SSH, databases and application dependencies. A change in one file may be overridden by an included config. Do not copy example paths/credentials into a different installed release.

##### Apache web server (`apache2`)

| What | Where | Change to |
|---|---|---|
| Hide the version number | `/etc/apache2/conf-available/security.conf` | `ServerTokens Prod` and `ServerSignature Off` |
| Disable TRACE requests | same file | `TraceEnable Off` |
| No folder listings | `/etc/apache2/apache2.conf` (and site files) | In `Options` lines, remove the word `Indexes` (e.g. `Options FollowSymLinks`) |
| Turn off the listing module | — | Disable `Indexes` in the affected directory; do not force module removal |
| Turn off user home pages | — | `sudo a2dismod userdir` (if enabled) |
| Run as www-data, not root | `/etc/apache2/envvars` | `APACHE_RUN_USER=www-data` and `APACHE_RUN_GROUP=www-data` |
| Security headers | new file `/etc/apache2/conf-available/security-headers.conf` | see below |

```bash
sudo a2enmod headers
echo '<IfModule mod_headers.c>
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
</IfModule>' | sudo tee /etc/apache2/conf-available/security-headers.conf
sudo a2enconf security security-headers
sudo apache2ctl configtest          # must say "Syntax OK"
sudo systemctl reload apache2
```

Also check:
- **Web files shouldn't be writable by the web server:** `sudo find /var/www -user www-data -type f`. Usually they should be owned by root: `sudo chown -R root:root /var/www/html` (careful: upload folders for an app like WordPress need write access).
- **Web shells** (hacker control pages hidden in the site): `sudo grep -rlE 'eval\(|base64_decode|shell_exec|system\(\$_' /var/www`
- **`.htaccess` files** that redirect visitors somewhere else: `sudo find /var/www -name .htaccess -exec cat {} \;`

---

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status apache2 --no-pager` (use actual installed unit). `sudo cp -a /etc/apache2/conf-available/security.conf /etc/apache2/conf-available/security.conf.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** `sudo apache2ctl configtest` → `sudo systemctl reload apache2`; `curl -I http://127.0.0.1/` and an authorized real-site test. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/apache2/conf-available/security.conf.before-cp /etc/apache2/conf-available/security.conf`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> Only change `Options Indexes` where directory listing is prohibited; preserve required sites, upload permissions and other included configs.

##### Nginx web server

```bash
sudo nano /etc/nginx/nginx.conf
```
In the `http { ... }` block: `server_tokens off;`

In the site files (`/etc/nginx/sites-enabled/*`): change `autoindex on;` to `autoindex off;`, and optionally add:
```
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
```
```bash
sudo nginx -t                       # must say "test is successful"
sudo systemctl reload nginx
```

---

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status nginx --no-pager` (use actual installed unit). `sudo cp -a /etc/nginx/nginx.conf /etc/nginx/nginx.conf.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** `sudo nginx -t` → `sudo systemctl reload nginx`; `curl -I http://127.0.0.1/` and authorized site routes. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/nginx/nginx.conf.before-cp /etc/nginx/nginx.conf`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> Set `server_tokens` within the existing `http` block; preserve `proxy_pass`, server blocks and document roots.

##### PHP (used by the website)

Edit the **web** PHP settings, not the command-line ones: `/etc/php/<version>/apache2/php.ini` (Apache) or `/etc/php/<version>/fpm/php.ini` (Nginx).

| Setting | Value | Why |
|---|---|---|
| `expose_php` | `Off` | Hide the PHP version |
| `display_errors` | `Off` | Don't show error details to visitors |
| `log_errors` | `On` | …but do log them |
| `allow_url_fopen` | `Off` | Restricts URL-aware file functions; can break legitimate HTTP integrations |
| `allow_url_include` | `Off` | Pages can't include remote code |
| `disable_functions` | `exec,passthru,shell_exec,system,proc_open,popen` | Reduces some command-execution paths; not a sandbox |
| `session.cookie_httponly` | `1` | JavaScript can't steal login cookies |
| `session.use_strict_mode` | `1` | Rejects made-up session IDs |

Then `sudo systemctl reload apache2` (or `php8.1-fpm` etc.).

> [!WARNING]
> `disable_functions` can break some web apps. If the site stops working after the change, remove functions from the list one at a time.

---

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status apache2 --no-pager` (use actual installed unit). `sudo cp -a /etc/php /etc/php.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** Validate edited PHP settings and application with the **active web SAPI**; `php -l PATH_TO_REAL_TEST_PHP` checks syntax only; reload the actual Apache/FPM unit and test the webpage. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/php.before-cp/. /etc/php/`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> `php --ini` checks CLI, not necessarily PHP-FPM/Apache. Discover the installed PHP version and its actual `php.ini`; do not paste directives into a directory.

##### MySQL / MariaDB

##### Built-in hardening tool
```bash
sudo mysql_secure_installation
```
Answer **yes** to: remove anonymous users, disallow root login remotely, remove the test database, reload privileges.

##### Settings file
`/etc/mysql/mysql.conf.d/mysqld.cnf` (MySQL) or `/etc/mysql/mariadb.conf.d/50-server.cnf` (MariaDB), under `[mysqld]`:
```
bind-address = 127.0.0.1      # only this computer can connect (skip if the README says others connect)
local_infile = 0              # SQL can't read files from the server's disk
```
```bash
sudo systemctl restart mysql      # or mariadb
```

##### Look at the database users
```bash
sudo mysql
```
```sql
SELECT user, host, plugin FROM mysql.user;          -- every database account
-- Only after recording SHOW CREATE USER and SHOW GRANTS for the exact account:
DROP USER ''@'localhost';                            -- an anonymous account
DROP USER 'root'@'%';                                -- root allowed from anywhere
-- Change an application credential only together with its private application configuration; never reuse a handbook example password.
SHOW GRANTS FOR 'webapp'@'localhost';                -- what this account can do
FLUSH PRIVILEGES;
EXIT;
```
Accounts that aren't needed, or that have `ALL PRIVILEGES` without needing them, are common planted problems.

---

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status mariadb --no-pager` (use actual installed unit). `sudo cp -a /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** Restart only the installed `mariadb` or `mysql` unit when required, inspect `journalctl -u UNIT -n 30 --no-pager`, and test approved local/application DB access. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/mysql/mariadb.conf.d/50-server.cnf.before-cp /etc/mysql/mariadb.conf.d/50-server.cnf`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> Use the actual `mysqld` section/config file; binding to loopback breaks required remote clients. Preserve socket-based root access, authorized users and grants.

##### vsftpd (FTP server)

```bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
sudo nano /etc/vsftpd.conf
```
| Setting | Value | Why |
|---|---|---|
| `anonymous_enable` | `NO` | No logins without an account |
| `anon_upload_enable` | `NO` | Anonymous users can't upload |
| `anon_mkdir_write_enable` | `NO` | …or make folders |
| `local_enable` | `YES` | Real users can log in (if the README needs it) |
| `chroot_local_user` | `YES` | Users are locked into their home folder |
| `allow_writeable_chroot` | `NO` (or absent) | Prefer a root-owned jail with a separate user-writable upload subdirectory |
| `xferlog_enable` | `YES` | Log every file transfer |
| `ssl_enable` | `YES` | Encrypt passwords and files (only if a certificate is set in `rsa_cert_file`) |

```bash
sudo systemctl restart vsftpd && systemctl status vsftpd
```
Also check `/etc/ftpusers` (users **not** allowed to use FTP; `root` should be in it) and the `userlist_*` settings.

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status vsftpd --no-pager` (use actual installed unit). `sudo cp -a /etc/vsftpd.conf /etc/vsftpd.conf.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** `sudo systemctl restart vsftpd` when appropriate; verify port, an authorized login, upload/download and passive-mode data transfer. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/vsftpd.conf.before-cp /etc/vsftpd.conf`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> `chroot_local_user=YES` needs a safe non-writable jail root and separate writable area; do not disable anonymous access when explicitly required or break TLS clients.

##### ProFTPD
In `/etc/proftpd/proftpd.conf`: `DefaultRoot ~`, `RootLogin off`, `ServerIdent off`, and comment out (`#`) the whole `<Anonymous ~ftp> ... </Anonymous>` block. Test with `sudo proftpd -t`.

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status proftpd --no-pager` (use actual installed unit). `sudo cp -a /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** `sudo proftpd -t` → `sudo systemctl reload proftpd`; verify authorized login, shared-directory access and file transfer. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/proftpd/proftpd.conf.before-cp /etc/proftpd/proftpd.conf`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> Review included files, `Anonymous` blocks and `DefaultRoot`; remove anonymous access only if unauthorized.

##### Pure-FTPd
```bash
echo yes | sudo tee /etc/pure-ftpd/conf/NoAnonymous
echo yes | sudo tee /etc/pure-ftpd/conf/ChrootEveryone
sudo systemctl restart pure-ftpd
```

---

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status pure-ftpd --no-pager` (use actual installed unit). `sudo cp -a /etc/pure-ftpd/conf /etc/pure-ftpd/conf.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** Restart the installed Pure-FTPd unit if needed; verify FTP listener plus authorized login and data transfer. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/pure-ftpd/conf.before-cp/. /etc/pure-ftpd/conf/`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> `NoAnonymous` and `ChrootEveryone` are **separate files** in `/etc/pure-ftpd/conf/`; do not merge both settings or disable required anonymous access.

##### Samba (Windows file sharing)

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
sudo nano /etc/samba/smb.conf
```
In `[global]`:
```
   restrict anonymous = 2
   map to guest = never
   usershare allow guests = no
   server min protocol = SMB2
```
In each share (`[sharename]`): `guest ok = no` (or remove `public = yes`). Check `read only` and `valid users` match what the README says.
```bash
testparm -s                    # check the file
sudo systemctl restart smbd
sudo pdbedit -L                # Samba users: remove any that aren't authorized
sudo smbpasswd -x mallory
```

---

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status smbd --no-pager` (use actual installed unit). `sudo cp -a /etc/samba/smb.conf /etc/samba/smb.conf.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** `sudo testparm -s` → `sudo systemctl reload smbd`; verify `smbclient -L localhost -U AUTHORIZED_USER` or a real Windows client. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/samba/smb.conf.before-cp /etc/samba/smb.conf`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> Preserve required share names/paths, `valid users`, write access, Linux file permissions and intentionally allowed guest access.

##### BIND DNS server

In `/etc/bind/named.conf.options`, inside `options { ... };`:
```
        version "none";                 // hide the version
        allow-transfer { none; };       // don't hand out the zone to anyone
        allow-recursion { localhost; localnets; };
```
```bash
sudo named-checkconf && sudo systemctl reload named
```
Also look in `/etc/bind/named.conf.local` for zones with `allow-transfer { any; };` or `allow-update { any; };`.

---

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status bind9 --no-pager` (use actual installed unit). `sudo cp -a /etc/bind/named.conf.options /etc/bind/named.conf.options.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** `sudo named-checkconf` and `sudo named-checkzone ZONE FILE` for changed zones → reload the installed BIND unit; verify `dig @127.0.0.1 REAL_ZONE`. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/bind/named.conf.options.before-cp /etc/bind/named.conf.options`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> Edit existing `options` blocks and check zone overrides; required secondary servers may need restricted/TSIG-protected zone transfers.

##### Postfix mail server

```bash
sudo postconf -e 'disable_vrfy_command = yes'        # can't ask "does user X exist?"
sudo postconf -e 'smtpd_helo_required = yes'
sudo postconf -e 'smtpd_banner = $myhostname ESMTP'  # hide the version
postconf mynetworks                                  # must NOT contain 0.0.0.0/0 (open relay)
sudo postfix check && sudo systemctl reload postfix
```

---

**✅ Service-specific verify and rollback (only if README-required):**
- [ ] **Inspect and back up:** `systemctl status postfix --no-pager` (use actual installed unit). `sudo cp -a /etc/postfix/main.cf /etc/postfix/main.cf.before-cp` (choose a fresh backup name if one already exists).
- **Validate / apply / verify:** `sudo postfix check` → `sudo systemctl reload postfix`; inspect `journalctl -u postfix -n 30 --no-pager` and test authorized SMTP delivery. Test a real required client, not just the daemon status.
- **↩️ Undo:** `sudo cp -a /etc/postfix/main.cf.before-cp /etc/postfix/main.cf`; repeat validation, apply and required-client test. If service is unavailable, inspect `journalctl -u UNIT -n 50 --no-pager` before reverting.
> [!CAUTION]
> Check `mynetworks`, relay restrictions and required submission before editing; never trust all source networks or break legitimate mail destinations.

##### SSH
See section 9 of the [Linux Mint checklist](linux-mint.md#9-ssh-server-only-if-installed).

---

##### WordPress (and other web apps)
- Update WordPress, plugins and themes from the admin dashboard.
- Delete admin accounts in WordPress that the README doesn't list (**Users** page).
- In `wp-config.php`, add `define('DISALLOW_FILE_EDIT', true);` so the dashboard can't edit PHP files.
- Make sure `wp-config.php` isn't readable by everyone: `sudo chmod 640 wp-config.php`.

##### PostgreSQL: local and required remote database access

- [ ] **🎯 DO THIS — PostgreSQL: local and required remote database access**

> [!NOTE]
> **🎯 What:** Inspect PostgreSQL listening addresses, client authentication and database roles.

> [!NOTE]
> **💡 Why it matters:** `trust` authentication can let a connecting client impersonate database users without a password. An overly restrictive listener can break a required web application on another machine.

> [!CAUTION]
> **🛑 Before changing anything:** In a Linux terminal run:

```bash
dpkg-query -W postgresql postgresql-common
pg_lsclusters
```

`pg_lsclusters` lists version, cluster, port, status and data/log directories. The generic `postgresql.service` can be `active (exited)` while a cluster is down; inspect the listed cluster. Connect locally:

```bash
sudo -u postgres psql -c 'SHOW config_file;' -c 'SHOW hba_file;' -c 'SHOW listen_addresses;'
```

**⭐ EASIEST WAY — GUI (when available):** Use a trusted installed database client to test the authorized account; do not use a superuser's successful connection as the ordinary client's test. There is no standard desktop GUI for these configuration files.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo cp -a /etc/postgresql/15/main/postgresql.conf /etc/postgresql/15/main/postgresql.conf.before-cp
> sudo cp -a /etc/postgresql/15/main/pg_hba.conf /etc/postgresql/15/main/pg_hba.conf.before-cp
> ```

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo nano /etc/postgresql/15/main/postgresql.conf
> ```
>
Inspect `listen_addresses = 'localhost'` for local-only clients. Required remote clients need the intended server address, not a blind wildcard. Then:

```bash
sudo nano /etc/postgresql/15/main/pg_hba.conf
```

Keep legitimate local peer authentication. Replace only an unauthorized `trust` rule with a compatible method. An example restricted remote rule is configuration text:

```text
host    appdb    appuser    192.168.10.0/24    scram-sha-256
```

First ensure that the role has a SCRAM password and clients support it. PostgreSQL uses the **first matching** HBA rule; a later secure rule does not override an earlier broad one.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo -u postgres psql -c 'SELECT line_number,error FROM pg_hba_file_rules WHERE error IS NOT NULL;'
> sudo -u postgres psql -c 'SELECT sourcefile,sourceline,name,error FROM pg_file_settings WHERE error IS NOT NULL;'
> ```
>
No error rows is expected, but these views do not replace client tests. Reload HBA-only changes:

```bash
sudo -u postgres psql -c 'SELECT pg_reload_conf();'
```

Listener changes require a scheduled cluster restart, for this example:

```bash
sudo pg_ctlcluster 15 main restart
```

**✅ Check it worked:** Run `pg_lsclusters`, re-query settings and test the real application as its database role. In `psql`, `\du` lists roles; inspect unexpected superuser, create-role or replication privileges. Do not put passwords on the shell command line.

> [!WARNING]
> **↩️ Undo:** Restore the two original files, validate them again, reload or restart according to which setting changed, and repeat the client test. Restore role credentials/grants separately if they changed.

> [!CAUTION]
> **⚠️ Warnings:** A config backup is not a database backup. Do not drop roles or databases until ownership, application dependencies and forensics are resolved.

##### ISC DHCP and Kea: identify the implementation first

- [ ] **🎯 DO THIS — ISC DHCP and Kea: identify the implementation first**

> [!NOTE]
> **🎯 What:** Keep required address allocation working while removing unauthorized scope or gateway settings.

> [!NOTE]
> **💡 Why it matters:** A wrong DHCP router or DNS option can disconnect every client even though the daemon is running.

> [!CAUTION]
> **🛑 Before changing anything:** Terminal checks:

```bash
dpkg-query -W isc-dhcp-server kea-dhcp4-server
systemctl status isc-dhcp-server kea-dhcp4-server --no-pager
ip -br address
```

A not-installed result is normal. Determine which implementation owns UDP 67 with `sudo ss -lunp`. Do not start a second DHCP server on the same lab network.

**⭐ EASIEST WAY — GUI (when available):** On a test client, open network settings and record its lease address, mask, router and DNS servers. A server GUI is not generally provided.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo cp -a /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.before-cp
> sudo cp -a /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.before-cp
> sudo nano /etc/dhcp/dhcpd.conf
> ```

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
> ```
>
Only after a successful test:

```bash
sudo systemctl restart isc-dhcp-server
```

For installed Kea instead, back up its JSON file, edit the existing `Dhcp4` → `subnet4`, `pools`, `option-data` and `interfaces-config` settings; preserve JSON types and validate:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Then restart `kea-dhcp4-server` only after success. Do not apply ISC syntax to Kea.

**✅ Check it worked:** Inspect unit status/journal and renew a noncritical authorized test client's lease through its network GUI. Verify assigned address, gateway, DNS and access to a required internal hostname. A listening UDP socket alone is insufficient.

> [!WARNING]
> **↩️ Undo:** Restore the changed file(s), validate with the same implementation's command and restart that unit. Do not delete the lease database to repair a syntax error.

> [!CAUTION]
> **⚠️ Warnings:** ISC DHCP is a legacy implementation; preserve the scenario's installed server rather than migrating implementations during a timed round. Do not renew your only remote-management client's lease until console access exists.

##### Web application files and certificates

- [ ] **🎯 DO THIS — Web application files and certificates**

> [!NOTE]
> **🎯 What:** Preserve required application behavior while checking secrets, writable directories and TLS.

> [!NOTE]
> **💡 Why it matters:** Removing a file because it contains `eval` or `exec` can destroy legitimate code; a web shell may also use neither string.

> [!CAUTION]
> **🛑 Before changing anything:** Back up the application, database and virtual-host config separately. Identify the web worker account and required write directories. Do not put backups containing credentials in the web root.

**⭐ EASIEST WAY — GUI (when available):** In the application's admin panel review users, plugins, themes and supported updates. In a browser inspect the certificate hostname, expiry and chain for the actual required HTTPS hostname.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> sudo find /var/www -xdev -type f -mtime -7 -ls
> sudo find /var/www -xdev -type f -perm -0002 -ls
> sudo stat /var/www/html/wp-config.php
> ```
>
Unexpected recent or world-writable files need comparison with a trusted package/application baseline. Do not run suspicious PHP files or publish configuration secrets.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
**✅ Check it worked:** Test login, static pages, uploads if required, database access and HTTPS from the intended client. Inspect application/server logs without clearing them.

> [!WARNING]
> **↩️ Undo:** Restore the particular changed config or supported application/database backup. Restore compatible versions together; a database schema migration may not support file-only rollback.

> [!CAUTION]
> **⚠️ Warnings:** Headers, hidden version strings and disabled PHP functions are supporting controls, not proof an application is secure. Keep required functionality and patch vulnerabilities.

---

### 21. Advanced Linux manual investigations (embedded)

The original practical text and copyable command blocks are retained here for self-contained study. For a Debian image, use Debian-specific explanations in Sections 0–19 before changing a setting.

> Use alongside [Linux Mint](linux-mint.md), [Ubuntu](../Ubuntu/ubuntu.md), [Debian](../Debian/debian.md), and [critical service hardening](linux-mint.md#20-complete-linux-critical-service-hardening-procedures-embedded). This page assumes **Ubuntu / Debian / Linux Mint using systemd**; consult the [FreeBSD checklist](../../Misc/FreeBSD/freebsd.md) for FreeBSD-specific commands. **Read the image README and preserve forensics evidence first.**

These are individually copyable terminal commands. **Inspection is not the same as permission to modify.** Run modifications only after verifying accounts, critical services, connectivity and backups.

##### L1. Verify user identities and sudo privileges—don't guess from names

- [ ] **🎯 DO THIS —** Matched every privileged identity to the competition README.

**⭐ EASIEST WAY — Terminal command(s):**

~~~bash
getent passwd
~~~

The third colon-delimited field is the UID, and the final field is the login shell. Service accounts commonly use \`/usr/sbin/nologin\`; that is not automatically suspicious.

~~~bash
awk -F: '$3 == 0 {print $1 " UID=" $3 " home=" $6 " shell=" $7}' /etc/passwd
~~~

Only \`root\` normally needs UID 0. An additional UID 0 account requires investigation, but **do not delete it before the README check and forensic preservation**.

~~~bash
getent group sudo
sudo grep -RnsE '^[[:space:]]*[^#[:space:]].*(ALL|NOPASSWD)' /etc/sudoers /etc/sudoers.d 2>/dev/null
~~~

> [!NOTE]
> **🧠 Interpretation:** Sudo rules can grant rights to users/groups without those names appearing as members of the \`sudo\` group. Look for \`NOPASSWD\`, wildcards and unusual command allowlists, but understand service/administration needs before editing.

**Before editing a sudo rule:**

~~~bash
sudo visudo -c
sudo cp -a /etc/sudoers /etc/sudoers.cp-backup
~~~

If authorized, use \`sudo visudo\` for the main file or \`sudo visudo -f /etc/sudoers.d/NAME\` for a specific included file. **Never edit sudo policy with an unvalidated plain-text overwrite.**

**Check after an authorized edit:**

~~~bash
sudo visudo -c
~~~

**Recovery:** Restore the backed-up single file through a root/recovery console if sudo stops working. Test a separate authorized session before leaving the administrator session.

##### L2. SSH: inspect *effective* settings and socket activation

- [ ] **🎯 DO THIS —** Confirmed whether SSH is required, listening and correctly configured.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ~~~bash
> systemctl status ssh --no-pager
> systemctl status ssh.socket --no-pager
> sudo ss -lntp
> ~~~
>
A distribution may use \`ssh.service\`, \`ssh.socket\` or other units; an inactive service does **not** alone mean that clients cannot connect. Ubuntu releases since 22.10 may use socket activation, with a generator-based configuration behavior on Ubuntu 24.04.

**Find the effective configuration, including snippets:**

~~~bash
sudo grep -RnsE '^[[:space:]]*(Include|PermitRootLogin|PasswordAuthentication|KbdInteractiveAuthentication|AllowUsers|AllowGroups|PubkeyAuthentication|Port|ListenAddress)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d 2>/dev/null
~~~

~~~bash
sudo /usr/sbin/sshd -t
sudo /usr/sbin/sshd -T | grep -Ei '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|kbdinteractiveauthentication|allowusers|allowgroups) '
~~~

\`sshd -t\` checks configuration syntax. \`sshd -T\` prints effective settings for a generic connection; **\`Match\` rules may alter settings for particular users/hosts**, so check their applicability before concluding all sessions have the same policy.

**⭐ EASIEST WAY — GUI (when available):** In a terminal use \`sudo nano /etc/ssh/sshd_config\` or edit the *specific* applicable file under \`/etc/ssh/sshd_config.d/\`. Before modifying it, copy that same file with \`sudo cp -a source destination\` to a backup path.

**Safe sequence for an authorized change:**

1. Keep the existing administrative session open.
2. Record current listening port, login method and allowed source addresses.
3. Confirm the README-required SSH accounts and methods; do **not** blindly disable password authentication if no working keys exist.
4. Edit the specific applicable setting, avoiding conflicting \`Include\` or \`Match\` directives.
5. Run \`sudo /usr/sbin/sshd -t\`; **stop if it reports errors**.
6. Reload the relevant service if supported and consistent with socket activation. On a conventional systemd SSH service:

~~~bash
sudo systemctl reload ssh
~~~

7. Open **a second SSH session** from an approved client, test normal login, and only then close the original session.

**Recovery:** Restore the exact backed-up config and reload/activate the appropriate unit using VM console if the remote test fails. If you changed the listening port on a socket-activated release, verify the socket generator/unit state too; don't assume an \`sshd_config\` reload alone changes the listener.

##### L3. PAM policy: inspect order before adding modules

- [ ] **🎯 DO THIS —** Inspected current PAM stack and package availability.

**⭐ EASIEST WAY — Terminal command(s):**

~~~bash
dpkg-query -W libpam-pwquality libpam-modules libpam-runtime 2>/dev/null
sudo grep -nEv '^[[:space:]]*(#|$)' /etc/pam.d/common-password /etc/pam.d/common-auth
grep -E '^[[:space:]]*PASS_(MAX|MIN|WARN)' /etc/login.defs
~~~

> [!NOTE]
> **🧠 Interpretation:** PAM is order-sensitive. A duplicated \`pam_unix.so\`, unsuitable control flag, or unavailable module can lock out every user. \`/etc/login.defs\` supplies defaults for some tools; it does **not** automatically change every existing account's expiry settings.

**Read one existing user's actual policy (replace username):**

~~~bash
sudo chage -l exampleuser
~~~

If changing aging is required, consult the policy specified in the README and the [Mint checklist](linux-mint.md#3-password-and-lockout-policy) for \`chage\` examples.

> [!CAUTION]
> **🛑 Before edits:** Preserve backups of \`/etc/pam.d/common-password\`, \`common-auth\` and the relevant original config, plus working console/root access. When available, use distribution-maintained \`pam-auth-update\` rather than inventing a new stack.

**✅ Verification:** Before logging out, test authentication in a *new local or console session* as an authorized ordinary user and verify an authorized sudo elevation. Never intentionally force a logout while authentication is unverified.

**Recovery:** Restore the specific original PAM file using recovery/console access, then retest. This is a high-risk category and should not be changed merely because a generic checklist recommends a number.

##### L4. Check scheduled persistence in cron and systemd

- [ ] **🎯 DO THIS —** Investigated scheduler entries before deleting anything.

**⭐ EASIEST WAY — Terminal command(s):**

~~~bash
sudo cat /etc/crontab
sudo ls -la /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly
sudo crontab -l
~~~

The last command shows root's crontab because of \`sudo\`. To inspect one authorized user's crontab:

~~~bash
sudo crontab -u exampleuser -l
~~~

**Inspect enabled and currently active units:**

~~~bash
systemctl list-unit-files --type=service --state=enabled
systemctl list-timers --all
systemctl --failed
~~~

**Inspect where a particular unit comes from (replace the name):**

~~~bash
systemctl cat example.service
systemctl show example.service -p FragmentPath -p ExecStart -p User -p WantedBy
~~~

> [!NOTE]
> **What to look for:** Unexpected execution from writable directories, shell commands launched as root, timers with misleading names, recent unexplained unit changes. A valid systemd service may be intentionally started through sockets or dependencies even when its service unit is disabled.

**✅ Verification:** Correlate any suspicious entry with \`journalctl -u example.service\`, ownership, file hashes, the README, and required software. Do not execute suspicious payloads.

**Recovery:** For an unauthorized entry, document and preserve it before making the smallest authorized change. To undo a previous disable operation, restore the recorded original unit enablement/state only; do not indiscriminately enable every listed service.

##### L5. Firewall: preserve required access before enabling UFW

- [ ] **🎯 DO THIS —** Identified real listeners, rule owner and permitted clients.

**⭐ EASIEST WAY — Terminal command(s):**

~~~bash
sudo ss -lntup
sudo ufw status verbose
sudo ufw status numbered
~~~

On hosts using \`nftables\` directly, inspect **before** adding UFW rules:

~~~bash
sudo nft list ruleset
~~~

> [!NOTE]
> **🧠 Interpretation:** A service on \`127.0.0.1\` is locally bound, while \`0.0.0.0\` or \`[::]\` may be externally reachable if network/firewall paths allow. A listening port is not automatically unnecessary.

**Before an approved UFW enablement:** Write down required SSH, HTTP/HTTPS, DNS, DHCP and other ports from the README; check the current remote-management path.

For an image requiring SSH on TCP 22, the specific allowance is:

~~~bash
sudo ufw allow 22/tcp
~~~

Only after verifying the required rules and retaining console access, if UFW is the chosen firewall:

~~~bash
sudo ufw enable
sudo ufw status verbose
~~~

**✅ Verify:** From an approved client, retest every README-required service and the management connection. \`ufw\` is a front end to Linux packet filtering and may coexist/conflict with other managers; do **not** reset \`iptables\`/\`nftables\` blindly.

**Recovery:** If you blocked access, use the VM console to restore the documented previous UFW state/rules; avoid deleting all firewall rules as a first response.

##### L6. Narrow file and package investigations

- [ ] **🎯 DO THIS —** Inspected evidence, not deleted files by extension alone.

~~~bash
sudo find /home /root /tmp /var/tmp -type f -mtime -2 -printf '%TY-%Tm-%Td %TH:%TM %u %m %p\n' 2>/dev/null
sudo find /home /root /tmp /var/tmp -type f -perm /0002 -ls 2>/dev/null
sudo find /usr/local/bin /usr/local/sbin -type f -perm /4000 -ls 2>/dev/null
~~~

> [!NOTE]
> **🧠 Interpretation:** These are *scoped searches*. They do not prove the rest of the file system is clean. World-writable and SUID files can be legitimate; an unusual entry requires review of owner, package and use.

~~~bash
dpkg -S /usr/bin/ssh 2>/dev/null
apt-cache policy openssh-server
grep -h ' install ' /var/log/dpkg.log* 2>/dev/null | tail -30
~~~

If \`dpkg -S\` reports no owning package for another path, investigate—some applications are legitimately installed outside dpkg.

**Final check:**

~~~bash
systemctl --failed
sudo ss -lntup
who
~~~

Confirm normal login, sudo, DNS/networking and all required services. Record any unverified concern rather than destroy unknown files.

##### References and cross-checks

- [Ubuntu 24.04 OpenSSH socket activation notes](https://documentation.ubuntu.com/release-notes/24.04/)
- [Ubuntu security: Unnecessarily open ports](https://documentation.ubuntu.com/security/common-mistakes/unnecessarily-open-ports/)
- [Ubuntu security: Firewalls](https://documentation.ubuntu.com/security/security-features/network/firewall/)
- CyberPatriot community topic inventories: [PeapGit CPLHF](https://github.com/PeapGit/cplhf) (historical hardening automation: **do not execute as part of this guide**), [Minagera Linux checklist](https://github.com/Minagera/CyberPatriot/blob/main/Checklists/Linux/README.md), [chessischess Linux checklist](https://github.com/chessischess/cyberpatriot-checklist/blob/master/Linux_Checklist.md).

---

### 22. Complete Linux terminal basics (embedded)

The original practical text and copyable command blocks are retained here for self-contained study. For a Debian image, use Debian-specific explanations in Sections 0–19 before changing a setting.

The **terminal** is a window where you type commands instead of clicking. On Linux most security work is faster in the terminal, and many settings can *only* be changed there.

**Open it:** press **Ctrl + Alt + T**, or open the menu and search for "Terminal".

##### How a command looks

```bash
id bob
```
- `id` = the command (show identity and group membership).
- `sudo` before a privileged command means run it with administrative authority; it normally asks for **your** password and does not echo it. This read-only example does not need it.
- `bob` = what to do it to.

Press **Enter** to run it. If it worked, Linux often prints **nothing**. Check the exit status and repeat the native verification; silence alone is not proof of success.

##### Keys that save time
| Key | What it does |
|---|---|
| **Tab** | Auto-complete a file or command name. Press it twice to see the choices. |
| **↑ / ↓** | Bring back earlier commands. |
| **Ctrl + C** | Stop the command that is running. |
| **Ctrl + Shift + C / V** | Copy / paste *inside the terminal* (plain Ctrl+C means "stop"!). |
| **q** | Quit a viewer like `less` or `man`. |

##### The 20 commands you'll actually use
| Command | What it does | Example |
|---|---|---|
| `pwd` | Show which folder you're in | `pwd` |
| `ls -la` | List files, including hidden ones (names starting with `.`) | `ls -la /home/bob` |
| `cd` | Go to a folder | `cd /etc` |
| `cat` | Print a file | `cat /etc/passwd` |
| `less` | Read a long file (q to quit, / to search) | `less /var/log/auth.log` |
| `nano` | Simple text editor (Ctrl+O save, Ctrl+X exit) | `sudo nano /etc/ssh/sshd_config` |
| `grep` | Find lines containing a word | `grep -i bob /etc/group` |
| `find` | Find files | `sudo find /home -iname "*.mp3"` |
| `rm` | Delete a file (no recycle bin!) | `sudo rm /home/bob/song.mp3` |
| `cp` | Copy | `sudo cp file file.bak` |
| `sudo` | Run as administrator | `sudo apt update` |
| `apt` | Install / remove / update software | `sudo apt purge nmap` |
| `systemctl` | Start / stop / check services | `systemctl status ssh` |
| `ss -tulpn` | Show what's listening on the network | `sudo ss -tulpn` |
| `ps aux` | Show running programs | `ps aux \| grep nc` |
| `id` | Show a user's groups | `id bob` |
| `passwd` | Change a password | `sudo passwd bob` |
| `chmod` / `chown` | Change permissions / owner | `sudo chmod 640 /etc/shadow` |
| `history` | Show your past commands | `history` |
| `man` | The manual for a command | `man userdel` |

##### Reading permissions
```
-rw-r----- 1 root shadow 1234 Oct 22 10:00 /etc/shadow
 ^^^ owner can read+write
    ^^^ group can read
       ^^^ others: nothing
```
Numbers: r=4, w=2, x=1. So `640` = owner rw (6), group r (4), others none (0).

##### Paths you'll see a lot
| Path | What's there |
|---|---|
| `/etc/` | Settings files for almost everything |
| `/home/<user>/` | Each user's files (Desktop, Documents, Downloads...) |
| `/var/log/` | Log files |
| `/tmp/` | Temporary files (attackers like hiding things here) |
| `/root/` | The root user's home folder |

##### Safety tips
- **Read the command before pressing Enter**, especially anything with `rm`.
- Before editing a settings file, **copy it**: `sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak`
- If a command asks `[Y/n]`, read what it's about to remove before answering.
- Recovery depends on the operation. Record values/backups before changes; deletion and credential changes may have no simple undo.

##### Practice a safe inspect–edit–verify–undo cycle

- [ ] **🎯 DO THIS — Practice a safe inspect–edit–verify–undo cycle**

> [!NOTE]
> **🎯 What:** Learn quoting, exit status, file editing and recovery on a harmless private practice file.

> [!NOTE]
> **💡 Why it matters:** Commands act on exact paths; spaces, shell wildcards and redirection change their meaning. A blank result is not proof of success.

> [!CAUTION]
> **🛑 Before changing anything:** Use a normal user's terminal on a permitted practice image. These commands do not need sudo. Do not use a real security configuration for your first editing exercise.

**⭐ EASIEST WAY — GUI (when available):** Open **Terminal** from the desktop menu. Open the file manager alongside it and compare your home directory with `pwd` and `ls -la`. In a terminal, **Ctrl+Shift+V** pastes; inspect the whole pasted line before Enter.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> pwd
> mkdir -m 700 "$HOME/cp-terminal-practice"
> ```
>
If the directory exists, inspect it instead of overwriting existing work. Create a harmless file:

```bash
printf '%s\n' 'original value' > "$HOME/cp-terminal-practice/example notes.txt"
```

Double quotes keep the path with spaces together; `$HOME` expands to your home folder. Single quotes keep text literal. `>` overwrites a file; `>>` appends. Neither belongs in a command unless you intend a write.

> [!NOTE]
> **🔁 Alternate (optional) — Terminal:**
>
>
> ```bash
> cp -p "$HOME/cp-terminal-practice/example notes.txt" "$HOME/cp-terminal-practice/example notes.txt.before"
> nano "$HOME/cp-terminal-practice/example notes.txt"
> ```
>
Change the text, **Ctrl+O → Enter** to save, **Ctrl+X** to leave. Use `command --help` or `man command` to inspect options; press `q` to leave a manual. A leading `#` in handbook prose is not a command prompt to paste.

**✅ Check it worked:**

```bash
cat "$HOME/cp-terminal-practice/example notes.txt"
echo "$?"
```

`$?` is the previous command's exit status: usually 0 means success; nonzero needs interpretation. For `grep`, 1 means no match, while 2 commonly means an error. Check immediately; any intervening command changes `$?`. `&&` runs the next command only after success, but a beginner should inspect commands individually first.

> [!WARNING]
> **↩️ Undo:**

```bash
cp -p "$HOME/cp-terminal-practice/example notes.txt.before" "$HOME/cp-terminal-practice/example notes.txt"
cat "$HOME/cp-terminal-practice/example notes.txt"
```

Expect `original value`. Practice files may be removed through the file manager after you have checked their paths.

> [!CAUTION]
> **⚠️ Warnings:** `sudo command > /protected/file` elevates the command, not the shell opening the file. Do not solve permission errors with `chmod 777`. Avoid `rm -rf`, guessed wildcards, copied shell prompts and piping downloads into a shell. **Ctrl+C** is appropriate for a stuck search, but interrupting package configuration or file writes can leave incomplete work.

---

<a id="stage-6"></a>
## Part 6 — Final Verification

> [!TIP]
> ✅ **Finish strong:** Verify the final configuration, required functionality, and saved evidence.

Check required functions, users, services, firewall, score and forensic evidence before concluding.

### 18. Final checks

- [ ] **🎯 DO THIS —** Every critical service is running: `systemctl status ssh` (repeat with each service the README lists)
- [ ] **🎯 DO THIS —** You can still use `sudo`
- [ ] **🎯 DO THIS —** The Scoring Report shows **no penalties**
- [ ] **🎯 DO THIS —** All forensics answers are saved
- [ ] **🎯 DO THIS —** Take a final snapshot
- [ ] **🎯 DO THIS —** **Don't reboot** unless you need to. If you must, reboot once and check everything still works.
