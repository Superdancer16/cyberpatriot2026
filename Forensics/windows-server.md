# Windows Server forensic questions — searchable Server and Active Directory handbook

For CyberPatriot-style **Windows Server 2016, 2019 and 2022**, including **standalone**, **domain member**, and **Domain Controller** images. Keep this open and press **Ctrl+F** for prompt keywords: `CNAME`, `share path`, `certificate`, `thumbprint`, `DNS`, `DHCP`, `domain user`, `GPO`, `Base64`, `AES`, `XOR`, `event`, etc.

**Read/answer every desktop Forensics Question before changing users, groups, shares, DNS, GPO, TLS, services, certificates or files.** Submit the exact requested answer after `ANSWER:` in the original question file, save, and check the Scoring Report. Historical answers shown by a training walkthrough are **not** answers for this VM.

The script, if used, should be run **after** this evidence pass. [Server hardening handbook](../Windows/windows-server.md) · [Windows workstation forensics](windows.md) · [Linux forensics](linux.md).

## ⭐ Easiest websites for decoding and investigating

**Only use websites if the round allows them.** Prefer the built-in commands below or an approved **offline CyberChef** copy when the material contains passwords, private keys, domain details, PCAP contents, sensitive filenames, or other nonpublic evidence. A browser site is not permission to disclose a file. **Never paste a real password or private key into a web decoder.**

| Website | Best for | What to click / enter |
|---|---|---|
| **[CyberChef — GCHQ](https://gchq.github.io/CyberChef/)** | **Best overall:** Base64, hex, ROT13, reverse text, XOR, binary, hashes, URL, compression, multiple layers | Paste safe sample text into **Input** (top right), search an operation on the **left**, drag it to **Recipe** (middle), inspect **Output** (bottom right). Stack operations **in order**; hover for help, and use **Magic** only as a clue |
| **[Cryptii](https://cryptii.com/)** | Simpler visual **Base64 → ROT13 → Reverse** chains, ASCII, Morse, Vigenère | Create conversion/cipher steps, choose **Decode**, put in the given text and compare each intermediate result |
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

## Ctrl+F quick question finder

| Keywords in question | Start here |
|---|---|
| encoded, cipher, ciphertext, decrypt, Base64, ROT13 | [Decoding decision tree](#decoding-decision-tree) |
| Base64, `=`, `==`, ASCII from Base64 | [Base64](#base64-and-multiple-layers) |
| hex, binary, first bytes, magic number, ELF, ASCII | [Hex and binary](#hex-ascii-binary-decimal-and-file-signatures) |
| ROT13, reverse, Caesar, affine, Atbash, Vigenere | [Classical ciphers](#rot13-reverse-caesar-atbash-affine-and-vigenere) |
| XOR, OTP, one-time pad, supplied key | [XOR](#xor-and-one-time-pad-puzzles) |
| AES, RSA, PGP, CMS, DPAPI, encrypted file, secret | [Real encryption](#real-encryption-cms-dpapi-aes-and-keys) |
| password-protected ZIP, 7z, archive, encrypted ZIP | [Archives](#password-protected-archives) |
| SHA-256, RIPEMD-160, MD5, digest, hash, NTLM | [Hashes](#file-hashes-ripemd160-and-hash-versus-password) |
| member server, Domain Controller, standalone | [Identify role](#first-three-minutes-identify-the-server-role-first) |
| domain user, disabled account, SID, RID, UPN, OU | [AD users](#active-directory-users-sids-and-organizational-units) |
| Domain Admins, Enterprise Admins, nested group | [Privileged groups](#active-directory-groups-and-privileged-membership) |
| logon, failed password, Kerberos, KDC, NTLM, lockout | [Authentication events](#event-viewer-windows-logs-and-timestamps) |
| GPO, Group Policy, resultant policy, linked GPO, FGPP | [GPO](#group-policy-and-resultant-password-policy) |
| DNS, CNAME, alias, `ns`, A record, PTR, SRV, TXT | [DNS](#dns-zones-aliases-cname-a-ptr-srv-and-txt) |
| DNS zone transfer, secure updates, DNS changes | [DNS](#dns-zones-aliases-cname-a-ptr-srv-and-txt) |
| DHCP, scope, reservation, lease, option 003, 006 | [DHCP](#dhcp-scopes-leases-reservations-and-options) |
| IIS, web root, bindings, ASPX, website, app pool, FTP | [IIS/FTP](#iis-websites-web-roots-logs-ftp-and-app-pools) |
| share, share name, hidden share, greybeard, path | [SMB shares](#smb-shares-hidden-shares-and-ntfs-access) |
| SYSVOL, NETLOGON, DFSR, AD replication, dcdiag | [DC health](#domain-controller-health-replication-and-time) |
| certificate subject, thumbprint, serial, EKU, SMB over QUIC | [Certificates](#certificates-thumbprints-eku-and-smb-over-quic) |
| port, PID, netstat, listening process, source IP | [Network](#ports-pids-and-network-connection-questions) |
| PCAP, Wireshark, TCP stream, DNS query, HTTP | [PCAP](#packet-captures-and-wireshark) |
| Event ID, Event Viewer, service installed, process | [Events](#event-viewer-windows-logs-and-timestamps) |
| service name, service binary, startup, scheduled task | [Persistence](#services-scheduled-tasks-and-startup-persistence) |
| registry, debugger, accessibility, Sticky Keys, IFEO | [Persistence](#services-scheduled-tasks-and-startup-persistence) |
| file version, created, last modified, owner, hashes | [File evidence](#files-metadata-ownership-and-version) |
| ADS, Zone.Identifier, alternate stream | [Alternate streams](#alternate-data-streams-and-file-contents) |
| browser, cookies, downloads, history, webshell | [IIS](#iis-websites-web-roots-logs-ftp-and-app-pools) |
| cannot find, no records, permission denied, different role | [Escalation](#if-ctrlf-does-not-find-the-question) |

## First three minutes: identify the server role first

**This is the critical difference from Windows 10/11.** A Domain Controller does not use the same local-account database as a standalone server. DNS/DHCP/IIS roles may exist on a member server, on a DC, or not at all.

GUI: **Server Manager → Local Server** (Desktop Experience), or **Win+R → `sysdm.cpl`** for computer/domain identity.

PowerShell 5.1 read-only:

```powershell
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$os | Select-Object Caption,Version,ProductType
$cs | Select-Object Name,Domain,PartOfDomain,DomainRole
```

- `ProductType=2` / `DomainRole=4 or 5` usually means **Domain Controller**.
- `ProductType=3` and `PartOfDomain=True` indicates **member server**.
- `ProductType=3` and not domain joined indicates **standalone server**.
- Server Core **does not have `dsa.msc`, `dnsmgmt.msc` or a local GUI**. Use authorized PowerShell/remote RSAT instead of installing a GUI.

**Forensic-first checklist:** open and read the question files on the desktop; record exact requested output; do not delete users/shares/certificates; keep working administrator access and a valid Scoring Report.

```powershell
Get-ChildItem "$env:USERPROFILE\Desktop" -Force -File -ErrorAction SilentlyContinue |
  Where-Object Name -match 'forensic|question' |
  Select-Object FullName,Length,LastWriteTime
```

Read a named question:

```powershell
Get-Content -LiteralPath 'C:\path\Forensics Question 1.txt' -Raw
```

**Output format matters:** `C:\path` is different from just a filename; a share name differs from its target path; an account's `SamAccountName` differs from its display name; a certificate's SHA-1 thumbprint differs from a file SHA-256 hash.

## Decoding decision tree

Use this directly for any Server question phrased as an encoded or encrypted message:

1. **Examine characters.** Even-length `0-9A-F` → hex; strings with `A-Za-z0-9+/=` → Base64; 8-bit binary groups → ASCII; readable but scrambled letters → ROT13, reverse, Caesar or another simple cipher.
2. **Look for supplied key and format.** `XOR`, `one-time pad`, `keyword`, `a,b`, `AES`, `certificate`, `CMS`, `DPAPI`, `PGP`, `password`, `IV`, `nonce`.
3. **Decode one layer**, record the intermediate output, and identify whether it is still encoded. A text file can contain Base64 whose bytes form hex, or ROT13 whose result must be reversed.
4. **Check bytes before text.** If decoded data is binary, inspect first bytes and file type rather than forcing it to UTF-8.
5. **Modern encryption needs a key** and valid format. Password hashes (NTLM, SHA256, MD5) cannot be directly decrypted.
6. Verify the requested exact **plaintext/path/hash/hex bytes** before submitting.

You can use an approved offline [CyberChef](https://github.com/gchq/CyberChef) recipe for multi-layer transforms. Avoid uploading server evidence to unrelated websites.

### Base64 and multiple layers

**⭐ EASIEST WAY — website if permitted:** [CyberChef](https://gchq.github.io/CyberChef/) → paste Base64 ciphertext → **From Base64** → inspect Output and, only if indicated, add **ROT13**, **Reverse Text**, **From Hex** or another operation. Do **not** paste actual AD passwords, private keys or confidential server data into other public tools.


```powershell
$encoded = 'SGVsbG8='
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($encoded))
# Hello
```

From an actual file:

```powershell
$encoded = (Get-Content -LiteralPath 'C:\path\encoded.txt' -Raw).Trim()
[byte[]]$data = [Convert]::FromBase64String($encoded)
[Text.Encoding]::UTF8.GetString($data)
```

If output is nonsensical text but looks like another encoding, try ROT13 or hex. If bytes begin with `PK`, `%PDF` or `MZ`, inspect as a file.

**Base64URL:** uses `-` and `_`; it may lack padding. Don't strip arbitrary evidence characters just to make a decoder run.

### Hex, ASCII, binary, decimal and file signatures

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) → **From Hex**, **From Binary**, or **From Decimal** according to the prompt. For the first bytes of a named file use [HexEd.it](https://hexed.it/en/) and read offset zero without saving edits.


PowerShell **5.1-compatible** hex decoding; do not assume `[Convert]::FromHexString` exists:

```powershell
$hex = '48 65 6c 6c 6f' -replace '[\s:-]',''
if ($hex.Length % 2 -ne 0 -or $hex -notmatch '^[0-9a-fA-F]+$') { throw 'Invalid hex string' }
[byte[]]$bytes = @([regex]::Matches($hex,'..') | ForEach-Object { [Convert]::ToByte($_.Value,16) })
[Text.Encoding]::UTF8.GetString($bytes)
# Hello
```

First N bytes of a file (answer in **hex**, not text):

```powershell
$stream = [IO.File]::OpenRead('C:\path\file.bin')
try {
  [byte[]]$first = New-Object byte[] 8
  $n = $stream.Read($first,0,$first.Length)
  [BitConverter]::ToString($first,0,$n)
} finally { $stream.Dispose() }
```

| Magic bytes | Common file type |
|---|---|
| `4D 5A` | PE/Windows executable |
| `50 4B 03 04` | ZIP/OOXML |
| `25 50 44 46` | PDF |
| `89 50 4E 47` | PNG |
| `FF D8 FF` | JPEG |
| `7F 45 4C 46` | ELF |
| `37 7A BC AF 27 1C` | 7-Zip |

Other short codes:

```powershell
[char][Convert]::ToInt32('01001000',2)     # binary to H
[char][Convert]::ToInt32('110',8)          # octal to H
[char]72                                   # decimal to H
[Uri]::UnescapeDataString('Hello%20World')
[Net.WebUtility]::HtmlDecode('Hello&#32;World')
```

`&#...;` is HTML encoding; `\u0048` is a Unicode escape; `.... . .-.. .-.. ---` is Morse. Don't treat every number as a cipher key.

### ROT13, reverse, Caesar, Atbash, affine and Vigenere

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) → **ROT13 → Reverse Text**, or use [dCode Affine](https://www.dcode.fr/affine-cipher) and [dCode Vigenère](https://www.dcode.fr/vigenere-cipher) for provided parameters. Do not use an online tool for secrets from a Domain Controller.


ROT13:

```powershell
$text = 'Uryyb Jbeyq'
$decoded = -join ($text.ToCharArray() | ForEach-Object {
  $v = [int][char]$_
  if ($v -ge 65 -and $v -le 90) { [char](65+(($v-65+13)%26)) }
  elseif ($v -ge 97 -and $v -le 122) { [char](97+(($v-97+13)%26)) }
  else { $_ }
})
$decoded
```

Reverse text:

```powershell
$chars = $decoded.ToCharArray()
[Array]::Reverse($chars)
-join $chars
```

**Caesar:** if encrypted with shift +3, decrypt with shift -3. Test 26 possible shifts only if the question gives no shift and plain-English recognition is plausible.

**Atbash:** A↔Z, B↔Y, etc.; no key.

**Affine:** with A=0 to Z=25, `E(x)=(a*x+b) mod 26`; decryption is `D(y)=inverse(a)*(y-b) mod 26`. `gcd(a,26)` must be 1. If `a=1,b=3`, decrypt by shifting letters back three. Use the actual key values from the question.

**Vigenere:** subtract the repeated keyword's letter values (A=0), advancing the key on letters only. No keyword? Search nearby files/README clues before trying random words.

**Layer example:** ROT13 can produce another reversed English phrase. Record intermediate text, then reverse **characters** (not word order); preserve exact capitalization.

### XOR and one-time-pad puzzles

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) → decode the **ciphertext** into bytes first (`From Hex`/`From Base64`), then apply **XOR** using the provided **key** and its correct encoding. Verify equal byte lengths for a one-time-pad-style question. Do not share the recipe URL if it contains evidence.


An OTP-style exercise may supply ciphertext and key as hex. XOR the corresponding **decoded bytes**, not the hex characters:

```powershell
function Hex-Bytes([string]$text) {
  $text = $text -replace '\s',''
  if ($text.Length % 2 -ne 0 -or $text -notmatch '^[0-9a-fA-F]+$') { throw 'Invalid hex' }
  [byte[]]@([regex]::Matches($text,'..') | ForEach-Object { [Convert]::ToByte($_.Value,16) })
}
[byte[]]$cipher = Hex-Bytes '08070f0f0c'
[byte[]]$key = Hex-Bytes '4062636363'
if ($cipher.Length -ne $key.Length) { throw 'Key length does not match this OTP-style ciphertext' }
[byte[]]$plain = for($i=0;$i -lt $cipher.Length;$i++){ $cipher[$i] -bxor $key[$i] }
[Text.Encoding]::UTF8.GetString($plain)
# Hello
```

If ciphertext/key are Base64, first use `[Convert]::FromBase64String` on both. If the key is literal UTF-8, use `[Text.Encoding]::UTF8.GetBytes`. Repeating-key XOR is distinct from a one-time pad; repeat only when specified.

### Real encryption: CMS, DPAPI, AES and keys

Search terms: `AES`, `RSA`, `CMS`, `certificate`, `DPAPI`, `PGP`, `IV`, `salt`, `nonce`, `password`, `key file`.

1. Preserve file and hash before decryption.
2. Determine container/encoding, exact cipher, mode, password/key, IV/nonce, tag and the identity that has the authorized private key.
3. Decrypt to a **new file/stream**, never overwrite original evidence.
4. Confirm output type and answer. Do not extract unrelated users' credentials/private keys.

For **CMS message** encrypted to an installed certificate with private key:

```powershell
Get-ChildItem Cert:\CurrentUser\My | Select-Object Subject,Thumbprint,HasPrivateKey
Unprotect-CmsMessage -Path 'C:\path\message.cms'   # only authorized recipient key
```

For **DPAPI** (`Export-Clixml` encrypted credentials and similar), data protected for one Windows account/machine may not decrypt under a different account or VM. That is expected and does not prove corruption.

**AES-GCM/CBC:** algorithm alone is not enough. Correct key, IV/nonce, mode, salt/KDF and authentication tag are mandatory. An arbitrary web decoder is not a safe way to handle server secrets.

**NTLM/SHA hashes are not reversible encodings.** If a lawful practice exercise supplies a hash and explicitly asks for a password, use only the provided lab material and coach-approved offline tools; don't extract or attempt to crack real AD account hashes.

### Password-protected archives

GUI (Desktop Experience): right-click ZIP → Extract All, or use an **already approved** archive tool. On Server Core use existing command-line tools; don't install a browser/GUI to solve a zip puzzle.

Read-only ZIP discovery:

```powershell
Get-ChildItem "$env:USERPROFILE\Desktop","$env:USERPROFILE\Downloads","C:\Users\Public" -Recurse -File -Filter '*.zip' -Force -ErrorAction SilentlyContinue |
  Select-Object FullName,Length,LastWriteTime
```

Seek the authorized passphrase in adjacent evidence, clues, filenames or README. Inspect an archive copy and do not run unknown extracted executables. AES-encrypted ZIP variants may not work with Windows' built-in extractor.

### File hashes, RIPEMD160 and hash versus password

**⭐ WEBSITE OPTION:** [CyberChef](https://gchq.github.io/CyberChef/) can calculate supported hashes for a permitted file in your browser; cross-check with the exact local algorithm below. [VirusTotal Search](https://www.virustotal.com/gui/home/search) can **look up** an existing hash, but does not calculate the scored file's correct digest or prove it is malicious.


```powershell
Get-FileHash -LiteralPath 'C:\path\evidence.bin' -Algorithm SHA256
Get-FileHash -LiteralPath 'C:\path\evidence.bin' -Algorithm MD5
Get-FileHash -LiteralPath 'C:\path\evidence.bin' -Algorithm SHA512
certutil -hashfile "C:\path\evidence.bin" SHA256
```

**RIPEMD160 is NOT an accepted `Get-FileHash` algorithm**. On a Windows PowerShell 5.1/.NET Framework image supporting the provider:

```powershell
$stream = [IO.File]::OpenRead('C:\path\evidence.bin')
$alg = [Security.Cryptography.RIPEMD160]::Create()
if (-not $alg) { $stream.Dispose(); throw 'RIPEMD160 provider unavailable' }
try {
  ([BitConverter]::ToString($alg.ComputeHash($stream))).Replace('-','').ToLowerInvariant()
} finally { $alg.Dispose(); $stream.Dispose() }
```

Otherwise use an already-approved offline RIPEMD160 tool; never silently substitute SHA-1. Hash only the exact requested **original file** and verify by recomputing.

## Active Directory, accounts and Group Policy

### Active Directory users, SIDs and organizational units

If **Domain Controller**, GUI: **Win+R → `dsa.msc` → Active Directory Users and Computers → View → Advanced Features**. Expand the actual domain's `Users` container and OUs.

Check exact user name, enabled flag, OU, principal name, last-logon attribute, creation date, password-expiration status:

```powershell
Import-Module ActiveDirectory
Get-ADUser -Filter * -Properties Enabled,WhenCreated,LastLogonDate,PasswordNeverExpires |
  Select-Object SamAccountName,Enabled,WhenCreated,LastLogonDate,PasswordNeverExpires,DistinguishedName
Get-ADUser -Identity 'exampleuser' -Properties * |
  Format-List SamAccountName,UserPrincipalName,SID,Enabled,DistinguishedName,WhenCreated,MemberOf
```

**SID/RID:** `S-1-5-21-...-RID`: last numeric segment is RID. `SamAccountName` (`jsmith`) differs from UPN (`jsmith@example.test`) and display name. **An OU path is part of `DistinguishedName`**; the string starts with CN, then OU/DC components.

On a **member server** where AD tools are unavailable, use authorized RSAT or query local identity:

```powershell
Get-CimInstance Win32_ComputerSystem | Select Name,Domain,PartOfDomain
whoami /user
whoami /groups
```

Do not make local SAM changes to "fix" an account that the question describes as a **domain** user. Domain account history may be present on a DC, member-server logs, or both.

### Active Directory groups and privileged membership

GUI: `dsa.msc` → locate group → **Properties → Members** (direct membership). To find nested groups, inspect group member objects recursively, and note whether the question asks **direct** versus **recursive** members.

```powershell
Import-Module ActiveDirectory
Get-ADGroup -Filter * | Select-Object Name,SamAccountName,GroupScope,GroupCategory
Get-ADGroupMember -Identity 'Domain Admins' |
  Select-Object Name,SamAccountName,ObjectClass
Get-ADGroupMember -Identity 'Domain Admins' -Recursive |
  Select-Object Name,SamAccountName,ObjectClass
Get-ADPrincipalGroupMembership -Identity 'exampleuser' |
  Select-Object Name,SamAccountName
```

Privileged groups to check if the prompt hints at them: `Domain Admins`, `Enterprise Admins`, `Schema Admins`, `Administrators`, `Account Operators`, `Server Operators`, `Backup Operators`, `DnsAdmins`, `Group Policy Creator Owners`.

**Pitfalls:** A user's `primaryGroupID` may not appear in the usual `memberOf` property. Domain local versus global versus universal group scopes also differ. Never remove a user from a privileged group just to answer who **was** in it.

### Group Policy and resultant password policy

GUI: **Win+R → `gpmc.msc`** → Forest → Domains → **actual domain** → Group Policy Objects. Identify policy links, inheritance, GPO status, scope and modification times.

```powershell
Import-Module GroupPolicy
Get-GPO -All | Select-Object DisplayName,Id,CreationTime,ModificationTime,GpoStatus
Get-GPInheritance -Target 'OU=Example,DC=example,DC=test'
gpresult /h "$env:TEMP\rsop.html"
```

**Password policy:**

```powershell
Import-Module ActiveDirectory
Get-ADDefaultDomainPasswordPolicy | Format-List *
Get-ADFineGrainedPasswordPolicy -Filter * |
  Select-Object Name,Precedence,MinPasswordLength,ComplexityEnabled
Get-ADUserResultantPasswordPolicy -Identity 'exampleuser'
```

**Default Domain Policy ≠ automatically the effective policy for every user.** Fine-grained password policies (FGPP) may override the domain default. On a member server, local `secpol.msc` might be overridden by domain GPO. Find the **resultant** policy before answering which setting actually applies.

Questions may ask for a GPO's **GUID**, display name, link location, modified time, setting, or security-filtering principal. These are different answer formats.

### Domain Controller health, replication and time

Search prompts: `replication partner`, `SYSVOL`, `NETLOGON`, `dcdiag`, `FSMO`, `time server`, `PDC emulator`, `domain controller`.

```powershell
repadmin /replsummary
repadmin /showrepl
dcdiag /test:Advertising /test:Services /test:NetLogons
net share
w32tm /query /status
w32tm /query /source
```

List FSMO role holders (if AD module installed):

```powershell
Get-ADDomain | Select-Object PDCEmulator,RIDMaster,InfrastructureMaster
Get-ADForest | Select-Object SchemaMaster,DomainNamingMaster
```

**Answer only what is asked:** replication status versus FSMO owner, time source versus the computer's hostname, SYSVOL share path versus GPO path. Failures may be due to a missing role, replication topology, firewall or wrong time; don't reconfigure AD to make a forensic report look clean.

## DNS, DHCP, IIS, SMB and certificates

### DNS zones, aliases (CNAME), A, PTR, SRV and TXT

**GUI:** Win+R → `dnsmgmt.msc` → Forward Lookup Zones / Reverse Lookup Zones → the exact zone. Double-click a record to inspect its target/TTL.

```powershell
Import-Module DnsServer
Get-DnsServerZone | Select-Object ZoneName,ZoneType,IsDsIntegrated,DynamicUpdate,SecureSecondaries
Get-DnsServerResourceRecord -ZoneName 'example.test' |
  Select-Object HostName,RecordType,RecordData,TimeToLive
```

To answer "which **CNAME aliases** point to `dc-01.example.test`":

```powershell
Get-DnsServerResourceRecord -ZoneName 'example.test' |
  Where-Object { $_.RecordType -eq 'CNAME' } |
  Select-Object HostName,@{Name='Target';Expression={$_.RecordData.HostNameAlias}}
```

**Important:** `CNAME` **alias name** (`ns`) differs from **target host** (`dc-01.example.test`). Normalize fully qualified targets with trailing dots when comparing; do not assume an alias has the same A record or IP as another host.

Other questions:

```powershell
Get-DnsServerResourceRecord -ZoneName 'example.test' |
  Where-Object { $_.RecordType -in @('A','AAAA','PTR','TXT','SRV','NS','MX') } |
  Select-Object HostName,RecordType,RecordData
Resolve-DnsName -Name 'www.example.test' -Type A
Resolve-DnsName -Name '_ldap._tcp.dc._msdcs.example.test' -Type SRV
```

- **A/AAAA:** hostname → IPv4/IPv6.
- **PTR:** reverse address → hostname.
- **SRV:** service target and port (e.g. `_ldap._tcp`).
- **TXT:** text/SPF-like data, possibly an encoded clue.
- **NS:** authoritative nameserver.
- **MX:** mail exchanger.
- **Zone transfer:** property of zone; don't confuse it with ordinary DNS resolution.

To inspect **zone transfer and dynamic update rules**, view **Zone Properties** and the actual secondary server list. **Secure-only dynamic updates require an AD-integrated zone**. Never disable transfers or edit a required record before answering the question.

**Historical school-team report:** a Server-style question asked for two CNAME aliases of a named DC. The general technique is to enumerate CNAME entries and compare their targets; don't reuse historical alias names.

### DHCP scopes, leases, reservations and options

GUI: **Win+R → `dhcpmgmt.msc` → IPv4** → Scopes, Address Leases, Reservations, Scope Options, Server Options.

```powershell
Import-Module DhcpServer
Get-DhcpServerv4Scope | Select-Object ScopeId,Name,StartRange,EndRange,State
Get-DhcpServerv4OptionValue | Select-Object OptionId,Name,Value
foreach ($scope in (Get-DhcpServerv4Scope)) {
  Get-DhcpServerv4Reservation -ScopeId $scope.ScopeId |
    Select-Object @{Name='Scope';Expression={$scope.ScopeId}},IPAddress,ClientId,Name
}
```

For a specific scope:

```powershell
Get-DhcpServerv4Lease -ScopeId 192.0.2.0 |
  Select-Object IPAddress,ClientId,HostName,AddressState,LeaseExpiryTime
Get-DhcpServerv4OptionValue -ScopeId 192.0.2.0
```

Replace `192.0.2.0` with the real ScopeId. **Lease ≠ reservation**; a MAC/client identifier may be represented with hyphens or colons. DHCP option **003** is the router/gateway; **006** is DNS servers. Confirm whether the question asks **server options** or **scope options**—the latter can override the former.

A DHCP server might be installed but not authorized in AD; check authorization separately if asked. Do not change scope options or reservations to answer a question about their previous values.

### IIS websites, web roots, logs, FTP and app pools

GUI: **Win+R → `inetmgr`** → server → Sites → select site → **Basic Settings**, **Bindings**, **Authentication**, **Logging**, **Directory Browsing**, **Application Pools**.

```powershell
Import-Module WebAdministration
Get-Website | Select-Object Name,State,PhysicalPath,Bindings
Get-WebBinding | Select-Object protocol,bindingInformation
Get-WebApplication | Select-Object Path,PhysicalPath,ApplicationPool
Get-ChildItem 'IIS:\AppPools' | Select-Object Name,State,ManagedRuntimeVersion
```

**What does a question want?**
- **Physical path / web root:** `C:\inetpub\wwwroot` or site-specific configured directory.
- **Host header / binding:** IP, TCP port, host name, protocol and certificate.
- **App pool identity:** inspect **Advanced Settings → Identity** (not necessarily the app pool name).
- **Directory browsing:** per-site config; not the same as Windows share permissions.
- **Web shell:** look for unusual `.aspx`/`.asp`/`.php` file, suspicious command execution, newly modified script, not every script file.

Read-only web-root inspection:

```powershell
Get-ChildItem 'C:\inetpub' -Recurse -Force -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Extension -in '.aspx','.asp','.php','.config' } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 100 FullName,Length,LastWriteTime

Get-ChildItem 'C:\inetpub' -Recurse -File -Include *.aspx,*.asp,*.php -ErrorAction SilentlyContinue |
  Select-String -Pattern 'cmd.exe','Process.Start','FromBase64String','Invoke-Expression' -List -ErrorAction SilentlyContinue |
  Select-Object Path,LineNumber
```

**IIS request logs** (site-numbered W3C folders):

```powershell
Get-ChildItem 'C:\inetpub\logs\LogFiles' -Force -ErrorAction SilentlyContinue
Get-ChildItem 'C:\inetpub\logs\LogFiles' -Filter *.log -Recurse -File -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 10 FullName,LastWriteTime,Length
```

W3C logs generally store **UTC timestamps**. Search `cs-uri-stem`, `c-ip`, HTTP status and user agent using the log header's `#Fields`; do not assume column order is fixed.

**FTP:** In IIS Manager, inspect FTP site path, configured authentication, SSL/TLS, user isolation and passive port rules. For server-specific FTP request logs, inspect the actual IIS FTP log configuration. A client connection test can verify service behavior, but don't use the user's credentials in a pasted public log.

### SMB shares, hidden shares and NTFS access

GUI: **Win+R → `fsmgmt.msc` → Shared Folders → Shares**. On Server Core use PowerShell.

```powershell
Get-SmbShare | Select-Object Name,Path,Description,Special
Get-SmbShareAccess -Name 'EXAMPLE_SHARE' |
  Select-Object Name,AccountName,AccessControlType,AccessRight
Get-Acl -LiteralPath 'C:\path\shared-folder' | Format-List Owner,AccessToString
net share
```

**Name versus path:** a custom share like `greybeard` has a target **absolute directory**. The name might be the answer, or the backing path, depending on prompt wording. A hidden share ends with `$`; `IPC$`, `ADMIN$`, drive-letter shares, **SYSVOL/NETLOGON** on DCs can be normal.

**Effective access = share permissions + NTFS permissions + user token/group membership.** Don't infer effective access from the share ACL alone. Inspect the mapped path and full account identities.

**Historical Server 2019 training pattern:** ask the path of an unexpected share. The technique is `fsmgmt.msc → Shares` or `Get-SmbShare`, then report exactly the full `Path`, not the share name.

### Certificates, thumbprints, EKU and SMB over QUIC

GUI: **Win+R → `certlm.msc`** (local computer) or `certmgr.msc` (current user) → Personal → Certificates → double-click → **Details**.

```powershell
Get-ChildItem Cert:\LocalMachine\My |
  Select-Object Subject,Issuer,Thumbprint,SerialNumber,NotBefore,NotAfter,HasPrivateKey,EnhancedKeyUsageList
Get-ChildItem Cert:\CurrentUser\My |
  Select-Object Subject,Issuer,Thumbprint,NotAfter
```

If question says "certificate intended for Server Authentication" (including **SMB over QUIC** on a supported server edition), inspect **Enhanced Key Usage (EKU)** for **Server Authentication**, plus Subject/SAN, expiration, issuer and private-key availability. Do not assume the feature is installed just because the question mentions it.

```powershell
Get-ChildItem Cert:\LocalMachine\My |
  Where-Object { @($_.EnhancedKeyUsageList | ForEach-Object FriendlyName) -contains 'Server Authentication' } |
  Format-List Subject,Issuer,Thumbprint,NotAfter,EnhancedKeyUsageList
```

**Thumbprint** is a certificate identifier (usually SHA-1 hex), not the same as SHA-256 hashing a file. If the prompt wants both **Subject and Thumbprint**, provide both exactly as displayed. Remove copy/paste whitespace only if the answer format requires it. **Do not export a private key** to answer a metadata question.

If a cert file is supplied, `certutil -dump "C:\path\cert.cer"` can inspect metadata without installing it. For CMS encrypted to a certificate, see [real encryption](#real-encryption-cms-dpapi-aes-and-keys).

## Network, event logs, persistence and file evidence

### Ports, PIDs and network connection questions

A question may ask **"What other port is listening under PID N?"**. The **local port** is after `:` in the local address; **PID** is the process ID, not the port. One process can own multiple listening sockets.

**GUI:** Task Manager → Details → enable PID column; Resource Monitor → Network → Listening Ports.

```cmd
netstat -abno
netstat -ano | findstr LISTENING
```

For an exact PID from the current image:

```powershell
Get-NetTCPConnection -State Listen |
  Sort-Object OwningProcess,LocalPort |
  Select-Object LocalAddress,LocalPort,OwningProcess
Get-Process -Id 1234 -ErrorAction SilentlyContinue |
  Select-Object Id,ProcessName,Path
```

For IIS/DNS/DHCP and DC roles, many legitimate ports are present (e.g. RPC, DNS, Kerberos, LDAP, SMB, HTTPS, RDP). A listening port is **not proof** of malware. Correlate PID → binary path → service/role → README.

### Packet captures and Wireshark

If the image provides a `.pcap`/`.pcapng` and Wireshark is already installed:

1. Open a copy of the file via **File → Open**; do not start a live capture to answer an offline PCAP question.
2. Use display filters `ip`, `tcp`, `udp`, `dns`, `http`, `tcp.port == 445`, `ip.addr == 192.0.2.10`, `kerberos`, `ldap`, `smb2`.
3. Select a packet, expand Internet Protocol/TCP/DNS/Kerberos/SMB fields and read **Source/Destination**, timestamps and ports.
4. **Right-click → Follow TCP Stream** for a conversation. Use **Statistics → Endpoints/Conversations** to count peers.
5. Check **source versus destination** and whether the question asks for **client IP** or **server IP**.
6. If an approved `tshark` already exists:

```cmd
tshark -r "C:\path\capture.pcap" -T fields -e frame.number -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport
```

Encrypted TLS or SMB encryption is not readable without the authorized session keys. Often the evidence requested is network metadata, not decrypted application payload.

### Event Viewer, Windows logs and timestamps

GUI: **Win+R → `eventvwr.msc` → Windows Logs → Security/System → Filter Current Log**. For server roles, inspect **Applications and Services Logs** and their role-specific channels (DNS Server, Directory Service, DHCP-Server, DFS Replication, etc.) when installed.

| Event ID / log | Meaning to investigate |
|---|---|
| Security 4624 / 4625 | successful / failed logon |
| Security 4648 | explicit credentials used |
| Security 4688 | process created, if enabled |
| Security 4720 / 4726 | account created / deleted |
| Security 4724 | password reset attempt |
| Security 4728 / 4732 | member added to global / local security group |
| Security 4729 / 4733 | member removed from global / local security group |
| Security 4740 | account lockout |
| Security 4768 / 4769 | Kerberos TGT / service ticket request |
| Security 4771 | Kerberos preauthentication failed |
| Security 4776 | NTLM credential validation |
| Security 4662 | directory object access, only if audited |
| Security 5136 | directory object modified, if AD change auditing enabled |
| Security 1102 | audit log cleared |
| System 7045 | service installed |
| Security 4698 | scheduled task created, if audited |

Example query with a time window:

```powershell
Get-WinEvent -FilterHashtable @{
  LogName='Security'
  Id=4624,4625,4720,4726,4728,4732,4740,4768,4769,4771,4776
  StartTime=(Get-Date).AddDays(-7)
} -ErrorAction SilentlyContinue |
  Select-Object -First 150 TimeCreated,Id,Message
```

Specific service installation:

```powershell
Get-WinEvent -FilterHashtable @{LogName='System';Id=7045} -ErrorAction SilentlyContinue |
  Select-Object -First 40 TimeCreated,Message
```

**Timestamp questions:** check time zone/UTC, log retention, channel, event ID, user and machine. `Get-WinEvent` may omit entries if audit settings were disabled. An empty search does not prove an event never occurred. Do not clear logs as part of a forensic pass.

### Services, scheduled tasks and startup persistence

**GUI:** `services.msc`, `taskschd.msc` → Task Scheduler Library, Task Manager → Startup apps, `regedit`.

```powershell
Get-CimInstance Win32_Service |
  Select-Object Name,State,StartMode,StartName,PathName
Get-ScheduledTask | Select-Object TaskPath,TaskName,State,Actions
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
```

Accessibility debugger override (read-only):

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.exe' -ErrorAction SilentlyContinue
```

A suspicious task launching `powershell.exe`, `cmd.exe`, `wscript.exe`, `mshta.exe`, or a binary under a writable Temp folder is a **lead**, not automatic proof. Record **task name, action/arguments, user, trigger, file path, PID, hash and time** before altering it.

Domain Controllers may legitimately run many scheduled maintenance tasks and protected services; don't disable system AD/Netlogon/DFSR entries because their names look unfamiliar.

### Files, metadata, ownership and version

GUI: File Explorer → View → Hidden items + File name extensions; file right-click **Properties → Details/Security**. A named server file may reside in `C:\inetpub`, `C:\Windows\SYSVOL`, a custom share root, Desktop or Documents.

```powershell
Get-Item -LiteralPath 'C:\path\file.exe' |
  Select-Object FullName,Length,Attributes,CreationTime,LastWriteTime
(Get-Item -LiteralPath 'C:\path\file.exe').VersionInfo |
  Format-List FileVersion,ProductVersion,CompanyName,OriginalFilename
Get-Acl -LiteralPath 'C:\path\file.exe' |
  Format-List Owner,AccessToString
```

Search narrow before whole drive:

```powershell
Get-ChildItem 'C:\Users','C:\inetpub' -File -Recurse -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like '*keyword*' -or $_.Extension -in '.zip','.txt','.pcap' } |
  Select-Object FullName,Length,LastWriteTime
```

**Time nuance:** Created/modified/access times may change after copy or access. Do not infer activity from a single property; use logs and object metadata as corroboration.

### Alternate data streams and file contents

```powershell
Get-Item -LiteralPath 'C:\path\file.txt' -Stream * -ErrorAction SilentlyContinue
Get-Content -LiteralPath 'C:\path\file.txt' -Stream Zone.Identifier -ErrorAction SilentlyContinue
```

NTFS alternate data streams can carry metadata like `Zone.Identifier` or additional content. Do not automatically delete streams or unblock evidence. If a file's extension is misleading, inspect its **magic bytes**, not its name alone.

### Image, audio, PDF and steganography

If a question supplies an image, PDF, audio or archive rather than a log:

1. Preserve original file and compute exact SHA-256.
2. Inspect visible contents, filename, extension, Properties → Details, comments, author, version, certificate or embedded QR code.
3. Inspect first bytes to confirm actual format; a PDF/ZIP/Office file can be renamed.
4. For steganography: look for provided tool/method hints, image layers, LSB, embedded files, spectrum/spectrogram or encoded metadata. Use only approved offline tools when available.
5. For encrypted PDF/ZIP: identify the required password/recipient key; do not upload private evidence to online unlock sites.

Distinguish **metadata extraction** from **decryption**. A certificate thumbprint or PDF author can be answered without any secret key.

## If Ctrl+F does not find the question

1. Underline the requested **answer type**: file path, user, group, GPO, domain controller, DNS CNAME, DHCP reservation, IIS path, share, port, timestamp, certificate, plaintext, hash.
2. Identify the **role**: DC, member, standalone; then the installed server role (AD, DNS, DHCP, IIS/FTP, SMB, CA, Hyper-V, SQL, printing).
3. Find the **authoritative store**: `dsa.msc`, `gpmc.msc`, `dnsmgmt.msc`, `dhcpmgmt.msc`, `inetmgr`, `fsmgmt.msc`, `certlm.msc`, Event Viewer or a named evidence file.
4. Run one narrow, read-only query for the exact user, group, zone, site, event ID, file or port. Don't run a domain-wide change command just to get information.
5. If missing, check another DC/role host, AD OU, nested group, DNS zone, compressed/archived log, UTC offset, record alias/target, file extensions or the relevant policy precedence.
6. If ciphertext fails to decode, write down each intermediate value and distinguish **hex/Base64 bytes**, **ROT/reversal**, **XOR byte key**, **real encryption with key**, and **one-way hashes**.
7. Re-read the prompt's nouns: **alias versus target**, **certificate subject versus thumbprint**, **share name versus absolute path**, **domain versus local user**, **direct versus nested member**, **source versus destination IP**.
8. If an application is unavailable, use authorized RSAT/PowerShell or the corresponding original server handbook, not a random installer or borrowed account.
9. Record the evidence and move to another question if needed; return once you have a more specific clue.

Personal scratch template: `exact question | role | artifact/zone/user | read-only command/GUI | observed value | answer format | verified`. Type **only the requested answer** in the scored question document.

## Sources and scope

Built from the supplied **CyberPatriot Forensics Question Research Report**, **CP19 Windows 11 Training Round 2 Answer Key**, and **CP19 Round 1 category summary**, plus general Microsoft Server investigation methods. Historical Server 2019/2022 examples in the research report are school/team records, **not proof of every past official question**.

- [Windows Server role-aware handbook](../Windows/windows-server.md).
- [Microsoft Learn — Get-WinEvent](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent).
- [Microsoft Learn — Get-DnsServerResourceRecord](https://learn.microsoft.com/en-us/powershell/module/dnsserver/get-dnsserverresourcerecord).
- [Microsoft Learn — Get-SmbShare](https://learn.microsoft.com/en-us/powershell/module/smbshare/get-smbshare).
- [Microsoft Learn — Get-FileHash](https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/Get-FileHash).
- [CyberChef open-source project](https://github.com/gchq/CyberChef) for approved offline decoding.

No guide can guarantee an instant answer to **every unforeseen forensic puzzle**. These sections provide a concrete, searchable investigation for the main types of evidence plus a role-aware fallback.
