# Linux forensic questions — searchable Debian, Mint and Ubuntu handbook

For CyberPatriot-style **Debian 12/13, Linux Mint and Ubuntu** images. Keep this guide open and use **Ctrl+F** for words in the prompt: `Base64`, `ROT13`, `UID`, `ELF`, `hash`, `MP3`, `cron`, `systemd`, `SSH`, `XOR`, `encrypted`, etc.

**Answer the forensic-question files before hardening.** Copy the exact wording and requested output format, inspect the original evidence, type the answer after `ANSWER:`, save the question file, and check the Scoring Report. Do not purge software, reset a user, erase evidence or kill suspicious processes just to investigate.

This is a **method handbook**, not an answer list for another image. Filenames, users, keys, and timestamps below are samples. Do not install tools or upload private evidence to websites unless the round and coach allow it.

Also see [Windows forensics](windows.md), [Windows Server forensics](windows-server.md), the [Debian handbook](../Linux/debian.md), [Linux Mint handbook](../Linux/linux-mint.md), and [Ubuntu handbook](../Linux/ubuntu.md).

## ⭐ Easiest websites for decoding and investigating

**Only use websites if the round allows them.** Prefer the built-in commands below or an approved **offline CyberChef** copy when the material contains passwords, private keys, domain details, PCAP contents, sensitive filenames, or other nonpublic evidence. A browser site is not permission to disclose a file. **Never paste a real password or private key into a web decoder.**

| Website | Best for | What to click / enter |
|---|---|---|
| **[CyberChef — GCHQ](https://gchq.github.io/CyberChef/)** | **Best overall:** Base64, hex, ROT13, reverse text, XOR, binary, hashes, URL, compression, multiple layers | Paste safe sample text into **Input** (top right), search an operation on the **left**, drag it to **Recipe** (middle), inspect **Output** (bottom right). Stack operations **in order**; hover for help, and use **Magic** only as a clue |
| **[Cryptii](https://cryptii.com/)** | Simpler visual **Base64 → ROT13 → Reverse** chains, ASCII, Morse, Vigenère | Create conversion/cipher steps, choose **Decode**, put in the given text and compare each intermediate result |
| **[dCode Cipher Identifier](https://www.dcode.fr/cipher-identifier)** | Unknown cipher or encoded message; hints such as Rail Fence, Bacon, Polybius, pigpen | Paste **permitted practice text** → **Analyze** → use the clues/keywords and compare likely cipher families; no automatic result is guaranteed |
| **[Wireshark User Guide](https://www.wireshark.org/docs/wsug_html_chunked/)** | Exact PCAP display filters and Follow Stream help | Read **Filtering Packets** / **Following Protocol Streams**; open captures in the installed Wireshark, not in a public upload site |
| **[dCode Affine](https://www.dcode.fr/affine-cipher)** | Affine cipher with `a`/`b` values | Paste ciphertext under **Affine Decoder**, enter exact `A` and `B`, click **Decrypt** |
| **[dCode Vigenère](https://www.dcode.fr/vigenere-cipher)** | Vigenère keyword puzzles | Paste ciphertext, select **Knowing the Key/Password**, enter key, click **Decrypt** |
| **[DenCode Cipher](https://dencode.com/en/cipher)** | Caesar, ROT13, Atbash, affine, Vigenère comparisons | Paste **practice or permitted** ciphertext and inspect the appropriate **Decoded** result |
| **[HexEd.it](https://hexed.it/en/)** | View a file's **first five bytes**, magic number, and hex/ASCII columns | **Open file** in the browser editor, look at **offset `00000000`**, read first N bytes in the hex column; **do not edit/save over** the original |
| **[VirusTotal Search](https://www.virustotal.com/gui/home/search)** | Look up whether a **known file hash** has been reported before | Enter **only a permitted SHA-256 hash** in **Search** (not Upload); a clean/unknown result proves neither safety nor that a file is authorized |
| **[CyberChef source / offline copy](https://github.com/gchq/CyberChef)** | Work without internet after approved setup | Use a permitted local copy instead of relying on a live website; do not download outside tools against round rules |

**CyberChef privacy detail:** Its project states processing happens locally in the browser, and HexEd.it makes a similar claim. Still, loaded data can be revealed if you **share a CyberChef URL containing input**, copy screenshots, use an untrusted browser, or install unwanted extensions. For confidential image content, prefer the offline copy or the exact commands below. Do not upload full VM images, credential databases, or private keys to other services.

### Three fastest website recipes (Ctrl+F: website, online decoder, CyberChef, Cryptii)

1. **Base64 → ROT13**: Open **CyberChef** → paste exact Base64 text in Input → search **From Base64** and add it to Recipe → search **ROT13** and add it **below** From Base64 → read final Output. In Cryptii use **Base64 Decode**, then **ROT13 Decode**. If the result looks like a phrase with weird casing, verify the final letter case against the question.
2. **ROT13 → Reverse Text**: Paste scrambled text → apply **ROT13**, then **Reverse Text**. For example the intermediate text might become backwards-readable; add **Reverse Text** rather than changing the ROT alphabet. Watch whether the problem asks you to reverse *characters* versus *word order*.
3. **Hex → ASCII**: Paste an even-length string of hex characters → apply **From Hex** (recognize bytes, not decimal numbers) → read Output as UTF-8/ASCII. If it shows garbage, switch to **To Hex/Hex view** and inspect magic bytes before interpreting as plain text.

For **XOR**, CyberChef can accept a supplied key; set **key encoding (hex, Base64-derived bytes, or UTF-8 text)** and the exact mode indicated by the prompt. It is not the same as applying XOR to the literal characters of a hex string. For **AES/GPG**, the algorithm name is insufficient: you need the correct key plus mode/IV/salt/tag. For **password hashes**, no website can simply reverse arbitrary SHA-256/NTLM into plaintext.

## Ctrl+F question finder

| Question keywords | Where to look |
|---|---|
| cipher, encryption, cryptogram, decode, layers, plaintext | [Decision tree](#decoding-decision-tree) |
| Base64, base 64, `=`, `==`, `Qenpnelf` | [Base64 and ROT13](#base64-then-rot13-layered-example) |
| ROT13, Caesar, shift, rotate, reverse, backwards | [ROT13 and Caesar](#rot13-caesar-and-reverse-text) |
| hex, hexadecimal, ASCII from hex, ELF, first five bytes | [Hex and magic bytes](#hex-encoding-and-magic-bytes) |
| binary, octal, ASCII codes, URL `%20`, HTML, Unicode, Morse | [Other encodings](#binary-decimal-octal-url-html-unicode-and-morse) |
| ROT47, Rail Fence, Bacon, Polybius, Pigpen, A1Z26, QWERTY/keyboard, JWT, columnar transposition | [Less common cipher types](#less-common-puzzle-types-rot47-rail-fence-bacon-polybius-pigpen-a1z26-keyboard-shift) |
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

**⭐ EASIEST WAY — website if permitted:** [CyberChef](https://gchq.github.io/CyberChef/) → paste the original Base64 text → **From Base64 → ROT13**. Or use [Cryptii](https://cryptii.com/) and chain **Base64 Decode → ROT13 Decode**. The answer is the **second** decoded output, not the intermediate ROT13 text.


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

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) → **ROT13 → Reverse Text**, or [Cryptii](https://cryptii.com/) with the same two steps. [DenCode](https://dencode.com/en/cipher) is convenient for a different Caesar shift.


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

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) → **From Hex** for plain text, or [HexEd.it](https://hexed.it/en/) → **Open file**, inspect offset `00000000` for the **exact first five bytes**, such as an ELF prefix. Don't use a text decoder when the answer requests hex bytes.


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

**⭐ WEBSITE OPTION:** [dCode Affine](https://www.dcode.fr/affine-cipher) → enter the exact affine coefficients `a`, `b` → Decrypt. [dCode Vigenère](https://www.dcode.fr/vigenere-cipher) → enter the supplied key → Decrypt. [DenCode](https://dencode.com/en/cipher) offers several cipher types on one page.


**Atbash:** reverse the alphabet (`A↔Z`, `B↔Y`) and preserve punctuation/case. It needs no key.

**Affine:** A=0 through Z=25; encryption `E(x)=(a*x+b) mod 26`, decryption uses the multiplicative inverse of `a`. If `gcd(a,26)` is not 1, an inverse doesn't exist.

```bash
python3 - <<'PY'
a,b = 1,3
cipher = "Khoor"
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

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) includes file-hash operations; if allowed, inspect a local, non-confidential file there and independently verify with the exact `sha256sum`/`openssl` command below. Never substitute a different hash algorithm.


Use the exact requested algorithm on the **original file**:

```bash
sha256sum /path/file
sha1sum /path/file
md5sum /path/file
sha512sum /path/file
openssl dgst -ripemd160 /path/file  # when supported by installed OpenSSL provider
```

SHA-256 = 64 hex digits; MD5 = 32; SHA-1 and RIPEMD160 often = 40. Length alone cannot prove the algorithm. Recompute the same digest twice and check for changed bytes/paths. Hashes are for comparison/integrity, **not decryption**.

## Less common puzzle types — ROT47, Rail Fence, Bacon, Polybius, Pigpen, A1Z26, keyboard shift

When Ctrl+F finds a **rare cipher name**, start with the clue, not a guessed key. [dCode Cipher Identifier](https://www.dcode.fr/cipher-identifier) can suggest likely cipher families for a **permitted, non-sensitive** ciphertext; use its **Clues/Keywords** box if you know a hint. [DenCode Cipher](https://dencode.com/en/cipher) has ROT47, Rail Fence, Bacon and other classical options; [CyberChef](https://gchq.github.io/CyberChef/) has ROT47, To/From Character Code, Morse and related operations. Results from an automatic identifier are **hypotheses**, not guaranteed plaintext.

| Ctrl+F keywords | How to recognize it | First investigation |
|---|---|---|
| **ROT47**, `!`, `?`, symbols | Text uses many visible ASCII punctuation symbols | [DenCode](https://dencode.com/en/cipher) → **Decoded → ROT47**; compare readable output |
| **Rail Fence**, **zigzag**, **rails**, **transposition** | Same letters, order scrambled in alternating rows | Try the given **rail count** in [DenCode](https://dencode.com/en/cipher), then check all text was preserved |
| **Columnar transposition**, **route cipher** | Letters appear permuted according to a keyword/grid | Look for the **column number, key order or grid shape**; try [Cipher Identifier](https://www.dcode.fr/cipher-identifier) for the right solver |
| **Bacon**, **Baconian**, `AABBA` | Runs of A/B or two different fonts/styles | Group into **five-symbol** units; [DenCode](https://dencode.com/en/cipher) → Baconian; verify I/J/U/V variant |
| **Polybius square**, **tap code**, `11 23 45` | Digits 1–5 in **pairs** | Convert pairs via a **5×5 square**; check whether I/J share a cell and whether key reshuffles alphabet |
| **A1Z26**, `1-26`, number-letter | Integers from 1 through 26 | Map `1=A ... 26=Z`, preserving separators; don't treat as decimal ASCII without a reason |
| **Pigpen**, **symbol cipher**, geometric shapes | Grids, X shapes and dots instead of ordinary letters | Search the cipher name in [dCode Identifier](https://www.dcode.fr/cipher-identifier); compare the supplied symbol chart |
| **Keyboard shift**, **QWERTY**, **left/right key** | Nonsense produced by neighboring keyboard keys | Check **keyboard layout and direction**; distinguish a QWERTY shift from Caesar alphabet shift |
| **Morse**, **dot dash**, `... --- ...` | Dots/dashes, spaces and `/` word separators | Use [CyberChef](https://gchq.github.io/CyberChef/) → **From Morse Code**, preserving word breaks |
| **JWT**, `eyJ...`, three dot-separated sections | `header.payload.signature` is usually Base64URL | Decode **header/payload** for readable JSON; do **not** mistake decoding for signature verification or claim token authenticity |

**Unknown cipher in the middle of a layered puzzle:** save the exact intermediate result, then use CyberChef **Magic** or dCode Identifier only to narrow down candidate transforms. Do not try unrelated ciphers on a SHA-256 hash or genuine AES ciphertext; without a key, an automatic "decoder" may confidently return nonsense.

## Finding files, owners and hidden evidence

### Search files and parent directories

GUI: Home folder → search name or extension; **Ctrl+H** shows hidden dotfiles in many Linux file managers.

Find MP3s (live `find` is safer than relying on a stale `locate` database):

```bash
sudo find /home -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.mp4' -o -iname '*.mkv' \) -print 2>/dev/null
```

If asked for the **directory containing** a media file, submit the **parent directory**, not just a filename:

```bash
dirname -- '/home/example/Music/song.mp3'
readlink -f -- '/home/example/Music'
```

If no result in the expected home directory, expand to:

```bash
sudo find /srv /opt /tmp /var/tmp -type f -iname '*keyword*' -print 2>/dev/null
sudo find / -type f -iname '*keyword*' -print 2>/dev/null
```

Avoid `sudo updatedb` solely to solve a path question when a live `find` works. If using `locate`, remember its index may not reflect recent files.

### UID, GID and orphaned file owners

Common prompt: "Which file is owned by UID **1951** even though no account has that UID?"

```bash
id username
id -u username
getent passwd 1951
sudo find / -xdev -uid 1951 -ls 2>/dev/null
sudo find / -xdev -nouser -ls 2>/dev/null
```

If `-xdev` does not find it, try other mounted filesystems or omit `-xdev` after checking what is mounted.

Verify the actual numeric owner:

```bash
stat -c 'file=%n UID=%u GID=%g owner=%U group=%G mode=%a' /path/to/file
ls -ln -- /path/to/file
getent passwd 1951
```

An orphaned numeric UID can remain on a file even after the user account was deleted. This is a documented **Debian practice question pattern**. Do not automatically change ownership before answering.

### Users, groups and UID zero

```bash
getent passwd
getent group
getent group sudo
id username
awk -F: '$3==0 {print $1,$3,$6,$7}' /etc/passwd
getent passwd | awk -F: '$3==0'
```

Normally root has UID 0. Additional UID-0 accounts warrant investigation. Distinguish a **human user** from a legitimate service account, and distinguish sudo-group membership from a user-specific `sudoers` permission.

### Permissions, SUID, capabilities and ACLs

```bash
stat -c '%A %a %U:%G %u:%g %n' /path/to/file
namei -l /path/to/file
sudo find /usr /bin /sbin -xdev -type f -perm /4000 -print 2>/dev/null
getcap -r /usr /opt 2>/dev/null
getfacl /path/to/file                    # if available
```

A question may request numeric permission mode (`640`), owner, group, `setuid`, a Linux capability, or an extended ACL. These are different properties. Do not use `chmod`, `chown`, `setcap` or SUID removal to **answer** a question.

### Unsafe C functions and source code

If the question mentions a `.c` source file or "unsafe standard library function", read the source **without executing it**:

```bash
nl -ba "$HOME/Desktop/example.c" | less
grep -nE '(^|[^[:alnum:]_])(gets|strcpy|strcat|sprintf|scanf|system|tmpnam|mktemp)[[:space:]]*\(' "$HOME/Desktop/example.c"
```

`gets`, unchecked `strcpy`/`strcat` and unbounded `sprintf` are common clues, but **a name appearing does not by itself prove the call is vulnerable**. Check the call's parameters, buffer sizes, and the prompt. Search through includes/macros and comments if the apparent answer is missing.

The supplied research contains a Debian-specific example involving an insecure function in a C source file. Use the *method* above; do not guess the answer from the exercise filename.

### Hidden files and misleading extensions

```bash
find "$HOME" -type f -name '.*' -print
sudo find /home /tmp /var/tmp /dev/shm -type f -mtime -2 -print 2>/dev/null
file -- /path/suspicious.dat
od -An -tx1 -N16 /path/suspicious.dat
strings -a -n 5 /path/suspicious.dat | head -60
```

`strings` finds possible hints, not proof of malicious content. A `.txt` file may actually be ELF/ZIP/PDF/PNG. Inspect bytes rather than believing the extension.

### Metadata and timestamp questions

```bash
stat /path/file
stat -c 'mode=%a owner=%U:%G UID=%u GID=%g size=%s mtime=%y ctime=%z birth=%w name=%n' /path/file
sudo find /home /tmp /var/tmp -type f -mmin -1440 -printf '%TY-%Tm-%Td %TH:%TM:%TS %u %p\n' 2>/dev/null
```

**mtime** = content modification; **ctime** = inode metadata change (not creation); **atime** = last access, often suppressed; **birth** may be unavailable. A time sequence needs corroboration from shell/log/package events. A file's creation time after copying may reflect the **copy**, not the original.

### Image, audio and steganography

Search `steganography`, `hidden text`, `LSB`, `metadata`, `EXIF`, `QR`, `waveform`, `spectrogram`, `embedded ZIP`.

1. Look at the visible image/audio first, including rotation, contrast, subtitles and QR codes.
2. Read `file`, `stat`, `sha256sum`, and first-byte hex before interpreting content.
3. If installed and permitted, `exiftool /path/image.jpg` or `identify -verbose /path/image.png` can show metadata without editing the file.
4. Look for appended archive data or suspicious size (use a **copy** for extraction).
5. If sound is involved, listen with an approved player or inspect a spectrogram in an already installed audio editor.
6. For LSB steganography, use an approved offline tool only when the prompt provides a reason; a failed stego guess is not proof there is no hidden data.

## Linux accounts, logs, services and network questions

### Bash history and command evidence

```bash
history                         # only the current shell's known history
sudo find /home /root -name '.bash_history' -type f -print 2>/dev/null
sudo grep -RniE 'curl|wget|nc |netcat|sudo|useradd|passwd|cron|systemctl' /home --include='.bash_history' 2>/dev/null
sudo grep -HniE 'curl|wget|nc |netcat|sudo|useradd|passwd|cron|systemctl' /root/.bash_history 2>/dev/null
```

**Limit:** history may not be written until logout; it can be disabled, deleted, modified or incomplete. Cross-check with the journal and files, not assumptions.

### Authentication logs and SSH logins

On Debian/Ubuntu/Mint systems where rsyslog auth logs exist:

```bash
sudo grep -Ei 'Accepted|Failed|Invalid user|sudo|session opened|useradd' /var/log/auth.log 2>/dev/null
sudo zgrep -Ei 'Accepted|Failed|sudo' /var/log/auth.log*.gz 2>/dev/null
```

If there is no `/var/log/auth.log`, use journal:

```bash
sudo journalctl -u ssh --no-pager | grep -Ei 'Accepted|Failed|Invalid'
sudo journalctl -t sshd --no-pager | tail -100
sudo journalctl -g 'Failed password|Accepted password|sudo|useradd' --no-pager
```

Cross-check account, time, source IP, password/public-key method and **success versus failure**. Optional:

```bash
last -a | head -35
sudo lastb | head -35      # may be unavailable on this image
who
```

### journalctl and time windows

```bash
sudo journalctl --since '2026-11-01 00:00:00' --until '2026-11-02 00:00:00' --no-pager
sudo journalctl -u ssh --since '1 day ago' --no-pager
sudo journalctl -p warning -n 100 --no-pager
journalctl --list-boots
timedatectl
```

If results are missing, check timezone, unit name (`ssh` or `sshd`), log permissions, retention, boot ID and whether persistent journaling is enabled. Don't assume logs survived reboot.

### Cron and systemd persistence

```bash
sudo crontab -l
sudo cat /etc/crontab
sudo ls -la /etc/cron.d /etc/cron.daily /var/spool/cron/crontabs 2>/dev/null
systemctl list-timers --all
systemctl list-unit-files --type=service
systemctl --user list-timers --all
```

All user crontabs, if authorized:

```bash
while IFS=: read -r username ignored; do
  printf '\n===== %s =====\n' "$username"
  sudo crontab -u "$username" -l 2>/dev/null
done < /etc/passwd
```

Inspect a suspicious installed unit **without executing it**:

```bash
systemctl cat NAME.service
systemctl show NAME.service -p ExecStart -p User -p FragmentPath
sudo find /etc/systemd/system -maxdepth 3 -type f -print
```

A cron entry containing `nc` or `netcat` could be malicious or a legitimate tool. Record **full command, user, file, network port and current PID**; do not stop/delete a process before answering a question about it.

### APT, dpkg, Snap and Flatpak history

```bash
sudo grep -Ei 'Install:|Upgrade:|Remove:|Purge:' /var/log/apt/history.log 2>/dev/null
sudo grep -Ei ' install | upgrade | remove | purge ' /var/log/dpkg.log 2>/dev/null
sudo zgrep -Ei ' install | upgrade | remove | purge ' /var/log/dpkg.log*.gz 2>/dev/null
dpkg-query -W -f='${Package}\t${Version}\t${Status}\n' PACKAGE
apt-mark showhold
```

Ubuntu images may have `snap list`, `snap changes`; Mint and other desktops may have `flatpak list` and `flatpak history` where supported. **Don't install or purge a package to answer a version/history question.**

### Processes and open ports

```bash
ps auxf
ps -eo pid,ppid,user,etime,cmd --sort=pid | less
sudo ss -lntup
sudo ss -tunp
sudo lsof -nP -iTCP -sTCP:LISTEN        # if installed
readlink -f /proc/1234/exe             # replace PID from this VM
tr '\0' ' ' < /proc/1234/cmdline
```

A **PID** is not a port. In `ss`, `:PORT` is in the local address field; `pid=...` is a process identifier shown when permitted. A process can own multiple sockets.

```bash
ip -br address
ip route
resolvectl status 2>/dev/null
```

### PCAP and Wireshark

With a supplied `.pcap` or `.pcapng` and an approved installed Wireshark:

1. File → Open the **copy** of the capture.
2. Use display filters: `ip`, `tcp`, `udp`, `dns`, `http`, `tcp.port == 22`, `ip.src == 192.0.2.10`.
3. Inspect **Source**, **Destination**, timestamps, packet fields and **Follow → TCP Stream** when relevant.
4. Use **Statistics → Endpoints/Conversations** for counts, not guesses from the most visible packet.

If `tshark` exists:

```bash
tshark -r /path/traffic.pcap -T fields -e frame.number -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport
```

If `tcpdump` exists:

```bash
tcpdump -nn -r /path/traffic.pcap | head -60
```

HTTPS/TLS traffic is encrypted without authorized session keys. The prompt may only require IP/port/DNS/packet metadata, not decrypted application content.

### Samba, NFS shares and mounts

```bash
findmnt
mount | head -50
grep -v '^\s*#' /etc/fstab
testparm -s                         # if Samba installed
grep -nE '^\[|path\s*=|valid users|guest ok' /etc/samba/smb.conf 2>/dev/null
sudo exportfs -v                    # if NFS tools installed
```

Distinguish **share name**, filesystem path, allowed users, NFS export target and actual Linux file permissions. Do not remove a share before answering a question about its location.

### Certificates, signatures and keys

```bash
openssl x509 -in /path/cert.pem -noout -subject -issuer -dates -serial -fingerprint -sha256
openssl x509 -in /path/cert.pem -noout -text | head -80
```

For DER certificates add `-inform DER`. A `BEGIN CERTIFICATE` public certificate differs from a `BEGIN PRIVATE KEY` secret key. Do not paste or export unrelated private-key material. A certificate fingerprint is not the same as a file SHA-256 digest.

## If Ctrl+F did not find your question

1. Identify the **answer type** (filename/path, username/UID/GID, byte sequence, plaintext, hash, PID/port, timestamp, package, certificate).
2. Identify the **artifact** (Desktop file, code, binary, archive, account database, auth logs, cron, systemd, PCAP, share, certificate, browser).
3. Choose the closest topic here and use **one narrow read-only command**. Replace sample names/paths with the actual prompt's values.
4. If nothing is found, **expand scope** (single home → `/home` → `/srv` and `/opt` → `/`; `-xdev` versus cross-mounted) and inspect dotfiles, compressed logs, stale indexes, alternate users and paths.
5. For decoding, save intermediate outputs; check **hex versus Base64**, **bytes versus UTF-8**, **ROT direction**, **reverse order**, **key text versus key bytes** and required file headers.
6. For "command not found", use an installed equivalent: `od` instead of `xxd`; `journalctl` instead of `auth.log`; Python 3 stdlib instead of a web decoder. Do not automatically install a tool.
7. Read the question again: **full directory** differs from filename, **UID** from username, **mtime** from `ctime`, and **local port** from remote port.
8. Record current evidence, move on to another question, and return with a more precise search term.

Notes template: `question wording | requested answer type | file/user/PID | commands | exact output | verification`. Submit only the requested answer after `ANSWER:` in the actual question file.

## Sources and scope

Created from the supplied **CyberPatriot Forensics Question Research Report**, **CP19 Debian 12 Training Round 2 Answer Key**, and **CP19 Round 1 categories**. Examples show methods rather than publishing a complete current-season answer key. The presence of a technique here does **not** establish that it appeared in an official past round.

- [Debian handbook](../Linux/debian.md) · [Mint handbook](../Linux/linux-mint.md) · [Ubuntu handbook](../Linux/ubuntu.md).
- [systemd journalctl documentation](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html).
- [Debian dpkg-query manual](https://manpages.debian.org/dpkg-query).
- [CyberChef open-source project](https://github.com/gchq/CyberChef) for approved offline layered decoding.

No document can predict **every future forensic question**. This is intended as a searchable starting procedure with clear fallback steps rather than a promise of guaranteed answers.
