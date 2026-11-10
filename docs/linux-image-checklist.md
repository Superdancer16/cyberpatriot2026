# Linux image guide

## Inventory

Read /etc/os-release and identify desktop, init system, package manager and active firewall. Record the image brief’s authorized users, administrative groups and expected services.

## Accounts

Use read-only getent passwd and getent group to inspect effective account sources. Check individual membership with id. Distinguish service accounts from interactive users and retain the approved administrator session during changes.

## Authentication

Review password aging, PAM policy and administrative grants against the brief. Use visudo for syntax validation when authorized to edit sudoers. Keep an existing session open and verify a second approved login before ending it.

## Services and listeners

On systemd images inspect systemctl status SERVICE and journalctl -u SERVICE. Match each expected listener to a required service and check its bind address. Inspect the actual dependency before changing startup behavior.

## Firewall and updates

Identify the active firewall manager and current rules before editing. Preserve required traffic and verify it through the intended client. Review package sources and proposed package changes before updating. Stop if the package manager proposes removing required components.

## Permissions and logs

Use ls -ld on relevant paths to inspect owner and mode. Check whether service accounts can still read their configuration and write required data. Review authentication and service logs around the baseline and last change.

## Distribution notes

Use the [platform notes](platform-notes.md) for Ubuntu, Debian, Mint and FreeBSD. Use the [service guide](service-hardening.md) when a service must remain available.
