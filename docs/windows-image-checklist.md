# Windows 10 and 11 image guide

## Accounts

Open Computer Management → Local Users and Groups where available, or Settings → Accounts for basic inventory. Compare named users and Administrators membership against the brief. Distinguish built-in, service and human accounts. Record the original membership before correcting an unauthorized grant. Keep an approved administrator session open and confirm a second approved login before closing it.

## Password and lockout policy

In Local Security Policy, inspect Account Policies → Password Policy and Account Lockout Policy. Capture current values and apply the brief’s explicit requirements. Consider service identities and lockout risk before changing credentials. On a managed machine, inspect effective policy before editing local settings.

## User rights and audit

Under Local Policies, review User Rights Assignment and Security Options. Check who may sign in locally or remotely and whether policy changes affect service identities. Use Event Viewer → Windows Logs → Security to review recent sign-in and account changes. Record event time, outcome and account without copying secrets.

## Defender

Open Windows Security → Virus & threat protection. Check the active provider, protection status, definitions, protection history and exclusions. Investigate the purpose and owner of an exclusion before removing it. Confirm the provider reports healthy and required workloads still run.

## Firewall and remote access

Open Windows Defender Firewall with Advanced Security. Record the active profile and inspect inbound rule scope, program and enabled status. Preserve explicitly required traffic. In Settings → System → Remote Desktop, inspect whether RDP is enabled and which users can connect. Verify authorized access from the approved client after any scoped change.

## Shares and permissions

Use Computer Management → Shared Folders and inspect each share’s intended audience. Compare share permissions with NTFS permissions on the folder’s Security tab. Check effective access as an authorized standard user. Avoid recursive permission changes to Windows or application directories.

## Services and startup

In Services, Task Scheduler and Task Manager → Startup apps, record entry owner, path, publisher, triggers and dependencies. Check the executable’s properties and corroborate with logs before deciding whether to disable an entry. Change one entry at a time and confirm the required application still opens.

## Updates and software

Use Settings → Windows Update and Apps → Installed apps. Check pending restarts and distinguish prohibited applications from dependencies and drivers. Coordinate permitted updates with the team lead. Confirm required software starts after approved removal or restart.

## Final review

Recheck approved sign-in, required apps, firewall rules, scoring and remaining time. If something breaks, restore the last known setting and verify the affected feature before continuing.
