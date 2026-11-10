# Linux critical service hardening

When the README says a service **must keep working**, you don't remove it. You make it **safer**. This guide covers the services that appear most often on Mint, Debian and Ubuntu images.

> [!IMPORTANT]
> Rules for every service:
> 1. **Back up the config file first:** `sudo cp file file.bak`
> 2. **Test the config** before restarting (each section shows the test command).
> 3. **Check the service still works** after restarting: `systemctl status <name>`. If it's red or "failed", restore the backup.
> 4. **Check the Scoring Report.** If the score dropped, undo your last change.

Use the per-service manual procedures below for every installed required service. No automation is included in this repository.

---

## Safe service editing workflow

All commands here are for a **terminal on Ubuntu, Linux Mint or Debian**, using `sudo` for privileged operations. They are written individually so you can inspect the result before the next command. They are not commands to run on this handbook's development workspace. For FreeBSD use its [own checklist](../checklists/freebsd.md); packages generally configure under `/usr/local/etc` and use rc services.

Before every service change: read the README, identify its package/unit, record a working client test, preserve evidence, and keep console access. A package can be absent without being a vulnerability. Do not install an unnecessary server just to complete a checklist. Replace all example site, share, user and network names with the image's actual values.

For a config edit, `sudo cp -a` preserves metadata. Use a unique backup suffix if `.before-cp` already exists. In `nano`, **Ctrl+W** searches, **Ctrl+O → Enter** saves, **Ctrl+X** exits. Edit existing directives in their correct section instead of appending contradictory copies. Check included files and per-site overrides. A successful syntax check does not prove client access works.

If a service fails: read `systemctl status` and `journalctl -u UNIT -n 50 --no-pager`, restore the edited file, recheck syntax, then reload/restart. Do not purge and reinstall as a first repair.


## Apache web server (`apache2`)

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

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Apache web server (`apache2`) without removing the required service.

**Why it matters:** These reduce version disclosure and disable TRACE; they do not replace patching. Check each enabled site for Options Indexes and remove only Indexes if browsing is not required.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' apache2
systemctl status apache2 --no-pager
systemctl cat apache2
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Open the required site in Firefox. There is no standard desktop GUI for Apache configuration; use the editor commands below.

**Typing (check and backup):** Main configuration: `/etc/apache2/conf-available/security.conf`. First preserve it:

```bash
sudo cp -a /etc/apache2/conf-available/security.conf /etc/apache2/conf-available/security.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/apache2/conf-available/security.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
ServerTokens Prod
ServerSignature Off
TraceEnable Off
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo apache2ctl configtest
```

Expected: Syntax OK. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload apache2
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status apache2 --no-pager
sudo journalctl -u apache2 -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
curl -I http://127.0.0.1/
```

Expected: An expected HTTP status and working required page; a redirect or authenticated response can be legitimate. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/apache2/conf-available/security.conf.before-cp /etc/apache2/conf-available/security.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## Nginx web server

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

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Nginx web server without removing the required service.

**Why it matters:** Place server_tokens inside the existing http block. In the actual site block inspect autoindex off; and avoid changing proxy_pass or document roots blindly.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' nginx
systemctl status nginx --no-pager
systemctl cat nginx
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Open the required site in a browser and compare with the baseline. Use a terminal editor for server settings.

**Typing (check and backup):** Main configuration: `/etc/nginx/nginx.conf`. First preserve it:

```bash
sudo cp -a /etc/nginx/nginx.conf /etc/nginx/nginx.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/nginx/nginx.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
server_tokens off;
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo nginx -t
```

Expected: syntax is ok and test is successful. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload nginx
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status nginx --no-pager
sudo journalctl -u nginx -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
curl -I http://127.0.0.1/
```

Expected: The required site still loads. For a virtual host, repeat with its real hostname; localhost alone can select the wrong site. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/nginx/nginx.conf.before-cp /etc/nginx/nginx.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## PHP (used by the website)

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

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed PHP (used by the website) without removing the required service.

**Why it matters:** Identify the active version and SAPI before editing: php --ini shows CLI settings, not necessarily Apache or FPM. Typical web files are /etc/php/8.2/apache2/php.ini or /etc/php/8.2/fpm/php.ini; discover the actual path. Do not add these lines to a directory.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' php-common
systemctl status apache2 --no-pager
systemctl cat apache2
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use the web application in a browser. Do not expose phpinfo publicly to inspect settings.

**Typing (check and backup):** Main configuration: `/etc/php`. First preserve it:

```bash
sudo cp -a /etc/php /etc/php.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo find /etc/php -maxdepth 3 -name php.ini -print
# Open the discovered web SAPI file, for example:
sudo nano /etc/php/8.2/apache2/php.ini
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
display_errors = Off
log_errors = On
expose_php = Off
allow_url_include = Off
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
php -l /var/www/html/index.php
```

Expected: No syntax errors detected (this checks that PHP source file, not web php.ini). If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload apache2
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status apache2 --no-pager
sudo journalctl -u apache2 -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
curl -I http://127.0.0.1/
```

Expected: The application still signs in and performs a normal permitted operation; check its error log. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/php.before-cp/. /etc/php/
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## MySQL / MariaDB

### Built-in hardening tool
```bash
sudo mysql_secure_installation
```
Answer **yes** to: remove anonymous users, disallow root login remotely, remove the test database, reload privileges.

### Settings file
`/etc/mysql/mysql.conf.d/mysqld.cnf` (MySQL) or `/etc/mysql/mariadb.conf.d/50-server.cnf` (MariaDB), under `[mysqld]`:
```
bind-address = 127.0.0.1      # only this computer can connect (skip if the README says others connect)
local_infile = 0              # SQL can't read files from the server's disk
```
```bash
sudo systemctl restart mysql      # or mariadb
```

### Look at the database users
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

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed MySQL / MariaDB without removing the required service.

**Why it matters:** Edit the existing mysqld section rather than creating duplicates. Loopback binding is appropriate only for local clients. MySQL uses mysql-server, unit mysql and usually /etc/mysql/mysql.conf.d/mysqld.cnf; substitute all three if that is installed. Preserve Unix-socket root authentication.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' mariadb-server
systemctl status mariadb --no-pager
systemctl cat mariadb
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** If a trusted database client is already installed, inspect user/grant screens without deleting accounts. No generic desktop control panel exists.

**Typing (check and backup):** Main configuration: `/etc/mysql/mariadb.conf.d/50-server.cnf`. First preserve it:

```bash
sudo cp -a /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
[mysqld]
bind-address = 127.0.0.1
local_infile = 0
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo mariadbd --help --verbose > /dev/null
```

Expected: Exit status 0; this is a preliminary option parse, not a complete live validation. If the validation fails, do not continue. When correct:

```bash
sudo systemctl restart mariadb
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status mariadb --no-pager
sudo journalctl -u mariadb -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo mariadb -e "SELECT VERSION(); SHOW VARIABLES LIKE 'bind_address'; SHOW VARIABLES LIKE 'local_infile';"
```

Expected: Version output and expected variable values; also test the application with its own database credentials. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/mysql/mariadb.conf.d/50-server.cnf.before-cp /etc/mysql/mariadb.conf.d/50-server.cnf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## vsftpd (FTP server)

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

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed vsftpd (FTP server) without removing the required service.

**Why it matters:** Retain anonymous read access only if required. If chroot_local_user=YES, use a root-owned, non-writable jail root and a separate user-writable upload directory. Enable TLS only with an installed valid certificate and compatible required clients.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' vsftpd
systemctl status vsftpd --no-pager
systemctl cat vsftpd
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use a trusted FTP client if installed; test the actual server name, authentication and TLS behavior.

**Typing (check and backup):** Main configuration: `/etc/vsftpd.conf`. First preserve it:

```bash
sudo cp -a /etc/vsftpd.conf /etc/vsftpd.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/vsftpd.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
anonymous_enable=NO
anon_upload_enable=NO
xferlog_enable=YES
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo grep -nE "anonymous_enable|anon_upload_enable|chroot|ssl_enable|rsa_cert|pasv_" /etc/vsftpd.conf
```

Expected: Review each setting manually; vsftpd has no portable standalone syntax-test flag. If the validation fails, do not continue. When correct:

```bash
sudo systemctl restart vsftpd
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status vsftpd --no-pager
sudo journalctl -u vsftpd -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo ss -ltnp | grep ":21 "
```

Expected: An FTP listener on the intended address; then log in and transfer an allowed test file with the required client. Port 21 alone does not verify passive data transfers. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/vsftpd.conf.before-cp /etc/vsftpd.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## ProFTPD
In `/etc/proftpd/proftpd.conf`: `DefaultRoot ~`, `RootLogin off`, `ServerIdent off`, and comment out (`#`) the whole `<Anonymous ~ftp> ... </Anonymous>` block. Test with `sudo proftpd -t`.

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed ProFTPD without removing the required service.

**Why it matters:** Disable only an unauthorized Anonymous block and review Include files. DefaultRoot confines users to their home directory; verify necessary shared directories remain accessible.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' proftpd-core
systemctl status proftpd --no-pager
systemctl cat proftpd
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use the required FTP client and inspect the connection log for TLS or permission errors.

**Typing (check and backup):** Main configuration: `/etc/proftpd/proftpd.conf`. First preserve it:

```bash
sudo cp -a /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/proftpd/proftpd.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
DefaultRoot ~
RootLogin off
ServerIdent off
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo proftpd -t
```

Expected: Syntax check complete. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload proftpd
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status proftpd --no-pager
sudo journalctl -u proftpd -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo ss -ltnp | grep ":21 "
```

Expected: Listener remains and an authorized client can list and transfer in its intended directory. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/proftpd/proftpd.conf.before-cp /etc/proftpd/proftpd.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## Pure-FTPd
```bash
echo yes | sudo tee /etc/pure-ftpd/conf/NoAnonymous
echo yes | sudo tee /etc/pure-ftpd/conf/ChrootEveryone
sudo systemctl restart pure-ftpd
```

---

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Pure-FTPd without removing the required service.

**Why it matters:** These are separate filename/value pairs, not lines for one configuration file: edit /etc/pure-ftpd/conf/NoAnonymous and /etc/pure-ftpd/conf/ChrootEveryone to contain yes. Preserve anonymous access when explicitly required.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' pure-ftpd
systemctl status pure-ftpd --no-pager
systemctl cat pure-ftpd
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use the required FTP client; no standard desktop GUI edits the Debian wrapper files.

**Typing (check and backup):** Main configuration: `/etc/pure-ftpd/conf`. First preserve it:

```bash
sudo cp -a /etc/pure-ftpd/conf /etc/pure-ftpd/conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/pure-ftpd/conf/NoAnonymous
sudo nano /etc/pure-ftpd/conf/ChrootEveryone
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
NoAnonymous: yes
ChrootEveryone: yes
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo pure-ftpd-wrapper --show-options
```

Expected: Inspect generated options; this does not start a server or guarantee runtime validity. If the validation fails, do not continue. When correct:

```bash
sudo systemctl restart pure-ftpd
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status pure-ftpd --no-pager
sudo journalctl -u pure-ftpd -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo ss -ltnp | grep ":21 "
```

Expected: Listener present and authorized FTP login and data transfer work. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/pure-ftpd/conf.before-cp/. /etc/pure-ftpd/conf/
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## Samba (Windows file sharing)

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

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Samba (Windows file sharing) without removing the required service.

**Why it matters:** Edit the existing global section. In each required share inspect guest ok, valid users, read only and path. Guest access can be an explicit scenario requirement. Preserve directory ownership and Unix group permissions.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' samba
systemctl status smbd --no-pager
systemctl cat smbd
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** On Windows use File Explorer with \\server\share, or Linux Files → Other Locations → smb://server/share. Test read/write as the required ordinary user.

**Typing (check and backup):** Main configuration: `/etc/samba/smb.conf`. First preserve it:

```bash
sudo cp -a /etc/samba/smb.conf /etc/samba/smb.conf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/samba/smb.conf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
[global]
   map to guest = never
   usershare allow guests = no
   server min protocol = SMB2
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo testparm -s
```

Expected: Loaded services file OK; warnings still need review. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload smbd
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status smbd --no-pager
sudo journalctl -u smbd -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo smbclient -L localhost -U alice
```

Expected: Authorized share list; supply the password interactively and use a real authorized Samba account. smbclient may not be installed; use an existing Windows client instead. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/samba/smb.conf.before-cp /etc/samba/smb.conf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## BIND DNS server

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

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed BIND DNS server without removing the required service.

**Why it matters:** Merge into the existing options block; do not create a second block. Replace localnets with explicit approved networks where practical. Required secondary DNS servers need an explicit allow-transfer ACL, preferably TSIG; none would break transfers. Inspect zone-level overrides.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' bind9
systemctl status named --no-pager
systemctl cat named
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use client network settings to confirm the expected DNS server; edit BIND through the terminal.

**Typing (check and backup):** Main configuration: `/etc/bind/named.conf.options`. First preserve it:

```bash
sudo cp -a /etc/bind/named.conf.options /etc/bind/named.conf.options.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/bind/named.conf.options
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
options {
    allow-recursion { localhost; localnets; };
    allow-transfer { none; };
};
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo named-checkconf
```

Expected: No output and exit 0; separately run named-checkzone for every edited zone. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload named
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status named --no-pager
sudo journalctl -u named -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
dig @127.0.0.1 example.org
```

Expected: Expected answer/status for a real required zone; also test an authorized remote client and any required secondary server. An authoritative-only server may correctly refuse unrelated recursion. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/bind/named.conf.options.before-cp /etc/bind/named.conf.options
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## Postfix mail server

```bash
sudo postconf -e 'disable_vrfy_command = yes'        # can't ask "does user X exist?"
sudo postconf -e 'smtpd_helo_required = yes'
sudo postconf -e 'smtpd_banner = $myhostname ESMTP'  # hide the version
postconf mynetworks                                  # must NOT contain 0.0.0.0/0 (open relay)
sudo postfix check && sudo systemctl reload postfix
```

---

### Manual procedure: inspect, change, verify and recover

- [ ] Done

**What:** Configure the installed Postfix mail server without removing the required service.

**Why it matters:** These reduce user enumeration and require a proper SMTP greeting. Inspect mynetworks and smtpd_relay_restrictions: never trust 0.0.0.0/0 or ::/0. Preserve approved relay networks, local destinations and authenticated submission.

**Before changing anything:** Identify the required clients and test one working transaction. Check package and service in a terminal:

```bash
dpkg-query -W -f='${binary:Package} ${Status} ${Version}\n' postfix
systemctl status postfix --no-pager
systemctl cat postfix
```

`install ok installed` establishes package installation; `active (running)` normally means the daemon is running. Some wrapper/oneshot units show `active (exited)`; inspect the actual daemon too. A missing unit requires checking package documentation, not guessing another service to stop.

**Clicking (GUI):** Use an already configured local mail client if permitted; no general desktop GUI safely edits relay policy.

**Typing (check and backup):** Main configuration: `/etc/postfix/main.cf`. First preserve it:

```bash
sudo cp -a /etc/postfix/main.cf /etc/postfix/main.cf.before-cp
```

Inspect includes and record the current relevant values. If the backup already exists, choose a new suffix. A backup directory copy must be checked before relying on it.

**Typing (fix, only when appropriate):** Open the actual file(s):

```bash
sudo nano /etc/postfix/main.cf
```

Inspect these directives in their appropriate context (configuration text, not shell commands):

```text
disable_vrfy_command = yes
smtpd_helo_required = yes
```

Do not replace the whole file with this excerpt. Validate before applying:

```bash
sudo postfix check
```

Expected: No diagnostics; warnings require review. If the validation fails, do not continue. When correct:

```bash
sudo systemctl reload postfix
```

A reload generally preserves existing connections; a restart interrupts them. Confirm a service-specific reload is supported before substituting it.

**Check it worked:**

```bash
systemctl status postfix --no-pager
sudo journalctl -u postfix -n 30 --no-pager
```

Then perform a protocol-level check:

```bash
sudo postconf mynetworks smtpd_relay_restrictions mydestination
```

Expected: Only expected trusted networks/destinations; perform an authorized local delivery test and inspect mail logs. Do not send test messages to real third parties. If the client utility is absent, use an existing authorized client rather than installing a new server. Check firewall source/port allowances as well as local configuration.

**Undo:** Restore only the files changed in this procedure from the recorded backup:

```bash
sudo cp -a /etc/postfix/main.cf.before-cp /etc/postfix/main.cf
```

Repeat the same validation, apply command and client test. For a directory backup, copying back does not remove newly added files: remove only the specific new file you created after reviewing its contents. Database account/grant changes and web application data require their own backups; configuration restoration does not reverse them.

**Warnings and troubleshooting:** Inspect the first error in the unit journal. Check permissions, included configuration, address conflicts and required credentials. Never disable the firewall, drop a database, remove all shares or reinstall the service to hide one error.

## SSH
See section 9 of the [Linux Mint checklist](../checklists/linux-mint.md#9-ssh-server-only-if-installed).

---

## WordPress (and other web apps)
- Update WordPress, plugins and themes from the admin dashboard.
- Delete admin accounts in WordPress that the README doesn't list (**Users** page).
- In `wp-config.php`, add `define('DISALLOW_FILE_EDIT', true);` so the dashboard can't edit PHP files.
- Make sure `wp-config.php` isn't readable by everyone: `sudo chmod 640 wp-config.php`.

## PostgreSQL: local and required remote database access

- [ ] Done

**What:** Inspect PostgreSQL listening addresses, client authentication and database roles.

**Why it matters:** `trust` authentication can let a connecting client impersonate database users without a password. An overly restrictive listener can break a required web application on another machine.

**Before changing anything:** In a Linux terminal run:

```bash
dpkg-query -W postgresql postgresql-common
pg_lsclusters
```

`pg_lsclusters` lists version, cluster, port, status and data/log directories. The generic `postgresql.service` can be `active (exited)` while a cluster is down; inspect the listed cluster. Connect locally:

```bash
sudo -u postgres psql -c 'SHOW config_file;' -c 'SHOW hba_file;' -c 'SHOW listen_addresses;'
```

**Clicking (GUI):** Use a trusted installed database client to test the authorized account; do not use a superuser's successful connection as the ordinary client's test. There is no standard desktop GUI for these configuration files.

**Typing (check and backup):** Substitute the actual paths shown above. For version 15 cluster main:

```bash
sudo cp -a /etc/postgresql/15/main/postgresql.conf /etc/postgresql/15/main/postgresql.conf.before-cp
sudo cp -a /etc/postgresql/15/main/pg_hba.conf /etc/postgresql/15/main/pg_hba.conf.before-cp
```

**Typing (fix, only when appropriate):**

```bash
sudo nano /etc/postgresql/15/main/postgresql.conf
```

Inspect `listen_addresses = 'localhost'` for local-only clients. Required remote clients need the intended server address, not a blind wildcard. Then:

```bash
sudo nano /etc/postgresql/15/main/pg_hba.conf
```

Keep legitimate local peer authentication. Replace only an unauthorized `trust` rule with a compatible method. An example restricted remote rule is configuration text:

```text
host    appdb    appuser    192.168.10.0/24    scram-sha-256
```

First ensure that the role has a SCRAM password and clients support it. PostgreSQL uses the **first matching** HBA rule; a later secure rule does not override an earlier broad one.

**Typing (validate/apply):**

```bash
sudo -u postgres psql -c 'SELECT line_number,error FROM pg_hba_file_rules WHERE error IS NOT NULL;'
sudo -u postgres psql -c 'SELECT sourcefile,sourceline,name,error FROM pg_file_settings WHERE error IS NOT NULL;'
```

No error rows is expected, but these views do not replace client tests. Reload HBA-only changes:

```bash
sudo -u postgres psql -c 'SELECT pg_reload_conf();'
```

Listener changes require a scheduled cluster restart, for this example:

```bash
sudo pg_ctlcluster 15 main restart
```

**Check it worked:** Run `pg_lsclusters`, re-query settings and test the real application as its database role. In `psql`, `\du` lists roles; inspect unexpected superuser, create-role or replication privileges. Do not put passwords on the shell command line.

**Undo:** Restore the two original files, validate them again, reload or restart according to which setting changed, and repeat the client test. Restore role credentials/grants separately if they changed.

**Warnings:** A config backup is not a database backup. Do not drop roles or databases until ownership, application dependencies and forensics are resolved.

## ISC DHCP and Kea: identify the implementation first

- [ ] Done

**What:** Keep required address allocation working while removing unauthorized scope or gateway settings.

**Why it matters:** A wrong DHCP router or DNS option can disconnect every client even though the daemon is running.

**Before changing anything:** Terminal checks:

```bash
dpkg-query -W isc-dhcp-server kea-dhcp4-server
systemctl status isc-dhcp-server kea-dhcp4-server --no-pager
ip -br address
```

A not-installed result is normal. Determine which implementation owns UDP 67 with `sudo ss -lunp`. Do not start a second DHCP server on the same lab network.

**Clicking (GUI):** On a test client, open network settings and record its lease address, mask, router and DNS servers. A server GUI is not generally provided.

**Typing (check and backup):** ISC uses `/etc/dhcp/dhcpd.conf` and `/etc/default/isc-dhcp-server`. Kea normally uses `/etc/kea/kea-dhcp4.conf`. For the installed ISC example:

```bash
sudo cp -a /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.before-cp
sudo cp -a /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.before-cp
sudo nano /etc/dhcp/dhcpd.conf
```

**Typing (fix, only when appropriate):** In the existing `subnet ... netmask ... {}` block, inspect `range`, `option routers`, and `option domain-name-servers`. The range must belong to the subnet and exclude static server addresses. In `/etc/default/isc-dhcp-server`, `INTERFACESv4` must name the intended lab-facing interface. Keep relay requirements.

**Typing (validate/apply):**

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

Only after a successful test:

```bash
sudo systemctl restart isc-dhcp-server
```

For installed Kea instead, back up its JSON file, edit the existing `Dhcp4` → `subnet4`, `pools`, `option-data` and `interfaces-config` settings; preserve JSON types and validate:

```bash
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

Then restart `kea-dhcp4-server` only after success. Do not apply ISC syntax to Kea.

**Check it worked:** Inspect unit status/journal and renew a noncritical authorized test client's lease through its network GUI. Verify assigned address, gateway, DNS and access to a required internal hostname. A listening UDP socket alone is insufficient.

**Undo:** Restore the changed file(s), validate with the same implementation's command and restart that unit. Do not delete the lease database to repair a syntax error.

**Warnings:** ISC DHCP is a legacy implementation; preserve the scenario's installed server rather than migrating implementations during a timed round. Do not renew your only remote-management client's lease until console access exists.

## Web application files and certificates

- [ ] Done

**What:** Preserve required application behavior while checking secrets, writable directories and TLS.

**Why it matters:** Removing a file because it contains `eval` or `exec` can destroy legitimate code; a web shell may also use neither string.

**Before changing anything:** Back up the application, database and virtual-host config separately. Identify the web worker account and required write directories. Do not put backups containing credentials in the web root.

**Clicking (GUI):** In the application's admin panel review users, plugins, themes and supported updates. In a browser inspect the certificate hostname, expiry and chain for the actual required HTTPS hostname.

**Typing (check):**

```bash
sudo find /var/www -xdev -type f -mtime -7 -ls
sudo find /var/www -xdev -type f -perm -0002 -ls
sudo stat /var/www/html/wp-config.php
```

Unexpected recent or world-writable files need comparison with a trusted package/application baseline. Do not run suspicious PHP files or publish configuration secrets.

**Typing (fix, only when appropriate):** For WordPress, use the editor on the actual `wp-config.php` and add `define('DISALLOW_FILE_EDIT', true);` only once before the final stop-editing comment. Set ownership/group so only the actual administrator and web worker can read credentials; `chmod 640` alone is not sufficient if the group is wrong. Update through supported application mechanisms after backup.

**Check it worked:** Test login, static pages, uploads if required, database access and HTTPS from the intended client. Inspect application/server logs without clearing them.

**Undo:** Restore the particular changed config or supported application/database backup. Restore compatible versions together; a database schema migration may not support file-only rollback.

**Warnings:** Headers, hidden version strings and disabled PHP functions are supporting controls, not proof an application is secure. Keep required functionality and patch vulnerabilities.
