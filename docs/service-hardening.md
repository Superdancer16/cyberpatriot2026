# Required service hardening

## Web and databases

For Apache, Nginx or IIS, record the intended site, bindings, service identity and document root. Review permissions and TLS requirements. For MySQL or MariaDB, compare bind addresses and application grants with the intended clients. Check configuration syntax using the installed service’s supported validator before reload. Verify a known page or application query.

## SSH and file sharing

Identify who needs access and from where. Review SSH authentication and authorized groups while retaining an approved session. For SMB or Samba compare share access with filesystem access. For required FTP, check the expected directory and anonymous access policy. Verify approved access and review denied access from an approved test account if the brief allows it.

## DNS and mail

For BIND or Windows DNS, distinguish authoritative answers from recursion and document permitted clients. For Postfix or another mail service, check relay scope and intended local delivery. Preserve required dependencies and verify a known lookup or approved test message after changes.
