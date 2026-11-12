# Windows 10/11 forensic questions — searchable investigation and decoding handbook

For CyberPatriot-style **Windows 10/11 workstation** images. Keep this open in GitHub and press **Ctrl+F** for the exact word in the prompt, such as `ROT13`, `port`, `hash`, `share`, `owner`, `cipher`, `PID`, `zip`, or `Event ID`.

**Start with the forensic-question files on the desktop, before hardening.** Copy the wording (including requested output format), answer in the original file after `ANSWER:`, save with **Ctrl+S**, and check the Scoring Report. Never delete, rename, execute, unzip into the evidence directory, reset a password, stop a process, or change logs before recording what the question asks.

This is a **method handbook, not an answer key for a particular image**. Exact paths and sample strings are examples. All commands are read-only unless explicitly labeled otherwise; do not install tools or upload image data to websites unless your competition rules and coach allow it.

Related: [Windows 10/11 hardening handbook](../Windows/windows-10-11.md) · [Linux forensics](linux.md) · [Windows Server forensics](windows-server.md).

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

| Search these words from your question | Go to |
|---|---|
| cipher, cryptogram, decrypt, encode, decode, encoded text, layers, plaintext | [Decoding decision tree](#decoding-decision-tree-read-first) |
| Base64, base 64, `=` or `==` ending, `SGVsbG8=` | [Base64](#base64) |
| hex, hexadecimal, ASCII from hex, `52756e...`, `0x`, bytes | [Hex and character encoding](#hex-and-character-encoding) |
| ROT13, ROT 13, reverse, backwards, mirrored, Caesar, shift | [ROT13 and reverse](#rot13-caesar-and-reversing-text) |
| ROT47, Rail Fence, Bacon, Polybius, Pigpen, A1Z26, QWERTY/keyboard, JWT, columnar transposition | [Less common cipher types](#less-common-puzzle-types-rot47-rail-fence-bacon-polybius-pigpen-a1z26-keyboard-shift) |
| Atbash, affine, `a=1`, `b=3`, substitution | [Classical ciphers](#atbash-affine-and-vigenere) |
| Vigenère, Vigenere, keyword cipher | [Classical ciphers](#atbash-affine-and-vigenere) |
| XOR, OTP, one-time pad, supplied key, known key, hex key | [XOR and one-time-pad puzzles](#xor-and-one-time-pad-puzzles) |
| 0 and 1, binary, decimal ASCII, octal, Morse | [Other encodings](#binary-decimal-octal-morse-url-and-html) |
| `%20`, URL encoded, `&#`, Unicode escapes, HTML entities | [Other encodings](#binary-decimal-octal-morse-url-and-html) |
| AES, RSA, PGP, GPG, OpenSSL, encrypted file, DPAPI, CMS | [Real encryption](#real-encryption-keys-and-protected-files) |
| password-protected ZIP, 7z, archive, brute-force, key file | [Archives](#password-protected-archives-and-password-clues) |
| hash, digest, MD5, SHA-1, SHA-256, SHA-512, RIPEMD-160 | [Hashes](#file-hashes-including-ripemd-160) |
| hidden file, file path, folder, extension, filename, Brutus, MP3 | [File discovery](#find-files-hidden-files-and-folders) |
| magic bytes, file header, ELF, PNG, JPEG, PDF, PE, EXE | [File signatures](#file-signatures-and-misleading-extensions) |
| metadata, EXIF, created, modified, author, file version | [Metadata](#file-metadata-and-executable-version) |
| alternate data stream, Zone.Identifier, ADS | [Alternate data streams](#alternate-data-streams-and-hidden-content) |
| steganography, image clue, QR, audio, spectrogram | [Steganography](#image-audio-and-steganography) |
| user, SID, username, administrator, group, Event Log Readers | [Users and groups](#users-sids-and-local-groups) |
| hostname, FQDN, full computer name, domain | [Computer identity](#computer-name-and-domain) |
| IP, source address, destination, port, connection, PID, netstat | [Network](#ports-pids-connections-and-pcap) |
| PCAP, pcapng, Wireshark, HTTP request, DNS query, packet | [PCAP](#pcap-and-wireshark) |
| Event Viewer, failed login, user created, logon, audit log | [Event logs](#event-logs-and-time-based-questions) |
| startup, persistence, scheduled task, Run key, service installed | [Persistence](#startup-tasks-registry-and-services) |
| share, hidden share, IPC$, mapped drive, share path | [Shares](#local-and-hidden-network-shares) |
| certificate, thumbprint, serial, issuer, expiration | [Certificates](#certificates-and-public-key-clues) |
| cannot find, no matches, permission denied, weird output | [When stuck](#when-ctrlf-does-not-find-your-question) |

## The first three minutes: preserve and inspect

1. Open **Desktop → Forensics Questions** or each `Forensics Question *.txt` file. Record the requested answer type: **name, full path, number, hexadecimal digest, plaintext, IP address, date or list**.
2. Open **File Explorer → View → Show → Hidden items** and **File name extensions** (Windows 10 uses the View ribbon). Do **not** remove suspicious files yet.
3. Keep PowerShell and Notepad open: **Start → Windows PowerShell → Run as administrator** only if the evidence requires elevation. PowerShell 5.1 is the baseline; newer PowerShell/.NET commands are not assumed.
4. Work from the path or artifact named in the question. Do not run a whole-drive recursive search unless the narrower search fails.
5. Read evidence first, answer second, and **only then** return to scored hardening.

Read a named text file without changing it:

```powershell
Get-Content -LiteralPath 'C:\Users\Public\Downloads\clue.txt' -Raw
```

List the desktop forensic files:

```powershell
Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Force -File |
  Where-Object Name -match 'forensic|question' |
  Select-Object FullName,Length,LastWriteTime
```

For output you need later, copy *only allowed* evidence to an approved private notes directory, calculate SHA-256 first, and leave the original where it is. The image README and round rules decide whether copying evidence is permitted.

## Decoding decision tree — read first

**Encoding** changes representation and requires no secret key. **Encryption** requires a cipher and key. **Hashing** is one-way; a SHA-256 or NTLM hash cannot simply be "decoded" into the original password.

1. **What are the characters?** Only `0-9 A-F` of even length → try hex. Letters/digits plus `/+` and optional `=` → try Base64. Groups of eight `0/1` → try binary ASCII. Mostly normal letters but nonsense → try ROT13, reverse, Caesar, Atbash or a supplied-key cipher.
2. **Check the prompt for hints:** `shift`, `rot`, `key`, `a`, `b`, `XOR`, `Vigenere`, `AES`, `base`, `binary`, `reverse`, `one-time pad`. A supplied key is usually essential, not decorative.
3. **Decode exactly ONE layer**, then inspect that output. If you get another encoded-looking string, try the next layer. Do not reverse the order without a reason.
4. **Byte versus text:** Hex/Base64 may decode to arbitrary binary. If the output begins with `PK`, `%PDF`, `MZ`, `7F 45 4C 46`, PNG bytes, or unreadable characters, inspect the file signature rather than forcing UTF-8 text.
5. **Validate:** Does the answer form a grammatical phrase, recognizable path or requested hex string? Check spaces, punctuation and case against the answer format.
6. **No key available?** Search for a `.key`, README hint, adjacent clue file, certificate or explicit password. Genuine modern encryption cannot be reliably broken just by guessing the algorithm.

**Common layered recipes to search:** `Base64 → ROT13`; `ROT13 → reverse`; `hex → ASCII`; `Base64 → hex → XOR`; `reverse → Base64`; `URL decode → Base64`; `Caesar → reverse`. The direction matters.

For a permitted visual decoder, an approved **offline/local CyberChef** copy can chain `From Base64`, `ROT13`, `Reverse text`, `From Hex`, `XOR`, and `To Hex`. Avoid pasting sensitive evidence into a third-party site. A generic website or "Magic" guess is a hint, not proof; see [CyberChef](https://github.com/gchq/CyberChef).

### Base64

**⭐ EASIEST WAY — website if permitted:** [CyberChef](https://gchq.github.io/CyberChef/) → paste the exact Base64 message in **Input** → add **From Base64** to the Recipe → read Output. If it is another cipher, drag **ROT13** or **Reverse Text** *below* it. A simpler alternative is [Cryptii](https://cryptii.com/) with **Base64 Decode**.


Recognition: strings like `SGVsbG8=`, often 4-character groups; `+`, `/`, `=` are common but not mandatory. Base64URL uses `-` and `_`. **Decode** means converting the Base64 characters into bytes; then decide if the bytes are text.

```powershell
$encoded = 'SGVsbG8='
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($encoded))
# Hello
```

From a file:

```powershell
$encoded = (Get-Content -LiteralPath 'C:\path\clue.txt' -Raw).Trim()
$bytes = [Convert]::FromBase64String($encoded)
[Text.Encoding]::UTF8.GetString($bytes)
```

If text is readable but scrambled, apply the next indicated operation (for example ROT13). If the bytes are binary, display the first bytes rather than claiming it is text:

```powershell
[BitConverter]::ToString($bytes[0..([Math]::Min(15,$bytes.Length-1))])
```

**If "invalid Base64":** remove line breaks, inspect hidden spaces, add the missing padding only if the question format supports it, and check whether it is Base64URL. Do not strip arbitrary characters from evidence. Never run decoded code.

### Hex and character encoding

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) → **From Hex**; for an actual file's first bytes, use [HexEd.it](https://hexed.it/en/) → **Open file** → read the leftmost hex values from offset `00000000`. No need to install a hex editor for a short byte question if the site is permitted.


Recognition: `48 65 6c 6c 6f`, `48656c6c6f`, or `0x48 0x65...`; hex uses two digits per byte. A common mistake is to decode the **literal characters** `4` and `8` instead of the byte `0x48`.

PowerShell **5.1-compatible** method (do not use `.NET Convert.FromHexString`, which may be unavailable on this image):

```powershell
$hex = '48 65 6c 6c 6f' -replace '(?i)0x','' -replace '[\s:-]',''
if ($hex.Length % 2 -ne 0 -or $hex -notmatch '^[0-9a-fA-F]+$') { throw 'Not valid even-length hex' }
[byte[]]$bytes = @([regex]::Matches($hex,'..') | ForEach-Object {
  [Convert]::ToByte($_.Value,16)
})
[Text.Encoding]::UTF8.GetString($bytes)
# Hello
```

To answer **"first five bytes of the file"**, do not convert the bytes to letters:

```powershell
$path = 'C:\path\file.bin'
$stream = [IO.File]::OpenRead($path)
try {
  [byte[]]$first = New-Object byte[] 5
  $count = $stream.Read($first,0,5)
  ([BitConverter]::ToString($first,0,$count)).Replace('-',' ')
} finally { $stream.Dispose() }
```

If hex output is still not plaintext, it might represent compressed, encrypted, or another encoded payload; inspect magic bytes.

### ROT13, Caesar and reversing text

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) → **ROT13 → Reverse Text**, or [Cryptii](https://cryptii.com/) → ROT13 then reverse. If Caesar shift is not 13, use [DenCode](https://dencode.com/en/cipher) and choose the proper **Decoded → Caesar** shift.


**ROT13** rotates each English letter by 13 positions; digits and punctuation stay unchanged. **Caesar** uses another shift. **Reverse** means reverse *characters*, not word order; some questions require both.

GUI: If the image includes an approved ROT13/offline decoder, paste the ciphertext, apply **ROT13**, inspect the result, then add **Reverse text** only if needed.

PowerShell 5.1 ROT13:

```powershell
$text = 'Uryyb Jbeyq'
$rot13 = -join ($text.ToCharArray() | ForEach-Object {
  $v = [int][char]$_
  if ($v -ge 65 -and $v -le 90) { [char](65+(($v-65+13)%26)) }
  elseif ($v -ge 97 -and $v -le 122) { [char](97+(($v-97+13)%26)) }
  else { $_ }
})
$rot13
# Hello World
```

Then reverse the **characters**:

```powershell
$chars = $rot13.ToCharArray()
[Array]::Reverse($chars)
-join $chars
```

If the message says "backwards", you may need **reverse first, ROT13 second**, or vice versa. Because ROT13 is applied character-by-character, these two particular operations commute; other layered transforms often do not.

For **Caesar shift N**, use the same ROT13 method with `13` replaced by the appropriate shift for decryption. If the question says "encrypted by a shift of 3", normally try **subtract 3**, not add 3. If you are not told the shift, test all 26 and select an intelligible result based on actual evidence, not on a guess.

**Released training-key pattern:** one Windows 11 exercise applied ROT13 and character reversal to obtain an English phrase. Record the final capitalization and spaces exactly as the prompt requires; don't copy a historical answer into another image.

### Atbash, affine and Vigenere

**⭐ WEBSITE OPTION:** [dCode Affine](https://www.dcode.fr/affine-cipher) accepts the exact `a`/`b` coefficients; [dCode Vigenère](https://www.dcode.fr/vigenere-cipher) accepts a keyword. [DenCode](https://dencode.com/en/cipher) compares Atbash, Affine, Caesar and Vigenère. Enter the cipher parameters **from the prompt**.


**Atbash** maps `A↔Z`, `B↔Y`, etc. It requires no key. On paper write paired alphabets: `ABCDEFGHIJKLMNOPQRSTUVWXYZ` versus `ZYXWVUTSRQPONMLKJIHGFEDCBA`. Preserve punctuation/case.

**Affine cipher:** plaintext letters are numbers 0–25; encryption is `E(x)=(a*x+b) mod 26`. Decryption is `D(y)=a_inverse*(y-b) mod 26`. The multiplier `a` must be coprime to 26; its multiplicative inverse satisfies `a*a_inverse mod 26 = 1`. If `a=1, b=3`, decrypt by shifting each letter **back three**. Find `a`/`b` in the prompt or an adjacent hint before brute-forcing.

For a supplied `a, b`, use this PowerShell method, which leaves punctuation unchanged:

```powershell
$letters = 'Khoor'
$a = 1; $b = 3
$inverse = @(1..25 | Where-Object { ($a * $_) % 26 -eq 1 } | Select-Object -First 1)[0]
if ($null -eq $inverse) { throw 'Affine a is not invertible mod 26' }
-join ($letters.ToCharArray() | ForEach-Object {
  $v = [int][char]$_
  if ($v -ge 65 -and $v -le 90) { [char](65+((($inverse*(($v-65)-$b)%26)+26)%26)) }
  elseif ($v -ge 97 -and $v -le 122) { [char](97+((($inverse*(($v-97)-$b)%26)+26)%26)) }
  else { $_ }
})
# With a=1, b=3, Khoor decodes to Hello. This demonstrates the operation, not a scored answer.
```

**Vigenere:** needs a **keyword**, repeated over letters only. For each alphabetic ciphertext character, subtract the corresponding keyword letter value (A=0 … Z=25) modulo 26; preserve spaces/punctuation. Example keyword clues may be in filenames or adjacent notes. If a decoded word looks almost correct, check whether nonletters should advance the key; standard Vigenere usually advances only for letters. An approved local cipher utility is simplest for a long ciphertext.

### XOR and one-time-pad puzzles

**XOR** compares byte pairs. A "one-time-pad-style" question often supplies **ciphertext and key**, both hex or Base64; first decode each to bytes, then XOR corresponding positions. A real one-time pad requires a truly random key as long as the message and must not be reused.

Example using two equally long **hex** strings on PowerShell 5.1:

```powershell
$cipherHex = '08070F0F0C'
$keyHex    = '4062636363'
function Hex-Bytes([string]$s) {
  $s = $s -replace '\s',''
  if ($s.Length % 2 -ne 0 -or $s -notmatch '^[0-9a-fA-F]+$') { throw 'Invalid hex' }
  [byte[]]@([regex]::Matches($s,'..') | ForEach-Object { [Convert]::ToByte($_.Value,16) })
}
[byte[]]$cipher = Hex-Bytes $cipherHex
[byte[]]$key = Hex-Bytes $keyHex
if ($cipher.Length -ne $key.Length) { throw 'OTP/XOR question requires the stated key length' }
[byte[]]$plain = for ($i=0; $i -lt $cipher.Length; $i++) { $cipher[$i] -bxor $key[$i] }
[Text.Encoding]::UTF8.GetString($plain)
```

**Check first:** Are the strings ASCII/UTF-8, hex or Base64? Is the key meant to repeat (a **different** repeating-XOR problem) or used once? Does the question specify text encoding? Do not apply a repeating key unless explicitly stated.

If your output is garbage: check whether you XORed **characters** instead of decoded bytes, whether the key is Base64 rather than text, and whether the ciphertext/key contain spaces or line breaks.

### Binary, decimal, octal, Morse, URL and HTML

| Format | How to recognize | Fast local direction |
|---|---|---|
| Binary ASCII | `01001000 01101001` | Split into **8-bit** groups; convert each from base 2 to a byte |
| Decimal ASCII | `72 101 108 108 111` | Each decimal number is a character code |
| Octal | `110 145 154` or `\110\145` | Convert each from base 8 to bytes |
| URL percent | `Hello%20World` | Replace `%HH` byte escapes through a URL decoder |
| HTML entities | `Hello&#32;World`, `&amp;` | HTML-entity decoder (not a Caesar cipher) |
| Unicode `\u` | `\u0048\u0069` | Unicode code-point escapes; not hex bytes |
| Morse | `.... . .-.. .-.. ---` | Dots and dashes; spaces separate letters, `/` often separates words |
| Decimal/hex character sequence | `0x48,0x69` | Decode bytes first, then UTF-8/ASCII text |

PowerShell examples:

```powershell
[Text.Encoding]::ASCII.GetString([byte[]]@(72,101,108,108,111))
[char][Convert]::ToInt32('48',16)
[char][Convert]::ToInt32('110',8)
[Uri]::UnescapeDataString('Hello%20World')
[System.Net.WebUtility]::HtmlDecode('Hello&#32;World')
```

For binary `01001000`, `[char][Convert]::ToInt32('01001000',2)` yields `H`. Decode groups consistently. If output looks shifted, check 7-bit versus 8-bit grouping, byte order, and an initial BOM.

### Real encryption, keys and protected files

Clues: `AES`, `RSA`, `PGP`, `GPG`, `DPAPI`, `CMS`, "private key", "certificate", `BEGIN PGP MESSAGE`, a password-protected ZIP, or binary ciphertext.

1. Preserve the original artifact and its hash.
2. Identify the **container** and format with file signatures/headers first, not by filename.
3. Find the **specified algorithm/mode**, supplied key/password, IV/nonce, salt, tag, encoding and associated key file. For authenticated modes such as AES-GCM, a missing tag prevents verification.
4. Use **only** the authorized key/password provided in the question/image; don't try random third-party sites or dump unrelated users' protected credentials.
5. Decrypt to a **new file**, not over the original; inspect its header, then read it.

**CMS encrypted message** (when the correct private key is already available in the user's Windows certificate store):

```powershell
Get-ChildItem Cert:\CurrentUser\My | Select-Object Subject,Thumbprint,HasPrivateKey
# Only with the authorized recipient key and a known CMS file:
Unprotect-CmsMessage -Path 'C:\path\message.cms'
```

**DPAPI / Windows encrypted credential XML:** A protected credential exported under one Windows user may not decrypt under another user/VM. That is a protection boundary, not necessarily a broken tool. Read-only inspect metadata; don't attempt to extract someone else's private keys.

**Hashes are not encryption.** MD5, SHA-256, SHA-512 and NTLM are digests; changing them "back" into arbitrary plaintext is not a normal decoding operation. If a question supplies a **practice hash** and asks for a password, confirm the exercise's scope and use only coach-approved offline lab tools; a hash alone does not contain a reversible plaintext message.

### Password-protected archives and password clues

GUI first: Right-click **ZIP → Extract All** (or an already installed approved 7-Zip tool). If asked for a password, look for the key in the question, nearby README, file properties, filenames, or a second clue. Work on a **copy** in a permitted scratch directory.

Look for ZIP files without opening executables:

```powershell
Get-ChildItem -Path "$env:USERPROFILE\Desktop","$env:USERPROFILE\Downloads","C:\Users\Public" -Filter *.zip -Recurse -File -Force -ErrorAction SilentlyContinue |
  Select-Object FullName,Length,LastWriteTime
```

A ZIP begins with `50 4B` ("PK"). A renamed archive may still have a ZIP signature. Some archive types use AES encryption not supported by Windows' built-in extractor; use an already-approved compatible tool, not random web decryptors.

If the prompt gives **no password/key**, search for other artifacts first. Do not claim that AES encryption can be reliably broken without the required credentials.

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

## File investigation

### Find files, hidden files and folders

**GUI first:** File Explorer → **This PC**, search the exact filename or a distinctive substring; enable **Hidden items** and **File name extensions**. Check `Desktop`, `Downloads`, `Documents`, `Public`, `AppData`, and the path specified in the question.

For a known suffix or name:

```powershell
Get-ChildItem 'C:\Users' -Recurse -Force -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like '*secret*' -or $_.Extension -in '.zip','.mp3','.txt' } |
  Select-Object FullName,Length,LastWriteTime
```

Search file **contents** (text files, not arbitrary binaries):

```powershell
Get-ChildItem 'C:\Users' -Recurse -Force -File -Include *.txt,*.log,*.ps1 -ErrorAction SilentlyContinue |
  Select-String -SimpleMatch 'KEYWORD' -List -ErrorAction SilentlyContinue |
  Select-Object Path,LineNumber,Line
```

Search all drives **only if necessary**, because it is slow and produces access-denied noise. Use `-LiteralPath` on evidence paths containing `[` or `]` so PowerShell doesn't treat them as wildcards.

If the question asks for the **directory containing** media, report the **parent directory** and not one song's filename:

```powershell
Split-Path -Parent 'C:\Users\Public\Music\sample.mp3'
```

### File signatures and misleading extensions

**⭐ WEBSITE OPTION:** [HexEd.it](https://hexed.it/en/) → **Open file → offset 00000000** → read the first 4–16 hexadecimal bytes. This lets you inspect a renamed file without running it; don't edit/save over evidence.


A file named `.txt` may actually be a binary/ZIP/PNG. Identify the **magic bytes** using the first-byte method above.

| First bytes in hex | Common interpretation |
|---|---|
| `4D 5A` | Windows PE executable (`MZ`) |
| `50 4B 03 04` | ZIP/Office Open XML container |
| `25 50 44 46` | PDF (`%PDF`) |
| `89 50 4E 47 0D 0A 1A 0A` | PNG |
| `FF D8 FF` | JPEG |
| `47 49 46 38` | GIF |
| `7F 45 4C 46` | ELF / Linux executable |
| `52 61 72 21` | RAR archive |
| `37 7A BC AF 27 1C` | 7-Zip archive |

The next byte of an ELF header can indicate **32-bit (01)** versus **64-bit (02)**. A question asking for "first five bytes" wants byte values, not a guess based on extension.

### File hashes including RIPEMD-160

**⭐ WEBSITE OPTION (small, permitted samples only):** [CyberChef](https://gchq.github.io/CyberChef/) → load the file into Input → search the **exact hash operation** (SHA2/MD5/RIPEMD160 as supported). Cross-check using the local commands below. Avoid upload-based hash calculators with sensitive forensic files.


GUI alternatives: `certutil` on Windows, or PowerShell. Hash the **original exact file**, not a renamed, edited or re-encoded copy.

```powershell
Get-FileHash -LiteralPath 'C:\path\file.bin' -Algorithm SHA256
Get-FileHash -LiteralPath 'C:\path\file.bin' -Algorithm MD5
Get-FileHash -LiteralPath 'C:\path\file.bin' -Algorithm SHA512
certutil -hashfile "C:\path\file.bin" SHA256
```

**RIPEMD-160:** `Get-FileHash -Algorithm RIPEMD160` is **not supported** (accepted algorithms are SHA1, SHA256, SHA384, SHA512, MD5). On a Windows PowerShell 5.1 environment where the .NET Framework RIPEMD160 provider exists:

```powershell
$path = 'C:\path\file.bin'
$stream = [IO.File]::OpenRead($path)
$alg = [Security.Cryptography.RIPEMD160]::Create()
if (-not $alg) { $stream.Dispose(); throw 'RIPEMD-160 provider unavailable' }
try {
  ([BitConverter]::ToString($alg.ComputeHash($stream))).Replace('-','').ToLowerInvariant()
} finally { $alg.Dispose(); $stream.Dispose() }
```

If that provider is unavailable, use a **preapproved** offline tool that supports RIPEMD-160; do not silently substitute SHA-1 or SHA-256. Recompute once to verify identical output. A hash may be upper/lowercase hexadecimal; honor the prompt's format.

### File metadata and executable version

**⭐ EASIEST WAY:** Right-click file → **Properties → Details**. For raw bytes use [HexEd.it](https://hexed.it/en/); for a suspicious file already hashed, [VirusTotal Search](https://www.virustotal.com/gui/home/search) can look up a **permitted hash**, but it is not proof the file is unauthorized. Don't upload the file itself.


**GUI first:** Right-click file → **Properties → Details**, **General**, and **Security**. For a running process: Task Manager → Details → right-click → **Open file location**.

```powershell
Get-Item -LiteralPath 'C:\path\file.exe' |
  Select-Object FullName,Length,CreationTime,LastWriteTime,Attributes
(Get-Item -LiteralPath 'C:\path\file.exe').VersionInfo |
  Format-List FileVersion,ProductVersion,OriginalFilename,CompanyName
Get-Acl -LiteralPath 'C:\path\file.exe' | Format-List Owner,AccessToString
```

**Time nuance:** `CreationTime` can change on copy; `LastWriteTime` is not necessarily execution time. Do not infer who modified a file from timestamps alone. Look for event logs, task actions and process paths.

### Alternate data streams and hidden content

NTFS can contain **alternate data streams (ADS)** like `Zone.Identifier` or a named stream:

```powershell
Get-Item -LiteralPath 'C:\path\file.txt' -Stream * -ErrorAction SilentlyContinue
Get-Content -LiteralPath 'C:\path\file.txt' -Stream Zone.Identifier -ErrorAction SilentlyContinue
```

Use `-Stream` only on file systems/PowerShell versions that support it. Do not automatically remove Mark-of-the-Web or run unknown streamed data.

### Image, audio and steganography

Search terms: `steganography`, `hidden message`, `EXIF`, `metadata`, `LSB`, `QR code`, `spectrogram`, `waveform`, `embedded text`, `comment`, `thumbnail`.

1. Preserve the original image/audio and note file size/hash.
2. Inspect visible content first, including QR codes, background/contrast, orientation, annotations and whether it looks cropped.
3. Check **Properties → Details** for comments, author, timestamps, camera model. If an approved `exiftool` is already installed, inspect metadata offline; never upload private evidence to a web converter.
4. Inspect the magic bytes and search for additional appended archive signatures; a photo can contain an embedded ZIP without the extension revealing it.
5. For audio, listen at normal speed first. If approved Audacity is installed, use **Spectrogram** to inspect for letters or shapes; do not install software unless allowed.
6. For LSB steganography, use an approved offline tool only when the question hints at that method. A stego tool finding "nothing" does not establish that no hidden data exists.

**If the answer asks what software was used to create an image:** metadata and signature may identify the format/creator, but not every file embeds that property. State only what the evidence supports.

## Windows identity, network and event questions

### Users, SIDs and local groups

GUI: **Win+R → `lusrmgr.msc` → Users** or **Groups → double-click group → Members**. For a historical group-membership question, record membership **before** removing anyone.

```powershell
Get-LocalUser | Select-Object Name,Enabled,SID
Get-LocalGroup | Select-Object Name,SID
Get-LocalGroupMember -Group 'Event Log Readers'
Get-LocalGroupMember -Group 'Remote Desktop Users'
whoami /user
whoami /groups
```

`Get-LocalGroupMember` may be unavailable in a 32-bit PowerShell process on some 64-bit systems. Use 64-bit Windows PowerShell or the GUI; older fallback: `net localgroup "Event Log Readers"`.

**What if asked for RID?** A SID ends in a relative identifier; for a local user, the digits after the final hyphen are the RID. Do not confuse the user RID with a process PID.

### Computer name and domain

GUI: **Settings → System → About**, or **Win+R → `sysdm.cpl` → Computer Name**.

```powershell
hostname
$env:COMPUTERNAME
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain
ipconfig /all
```

**FQDN:** a domain-joined computer may be `HOST.domain.example`; a workgroup name is not a DNS suffix. Report the exact form asked.

### Ports, PIDs, connections and PCAP

Common prompts: "which **other** port belongs to process PID X?", "process listening on 445", "source IP" or "remote connection".

GUI: **Task Manager → Details** (PID, process), then **Performance → Open Resource Monitor → Network**. For a command-line snapshot:

```cmd
netstat -abno
netstat -ano | findstr LISTENING
```

`-b` may require an elevated CMD prompt and takes time. **PID is the far-right process identifier; local port is after the colon in Local Address.** A process can own multiple listening sockets: filter by PID, not just by one port.

```powershell
Get-NetTCPConnection -State Listen |
  Select-Object LocalAddress,LocalPort,OwningProcess |
  Sort-Object OwningProcess,LocalPort
Get-Process -Id 1234 -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,Path
```

**Historical training pattern:** a Windows 11 question used PID 4 on SMB port 445 and asked for another listening port of the same PID. The method is *find every socket with the same PID*. Do not reuse the historical port number on a different image.

### PCAP and Wireshark

If a `.pcap` or `.pcapng` is supplied and **Wireshark is already installed/approved**:

1. Open the **copy** of the capture in Wireshark (File → Open). Do not capture live network traffic merely to answer a file question.
2. Use the filter that matches the prompt: `ip`, `tcp`, `udp`, `dns`, `http`, `tcp.port == 445`, `ip.src == 192.0.2.10`, `tcp.stream eq 0`.
3. Sort by time, inspect **Source**, **Destination**, **Protocol**, **Info**, and the selected packet's IP/TCP/UDP fields.
4. For a specified conversation: **right-click packet → Follow → TCP/UDP Stream**. For host counts use **Statistics → Endpoints/Conversations**.
5. Copy the exact field or answer type; check **IPv4 vs IPv6**, source versus destination, and whether a NAT/proxy intervenes.
6. If `tshark` is already installed:

```cmd
tshark -r "C:\path\evidence.pcap" -T fields -e frame.number -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport
```

For HTTPS/TLS captures, plaintext is not automatically readable. Without proper session keys, encrypted payloads remain encrypted; packet metadata may still answer the question.

### Event logs and time-based questions

GUI: **Win+R → `eventvwr.msc` → Windows Logs → Security/System → Filter Current Log**. Note timestamps/time zone and the event's **Account Name**, **Logon Type**, **Process Name** and **Source Network Address**.

| Event ID | Typical meaning |
|---|---|
| 4624 | successful logon |
| 4625 | failed logon |
| 4634 | logoff |
| 4648 | explicit credentials used |
| 4688 | process created (only if auditing enabled) |
| 4720 / 4726 | user created / deleted |
| 4722 | account enabled |
| 4724 | password-reset attempt |
| 4728 / 4732 | member added to global / local security group |
| 4733 | member removed from local group |
| 4740 | account locked out |
| 1102 | Security audit log cleared |
| 7045 (System) | service installed |
| 4698 (Security) | scheduled task created, if audited |

```powershell
Get-WinEvent -FilterHashtable @{
  LogName='Security'; Id=4624,4625,4720,4726,4732,4740
  StartTime=(Get-Date).AddDays(-7)
} -ErrorAction SilentlyContinue |
  Select-Object -First 100 TimeCreated,Id,Message
```

If the event is absent: check whether auditing was enabled, log retention, time range, system time and the correct channel. A cleared log may be evidence, but it cannot reconstruct vanished events by itself. Do not clear logs.

### Startup, tasks, registry and services

Search terms: `scheduled task`, `at logon`, `Run`, `RunOnce`, `service installed`, `persistence`, `backdoor`, `debugger`.

GUI: **Win+R → `taskschd.msc` → Task Scheduler Library**; inspect **Actions**, **Triggers**, **Author**, and **Last Run Time**. Inspect **Task Manager → Startup apps**.

```powershell
Get-ScheduledTask | Select-Object TaskPath,TaskName,State,Actions
Get-CimInstance Win32_Service | Select-Object Name,State,StartMode,StartName,PathName
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
```

For an accessibility debugger hijack, **read** but do not delete until answered:

```powershell
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.exe' -ErrorAction SilentlyContinue
```

Ask: Which executable does the task run? Who owns it? When was it modified? Does the service depend on it? Can you correlate it to a scheduled task or listening port?

### Local and hidden network shares

GUI: **Win+R → `fsmgmt.msc` → Shared Folders → Shares**.

```powershell
Get-SmbShare | Select-Object Name,Path,Description,Special
Get-SmbShareAccess -Name 'EXAMPLE_SHARE'
net share
```

**`IPC$`** is a built-in administrative named pipe share (often shown with the `$` suffix). Some prompts may omit the suffix or ask for the share **name** versus its **path**; answer exactly as phrased. Do not remove `ADMIN$`, `C$`, `IPC$` or other system shares just because they are hidden.

### Certificates and public-key clues

GUI: **Win+R → `certmgr.msc`** (current user) or **`certlm.msc`** (local machine) → Personal/Trusted stores → certificate **Details**.

```powershell
Get-ChildItem Cert:\CurrentUser\My | Select-Object Subject,Issuer,Thumbprint,NotAfter,HasPrivateKey
Get-ChildItem Cert:\LocalMachine\My | Select-Object Subject,Issuer,Thumbprint,NotAfter,HasPrivateKey
```

Distinguish **subject**, **issuer**, **serial number**, **thumbprint**, and **public key algorithm**. A certificate's SHA-1 thumbprint is not the same thing as a file's SHA-256 digest. Do not export private keys to solve an unrelated question.

## When Ctrl+F does not find your question

Use the **noun + verb + answer type** method:

1. Highlight what you must return: **user / group / path / hash / IP / port / process / timestamp / plaintext / version / certificate / event**.
2. Highlight where evidence lives: **file / desktop / registry / logs / share / browser / process / network capture / certificate store**.
3. Choose the closest topic above, take **one read-only inventory**, then narrow by filename, PID, account, port or time.
4. Search the **exact error or application setting** in the local Windows handbook; if approved internet is available, search Microsoft's official documentation for the relevant cmdlet/version. Don't use unrelated scripts from unknown sources.
5. If a decoding step fails, write down intermediate output and test a different representation (**hex versus Base64**, **bytes versus UTF-8**, **reversed versus shifted**, **key text versus key bytes**). Keep the original unmodified.
6. Revisit the prompt's units: decimal/hex, local/remote port, name/full path, UTC/local time, group direct/nested member, source/destination.
7. If still unknown, **record what you tried and move on**; more machine exploration may reveal the named artifact without destructive guessing.

**Answer template for notes (not for submission):** `Question wording | artifact path | evidence before modification | commands/UI used | exact result | format requested | verified (Y/N)`. Paste only the requested answer after `ANSWER:` in the actual question file.

## Sources and cross-checks

This guide was built from the supplied **CyberPatriot Forensics Question Research Report**, **CP-19 Windows 11 Training Round 2 Answer Key**, and **CP-19 Round 1 vulnerability-category summary**, with generalized examples rather than reproducing a complete scored answer key. Historical training solutions demonstrate *methods*, not guaranteed answers for another VM.

- [Microsoft Learn — Get-FileHash](https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/Get-FileHash): accepted hashes exclude RIPEMD160.
- [Microsoft Learn — Get-WinEvent](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent).
- [Microsoft Learn — Get-SmbShare](https://learn.microsoft.com/en-us/powershell/module/smbshare/get-smbshare).
- [CyberChef open-source project](https://github.com/gchq/CyberChef) for approved/offline multi-stage encoding practice.
- [General forensic overview](../General/All/forensics-questions.md) · [Windows remediation handbook](../Windows/windows-10-11.md).

Do not expect any document to cover **every possible future question**. This guide supplies starting workflows for broad question families; confirm the particular image's evidence before answering.
