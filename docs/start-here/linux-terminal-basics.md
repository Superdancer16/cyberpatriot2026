# Linux terminal basics

The **terminal** is a window where you type commands instead of clicking. On Linux most security work is faster in the terminal, and many settings can *only* be changed there.

**Open it:** press **Ctrl + Alt + T**, or open the menu and search for "Terminal".

## How a command looks

```bash
id bob
```
- `id` = the command (show identity and group membership).
- `sudo` before a privileged command means run it with administrative authority; it normally asks for **your** password and does not echo it. This read-only example does not need it.
- `bob` = what to do it to.

Press **Enter** to run it. If it worked, Linux often prints **nothing**. Check the exit status and repeat the native verification; silence alone is not proof of success.

## Keys that save time
| Key | What it does |
|---|---|
| **Tab** | Auto-complete a file or command name. Press it twice to see the choices. |
| **↑ / ↓** | Bring back earlier commands. |
| **Ctrl + C** | Stop the command that is running. |
| **Ctrl + Shift + C / V** | Copy / paste *inside the terminal* (plain Ctrl+C means "stop"!). |
| **q** | Quit a viewer like `less` or `man`. |

## The 20 commands you'll actually use
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

## Reading permissions
```
-rw-r----- 1 root shadow 1234 Oct 22 10:00 /etc/shadow
 ^^^ owner can read+write
    ^^^ group can read
       ^^^ others: nothing
```
Numbers: r=4, w=2, x=1. So `640` = owner rw (6), group r (4), others none (0).

## Paths you'll see a lot
| Path | What's there |
|---|---|
| `/etc/` | Settings files for almost everything |
| `/home/<user>/` | Each user's files (Desktop, Documents, Downloads...) |
| `/var/log/` | Log files |
| `/tmp/` | Temporary files (attackers like hiding things here) |
| `/root/` | The root user's home folder |

## Safety tips
- **Read the command before pressing Enter**, especially anything with `rm`.
- Before editing a settings file, **copy it**: `sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak`
- If a command asks `[Y/n]`, read what it's about to remove before answering.
- Recovery depends on the operation. Record values/backups before changes; deletion and credential changes may have no simple undo.

## Practice a safe inspect–edit–verify–undo cycle

- [ ] Done

**What:** Learn quoting, exit status, file editing and recovery on a harmless private practice file.

**Why it matters:** Commands act on exact paths; spaces, shell wildcards and redirection change their meaning. A blank result is not proof of success.

**Before changing anything:** Use a normal user's terminal on a permitted practice image. These commands do not need sudo. Do not use a real security configuration for your first editing exercise.

**Clicking (GUI):** Open **Terminal** from the desktop menu. Open the file manager alongside it and compare your home directory with `pwd` and `ls -la`. In a terminal, **Ctrl+Shift+V** pastes; inspect the whole pasted line before Enter.

**Typing (check/create):**

```bash
pwd
mkdir -m 700 "$HOME/cp-terminal-practice"
```

If the directory exists, inspect it instead of overwriting existing work. Create a harmless file:

```bash
printf '%s\n' 'original value' > "$HOME/cp-terminal-practice/example notes.txt"
```

Double quotes keep the path with spaces together; `$HOME` expands to your home folder. Single quotes keep text literal. `>` overwrites a file; `>>` appends. Neither belongs in a command unless you intend a write.

**Typing (edit):**

```bash
cp -p "$HOME/cp-terminal-practice/example notes.txt" "$HOME/cp-terminal-practice/example notes.txt.before"
nano "$HOME/cp-terminal-practice/example notes.txt"
```

Change the text, **Ctrl+O → Enter** to save, **Ctrl+X** to leave. Use `command --help` or `man command` to inspect options; press `q` to leave a manual. A leading `#` in handbook prose is not a command prompt to paste.

**Check it worked:**

```bash
cat "$HOME/cp-terminal-practice/example notes.txt"
echo "$?"
```

`$?` is the previous command's exit status: usually 0 means success; nonzero needs interpretation. For `grep`, 1 means no match, while 2 commonly means an error. Check immediately; any intervening command changes `$?`. `&&` runs the next command only after success, but a beginner should inspect commands individually first.

**Undo:**

```bash
cp -p "$HOME/cp-terminal-practice/example notes.txt.before" "$HOME/cp-terminal-practice/example notes.txt"
cat "$HOME/cp-terminal-practice/example notes.txt"
```

Expect `original value`. Practice files may be removed through the file manager after you have checked their paths.

**Warnings:** `sudo command > /protected/file` elevates the command, not the shell opening the file. Do not solve permission errors with `chmod 777`. Avoid `rm -rf`, guessed wildcards, copied shell prompts and piping downloads into a shell. **Ctrl+C** is appropriate for a stuck search, but interrupting package configuration or file writes can leave incomplete work.
