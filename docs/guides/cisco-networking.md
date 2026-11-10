# Cisco networking and Packet Tracer

Most CyberPatriot rounds have a Cisco Networking Challenge next to the operating system images. It has two parts: a multiple-choice quiz on networking theory and a hands-on activity in Cisco Packet Tracer, where you set up routers, switches and PCs in a simulator. This page covers the basics you need for both, plus a cheat sheet of the Cisco commands that come up again and again.

## What the Cisco part of a round is

| Part | What you do | What helps most |
|---|---|---|
| **Quiz** | Answer multiple-choice questions about networking | Knowing the ideas: layers, addresses, ports, subnetting, how devices work |
| **Packet Tracer activity** | Open a `.pka` file and configure the devices it describes | Typing Cisco commands quickly and correctly, and checking your work |

The challenge is based on material from the **Cisco Networking Academy** (NetAcad), Cisco's free online training program. The topics change from round to round. Check what your round covers (your coach gets this information) and study those topics first.

### How to prepare

1. Make a free account at **netacad.com**. Packet Tracer is a free download for NetAcad users.
2. Build small networks yourself: two PCs, a switch and a router is enough to practice almost everything on this page.
3. Practice the **security tasks** (passwords, SSH, banners) until you can type them without looking.
4. Do subnetting problems by hand until they feel easy. They show up in quizzes all the time.

> [!TIP]
> Skills beat memorizing. If you understand *why* a router needs a default gateway or *why* a port is down, you can answer questions you have never seen before.

## Networking basics

### The OSI and TCP/IP models

A **model** splits networking into layers. Each layer does one job and hands its work to the next layer. The **OSI** model (Open Systems Interconnection) has 7 layers. The **TCP/IP** model, which the internet really uses, has 4.

| # | OSI layer | What it does | Examples | Data unit (PDU) | TCP/IP layer |
|---|---|---|---|---|---|
| 7 | Application | The network services programs use | HTTP, DNS, FTP, SSH, DHCP | Data | Application |
| 6 | Presentation | Formats, compresses and encrypts data | JPEG, ASCII, encryption | Data | Application |
| 5 | Session | Starts, manages and ends conversations | Sessions between apps | Data | Application |
| 4 | Transport | Splits data up, uses port numbers, can resend lost data | TCP, UDP | Segment (TCP) / datagram (UDP) | Transport |
| 3 | Network | Logical addresses and routing between networks | IPv4, IPv6, ICMP, routers | Packet | Internet |
| 2 | Data Link | Physical (MAC) addresses, delivery on the local network | Ethernet, Wi-Fi frames, switches | Frame | Network Access |
| 1 | Physical | Bits as electrical, light or radio signals | Cables, connectors, hubs | Bits | Network Access |

**PDU** means Protocol Data Unit: the name for a chunk of data at each layer. To remember the OSI layers from 1 to 7: **P**lease **D**o **N**ot **T**hrow **S**ausage **P**izza **A**way.

> [!NOTE]
> Some books call the bottom TCP/IP layer "Link" instead of "Network Access". They mean the same thing.

### Network devices

| Device | Layer | What it does |
|---|---|---|
| **Hub** | 1 | Repeats every signal out every port. Old and slow, because everyone shares the bandwidth. |
| **Switch** | 2 | Connects devices in the same network. Learns MAC addresses and sends each frame only out the right port. |
| **Router** | 3 | Connects *different* networks and picks the path for each packet using IP addresses. |
| **Access point (AP)** | 2 | Lets wireless devices join a wired network. |
| **Firewall** | 3 and up | Allows or blocks traffic based on rules. |

### Addresses and traffic types

- A **MAC address** (Media Access Control) is the physical address burned into a network card. It is 48 bits, written as 12 hexadecimal digits, like `00:1A:2B:3C:4D:5E`. Switches use it. It only matters on the local network.
- An **IP address** (Internet Protocol) is the logical address you set in software, like `192.168.1.10`. Routers use it to move packets between networks.
- **Unicast** goes to one device. **Broadcast** goes to every device on the local network (the MAC address `FF:FF:FF:FF:FF:FF`). **Multicast** goes to a group of devices that asked for it.
- Routers do **not** forward broadcasts. Each router interface is the edge of a **broadcast domain**.

### TCP vs UDP

| | TCP (Transmission Control Protocol) | UDP (User Datagram Protocol) |
|---|---|---|
| Connection | Sets up a connection first (three-way handshake: SYN, SYN-ACK, ACK) | No setup, just sends |
| Reliable? | Yes. Numbers the data, confirms delivery, resends lost pieces | No. Lost data stays lost |
| Speed | Slower, more overhead | Faster, less overhead |
| Used for | Web pages, email, file transfer, SSH | DNS lookups, DHCP, video calls, streaming, online games |

### The protocols that make a network work

- **DHCP** (Dynamic Host Configuration Protocol) gives a device its IP address, subnet mask, default gateway and DNS server automatically. The four steps are **DORA**: **D**iscover (the client broadcasts "is there a DHCP server?"), **O**ffer (a server offers an address), **R**equest (the client asks for that address), **A**cknowledge (the server confirms).
- **DNS** (Domain Name System) turns names like `www.example.com` into IP addresses.
- **ARP** (Address Resolution Protocol) finds the MAC address that goes with an IPv4 address on the local network. The question is a broadcast ("who has 192.168.1.1?"), the answer is unicast.
- **NAT** (Network Address Translation) lets many devices with private addresses share one public address on the internet. The router rewrites the addresses as traffic passes through.
- **ICMP** (Internet Control Message Protocol) carries error and test messages. `ping` and `traceroute` use it.
- The **default gateway** is the router address a device sends traffic to when the destination is on a *different* network. If it's wrong or missing, a PC can reach its own network but nothing beyond it.

## IPv4 addressing and subnetting

An IPv4 address is **32 bits**, written as four numbers (octets) from 0 to 255: `192.168.1.10`. The **subnet mask** says which part is the **network** and which part is the **host** (the device).

### Binary in one minute

Each octet is 8 bits. The bit values, left to right, are:

| 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |
|---|---|---|---|---|---|---|---|

Add up the values where the bit is 1. For example, `11000000` = 128 + 64 = **192**, and `10101100` = 128 + 32 + 8 + 4 = **172**.

### Classes (historical) and special ranges

Classes are an old system that modern networks no longer use, but quizzes still ask about them.

| Class | First octet | Default mask | Use |
|---|---|---|---|
| A | 1 to 126 | 255.0.0.0 (/8) | Very large networks |
| B | 128 to 191 | 255.255.0.0 (/16) | Medium networks |
| C | 192 to 223 | 255.255.255.0 (/24) | Small networks |
| D | 224 to 239 | none | Multicast |
| E | 240 to 255 | none | Experimental |

| Range | Meaning |
|---|---|
| `10.0.0.0/8` (10.0.0.0 to 10.255.255.255) | Private |
| `172.16.0.0/12` (172.16.0.0 to 172.31.255.255) | Private |
| `192.168.0.0/16` (192.168.0.0 to 192.168.255.255) | Private |
| `127.0.0.0/8` | Loopback (the device itself, usually `127.0.0.1`) |
| `169.254.0.0/16` | APIPA (Automatic Private IP Addressing): a PC gives itself one when it can't reach a DHCP server |

**Private** addresses are free to use inside any network but are not routed on the internet. NAT translates them to a public address.

### CIDR and subnet masks

**CIDR** (Classless Inter-Domain Routing) notation writes the mask as a slash and the number of network bits: `/24` means the first 24 bits are network bits, so the mask is `255.255.255.0`. Usable hosts = 2^(host bits) − 2, because the first address is the network address and the last is the broadcast address.

| CIDR | Subnet mask | Usable hosts | Block size (octet it changes in) |
|---|---|---|---|
| /8 | 255.0.0.0 | 16,777,214 | 1 (octet 1) |
| /9 | 255.128.0.0 | 8,388,606 | 128 (octet 2) |
| /10 | 255.192.0.0 | 4,194,302 | 64 (octet 2) |
| /11 | 255.224.0.0 | 2,097,150 | 32 (octet 2) |
| /12 | 255.240.0.0 | 1,048,574 | 16 (octet 2) |
| /13 | 255.248.0.0 | 524,286 | 8 (octet 2) |
| /14 | 255.252.0.0 | 262,142 | 4 (octet 2) |
| /15 | 255.254.0.0 | 131,070 | 2 (octet 2) |
| /16 | 255.255.0.0 | 65,534 | 1 (octet 2) |
| /17 | 255.255.128.0 | 32,766 | 128 (octet 3) |
| /18 | 255.255.192.0 | 16,382 | 64 (octet 3) |
| /19 | 255.255.224.0 | 8,190 | 32 (octet 3) |
| /20 | 255.255.240.0 | 4,094 | 16 (octet 3) |
| /21 | 255.255.248.0 | 2,046 | 8 (octet 3) |
| /22 | 255.255.252.0 | 1,022 | 4 (octet 3) |
| /23 | 255.255.254.0 | 510 | 2 (octet 3) |
| /24 | 255.255.255.0 | 254 | 1 (octet 3) |
| /25 | 255.255.255.128 | 126 | 128 (octet 4) |
| /26 | 255.255.255.192 | 62 | 64 (octet 4) |
| /27 | 255.255.255.224 | 30 | 32 (octet 4) |
| /28 | 255.255.255.240 | 14 | 16 (octet 4) |
| /29 | 255.255.255.248 | 6 | 8 (octet 4) |
| /30 | 255.255.255.252 | 2 | 4 (octet 4) |

> [!TIP]
> Memorize the last-octet mask values: **128, 192, 224, 240, 248, 252, 254, 255**. Block size is always **256 minus the mask value** in the octet that isn't 255 or 0.

### Step-by-step: find the network, broadcast and hosts

1. Find the **interesting octet**: the one where the mask is not 255 and not 0.
2. **Block size** = 256 − the mask value in that octet.
3. List the multiples of the block size (0, block, 2 × block, …). The **network address** is the biggest multiple that is less than or equal to the IP's value in that octet. Octets after it become 0.
4. The **broadcast address** is the next network address minus 1. Octets after the interesting one become 255.
5. **First host** = network address + 1. **Last host** = broadcast address − 1.
6. **Number of hosts** = 2^(32 − prefix) − 2.

### Worked example 1: 192.168.10.77/26

- /26 = mask `255.255.255.192`. The interesting octet is the 4th.
- Block size = 256 − 192 = **64**. Networks: .0, .64, .128, .192.
- 77 falls between 64 and 128, so the network is **192.168.10.64**.
- Broadcast = 128 − 1 = **192.168.10.127**.
- Hosts: **192.168.10.65** to **192.168.10.126**. That is 2^6 − 2 = **62** hosts.

### Worked example 2: 172.16.45.200/20

- /20 = mask `255.255.240.0`. The interesting octet is the 3rd.
- Block size = 256 − 240 = **16**. Networks in the 3rd octet: 0, 16, 32, 48, …
- 45 falls between 32 and 48, so the network is **172.16.32.0**.
- Broadcast: the next network is 172.16.48.0, so the broadcast is **172.16.47.255**.
- Hosts: **172.16.32.1** to **172.16.47.254**. That is 2^12 − 2 = **4,094** hosts.

### Worked example 3: 10.1.1.5/30

- /30 = mask `255.255.255.252`. Block size = **4**. Networks: .0, .4, .8, …
- Network **10.1.1.4**, broadcast **10.1.1.7**, hosts **10.1.1.5** and **10.1.1.6** (2 hosts).
- A /30 is common on a link between two routers, because the link needs exactly two addresses.

### Picking a mask for a number of hosts

Find the smallest number of host bits where 2^(host bits) − 2 is at least the number of hosts you need. Example: you need 50 hosts. 2^5 − 2 = 30 is too small, 2^6 − 2 = 62 is enough. That's 6 host bits, so the prefix is 32 − 6 = **/26**.

### IPv6 basics

- An IPv6 address is **128 bits**, written as 8 groups of 4 hexadecimal digits separated by colons: `2001:0db8:0000:0000:0000:ff00:0042:8329`.
- **Shortening rule 1:** drop leading zeros in any group (`0db8` becomes `db8`, `0042` becomes `42`).
- **Shortening rule 2:** replace **one** run of consecutive all-zero groups with `::`. You may only use `::` once in an address.
- So the address above becomes `2001:db8::ff00:42:8329`.

| Address | Meaning |
|---|---|
| `::1` | Loopback (like 127.0.0.1) |
| `fe80::/10` | Link-local: works only on the local link. Every IPv6 interface makes one automatically. |
| `2000::/3` | Global unicast: public addresses, routed on the internet |
| `fc00::/7` | Unique local: private addresses, like 10.x.x.x in IPv4 |

A normal IPv6 network (LAN) uses a **/64** prefix. IPv6 has no broadcast. It uses multicast instead.

## Common ports

A **port** number tells the receiving computer which program the traffic is for. Ports 0 to 1023 are the "well-known" ports.

| Port | Protocol | TCP / UDP | What it is |
|---|---|---|---|
| 20, 21 | FTP (File Transfer Protocol) | TCP | File transfer. 21 = commands, 20 = data. Not encrypted. |
| 22 | SSH (Secure Shell) | TCP | Encrypted remote login. Also SFTP and SCP. |
| 23 | Telnet | TCP | Remote login with **no** encryption. Replace with SSH. |
| 25 | SMTP (Simple Mail Transfer Protocol) | TCP | Sending email between servers |
| 53 | DNS (Domain Name System) | UDP and TCP | Name lookups (UDP); big replies and zone transfers (TCP) |
| 67, 68 | DHCP (Dynamic Host Configuration Protocol) | UDP | 67 = server, 68 = client |
| 69 | TFTP (Trivial File Transfer Protocol) | UDP | Simple file transfer, often used to back up Cisco configs |
| 80 | HTTP (Hypertext Transfer Protocol) | TCP | Web pages, not encrypted |
| 110 | POP3 (Post Office Protocol 3) | TCP | Downloading email |
| 123 | NTP (Network Time Protocol) | UDP | Clock sync |
| 143 | IMAP (Internet Message Access Protocol) | TCP | Reading email on the server |
| 161, 162 | SNMP (Simple Network Management Protocol) | UDP | Device monitoring. 162 = traps (alerts) |
| 389 | LDAP (Lightweight Directory Access Protocol) | TCP (also UDP) | Directory lookups, like Active Directory |
| 443 | HTTPS (HTTP Secure) | TCP | Encrypted web pages |
| 445 | SMB (Server Message Block) | TCP | Windows file sharing |
| 514 | Syslog | UDP | Sending log messages to a log server |
| 636 | LDAPS (LDAP over TLS) | TCP | Encrypted LDAP |
| 3306 | MySQL | TCP | MySQL database |
| 3389 | RDP (Remote Desktop Protocol) | TCP (also UDP) | Windows Remote Desktop |

## Cisco IOS basics

**IOS** (Internetwork Operating System) is the software on Cisco routers and switches. You talk to it through a command line, the **CLI** (command-line interface). In Packet Tracer, click a device and open the **CLI** tab.

### Modes and prompts

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

### Show commands

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

### Reading `show ip interface brief`

| Status / Protocol | Meaning | Usual fix |
|---|---|---|
| up / up | Working | Nothing |
| administratively down / down | Someone typed `shutdown` (router ports start this way) | `no shutdown` on the interface |
| down / down | No cable, or the other end is off | Check the cable and the device on the other end |
| up / down | Cable is fine but the link doesn't work | Check the other side's settings (for example, clock rate on a serial link) |

## Securing a device

These are the classic Packet Tracer security tasks. The examples use simple passwords. Always type exactly the passwords and names the activity instructions give you, because the grader checks for them.

### Set the hostname

Gives the device a name. The prompt changes right away.

```text
Router(config)# hostname R1
R1(config)#
```

### Set the enable secret

Protects privileged EXEC mode. `enable secret` stores the password as a hash.

```text
R1(config)# enable secret Cl@ss123
```

> [!WARNING]
> Don't use `enable password`. It is stored in plain text in the config. If both are set, the device uses `enable secret` and ignores `enable password`.

### Protect the console line

The console is the physical port you plug a console cable into. `login` makes the device actually ask for the password.

```text
R1(config)# line console 0
R1(config-line)# password C0nsole!
R1(config-line)# login
R1(config-line)# exec-timeout 5 0
R1(config-line)# exit
```

`exec-timeout 5 0` logs out an idle session after 5 minutes and 0 seconds.

### Protect the VTY lines (remote login)

VTY (virtual terminal) lines are used for remote logins with Telnet or SSH. Routers usually have lines `0 4`. Many switches have `0 15`.

```text
R1(config)# line vty 0 4
R1(config-line)# password Vty!pass
R1(config-line)# login
R1(config-line)# transport input ssh
R1(config-line)# exit
```

`transport input ssh` allows SSH only, so nobody can log in with unencrypted Telnet. To use SSH you also need the setup in the SSH section below.

### Encrypt the plain-text passwords

Hides the console, VTY and `enable password` passwords in the config.

```text
R1(config)# service password-encryption
```

This uses weak "type 7" encryption that's easy to reverse. It only stops someone reading the password over your shoulder. That's why `enable secret` is still needed.

### Add a login banner

Shows a warning to everyone who connects. The `#` marks the start and end of the message. Any character works as long as it isn't in the message.

```text
R1(config)# banner motd #Authorized access only. Violators will be prosecuted.#
```

MOTD means "message of the day".

### Require a minimum password length

New passwords shorter than this are rejected.

```text
R1(config)# security passwords min-length 10
```

### Block repeated failed logins

Blocks all login attempts for 120 seconds if there are 3 failed attempts within 60 seconds.

```text
R1(config)# login block-for 120 attempts 3 within 60
```

### Shut down unused interfaces

A port that isn't used can't be used by an attacker. `interface range` configures many ports at once.

```text
S1(config)# interface range fastEthernet 0/10 - 24
S1(config-if-range)# shutdown
```

### Configure SSH

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

### Save the configuration

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

## Interfaces and addressing

### Router interface

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

### Switch management address (SVI)

A switch's ports don't have IP addresses. To manage a switch remotely, give it an address on an **SVI** (switched virtual interface), which is a virtual interface for a VLAN. Switch ports are **up by default**, but the SVI needs `no shutdown`.

```text
S1(config)# interface vlan 1
S1(config-if)# ip address 192.168.1.2 255.255.255.0
S1(config-if)# no shutdown
S1(config-if)# exit
S1(config)# ip default-gateway 192.168.1.1
```

`ip default-gateway` lets the switch answer devices on other networks.

### PC addressing in Packet Tracer

1. Click the PC, open the **Desktop** tab, then **IP Configuration**.
2. Choose **Static** and type the IPv4 address, subnet mask, default gateway and DNS server. Or choose **DHCP** to get them from a DHCP server.
3. Check it in **Desktop > Command Prompt**:

```powershell
ipconfig /all
ping 192.168.1.1
```

## VLANs and trunks

A **VLAN** (virtual LAN) splits one switch into separate networks. Devices in different VLANs can't talk to each other without a router (or a multilayer switch). VLAN 1 is the default VLAN that every port starts in.

### Create a VLAN and put ports in it

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

### Trunks

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

### Port security

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

### Router-on-a-stick

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

## Routing and DHCP

### Static and default routes

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

### DHCP server on a router

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

## Troubleshooting checklist

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

## Packet Tracer tips

- **Read the instructions twice** before you start. Write down every name, password and address. Spelling and capital letters must match exactly.
- The **Check Results** button in the instructions window shows your completion percentage and which assessment items are correct. Check it often.
- **Don't click Reset Activity.** It erases all your work.
- **Save the `.pka` file** often with **File > Save** (Ctrl+S), and save it where your instructions say.
- Watch the **timer** if the activity has one. Do the tasks you know first, then come back to the hard ones.
- Click the **Fast Forward Time** button at the bottom of the window to skip ahead in the simulation, for example while links come up or DHCP hands out addresses.
- Use **Tab** and short commands to type faster, and `do` to run `show` commands without leaving config mode.
- When a task doesn't score, compare your `show running-config` with the instructions line by line.

For more terms, see the [glossary](glossary.md).

## Complete manual lab procedures

The earlier tables remain quick references. These procedures add validation, rollback and missing routing/security topics. **All addresses, ports, VLANs and credentials here are lab examples.** Use the activity's actual topology and requirements. On Packet Tracer click the router/switch → **CLI**, press Enter, and answer `no` to the initial setup dialog only if appropriate. On real equipment use an authorized console connection and record the model/IOS version first.

### C.1 Console baseline, modes and recovery

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

### C.2 Local passwords, console/VTY and SSH

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

### C.3 Addressing, subnetting, VLANs, trunks and inter-VLAN routing

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

### C.4 Port security, STP and BPDU Guard

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

### C.5 Static routes and OSPF

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

### C.6 Extended ACLs and management access

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

### C.7 DHCP, logging and final troubleshooting

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
