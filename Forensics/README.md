# 🔎 Forensics — Searchable Question Finder

> [!TIP]
> Start here when a forensics prompt looks unfamiliar. Open the correct operating-system guide, then use **Ctrl+F** for the terms from the question. These are investigative guides, not a collection of live competition answers.

## Choose the guide for your image

| Image | Searchable handbook | Useful Ctrl+F terms |
|---|---|---|
| Windows 10 / Windows 11 | [Windows forensics](windows.md) | Base64, ROT13, Caesar, XOR, encryption, BitLocker, file signature, alternate data stream, event log, registry, port, hash |
| Windows Server / Active Directory | [Server forensics](windows-server.md) | domain user, SID, group, Group Policy, DNS, DHCP, IIS, SMB, certificate, CMS, DPAPI, AES, event log |
| Debian / Mint / Ubuntu | [Linux forensics](linux.md) | GPG, OpenSSL, ROT13, Base64, hex, ELF, UID, GID, chmod, sudo, SSH, cron, journalctl, PCAP |

## If your question does not match a chapter

1. **Identify the artifact:** Is it a message, file, archive, user account, service, network capture, or log entry?
2. **Copy exact wording:** Search the right guide using a distinctive noun, extension, cipher name, port, or tool.
3. **Check layers:** A suspicious string might be encoded more than once; encoding is not the same as encryption, and genuine encryption requires the correct key or authorized recovery method.
4. **Preserve evidence first:** Record paths, timestamps and copies when appropriate. Do not delete suspicious files just because the question mentions them.
5. **Verify the result:** Check that decoded text, a username, hash, or event timestamp actually answers the question.

For a shorter cross-platform introduction, open [General forensics questions](../General/All/forensics-questions.md). For safe first actions, open [Reading the image README](../General/All/reading-the-readme.md).

[Complete file index](../INDEX.md) · [Repository home](../README.md)
