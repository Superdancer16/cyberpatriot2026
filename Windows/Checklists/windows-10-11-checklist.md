# 🪟 Windows 10/11 — Printable Checklist & GitHub Progress Tracker

> **Source:** [Full Windows 10/11 guide](../windows-10-11.md). This tracker is a **separate companion**; the original guide is not changed.
>
> **How to track:** Print the matching PDF and mark the square beside each small task. For GitHub tracking, click **Edit** on this Markdown file, change `[ ]` to `[x]` as tasks are completed, and commit the change. If an item does not apply, append `(N/A — reason)` to its text in your own progress copy. GitHub Markdown checkboxes do not automatically save themselves when clicked.
>
> **Safety:** Read the actual competition README and forensic questions first. A task may be inspection-only or not applicable; **do not change a setting just to tick its box**. Protect necessary services and administrator access.

**Round/date:** ___________________  **Image:** ___________________  **Team:** ___________________

**Starting score:** __________  **Final score:** __________  **Reviewer:** ___________________

**Legend:** ☐ not done · ☑ complete · N/A not applicable · Check the full guide before changing any setting.

## 01. Read the image instructions and prepare safely  
*Full guide: [Part 2](../windows-10-11.md#stage-2)*

- [ ] **W001** — Read the complete image README before making any change
- [ ] **W002** — Record the current Windows version, edition and build
- [ ] **W003** — Record the initial scoring report value and timestamp
- [ ] **W004** — Write down all required user accounts
- [ ] **W005** — Write down all required local administrators
- [ ] **W006** — Identify any domain membership or centrally managed policies
- [ ] **W007** — List README-required services and applications
- [ ] **W008** — List prohibited applications, files and remote-access tools
- [ ] **W009** — Identify required network shares and their authorized users
- [ ] **W010** — Identify required network services and listening ports
- [ ] **W011** — Confirm the current administrator can elevate successfully
- [ ] **W012** — Record a VM recovery method or approved snapshot if allowed
- [ ] **W013** — Open an elevated PowerShell window
- [ ] **W014** — Record every changed setting and its original value

## 02. Forensic questions and evidence  
*Full guide: [Part 2](../windows-10-11.md#stage-2)*

- [ ] **W015** — Find every Forensics Question file supplied with the image
- [ ] **W016** — Read each complete question and required answer format
- [ ] **W017** — Locate the relevant user, file, program, event or configuration
- [ ] **W018** — Record suspicious-file paths before any cleanup
- [ ] **W019** — Record file hash when the question requests one
- [ ] **W020** — Record timestamps and time zone when requested
- [ ] **W021** — Inspect relevant Event Viewer logs without clearing them
- [ ] **W022** — Decode requested text only as data; never execute it
- [ ] **W023** — Save each answer in the original question file
- [ ] **W024** — Confirm every question file was saved
- [ ] **W025** — Reopen unanswered questions after other safe investigations

## 03. Users, Guest account and administrators  
*Full guide: [Part 3](../windows-10-11.md#stage-3)*

- [ ] **W026** — List all local users, including disabled and built-in accounts
- [ ] **W027** — Compare human users with the README authorization list
- [ ] **W028** — Inspect built-in Guest account state
- [ ] **W029** — Inspect built-in Administrator account and recovery requirements
- [ ] **W030** — Inspect local Administrators group membership
- [ ] **W031** — Inspect Remote Desktop Users group membership
- [ ] **W032** — Inspect Backup Operators and any other privileged local groups
- [ ] **W033** — Identify domain groups that legitimately administer this workstation
- [ ] **W034** — Check PasswordRequired and PasswordNeverExpires for each real user
- [ ] **W035** — Check each authorized user's Enabled state
- [ ] **W036** — Disable a confirmed unauthorized user only after preserving evidence
- [ ] **W037** — Remove confirmed unauthorized local administrator membership
- [ ] **W038** — Add a missing authorized user only if the README requires it
- [ ] **W039** — Restore missing authorized administrator membership if needed
- [ ] **W040** — Set a required user's password interactively if policy requires it
- [ ] **W041** — Verify local user and privileged-group membership after changes
- [ ] **W042** — Test a second authorized administrator sign-in

## 04. Passwords, lockout and effective policy  
*Full guide: [Part 3](../windows-10-11.md#stage-3)*

- [ ] **W043** — Record current local account password policy with net accounts
- [ ] **W044** — Inspect minimum password length
- [ ] **W045** — Inspect maximum password age
- [ ] **W046** — Inspect minimum password age
- [ ] **W047** — Inspect password history requirement
- [ ] **W048** — Inspect complexity requirement
- [ ] **W049** — Inspect reversible encryption setting
- [ ] **W050** — Inspect account lockout threshold
- [ ] **W051** — Inspect account lockout duration
- [ ] **W052** — Inspect account lockout observation window
- [ ] **W053** — Check whether Group Policy overrides local settings
- [ ] **W054** — Back up current policy values before editing
- [ ] **W055** — Change only values actually required by the image
- [ ] **W056** — Verify final account policy with net accounts and policy GUI
- [ ] **W057** — Test an authorized normal-user login after policy changes

## 05. Defender and endpoint protection  
*Full guide: [Part 3](../windows-10-11.md#stage-3)*

- [ ] **W058** — Identify which antivirus provider is active
- [ ] **W059** — Check Microsoft Defender antivirus and real-time protection state
- [ ] **W060** — Check behavior monitoring state
- [ ] **W061** — Check script scanning state
- [ ] **W062** — Check cloud-delivered protection when available
- [ ] **W063** — Check potentially unwanted application protection
- [ ] **W064** — Inspect Defender exclusion paths
- [ ] **W065** — Inspect Defender excluded file extensions
- [ ] **W066** — Inspect Defender excluded processes
- [ ] **W067** — Review exclusions against required applications before removal
- [ ] **W068** — Check current Defender signature date
- [ ] **W069** — Update signatures when required and supported
- [ ] **W070** — Review protection history and relevant detections
- [ ] **W071** — Perform an approved scan after collecting forensic evidence
- [ ] **W072** — Verify protection state and required software still work

## 06. Firewall and network exposure  
*Full guide: [Part 3](../windows-10-11.md#stage-3)*

- [ ] **W073** — Check Domain firewall profile Enabled state
- [ ] **W074** — Check Private firewall profile Enabled state
- [ ] **W075** — Check Public firewall profile Enabled state
- [ ] **W076** — Check default inbound and outbound actions
- [ ] **W077** — Identify the currently active network profile
- [ ] **W078** — Inventory enabled inbound allow rules
- [ ] **W079** — Inspect suspicious rules for executable and port scope
- [ ] **W080** — Inspect remote IP scope of required inbound rules
- [ ] **W081** — List listening TCP ports and their owning processes
- [ ] **W082** — List listening UDP endpoints where needed
- [ ] **W083** — Record or export existing firewall policy before risky changes
- [ ] **W084** — Enable appropriate profiles only after required exceptions are safe
- [ ] **W085** — Disable only confirmed unauthorized inbound rules
- [ ] **W086** — Test every README-required network function from an approved client
- [ ] **W087** — Verify firewall state and record any rollback needed

## 07. Updates and Windows features  
*Full guide: [Part 3](../windows-10-11.md#stage-3)*

- [ ] **W088** — Open Windows Update and inspect pending updates
- [ ] **W089** — Check Windows Update service configuration
- [ ] **W090** — Check whether updates are managed by domain policy
- [ ] **W091** — Inspect update history and any failed security updates
- [ ] **W092** — Install permitted security updates without forced release upgrade
- [ ] **W093** — Update required applications and browsers from approved sources
- [ ] **W094** — Check whether a restart is pending
- [ ] **W095** — Verify required applications still work after updates
- [ ] **W096** — Inspect SMBv1 optional feature state
- [ ] **W097** — Inspect SMB client signing requirement
- [ ] **W098** — Inspect SMB server signing requirement
- [ ] **W099** — Review legacy Telnet, TFTP, SNMP and PowerShell 2.0 components
- [ ] **W100** — Disable an unnecessary legacy feature only if compatible
- [ ] **W101** — Verify disabled feature state and any reboot requirement

## 08. Services, remote access and sharing  
*Full guide: [Part 4](../windows-10-11.md#stage-4)*

- [ ] **W102** — Inventory installed services and startup types
- [ ] **W103** — Map unexpected service executables to actual file paths
- [ ] **W104** — Check Remote Registry state and whether it is required
- [ ] **W105** — Check Remote Desktop state and whether it is required
- [ ] **W106** — Check Network Level Authentication if RDP is required
- [ ] **W107** — Review authorized Remote Desktop Users membership
- [ ] **W108** — Check Remote Assistance policy and any required exception
- [ ] **W109** — Check SSH server or other remote-control services
- [ ] **W110** — Check required web, file, database or backup services
- [ ] **W111** — Check SMB share names and underlying folder paths
- [ ] **W112** — Check each required share's share permissions
- [ ] **W113** — Check each required share's NTFS permissions
- [ ] **W114** — Test file access as an authorized nonadministrator
- [ ] **W115** — Disable a confirmed unnecessary service one at a time
- [ ] **W116** — Verify remaining required services still function
- [ ] **W117** — Restore any required service accidentally disabled

## 09. Prohibited software, files and browser security  
*Full guide: [Part 4](../windows-10-11.md#stage-4)*

- [ ] **W118** — Inspect installed desktop programs and app packages
- [ ] **W119** — Inspect Microsoft Store apps when relevant
- [ ] **W120** — Inspect portable utilities not registered as installed programs
- [ ] **W121** — Compare remote-control and networking tools with README
- [ ] **W122** — Identify prohibited games or torrent clients
- [ ] **W123** — Preview or review uninstall effects before removing software
- [ ] **W124** — Locate potentially prohibited media files without bulk deletion
- [ ] **W125** — Preserve files involved in forensic questions
- [ ] **W126** — Check browser version and permitted extensions
- [ ] **W127** — Check SmartScreen and suspicious download warnings
- [ ] **W128** — Check AutoPlay or automatic removable-media actions
- [ ] **W129** — Verify approved browsers and apps still launch
- [ ] **W130** — Confirm prohibited items were handled without affecting needed apps

## 10. Startup persistence and malicious changes  
*Full guide: [Part 4](../windows-10-11.md#stage-4)*

- [ ] **W131** — Inspect Startup apps for unknown executables
- [ ] **W132** — Inspect HKLM Run startup registry entries
- [ ] **W133** — Inspect HKCU Run startup registry entries
- [ ] **W134** — Inspect scheduled tasks and task actions
- [ ] **W135** — Inspect newly installed or suspicious services
- [ ] **W136** — Inspect service Log On As identities
- [ ] **W137** — Check unexpected executables in AppData or Temp
- [ ] **W138** — Inspect hosts-file changes and required entries
- [ ] **W139** — Inspect unexpected listening ports or remote connections
- [ ] **W140** — Check suspicious executable hash and signature
- [ ] **W141** — Inspect Sticky Keys or accessibility-program replacement indicators
- [ ] **W142** — Correlate suspicious entries with event logs
- [ ] **W143** — Disable only confirmed unauthorized persistence after preserving evidence
- [ ] **W144** — Verify suspicious startup item no longer runs
- [ ] **W145** — Retest required logins and applications

## 11. Audit, user rights and advanced safeguards  
*Full guide: [Part 5](../windows-10-11.md#stage-5)*

- [ ] **W146** — Inspect current audit policy categories
- [ ] **W147** — Check account logon auditing where required
- [ ] **W148** — Check account management auditing where required
- [ ] **W149** — Check logon and logoff auditing where required
- [ ] **W150** — Check policy-change auditing where required
- [ ] **W151** — Check process creation auditing if required
- [ ] **W152** — Inspect User Account Control enabled state
- [ ] **W153** — Inspect security options for guest and anonymous access
- [ ] **W154** — Inspect interactive logon and inactivity settings
- [ ] **W155** — Inspect user rights for privileged groups
- [ ] **W156** — Inspect effective Group Policy precedence
- [ ] **W157** — Inspect SMB signing and NTLM compatibility before changes
- [ ] **W158** — Inspect screen lock and resume authentication
- [ ] **W159** — Inspect WDigest plaintext-credential policy where relevant
- [ ] **W160** — Inspect LLMNR and NetBIOS policy only if role-compatible
- [ ] **W161** — Verify new audit events appear when auditing is enabled
- [ ] **W162** — Restore exact recorded policy if access breaks

## 12. Final verification and handoff  
*Full guide: [Part 6](../windows-10-11.md#stage-6)*

- [ ] **W163** — Reopen and save all forensic answer files
- [ ] **W164** — Recheck the complete authorized user and admin list
- [ ] **W165** — Verify strong password and lockout policy matches README
- [ ] **W166** — Verify Defender status and signature freshness
- [ ] **W167** — Verify all applicable firewall profiles are on
- [ ] **W168** — Verify only necessary inbound exceptions remain
- [ ] **W169** — Verify updates are complete or pending status documented
- [ ] **W170** — Verify required services, shares and web connections work
- [ ] **W171** — Verify no unauthorized software or persistence remains
- [ ] **W172** — Confirm administrator and ordinary user logins still work
- [ ] **W173** — Refresh scoring report and record final value and time
- [ ] **W174** — Review each change and its rollback note
- [ ] **W175** — Save any permitted evidence and cleanly finish without unsafe reboot


---

### Finish notes

**Tasks marked N/A (IDs and reasons):** _______________________________________________

**Required services tested:** __________________________________________________________

**Unexpected score changes or remaining issues:** ______________________________________

**Final reviewer initials / date:** ____________________________________________________
