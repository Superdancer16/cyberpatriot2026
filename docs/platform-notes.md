# Ubuntu, Debian, Linux Mint and FreeBSD

## Ubuntu

Identify the release and desktop. On GNOME, check Settings for Users and Sharing. Review APT packages and Snap applications separately when both are present. Check whether an SSH listener is controlled by a service or socket before changing its configuration.

## Debian

Check whether the image uses sudo or a designated root workflow. Confirm the configured package repositories match the installed release. Check the installed browser and display manager instead of assuming desktop defaults.

## Linux Mint

Identify the desktop edition first. On Cinnamon, review Users and Groups, Startup Applications and Update Manager. Check session startup separately from system services. Review APT and Flatpak inventories when both are present.

## FreeBSD

Use freebsd-version for release information, pw usershow for account inspection and service -e for enabled rc services. Review wheel membership and the configured privilege delegation tool separately. Identify the active firewall before editing and preserve console access. Distinguish base-system maintenance from third-party packages. Record any rc settings you change and check the dependent service immediately.
