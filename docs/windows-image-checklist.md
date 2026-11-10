# Windows Image Checklist

This checklist is a set of inspection prompts for authorized CyberPatriot Windows images. Windows editions and round requirements differ; verify each item in the image instructions before making changes.

## Accounts and access

- [ ] Review local users and groups for unexpected accounts or memberships.
- [ ] Compare required accounts and administrators with the image instructions.
- [ ] Review password, lockout, and sign-in policies.
- [ ] Check guest access and remote sign-in settings where relevant.
- [ ] Do not disable, delete, rename, or change credentials for required accounts without explicit authorization.

## Security settings

- [ ] Review Microsoft Defender or the installed security product status.
- [ ] Check Windows Firewall profiles and rules against required network behavior.
- [ ] Review Remote Desktop, file sharing, and other remote access settings.
- [ ] Inspect update status and security policy settings where permitted.
- [ ] Review audit and event logging status if the round instructions call for it.

## Software and persistence

- [ ] Review installed applications for unauthorized or clearly suspicious software.
- [ ] Inspect startup applications and scheduled tasks for unfamiliar entries.
- [ ] Review services and processes that appear unexpected; research before changing them.
- [ ] Preserve software and services required by the image instructions.

## Verification

- [ ] Confirm every change took effect.
- [ ] Confirm required logins, services, and applications still function.
- [ ] Recheck the score and record any remaining uncertainty.
