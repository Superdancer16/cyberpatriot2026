# Linux forensic questions — searchable Debian, Mint and Ubuntu handbook

For CyberPatriot-style **Debian 12/13, Linux Mint and Ubuntu** images. Keep this guide open and use **Ctrl+F** for words in the prompt: `Base64`, `ROT13`, `UID`, `ELF`, `hash`, `MP3`, `cron`, `systemd`, `SSH`, `XOR`, `encrypted`, etc.

**Answer the forensic-question files before hardening.** Copy the exact wording and requested output format, inspect the original evidence, type the answer after `ANSWER:`, save the question file, and check the Scoring Report. Do not purge software, reset a user, erase evidence or kill suspicious processes just to investigate.

This is a **method handbook**, not an answer list for another image. Filenames, users, keys, and timestamps below are samples. Do not install tools or upload private evidence to websites unless the round and coach allow it.

Also see [Windows forensics](windows.md), [Windows Server forensics](windows-server.md), the [Debian handbook](../Linux/debian.md), [Linux Mint handbook](../Linux/linux-mint.md), and [Ubuntu handbook](../Linux/ubuntu.md).

## Ctrl+F question finder

| Question keywords | Where to look |
|---|---|
| cipher, encryption, cryptogram, decode, layers, plaintext | [Decision tree](#decoding-decision-tree) |
| Base64, base 64, `=`, `==`, `Qenpnelf` | [Base64 and ROT13](#base64-then-rot13-layered-example) |
| ROT13, Caesar, shift, rotate, reverse, backwards | [ROT13 and Caesar](#rot13-caesar-and-reverse-text) |
| hex, hexadecimal, ASCII from hex, ELF, first five bytes | [Hex and magic bytes](#hex-encoding-and-magic-bytes) |
| binary, octal, ASCII codes, URL `%20`, HTML, Unicode, Morse | [Other encodings](#binary-decimal-octal-url-html-unicode-and-morse) |
| Atbash, affine, `a`, `b`, Vigenere, keyword | [Classical ciphers](#atbash-affine-and-vigenere) |
| XOR, OTP, one-time pad, supplied key | [XOR and pad](#xor-and-supplied-pad-key) |
| AES, GPG, PGP, OpenSSL, encryption key, password | [Real encryption](#gpg-openssl-and-real-encryption) |
| encrypted ZIP, 7z, archive, tar, compressed | [Archives](#archives-and-password-protected-zips) |
| MD5, SHA, RIPEMD160, digest, file checksum | [Hashes](#file-hashes-and-checksums) |
| file path, directory, MP3, prohibited files, hidden file | [Find files](#search-files-and-parent-directories) |
| UID, GID, orphan, nouser, numeric owner | [UID ownership](#uid-gid-and-orphaned-file-owners) |
| unsafe C function, gets, strcpy, source code | [Code analysis](#unsafe-c-functions-and-source-code) |
| 7F 45 4C 46, ELF, executable, first bytes | [Magic bytes](#hex-encoding-and-magic-bytes) |
| timestamps, birth, ctime, mtime, EXIF | [Metadata](#metadata-and-timestamp-questions) |
| permission, mode, rwx, SUID, SGID, ACL, capabilities | [Permissions](#permissions-suid-capabilities-and-acls) |
| hidden message, image, audio, spectrogram, steganography | [Images and audio](#image-audio-and-steganography) |
| user, sudo, UID 0, group membership | [Users](#users-groups-and-uid-zero) |
| bash history, who ran, `.bash_history` | [History](#bash-history-and-command-evidence) |
| SSH login, Failed, Accepted, auth.log | [Authentication](#authentication-logs-and-ssh-logins) |
| journal, systemd, service events, time window | [Journal](#journalctl-and-time-windows) |
| cron, systemd timer, startup, persistence | [Cron and systemd](#cron-and-systemd-persistence) |
| package history, dpkg, apt, installed, removed, Snap, Flatpak | [Packages](#apt-dpkg-snap-and-flatpak-history) |
| PID, listening port, netcat, process executable | [Processes](#processes-and-open-ports) |
| PCAP, Wireshark, tshark, TCP, DNS, source IP | [PCAP](#pcap-and-wireshark) |
| Samba, shared folder, NFS, fstab, mount | [Shares](#samba-nfs-shares-and-mounts) |
| cert, X509, issuer, fingerprint, private key | [Certificates](#certificates-signatures-and-keys) |
| failed, not found, no answer, command missing | [Escalation](#if-ctrlf-did-not-find-your-question) |

## First three minutes: preserve questions and original files

1. Read every `Forensics Question *.txt` file on the desktop and note **what type of answer** is requested: plaintext, full path, UID, hash, PID, port, date, user, certificate, etc.
2. Open Terminal (often **Ctrl+Alt+T**) or the desktop file manager. In common GTK file managers, **Ctrl+H** shows hidden dotfiles.
3. Record file path, size, SHA-256, ownership and timestamps before changing anything. Use `sudo` for authorized inspection of protected files only.
4. Start in the **folder named by the prompt**. Expand to `/home`, `/srv`, `/opt`, `/tmp` and finally `/` only if the narrow search fails.
5. Answer in the question's original file, **save**, check the score, and only then return to hardening.

```bash
find "$HOME/Desktop" "$HOME/Downloads" -maxdepth 3 -type f -iname '*forensic*' -print 2>/dev/null
cat -- "$HOME/Desktop/clue.txt"
sed -n '1,70l' "$HOME/Desktop/clue.txt"   # expose whitespace and line endings
sha256sum "$HOME/Desktop/clue.txt"
stat "$HOME/Desktop/clue.txt"
```

For exact byte puzzles, use `printf '%s'` rather than `echo` because `echo` adds a newline.

## Decoding decision tree

**Encoding** (Base64/hex/binary) represents data, **simple ciphers** (ROT13/Caesar/Affine) are reversible without strong secrecy, **modern encryption** (AES/PGP) requires the correct key and format, and **hashing** is one-way.

1. **Look at the alphabet:** even-length hex → hex; `A-Za-z0-9+/=` → Base64; groups of eight 0s/1s → binary; ordinary-looking scrambled words → ROT13/reverse/Caesar/Atbash/Vigenere.
2. **Look for supplied parameters:** shift, keyword, `a` and `b`, ciphertext and key, IV, nonce, salt, tag, passphrase. A key may be in an adjacent file or README clue.
3. **Decode one layer at a time.** If the first result still looks encoded, apply the next hinted transform to that result. Record each intermediate output.
4. **Text or binary?** Use `file`, `od`, `xxd` (when installed) and magic bytes to tell whether decoded bytes are a ZIP/PNG/ELF/PDF instead of UTF-8.
5. **Verify the format:** uppercase/lowercase, spaces, punctuation, path versus filename, decimal versus hexadecimal.
6. **If a real encryption key is missing**, search for it. Do not claim a genuine AES/GPG ciphertext can be decrypted from the algorithm name alone.

Layered recipes worth trying *only when evidence points to them*: **Base64 → ROT13**, **ROT13 → reverse**, **hex → ASCII**, **reverse → Base64**, **Base64 → XOR**, **URL decode → Base64**.

An approved, local/offline [CyberChef](https://github.com/gchq/CyberChef) copy can chain these transforms. If online tools are permitted, avoid uploading private evidence to third-party websites.

### Base64 then ROT13 — layered example

Decode a string:

```bash
printf '%s' 'SGVsbG8=' | base64 --decode
# Hello
```

Decode a file:

```bash
base64 --decode "$HOME/Desktop/encoded.txt"
```

If the output is still scrambled, try ROT13:

```bash
printf '%s' 'Qenpnelf ng qnja' | tr 'A-Za-z' 'N-ZA-Mn-za-m'
# Dracarys at dawn
```

The supplied CP19 Debian 12 training answer key illustrates this **Base64 → ROT13** sequence. Its displayed answer may capitalize a word differently from the intermediate decoded letters; always use the answer format and case requested in the active question.

Two transforms in a single read-only pipeline:

```bash
base64 --decode "$HOME/Desktop/encoded.txt" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
```

**If Base64 reports invalid input:** inspect line breaks, quotations, copied spaces, padding or Base64URL (`-`, `_`). Do not strip arbitrary data from evidence to force output.

### ROT13, Caesar and reverse text

ROT13 shifts letters by 13. Reversing text flips **characters**, not the order of words.

```bash
printf '%s' 'Uryyb Jbeyq' | tr 'A-Za-z' 'N-ZA-Mn-za-m'
# Hello World
printf '%s' 'olleH' | rev
# Hello
printf '%s' 'byyrU' | tr 'A-Za-z' 'N-ZA-Mn-za-m' | rev
# Hello (two-stage example)
```

If the question says "Caesar encrypted with +3", normally **decrypt by subtracting three**. To try all shifts using Python 3:

```bash
python3 - <<'PY'
text = "Khoor Zruog"
for shift in range(26):
    result = ''.join(
        chr(ord('A')+(ord(c)-ord('A')-shift)%26) if 'A'<=c<='Z' else
        chr(ord('a')+(ord(c)-ord('a')-shift)%26) if 'a'<=c<='z' else c
        for c in text
    )
    print(f"shift={shift:2}: {result}")
PY
```

ROT13 and reverse happen to commute because ROT13 acts independently on letters. **Other** layers (Base64, hex, XOR, decompression) generally do not commute.

### Hex encoding and magic bytes

Hex is two digits per byte. `48 65 6c 6c 6f` is byte-encoded "Hello":

```bash
printf '%s' '48 65 6c 6c 6f' | xxd -r -p     # xxd when installed
python3 -c "print(bytes.fromhex('48 65 6c 6c 6f').decode('utf-8'))"
```

To answer **"first five bytes"**, do not convert the bytes into a word:

```bash
od -An -tx1 -N5 /path/to/file | xargs
file /path/to/file
xxd -l 16 /path/to/file               # optional xxd
```

| First bytes (hex) | Typical file |
|---|---|
| `7f 45 4c 46` | ELF executable/shared object |
| `7f 45 4c 46 01` | ELF 32-bit class |
| `7f 45 4c 46 02` | ELF 64-bit class |
| `50 4b 03 04` | ZIP or OOXML container |
| `25 50 44 46` | PDF |
| `89 50 4e 47 0d 0a 1a 0a` | PNG |
| `ff d8 ff` | JPEG |
| `4d 5a` | Windows PE EXE |
| `37 7a bc af 27 1c` | 7-Zip |

A CP19 Round 1 Linux answer was expressed as a five-byte hexadecimal sequence, but the provided category summary does **not** specify the original artifact. Always read actual bytes from the file named in your current prompt.

### Binary, decimal, octal, URL, HTML, Unicode and Morse

| Pattern | Meaning |
|---|---|
| `01001000 01101001` | binary ASCII |
| `72 101 108 108 111` | decimal ASCII |
| `110 145 154 154 157` | octal ASCII |
| `Hello%20World` | URL percent encoding |
| `Hello&#32;World` | HTML numeric character entity |
| `\u0048\u0069` | Unicode escape sequence |
| `.... . .-.. .-.. ---` | Morse dots and dashes |

```bash
python3 - <<'PY'
import html, urllib.parse
print(''.join(chr(int(x,2)) for x in '01001000 01101001'.split()))
print(''.join(chr(int(x)) for x in '72 101 108 108 111'.split()))
print(''.join(chr(int(x,8)) for x in '110 145 154 154 157'.split()))
print(urllib.parse.unquote('Hello%20World'))
print(html.unescape('Hello&#32;World'))
PY
```

For Morse use a dot-dash alphabet; `/` commonly separates words. Keep the exact spacing from the prompt.

### Atbash, affine and Vigenere

**Atbash:** reverse the alphabet (`A↔Z`, `B↔Y`) and preserve punctuation/case. It needs no key.

**Affine:** A=0 through Z=25; encryption `E(x)=(a*x+b) mod 26`, decryption uses the multiplicative inverse of `a`. If `gcd(a,26)` is not 1, an inverse doesn't exist.

```bash
python3 - <<'PY'
a,b = 1,3
cipher = "Qeb"
inverse = pow(a,-1,26)       # Python 3.8+
def decode(c):
    if c.isascii() and c.isalpha():
        start = ord('A') if c.isupper() else ord('a')
        return chr(start+(inverse*(ord(c)-start-b))%26)
    return c
print(''.join(map(decode,cipher)))
PY
```

**Vigenere:** requires a repeated keyword. Standard form subtracts keyword letter shifts (A=0), advancing the key on alphabetic characters only:

```bash
python3 - <<'PY'
cipher,key="Lxfopv ef rnhr","LEMON"  # ordinary example
key=''.join(x for x in key.upper() if x in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
if not key: raise ValueError("Keyword missing")
result=[]; i=0
for c in cipher:
    if c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
        start=ord('A') if c.isupper() else ord('a')
        result.append(chr(start+(ord(c)-start-(ord(key[i%len(key)])-65))%26))
        i+=1
    else: result.append(c)
print(''.join(result))
PY
```

If the output is nearly readable, check key, shift direction, nonletter handling and whether the question gives a different alphabet.

### XOR and supplied pad key

XOR uses **bytes**, not visual characters. A one-time-pad-style question often provides a key exactly as long as the ciphertext, both hex or Base64:

```bash
python3 - <<'PY'
cipher_hex="08070f0f0c"
key_hex="4062636363"
cipher,key=bytes.fromhex(cipher_hex),bytes.fromhex(key_hex)
if len(cipher)!=len(key): raise ValueError("Key and ciphertext lengths must match")
plain=bytes(a^b for a,b in zip(cipher,key))
print(plain.decode('utf-8'))
# Hello
PY
```

If Base64 strings are provided, decode with `base64.b64decode`. If key is literal UTF-8, use `key_text.encode('utf-8')`. **Repeating XOR** is not the same as a one-time pad: repeat the key only if the question says to.

If output is garbage, check byte encoding, key length, pasted whitespace and whether you XORed encoded characters instead of decoded bytes.

### GPG, OpenSSL and real encryption

Unlike Base64/ROT13, modern encryption requires the **correct key and full format** (mode, IV/nonce, salt, authentication tag, etc.).

1. Hash and preserve the original encrypted file.
2. Run `file /path/message` and inspect header bytes. Look for `-----BEGIN PGP MESSAGE-----`, a `.gpg` file, `Salted__`, or a named cipher/mode.
3. Search the prompt and nearby files for the **authorized passphrase, key file or recipient key**.
4. Decrypt to a **new destination**. Never overwrite the original.
5. Verify file signature, expected plaintext and answer format; do not execute output.

Read-only PGP metadata:

```bash
gpg --list-packets /path/message.gpg
gpg --list-keys
gpg --list-secret-keys
```

Decrypt only if the authorized key/passphrase is available:

```bash
gpg --output /tmp/decoded-copy.txt --decrypt /path/message.gpg
```

If the prompt specifically says **OpenSSL AES-256-CBC with PBKDF2**:

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -in /path/message.enc -out /tmp/decoded-copy.bin
```

This requires the correct passphrase. `openssl enc` is **not** a general AES-GCM decryption tool; nonce/tag handling differs. An unknown salt or incompatible KDF causes failure even with a valid-looking password.

**A hash is not encryption.** SHA256, MD5, SHA1 and NTLM hashes are not recoverable plaintext through `base64 -d`. Use only coach-approved offline tools for specifically supplied practice password-hash challenges.

### Archives and password-protected ZIPs

Read-only inventory:

```bash
file /path/archive
ls -lah /path/archive
unzip -l /path/archive.zip            # if unzip installed
tar -tf /path/archive.tar.gz          # listing only
7z l /path/archive.7z                 # if already installed
```

If password-protected, find the **key** in the question, filename, README, sibling text files or other hints. Extract a **copy** into a permitted scratch directory only after answering any questions about the original archive.

Do not upload evidence to random decryptor sites or execute unknown extracted programs. Some ZIP variants use AES and are unsupported by older `unzip` builds.

### File hashes and checksums

Use the exact requested algorithm on the **original file**:

```bash
sha256sum /path/file
sha1sum /path/file
md5sum /path/file
sha512sum /path/file
openssl dgst -ripemd160 /path/file  # when supported by installed OpenSSL provider
```

SHA-256 = 64 hex digits; MD5 = 32; SHA-1 and RIPEMD160 often = 40. Length alone cannot prove the algorithm. Recompute the same digest twice and check for changed bytes/paths. Hashes are for comparison/integrity, **not decryption**.
