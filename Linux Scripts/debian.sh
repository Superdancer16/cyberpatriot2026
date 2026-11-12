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
