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

