# Linux Image Checklist

This checklist is a set of inspection prompts for authorized CyberPatriot Linux images. Distributions, versions, and round requirements differ; verify each item in the image instructions before making changes.

## Accounts and access

- [ ] Review local users, groups, and administrative privileges.
- [ ] Compare required accounts with the image instructions.
- [ ] Review password and account policies where applicable.
- [ ] Inspect SSH access and other remote login settings against required functionality.
- [ ] Do not delete or lock accounts until their purpose and round requirements are known.

## System security

- [ ] Review firewall status and rules against required network behavior.
- [ ] Check update status and enabled security controls where permitted.
- [ ] Review file permissions on sensitive system and configuration files.
- [ ] Inspect enabled services and listening network services; investigate unfamiliar items before changing them.
- [ ] Review scheduled jobs and startup configuration for unexpected entries.
- [ ] Check logging status when relevant to the instructions.

## Software and verification

- [ ] Review installed packages for unauthorized or clearly suspicious software.
- [ ] Preserve packages and services required by the image instructions.
- [ ] Confirm every change took effect and required applications still work.
- [ ] Recheck the score and record any remaining uncertainty.

Use commands only when permitted, understood, and appropriate for the specific image. Review command effects before execution; avoid copying unreviewed commands from the internet or using broad automated cleanup.
