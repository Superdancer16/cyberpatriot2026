#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
MODE=menu
CONFIG=
YES=0
ALLOW_REMOVALS=0
INIT=0
ONLY=
VERSION=1.0
STAMP=$(date +%Y%m%d-%H%M%S)
ROOT="${HOME}/DebianSecurityWork"
BACKUPS="$ROOT/backups-$STAMP"
LOG="$ROOT/changes-$STAMP.txt"
SUMMARY="$ROOT/summary-$STAMP.tsv"
REPORT="$ROOT/audit-$STAMP.txt"
SECTIONS=(discovery users groups passwords pam firewall updates services ssh kernel permissions software files persistence hosts desktop browsers apparmor logging serverapps verify)
usage() {
    printf '%s\n' 'Debian 12/13 one-run security helper' '  sudo bash debian.sh --audit' '  sudo bash debian.sh --init-config --config image-config.json' '  sudo bash debian.sh --apply --config image-config.json [--yes] [--allow-removals]' '  sudo bash debian.sh --apply --config image-config.json --only users,groups,ssh' '  --menu  --list  --help'
}
while (($#)); do
    case "$1" in
        --audit) MODE=audit ;;
        --apply) MODE=apply ;;
        --menu) MODE=menu ;;
        --init-config) INIT=1 ;;
        --config) [[ $# -gt 1 ]] || { echo 'Missing --config file' >&2; exit 2; }; CONFIG="$2"; shift ;;
        --only) [[ $# -gt 1 ]] || { echo 'Missing --only sections' >&2; exit 2; }; ONLY="$2"; shift ;;
        --yes) YES=1 ;;
        --allow-removals) ALLOW_REMOVALS=1 ;;
        --list) printf '%s\n' "${SECTIONS[@]}"; exit 0 ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    esac
    shift
done
[[ -f /etc/os-release ]] || { echo 'Missing /etc/os-release' >&2; exit 2; }
. /etc/os-release
[[ "${ID:-}" == debian ]] || { echo 'Only Debian is supported.' >&2; exit 2; }
[[ "${VERSION_ID:-}" == 12 || "${VERSION_ID:-}" == 13 ]] || { echo 'Only Debian 12/13 supported.' >&2; exit 2; }
command -v python3 >/dev/null || { echo 'Python 3 is required for JSON.' >&2; exit 2; }
if [[ "$MODE" == apply && $EUID -ne 0 ]]; then echo 'Run Apply with sudo.' >&2; exit 2; fi
mkdir -p "$BACKUPS"
chmod 700 "$ROOT" "$BACKUPS"
printf 'time\tstatus\ttask\n' > "$SUMMARY"
: > "$LOG"
log() { printf '%s %s\n' "$(date +'%F %T')" "$*" | tee -a "$LOG"; }
status() { printf '%s\t%s\t%s\n' "$(date +'%T')" "$1" "${2//$'\t'/ }" >> "$SUMMARY"; log "[$1] $2"; }
backup() {
    local src="$1" dest
    [[ -f "$src" && "$src" == /* ]] || return 0
    dest="$BACKUPS/originals$src"
    mkdir -p "$(dirname "$dest")"
    [[ -e "$dest" ]] || cp -a -- "$src" "$dest"
}
capture() {
    local title="$1"; shift
    local target="$BACKUPS/review-$title.txt"
    { printf '%s\n' "$title"; "$@"; } > "$target" 2>&1 || true
    status REVIEW "Inspection: $target"
}
change() {
    local name="$1"; shift
    if [[ "$MODE" == audit ]]; then status WOULD "$name"; return 0; fi
    if "$@"; then status CHANGED "$name"; else status FAILED "$name"; fi
}
safe_user() { [[ "$1" =~ ^[a-z_][a-z0-9_.-]*\$?$ && "$1" != root ]]; }
safe_group() { [[ "$1" =~ ^[a-z_][a-z0-9_.-]*\$?$ ]]; }
safe_unit() { [[ "$1" =~ ^[a-zA-Z0-9@_.-]+(\.service)?$ ]]; }
safe_pkg() { [[ "$1" =~ ^[a-z0-9][a-z0-9+.:~-]*$ ]]; }
member() { local item; for item in "${@:2}"; do [[ "$item" == "$1" ]] && return 0; done; return 1; }
cfg() {
    python3 - "$CONFIG" "$1" "$2" <<'PY'
import json,sys
obj=json.load(open(sys.argv[1],encoding="utf-8"))
for part in sys.argv[2].split("."): obj=obj.get(part) if isinstance(obj,dict) else None
mode=sys.argv[3]
if mode=="scalar":
    print(str(obj).lower() if isinstance(obj,bool) else ("" if obj is None else str(obj)))
elif mode=="list":
    if isinstance(obj,list):
        for v in obj: print(str(v))
elif mode=="pairs":
    if isinstance(obj,dict):
        for key,value in obj.items():
            if isinstance(value,list):
                for v in value: print(str(key)+"\t"+str(v))
            else: print(str(key)+"\t"+str(value))
elif mode=="records":
    if isinstance(obj,list):
        for value in obj:
            if isinstance(value,dict): print(str(value.get("User",""))+"\t"+str(value.get("Line","")))
PY
}
scalar() { cfg "$1" scalar; }
list() { cfg "$1" list; }
pairs() { cfg "$1" pairs; }
records() { cfg "$1" records; }
guard_removal() {
    if (( ! ALLOW_REMOVALS )); then status REVIEW "$1: add --allow-removals after review"; return 1; fi
    if [[ "$(scalar ForensicsComplete)" != true ]]; then status REVIEW "$1: forensics not marked complete"; return 1; fi
}
validate_config() {
    [[ -n "$CONFIG" && -f "$CONFIG" ]] || { echo 'Apply needs --config image-config.json' >&2; exit 2; }
    python3 - "$CONFIG" <<'PY'
import json,sys
c=json.load(open(sys.argv[1],encoding="utf-8"))
def err(s): raise SystemExit("Configuration error: "+s)
def scan(v):
    if isinstance(v,str) and any(ord(ch)<32 for ch in v): err("control character in a value")
    if isinstance(v,list):
        for x in v: scan(x)
    if isinstance(v,dict):
        for k,x in v.items(): scan(k); scan(x)
scan(c)
if c.get("ConfirmedReadme") is not True: err("read the image README and set ConfirmedReadme to true")
admins=c.get("AuthorizedAdmins",[])
if not isinstance(admins,list) or not admins: err("AuthorizedAdmins cannot be empty")
auth=set(admins+c.get("AuthorizedUsers",[]))
for n in c.get("RemoveUsers",[])+c.get("DisableUsers",[]):
    if n in auth: err("authorized user targeted: "+n)
for a,b in (("DisableServices","RequiredServices"),("RemovePackages","RequiredSoftware")):
    both=set(c.get(a,[]))&set(c.get(b,[]))
    if both: err("required item selected for removal: "+",".join(both))
PY
}
init_config() {
    local file="${CONFIG:-image-config.json}"
    [[ ! -e "$file" ]] || { echo "Refusing overwrite: $file" >&2; exit 2; }
    python3 - "$file" <<'PY'
import json,sys
c={
"ConfirmedReadme":False,"ForensicsComplete":False,
"AuthorizedAdmins":[],"AuthorizedUsers":[],"RequiredServices":[],"RequiredSoftware":[],"RequiredPorts":[],
"NewUsers":[],"DisableUsers":[],"RemoveUsers":[],"DemoteSudo":[],"SetPasswords":[],"ExpirePasswords":[],
"NewGroups":[],"GroupMembers":{},"RemoveGroupMembers":{},"PasswordAging":{},"UserAging":{},
"PasswordQuality":{},"RemovePAMNullok":False,
"EnableUFW":False,"InstallUFW":False,"FirewallAllowPorts":[],
"UpdatePackageLists":False,"UpgradePackages":False,"UpdatePackages":[],"EnableDailyUpdateRefresh":False,
"DisableServices":[],"EnableRequiredServices":False,"SSH":{"DisableRootLogin":False,"DisableEmptyPasswords":False},
"Sysctl":{},"FixShadowPermissions":False,"RemovePackages":[],"RemoveFiles":[],
"RemoveCronLines":[],"RemoveHostsLines":[],"DisableUnits":[],
"Desktop":{"DisableGdmAutologin":False},
"Browsers":{"ChromiumBlockPopups":False},
"AppArmorProfiles":[],"Logging":{"EnableAuditd":False,"EnableRsyslog":False},
"ServiceHardening":{"Apache":False,"Nginx":False,"VsftpdNoAnonymous":False,"SambaNoSMB1":False,"PostfixNoVRFY":False},
"ScanPaths":["/home","/tmp","/var/tmp"]
}
with open(sys.argv[1],"x",encoding="utf-8") as out: json.dump(c,out,indent=2); out.write("\n")
print("Created "+sys.argv[1]+". Complete it from the active image README.")
PY
}
audit() {
    {
        printf 'Debian security audit — %s\n' "$(date -Is)"
        printf 'Debian %s — %s — UID %s\n' "$VERSION_ID" "$(hostname)" "$EUID"
        for title in accounts admins uid0 aging pam firewall updates services ssh ports perms; do
            printf '\n### %s\n' "$title"
            case "$title" in
                accounts) getent passwd | awk -F: '$3>=1000&&$3<65534{print $1,$3,$6,$7}' ;;
                admins) getent group sudo ;;
                uid0) awk -F: '$3==0{print}' /etc/passwd ;;
                aging) grep '^PASS_' /etc/login.defs ;;
                pam) grep -nE 'pam_unix|pam_pwquality|pam_faillock|nullok' /etc/pam.d/common-{auth,password} ;;
                firewall) command -v ufw >/dev/null && ufw status verbose || true ;;
                updates) apt-mark showhold; apt list --upgradable 2>/dev/null | head -70 ;;
                services) systemctl --failed --no-pager; systemctl list-units --type=service --state=running --no-pager ;;
                ssh) command -v sshd >/dev/null && sshd -T 2>/dev/null | grep -E 'permitrootlogin|permitemptypasswords' || true ;;
                ports) ss -lntup | head -80 ;;
                perms) stat -c '%a %U:%G %n' /etc/{passwd,shadow,group,gshadow} ;;
            esac 2>&1 || true
        done
    } > "$REPORT"
    status OK "Audit saved: $REPORT"
}

is_authorized() {
    local candidate="$1" item
    while IFS= read -r item; do [[ "$candidate" == "$item" ]] && return 0; done < <(list AuthorizedAdmins)
    while IFS= read -r item; do [[ "$candidate" == "$item" ]] && return 0; done < <(list AuthorizedUsers)
    return 1
}
is_required_service() {
    local candidate="$1" item
    while IFS= read -r item; do [[ "$candidate" == "$item" ]] && return 0; done < <(list RequiredServices)
    return 1
}
is_required_package() {
    local candidate="$1" item
    while IFS= read -r item; do [[ "$candidate" == "$item" ]] && return 0; done < <(list RequiredSoftware)
    return 1
}
user_present() { getent passwd "$1" >/dev/null; }
group_present() { getent group "$1" >/dev/null; }
unit_present() { systemctl cat "$1" >/dev/null 2>&1; }
do_discovery() {
    capture 'root-cron' bash -c 'crontab -u root -l 2>/dev/null || true'
    capture 'scheduled-timers' systemctl list-timers --all --no-pager
    capture 'enabled-services' systemctl list-unit-files --state=enabled --no-pager
    capture 'sockets' ss -lntup
    capture 'shadow' stat -c '%a %U:%G %n' /etc/shadow /etc/gshadow
    capture 'sudo-policies' bash -c 'grep -RnE "NOPASSWD|!authenticate" /etc/sudoers /etc/sudoers.d 2>/dev/null || true'
    capture 'files-suid' bash -c 'find /usr /bin /sbin /opt -xdev -type f -perm /4000 -print 2>/dev/null | head -150'
    capture 'files-world-writable' bash -c 'find /etc /usr/local -xdev -type f -perm /0002 -print 2>/dev/null | head -150'
    capture 'systemd-overrides' systemctl list-unit-files --type=service --no-pager
    capture 'hosts' cat /etc/hosts
    capture 'installed-packages' bash -c 'dpkg-query -W -f="${binary:Package} ${Version}\n" 2>/dev/null || true'
    capture 'sshd-policy' bash -c 'command -v sshd >/dev/null && sshd -T 2>/dev/null | head -80 || true'
    capture 'apt-sources' bash -c 'grep -RHE "^(deb |URIs:|Suites:|Signed-By:|Trusted:)" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null || true'
    capture 'crontab-directories' bash -c 'ls -la /etc/cron.d /etc/cron.daily /var/spool/cron/crontabs 2>/dev/null || true'
    if [[ -n "$CONFIG" && -f "$CONFIG" ]]; then
        local dir name
        while IFS= read -r dir; do
            [[ -d "$dir" && "$dir" == /* && "$dir" != / ]] || continue
            case "$dir" in /etc|/usr|/lib|/var/lib) continue ;; esac
            name=$(printf '%s' "$dir" | tr '/ ' '__')
            local out="$BACKUPS/review-file-candidates-$name.txt"
            find "$dir" -xdev -type f \( -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.zip' -o -iname '*.pcap' -o -iname '*.torrent' -o -iname '*netcat*' \) -print 2>/dev/null | head -200 > "$out" || true
            status REVIEW "Candidate files (review manually): $out"
        done < <(list ScanPaths)
    fi
    status REVIEW 'Inspect nonstandard service binaries, startup scripts and user-level timers before making changes.'
}
do_users() {
    local name owner id
    while IFS= read -r name; do
        safe_user "$name" || { status SKIPPED "Invalid requested user: $name"; continue; }
        is_authorized "$name" || { status SKIPPED "New user $name not authorized in config"; continue; }
        if user_present "$name"; then status OK "Authorized user already exists: $name"; continue; fi
        if (( YES )); then status REVIEW "Create $name interactively: password is required and never saved in JSON"; continue; fi
        if [[ "$MODE" == audit ]]; then status WOULD "Create authorized user $name"; continue; fi
        if adduser --disabled-password --gecos '' "$name" && passwd "$name"; then
            status CHANGED "Created authorized user and password: $name"
        else
            status FAILED "Could not fully create $name; check lock state before proceeding"
        fi
    done < <(list NewUsers)
    while IFS= read -r name; do
        safe_user "$name" && user_present "$name" || { status REVIEW "Password target not found/invalid: $name"; continue; }
        is_authorized "$name" || { status SKIPPED "Password target not authorized: $name"; continue; }
        if (( YES )); then status REVIEW "Set $name password interactively; unattended run stores no secrets"; continue; fi
        change "Set password for $name" passwd "$name"
    done < <(list SetPasswords)
    while IFS= read -r name; do
        safe_user "$name" && user_present "$name" || { status REVIEW "Cannot expire password: $name"; continue; }
        is_authorized "$name" || { status SKIPPED "Password expiry not authorized: $name"; continue; }
        change "Require password change at next login: $name" chage -d 0 "$name"
    done < <(list ExpirePasswords)
    while IFS= read -r name; do
        safe_user "$name" && user_present "$name" || { status REVIEW "Cannot demote sudo account: $name"; continue; }
        if is_authorized "$name" && ! grep -qxF "$name" <(list AuthorizedUsers); then
            status SKIPPED "Only standard users listed in AuthorizedUsers can be demoted: $name"; continue
        fi
        if id -nG "$name" | tr ' ' '\n' | grep -qx sudo; then
            change "Remove unauthorized sudo membership from $name" gpasswd -d "$name" sudo
        else status OK "$name is not a sudo-group member"; fi
    done < <(list DemoteSudo)
    while IFS= read -r name; do
        safe_user "$name" && user_present "$name" || { status REVIEW "Cannot disable account: $name"; continue; }
        if is_authorized "$name" || [[ "$name" == "${SUDO_USER:-}" ]]; then
            status SKIPPED "Required/current account cannot be disabled: $name"; continue
        fi
        if [[ "$MODE" == apply ]]; then chage -l "$name" > "$BACKUPS/user-before-$name.txt" || true; fi
        change "Expire unauthorized account $name" usermod --expiredate 1970-01-02 "$name"
    done < <(list DisableUsers)
    while IFS= read -r name; do
        safe_user "$name" && user_present "$name" || { status OK "User absent/invalid: $name"; continue; }
        if is_authorized "$name" || [[ "$name" == "${SUDO_USER:-}" ]]; then
            status SKIPPED "Cannot delete required/current account: $name"; continue
        fi
        guard_removal "Remove account $name" || continue
        id=$(id -u "$name")
        if (( id < 1000 )); then status SKIPPED "Service/low-UID account $name requires manual review"; continue; fi
        if pgrep -u "$name" >/dev/null 2>&1; then status REVIEW "User $name has active processes; inspect and sign out first"; continue; fi
        if [[ "$MODE" == apply ]]; then
            getent passwd "$name" > "$BACKUPS/user-removed-$name.txt"
            id "$name" >> "$BACKUPS/user-removed-$name.txt" || true
        fi
        change "Delete explicitly unauthorized user $name (home retained)" userdel "$name"
    done < <(list RemoveUsers)
}
do_groups() {
    local group name
    while IFS= read -r group; do
        safe_group "$group" || { status REVIEW "Invalid group name: $group"; continue; }
        if group_present "$group"; then status OK "Group already exists: $group"; continue; fi
        change "Create README-required group $group" addgroup "$group"
    done < <(list NewGroups)
    while IFS=$'\t' read -r group name; do
        safe_group "$group" && safe_user "$name" || { status REVIEW "Invalid group/member: $group / $name"; continue; }
        group_present "$group" && user_present "$name" || { status REVIEW "Group/member missing: $group / $name"; continue; }
        is_authorized "$name" || { status SKIPPED "Cannot add unauthorized member $name to $group"; continue; }
        if id -nG "$name" | tr ' ' '\n' | grep -qxF "$group"; then
            status OK "$name is already in group $group"
        else change "Add $name to group $group" adduser "$name" "$group"; fi
    done < <(pairs GroupMembers)
    while IFS=$'\t' read -r group name; do
        safe_group "$group" && safe_user "$name" || { status REVIEW "Invalid group/member removal"; continue; }
        if [[ "$group" == sudo ]] && is_authorized "$name"; then
            status SKIPPED "Cannot remove sudo from authorized admin without human review"; continue
        fi
        group_present "$group" && user_present "$name" || { status OK "Group/member already absent: $group / $name"; continue; }
        if id -nG "$name" | tr ' ' '\n' | grep -qxF "$group"; then
            change "Remove unauthorized group membership $name from $group" gpasswd -d "$name" "$group"
        else status OK "$name not in group $group"; fi
    done < <(pairs RemoveGroupMembers)
}

set_file_value() {
    local file="$1" key="$2" value="$3" style="$4"
    backup "$file"
    python3 - "$file" "$key" "$value" "$style" <<'PY'
import re,sys,os
path,key,value,style=sys.argv[1:]
lines=open(path,encoding="utf-8").read().splitlines(keepends=True) if os.path.exists(path) else []
pat=re.compile(r'^\s*#?\s*'+re.escape(key)+r'\s*(?:=|\s)\s*.*$')
found=False
out=[]
for ln in lines:
    if pat.match(ln):
        if not found:
            out.append(f"{key}{' = ' if style=='equals' else '  '}{value}\n")
            found=True
    else: out.append(ln)
if not found: out.append(f"{key}{' = ' if style=='equals' else '  '}{value}\n")
with open(path,'w',encoding='utf-8') as f: f.writelines(out)
PY
}
user_age_rows() {
    python3 - "$CONFIG" <<'PY'
import json,sys
c=json.load(open(sys.argv[1],encoding='utf-8'))
for name,props in c.get('UserAging',{}).items():
    if isinstance(props,dict):
        print(str(name)+'\t'+str(props.get('max',''))+'\t'+str(props.get('min',''))+'\t'+str(props.get('warn','')))
PY
}
do_passwords() {
    local key value user max min warn
    while IFS=$'\t' read -r key value; do
        case "$key" in PASS_MIN_DAYS|PASS_MAX_DAYS|PASS_WARN_AGE) ;; *) status REVIEW "Unknown login.defs policy: $key"; continue ;; esac
        [[ "$value" =~ ^[0-9]{1,4}$ ]] || { status REVIEW "Invalid numeric password age: $key=$value"; continue; }
        change "Default password policy $key=$value" set_file_value /etc/login.defs "$key" "$value" space
    done < <(pairs PasswordAging)
    while IFS=$'\t' read -r user max min warn; do
        safe_user "$user" && user_present "$user" || { status REVIEW "Aging target not found/valid: $user"; continue; }
        is_authorized "$user" || { status SKIPPED "Password aging target not authorized: $user"; continue; }
        if [[ -n "$max" && ! "$max" =~ ^[0-9]{1,4}$ ]] || [[ -n "$min" && ! "$min" =~ ^[0-9]{1,4}$ ]] || [[ -n "$warn" && ! "$warn" =~ ^[0-9]{1,4}$ ]]; then
            status REVIEW "Invalid aging numbers for $user"; continue
        fi
        local args=()
        [[ -n "$max" ]] && args+=(-M "$max")
        [[ -n "$min" ]] && args+=(-m "$min")
        [[ -n "$warn" ]] && args+=(-W "$warn")
        ((${#args[@]})) || continue
        if [[ "$MODE" == apply ]]; then chage -l "$user" > "$BACKUPS/chage-before-$user.txt" || true; fi
        change "Set recorded password aging for $user" chage "${args[@]}" "$user"
    done < <(user_age_rows)
}
remove_pam_nullok() {
    local file=/etc/pam.d/common-auth
    backup "$file"
    python3 - "$file" <<'PY'
import re,sys
path=sys.argv[1]
data=open(path,encoding='utf-8').read().splitlines(keepends=True)
out=[]
for line in data:
    if not line.lstrip().startswith('#') and 'pam_unix.so' in line:
        line=re.sub(r'(?<!\S)nullok(?!\S)','',line)
    out.append(line)
with open(path,'w',encoding='utf-8') as f: f.writelines(out)
PY
    ! grep -E 'pam_unix\.so.*[[:space:]]nullok([[:space:]]|$)' "$file" >/dev/null
}
do_pam() {
    local key value
    if [[ "$(scalar RemovePAMNullok)" == true ]]; then
        if grep -E 'pam_unix\.so.*[[:space:]]nullok([[:space:]]|$)' /etc/pam.d/common-auth >/dev/null; then
            change 'Disallow nullok in common-auth (retain console access)' remove_pam_nullok
            status REVIEW 'PAM changed: test a new authorized login and sudo before closing the current session.'
        else status OK 'PAM common-auth has no active nullok on pam_unix'; fi
    fi
    if [[ -z "$(pairs PasswordQuality)" ]]; then return; fi
    if ! grep -q 'pam_pwquality.so' /etc/pam.d/common-password; then
        status REVIEW 'Password quality requested but pam_pwquality.so is absent from common-password. Install/configure libpam-pwquality manually first.'
        return
    fi
    while IFS=$'\t' read -r key value; do
        case "$key" in minlen|difok|maxrepeat|ucredit|lcredit|dcredit|ocredit|dictcheck|usercheck) ;; *) status REVIEW "Unsupported quality option: $key"; continue ;; esac
        [[ "$value" =~ ^-?[0-9]{1,3}$ ]] || { status REVIEW "Non-numeric quality value for $key"; continue; }
        change "Configure pwquality $key=$value" set_file_value /etc/security/pwquality.conf "$key" "$value" equals
    done < <(pairs PasswordQuality)
    status REVIEW 'After PAM/pwquality changes, test real password change and another authorized login. Failed-login lockout and password-history module ordering require manual review.'
}
do_firewall() {
    local port num proto
    if [[ "$(scalar EnableUFW)" != true ]]; then status SKIPPED 'UFW enablement not selected'; return; fi
    if ! command -v ufw >/dev/null 2>&1; then
        if [[ "$(scalar InstallUFW)" == true ]]; then
            if [[ "$MODE" == apply ]]; then apt-get update -qq || { status FAILED 'APT update for UFW'; return; }; fi
            change 'Install missing UFW package' apt-get install -y ufw
        else status REVIEW 'UFW not installed; set InstallUFW if approved'; return; fi
    fi
    if ! command -v ufw >/dev/null 2>&1; then return; fi
    if systemctl is-active --quiet nftables && [[ "$(ufw status 2>/dev/null | head -1)" == *inactive* ]]; then
        status REVIEW 'Native nftables manager is active; investigate firewall ownership before enabling UFW.'
        return
    fi
    if [[ "$MODE" == apply ]]; then
        mkdir -p "$BACKUPS/firewall"
        cp -a /etc/ufw "$BACKUPS/firewall/ufw-before" 2>/dev/null || true
        ufw status verbose > "$BACKUPS/firewall/status-before.txt" 2>&1 || true
    fi
    local ports=()
    mapfile -t ports < <(list RequiredPorts)
    local extra=()
    mapfile -t extra < <(list FirewallAllowPorts)
    ports+=("${extra[@]}")
    for port in "${ports[@]}"; do
        [[ "$port" =~ ^[0-9]{1,5}(/(tcp|udp))?$ ]] || { status REVIEW "Invalid firewall port/protocol $port"; continue; }
        num="${port%%/*}"
        ((10#$num > 0 && 10#$num <= 65535)) || { status REVIEW "Port out of range: $port"; continue; }
        change "Allow README-required firewall port $port" ufw allow "$port"
    done
    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        local sshport
        sshport=$(printf '%s' "$SSH_CONNECTION" | awk '{print $4}')
        if ! member "$sshport" "${ports[@]}" && ! member "$sshport/tcp" "${ports[@]}"; then
            status REVIEW "Current SSH connection uses port $sshport not allowed in JSON. UFW will NOT be enabled."
            return
        fi
    fi
    if [[ "$MODE" == audit ]]; then status WOULD 'Enable UFW'; return; fi
    if ufw --force enable; then
        if ufw status | grep -q '^Status: active'; then status CHANGED 'UFW enabled'; else status FAILED 'UFW not active'; fi
    else status FAILED 'UFW enablement'; fi
    status REVIEW 'Verify required SSH/web/database connections from a second authorized client.'
}
do_updates() {
    local pkg
    if [[ "$(scalar EnableDailyUpdateRefresh)" == true ]]; then
        change 'Enable daily APT package list updates' set_file_value /etc/apt/apt.conf.d/20auto-upgrades 'APT::Periodic::Update-Package-Lists' '"1";' space
    fi
    if [[ "$(scalar UpdatePackageLists)" != true && "$(scalar UpgradePackages)" != true && -z "$(list UpdatePackages)" ]]; then
        status SKIPPED 'APT update/upgrade not selected'; return
    fi
    if [[ "$MODE" == audit ]]; then status WOULD 'Update APT package lists'; return; fi
    if ! apt-get update; then status FAILED 'apt-get update (inspect repositories)'; return; fi
    status CHANGED 'Refreshed APT package lists'
    if [[ "$(scalar UpgradePackages)" == true ]]; then
        status REVIEW 'Full APT upgrade requested. Check package removal/configuration prompts and required services.'
        change 'Install reviewed Debian package updates' env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold
    fi
    while IFS= read -r pkg; do
        safe_pkg "$pkg" || { status REVIEW "Invalid package target: $pkg"; continue; }
        if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'ok installed'; then
            change "Update approved package $pkg" env DEBIAN_FRONTEND=noninteractive apt-get install -y --only-upgrade "$pkg"
        else status REVIEW "Required package update target not installed: $pkg"; fi
    done < <(list UpdatePackages)
    status REVIEW 'Verify Chromium/OpenSSH and any required application still run; inspect reboot requirements.'
}

service_needed() {
    local name="${1%.service}" item
    while IFS= read -r item; do
        [[ "${item%.service}" == "$name" ]] && return 0
    done < <(list RequiredServices)
    return 1
}
do_services() {
    local name current enabled
    local protected=(sshd ssh systemd-journald systemd-logind dbus dbus-broker NetworkManager networking systemd-networkd systemd-resolved systemd-timesyncd cron rsyslog auditd udev systemd-udevd)
    while IFS= read -r name; do
        safe_unit "$name" || { status REVIEW "Unsafe systemd unit name: $name"; continue; }
        if service_needed "$name" || member "${name%.service}" "${protected[@]}"; then
            status SKIPPED "Protected/required service not disabled: $name"; continue
        fi
        if [[ "$name" == *.socket || "$name" == *.target ]]; then status SKIPPED "Only service units are supported: $name"; continue; fi
        name="${name%.service}.service"
        if ! unit_present "$name"; then status OK "Unit missing: $name"; continue; fi
        enabled=$(systemctl is-enabled "$name" 2>/dev/null || true)
        current=$(systemctl is-active "$name" 2>/dev/null || true)
        if [[ "$enabled" == disabled && "$current" == inactive ]]; then status OK "Already stopped/disabled $name"; continue; fi
        if [[ "$MODE" == apply ]]; then
            systemctl cat "$name" > "$BACKUPS/service-$name.txt" 2>&1 || true
            printf 'state=%s enabled=%s\n' "$current" "$enabled" >> "$BACKUPS/service-$name.txt"
        fi
        change "Stop and disable explicitly unneeded service $name" systemctl disable --now "$name"
    done < <(list DisableServices)
    if [[ "$(scalar EnableRequiredServices)" == true ]]; then
        while IFS= read -r name; do
            safe_unit "$name" || continue
            name="${name%.service}.service"
            if ! unit_present "$name"; then status REVIEW "Required service missing: $name"; continue; fi
            if systemctl is-active --quiet "$name"; then status OK "Required service active: $name"
            else
                if [[ "$name" == *mysql* || "$name" == *mariadb* || "$name" == *postgres* || "$name" == *dns* ]]; then
                    status REVIEW "Database/DNS $name needs dependency check before starting"
                else change "Start README-required service $name" systemctl start "$name"; fi
            fi
        done < <(list RequiredServices)
    fi
    status REVIEW 'Verify critical services with a real client (web page, SSH login, DNS lookup or FTP transfer).'
}
set_sshd_setting() {
    local key="$1" value="$2" file=/etc/ssh/sshd_config
    backup "$file"
    python3 - "$file" "$key" "$value" <<'PY'
import re,sys
path,key,value=sys.argv[1:]
lines=open(path,encoding='utf-8').readlines()
out=[];seen=False
for line in lines:
    if re.match(r'^\s*Match\s+',line,re.I):
        if not seen: out.append(f"{key} {value}\n");seen=True
    if not seen and re.match(r'^\s*#?\s*'+re.escape(key)+r'\s+',line,re.I):
        if not line.lstrip().startswith("#"):
            if not seen: out.append(f"{key} {value}\n");seen=True
            continue
    out.append(line)
if not seen: out.append(f"{key} {value}\n")
open(path,'w',encoding='utf-8').writelines(out)
PY
}
ssh_fix_one() {
    local key="$1" expected="$2" file=/etc/ssh/sshd_config
    set_sshd_setting "$key" "$expected"
    if ! /usr/sbin/sshd -t; then
        cp -a "$BACKUPS/originals$file" "$file"
        return 1
    fi
    local got
    got=$(/usr/sbin/sshd -T 2>/dev/null | awk -v k="${key,,}" '$1==k {print $2;exit}')
    if [[ "$got" != "$expected" ]]; then
        cp -a "$BACKUPS/originals$file" "$file"
        status REVIEW "SSH $key is overridden by Include/Match; changed file restored."
        return 1
    fi
    if systemctl is-active --quiet ssh.service; then
        if ! systemctl reload ssh.service; then
            cp -a "$BACKUPS/originals$file" "$file"
            systemctl reload ssh.service || true
            return 1
        fi
    fi
}
do_ssh() {
    if [[ "$(scalar SSH.DisableRootLogin)" != true && "$(scalar SSH.DisableEmptyPasswords)" != true ]]; then
        status SKIPPED 'No SSH settings requested'; return
    fi
    if [[ ! -x /usr/sbin/sshd || ! -f /etc/ssh/sshd_config ]]; then
        status REVIEW 'SSH server not installed/configured; do not install it unless README requires.'
        return
    fi
    if [[ "$MODE" == apply ]]; then /usr/sbin/sshd -t || { status FAILED 'Baseline SSH syntax invalid; no changes'; return; }; fi
    if [[ "$(scalar SSH.DisableRootLogin)" == true ]]; then
        change 'Disable direct SSH root login' ssh_fix_one PermitRootLogin no
    fi
    if [[ "$(scalar SSH.DisableEmptyPasswords)" == true ]]; then
        change 'Disable SSH empty passwords' ssh_fix_one PermitEmptyPasswords no
    fi
    status REVIEW 'Check sshd -T, drop-ins, Match rules, required SSH ports and a second authorized login.'
}
do_kernel() {
    local key value previous
    local allowed=(net.ipv4.tcp_syncookies net.ipv4.ip_forward kernel.randomize_va_space net.ipv4.conf.all.accept_redirects net.ipv4.conf.default.accept_redirects net.ipv4.conf.all.send_redirects net.ipv4.conf.default.send_redirects net.ipv4.conf.all.accept_source_route net.ipv6.conf.all.accept_redirects)
    local file=/etc/sysctl.d/90-cp-debian.conf
    while IFS=$'\t' read -r key value; do
        member "$key" "${allowed[@]}" || { status REVIEW "Unsupported sysctl option: $key"; continue; }
        [[ "$value" =~ ^[012]$ ]] || { status REVIEW "Invalid sysctl value $key=$value"; continue; }
        if [[ "$key" == net.ipv4.ip_forward && "$value" == 0 ]]; then
            status REVIEW 'IPv4 forwarding off can break a required router/VPN/container gateway. Confirm topology.'
        fi
        previous=$(sysctl -n "$key" 2>/dev/null || true)
        if [[ "$previous" == "$value" ]] && grep -qF "$key = $value" "$file" 2>/dev/null; then status OK "$key already $value"; continue; fi
        if [[ "$MODE" == audit ]]; then status WOULD "Set sysctl $key=$value"; continue; fi
        backup "$file"
        printf '%s = %s\n' "$key" "$previous" >> "$BACKUPS/sysctl-before.txt"
        if set_file_value "$file" "$key" "$value" equals &&
           sysctl -w "$key=$value" >/dev/null &&
           [[ "$(sysctl -n "$key")" == "$value" ]]; then
            status CHANGED "Set sysctl $key=$value"
        else status FAILED "Could not apply sysctl $key=$value"; fi
    done < <(pairs Sysctl)
}
do_permissions() {
    if [[ "$(scalar FixShadowPermissions)" != true ]]; then status SKIPPED 'Shadow permission remediation not selected'; return; fi
    local file perms
    for file in /etc/shadow /etc/gshadow; do
        [[ -f "$file" ]] || continue
        perms=$(stat -c '%a' "$file")
        if [[ "$MODE" == audit ]]; then status WOULD "Review $file mode $perms"; continue; fi
        backup "$file"
        chmod o-rwx,g-w "$file"
        if [[ "$(stat -c %a "$file")" == "$perms" ]]; then status OK "$file permissions already restrictive"
        else status CHANGED "Removed world access and group write from $file (was $perms)"; fi
    done
    status REVIEW 'Verify owner/group and authentication still work; do not change secure 000/600 modes to 640 blindly.'
}
do_apparmor() {
    if ! command -v aa-status >/dev/null 2>&1; then
        status REVIEW 'AppArmor tooling is missing; do not install/reconfigure blindly'; return
    fi
    capture 'apparmor-before' aa-status
    local file
    while IFS= read -r file; do
        if [[ "$file" != /etc/apparmor.d/* || ! -f "$file" ]] || [[ "$file" == *..* ]]; then
            status SKIPPED "AppArmor profile must be an existing /etc/apparmor.d file: $file"; continue
        fi
        command -v aa-enforce >/dev/null 2>&1 || { status REVIEW 'aa-enforce command absent'; continue; }
        if [[ "$MODE" == apply ]]; then backup "$file"; fi
        change "Set AppArmor profile enforce: $file" aa-enforce "$file"
    done < <(list AppArmorProfiles)
}
do_logging() {
    local name key
    for name in auditd rsyslog; do
        if [[ "$name" == auditd ]]; then key=Logging.EnableAuditd; else key=Logging.EnableRsyslog; fi
        [[ "$(scalar "$key")" == true ]] || continue
        if ! unit_present "$name.service"; then status REVIEW "Requested $name not installed"; continue; fi
        if systemctl is-active --quiet "$name"; then status OK "$name running"
        else change "Start required logging service $name" systemctl enable --now "$name"; fi
    done
    capture 'journal-errors' journalctl -p err -n 40 --no-pager
}

do_software() {
    local pkg simulation count
    while IFS= read -r pkg; do
        safe_pkg "$pkg" || { status REVIEW "Invalid package: $pkg"; continue; }
        if is_required_package "$pkg"; then status SKIPPED "Required package protected: $pkg"; continue; fi
        if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'ok installed'; then
            status OK "Package not installed: $pkg"; continue
        fi
        guard_removal "Remove prohibited package $pkg" || continue
        simulation="$BACKUPS/apt-purge-simulation-$pkg.txt"
        apt-get -s purge "$pkg" > "$simulation" 2>&1 || { status REVIEW "APT removal simulation failed for $pkg"; continue; }
        count=$(grep -Ec '^(Remv|Purg) ' "$simulation" || true)
        if [[ "$count" != 1 ]]; then
            status REVIEW "Package $pkg would remove $count packages; inspect $simulation and remove manually."
            continue
        fi
        change "Purge exact prohibited package $pkg" env DEBIAN_FRONTEND=noninteractive apt-get purge -y "$pkg"
    done < <(list RemovePackages)
}
do_files() {
    local requested actual
    while IFS= read -r requested; do
        [[ "$requested" == /* && -f "$requested" && ! -L "$requested" ]] || {
            status REVIEW "File absent, symlink or unsafe: $requested"; continue
        }
        actual=$(realpath -e -- "$requested") || continue
        case "$actual" in
            /home/*|/tmp/*|/var/tmp/*|/opt/*|/srv/*) ;;
            *) status SKIPPED "System/credential path requires manual review: $actual"; continue ;;
        esac
        [[ "$actual" != "$BACKUPS"* && "$actual" != "$ROOT"* ]] || { status SKIPPED "Cannot remove script report: $actual"; continue; }
        guard_removal "Delete prohibited file $actual" || continue
        if [[ "$MODE" == apply ]]; then
            sha256sum "$actual" >> "$BACKUPS/file-deletion-hashes.txt" || true
            stat -c '%a %U:%G %s %n' "$actual" >> "$BACKUPS/file-deletion-hashes.txt" || true
        fi
        change "Delete exact prohibited file $actual" rm -f -- "$actual"
    done < <(list RemoveFiles)
}
cron_remove_line() {
    local user="$1" line="$2" src="$BACKUPS/cron-before-$user.txt" new="$BACKUPS/cron-after-$user.txt"
    crontab -u "$user" -l > "$src" 2>/dev/null || return 1
    grep -Fqx -- "$line" "$src" || return 1
    grep -Fvx -- "$line" "$src" > "$new" || true
    crontab -u "$user" "$new"
}
do_persistence() {
    local user line unit
    while IFS=$'\t' read -r user line; do
        [[ -n "$line" ]] || continue
        if [[ "$user" != root ]] && ! safe_user "$user"; then status REVIEW "Unsafe cron owner $user"; continue; fi
        user_present "$user" || { status REVIEW "Cron user absent: $user"; continue; }
        if [[ "$line" == \#* || "$line" == *$'\n'* ]]; then status REVIEW 'Cron entry must be a single exact executable line'; continue; fi
        if ! crontab -u "$user" -l 2>/dev/null | grep -Fqx -- "$line"; then
            status OK "Target cron entry absent for $user"; continue
        fi
        change "Remove exact unauthorized cron entry for $user" cron_remove_line "$user" "$line"
    done < <(records RemoveCronLines)
    while IFS= read -r unit; do
        safe_unit "$unit" || { status REVIEW "Unsafe unit name $unit"; continue; }
        unit="${unit%.service}.service"
        if service_needed "$unit" || [[ "$unit" == systemd* || "$unit" == dbus* || "$unit" == ssh.service ]]; then
            status SKIPPED "Protected/required unit $unit"; continue
        fi
        if unit_present "$unit"; then
            if [[ "$MODE" == apply ]]; then systemctl cat "$unit" > "$BACKUPS/unit-before-$unit.txt" 2>&1 || true; fi
            change "Disable confirmed malicious systemd unit $unit" systemctl disable --now "$unit"
        else status OK "Unit absent: $unit"; fi
    done < <(list DisableUnits)
    status REVIEW 'Inspect user crontabs, systemd user units, shell startup, at jobs and unexpected listeners.'
}
hosts_remove_line() {
    local line="$1" path=/etc/hosts
    backup "$path"
    python3 - "$path" "$line" <<'PY'
import sys
p,target=sys.argv[1:]
lines=open(p,encoding='utf-8').readlines()
with open(p,'w',encoding='utf-8') as f:
    for line in lines:
        if line.rstrip('\r\n')!=target: f.write(line)
PY
}
do_hosts() {
    local entry
    while IFS= read -r entry; do
        [[ -n "$entry" ]] || continue
        if ! grep -Fxq -- "$entry" /etc/hosts; then status OK "Hosts entry absent: $entry"; continue; fi
        if [[ "$entry" == *localhost* || "$entry" == *127.0.0.1* || "$entry" == *::1* ]]; then
            status REVIEW "Hosts entry may be system-required: $entry"; continue
        fi
        change "Remove exact unauthorized hosts mapping" hosts_remove_line "$entry"
    done < <(list RemoveHostsLines)
}
gdm_disable_autologin() {
    local file=/etc/gdm3/daemon.conf
    backup "$file"
    python3 - "$file" <<'PY'
import re,sys
path=sys.argv[1]
lines=open(path,encoding='utf-8').readlines()
out=[];in_daemon=False;seen=False;had_section=False
for line in lines:
    m=re.match(r'^\s*\[([^\]]+)\]',line)
    if m:
        if in_daemon and not seen: out.append('AutomaticLoginEnable=false\n');seen=True
        in_daemon=m.group(1).lower()=='daemon'
        had_section=had_section or in_daemon
    if in_daemon and re.match(r'^\s*#?\s*AutomaticLoginEnable\s*=',line):
        if not seen: out.append('AutomaticLoginEnable=false\n');seen=True
        continue
    if in_daemon and re.match(r'^\s*#?\s*AutomaticLogin\s*=',line):
        continue
    out.append(line)
if had_section and in_daemon and not seen: out.append('AutomaticLoginEnable=false\n')
if not had_section: out+=['\n[daemon]\n','AutomaticLoginEnable=false\n']
open(path,'w',encoding='utf-8').writelines(out)
PY
}
do_desktop() {
    if [[ "$(scalar Desktop.DisableGdmAutologin)" != true ]]; then return; fi
    if [[ ! -f /etc/gdm3/daemon.conf || ! -d /etc/gdm3 ]]; then
        status REVIEW 'GDM3 is not installed; use the actual desktop/login manager.'; return
    fi
    change 'Disable GDM3 automatic login in daemon.conf' gdm_disable_autologin
    status REVIEW 'Check GDM3 settings and new authorized login at a safe checkpoint; do not restart display manager mid-round.'
}
chromium_policy() {
    local file=/etc/chromium/policies/managed/90-cp-security.json
    mkdir -p "$(dirname "$file")"
    backup "$file"
    python3 - "$file" <<'PY'
import json,os,sys
p=sys.argv[1]; obj={}
if os.path.exists(p):
    with open(p,encoding='utf-8') as f: obj=json.load(f)
obj['DefaultPopupsSetting']=2
with open(p,'w',encoding='utf-8') as f: json.dump(obj,f,indent=2);f.write('\n')
PY
    chmod 644 "$file"
}
do_browsers() {
    if [[ "$(scalar Browsers.ChromiumBlockPopups)" == true ]]; then
        if command -v chromium >/dev/null 2>&1 || dpkg-query -W chromium >/dev/null 2>&1; then
            change 'Set Chromium default pop-up block policy' chromium_policy
            status REVIEW 'Verify actual installed Chromium policy path with chrome://policy and required websites.'
        else status REVIEW 'Chromium absent; do not install a browser that README does not require.'; fi
    fi
    status REVIEW 'Check Firefox ESR/Chromium browser versions, extensions, required default browser and pop-up settings in their GUIs.'
}

