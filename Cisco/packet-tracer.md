# Cisco Packet Tracer — Complete CyberPatriot Step-by-Step Handbook

**One comprehensive Packet Tracer guide:** configure, verify, troubleshoot, and preserve every network function required by an authorized CyberPatriot activity. It consolidates the former Cisco networking/configuration guide and the switching/routing/ACL troubleshooting guide, adds new detailed workflows, and retains the original command reference and labs below.

> [!IMPORTANT]
> **There is no universal maximum-score command list.** The actual Packet Tracer activity, task text, device capabilities, hidden grading rules and allowed tools control what is assessed. Never assume a recommendation earns points. Do not invent addresses, interface names, task passwords or router roles for a live activity. **Inspect → make the smallest task-required change → verify → record recovery → save.**
>
> The examples below are **original practice configurations using documentation IPs**. Copy them only in a matching, authorized training topology after replacing every example address, interface, VLAN and credential. Commands are shown without IOS prompts so they can be pasted into the appropriate CLI mode. **Do not use commands unsupported by the selected Packet Tracer IOS device.**


> **Guide order:** Basics/Info → First Things to Do → High-priority connectivity → Services/security → Advanced features → Final verification. Exact activity task requirements take precedence; no particular configuration is guaranteed to earn points.

## Part 1 — Basics / Information Needed

### Cisco basics you need before using the Packet Tracer CLI

- [ ] Understand a **PC/host**, switch, router, gateway, interface/port, MAC address, IPv4 subnet, VLAN and trunk.
- [ ] Know **User EXEC (>)**, **Privileged EXEC (#)**, **Global config ((config)#)**, and **interface config ((config-if)#)**.
- [ ] Know that **show** commands inspect state while **configure terminal** changes the device. **end** returns to privileged EXEC, and a **no** command generally reverses a specific setting.
- [ ] Understand saving: **copy running-config startup-config** saves active IOS changes; a Packet Tracer activity file must be saved/submitted separately.
- [ ] Identify the activity's **required interfaces, addressing, passwords, VLANs and services** before making any change.

**Typing (check, Cisco CLI):**

~~~text
enable
show version
show running-config
show ip interface brief
~~~

**How to read a result:** Administratively down means the interface was shut by config; up/up indicates operational link status, not proof the web/DNS application works. Never use **erase startup-config** or **reload** as a generic recovery step.

## Part 2 — First Things to Do

Read the current task scope and learn the CLI before touching configuration.

### CyberPatriot XIX (2026–2027): official Packet Tracer scope

The [official CP-19 challenges-by-round page](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round) specifies the following **public** module ranges and challenge point totals. This is not a list of individual scoring requirements.

| Division / round | Packet Tracer modules | Maximum challenge points shown |
|---|---|---:|
| All teams — practice round | Intro | Unscored |
| High school — Round 1 | 1–7 | 20 |
| High school — Round 2 | 1–11 and 21–22 | 20 |
| High school — State Round | 1–17 | 70 |
| High school — Semifinals, Platinum | 1–23 | 168 |
| High school — Semifinals, Gold/Silver | 1–23 | 70 |
| Middle school — introductory round | 1–7 | 20 |
| Middle school — State Round | 1–11 and 21–22 | 20 |
| Middle school — Semifinals | 1–17 and 21–22 | 20 |

The official [CyberPatriot training page](https://www.uscyberpatriot.org/competition/training-materials) distinguishes the **NetAcad Content Course** (study material) from the **Competition Course** (graded quiz and Packet Tracer exercise). Follow the assigned modules for your round. The practical topics below are a **broad skills inventory**, not a prediction of every actual activity.

---

### Start here: tasks, priority and navigation

- [0. Read the activity, save safely, identify requirements](#0-before-you-configure-anything)
- [1. Inventory devices, address plan and topology](#1-inventory-the-topology)
- [2. IOS CLI and baseline inspection](#2-ios-cli-and-baseline-inspection)
- [3. Physical interfaces, cabling and status](#3-physical-interfaces-and-links)
- [4. End devices, servers and IP settings](#4-pcs-servers-and-ip-addressing)
- [5. VLANs, access ports, trunks and management](#5-vlans-access-ports-and-trunks)
- [6. Inter-VLAN routing](#6-inter-vlan-routing)
- [7. Static, default and return routing](#7-static-and-default-routing)
- [8. Dynamic routing: OSPF, EIGRP, RIP](#8-dynamic-routing-ospf-eigrp-and-rip)
- [9. DHCP pools and relay](#9-dhcp-pools-and-relay)
- [10. DNS, HTTP, email, FTP, TFTP](#10-server-and-application-services)
- [11. Port security and edge protections](#11-port-security-and-switch-edge-protections)
- [12. STP, EtherChannel and trunk protections](#12-stp-etherchannel-and-trunk-security)
- [13. IPv4 ACLs and filtering](#13-ipv4-acls-and-filtering)
- [14. NAT and PAT](#14-nat-and-pat)
- [15. Wireless networks](#15-wireless-configuration)
- [16. IPv6](#16-ipv6-addressing-and-routing)
- [17. Secure router/switch management](#17-secure-device-management)
- [18. Logging, neighbor discovery and management checks](#18-logging-and-management-visibility)
- [19. Packet Tracer tools, simulation and scoring](#19-packet-tracer-simulation-and-activity-checks)
- [20. Symptom-first troubleshooting and final verification](#20-symptom-first-troubleshooting)
- [21. Expanded original Cisco configuration reference](#21-expanded-original-configuration-reference)
- [22. Consolidated switch, routing and security troubleshooting](#22-consolidated-troubleshooting-reference)
- [23. Source and safety notes](#23-sources-and-scope)

This is **Packet Tracer practice**, not a substitute for the separate [Cisco quiz Q&A guide](cisco-quiz.md). Read a configuration step's **Before**, **Clicking**, **Typing (check)**, **Typing (change)**, **Verify**, and **Undo** blocks before attempting it.

---

---

### 0. Before you configure anything

- [ ] Read the complete activity instructions and save the required files.

**Clicking (Packet Tracer):**
1. Open **Cisco Packet Tracer**, using a compatible installation from the official [Getting Started with Packet Tracer](https://www.netacad.com/courses/getting-started-cisco-packet-tracer/1000) course.
2. In the activity's **Competition Course**, open/download the assigned exercise using the official instructions. A **.pka** activity can include grading and locked features; a **.pkt** file is a normal Packet Tracer network file.
3. Read the entire **Instructions / Activity** pane (may be displayed separately). Read every device name, hostname, interface, IP/prefix, username, password, VLAN, required protocol, and what is **not** allowed to change.
4. When permitted, **File → Save As** to preserve an original working copy. Retain the expected file type; do not convert a graded PKA into a generic PKT and expect its activity grading to survive.
5. Keep a private task checklist. For each instruction note: **Device → exact interface/configuration → command/UI action → how to verify → done**.
6. Do not immediately change all passwords, VLANs, routes or interface states. Some instructions **require an existing configuration to remain**.

**Activity scoring:** Some practice PKA files expose a completion percentage, **Check Results**, or **Assessment Items**; others hide or restrict them. Use only the features presented and permitted by that particular activity. No visible feedback is **not proof of success or failure**. Do not bypass locked grading, seek live answer files, or edit the assessment.

**Prioritize:** First restore necessary host IP/gateway/link connectivity, then VLAN/trunk, router interfaces/routes, services/DHCP/DNS, security and ACL tasks, then end-to-end verification. Follow the actual task order if dependencies differ.

---

---

### 1. Inventory the topology

- [ ] Completed a device/interface/address table before changing configuration.

**Clicking:** Select each router, switch, PC, server, AP and wireless router in the logical workspace. On routers/switches choose **CLI**, on PCs choose **Desktop → IP Configuration** and **Command Prompt**, and on Packet Tracer servers choose **Config / Services / Desktop** according to available tabs. Use **Physical** view when port modules or actual cabling must be inspected.

| Inventory item | Example to record | Why it matters |
|---|---|---|
| Device model and role | S1 switch, R1 router, Server0 | IOS features differ |
| Physical link | S1 Fa0/1 → R1 Gi0/0 | Commands must target the actual ports |
| Client network | VLAN 10, 192.168.10.0/24 | Must match access port, gateway and route |
| Gateway | R1 Gi0/0.10, 192.168.10.1 | Clients need a reachable next hop |
| Required server | DNS server 192.168.20.10 | Wrong address creates false service failures |
| Protocol/service | SSH, DHCP, HTTP, DNS, ACL | Verifies against activity objectives |

**Use only numbers provided by the activity**. The following examples describe a training topology:
- PC-A: 192.168.10.10/24, gateway 192.168.10.1, on VLAN 10;
- PC-B: 192.168.20.10/24, gateway 192.168.20.1, on VLAN 20;
- switch S1 connected to router R1 by a tagged uplink;
- independent second router R2 may be used later in routing exercises.

**Verify:** Match interface labels in the drawn topology and **show ip interface brief**. A switch port labelled Fa0/1 is different from Gi0/1; Packet Tracer switch models have different port counts.

---

---

### 2. IOS CLI and baseline inspection

- [ ] Can identify each mode and collect a safe read-only baseline.

| CLI prompt | Mode | What it allows |
|---|---|---|
| S1> | User EXEC | Some inspection |
| S1# | Privileged EXEC | Most show/diagnostic commands; enters config |
| S1(config)# | Global config | Hostname, routing, users, VLAN selection |
| S1(config-if)# | Interface config | Addresses, shutdown, switchport behavior |
| S1(config-line)# | Line config | Console and VTY login |
| S1(config-router)# | Routing protocol | OSPF/EIGRP/RIP settings |

**Clicking:** Device → **CLI** → press Enter. If initial configuration dialog appears on a blank lab device, follow the lab instructions; do not erase the configured activity.

**Typing (check; commands one by one):**

~~~text
enable
show version
show running-config
show startup-config
show ip interface brief
show interfaces
~~~

For a switch, where supported:

~~~text
show vlan brief
show interfaces trunk
show mac address-table
~~~

**What output means:** Interface state **up/up** usually means both interface and line protocol operate. **administratively down** means disabled by configuration; **down/down** can indicate cable, device, transceiver or shutdown. A trunk may be configured yet not carry the correct VLANs. A router often needs an IP route and a return route.

**Typing (learn modes):**

~~~text
configure terminal
hostname S1
end
show running-config
~~~

**Warning:** The hostname is an example only; use the requested name. From config mode, **exit** moves up one level; **end** returns to privileged EXEC; **?** displays context help. A **no** prefix usually removes/reverts a particular command, but can have a larger effect for some features—inspect first.

**Undo:** Save the previous value before changing it. Restore the old hostname or targeted interface value. Do **not** use erase startup-config, write erase, or reload for routine troubleshooting.

---

### First-steps mini-checklist (complete before changing configurations)

1. Read all activity instructions, record the exact topology and save a working copy **only when permitted**.
2. Identify each device/port and PC address with its **actual IP, mask, gateway and DNS**.
3. On switches inspect **show vlan brief** and **show interfaces trunk**.
4. On routers inspect **show ip interface brief** and **show ip route**.
5. On clients test local gateway, then remote subnet and the required application.
6. Only then identify a missing task requirement; change one setting, retest, record it, save the working device/activity when instructed.

**Typing (read-only baseline; run only commands supported on the selected device):**

~~~text
show ip interface brief
show vlan brief
show interfaces trunk
show ip route
show access-lists
~~~

Router devices may not support switch-only commands; a basic Layer 2 switch may not support IP routing commands. **No output is not a hidden scoring answer**; confirm your device and privilege mode.

## Part 3 — High-Priority Connectivity and Configuration

Interfaces, addressing, VLANs, trunks and routing form the foundation for many other tasks.

### 3. Physical interfaces and links

- [ ] Identified down interfaces and configured only those that the task needs enabled.

**Clicking:** Inspect the cable by hovering or using the physical links. End-device **Desktop → Command Prompt** can test connectivity once the link comes up. Choose the correct copper/fiber cable for the ports; automatic cable choice works in many Packet Tracer scenarios.

**Typing (check):**

~~~text
enable
show ip interface brief
show interfaces status
~~~

**Typing (change; example router port only):**

~~~text
configure terminal
interface gigabitEthernet 0/0
no shutdown
end
~~~

**Check it worked:**

~~~text
show ip interface brief
show interfaces gigabitEthernet 0/0
~~~

**Undo:** If the activity expressly requires that interface disabled, return to its original state using interface configuration then **shutdown**. Only shut a port after confirming it is **unused**; doing this to an uplink can disconnect multiple VLANs and invalidate other tasks.

**Common pitfalls:** Wrong physical port, disabled other endpoint, incompatible module/media, and confusing **up/down** versus **administratively down**. Cisco auto-MDIX support varies by device; do not assume a cable warning means VLAN configuration is wrong.

---

---

### 4. PCs, servers and IP addressing

- [ ] Checked IP, subnet mask, default gateway and DNS of every required end device.

**Clicking (PC):** PC → **Desktop → IP Configuration** → choose **Static** or **DHCP** exactly as instructed. For static IPv4 enter its IP, subnet mask, default gateway and DNS server. For IPv6 use the IPv6 section. Save/close the window; Packet Tracer generally persists settings within the activity file.

**Clicking (Server):** Server → **Desktop → IP Configuration** (address), and **Services** for application features. A server's **Config** tab may offer interface settings as well.

**Typing (check on the PC's Command Prompt, not router IOS):**

~~~text
ipconfig
ping 192.168.10.1
~~~

Replace the example gateway with the actual same-subnet router interface.

**Subnet sanity checks:** A /24 uses 255.255.255.0; a /26 uses 255.255.255.192. An IPv4 host treats an off-subnet destination as traffic for its gateway; it ARPs for the gateway MAC, not the remote host's MAC. In an ordinary /26 subnet, the usable range excludes the network and broadcast address.

**Verify:** Ping same-VLAN target, then local gateway, then destination on another subnet. A successful gateway ping does not prove DNS or HTTP is working; test them separately.

**Undo:** Restore the recorded original IP configuration and re-run **ipconfig** and pings.

---

---

### 5. VLANs, access ports and trunks

- [ ] Created the requested VLANs and verified each access port/uplink.

**Why:** VLANs split Layer 2 broadcast domains. An access port serves one data VLAN; an 802.1Q trunk can carry several VLANs. **Native VLAN** treatment and allowed VLANs must be coordinated between ends.

**Typing (check on switch):**

~~~text
enable
show vlan brief
show interfaces trunk
show spanning-tree
~~~

**Typing (create VLANs in a training S1):**

~~~text
configure terminal
vlan 10
name STUDENTS
exit
vlan 20
name STAFF
exit
end
~~~

**Typing (assign one confirmed PC-facing access port):**

~~~text
configure terminal
interface fastEthernet 0/5
switchport mode access
switchport access vlan 10
no shutdown
end
~~~

**Typing (trunk; ONLY when Gi0/1 is the actual uplink):**

~~~text
configure terminal
interface gigabitEthernet 0/1
switchport mode trunk
switchport trunk allowed vlan 10,20
no shutdown
end
~~~

**Important:** Setting **switchport trunk allowed vlan 10,20** may *replace* an existing allowed list and drop a required management/voice VLAN. Read the current list before changing it; use an additive operation when appropriate, with device support checked. Some switches need **switchport trunk encapsulation dot1q**, but many models do not support or need that command.

**Check it worked:**

~~~text
show vlan brief
show interfaces trunk
show running-config
~~~

If supported, inspect a specific port using **show interfaces fastEthernet 0/5 switchport**.

**Undo:** Restore the exact previous access VLAN, allowed list, native VLAN and port mode from the baseline. Test existing required clients again.

---

---

### 6. Inter-VLAN routing

- [ ] Selected the correct router-on-a-stick or Layer 3 switch design.

#### 6.1 Router-on-a-stick

**What:** A router uses 802.1Q subinterfaces on a physical uplink to route between VLANs.

**Before:** Switch-to-router port must be a trunk permitting the VLANs. The physical router interface must not be administratively down. The PC gateways must equal the respective router subinterface IPs.

**Typing (router example):**

~~~text
enable
configure terminal
interface gigabitEthernet 0/0
no shutdown
exit
interface gigabitEthernet 0/0.10
encapsulation dot1Q 10
ip address 192.168.10.1 255.255.255.0
exit
interface gigabitEthernet 0/0.20
encapsulation dot1Q 20
ip address 192.168.20.1 255.255.255.0
end
~~~

**Verify (router):**

~~~text
show ip interface brief
show ip route
~~~

**Verify (PCs):** PC-A pings 192.168.10.1, PC-B pings 192.168.20.1, then PC-A tests PC-B where allowed. If inter-VLAN traffic fails, inspect the trunk, gateway/mask and ACL before adding random static routes.

**Undo:** Restore the old physical/subinterface encapsulation, addresses and shutdown state. Removing an entire subinterface can disrupt an otherwise required VLAN.

#### 6.2 Layer 3 switch SVIs

**What:** A capable multilayer switch can route through a VLAN interface, after routing is enabled.

**Typing (example only on a switch that supports routing):**

~~~text
enable
configure terminal
ip routing
vlan 10
exit
interface vlan 10
ip address 192.168.10.1 255.255.255.0
no shutdown
end
~~~

**Verify:**

~~~text
show ip interface brief
show ip route
show vlan brief
~~~

A VLAN SVI can be down because the VLAN lacks an active Layer 2 port. On a **Layer 2-only switch**, use an SVI for management and (if appropriate) **ip default-gateway ADDRESS**; **ip routing** may be unsupported.

---

---

### 7. Static and default routing

- [ ] Verified forward **and return** routes before modifying topology.

**Typing (check):**

~~~text
enable
show ip route
show ip interface brief
~~~

**Typing (example: R1 must reach 192.168.30.0/24 through next-hop 192.168.12.2):**

~~~text
configure terminal
ip route 192.168.30.0 255.255.255.0 192.168.12.2
end
~~~

**Default route example** (only if next-hop is genuinely the upstream router):

~~~text
configure terminal
ip route 0.0.0.0 0.0.0.0 192.168.12.2
end
~~~

**Verify:**

~~~text
show ip route
ping 192.168.12.2
traceroute 192.168.30.10
~~~

**Interpret:** Longest-prefix match chooses the most specific installed route for forwarding. Administrative distance selects between **competing route sources for the same prefix**. A successful forward ping can still fail if the destination network lacks a return route.

**Undo:** Remove only the exact static route inserted, if wrong, e.g. **no ip route 192.168.30.0 255.255.255.0 192.168.12.2** in configuration mode. Reinstall the original if previously present.

---

---

### 9. DHCP pools and relay

- [ ] Identified the DHCP server/relay, lease scope, excluded addresses, gateway and DNS.

#### 9.1 Router as DHCP server

**Typing (check):**

~~~text
show ip dhcp pool
show ip dhcp binding
show running-config
~~~

**Example:**

~~~text
configure terminal
ip dhcp excluded-address 192.168.10.1 192.168.10.20
ip dhcp pool VLAN10
network 192.168.10.0 255.255.255.0
default-router 192.168.10.1
dns-server 192.168.20.10
end
~~~

**Explanation:** The excluded range protects fixed addresses. The pool must match the actual subnet and gateway. An excluded range is **not** a firewall rule.

**Verify:** On a test PC, **Desktop → IP Configuration → DHCP**, then **Desktop → Command Prompt → ipconfig**. Confirm address, mask, gateway and DNS, and ping the gateway.

#### 9.2 DHCP relay when server is on another subnet

**Before:** The client-facing router interface needs the helper address—not an arbitrary uplink.

~~~text
configure terminal
interface gigabitEthernet 0/0.10
ip helper-address 192.168.20.10
end
~~~

**Check:**

~~~text
show running-config
show ip dhcp binding
~~~

If the actual DHCP server is a Packet Tracer **Server**, the router's **show ip dhcp binding** may not contain its leases. Check the server's **Services → DHCP** and the client address instead.

**Undo:** Restore the original pool/helper definition; do not clear all leases, reset the DHCP server, or force a new address from every client.

---

### Research expansion: fast reachability and configuration inspection

- [ ] Check **one task at a time** and retain working neighboring VLANs/routes.

| Task category often seen in learning exercises | Check first | Verify end-to-end |
|---|---|---|
| IP address / gateway | PC Desktop → IP Configuration; show ip interface brief | PC ping local gateway |
| Switch access VLAN | show vlan brief; specific interface config | Same-VLAN hosts communicate |
| Trunk / router-on-a-stick | show interfaces trunk; router subinterface dot1Q | PC reaches each required gateway |
| Static routes | show ip route, next hop | Destination and **return** route reachability |
| DHCP | Router pool / Server Services → DHCP | PC receives correct lease, DNS, gateway |
| DNS / Web | Server Services → DNS / HTTP | Required hostname opens in PC browser |
| ACL | show access-lists; show ip interface | **Allowed** traffic works; **blocked** traffic fails |
| SSH | show ip ssh; VTY and local user settings | Approved admin logs in over SSH |
| Port security | show port-security interface | Allowed PC works without err-disabled port |

**Why prioritized?** These are prerequisites for many other networking tasks and recur in public training checklists. **They are not a claim about secret Packet Tracer grading criteria.**

**Common trap:** If the first ping times out because ARP is resolving, try it again after checking layer 2; do not immediately insert random static routes. On a permitted practice file, use **Simulation → Filters (ARP/ICMP/DHCP/DNS)** to see where a packet is lost.

## Part 4 — Required Applications and Network Security

Apply security requirements only after verifying the network path and keeping required access.

### 10. Server and application services

- [ ] Verified that each required service works at **application level**, not just with ping.

**Packet Tracer server GUI:** Select **Server → Services**. The available tabs depend on model and simulator version: typically **DNS, DHCP, HTTP, FTP, EMAIL, TFTP**. Use the name/address and user credentials provided by the activity.

| Service | Where to configure | Verification |
|---|---|---|
| DNS | Server → Services → DNS; add A/AAAA records if supported | PC browser opens assigned hostname / available name lookup |
| DHCP | Server → Services → DHCP; set pool, mask, gateway, DNS | Test PC gets correct lease |
| HTTP/HTTPS | Server → Services → HTTP; toggle only if required | PC **Desktop → Web Browser** loads expected page |
| FTP/TFTP | Server → Services → FTP or TFTP | Required authorized transfer works; account/filename exact |
| EMAIL | Server → Services → EMAIL; add domain/accounts | PC **Desktop → Email** sends/receives expected message |
| NTP | Compatible Server device → Services → NTP if available | Router/device time checks and service status |

**Worked DNS + HTTP example (only in a matching lab):**
1. Give Server0 static **192.168.20.10/24**, gateway **192.168.20.1**.
2. Under **Services → DNS**, enable DNS if required; create **www.lab.example → 192.168.20.10**.
3. Under **Services → HTTP**, enable HTTP if required; verify the supplied page exists.
4. Point the test PC's DNS setting to **192.168.20.10**.
5. In PC browser, open the required hostname. Verify a page loads—not just a ping to the IP.

**Troubleshooting:** If an IP works but hostname fails, inspect DNS service, record, client DNS address and routing. If ping works but web fails, inspect HTTP state, port, host record, firewall/ACL and relevant service configuration. Do not blindly toggle every service On.

**Undo:** Restore the exact original record, service On/Off state and client settings. Do not delete other DNS records or mail accounts.

---

---

### 11. Port security and switch edge protections

- [ ] Identified **true end-host ports** and required number of endpoint MACs.

**Typing (check):**

~~~text
show port-security
show port-security interface fastEthernet 0/5
show mac address-table
~~~

**Example (one-PC access port):**

~~~text
configure terminal
interface fastEthernet 0/5
switchport mode access
switchport port-security
switchport port-security maximum 1
switchport port-security violation restrict
end
~~~

**Verify:** Run **show port-security interface fastEthernet 0/5**, confirm PC connectivity and inspect violation counters.

**Caution:** A phone plus PC, shared access port, or uplink may need more than one MAC. **restrict** drops unauthorized traffic while logging/counting; **shutdown** generally error-disables the port. Never apply a single-host policy to a switch uplink.

**Undo:** Restore original port security maximum, violation mode and learned/sticky MAC behavior. Do not run **default interface** to undo one setting.

---

---

### 12. STP, EtherChannel and trunk security

- [ ] Distinguished switch uplinks from edge ports and recorded the working spanning tree.

#### 12.1 STP and BPDU Guard

**Typing (check):**

~~~text
show spanning-tree
show spanning-tree vlan 10
~~~

On a **confirmed host-facing** interface only:

~~~text
configure terminal
interface fastEthernet 0/5
spanning-tree portfast
spanning-tree bpduguard enable
end
~~~

**Check:** Verify endpoint traffic, spanning-tree topology and error-disable state. BPDU Guard may disable the port if it hears BPDUs; never apply PortFast/BPDU Guard indiscriminately to intentional switch-to-switch links. Restore old settings if wrong.

#### 12.2 EtherChannel / LACP (only if required)

**Before:** Confirm physical ports, speed/duplex, VLAN/trunk configuration and partner compatibility are consistent. Two cables alone do not mean an EtherChannel should be configured.

**Typing (example for two matching switch uplinks):**

~~~text
configure terminal
interface range fastEthernet 0/1 - 2
channel-group 1 mode active
exit
interface port-channel 1
switchport mode trunk
switchport trunk allowed vlan 10,20
end
~~~

**Check:**

~~~text
show etherchannel summary
show interfaces trunk
~~~

**Interpretation:** A bundled Port-channel must actually form with intended members. **LACP active/active** or **active/passive** can negotiate; passive/passive does not form an LACP bundle. Some Packet Tracer models have limited EtherChannel support. Restoring incorrectly applied channels requires returning each member and the port-channel to its recorded configuration.

#### 12.3 DTP and trunk security (when available)

- Set access ports explicitly as access ports rather than leaving them dynamically negotiable.
- On confirmed static trunks, consider disabling dynamic negotiation where the actual IOS supports it and the activity calls for it.
- Match native VLAN and allowed VLAN list at both ends. Do not silently prune a management VLAN.

**Verify:** **show interfaces trunk**, **show vlan brief**, **show spanning-tree** and required end-to-end tests.

---

---

### 13. IPv4 ACLs and filtering

- [ ] Wrote the required **source, destination, protocol, port and direction** in plain English.

**Key ideas:** Standard IPv4 ACLs mainly match **source address**; extended ACLs can match source, destination, protocol and TCP/UDP ports. ACL entries run **top to bottom**, first match applies, and an **implicit deny** is present if no rule permits traffic. The wildcard mask **0** bits must match while **1** bits are ignored.

**Typing (check):**

~~~text
show access-lists
show ip interface
show running-config
~~~

#### 13.1 Standard named ACL example

For a lab that **only allows subnet 192.168.10.0/24** in the specified location:

~~~text
configure terminal
ip access-list standard LAB10
permit 192.168.10.0 0.0.0.255
exit
interface gigabitEthernet 0/1
ip access-group LAB10 out
end
~~~

**Warning:** This example denies all other IPv4 sources at this interface; use only if it is precisely the task's intended policy and placement. Standard ACLs cannot express a destination TCP port.

#### 13.2 Extended named ACL example

In a lab that must **deny HTTP from 192.168.10.0/24 to host 192.168.20.10 but allow everything else**:

~~~text
configure terminal
ip access-list extended LAB_HTTP_BLOCK
deny tcp 192.168.10.0 0.0.0.255 host 192.168.20.10 eq 80
permit ip any any
exit
interface gigabitEthernet 0/0.10
ip access-group LAB_HTTP_BLOCK in
end
~~~

**What the command means:** Denies only matching TCP/80 requests; the final permit allows other IP traffic; **in** means entering this specific router interface. Port 443 is a different service and is not automatically denied.

**Verification:**

~~~text
show access-lists LAB_HTTP_BLOCK
show ip interface gigabitEthernet 0/0.10
~~~

Perform **both** a prohibited HTTP connection test and a permitted connection test from an authorized client. On some devices the hit counter is limited or not updated in Packet Tracer; functional tests matter.

**Undo (remove only the new interface binding, then restore any previous binding):**

~~~text
configure terminal
interface gigabitEthernet 0/0.10
no ip access-group LAB_HTTP_BLOCK in
end
~~~

Do not delete a named ACL that other interfaces or systems still use. ACL direction, reversed source/destination and wildcard masks are very common scoring mistakes.

---

---

### 17. Secure device management

- [ ] Checked access to console/VTY and required SSH **before** changing authentication.

**Why:** Router/switch management is a frequent security configuration skill. Modern SSH is preferred to Telnet; Cisco-supported key algorithms and the Packet Tracer emulator vary by IOS model.

**Typing (check):**

~~~text
show running-config
show ip ssh
show users
~~~

**Example practice configuration (replace device name, domain, username, password; avoid putting live secrets in shared docs):**

~~~text
configure terminal
hostname S1
ip domain-name lab.example
username cpadmin privilege 15 secret ReplaceWithUniqueAuthorizedSecret
enable secret ReplaceWithDifferentAuthorizedSecret
crypto key generate rsa
ip ssh version 2
line vty 0 4
login local
transport input ssh
end
~~~

**Important:** On some IOS releases **crypto key generate rsa** opens an interactive question about modulus (choose a supported strong key length); on others syntax differs. Do not paste the literal placeholder passwords on a real or competition device. Some simulators only support smaller RSA sizes than modern equipment. Do not change management credentials if the task provides required ones and you lack recovery access.

**Verification:**
1. Confirm the management SVI/router interface has an IP and can be reached by the authorized management host.
2. Use **show ip ssh** to confirm SSH is enabled where supported.
3. From an authorized client, open the supported SSH client (Packet Tracer PC → Desktop → Command Prompt or available SSH interface) and test authentication.
4. Confirm Telnet is disabled if the activity requires SSH-only access.
5. Re-open the console/VTY configuration in **show running-config**.

**Undo:** With console access, restore old account/VTY/SSH configuration from baseline. Do **not** remove all keys, disable all VTY lines or overwrite the enable secret blindly.

**Optional tasks only when assigned:** hostname, MOTD banner, console login policy, login blocking/throttling, password minimum length, service-password-encryption. **service password-encryption is weak obfuscation for some plaintext credentials—not strong hashing.**

---

### Research expansion: Cisco command safety and compatibility

- [ ] Confirm the switch/router model before copying an IOS block: FastEthernet and GigabitEthernet port numbering varies.
- [ ] Check interfaces and VLANs at **both ends**; one enabled trunk cannot compensate for an incorrect far-end allowed VLAN list.
- [ ] On packet-filtering activities, document source, destination, transport, port and **direction** before applying a standard/extended ACL.
- [ ] On SSH tasks, preserve console/authorized access first; don't replace provided passwords/keys with a public sample.
- [ ] Test required server/client functions and save only after validation.

**Typing (check):**

~~~text
show version
show interfaces
show ip route
show access-lists
show running-config
~~~

**Recovery:** A change made in a session is not necessarily persisted. Restore the exact baseline setting rather than resetting a whole interface or erasing startup configuration. Packet Tracer emulates an IOS subset; unsupported commands should lead you to device/task documentation, not improvisation.

## Part 5 — Advanced Routing, NAT, Wireless, IPv6 and Debugging

Dynamic routing, NAT/PAT, Wi-Fi, IPv6, simulation and full command references follow the high-priority basics.

### 8. Dynamic routing: OSPF, EIGRP and RIP

- [ ] Confirmed the activity's exact routing protocol, area/AS, networks and router IDs.

#### 8.1 OSPF (Open Shortest Path First)

**Before:** Router links need appropriate IP/subnet, routing protocol compatibility, and correct OSPF area. OSPF uses **cost**; an interface's OSPF priority is for certain DR/BDR elections, not the path metric.

**Typing (check):**

~~~text
show ip route
show ip ospf neighbor
show ip ospf interface brief
~~~

**Example (R1 advertising two /24 subnets into area 0; match exact topology):**

~~~text
enable
configure terminal
router ospf 1
network 192.168.10.0 0.0.0.255 area 0
network 192.168.12.0 0.0.0.255 area 0
end
~~~

**Verify:** Confirm expected neighbor state **FULL** when applicable, OSPF-learned routes (often **O**) in **show ip route**, and allowed host traffic. Some network types need different adjacency expectations. Avoid debugging OSPF by changing every router ID at once.

#### 8.2 EIGRP (if assigned)

**Typing (example):**

~~~text
configure terminal
router eigrp 100
network 192.168.10.0 0.0.0.255
network 192.168.12.0 0.0.0.255
no auto-summary
end
~~~

**Check:**

~~~text
show ip eigrp neighbors
show ip route eigrp
~~~

EIGRP classic behavior varies by IOS/device; default metric primarily considers minimum bandwidth and total delay. The same AS number and compatible network settings are essential for neighbors in this simplified example. Do not replace an assigned OSPF protocol with EIGRP.

#### 8.3 RIPv2 (only if assigned)

~~~text
configure terminal
router rip
version 2
no auto-summary
network 192.168.10.0
network 192.168.12.0
end
~~~

This example is **illustrative**: RIP network statements are historically classful selection statements and must be matched to the actual connected networks/implementation. Check **show ip protocols** and **show ip route rip**. RIP's usable hop count ends at **15**; 16 represents unreachable.

**Recovery for any dynamic protocol:** Restore the exact previous network/area/AS/route configuration from baseline. Do not clear all routing processes or delete an area's entire configuration without knowing the required routing design.

---

---

### 14. NAT and PAT

- [ ] Confirmed NAT is **explicitly required** and identified inside/outside interfaces.

**Why:** NAT translates IP addresses; **PAT (NAT overload)** lets multiple inside hosts share a translated address via port mappings. NAT is not a substitute for routing, and not every local network activity needs it.

**Topology example:** R1 inside = 192.168.10.0/24 on Gi0/0, outside = Gi0/1 with a valid upstream address and default route from the actual lab. **Do not assume public Internet connectivity exists in Packet Tracer.**

**Typing (check):**

~~~text
show ip interface brief
show ip route
show ip nat translations
show ip nat statistics
~~~

**Example configuration (only when inside/outside ports are already correctly addressed):**

~~~text
configure terminal
access-list 10 permit 192.168.10.0 0.0.0.255
interface gigabitEthernet 0/0
ip nat inside
exit
interface gigabitEthernet 0/1
ip nat outside
exit
ip nat inside source list 10 interface gigabitEthernet 0/1 overload
end
~~~

**Explanation:** ACL 10 **selects which inside source addresses can be translated**. It is not an inbound Internet firewall ACL. The Gi0/1 address is used as the translated source; the outside route and remote return path still must be valid.

**Verify:** Generate a permitted client connection to a configured external test host. Then run:

~~~text
show ip nat translations
show ip nat statistics
~~~

An empty translation table without matching traffic doesn't necessarily mean a bad configuration.

**Undo:** Remove only the NAT overload mapping and the interface inside/outside statements you added, restoring any previous settings. Preserve ACL 10 if it is used by other features. [Cisco NAT configuration reference](https://www.cisco.com/c/en/us/support/docs/ip/network-address-translation-nat/13772-12.html).

---

---

### 15. Wireless configuration

- [ ] Confirmed required SSID, access point/router model, client adapters, security type and IP plan.

**Clicking (Packet Tracer):**
1. Select the **Wireless Router** or **Access Point** device; use **GUI**, **Config**, or **Wireless** tab as available. These tabs differ across device models.
2. Set the required **SSID** exactly (case sensitive). On a training wireless router, configure WAN/LAN and DHCP **only if** the exercise assigns that role.
3. Choose the strongest **supported and task-required** authentication—commonly **WPA2-Personal (AES)** in simplified Packet Tracer labs. Not all Packet Tracer wireless devices support WPA3; do not assume that unavailable options can be forced.
4. Enter the specified passphrase **only if the activity supplies or authorizes one**. Do not reuse handbook example credentials.
5. On the laptop/PC, confirm it has a compatible wireless NIC/module (if relevant, check **Physical** view and follow safe power-off/module-change steps).
6. Open **Desktop → PC Wireless** or the available wireless client utility; select the exact SSID; enter its passphrase and connect.
7. Check **Desktop → IP Configuration**: DHCP/static address, mask, gateway, DNS as required.

**Verify:** Confirm association, received correct IP settings, ping gateway, and test required HTTP/DNS/application service. Intermittent connection may mean wrong authentication, incorrect channel/coverage, incompatible adapter or IP/gateway error.

**Security concepts:** WEP is obsolete/insecure. Hiding the SSID is not meaningful protection. Guest/client isolation might break required peer connectivity. Enterprise 802.1X/RADIUS requires its corresponding server and supported simulator features.

**Undo:** Restore SSID, security mode, authorized credentials and DHCP settings recorded at baseline, then reconnect the test client.

---

---

### 16. IPv6 addressing and routing

- [ ] Verified actual IPv6 prefixes, gateway and router feature support.

**Typing (router check):**

~~~text
show ipv6 interface brief
show ipv6 route
show running-config
~~~

**Example only (two-router or LAN IPv6 lab):**

~~~text
configure terminal
ipv6 unicast-routing
interface gigabitEthernet 0/0
ipv6 address 2001:DB8:10::1/64
no shutdown
end
~~~

**Verify (router):**

~~~text
show ipv6 interface brief
show ipv6 route
~~~

**Verify (PC):** Desktop → IP Configuration → IPv6 (if supported) and test an assigned IPv6 destination. Router Advertisements can support SLAAC in supported scenarios. IPv6 uses **Neighbor Discovery**, not ARP; a link-local address alone is not proof global routing works.

**Static IPv6 example (only if a remote prefix and correct next-hop are assigned):**

~~~text
configure terminal
ipv6 route 2001:DB8:20::/64 2001:DB8:12::2
end
~~~

**Undo:** Restore only the original IPv6 interface address/route and routing switch if changed. Do not disable IPv6 globally on a task that requires it.

---

---

### 18. Logging and management visibility

- [ ] Inspected time, logging, neighbors and active sessions.

**Typing (check):**

~~~text
show clock
show logging
show cdp neighbors
show lldp neighbors
show users
show running-config
~~~

**Notes:** CDP is Cisco-originated; LLDP is standards-based. They can reveal connected device identity and interface, but may be disabled; using a neighbor command is not a reason to enable the protocol unless the activity calls for it.

**Optional simple local log settings on supported IOS:**

~~~text
configure terminal
service timestamps log datetime msec
logging buffered 16384 informational
end
~~~

**Verify:** **show logging** and **show clock**, then test actual required clients. External syslog, NTP or SNMP configuration requires a correct server/service and allowed ports. SNMP v1/v2c community strings are not equivalent to SNMPv3 authentication/privacy. Never enable an externally accessible management protocol solely because a generic checklist recommends it.

---

---

### 19. Packet Tracer Simulation and activity checks

- [ ] Used Packet Tracer diagnostics appropriately without altering the grader.

**Clicking:** In the lower-right Packet Tracer UI, switch between **Realtime** and **Simulation**. In Simulation use **Edit Filters** to show only relevant protocols (ARP, ICMP, DHCP, DNS, HTTP, etc. if available). Click **Capture/Forward** or **Auto Capture/Play** to observe packet progression.

**Worked troubleshooting sequence (PC ping to gateway):**
1. Confirm PC's **IP Configuration** is correct.
2. Switch to **Simulation** and filter **ARP** and **ICMP**.
3. From PC **Command Prompt**, ping its real gateway.
4. If the first exchange is ARP and it fails, check local VLAN, port, link and gateway interface.
5. If ARP resolves but ICMP gets dropped, check target address, ACL, router status, return routes and host restrictions.
6. After solving, return to Realtime and confirm the real application task works.

**Activity completion:** If **Check Results → Assessment Items** exists and its use is permitted, compare each missed objective with the instruction before making changes. Some official activities hide check results or grade after submission. Do not assume the Completion percentage equals your official CyberPatriot competition score. Save through the activity's required method and confirm the submission/upload if the official system calls for it.

**Troubleshooting outcome:** A red envelope in Simulation isn't always proof of bad routing—an intentionally denied ACL flow should fail, while a permitted task flow should succeed.

---

---

### 21. Expanded original configuration reference

These additional configuration steps and full lab procedures are retained from the previous Cisco guide. **Sections 0–20 are the primary workflow**; if a legacy example conflicts with the activity or Cisco device, use the device-specific task requirements and verify before applying.

#### Cisco IOS basics

**IOS** (Internetwork Operating System) is the software on Cisco routers and switches. You talk to it through a command line, the **CLI** (command-line interface). In Packet Tracer, click a device and open the **CLI** tab.

##### Modes and prompts

The prompt tells you which mode you are in. Each mode allows different commands.

| Mode | Prompt | How to get there | What you can do |
|---|---|---|---|
| User EXEC | `Router>` | Where you start | A few basic `show` commands, `ping` |
| Privileged EXEC | `Router#` | `enable` | All `show` commands, save, reload, debug |
| Global configuration | `Router(config)#` | `configure terminal` | Settings for the whole device |
| Interface configuration | `Router(config-if)#` | `interface g0/0` | Settings for one port |
| Line configuration | `Router(config-line)#` | `line console 0` or `line vty 0 4` | Console and remote login settings |
| VLAN configuration | `Switch(config-vlan)#` | `vlan 10` | Name a VLAN |

```text
Router> enable
Router# configure terminal
Router(config)# interface gigabitEthernet 0/0
Router(config-if)# exit
Router(config)# end
Router#
```

- `exit` goes back **one** level. `end` (or **Ctrl+Z**) jumps straight back to privileged EXEC.
- `disable` goes from privileged EXEC back to user EXEC.
- `?` lists the commands you can type here. `show ?` lists everything that can follow `show`.
- **Tab** finishes a command word for you.
- You can **shorten** any word as long as it's unique: `conf t`, `int g0/0`, `sh ip int br`.
- `do` runs a privileged EXEC command from any config mode, so you don't have to leave: `do show ip interface brief`.
- `no` in front of a command undoes it: `no shutdown`, `no ip address`.

> [!TIP]
> Mistyped a word in privileged EXEC and the router freezes for a while "Translating..."? It thinks you typed a host name and tries to look it up. Run `no ip domain-lookup` in global config to stop that.

##### Show commands

All of these run in privileged EXEC (`Router#`), or with `do` in config mode.

| Command | What it shows |
|---|---|
| `show running-config` | The **current** configuration in RAM (memory). Lost on reboot unless you save. |
| `show startup-config` | The **saved** configuration in NVRAM (non-volatile memory). Loaded at boot. |
| `show ip interface brief` | Every interface, its IP address and whether it is up. The most useful command. |
| `show interfaces` | Detailed status and counters for each interface |
| `show vlan brief` | VLANs on a switch and which ports are in each |
| `show interfaces trunk` | Which switch ports are trunks and which VLANs they carry |
| `show ip route` | The routing table: which networks the router knows and how to reach them |
| `show version` | IOS version, uptime, model, memory and the configuration register |
| `show mac address-table` | Which MAC address the switch learned on which port |
| `show cdp neighbors` | Directly connected Cisco devices (CDP = Cisco Discovery Protocol) |
| `show port-security` | Port security settings and violation counts |
| `show ip ssh` | Whether SSH is turned on and which version |
| `show history` | The last commands you typed |

##### Reading `show ip interface brief`

| Status / Protocol | Meaning | Usual fix |
|---|---|---|
| up / up | Working | Nothing |
| administratively down / down | Someone typed `shutdown` (router ports start this way) | `no shutdown` on the interface |
| down / down | No cable, or the other end is off | Check the cable and the device on the other end |
| up / down | Cable is fine but the link doesn't work | Check the other side's settings (for example, clock rate on a serial link) |

#### Securing a device

These are the classic Packet Tracer security tasks. The examples use simple passwords. Always type exactly the passwords and names the activity instructions give you, because the grader checks for them.

##### Set the hostname

Gives the device a name. The prompt changes right away.

```text
Router(config)# hostname R1
R1(config)#
```

##### Set the enable secret

Protects privileged EXEC mode. `enable secret` stores the password as a hash.

```text
R1(config)# enable secret Cl@ss123
```

> [!WARNING]
> Don't use `enable password`. It is stored in plain text in the config. If both are set, the device uses `enable secret` and ignores `enable password`.

##### Protect the console line

The console is the physical port you plug a console cable into. `login` makes the device actually ask for the password.

```text
R1(config)# line console 0
R1(config-line)# password C0nsole!
R1(config-line)# login
R1(config-line)# exec-timeout 5 0
R1(config-line)# exit
```

`exec-timeout 5 0` logs out an idle session after 5 minutes and 0 seconds.

##### Protect the VTY lines (remote login)

VTY (virtual terminal) lines are used for remote logins with Telnet or SSH. Routers usually have lines `0 4`. Many switches have `0 15`.

```text
R1(config)# line vty 0 4
R1(config-line)# password Vty!pass
R1(config-line)# login
R1(config-line)# transport input ssh
R1(config-line)# exit
```

`transport input ssh` allows SSH only, so nobody can log in with unencrypted Telnet. To use SSH you also need the setup in the SSH section below.

##### Encrypt the plain-text passwords

Hides the console, VTY and `enable password` passwords in the config.

```text
R1(config)# service password-encryption
```

This uses weak "type 7" encryption that's easy to reverse. It only stops someone reading the password over your shoulder. That's why `enable secret` is still needed.

##### Add a login banner

Shows a warning to everyone who connects. The `#` marks the start and end of the message. Any character works as long as it isn't in the message.

```text
R1(config)# banner motd #Authorized access only. Violators will be prosecuted.#
```

MOTD means "message of the day".

##### Require a minimum password length

New passwords shorter than this are rejected.

```text
R1(config)# security passwords min-length 10
```

##### Block repeated failed logins

Blocks all login attempts for 120 seconds if there are 3 failed attempts within 60 seconds.

```text
R1(config)# login block-for 120 attempts 3 within 60
```

##### Shut down unused interfaces

A port that isn't used can't be used by an attacker. `interface range` configures many ports at once.

```text
S1(config)# interface range fastEthernet 0/10 - 24
S1(config-if-range)# shutdown
```

##### Configure SSH

SSH (Secure Shell) is encrypted remote login. It needs a hostname that isn't the default, a domain name, RSA keys and a local user.

```text
R1(config)# ip domain-name cyberpatriot.local
R1(config)# crypto key generate rsa
How many bits in the modulus [512]: 1024
R1(config)# username admin secret Adm1nPass!
R1(config)# ip ssh version 2
R1(config)# line vty 0 4
R1(config-line)# transport input ssh
R1(config-line)# login local
R1(config-line)# exit
```

- The key must be at least **768 bits** for SSH version 2. Use 1024 or 2048. You can also type it in one line: `crypto key generate rsa general-keys modulus 1024`.
- `login local` checks the username and password you created with `username`, instead of the line password.
- Optional extras: `ip ssh time-out 60` and `ip ssh authentication-retries 3`.
- Test from a PC in Packet Tracer (**Desktop > Command Prompt**):

```powershell
ssh -l admin 192.168.1.1
```

##### Save the configuration

Everything you type changes the **running-config** only. If the device reloads, unsaved changes are gone. Save to the **startup-config**:

```text
R1# copy running-config startup-config
Destination filename [startup-config]?
Building configuration...
[OK]
```

Press **Enter** at the question. `write memory` (or just `wr`) does the same thing. From config mode, use `do copy running-config startup-config`.

> [!IMPORTANT]
> Some Packet Tracer activities check the startup-config. Save on **every** device when you're done, and again after any later change.

#### Interfaces and addressing

##### Router interface

Router interfaces are **shut down by default**, so `no shutdown` is required.

```text
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# description Link to LAN 1
R1(config-if)# ip address 192.168.1.1 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# exit
```

The router's interface address is usually the **default gateway** for the PCs on that LAN.

For IPv6, turn on IPv6 routing once, then give the interface an address:

```text
R1(config)# ipv6 unicast-routing
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# ipv6 address 2001:db8:acad:1::1/64
```

> [!NOTE]
> On a serial link between two routers, the end with the **DCE** cable (data communications equipment, shown with a clock icon in Packet Tracer) needs `clock rate 64000` on its interface. Without it, the link shows up / down.

##### Switch management address (SVI)

A switch's ports don't have IP addresses. To manage a switch remotely, give it an address on an **SVI** (switched virtual interface), which is a virtual interface for a VLAN. Switch ports are **up by default**, but the SVI needs `no shutdown`.

```text
S1(config)# interface vlan 1
S1(config-if)# ip address 192.168.1.2 255.255.255.0
S1(config-if)# no shutdown
S1(config-if)# exit
S1(config)# ip default-gateway 192.168.1.1
```

`ip default-gateway` lets the switch answer devices on other networks.

##### PC addressing in Packet Tracer

1. Click the PC, open the **Desktop** tab, then **IP Configuration**.
2. Choose **Static** and type the IPv4 address, subnet mask, default gateway and DNS server. Or choose **DHCP** to get them from a DHCP server.
3. Check it in **Desktop > Command Prompt**:

```powershell
ipconfig /all
ping 192.168.1.1
```

#### VLANs and trunks

A **VLAN** (virtual LAN) splits one switch into separate networks. Devices in different VLANs can't talk to each other without a router (or a multilayer switch). VLAN 1 is the default VLAN that every port starts in.

##### Create a VLAN and put ports in it

```text
S1(config)# vlan 10
S1(config-vlan)# name Students
S1(config-vlan)# exit
S1(config)# interface fastEthernet 0/1
S1(config-if)# switchport mode access
S1(config-if)# switchport access vlan 10
S1(config-if)# exit
```

An **access** port belongs to one VLAN. Use `interface range fastEthernet 0/1 - 10` to set many ports at once.

##### Trunks

A **trunk** carries traffic for many VLANs over one link, usually between switches or from a switch to a router. It adds an **802.1Q** tag to each frame that says which VLAN it belongs to.

```text
S1(config)# interface gigabitEthernet 0/1
S1(config-if)# switchport mode trunk
S1(config-if)# switchport trunk native vlan 99
S1(config-if)# switchport trunk allowed vlan 10,20,99
```

The **native VLAN** is the one VLAN whose traffic crosses the trunk without a tag. It must match on both ends. Changing it away from VLAN 1 is a common security task.

> [!NOTE]
> On some multilayer switches (such as the 3560), you must type `switchport trunk encapsulation dot1q` before `switchport mode trunk`. On 2960 switches that command doesn't exist, because they only support 802.1Q.

##### Port security

Port security limits which devices (MAC addresses) can use a switch port. It only works on a port set to access (or trunk) mode.

```text
S1(config)# interface fastEthernet 0/1
S1(config-if)# switchport mode access
S1(config-if)# switchport port-security
S1(config-if)# switchport port-security maximum 2
S1(config-if)# switchport port-security mac-address sticky
S1(config-if)# switchport port-security violation shutdown
```

- `maximum 2` allows at most 2 MAC addresses on the port.
- `mac-address sticky` remembers the MAC addresses it learns and adds them to the running-config.
- Violation modes: **shutdown** (the default: the port turns off, "err-disabled"), **restrict** (drops the bad traffic, logs it and counts it), **protect** (drops the bad traffic silently).
- To turn a shut-down port back on, remove the bad device, then type `shutdown` and `no shutdown` on the interface.
- Check with `show port-security interface fastEthernet 0/1`.

##### Router-on-a-stick

To let VLANs talk to each other, one router port can route for several VLANs using **subinterfaces**, one per VLAN. The switch port going to the router must be a trunk.

```text
R1(config)# interface gigabitEthernet 0/0.10
R1(config-subif)# encapsulation dot1Q 10
R1(config-subif)# ip address 192.168.10.1 255.255.255.0
R1(config-subif)# exit
R1(config)# interface gigabitEthernet 0/0.20
R1(config-subif)# encapsulation dot1Q 20
R1(config-subif)# ip address 192.168.20.1 255.255.255.0
R1(config-subif)# exit
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# no shutdown
```

`encapsulation dot1Q 10` must come **before** the IP address. Each PC uses its own VLAN's subinterface address as its default gateway.

#### Routing and DHCP

##### Static and default routes

A router knows its directly connected networks automatically. For other networks, you add a **static route**: the destination network, its mask, and the next-hop address (the next router's IP).

```text
R1(config)# ip route 192.168.20.0 255.255.255.0 10.0.0.2
```

A **default route** matches every destination the router doesn't have a better route for. It's usually pointed at the internet provider.

```text
R1(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

You can also name the exit interface instead of the next hop: `ip route 192.168.20.0 255.255.255.0 serial0/0/0`.

In `show ip route`, the code letter says where each route came from: **C** = directly connected, **L** = local (the router's own address), **S** = static, **S\*** = static default route.

##### DHCP server on a router

```text
R1(config)# ip dhcp excluded-address 192.168.1.1 192.168.1.10
R1(config)# ip dhcp pool LAN1
R1(dhcp-config)# network 192.168.1.0 255.255.255.0
R1(dhcp-config)# default-router 192.168.1.1
R1(dhcp-config)# dns-server 192.168.1.5
R1(dhcp-config)# exit
```

- `excluded-address` keeps addresses (like the router's own and servers') from being handed out. Type it in global config, not inside the pool.
- `network` is the range to hand out. `default-router` is the gateway the PCs get. `dns-server` is the DNS server they get.
- Check which addresses were handed out with `show ip dhcp binding`.
- If the DHCP server is on a different network, the router interface facing the clients needs `ip helper-address` followed by the server's IP, because routers don't forward the DHCP broadcast otherwise.

#### Troubleshooting checklist

Work from the bottom layer up.

1. **Cables.** In Packet Tracer use a **copper straight-through** cable between different kinds of devices (PC to switch, switch to router). Use a **copper crossover** cable between similar devices (switch to switch, PC to PC, router to router, PC to router). The lightning-bolt cable picks the type for you. A **console** cable connects a PC's RS-232 port to a device's console port, then you use **Desktop > Terminal** on the PC.
2. **Link lights.** Green = up. Orange (amber) = the switch port is still starting up, wait a few seconds. Red = down.
3. **Interfaces up/up.** Run `show ip interface brief`. Fix any port that's administratively down with `no shutdown`.
4. **Addresses.** Check the IP address, subnet mask and default gateway on every PC. The gateway must be the router's address on the **same** network as the PC. A typo in one octet is the most common mistake.
5. **VLANs.** Check that each port is in the right VLAN with `show vlan brief`, and that trunks are trunks with `show interfaces trunk`.
6. **Routes.** Check `show ip route` on each router. Every router needs a route to every network, and the replies need a route back.
7. **Test.** Ping from a PC to its gateway, then further away. Use `tracert` to see where packets stop. On a router, the commands are `ping` and `traceroute`.
8. **Save** the config on every device, then click **Check Results**.

```powershell
ping 192.168.1.1
tracert 192.168.20.10
arp -a
```

> [!TIP]
> The first ping often loses a packet or two while ARP finds the MAC address. On a router you'll see `.!!!!`. Ping again before you start changing things.

#### Packet Tracer tips

- **Read the instructions twice** before you start. Write down every name, password and address. Spelling and capital letters must match exactly.
- The **Check Results** button in the instructions window shows your completion percentage and which assessment items are correct. Check it often.
- **Don't click Reset Activity.** It erases all your work.
- **Save the `.pka` file** often with **File > Save** (Ctrl+S), and save it where your instructions say.
- Watch the **timer** if the activity has one. Do the tasks you know first, then come back to the hard ones.
- Click the **Fast Forward Time** button at the bottom of the window to skip ahead in the simulation, for example while links come up or DHCP hands out addresses.
- Use **Tab** and short commands to type faster, and `do` to run `show` commands without leaving config mode.
- When a task doesn't score, compare your `show running-config` with the instructions line by line.

For more terms, see the [glossary](../General/All/glossary.md).

#### Complete manual lab procedures

The earlier tables remain quick references. These procedures add validation, rollback and missing routing/security topics. **All addresses, ports, VLANs and credentials here are lab examples.** Use the activity's actual topology and requirements. On Packet Tracer click the router/switch → **CLI**, press Enter, and answer `no` to the initial setup dialog only if appropriate. On real equipment use an authorized console connection and record the model/IOS version first.

##### C.1 Console baseline, modes and recovery

- [ ] Done

**What:** Record current configuration and understand which command mode you are using.

**Why it matters:** Running configuration changes are immediate. Saving persists mistakes as well as fixes.

**Before changing anything:** Read activity instructions, map ports and networks, retain console access and save a private copy of the current configuration. Packet Tracer **File → Save As** makes a separate practice copy; follow competition file rules.

**Clicking (GUI):** On a real console use the terminal settings specified for the hardware (often 9600 baud, 8 data bits, no parity, 1 stop bit, no flow control). Packet Tracer's device CLI bypasses cabling; its PC **Desktop → Terminal** uses the console cable.

**Typing (check):** Enter one command at a time, without typing a displayed `Router#` prompt:

```text
enable
show version
show running-config
show startup-config
show ip interface brief
show interfaces status
```

The last command is a switch command and may be unsupported on a router. `>` is user EXEC, `#` privileged EXEC, `(config)#` global config, `(config-if)#` interface config. `exit` goes up one level; `end` or **Ctrl+Z** returns to privileged EXEC. `?` shows context-sensitive help. A caret marks where the parser stopped, not necessarily the root cause.

**Typing (fix, only when appropriate):** Set a required hostname from privileged EXEC:

```text
configure terminal
hostname Lab-SW1
end
```

The prompt should now use Lab-SW1. To inspect without leaving configuration mode, use `do show running-config` when supported.

**Check it worked:** Run the relevant show command after each small change. Only after function checks save:

```text
copy running-config startup-config
```

Press Enter to accept the destination. Check `[OK]` and compare the relevant startup-config lines.

**Undo:** Restore the exact previous hostname/settings. `copy startup-config running-config` **merges**, rather than cleanly replacing, configuration. Supported real IOS may offer `configure replace` with a saved backup; check platform support and impact first. Reloading without saving discards **all** unsaved work and interrupts service; never use it casually or during a timed activity without understanding consequences.

**Warnings:** Do not erase startup-config, delete vlan.dat, reset the activity, or paste entire configuration files without reviewing topology and platform support. Save Packet Tracer's `.pka/.pkt` file separately from IOS's startup-config.

##### C.2 Local passwords, console/VTY and SSH

- [ ] Done

**What:** Authenticate local console and remote access and use SSH instead of cleartext Telnet.

**Why it matters:** `service password-encryption` type 7 is reversible obfuscation. It does not make line passwords equivalent to modern secrets.

**Before changing anything:** Keep console access, record line ranges from `show running-config`, choose unique strong private credentials, and use the required hostname/domain. In the commands below replace the example secrets before entering them; never deploy the printed example.

**Clicking (GUI):** Packet Tracer device → **CLI**; use a PC **Desktop → Command Prompt** for the SSH test. Real terminal clients should verify the expected device/host key where supported.

**Typing (check):** Privileged EXEC:

```text
show running-config
show ip ssh
show users
show line
```

**Typing (fix, only when appropriate):** From privileged EXEC, replacing both secret placeholders with private values:

```text
configure terminal
enable secret REPLACE_WITH_PRIVATE_ENABLE_SECRET
username labadmin privilege 15 secret REPLACE_WITH_PRIVATE_USER_SECRET
ip domain-name lab.example
line console 0
login local
exec-timeout 5 0
logging synchronous
exit
line vty 0 4
login local
transport input ssh
exec-timeout 5 0
exit
end
```

Global commands set secrets and domain; line-mode commands select local login, protocol and idle timeout (minutes/seconds). Repeat VTY settings for every actual range, such as 5–15, if present. Some devices use a single 0–15 range. Create the user **before** `login local`. Privilege 15 grants full control; only use it for an authorized administrator.

Generate a key on a device with no suitable existing SSH key:

```text
configure terminal
crypto key generate rsa modulus 2048
ip ssh version 2
end
```

Some Packet Tracer versions prompt for modulus after `crypto key generate rsa` instead. Use `?` to discover support. Avoid replacing an existing key without recording the impact on client trust. On real IOS prefer supported modern secret algorithms (for example type 8/9 where supported); do not claim every simulator supports them.

**Check it worked:** `show ip ssh` should report SSH version 2; inspect all VTY ranges. From an authorized Packet Tracer PC:

```text
ssh -l labadmin 192.168.99.2
```

Use the actual reachable management address. Confirm login and authorized privilege. A ping alone does not test SSH authentication.

**Undo:** From the console restore the recorded line login/transport/timeout and account settings. Do not enable Telnet as a permanent workaround. Deleting new RSA keys can break existing sessions/trust; review before changing them.

**Warnings:** SSH also needs a reachable interface/SVI, proper mask/gateway/routes and permitted ACLs. A password rejected by a minimum-length policy is not fixed by repeatedly entering it. Never publish real secrets in configuration screenshots.

##### C.3 Addressing, subnetting, VLANs, trunks and inter-VLAN routing

- [ ] Done

**What:** Build a consistent Layer 2 VLAN and Layer 3 gateway path.

**Why it matters:** Two PCs in different VLANs cannot communicate without routing, even if cabled to one switch. Overlapping IP subnets on different VLANs are not repaired by a trunk.

**Before changing anything:** Draw a port/VLAN/address table. Example: VLAN 10 uses 192.168.10.0/24, gateway .1; VLAN 20 uses 192.168.20.0/24, gateway .1. For /26, host bits=6, block size=64, ordinary usable hosts=62. The earlier 192.168.10.77/26 example therefore has network .64, broadcast .127, hosts .65–.126. Network and broadcast addresses are not PC addresses. /31 and /32 have special uses outside this ordinary host-count rule.

**Clicking (GUI):** Packet Tracer PC → **Desktop → IP Configuration**; enter its actual unique host address, mask and own VLAN gateway. Do not put the network or broadcast address in the host field.

**Typing (check):** Privileged switch EXEC:

```text
show vlan brief
show interfaces trunk
show interfaces gigabitEthernet 0/1 switchport
show ip interface brief
```

Use actual interfaces from the inventory, such as GigabitEthernet1/0/1 on other models.

**Typing (fix, only when appropriate):** Switch configuration example, retaining all other required VLANs on the trunk:

```text
configure terminal
vlan 10
name Students
exit
vlan 20
name Staff
exit
interface fastEthernet 0/1
switchport mode access
switchport access vlan 10
exit
interface fastEthernet 0/2
switchport mode access
switchport access vlan 20
exit
interface gigabitEthernet 0/1
switchport mode trunk
switchport trunk allowed vlan add 10,20
no shutdown
end
```

`add` preserves an existing allowed list; using a new list without `add` replaces it. Native VLANs must match at both ends. If changing native VLAN, create the chosen VLAN on both devices and record management dependencies first. On platforms requiring encapsulation selection use the supported `switchport trunk encapsulation dot1q` before mode trunk; 2960 does not accept it.

For router-on-a-stick, router privileged EXEC:

```text
configure terminal
interface gigabitEthernet 0/0
no shutdown
exit
interface gigabitEthernet 0/0.10
encapsulation dot1Q 10
ip address 192.168.10.1 255.255.255.0
exit
interface gigabitEthernet 0/0.20
encapsulation dot1Q 20
ip address 192.168.20.1 255.255.255.0
end
```

On a supported multilayer switch the alternative is `ip routing` plus gateway addresses on `interface vlan 10` and `interface vlan 20`; do not simultaneously duplicate those gateway IPs on a router. An SVI normally needs the VLAN and an active forwarding member/trunk before its protocol becomes up.

**Check it worked:** On switches check VLAN membership/trunks; on the router check `show ip interface brief` and `show ip route` for connected VLAN networks. Ping the local gateway from each PC, then an authorized host in the other VLAN. If the first ping loses packets, ARP may be resolving; repeat once. Required ACLs may intentionally prevent some cross-VLAN traffic.

**Undo:** Restore the exact original port VLAN, trunk allowed list and interface address; remove only newly created unused subinterfaces/VLANs. Do not `default interface` on a live uplink as a generic repair.

**Warnings:** Real hardware may support auto-MDI/MDIX; Packet Tracer cable behavior/model support varies. Diagnose link state before assuming a red link is an IP problem.

##### C.4 Port security, STP and BPDU Guard

- [ ] Done

**What:** Limit endpoint MAC addresses and prevent an unplanned switch on a true edge port from influencing spanning tree.

**Why it matters:** STP prevents Layer 2 loops. PortFast skips listening/learning delay for endpoints; BPDU Guard disables a PortFast edge port receiving a BPDU.

**Before changing anything:** Identify end-user ports versus switch/router uplinks, IP phones and virtualization hosts. Record existing secure/sticky MACs, expected MAC count and STP root. Never apply an endpoint template to every interface.

**Clicking (GUI):** In Packet Tracer inspect both cable endpoints and attached devices. Use the CLI for explicit port-security/STP behavior; a green link does not prove the VLAN policy is right.

**Typing (check):** Privileged EXEC:

```text
show spanning-tree vlan 10
show port-security interface fastEthernet 0/1
show interfaces status
```

**Typing (fix, only when appropriate):** For one actual endpoint port:

```text
configure terminal
interface fastEthernet 0/1
switchport mode access
switchport access vlan 10
switchport port-security
switchport port-security maximum 1
switchport port-security mac-address sticky
switchport port-security violation restrict
spanning-tree portfast
spanning-tree bpduguard enable
end
```

Choose the scenario's count and violation mode; phones/VMs may need more than one MAC. Restrict drops violating traffic and counts/logs violations; shutdown err-disables the port. Do not connect the endpoint until ready to learn its intended MAC; sticky learning can capture an attacker's address first.

**Check it worked:** `show port-security interface fastEthernet 0/1` should show the intended maximum/count/mode, and `show spanning-tree interface fastEthernet 0/1 detail` should reflect edge behavior. Test the approved endpoint. Verify the intended root bridge, forwarding and blocked redundant links; blocked links can be healthy STP behavior.

**Undo:** Restore the recorded per-port settings. If err-disabled, first remove the unexpected switch/loop or violating MAC source; then in that interface use `shutdown` followed by `no shutdown`. Clear only the stale authorized sticky MAC using the actual platform-supported command after inspection, not all switch security state.

**Warnings:** Do not enable PortFast/BPDU Guard on ordinary inter-switch trunks or disable STP to make every link forward. That can produce a broadcast storm.

##### C.5 Static routes and OSPF

- [ ] Done

**What:** Route between networks either explicitly or through the OSPF link-state routing protocol.

**Why it matters:** Every path needs a return route. OSPF `network` selects participating interfaces using a wildcard mask, not a subnet mask.

**Before changing anything:** Record the topology, next hops, area design and existing routing table. Example link: R1 10.0.0.1/30 to R2 10.0.0.2/30; each router has its own nonoverlapping LAN. Do not add routes that bypass required segmentation.

**Clicking (GUI):** In Packet Tracer inspect each router/interface and PC gateway. Use CLI for routing and Simulation mode to see where an authorized test packet stops.

**Typing (check):** Privileged EXEC:

```text
show ip route
show ip protocols
show ip ospf neighbor
show ip interface brief
```

**Typing (fix, only when appropriate):** Static-route example on R1:

```text
configure terminal
ip route 192.168.20.0 255.255.255.0 10.0.0.2
end
```

The next hop must be reachable. R2 also needs its return route. Use a default route only toward the actual intended gateway, not an arbitrary documentation address.

For an OSPF lab instead, R1 example:

```text
configure terminal
router ospf 1
router-id 1.1.1.1
passive-interface default
no passive-interface gigabitEthernet 0/1
network 10.0.0.0 0.0.0.3 area 0
network 192.168.10.0 0.0.0.255 area 0
end
```

Process ID 1 is locally significant; router ID must be unique. Replace Gi0/1 with the actual router-to-router link. Passive-interface advertises the LAN but avoids forming neighbors with endpoint devices. Configure R2 consistently with a different router ID and its own LAN. Do not run `clear ip ospf process` merely to refresh a lab; it interrupts adjacencies.

**Check it worked:** On both routers inspect neighbors and routes. Neighbors normally reach FULL on a simple two-router link; some multiaccess non-DR pairs can legitimately remain 2WAY. Remote OSPF routes show `O`. Ping an authorized remote LAN host and trace the path; check return routing, ACLs and host gateways.

**Undo:** For the example static route, global configuration `no ip route 192.168.20.0 255.255.255.0 10.0.0.2` removes only that route. For OSPF restore the specific changed network/passive setting. Do not `no router ospf 1` on an existing production/lab process with other required networks.

**Warnings:** Neighbor failures often come from area, mask, timer, authentication, MTU or passive-interface mismatch. Authentication syntax varies across IOS/Packet Tracer; follow platform guidance and activity requirements rather than pasting an unsupported modern command.

##### C.6 Extended ACLs and management access

- [ ] Done

**What:** Apply ordered Layer 3/4 rules at the intended interface/direction or VTY access path.

**Why it matters:** ACLs have an implicit deny at the end, and the first match wins. A rule can block your management session as soon as it is attached.

**Before changing anything:** Keep a console, record the existing ACL and binding, and list all traffic that must remain. Interface ACLs normally are stateless; do not assume automatic reply allowances like a host stateful firewall.

**Clicking (GUI):** In Packet Tracer use CLI and test from separate authorized/unauthorized lab PCs; Simulation mode can help identify the drop location.

**Typing (check):** Privileged EXEC:

```text
show access-lists
show ip interface gigabitEthernet 0/0
show running-config
```

**Typing (fix, only when appropriate):** Example policy permits HTTPS from Students to one server and denies other Students traffic to Staff while preserving unrelated routed traffic. Adapt the entire policy to the actual requirements:

```text
configure terminal
ip access-list extended STUDENT-IN
10 permit tcp 192.168.10.0 0.0.0.255 host 192.168.20.10 eq 443
20 deny ip 192.168.10.0 0.0.0.255 192.168.20.0 0.0.0.255
30 permit ip any any
exit
interface gigabitEthernet 0/0.10
ip access-group STUDENT-IN in
end
```

The example is attached where Students traffic **enters** the router. Wildcard `0.0.0.255` matches a /24. The last permit preserves other flows for this teaching example; omit or narrow it only after explicitly defining all required paths. Do not replace an existing required ACL without preserving its rules.

For VTY source restriction, use a standard ACL separately, after confirming the management subnet:

```text
configure terminal
ip access-list standard MGMT-SOURCES
permit 192.168.99.0 0.0.0.255
exit
line vty 0 4
access-class MGMT-SOURCES in
end
```

Apply to every actual VTY range as needed. IPv6 requires separate supported IPv6 controls; an IPv4 ACL does not cover it.

**Check it worked:** Run `show access-lists` and confirm relevant counters increase during authorized lab tests. Verify the correct interface/direction in `show ip interface`. Test HTTPS, intended denials and a **new** management SSH session. Packet Tracer may not implement every counter/logging detail.

**Undo:** From the console, remove only the binding you added with `no ip access-group STUDENT-IN in` in the same interface, or `no access-class MGMT-SOURCES in` in the same VTY range. Restore the previous binding immediately if one existed. Remove unused ACL definitions only after checking references.

**Warnings:** An `established` TCP keyword is not a complete stateful firewall. Do not paste `deny ip any any` as the first rule, assume an ACL acts before it is attached, or test a security policy solely with ping.

##### C.7 DHCP, logging and final troubleshooting

- [ ] Done

**What:** Verify address allocation, event visibility and saved device state.

**Why it matters:** DHCP needs correct excluded ranges/gateway/DNS, and a server on a different network needs a relay. Logging without accurate time is hard to correlate.

**Before changing anything:** Record DHCP bindings/pools, required relay addresses, logging destinations and time configuration. Do not clear live leases or logs as a first troubleshooting step.

**Clicking (GUI):** Packet Tracer PC → **Desktop → IP Configuration → DHCP** on a noncritical test client. Use **Simulation** to inspect Discover/Offer/Request/Ack if allocation fails. On real hardware use the approved monitoring/logging system.

**Typing (check):** Privileged EXEC:

```text
show ip dhcp pool
show ip dhcp binding
show ip dhcp conflict
show logging
show clock
show running-config
```

**Typing (fix, only when appropriate):** Use the DHCP pool example earlier with the real subnet, exclusions, gateway and DNS. Where the DHCP server is remote, on the **client-facing** router interface:

```text
configure terminal
interface gigabitEthernet 0/0.10
ip helper-address 192.168.20.5
end
```

Use the actual server; a helper may relay other UDP broadcasts depending on IOS, so inspect platform behavior. Do not put the helper arbitrarily on every link.

A basic local logging example on supported IOS:

```text
configure terminal
service timestamps log datetime msec
logging buffered 16384 informational
end
```

Configure approved NTP/syslog destinations only when supplied; never point lab devices at an unapproved real service. Some Packet Tracer models implement only a subset.

**Check it worked:** A test client receives an address in the intended pool, correct mask/gateway/DNS and resolves/reaches required destinations. Inspect DHCP bindings and logging. Work through layers: link → interface up/up → VLAN/trunk → host address/gateway → route/return route → ACL → application. Save running-config and the Packet Tracer file after successful tests.

**Undo:** Restore the recorded specific pool option/helper/log setting. Do not clear all leases, erase startup-config or Reset Activity to undo one command.

**Warnings:** A failed unsupported command may be a simulator limitation; use `?`, `show version` and the activity instructions. Do not claim a real IOS feature was tested merely because a simplified Packet Tracer equivalent worked.

---

### 22. Consolidated troubleshooting reference

The former separate switching, VLAN, routing, ACL and troubleshooting document is reproduced here as a detailed **secondary reference**. The examples below are independent scenarios, not instructions to run every command in one topology.


Use alongside the [main Cisco guide](packet-tracer.md). These are **manual examples**, not scripts. Commands vary by model and simulator image. Preserve the Packet Tracer activity file using **File → Save As** when allowed; obey the specific activity requirements.

#### 1. Begin with a baseline

- [ ] Recorded interfaces, version, routes, VLANs and configuration.

**Clicking:** Select router or switch → **CLI**. Press Enter to reach the prompt. Enter privileged EXEC mode.

**Typing (check):**

~~~text
enable
show version
show running-config
show ip interface brief
~~~

**Why:** You need original settings before making a reversible change. Never erase the entire startup configuration to fix one port.

#### 2. PC cannot reach its gateway: check access VLAN and trunk

- [ ] Checked PC IP/mask/gateway and correct switch port VLAN.

**Clicking:** PC → **Desktop → IP Configuration**. Record IP address, mask, gateway. Switch → **CLI**.

**Typing (check):**

~~~text
show vlan brief
show interfaces trunk
show spanning-tree
show interfaces status
~~~

Some Packet Tracer platforms do not support every show command; use show interfaces and show running-config as alternatives.

**Example modification — ONLY if the task requires VLAN 20 on FastEthernet 0/5:**

~~~text
enable
configure terminal
vlan 20
 name STUDENTS
exit
interface fastEthernet 0/5
 switchport mode access
 switchport access vlan 20
 no shutdown
end
~~~

**Verify:**

~~~text
show vlan brief
show interfaces fastEthernet 0/5 switchport
~~~

Test the correct gateway from PC → **Desktop → Command Prompt** using ping. An access port must not be reconfigured as a trunk. **Undo:** Restore the original interface VLAN and mode recorded in your baseline.

#### 3. Trunk missing a VLAN

- [ ] Confirmed exact VLANs required on both ends before changing allowed lists.

~~~text
show interfaces trunk
show spanning-tree vlan 20
~~~

**Example modification — only for an approved trunk carrying VLANs 10, 20, and 99:**

~~~text
enable
configure terminal
interface gigabitEthernet 0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,99
 no shutdown
end
~~~

**Caution:** The allowed list is restrictive; it can remove access for VLANs not listed. Check both ends and restore the previous list if clients lose connectivity. Packet Tracer support varies.

#### 4. Inter-VLAN routing via router-on-a-stick

- [ ] Checked router's physical interface, subinterfaces, switch trunk, and PC gateway.

~~~text
show ip interface brief
show ip route
show running-config
~~~

**Example only — Router subinterface for VLAN 20:**

~~~text
enable
configure terminal
interface gigabitEthernet 0/0
 no shutdown
exit
interface gigabitEthernet 0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0
end
~~~

The switch uplink must permit VLAN 20 and the client gateway must match the router subinterface. **Verify** with show ip interface brief and ping the real test host. **Undo:** Restore the original subinterface encapsulation and address; do not remove the physical interface's other legitimate subinterfaces.

#### 5. Port security: identify a legitimate edge port first

- [ ] Recorded existing port-security state and authorized MAC count.

~~~text
show port-security
show port-security interface fastEthernet 0/5
show mac address-table interface fastEthernet 0/5
~~~

**Example — one PC on a confirmed access port:**

~~~text
enable
configure terminal
interface fastEthernet 0/5
 switchport mode access
 switchport port-security
 switchport port-security maximum 1
 switchport port-security violation restrict
end
~~~

**Verify:**

~~~text
show port-security interface fastEthernet 0/5
show interfaces fastEthernet 0/5
~~~

Maximum 1 is inappropriate for some phone-plus-PC ports. Violation shutdown can place a port into err-disabled state. **Undo:** Restore only the previous port-security commands and MAC behavior, not an entire default interface.

#### 6. STP / BPDU Guard: edge ports are not uplinks

- [ ] Identified the physical topology and switch-to-switch ports.

~~~text
show spanning-tree
show spanning-tree vlan 20
~~~

**Example — only for a verified end-host access interface:**

~~~text
enable
configure terminal
interface fastEthernet 0/5
 spanning-tree portfast
 spanning-tree bpduguard enable
end
~~~

**Why:** PortFast avoids standard convergence delays on edge ports; BPDU Guard protects against unexpected BPDUs. Applying this to an inter-switch port can disable a required connection. **Verify:** Test end-host connectivity, STP state and err-disabled status. **Undo:** Revert the two settings if applied to the wrong port.

#### 7. Extended ACLs: direction and wildcard mask

- [ ] Listed required allowed/blocked flows before applying an ACL.

~~~text
show access-lists
show ip interface
show ip route
~~~

**Illustrative policy only:** Block TCP HTTP from subnet 192.168.10.0/24 to server 192.168.20.10 while permitting other IP traffic. Replace addressing and policy based on the activity.

~~~text
enable
configure terminal
ip access-list extended LAB_HTTP_FILTER
 deny tcp 192.168.10.0 0.0.0.255 host 192.168.20.10 eq 80
 permit ip any any
exit
interface gigabitEthernet 0/0.10
 ip access-group LAB_HTTP_FILTER in
end
~~~

The 0.0.0.255 value is an ACL wildcard mask. The in direction is relative to the interface. An ACL has an implicit deny after the last statement. **Verify:**

~~~text
show ip interface gigabitEthernet 0/0.10
show access-lists LAB_HTTP_FILTER
~~~

Test both a prohibited flow and a **required permitted** flow. Counters may be limited in Packet Tracer. **Undo:** Remove only the new interface binding and restore any former ACL:

~~~text
enable
configure terminal
interface gigabitEthernet 0/0.10
 no ip access-group LAB_HTTP_FILTER in
end
~~~

Do not delete a shared ACL before checking other interface bindings.

#### 8. DHCP, DHCP snooping and DAI

- [ ] Checked service location, DHCP pool, relay address and trust boundaries.

~~~text
show ip dhcp pool
show ip dhcp binding
show ip dhcp snooping
show ip dhcp snooping binding
show ip arp inspection
~~~

Not all commands work on every Packet Tracer device.

**Troubleshooting sequence:**

1. PC → **Desktop → IP Configuration → DHCP**. Record any address assigned.
2. Check the access VLAN and trunk.
3. Check router gateway / subinterface.
4. Check pool subnet, excluded addresses and available leases.
5. If DHCP server is elsewhere, inspect any helper address on the **client-facing routed interface**.
6. For DHCP snooping, trust only the legitimate server-facing path.
7. For Dynamic ARP Inspection, confirm DHCP snooping bindings or static ARP ACLs exist before enabling it.

**Why:** Incorrect trust placement can block legitimate DHCP and ARP, while over-trusting edge ports weakens protection. Test real clients before and after a configuration change.

#### 9. SSH management and save procedure

- [ ] Confirmed approved access, remote management authentication and final connections.

~~~text
show ip ssh
show running-config
show startup-config
show logging
~~~

See [main Cisco guide: configure SSH](packet-tracer.md#17-secure-device-management) for complete hostname, RSA key, VTY/local authentication and SSH transport steps. Use the actual authorized credentials and device capabilities.

After successful verification, save:

~~~text
copy running-config startup-config
~~~

**Do not save a broken state just because commands were accepted.**

#### Fast diagnosis table

| Symptom | Check first | Check next |
|---|---|---|
| Link is down | Cable and shutdown status | Connected interface/device |
| PCs in one VLAN cannot talk | PC IP/mask and access VLAN | Trunks, port security, STP |
| PC cannot ping gateway | VLAN and router subinterface | ACL and host gateway |
| Inter-VLAN communication fails | Routes and gateway | ACL direction and return path |
| DHCP fails | VLAN, pool and relay | Snooping trust, scope exhaustion |
| SSH fails | Management IP reachability | Keys, VTY lines, users and transport |

#### References

- [Cisco Support: Switches](https://www.cisco.com/c/en/us/support/switches/index.html)
- [Cisco Support: Routers](https://www.cisco.com/c/en/us/support/routers/index.html)
- [Cisco Networking Academy / Packet Tracer](https://www.netacad.com/)
- [CyberPatriot Toolkit](https://github.com/Ripper1004/CyberPatriot-Toolkit/tree/main/docs)
- [CyberPatriot community checklists](https://github.com/chessischess/cyberpatriot-checklist)

**All examples are defensive lab instructions. Match every command to the activity requirements, interface names, supported IOS version and required connectivity.**

## Part 6 — Final Verification and Sources

Troubleshoot from physical/link to routing and application before saving and submitting.

### 20. Symptom-first troubleshooting

- [ ] Diagnosed from lower layers upward; fixed one cause at a time.

| Symptom | First investigation | Then check |
|---|---|---|
| Link red/down | Correct physical port/cable; **show ip interface brief** | Both ends shutdown, model/modules |
| PC cannot ping gateway | PC IP/mask/gateway; access VLAN | Trunk, router subinterface, port security, STP |
| Same-VLAN peers cannot ping | Ports in same VLAN | Host IP/mask, security, cabling |
| Two VLANs cannot reach each other | Router-on-stick/L3 SVI gateway | Trunk VLAN list, ACL, routes |
| Network behind R2 unreachable | R1 and R2 routing tables | Next-hop, return route, mask, ACL |
| DHCP failure | Server/pool, client VLAN, excluded addresses | Relay/helper, DHCP snooping/trust |
| DNS fails but IP works | DNS IP, record, server On | Routing, UDP/TCP 53, ACL |
| HTTP fails but ping works | HTTP server state, target URL | DNS, server address, ACL/port |
| SSH fails | IP route and management interface | Username/secret, RSA key, SSH version, VTY |
| Port error-disabled | **show port-security**; STP/BPDU logs | MAC limit, unexpected BPDU, physical topology |
| NAT never translates | Inside/outside, ACL match | Outside address, return/default route, actual traffic |
| Wireless client gets no connection | SSID and security/passphrase | Adapter, signal, DHCP, gateway |

**Before final submission:**
- [ ] Every explicitly required router/switch/PC/server interface has correct **status, address and subnet**.
- [ ] VLAN membership, trunks and management VLAN are checked from both ends.
- [ ] Routes **and return routes** are present; dynamic neighbors behave as expected.
- [ ] DHCP leases and DNS/HTTP/FTP/mail reachability are tested if required.
- [ ] Each ACL is tested with a **denied** and an **allowed** flow.
- [ ] Switch port-security, STP, EtherChannel and wireless settings meet the actual exercise.
- [ ] Remote management works as required without accidentally exposing Telnet/weak access.
- [ ] Changes are saved with **copy running-config startup-config** after verifying; activity file saved/submitted as instructed.
- [ ] No unsupported commands were guessed, no assessment metadata modified, no unrelated settings deleted.

**Save only after successful verification:**

~~~text
enable
copy running-config startup-config
~~~

Some tasks grade running configuration directly; use the actual submission instructions. The CLI save operation does **not** replace saving the Packet Tracer activity file.

---

---

### 23. Sources and scope

**Official/current sources**
- [CyberPatriot XIX competition challenge schedule and maximum point values](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round)
- [CyberPatriot official Cisco quiz and Packet Tracer training description](https://www.uscyberpatriot.org/competition/training-materials)
- [Cisco NetAcad: Getting Started with Packet Tracer](https://www.netacad.com/courses/getting-started-cisco-packet-tracer/1000)
- [Cisco NetAcad: Exploring Networking with Packet Tracer](https://www.netacad.com/courses/exploring-networking-cisco-packet-tracer?courseLang=en-US)
- [Cisco: Configure SSH on Routers](https://www.cisco.com/c/en/us/support/docs/security-vpn/secure-shell-ssh/4145-ssh.html)
- [Cisco: Configure NAT and PAT](https://www.cisco.com/c/en/us/support/docs/ip/network-address-translation-nat/13772-12.html)
- [Cisco: Access Control Lists](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/security/acls/acls-configuration-guide/access-control-lists.html)
- [Cisco: PortFast and BPDU Guard](https://www.cisco.com/c/en/us/support/docs/lan-switching/spanning-tree-protocol/10586-65.html)

**Independent educational references**
- [Cyber4Youth Cisco learning track](https://cyber4youth.com/learn/cyberpatriot)
- [Ripper1004 CyberPatriot Toolkit](https://github.com/Ripper1004/CyberPatriot-Toolkit/tree/main/docs)
- [CCA CyberPatriot resources](https://sites.google.com/view/cca-cyberpatriot/program-info/cyberpatriot)

**Limitations:** Cisco device/IOS/Packet Tracer versions differ; a correct IOS concept may have a different supported syntax or be absent on a simulator device. The point totals above are **published maximums for the challenge**, not scores earned by these procedures, and no example guarantees any individual grading item. We have **not** executed or tested these commands against an actual competition PKA. Only use authorized training and follow current competition rules.

### Final Packet Tracer handoff checklist

- [ ] Every task-required link and router interface state verified.
- [ ] Client IP/mask, gateway, DNS, VLAN, trunk, subinterface and route checked.
- [ ] Required application-level transactions (web, DNS, DHCP, FTP, email, SSH) tested.
- [ ] ACLs tested with a permitted and prohibited flow.
- [ ] No authorized client was accidentally blocked by port-security, STP or trunk changes.
- [ ] Saved working IOS running configuration and the **correct activity file** following instructions.
- [ ] No activity grading assets, password placeholders or unrelated configurations modified.
- [ ] Any issue not resolved is documented specifically, not hidden by broad resets.
