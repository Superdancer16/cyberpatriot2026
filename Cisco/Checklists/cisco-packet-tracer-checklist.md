# 🌐 Cisco Packet Tracer — Printable Checklist & GitHub Progress Tracker

> **Source:** [Complete Cisco Packet Tracer guide](../Cisco/packet-tracer.md). This is a **separate tracking tool**, not a replacement for that guide.
>
> **Print:** Use `cisco-packet-tracer-checklist.pdf` and mark each small task as completed.
>
> **Track in GitHub:** Edit this tracker, change `[ ]` to `[x]`, and commit the change. If an item doesn't apply, record `(N/A — reason)` alongside it. Checkboxes in rendered GitHub Markdown don't automatically save when clicked.
>
> **Important:** Packet Tracer exercises vary. Only configure interfaces, routing, security and services that the actual activity requires; never modify activity assessment/grader files.

**Round/date:** ___________________  **Activity/file:** ___________________  **Team:** ___________________

**Initial result:** __________  **Final result:** __________  **Reviewer:** ___________________

## 01. Read and preserve the Packet Tracer activity  
*Full guide: [Part 2](../Cisco/packet-tracer.md#stage-2)*

- [ ] **C001** — Read the entire Packet Tracer activity instruction pane
- [ ] **C002** — Identify required PKA/PKT file type and submission method
- [ ] **C003** — Record the exact device names mentioned in the task
- [ ] **C004** — Record all required configurations and changes
- [ ] **C005** — Record settings or services that must remain unchanged
- [ ] **C006** — Identify available Check Results or Activity Assessment controls
- [ ] **C007** — Use grading feedback only when the activity permits it
- [ ] **C008** — Save a working copy of the activity if permitted
- [ ] **C009** — Record initial completion result when shown
- [ ] **C010** — Identify all permitted source notes and external resources
- [ ] **C011** — Do not erase any device startup configuration
- [ ] **C012** — Do not reset or modify the activity assessment/grader
- [ ] **C013** — Keep a task list with each device and interface

## 02. Inspect topology, IP plan and endpoints  
*Full guide: [Part 2](../Cisco/packet-tracer.md#stage-2)*

- [ ] **C014** — Identify all routers and their model/IOS capabilities
- [ ] **C015** — Identify all switches and model/port numbering
- [ ] **C016** — Identify every PC, server and wireless endpoint
- [ ] **C017** — Record each physical link between devices
- [ ] **C018** — Record router interface names and peer interfaces
- [ ] **C019** — Record client VLAN membership requirements
- [ ] **C020** — Record IPv4 addresses and masks for each LAN
- [ ] **C021** — Record client default gateways
- [ ] **C022** — Record DNS server addresses
- [ ] **C023** — Record any IPv6 prefixes and addresses
- [ ] **C024** — Record each server's configured address and role
- [ ] **C025** — Record static and dynamic routing requirements
- [ ] **C026** — Check which topology devices are administratively shut down
- [ ] **C027** — Record each network service to test at the end

## 03. Cisco IOS basics and safe baseline  
*Full guide: [Part 2](../Cisco/packet-tracer.md#stage-2)*

- [ ] **C028** — Open the CLI on each relevant router and switch
- [ ] **C029** — Identify user EXEC and privileged EXEC prompt
- [ ] **C030** — Enter enable mode only with authorized credentials
- [ ] **C031** — Check device model and IOS version
- [ ] **C032** — Inspect running configuration
- [ ] **C033** — Inspect saved startup configuration
- [ ] **C034** — Check interface IP addresses and status
- [ ] **C035** — Check relevant switch VLAN list
- [ ] **C036** — Check operational trunks if supported
- [ ] **C037** — Check router routing table
- [ ] **C038** — Check access lists if configured
- [ ] **C039** — Record original settings before any modification
- [ ] **C040** — Use question-mark help for an unsupported command
- [ ] **C041** — Do not run erase startup-config or reload as a shortcut

## 04. Physical links and interface state  
*Full guide: [Part 3](../Cisco/packet-tracer.md#stage-3)*

- [ ] **C042** — Check every required cable connects correct ports
- [ ] **C043** — Check cable/media compatibility and interface modules
- [ ] **C044** — Check correct router/switch interface identity
- [ ] **C045** — Check both ends of an unexpectedly down link
- [ ] **C046** — Distinguish administratively down from down/down
- [ ] **C047** — Enable only a required disabled interface
- [ ] **C048** — Confirm link becomes operational after change
- [ ] **C049** — Check switch port speed and duplex if required
- [ ] **C050** — Check line protocol state where supported
- [ ] **C051** — Verify local gateway ping when IP is configured
- [ ] **C052** — Restore an intentionally disabled port if changed incorrectly
- [ ] **C053** — Record and resolve unexpected link failure before continuing

## 05. PC, server and network addressing  
*Full guide: [Part 3](../Cisco/packet-tracer.md#stage-3)*

- [ ] **C054** — Open each PC Desktop IP Configuration
- [ ] **C055** — Check static versus DHCP choice
- [ ] **C056** — Check each client IPv4 address
- [ ] **C057** — Check each client subnet mask
- [ ] **C058** — Check each client default gateway
- [ ] **C059** — Check each client's DNS server
- [ ] **C060** — Check server IP, subnet and gateway if present
- [ ] **C061** — Verify subnet network/broadcast logic for assigned prefix
- [ ] **C062** — Check no host uses a conventional broadcast/network address
- [ ] **C063** — Check duplicate addresses or incorrect host subnet
- [ ] **C064** — Run ipconfig on required PC when supported
- [ ] **C065** — Ping each client's local gateway
- [ ] **C066** — Ping same-VLAN destination when required
- [ ] **C067** — Restore exact originally assigned IP data if needed

## 06. VLANs, access ports and trunks  
*Full guide: [Part 3](../Cisco/packet-tracer.md#stage-3)*

- [ ] **C068** — Inspect existing VLAN IDs and names
- [ ] **C069** — Create only the missing task-required VLANs
- [ ] **C070** — Verify every required VLAN exists
- [ ] **C071** — Identify each access port for an endpoint
- [ ] **C072** — Configure correct access VLAN on each assigned port
- [ ] **C073** — Verify access port mode is appropriate
- [ ] **C074** — Confirm required access ports are enabled
- [ ] **C075** — Identify all inter-switch trunk links
- [ ] **C076** — Identify router-on-a-stick trunk links
- [ ] **C077** — Check trunking mode at both ends
- [ ] **C078** — Check 802.1Q tagging/encapsulation support
- [ ] **C079** — Check allowed VLAN list at both trunk ends
- [ ] **C080** — Check native VLAN setting and mismatch risks
- [ ] **C081** — Preserve existing required management and voice VLANs
- [ ] **C082** — Verify show interfaces trunk output
- [ ] **C083** — Verify required VLAN clients communicate
- [ ] **C084** — Restore accidentally pruned VLAN or wrong port mode

## 07. VLAN gateways and inter-VLAN routing  
*Full guide: [Part 3](../Cisco/packet-tracer.md#stage-3)*

- [ ] **C085** — Identify router-on-a-stick versus Layer 3 switch design
- [ ] **C086** — Verify router physical interface for VLAN trunk is enabled
- [ ] **C087** — Check correct 802.1Q subinterface per VLAN
- [ ] **C088** — Check subinterface VLAN ID matches intended tagged VLAN
- [ ] **C089** — Check each subinterface IPv4 address and subnet
- [ ] **C090** — Check trunk carries every required routed VLAN
- [ ] **C091** — Check client gateways point at correct router/SVI
- [ ] **C092** — Check SVI exists on multilayer switch when used
- [ ] **C093** — Check operational Layer 2 member ports for each active SVI
- [ ] **C094** — Enable ip routing only on capable switch when required
- [ ] **C095** — Verify each client can reach its local gateway
- [ ] **C096** — Verify permitted communication between VLAN subnets
- [ ] **C097** — Restore previously correct subinterface/SVI settings if needed

## 08. Static, default and dynamic routing  
*Full guide: [Part 3](../Cisco/packet-tracer.md#stage-3)*

- [ ] **C098** — Inspect connected routes on each router
- [ ] **C099** — List all required remote destination networks
- [ ] **C100** — Check static route next hops for correct reachability
- [ ] **C101** — Check default route on the appropriate upstream router
- [ ] **C102** — Check return routes on remote networks
- [ ] **C103** — Check subnet mask/prefix for each installed route
- [ ] **C104** — Verify longest-prefix routing behavior if multiple routes match
- [ ] **C105** — Identify assigned dynamic routing protocol
- [ ] **C106** — Check OSPF process and area assignments if required
- [ ] **C107** — Check OSPF neighbor states
- [ ] **C108** — Check OSPF-learned routes
- [ ] **C109** — Check EIGRP AS/network selection if required
- [ ] **C110** — Check EIGRP neighbors and learned routes
- [ ] **C111** — Check RIPv2 version and network selection if required
- [ ] **C112** — Check routing protocol administrative distance when relevant
- [ ] **C113** — Ping an approved remote test host
- [ ] **C114** — Use traceroute to locate an unexpected routed failure
- [ ] **C115** — Undo only one incorrect route/protocol setting

## 09. DHCP pools, relay and DNS  
*Full guide: [Part 3](../Cisco/packet-tracer.md#stage-3)*

- [ ] **C116** — Identify the actual DHCP server device
- [ ] **C117** — Inspect DHCP pool network and subnet mask
- [ ] **C118** — Inspect default-router option in DHCP pool
- [ ] **C119** — Inspect DNS server option in DHCP pool
- [ ] **C120** — Inspect reserved/excluded address ranges
- [ ] **C121** — Check pool has usable remaining leases
- [ ] **C122** — Check client-facing router helper address if DHCP is remote
- [ ] **C123** — Check DHCP snooping trust when configured
- [ ] **C124** — Request/renew DHCP on one approved client
- [ ] **C125** — Verify assigned client IP and prefix
- [ ] **C126** — Verify assigned gateway and DNS data
- [ ] **C127** — Inspect DNS server service status
- [ ] **C128** — Inspect required DNS records and hostnames
- [ ] **C129** — Check client DNS server address matches service
- [ ] **C130** — Verify required hostname resolves or opens
- [ ] **C131** — Restore only an incorrect pool/helper/DNS record

## 10. Application/server tasks  
*Full guide: [Part 4](../Cisco/packet-tracer.md#stage-4)*

- [ ] **C132** — Check required Packet Tracer server service list
- [ ] **C133** — Check HTTP or HTTPS enabled if required
- [ ] **C134** — Open required web page via IP
- [ ] **C135** — Open required web page via DNS hostname
- [ ] **C136** — Check FTP service state when required
- [ ] **C137** — Check FTP authorized user account
- [ ] **C138** — Test an authorized FTP file transfer
- [ ] **C139** — Check TFTP service/file when required
- [ ] **C140** — Check email domain and user accounts when required
- [ ] **C141** — Test mail send/receive if assigned
- [ ] **C142** — Check time/NTP if assigned
- [ ] **C143** — Check required application firewall/ACL path
- [ ] **C144** — Do not enable unrelated server services
- [ ] **C145** — Restore service/record data if a client test fails

## 11. Cisco device login and SSH  
*Full guide: [Part 4](../Cisco/packet-tracer.md#stage-4)*

- [ ] **C146** — Check intended hostname and domain name
- [ ] **C147** — Check enable secret requirement
- [ ] **C148** — Check authorized local usernames and secrets
- [ ] **C149** — Check console line login and passwords if assigned
- [ ] **C150** — Check VTY lines and their transport settings
- [ ] **C151** — Check SSH keys/IOS support
- [ ] **C152** — Check SSH v2 setting where supported
- [ ] **C153** — Verify no unnecessary Telnet access if SSH-only required
- [ ] **C154** — Check management SVI/router interface IP reachability
- [ ] **C155** — Check VTY ACL or approved management hosts if assigned
- [ ] **C156** — Test a new authorized SSH login
- [ ] **C157** — Preserve console recovery if SSH fails
- [ ] **C158** — Check banner or password policy only if task requires it
- [ ] **C159** — Save device configuration after verified changes

## 12. ACLs, port security and STP  
*Full guide: [Part 4](../Cisco/packet-tracer.md#stage-4)*

- [ ] **C160** — List traffic flows that must be allowed
- [ ] **C161** — List traffic flows that must be denied
- [ ] **C162** — Record source and destination networks for ACL
- [ ] **C163** — Record protocol and port for extended ACL
- [ ] **C164** — Check ACL wildcard mask against intended prefix
- [ ] **C165** — Inspect ACL rule order and implicit deny
- [ ] **C166** — Check ACL interface binding and direction
- [ ] **C167** — Apply only task-required ACL entries
- [ ] **C168** — Test one permitted flow across ACL
- [ ] **C169** — Test one intentionally blocked flow across ACL
- [ ] **C170** — Check access port maximum MAC address setting
- [ ] **C171** — Check port-security violation mode
- [ ] **C172** — Check learned/sticky MAC state when required
- [ ] **C173** — Confirm edge port security does not disable legitimate PC
- [ ] **C174** — Check STP topology and root bridge where required
- [ ] **C175** — Check PortFast only on genuine host-facing edge port
- [ ] **C176** — Check BPDU Guard does not disable switch uplink
- [ ] **C177** — Restore accidental ACL/port-security/STP disruption

## 13. EtherChannel, NAT, wireless and IPv6  
*Full guide: [Part 5](../Cisco/packet-tracer.md#stage-5)*

- [ ] **C178** — Check whether EtherChannel is actually required
- [ ] **C179** — Check EtherChannel member ports and modes
- [ ] **C180** — Verify matching trunk/VLAN settings on bundle members
- [ ] **C181** — Check LACP negotiation compatibility
- [ ] **C182** — Verify show etherchannel summary where supported
- [ ] **C183** — Identify NAT inside and outside interfaces if required
- [ ] **C184** — Inspect NAT selection ACL
- [ ] **C185** — Check PAT overload mapping when required
- [ ] **C186** — Generate matching inside-to-outside traffic
- [ ] **C187** — Verify NAT translations appear
- [ ] **C188** — Record wireless SSID exactly as assigned
- [ ] **C189** — Check wireless security mode and passphrase
- [ ] **C190** — Verify client wireless adapter/association
- [ ] **C191** — Verify wireless client DHCP/address/gateway
- [ ] **C192** — Check IPv6 unicast-routing requirement
- [ ] **C193** — Check IPv6 addresses and prefix lengths
- [ ] **C194** — Check IPv6 neighbor and route information
- [ ] **C195** — Test authorized IPv6 reachability
- [ ] **C196** — Restore specific bad advanced configuration if needed

## 14. Troubleshooting and simulation  
*Full guide: [Part 5](../Cisco/packet-tracer.md#stage-5)*

- [ ] **C197** — Test problem from lower layers upward
- [ ] **C198** — Check physical cable and interface first
- [ ] **C199** — Check client subnet and gateway next
- [ ] **C200** — Check access VLAN and trunk allowances
- [ ] **C201** — Check router subinterface or SVI
- [ ] **C202** — Check forward and return routes
- [ ] **C203** — Check ACL direction and actual permitted traffic
- [ ] **C204** — Check DHCP relay and server when lease fails
- [ ] **C205** — Check DNS when IP works but hostname fails
- [ ] **C206** — Check HTTP service when ping works but web fails
- [ ] **C207** — Check port security or BPDU shutdown when edge port fails
- [ ] **C208** — Check NAT only if translations are required
- [ ] **C209** — Use Packet Tracer Simulation Mode when helpful
- [ ] **C210** — Filter ARP/ICMP/DHCP/DNS protocol events where supported
- [ ] **C211** — Use Capture/Forward to see the first drop
- [ ] **C212** — Confirm intended blocked flows versus unintended drops
- [ ] **C213** — Verify a changed setting with actual client traffic

## 15. Final review, saving and submission  
*Full guide: [Part 6](../Cisco/packet-tracer.md#stage-6)*

- [ ] **C214** — Recheck all task-required interface statuses
- [ ] **C215** — Recheck all PC/server IP and gateway settings
- [ ] **C216** — Recheck required VLANs and trunks
- [ ] **C217** — Recheck static or dynamic routes and return paths
- [ ] **C218** — Recheck DHCP leases and DNS functionality
- [ ] **C219** — Recheck web/FTP/email required services
- [ ] **C220** — Recheck SSH or management authentication
- [ ] **C221** — Recheck allowed and denied ACL flows
- [ ] **C222** — Recheck port security/STP and other advanced features
- [ ] **C223** — Inspect any permitted Check Results only as allowed
- [ ] **C224** — Confirm no unrelated working configuration was removed
- [ ] **C225** — Save running-config to startup-config when required
- [ ] **C226** — Save the correct PKA/PKT file under required name
- [ ] **C227** — Submit activity through the official method if required
- [ ] **C228** — Record completion/result and outstanding items
- [ ] **C229** — Confirm no invented credentials/IPs remain from examples

---

### Completion notes

**N/A task IDs / reasons:** ______________________________________________________________

**Required end-to-end tests passed:** ____________________________________________________

**Outstanding configuration items:** ____________________________________________________

**Reviewer initials / date:** ___________________________________________________________
