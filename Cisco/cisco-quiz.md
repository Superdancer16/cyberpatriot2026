# 🧠 Cisco Quiz — Comprehensive Networking Vocabulary, Questions and Answers

> [!TIP]
> **🧭 Jump to a stage:** [📘 Basics](#stage-1) · [🚀 First steps](#stage-2) · [🛡️ Priority](#stage-3) · [⚙️ Practical work](#stage-4) · [🧰 Advanced](#stage-5) · [✅ Final](#stage-6)
> **🎯 Goal:** Work from foundational concepts toward more complex configuration and scenario questions.

> [!IMPORTANT]
> **🧠 Practice approach:** Answer each original short-response question before revealing its answer. Follow the current competition rules on outside notes and resources.


**Purpose:** A comprehensive, searchable, open-ended **question → correct answer** bank for studying CyberPatriot Cisco **multiple-choice concepts**. There are **no A–D answer choices**, no proprietary NetAcad test questions, and no Packet Tracer lab exercises here. Read the question, try to answer from memory, then check the answer. During permitted reference-based study, press **Ctrl+F** to find a term.

> [!IMPORTANT]
> **Official training takes priority.** The CyberPatriot XIX (2026–27) [round-specific topic schedule](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round) identifies the NetAcad modules that count in each round. These questions are independently written practice, not official quiz wording or an answer key. The exact live quiz, question count and permitted references must follow the current rules and competition instructions, not a third-party web page.


> **Guide order:** Basics and vocabulary → First study tasks → Common fundamentals and ports → Intermediate concepts → Advanced scenarios and protocol details → Final review. These are priority study topics, **not** a prediction of secret quiz items.

---

<a id="stage-1"></a>
## Part 1 — Basics / Information Needed

> [!TIP]
> 📘 **Know the essentials:** Definitions, tools and rules before starting.


### Cisco quiz basics you should understand first

Know the difference between a **term**, a **protocol**, an **OSI layer**, a **port number**, an **IP protocol number**, a **device**, a **configuration command**, and a **troubleshooting symptom**. Most distractors confuse two of these categories.

| Quick distinction | Remember |
|---|---|
| Switch vs router | Ethernet frames and MAC learning inside VLANs vs IP routes between networks |
| TCP vs UDP | Ordered reliable byte stream vs connectionless datagrams |
| ARP vs DNS | Local IPv4-to-MAC lookup vs hostname-to-IP lookup |
| DHCP vs DNS | Client addressing/gateway/DNS settings vs name records |
| ACL vs NAT | Packet permitting/denying vs address translation |
| OSPF/EIGRP | IP protocol numbers 89 and 88, **not TCP/UDP port numbers** |
| CIDR and wildcard | Prefix bits define subnet; Cisco wildcard zeros mean must-match |
| STP vs port security | Protects switching loop topology vs restricts MACs at a port |

**Scoring caution:** Exact graded quiz questions and answer choices are not public; the official assigned NetAcad module material is the primary source for the current round. This is an **original question-and-answer reference**, not an answer key.

---

<a id="stage-2"></a>
## Part 2 — First Things to Do

> [!IMPORTANT]
> 🚀 **First actions:** Read instructions and establish a safe starting point.


Review official modules and the study workflow; this section links to all topic categories.

### The fastest way to study for the CyberPatriot Cisco Networking Quiz

**Use this as an original searchable Q&A study guide.** It organizes concepts from the [official CyberPatriot training description](https://www.uscyberpatriot.org/competition/training-materials), the [NetAcad CyberPatriot Content Course](https://www.netacad.com/courses/cyberpatriot-content) and public community study references. The assigned **NetAcad Content Course** is the primary source for your round; the **Competition Course** is where its graded quiz and Packet Tracer exercise are delivered.

#### 2026–27 official scope and point values

The published [CyberPatriot XIX challenge schedule](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round) lists:

| Division and round | Networking **quiz** modules | Published quiz points |
|---|---|---:|
| Practice | 1–2 | Unscored |
| High-school Round 1 | 3–7 | 10 |
| High-school Round 2 | 8–11 and 21–22 | 10 |
| High-school State | 12–17 | 30 |
| High-school Semifinals, Platinum | 18–20 and 23 | 72 |
| High-school Semifinals, Gold/Silver | 18–20 and 23 | 30 |
| Middle-school introductory | 3–7 | 10 |
| Middle-school State | 8–11 and 21–22 | 10 |
| Middle-school Semifinals | 12–17 | 10 |

Module ranges are **official round scopes**, not a claim that a particular Q number below comes from a particular module. The schedule is subject to change. **Do not assume the quiz is open-book or that outside references/collaboration are allowed**; follow the current rulebook and instructions for the competition. Prepare a searchable reference during training where permitted.

#### Which kinds of networking questions should you prepare for?

| Question style | Example prompt (original practice) | What the answer must distinguish |
|---|---|---|
| Vocabulary/definition | Which protocol maps IPv4 addresses to local MAC addresses? | ARP, not DNS or DHCP |
| Layer and PDU | At which OSI layer do TCP and UDP port numbers belong? | Transport Layer 4, not Session Layer 5 |
| Protocol/port | Is OSPF TCP port 89? | No: OSPF is **IP protocol number 89** |
| Device roles | Does a Layer 2 switch route between VLANs by default? | Usually no; needs a router or capable L3 switch |
| Subnetting | Find the network address for 192.168.40.77/27 | /27 increments of 32: 192.168.40.64 |
| CLI configuration | What does no shutdown fix? | Admin-disabled interface, not wrong cable/VLAN |
| Reading output | What does administratively down mean? | Interface was shut in configuration |
| Troubleshooting | IP web access works but hostname web access fails | DNS configuration/service |
| Routing comparison | Which path is chosen, a /24 OSPF route or /16 static route? | Longest matching prefix, not blindly AD=1 |
| Security design | Why prefer SSH over Telnet? | Encrypted authentication/management |
| Wireless | WPA2 key correct but no IP lease | Investigate DHCP, VLAN, isolation, gateway |
| Multi-step scenario | A PC can reach its gateway but not a remote subnet | Routes, return route, ACL and relevant NAT |

#### Training workflow for high retention

1. **Read the assigned NetAcad module**, including its diagrams and interactive examples. Summarize definitions in your own words.
2. Use the numbered Q&A below for **active recall**: cover each Answer, speak a concise answer, then compare.
3. Learn the **reason the wrong-sounding alternatives are wrong**, not merely a word association.
4. Do short timed practices using **original** questions: definitions, scenarios, subnetting and command interpretation.
5. Record terms you missed in a short **weak topics** section and repeat them in a later practice session.
6. Use the [Packet Tracer manual](packet-tracer.md) to make CLI concepts concrete, but remember that the graded **quiz** and **Packet Tracer activity** are distinct tasks.
7. If reference materials are permitted during an assessment, use **Ctrl+F** with the key concept or standard port/protocol; always verify which resources are permitted before the competition.

#### High-value speed tricks and warnings

- **Spot the question's scope:** "Which protocol?" is not the same as "Which layer?" or "Which port?"
- **Watch negative wording:** "NOT", "least likely", "except", "incorrect" reverse the expected selection.
- **Differentiate a best answer from a merely possible one.** Select the explanation that matches the described device/layer and all constraints.
- **Subnet by block size:** /25=128 addresses, /26=64, /27=32, /28=16, /29=8, /30=4. Network = start of the block; broadcast = last address of the block.
- **Know key exceptions:** /31 point-to-point and /32 host routes; IPv6 has no broadcast; IP protocol numbers are not TCP/UDP ports.
- **Check traffic direction:** An ACL applied inbound is evaluated as packets enter that specific interface.
- **Do not memorize obsolete inaccuracies:** OSPF is an **open standard**, and OSI **Session** is not the layer that defines TCP/UDP ports.
- **Do not equate a published challenge maximum with a promise of point values for individual questions.**

#### Official and community reading priorities

1. [CyberPatriot XIX official challenges and modules](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round) and [CyberPatriot training materials](https://www.uscyberpatriot.org/competition/training-materials)
2. [Cisco NetAcad CyberPatriot Content Course](https://www.netacad.com/courses/cyberpatriot-content) and [Getting Started with Packet Tracer](https://www.netacad.com/courses/getting-started-cisco-packet-tracer/1000)
3. [Networking for CyberPatriot Quizlet](https://quizlet.com/846446350/networking-for-cyberpatriot-flash-cards/) and [additional CyberPatriot study Quizlet](https://quizlet.com/212436050/cyber-patriot-study-guide-flash-cards/) — **independent, potentially outdated**
4. [CCA CyberPatriot site](https://sites.google.com/view/cca-cyberpatriot/program-info/cyberpatriot), [Cyber4Youth course](https://cyber4youth.com/learn/cyberpatriot) and [Discovery Middle School training materials](https://dms.madisoncity.k12.al.us/cyberpatriot-training-materials)
5. [Cisco IOS support documentation](https://www.cisco.com/c/en/us/support/) and [IANA service names / port numbers](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml)

**Source quality check:** Public Quizlet sets are good term inventories but are not authoritative. For example, some student sets inaccurately say that OSPF is Cisco-only or put TCP/UDP port numbers in the OSI Session layer. These notes correct such errors and independently summarize the underlying networking concepts.

---


### CyberPatriot XIX: which NetAcad modules to study?

| Round / division | Networking quiz scope listed in official CP-19 schedule |
|---|---|
| Practice round (all) | Modules **1–2** |
| High-school Round 1 | Modules **3–7** |
| High-school Round 2 | Modules **8–11, 21–22** |
| High-school State Round | Modules **12–17** |
| High-school Semifinals | Modules **18–20, 23** |
| Middle-school introductory round | Modules **3–7** |
| Middle-school State Round | Modules **8–11, 21–22** |
| Middle-school Semifinals | Modules **12–17** |

The official [CyberPatriot training page](https://www.uscyberpatriot.org/competition/training-materials) states that quiz and Packet Tracer activities are based on assigned NetAcad **Content Course** materials. Coaches/mentors can enroll teams using [NetAcad's CyberPatriot Content Course](https://www.netacad.com/courses/cyberpatriot-content). **Module numbers here come from the published round schedule; they are not asserted as precise tags for individual questions below.**

---

### Jump to topic

- [Network basics and core vocabulary](#network-basics-and-core-vocabulary) — 16 questions
- [OSI model, TCP/IP model, and data flow](#osi-model-tcpip-model-and-data-flow) — 16 questions
- [Network devices, physical media, and Ethernet](#network-devices-physical-media-and-ethernet) — 20 questions
- [IPv4 addressing and subnetting](#ipv4-addressing-and-subnetting) — 24 questions
- [IPv6 basics](#ipv6-basics) — 12 questions
- [TCP, UDP, applications and common protocols](#tcp-udp-applications-and-common-protocols) — 30 questions
- [DNS, DHCP, NAT, and traffic delivery](#dns-dhcp-nat-and-traffic-delivery) — 12 questions
- [Switching, VLANs, trunks, and Layer 2 security](#switching-vlans-trunks-and-layer-2-security) — 23 questions
- [Routing, OSPF, EIGRP, RIP, and BGP](#routing-ospf-eigrp-rip-and-bgp) — 22 questions
- [Network security and wireless concepts](#network-security-and-wireless-concepts) — 25 questions
- [Cisco IOS and Packet Tracer terminology](#cisco-ios-and-packet-tracer-terminology) — 23 questions
- [Standards organizations and network governance](#standards-organizations-and-network-governance) — 10 questions
- [Short scenario questions: choose the concept](#short-scenario-questions-choose-the-concept) — 21 questions

### First things to do for an efficient Cisco networking study session

1. Check the [official CyberPatriot XIX module schedule](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round) and the coach-assigned NetAcad Content Course modules for your division/round.
2. Read each assigned module's explanations and diagrams; take notes about **definitions, layer functions, standard ports, addressing and device roles**.
3. Answer at least 10 short-answer questions **without seeing the answers**; then review missed items.
4. Study protocols as comparisons (ARP vs DNS, switch vs router, access vs trunk, standard vs extended ACL).
5. Practice basic /24 to /30 subnetting mentally, then IPv6 representation and address ranges.
6. Use the Packet Tracer guide only to **reinforce** concepts; the Networking Quiz and Packet Tracer assessment are different.
7. Follow the current rules about whether notes, Internet access or collaboration are allowed. **Never assume an assessment is open-book solely from a third-party blog.**

**Fast oral drill — answer in one sentence:** What are the seven OSI layers? Which layer uses port numbers? What does DHCP DORA stand for? Which protocol maps IPv4 to MAC? Why is SSH preferred over Telnet? What does a default gateway do? What is VLAN tagging? Why is a /26 not the same as a /24?

The questions below contain answers; cover them while practicing so you learn concepts instead of only recognizing words.

---

<a id="stage-3"></a>
## Part 3 — Common Networking Fundamentals and Vocabulary

> [!IMPORTANT]
> 🛡️ **Core material:** Practice the essential skills and concepts before advanced variations.


These high-frequency fundamentals help answer direct-recall and short scenario questions quickly.

### Network basics and core vocabulary

**Q001. What is a computer network?**

**Answer:** A collection of connected devices that exchange data and share resources using agreed communication protocols.

**Q002. What is a protocol?**

**Answer:** A standardized set of rules governing how devices format, transmit, receive, and interpret data.

**Q003. What are a LAN, WAN, and WLAN?**

**Answer:** LAN is a local-area network, WAN spans a larger geographical area, and WLAN is a wireless local-area network.

**Q004. What is the Internet?**

**Answer:** A global network of interconnected networks that communicate primarily using the TCP/IP protocol suite.

**Q005. What is an intranet?**

**Answer:** A private network or collection of resources intended for members of an organization, typically using Internet technologies.

**Q006. What is an endpoint or host?**

**Answer:** A device such as a PC, phone, printer, or server that sends or receives traffic over a network.

**Q007. What is a server, and what is a client?**

**Answer:** A server provides a service or resource; a client requests or uses it. A device may play both roles.

**Q008. What is peer-to-peer networking?**

**Answer:** A design in which endpoints can share resources directly rather than relying exclusively on a centralized server.

**Q009. What is bandwidth?**

**Answer:** The maximum theoretical or rated data-transfer capacity of a link, typically measured in bits per second.

**Q010. What is throughput?**

**Answer:** The actual rate of successfully delivered data, generally lower than rated bandwidth because of overhead and conditions.

**Q011. What is latency?**

**Answer:** The time required for data to travel from a source to a destination; round-trip time includes the return journey.

**Q012. What is jitter?**

**Answer:** Variation in packet delay; large jitter can degrade real-time audio and video.

**Q013. What is packet loss?**

**Answer:** Packets fail to reach their destination because of congestion, errors, filtering, or other network issues.

**Q014. What is encapsulation?**

**Answer:** Adding protocol headers (and sometimes trailers) as data passes down network layers; decapsulation removes them at the receiver.

**Q015. What is a PDU?**

**Answer:** A protocol data unit: the unit of data at a particular layer, such as a segment, packet, or frame.

**Q016. What are unicast, broadcast, multicast, and anycast?**

**Answer:** Unicast targets one receiver, broadcast all nodes in a broadcast domain, multicast a subscribed group, and anycast one selected member of a group sharing an address.

---

### OSI model, TCP/IP model, and data flow

**Q017. List the seven OSI layers from Layer 1 to Layer 7.**

**Answer:** Physical, Data Link, Network, Transport, Session, Presentation, Application.

**Q018. Which OSI layer deals with cables, radio signals, and raw bits?**

**Answer:** Layer 1, Physical.

**Q019. Which OSI layer uses Ethernet frames and MAC addresses?**

**Answer:** Layer 2, Data Link.

**Q020. Which OSI layer makes IP routing decisions?**

**Answer:** Layer 3, Network.

**Q021. Which OSI layer uses TCP/UDP port numbers?**

**Answer:** Layer 4, Transport.

**Q022. What does the OSI Session layer do?**

**Answer:** Layer 5 establishes, manages, and terminates communication sessions; it is not the TCP/UDP port-number layer.

**Q023. What does the OSI Presentation layer do?**

**Answer:** Layer 6 provides data representation/translation and can handle functions such as formatting, compression, and encryption.

**Q024. What does the OSI Application layer represent?**

**Answer:** Layer 7 provides network-facing services to applications, such as HTTP, DNS, and email protocols.

**Q025. What are the main PDUs at Layers 1, 2, 3, and 4?**

**Answer:** Bits, frame, packet, and TCP segment or UDP datagram, respectively.

**Q026. What are the four commonly taught TCP/IP model layers?**

**Answer:** Network Access (Link), Internet, Transport, and Application.

**Q027. Which TCP/IP layer corresponds to OSI Layer 3?**

**Answer:** The Internet layer, which handles IP addressing and packet routing.

**Q028. Which TCP/IP layer combines OSI Layers 5, 6, and 7?**

**Answer:** The Application layer.

**Q029. What is the difference between a MAC address and an IP address?**

**Answer:** A MAC address identifies a link-layer interface for local delivery; an IP address is a logical network-layer address used in routing.

**Q030. What changes when a packet crosses a router?**

**Answer:** The Layer 2 frame is replaced for the next link; IP addresses usually stay the same unless NAT is involved, while IPv4 TTL / IPv6 hop limit decreases.

**Q031. What does a switch primarily examine to forward an Ethernet frame?**

**Answer:** The destination MAC address and its MAC address table, within the relevant VLAN.

**Q032. What does a router primarily examine to forward an IP packet?**

**Answer:** The destination IP address, using the best matching route (longest prefix match).

---

### Network devices, physical media, and Ethernet

**Q033. What does a hub do?**

**Answer:** A legacy Layer 1 device that repeats received signals to other ports, creating a shared collision domain.

**Q034. What does an Ethernet switch do?**

**Answer:** Learns source MAC addresses and forwards or floods Layer 2 frames within the correct VLAN.

**Q035. What does a router do?**

**Answer:** Connects IP networks and chooses next-hop interfaces based on its routing table.

**Q036. What is a wireless access point?**

**Answer:** A device that bridges Wi-Fi clients into a network, typically using IEEE 802.11.

**Q037. What is the purpose of a firewall?**

**Answer:** Enforce security rules by allowing, rejecting, or dropping network traffic based on configured criteria.

**Q038. What is a NIC?**

**Answer:** A network interface card/controller, providing a device's network connectivity and link-layer functions.

**Q039. What is the role of a modem?**

**Answer:** It modulates and demodulates signals to connect to a provider's access medium; not every broadband link needs a separate modem.

**Q040. What is UTP cable?**

**Answer:** Unshielded twisted-pair copper cable used in many Ethernet installations, commonly terminated with 8P8C modular connectors.

**Q041. What are Cat5e and Cat6?**

**Answer:** Twisted-pair cable performance categories; Cat6 generally supports better high-frequency performance, but actual link speeds and distances depend on the installation.

**Q042. Why use fiber-optic cabling?**

**Answer:** It transmits light, supports long distances and high throughput, and is immune to electromagnetic interference along the fiber.

**Q043. What is the difference between single-mode and multimode fiber?**

**Answer:** Single-mode carries light in one propagation mode for longer distances; multimode carries multiple modes and is common on shorter links.

**Q044. What are half-duplex and full-duplex?**

**Answer:** Half-duplex devices take turns transmitting; full-duplex devices transmit and receive simultaneously.

**Q045. What is a collision domain?**

**Answer:** A shared Ethernet medium in which simultaneous transmissions can interfere; modern full-duplex switched links avoid classic collisions.

**Q046. What is a broadcast domain?**

**Answer:** A set of Layer 2 interfaces that receive the same broadcast traffic, usually bounded by routers and VLANs.

**Q047. What is CSMA/CD?**

**Answer:** Carrier Sense Multiple Access with Collision Detection, historically used on shared half-duplex Ethernet; not used for modern full-duplex switched Ethernet.

**Q048. What is CSMA/CA?**

**Answer:** Carrier Sense Multiple Access with Collision Avoidance, a contention mechanism used by Wi-Fi to reduce transmission collisions.

**Q049. What is PoE?**

**Answer:** Power over Ethernet delivers electrical power over Ethernet cabling to compatible devices such as access points and IP phones.

**Q050. What is the Ethernet FCS?**

**Answer:** Frame Check Sequence, a trailer field containing a CRC used to detect transmission errors in received Ethernet frames.

**Q051. What is an MTU?**

**Answer:** Maximum Transmission Unit, the largest packet payload an interface can transmit without fragmentation or other special handling.

**Q052. What is auto-MDIX?**

**Answer:** A feature allowing an Ethernet port to automatically adapt transmit/receive pairs, reducing the need to choose crossover cables.

---

### IPv4 addressing and subnetting

**Q053. How many bits are in an IPv4 address?**

**Answer:** 32 bits, usually written as four decimal octets separated by dots.

**Q054. What is a subnet mask?**

**Answer:** A 32-bit mask identifying an IPv4 address's network prefix versus host portion.

**Q055. What is CIDR notation?**

**Answer:** A slash followed by the number of prefix bits, such as 192.168.1.0/24.

**Q056. What is the default gateway?**

**Answer:** A router's local interface or virtual gateway address that a host sends off-subnet traffic toward.

**Q057. What are the RFC 1918 private IPv4 ranges?**

**Answer:** 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16.

**Q058. What is 127.0.0.1?**

**Answer:** The IPv4 loopback address used to communicate with the local host.

**Q059. What is an APIPA address?**

**Answer:** An automatic IPv4 link-local address from 169.254.0.0/16, commonly used when DHCP is unavailable; it does not provide normal routed connectivity.

**Q060. What does 0.0.0.0/0 mean in a routing table?**

**Answer:** The default IPv4 route, matching destinations that do not have a more specific route.

**Q061. What does 255.255.255.255 represent?**

**Answer:** The limited IPv4 broadcast address, which routers ordinarily do not forward.

**Q062. What is a network address?**

**Answer:** The address identifying an IPv4 subnet, with host bits set to zero.

**Q063. What is an IPv4 directed broadcast address?**

**Answer:** The highest address in a conventional IPv4 subnet, with all host bits set to one; directed broadcasts are ordinarily filtered by routers.

**Q064. How many total IPv4 addresses are in a /24?**

**Answer:** 256 addresses, typically 254 usable host addresses in an ordinary /24 LAN.

**Q065. How many usable hosts are in a typical /25, /26, /27, and /28?**

**Answer:** /25: 126; /26: 62; /27: 30; /28: 14. These subtract network and broadcast addresses for conventional subnets.

**Q066. What are /30 and /31 commonly used for?**

**Answer:** /30 provides four addresses with two conventional host addresses; /31 is supported for point-to-point links under RFC 3021.

**Q067. What is the mask for /24, /25, /26, /27, and /28?**

**Answer:** 255.255.255.0, 255.255.255.128, 255.255.255.192, 255.255.255.224, and 255.255.255.240.

**Q068. What subnet contains 192.168.10.77/26?**

**Answer:** 192.168.10.64/26; broadcast 192.168.10.127; ordinary usable range 192.168.10.65–126.

**Q069. What is the subnet of 172.16.45.200/20?**

**Answer:** 172.16.32.0/20, with a broadcast of 172.16.47.255.

**Q070. What subnet contains 10.1.1.5/30?**

**Answer:** 10.1.1.4/30; usable addresses are 10.1.1.5 and 10.1.1.6.

**Q071. How do you calculate a typical subnet's usable host count?**

**Answer:** For a conventional IPv4 subnet with h host bits, 2^h − 2; /31 point-to-point and /32 host routes are special cases.

**Q072. What is VLSM?**

**Answer:** Variable Length Subnet Masking, dividing address space into differently sized subnets according to need.

**Q073. What is supernetting or route summarization?**

**Answer:** Combining several contiguous networks into a shorter routing prefix to reduce route table entries.

**Q074. Why does a host need its subnet mask?**

**Answer:** To decide whether a destination is on-link or must be sent to a router.

**Q075. What are historical Class A, B, and C default masks?**

**Answer:** Class A /8, B /16, C /24 in the former classful scheme; modern networks use CIDR instead.

**Q076. What is a wildcard mask in a Cisco ACL?**

**Answer:** An inverse-style address match mask; zero bits must match and one bits are ignored. A /24 commonly uses 0.0.0.255.

---

### TCP, UDP, applications and common protocols

**Q077. How do TCP and UDP differ?**

**Answer:** TCP is connection-oriented and provides ordered, retransmitted byte-stream delivery; UDP is connectionless, with minimal transport guarantees.

**Q078. What is the TCP three-way handshake?**

**Answer:** SYN, SYN-ACK, ACK, establishing a TCP connection.

**Q079. What are TCP sequence numbers and acknowledgments for?**

**Answer:** Tracking received byte ranges and enabling loss recovery and ordered delivery.

**Q080. What is a TCP/UDP port number?**

**Answer:** A 16-bit identifier used by transport protocols to distinguish services and application endpoints.

**Q081. What are well-known, registered, and dynamic/private ports?**

**Answer:** 0–1023 well-known/system, 1024–49151 registered/user, and 49152–65535 dynamic/private.

**Q082. What is DNS?**

**Answer:** Domain Name System, which resolves names and stores records such as A, AAAA, MX and CNAME; usually UDP 53, sometimes TCP 53.

**Q083. What is an A record versus an AAAA record?**

**Answer:** A maps a name to an IPv4 address; AAAA maps a name to an IPv6 address.

**Q084. What is an MX record?**

**Answer:** A DNS record identifying mail exchangers for a domain.

**Q085. What is DHCP?**

**Answer:** Dynamic Host Configuration Protocol, which supplies clients with IP configuration such as address, subnet mask, gateway and DNS servers.

**Q086. What are the DHCP DORA steps?**

**Answer:** Discover → Offer → Request → Acknowledge, the common initial IPv4 lease process.

**Q087. Which UDP ports does DHCPv4 normally use?**

**Answer:** Server 67 and client 68.

**Q088. What is BOOTP?**

**Answer:** Bootstrap Protocol, a predecessor of DHCP used to provide startup IP information and boot-related configuration.

**Q089. What is HTTP and its usual port?**

**Answer:** Hypertext Transfer Protocol for web requests/responses, typically TCP 80.

**Q090. What is HTTPS and its usual port?**

**Answer:** HTTP protected by TLS, normally TCP 443; HTTP/3 may use QUIC over UDP 443.

**Q091. What is FTP and which ports matter?**

**Answer:** File Transfer Protocol, traditionally TCP 21 for control and TCP 20 for active-mode data; passive-mode data uses negotiated ports.

**Q092. What is TFTP?**

**Answer:** Trivial File Transfer Protocol, a simple UDP-based file transfer protocol that initially uses UDP 69; it has no built-in authentication or encryption.

**Q093. What is SSH and its standard port?**

**Answer:** Secure Shell, an encrypted remote access protocol typically using TCP 22.

**Q094. What is Telnet and why is it discouraged?**

**Answer:** A remote terminal protocol normally using TCP 23; classic Telnet transmits credentials and data without encryption.

**Q095. What is SMTP?**

**Answer:** Simple Mail Transfer Protocol for email transfer; commonly TCP 25 for server-to-server and TCP 587 for message submission.

**Q096. What are POP3 and IMAP?**

**Answer:** POP3 normally retrieves/downloads email (TCP 110, TLS TCP 995); IMAP synchronizes messages on a server (TCP 143, TLS TCP 993).

**Q097. What are SNMP and SNMP traps?**

**Answer:** Simple Network Management Protocol manages/monitors devices, normally UDP 161; notifications/traps commonly use UDP 162.

**Q098. What is NTP?**

**Answer:** Network Time Protocol, synchronizing device clocks, normally UDP 123.

**Q099. What is Syslog?**

**Answer:** A system for forwarding log messages to a logging service, often UDP 514; modern deployments also use TCP/TLS variants.

**Q100. What is RDP and its common port?**

**Answer:** Microsoft Remote Desktop Protocol, typically TCP and/or UDP 3389.

**Q101. What is LDAP and LDAPS?**

**Answer:** Lightweight Directory Access Protocol, commonly TCP/UDP 389; LDAP over TLS is commonly TCP 636.

**Q102. What is SMB and its modern direct-hosted port?**

**Answer:** Server Message Block for file/printer shares, typically TCP 445.

**Q103. What is ICMP used for?**

**Answer:** Network diagnostics and control/error messages, such as echo requests and replies; ICMP itself has no TCP/UDP port number.

**Q104. What is ARP?**

**Answer:** Address Resolution Protocol, used on IPv4 local networks to find a MAC address for a known on-link IPv4 address.

**Q105. What is PPP?**

**Answer:** Point-to-Point Protocol, a Layer 2 protocol for direct serial or other point-to-point connections.

**Q106. What is PPPoE?**

**Answer:** PPP over Ethernet, often used by broadband providers to carry PPP sessions over Ethernet links.

---

### High-speed reference: common port numbers

| Protocol / use | Common port(s) and transport | Key distinction |
|---|---|---|
| FTP | TCP 21 (control), TCP 20 (traditional active data) | Passive data negotiated separately |
| SSH / Telnet | TCP 22 / TCP 23 | SSH encrypts; Telnet usually does not |
| SMTP | TCP 25, submission TCP 587 | Email transfer/submission |
| DNS | UDP and TCP 53 | UDP common; TCP also used |
| DHCPv4 | UDP server 67, client 68 | DORA lease process |
| TFTP | UDP 69 (initial request) | Simple file transfer |
| HTTP / HTTPS | TCP 80 / TCP 443 (HTTPS may use UDP 443 for HTTP/3) | TLS secures HTTPS |
| POP3 / IMAP | TCP 110 / TCP 143 | Email retrieval / synchronization |
| NTP | UDP 123 | Time synchronization |
| SNMP / traps | UDP 161 / UDP 162 | Queries / notifications |
| LDAP / LDAPS | 389 / TCP 636 | Directory services |
| Syslog | Often UDP 514 | Other transports available |
| SMB | TCP 445 | File and printer sharing |
| RADIUS | Usually UDP 1812 / 1813 | AAA auth / accounting |
| TACACS+ | TCP 49 | AAA |
| BGP | TCP 179 | Exterior routing protocol |
| RDP | TCP/UDP 3389 | Remote desktop |

**Trick question:** OSPF, EIGRP and ICMP use **IP protocol numbers** (OSPF 89, EIGRP 88, ICMPv4 1), **not TCP/UDP port numbers**. ARP is a link-layer protocol, not a TCP/UDP service.

---

### Fast contrasts often used as distractors

| Easily confused | Remember this |
|---|---|
| Switch vs router | Switch: MAC + frames within VLAN; router: IP + packets between networks |
| MAC vs IP | MAC is local link identity; IP is logical/routed address |
| Bandwidth vs throughput | Link capacity vs observed delivered data rate |
| TCP vs UDP | Reliable ordered byte-stream vs connectionless datagrams |
| ARP vs DNS | IPv4 → MAC on local link vs hostname → IP address |
| DNS vs DHCP | Name records vs automatic host configuration |
| HTTP vs HTTPS | Application web protocol vs web protocol protected by TLS |
| SSH vs Telnet | Encrypted vs traditionally plaintext remote terminal |
| Standard vs extended ACL | Mainly source IP vs richer IP/protocol/port matching |
| OSPF vs EIGRP vs RIP vs BGP | Link-state cost vs DUAL composite metric vs hop count vs inter-AS path-vector routing |
| VLAN vs subnet | Layer 2 segmentation vs Layer 3 address prefix; often aligned but not identical |
| STP vs PortFast vs BPDU Guard | Prevent switching loops vs rapid edge forwarding vs block unexpected edge BPDUs |
| Admin distance vs metric | Choose between route sources for same prefix vs compare paths within routing process |
| Longest prefix vs AD | Forwarding uses most-specific matching route; AD decides installed route source for a prefix |
| SSID vs WPA | Wi-Fi network identifier vs wireless security mechanisms |
| IANA vs ICANN vs IETF | Registries/number coordination vs naming governance vs technical standards/RFC work |

### High-yield question styles and response techniques

- **Definition wording:** Answer with the identifying *function*, not only an acronym expansion.
- **Layer/protocol/port wording:** State whether the item is an OSI layer, TCP/UDP port, or IP protocol number.
- **Subnetting:** Identify prefix length, block size, network address, broadcast (where applicable) and usable range.
- **Routing:** Longest-prefix match controls forwarding among installed routes; administrative distance compares competing route sources for the *same prefix*.
- **Network troubleshooting:** Check local link and gateway before DNS or distant routers; if IP-based web access works but names fail, inspect DNS.
- **Security:** Differentiate prevention, monitoring, access control, encryption and authentication; don't assume all controls can be substituted.
- **Question traps:** Watch NOT / EXCEPT, confusing synonyms, IPv4-versus-IPv6 behavior, old classful addressing and GUI/device-specific terms.

**Source correction notes:** OSPF is an open standards-based protocol, not a Cisco-only protocol. TCP and UDP port numbers belong to **Transport (OSI Layer 4)**, not Session (Layer 5). IPv6 uses Neighbor Discovery instead of ARP.

---

<a id="stage-4"></a>
## Part 4 — Intermediate IPv6, Switching, Services and Security

> [!TIP]
> ⚙️ **Practice carefully:** Apply the methods to the actual exercise or study problem.


Study service behavior, protocol distinctions, switch security, IPv6 and command meaning.

### IPv6 basics

**Q107. How many bits are in an IPv6 address?**

**Answer:** 128 bits, commonly represented as eight groups of hexadecimal digits.

**Q108. What does :: mean in IPv6 notation?**

**Answer:** Compression of one contiguous run of all-zero 16-bit groups; it can appear only once in an address.

**Q109. What is an IPv6 link-local address?**

**Answer:** An address typically from fe80::/10 for communication on the same link; it is not routed across normal IPv6 routers.

**Q110. What is an IPv6 global unicast address?**

**Answer:** A routable unicast address, commonly allocated from 2000::/3.

**Q111. What is an IPv6 unique local address?**

**Answer:** A privately scoped IPv6 address from fc00::/7, commonly using locally assigned fd00::/8 addresses.

**Q112. What is the IPv6 loopback address?**

**Answer:** ::1/128.

**Q113. Does IPv6 use broadcast addresses?**

**Answer:** No. IPv6 uses multicast and unicast (including anycast) instead of broadcast.

**Q114. What is NDP?**

**Answer:** Neighbor Discovery Protocol, an ICMPv6-based mechanism for discovering neighbors, routers and link information; it replaces ARP's main job.

**Q115. What are SLAAC and DHCPv6?**

**Answer:** SLAAC builds IPv6 addresses using router advertisements; DHCPv6 can provide addresses and/or additional configuration, depending on network design.

**Q116. What are router advertisements (RA)?**

**Answer:** ICMPv6 messages from routers that communicate prefixes, default-router availability and configuration flags.

**Q117. What is an IPv6 prefix length?**

**Answer:** The number of leading network bits, written /n; /64 is common for LAN subnets supporting SLAAC.

**Q118. What is IPv6 hop limit?**

**Answer:** The IPv6 equivalent of IPv4 TTL, decreased by routers to prevent indefinite circulation.

---

### DNS, DHCP, NAT, and traffic delivery

**Q119. What is NAT?**

**Answer:** Network Address Translation, changing IP address information as packets pass through a translating device.

**Q120. What is PAT or NAT overload?**

**Answer:** Port Address Translation: many inside hosts share one public IPv4 address using distinct transport port mappings.

**Q121. What is a DHCP lease?**

**Answer:** A time-limited assignment of IP configuration from a DHCP server to a client.

**Q122. What happens if a DHCP server cannot be reached?**

**Answer:** The client may retain a valid lease, use a fallback link-local IPv4 address, or have no usable address; behavior depends on platform and state.

**Q123. What is DHCP relay or ip helper-address?**

**Answer:** A router feature that forwards client DHCP broadcasts to a DHCP server on another subnet.

**Q124. What is the difference between a recursive and authoritative DNS server?**

**Answer:** A recursive resolver looks up an answer for a client; an authoritative server publishes records for zones it serves.

**Q125. What is DNS caching?**

**Answer:** Temporarily storing DNS answers based on their TTL to reduce repeated queries.

**Q126. What is split-horizon DNS or split DNS?**

**Answer:** Using different DNS answers or zones for internal and external clients.

**Q127. What is TTL in a DNS record versus IPv4 TTL?**

**Answer:** DNS TTL is a cache lifetime; IPv4 TTL is a hop-limit field decremented by routers. They are different concepts.

**Q128. What is port forwarding?**

**Answer:** A NAT/router rule sending traffic arriving at a selected external address/port to a specified internal service.

**Q129. What is a default route?**

**Answer:** A fallback route for destinations not matched by a more-specific route, usually 0.0.0.0/0 for IPv4 or ::/0 for IPv6.

**Q130. What happens to IPv4 ARP when a client sends to another subnet?**

**Answer:** The client resolves the MAC address of its default gateway, not the remote destination's MAC address.

---

### Switching, VLANs, trunks, and Layer 2 security

**Q131. What is a VLAN?**

**Answer:** A Virtual LAN: a logical Layer 2 broadcast domain defined on switches, generally separating traffic between groups of ports.

**Q132. What is an access port?**

**Answer:** A switch port normally carrying untagged traffic for one access VLAN.

**Q133. What is a trunk port?**

**Answer:** A link that carries traffic for multiple VLANs, commonly using IEEE 802.1Q tags.

**Q134. What is an IEEE 802.1Q tag?**

**Answer:** A VLAN identifier and related priority information inserted into Ethernet frames on tagged links.

**Q135. What is a native VLAN?**

**Answer:** On a traditional 802.1Q trunk, the VLAN associated with untagged traffic; both ends must agree or traffic can be misclassified.

**Q136. What is VLAN 1?**

**Answer:** The default VLAN on many Cisco switches; using dedicated management and user VLANs is common best practice.

**Q137. What is an SVI?**

**Answer:** Switched Virtual Interface, a Layer 3 logical interface associated with a VLAN, often used for management or inter-VLAN routing on capable switches.

**Q138. What is inter-VLAN routing?**

**Answer:** Routing between separate VLAN subnets using a router or a Layer 3 switch.

**Q139. What is router-on-a-stick?**

**Answer:** Inter-VLAN routing over one router physical link using separate 802.1Q-tagged subinterfaces.

**Q140. What is a MAC address table or CAM table?**

**Answer:** A switch table mapping learned MAC addresses and VLANs to outgoing interfaces.

**Q141. What does a switch do with unknown unicast traffic?**

**Answer:** It ordinarily floods the frame to other forwarding ports in the same VLAN until the destination MAC is learned or policy changes behavior.

**Q142. What is a broadcast storm?**

**Answer:** Excessive Layer 2 broadcast traffic, often caused by a switching loop or misconfiguration, that overwhelms network resources.

**Q143. What is STP?**

**Answer:** Spanning Tree Protocol, preventing Layer 2 loops by selecting a loop-free active topology and blocking redundant paths.

**Q144. How does STP elect a root bridge?**

**Answer:** The switch with the lowest bridge ID wins; bridge priority is considered before the MAC-address portion.

**Q145. What is an STP BPDU?**

**Answer:** Bridge Protocol Data Unit, messages switches exchange to establish and maintain spanning-tree topology.

**Q146. What is PortFast?**

**Answer:** A Cisco feature that moves designated edge ports rapidly to forwarding; use on true end-host ports, not arbitrary switch-to-switch links.

**Q147. What is BPDU Guard?**

**Answer:** A feature that protects edge ports by disabling them when unexpected BPDUs are received, according to configuration.

**Q148. What is port security?**

**Answer:** A switch feature limiting which or how many source MAC addresses may use a port, with configured violation actions.

**Q149. What is a port-security violation mode?**

**Answer:** Typical Cisco modes include protect (drop), restrict (drop and log/count), and shutdown (put the port in error-disabled state).

**Q150. What is DTP?**

**Answer:** Dynamic Trunking Protocol, a Cisco protocol used by some switches to negotiate trunk links; static trunking avoids unwanted negotiation.

**Q151. What is VTP?**

**Answer:** VLAN Trunking Protocol, a Cisco technology for distributing VLAN information between switches in a VTP domain.

**Q152. What is EtherChannel?**

**Answer:** Bundling multiple physical links into one logical link for capacity and redundancy; LACP is a standards-based negotiation method.

**Q153. What is LLDP versus CDP?**

**Answer:** LLDP is a standards-based neighbor discovery protocol; CDP is Cisco Discovery Protocol, a Cisco-originated neighbor discovery method.

---

### Network security and wireless concepts

**Q154. What are the CIA triad's three goals?**

**Answer:** Confidentiality (prevent unauthorized disclosure), Integrity (prevent unauthorized alteration), and Availability (keep services accessible when needed).

**Q155. What is the principle of least privilege?**

**Answer:** Grant each user, device or service only the permissions necessary for its authorized job.

**Q156. What is an ACL?**

**Answer:** Access Control List, ordered permit/deny rules used to filter traffic or control access on supported devices.

**Q157. What is the difference between standard and extended Cisco IPv4 ACLs?**

**Answer:** Standard ACLs primarily match source IPv4 addresses; extended ACLs can match source/destination, protocol, and transport ports.

**Q158. What does implicit deny mean in an ACL?**

**Answer:** Traffic that matches none of the permit statements is denied at the end of the ACL.

**Q159. What is ACL wildcard-mask logic?**

**Answer:** A 0 bit means match the corresponding address bit; a 1 bit means ignore it.

**Q160. What is defense in depth?**

**Answer:** Using multiple complementary security controls so a single failure does not expose the entire system.

**Q161. What is segmentation?**

**Answer:** Dividing networks into distinct zones or VLANs with controlled routing and filtering to limit unnecessary access.

**Q162. What is a DMZ?**

**Answer:** A network zone for externally reachable services separated by policy from internal systems.

**Q163. What is an IDS versus an IPS?**

**Answer:** An intrusion detection system alerts on suspicious activity; an intrusion prevention system can actively block it.

**Q164. What is a VPN?**

**Answer:** A virtual private network providing an encrypted or otherwise protected logical tunnel over another network, depending on the protocol.

**Q165. What is 802.1X?**

**Answer:** Port-based network access control using EAP with an authenticator such as a switch/AP and usually a back-end authentication server.

**Q166. What is RADIUS?**

**Answer:** A centralized AAA protocol, often used for network access authentication and accounting; common UDP ports are 1812 and 1813.

**Q167. What is TACACS+?**

**Answer:** A Cisco-originated AAA protocol typically using TCP 49 and separating authentication, authorization and accounting.

**Q168. What is AAA?**

**Answer:** Authentication establishes identity; Authorization determines permissions; Accounting records activity.

**Q169. What is SSH preferred over Telnet?**

**Answer:** SSH encrypts authentication and management traffic; classic Telnet exposes them in plaintext.

**Q170. What is DHCP snooping?**

**Answer:** A Layer 2 security feature that blocks untrusted DHCP server messages and can build client binding data.

**Q171. What is Dynamic ARP Inspection (DAI)?**

**Answer:** A switch protection that checks ARP packets against trusted bindings or ARP ACLs to reduce ARP spoofing.

**Q172. What is ARP spoofing?**

**Answer:** Sending falsified ARP information to redirect local IPv4 traffic, possibly enabling interception or disruption.

**Q173. What is a rogue access point?**

**Answer:** An unauthorized wireless AP that can bypass network controls or attract clients.

**Q174. What is a wireless SSID?**

**Answer:** Service Set Identifier, the name identifying a Wi-Fi network; hiding it is not reliable security.

**Q175. What is WPA2 versus WPA3?**

**Answer:** Wi-Fi security generations; WPA3-Personal uses SAE, while WPA2-Personal commonly uses a pre-shared-key handshake.

**Q176. Why is WEP insecure?**

**Answer:** Its legacy cryptographic design has practical weaknesses; it should not be used to secure modern Wi-Fi.

**Q177. What is 802.11?**

**Answer:** The IEEE family of wireless LAN standards used by Wi-Fi, including revisions such as 802.11n/ac/ax/be.

**Q178. What is a VLAN hopping attack?**

**Answer:** An attack exploiting trunking or VLAN-tag handling weaknesses to reach traffic in unintended VLANs; careful trunk and access-port settings help mitigate it.

---

### Cisco IOS and Packet Tracer terminology

**Q179. What is Cisco IOS?**

**Answer:** Cisco Internetwork Operating System, the software used to configure and operate many Cisco routers and switches.

**Q180. What are Cisco user EXEC and privileged EXEC modes?**

**Answer:** User EXEC usually shows `>` with limited commands; privileged EXEC shows `#` and allows broader show and administration commands.

**Q181. What does `enable` do?**

**Answer:** Moves from user EXEC to privileged EXEC mode when authorized; it may request the configured enable secret.

**Q182. What does `configure terminal` do?**

**Answer:** Enters global configuration mode so device configuration can be changed.

**Q183. What do `(config)#` and `(config-if)#` indicate?**

**Answer:** Global configuration mode and interface configuration mode, respectively.

**Q184. What does `exit` versus `end` do?**

**Answer:** `exit` backs out one configuration level; `end` returns directly to privileged EXEC.

**Q185. What does `show running-config` display?**

**Answer:** The current active configuration held in memory.

**Q186. What does `show startup-config` display?**

**Answer:** The saved configuration used at startup, when one is stored.

**Q187. How do you save the current configuration on typical IOS?**

**Answer:** Use `copy running-config startup-config` from privileged EXEC after verifying settings.

**Q188. What does `show ip interface brief` reveal?**

**Answer:** Interface addresses and operational/line-protocol status; it helps identify down or administratively down interfaces.

**Q189. What does `administratively down` mean?**

**Answer:** The interface was manually disabled, often with `shutdown`.

**Q190. What does `no shutdown` do?**

**Answer:** Removes the administrative shutdown setting on a selected interface; it does not fix physical cable/VLAN problems.

**Q191. What does `show vlan brief` display?**

**Answer:** The switch's VLAN IDs/names and commonly associated access ports.

**Q192. What does `show interfaces trunk` display?**

**Answer:** Trunk links and information such as allowed VLANs and tagging behavior on supported switches.

**Q193. What does `show ip route` display?**

**Answer:** The IPv4 routing table, including connected and learned routes.

**Q194. What does `show access-lists` display?**

**Answer:** Configured ACL entries and, on supported platforms, match counters.

**Q195. What is `service password-encryption`?**

**Answer:** A Cisco IOS feature that obfuscates certain plaintext password representations; it is not equivalent to strong modern password hashing.

**Q196. What is an `enable secret`?**

**Answer:** A privileged EXEC password stored using a one-way hash type supported by the IOS release; generally preferable to legacy `enable password`.

**Q197. What does `line vty` configure?**

**Answer:** Settings for virtual terminal lines used by remote administrative sessions.

**Q198. What does `transport input ssh` do?**

**Answer:** Allows SSH on selected VTY lines while excluding Telnet for those lines.

**Q199. What does `show cdp neighbors` do?**

**Answer:** Lists directly connected Cisco Discovery Protocol neighbors when CDP is enabled.

**Q200. What does `show logging` do?**

**Answer:** Displays device log messages and configured logging information on supported IOS.

**Q201. What is Packet Tracer?**

**Answer:** Cisco's network simulation tool for designing, configuring and troubleshooting virtual network devices; not all real IOS features are simulated.

---

### Standards organizations and network governance

**Q202. What does IEEE stand for and what does it standardize?**

**Answer:** Institute of Electrical and Electronics Engineers; it publishes many networking standards, including Ethernet (802.3) and Wi-Fi (802.11).

**Q203. What does IETF stand for?**

**Answer:** Internet Engineering Task Force, which develops Internet technical standards and publishes many RFCs.

**Q204. What is an RFC?**

**Answer:** Request for Comments, a publication in the Internet technical document series; RFCs may be standards, informational, experimental or other types.

**Q205. What is the IAB?**

**Answer:** Internet Architecture Board, which provides architecture oversight and guidance for Internet standards work.

**Q206. What is the IRTF?**

**Answer:** Internet Research Task Force, which coordinates longer-term Internet research groups.

**Q207. What is ISOC?**

**Answer:** Internet Society, a nonprofit supporting an open, globally connected Internet and related communities.

**Q208. What is IANA?**

**Answer:** Internet Assigned Numbers Authority functions, coordinating global Internet numbers and protocol parameter registries within ICANN's ecosystem.

**Q209. What is ICANN?**

**Answer:** Internet Corporation for Assigned Names and Numbers, which coordinates key Internet naming and addressing systems and performs IANA functions through its affiliate.

**Q210. What are TIA and EIA associated with?**

**Answer:** Telecommunications Industry Association and former Electronic Industries Alliance; historically important in structured cabling and telecommunications standards.

**Q211. What is ITU-T?**

**Answer:** The ITU Telecommunication Standardization Sector, which develops telecommunications standards and recommendations.

---

<a id="stage-5"></a>
## Part 5 — Advanced Routing, Scenarios and Expanded Question Bank

> [!NOTE]
> 🧰 **Deep reference:** Explore advanced cases, troubleshooting and common misconceptions.


Apply concepts through multi-step reasoning, CLI output interpretation, protocol behavior and troubleshooting.

### Routing, OSPF, EIGRP, RIP, and BGP

**Q212. What is a routing table?**

**Answer:** A table of destination prefixes and next hops or interfaces a router uses to forward IP traffic.

**Q213. What is a static route?**

**Answer:** A route manually configured by an administrator rather than learned from a dynamic routing protocol.

**Q214. What is a dynamic routing protocol?**

**Answer:** A protocol through which routers exchange reachability information and adapt to topology changes.

**Q215. What is an IGP?**

**Answer:** Interior Gateway Protocol, used for routing within one administrative routing domain, such as OSPF, IS-IS, RIP, or EIGRP.

**Q216. What is an EGP?**

**Answer:** Exterior Gateway Protocol, typically referring to BGP for exchanging reachability between autonomous systems.

**Q217. What is RIP?**

**Answer:** Routing Information Protocol, a distance-vector IGP using hop count as its metric; RIPv2 supports classless routes.

**Q218. What is the maximum usable hop count in RIP?**

**Answer:** 15 hops; 16 means unreachable.

**Q219. What is OSPF?**

**Answer:** Open Shortest Path First, a link-state IGP using link-state advertisements and shortest-path calculations to build routes.

**Q220. What metric does OSPF commonly use?**

**Answer:** Cost, often derived from interface bandwidth under Cisco configurations; total path cost is the sum of link costs.

**Q221. What is OSPF area 0?**

**Answer:** The backbone area to which other normal OSPF areas connect, directly or by supported virtual-link design.

**Q222. What is an OSPF LSA?**

**Answer:** Link-State Advertisement containing topology or routing information used in building the OSPF link-state database.

**Q223. What are an OSPF DR and BDR?**

**Answer:** Designated Router and Backup Designated Router, elected on certain multiaccess network types to reduce adjacency overhead.

**Q224. What is EIGRP?**

**Answer:** Enhanced Interior Gateway Routing Protocol, a Cisco-originated advanced distance-vector IGP using the DUAL algorithm.

**Q225. What metric does EIGRP use by default?**

**Answer:** A composite metric primarily based on minimum path bandwidth and cumulative interface delay; other factors exist but are not included by default.

**Q226. What is DUAL?**

**Answer:** Diffusing Update Algorithm, used by EIGRP to determine loop-free routes and alternatives.

**Q227. What is BGP?**

**Answer:** Border Gateway Protocol, a path-vector interdomain routing protocol commonly used between autonomous systems on the Internet.

**Q228. What is an autonomous system (AS)?**

**Answer:** A set of networks governed by a common routing policy, identified by an autonomous system number for BGP.

**Q229. What is administrative distance?**

**Answer:** A Cisco preference value for route sources when competing routes to the same prefix exist; lower is normally preferred.

**Q230. What are common default Cisco administrative distances?**

**Answer:** Connected 0, static 1, internal EIGRP 90, OSPF 110, RIP 120; configurable values can differ.

**Q231. What is longest prefix match?**

**Answer:** The forwarding choice of the most specific matching installed route, such as preferring a /24 over a /16 for the same destination.

**Q232. What is a next hop?**

**Answer:** The neighboring router/address to which a packet is sent on the way toward its destination.

**Q233. What is route convergence?**

**Answer:** The process by which routers update their topology/routing information after a change until the network reaches a consistent state.

---

### Short scenario questions: choose the concept

**Q234. A PC can ping its own address but not the local default gateway. What should you inspect first?**

**Answer:** Check the gateway IP, subnet mask, cable/link state, access VLAN, switch port, interface status and local firewall; don't start by changing Internet DNS.

**Q235. A PC can ping a public IPv4 address but websites fail by name. What likely service should be checked?**

**Answer:** DNS name resolution and the client's configured DNS servers.

**Q236. Two PCs on different VLANs cannot communicate even though each can ping its own gateway. What may be missing?**

**Answer:** Inter-VLAN routing, route-back information, or an ACL permitting the required traffic.

**Q237. A switch has a frame for an unknown destination MAC. What generally happens?**

**Answer:** It floods the frame to the other forwarding ports in the same VLAN, subject to security/filtering rules.

**Q238. Two routers advertise the same prefix using OSPF and internal EIGRP. Which source wins at default Cisco AD?**

**Answer:** Internal EIGRP (AD 90) over OSPF (AD 110), assuming equal prefixes, valid next hops and default distances.

**Q239. A router has both 192.168.0.0/16 and 192.168.1.0/24 routes. Which matches 192.168.1.5 for forwarding?**

**Answer:** 192.168.1.0/24 because longest prefix match chooses the more specific installed route.

**Q240. A client receives 169.254.x.x instead of a normal IPv4 address. What should you investigate?**

**Answer:** DHCP reachability, DHCP server/pool, VLAN, relay configuration and link connectivity.

**Q241. A new switch creates a Layer 2 loop. Which protocol is designed to prevent it?**

**Answer:** Spanning Tree Protocol (STP) or a supported variant such as RSTP.

**Q242. A switch port err-disables after receiving a BPDU. What feature may be responsible?**

**Answer:** BPDU Guard on an edge or PortFast-configured port; verify device logs and configuration.

**Q243. A user wants encrypted remote Cisco administration. What protocol should be chosen?**

**Answer:** SSH rather than Telnet.

**Q244. A quiz asks which protocol resolves IPv4 addresses to MAC addresses locally. What is the answer?**

**Answer:** ARP; IPv6 uses Neighbor Discovery instead.

**Q245. A quiz asks for the DHCP message order. What is the answer?**

**Answer:** Discover, Offer, Request, Acknowledge (DORA).

**Q246. A quiz asks which device separates broadcast domains by default. What is the answer?**

**Answer:** A router or other Layer 3 boundary; a switch ordinarily separates collision domains, while VLANs create distinct Layer 2 broadcast domains.

**Q247. A quiz asks whether TCP or UDP guarantees in-order reliable delivery. What is the answer?**

**Answer:** TCP provides ordered and retransmitted byte-stream delivery; UDP has no built-in delivery guarantee.

**Q248. A network design requires 50 conventional IPv4 hosts per subnet. Which is the smallest usual prefix?**

**Answer:** /26, which has 64 total addresses and 62 ordinary usable host addresses.

**Q249. A router interface is listed as administratively down. What likely needs checking?**

**Answer:** Whether `shutdown` is configured; if the activity requires the interface up, use `no shutdown` in that interface's configuration mode.

**Q250. An ACL blocks everything after two permit statements. What is the cause?**

**Answer:** The implicit deny at the end of the ACL catches packets not matched by a permit statement.

**Q251. A switch management SVI cannot reach an off-subnet management PC. What might be missing?**

**Answer:** On a Layer 2 switch, the correct `ip default-gateway` and SVI/IP/subnet; on a Layer 3 switch, appropriate routing such as a default route.

**Q252. A PC can reach its gateway but fails to get an IP lease from a server in another subnet. What configuration might be missing?**

**Answer:** A DHCP relay (`ip helper-address`) on the client-facing router interface, or an allowed DHCP path.

**Q253. A question mentions lowest OSPF cost. Is router priority the metric?**

**Answer:** No. OSPF uses route cost; interface priority is used for DR/BDR election on certain multiaccess networks.

**Q254. The competition asks for the exact NetAcad quiz answers. Can these notes guarantee them?**

**Answer:** No. These are original concept questions based on public learning objectives, not a copy of private or live competition questions.

---


### Additional quiz-style question bank: deeper concepts and exam traps

These are **new, original**, short-answer practice items supplementing Q001–Q254. They focus on the interpretation, troubleshooting and vocabulary distractors typical of networking assessments. **These are not copied from proprietary NetAcad exams and not guaranteed live competition questions.**

#### Reading Cisco configuration and command intent (20 questions)

**Q255. A Cisco switch shows a port in VLAN 1, but a PC is assigned to VLAN 20. What should you inspect?**

**Answer:** Check the port's access VLAN with show vlan brief and interface switchport settings; assign VLAN 20 only when it is the intended access VLAN.

**Q256. What does a switchport trunk allowed vlan list control?**

**Answer:** It controls which VLANs' traffic is permitted across that trunk; replacing it can unintentionally exclude a required VLAN.

**Q257. When might switchport mode access be safer than dynamic negotiation?**

**Answer:** On an end-host port that should not form a trunk, explicitly using access mode reduces unintended trunk negotiation.

**Q258. A router subinterface has encapsulation dot1Q 30. What does 30 identify?**

**Answer:** The 802.1Q VLAN tag ID associated with traffic processed by that router subinterface.

**Q259. What does ip routing enable on a capable multilayer switch?**

**Answer:** Layer 3 IP forwarding between routed interfaces and SVIs; a basic Layer 2 switch may not support it.

**Q260. Why does an SVI for VLAN 10 sometimes remain down despite no shutdown?**

**Answer:** The VLAN may be missing, have no active associated Layer 2 port, or be unavailable due to platform conditions.

**Q261. What is the effect of no shutdown on an interface?**

**Answer:** Removes administrative shutdown; it cannot repair a bad cable, wrong VLAN or down far-end port.

**Q262. What does ip helper-address generally do on a client-facing router interface?**

**Answer:** Relays selected broadcasts, commonly DHCP requests, toward a specified server on another subnet.

**Q263. What does ip dhcp excluded-address prevent?**

**Answer:** It keeps specified IPv4 addresses out of the router's DHCP assignment pool, often protecting static gateways or servers.

**Q264. What is the purpose of a Cisco OSPF network statement with area 0?**

**Answer:** It selects matching local interfaces to participate in OSPF and associates them with the designated area.

**Q265. What is the purpose of router eigrp 100?**

**Answer:** Starts/configures a classic EIGRP routing process using autonomous-system number 100 on supported IOS.

**Q266. What does login local under line vty require?**

**Answer:** User authentication against configured local username/secret credentials, unless other AAA policy supersedes it.

**Q267. What does transport input ssh prevent when applied to appropriate VTY lines?**

**Answer:** It restricts incoming remote terminal sessions on those lines to SSH rather than Telnet.

**Q268. What is the difference between copy running-config startup-config and show startup-config?**

**Answer:** The first saves the active configuration for next boot; the second displays the previously stored startup configuration.

**Q269. What does show ip interface brief help diagnose immediately?**

**Answer:** Interface IP addresses and state, including administratively down, down/down and up/up status.

**Q270. What does show interfaces trunk tell you that show vlan brief may not?**

**Answer:** Operational trunk ports, their tagging/native VLAN information, and VLANs allowed/active across them.

**Q271. What does show ip route ospf display?**

**Answer:** Routes installed in the IPv4 routing table learned through OSPF, not the complete set of every LSA.

**Q272. What does show access-lists help verify?**

**Answer:** ACL entries and, on supporting devices, rule hit counters; you still need an allowed-flow and denied-flow test.

**Q273. What does show ip nat translations show?**

**Answer:** Active NAT mappings between original and translated addresses/ports; an empty table can simply mean no matching traffic occurred.

**Q274. What does show port-security interface report?**

**Answer:** Port security state, violation counters, maximum/learned MAC addresses, and associated security behavior where supported.

#### Practical IPv4 subnetting questions (14 questions)

**Q275. What is the network and broadcast of 10.2.4.130/26?**

**Answer:** Network 10.2.4.128/26; broadcast 10.2.4.191; typical usable range .129–.190.

**Q276. What is the network and broadcast of 192.168.40.77/27?**

**Answer:** Network 192.168.40.64/27; broadcast 192.168.40.95; usable .65–.94.

**Q277. Which subnet contains 172.20.13.9/23?**

**Answer:** 172.20.12.0/23, broadcast 172.20.13.255, with ordinary usable hosts 172.20.12.1 through 172.20.13.254.

**Q278. What subnet contains 192.168.5.200/28?**

**Answer:** 192.168.5.192/28; broadcast .207; ordinary usable addresses .193–.206.

**Q279. What is the smallest conventional IPv4 subnet for 100 usable hosts?**

**Answer:** A /25 provides 128 total addresses and 126 typical usable host addresses.

**Q280. What is the smallest conventional IPv4 subnet for 13 usable hosts?**

**Answer:** A /28 provides 16 total IPv4 addresses and 14 typical usable addresses.

**Q281. What is the subnet mask and block size for /27?**

**Answer:** 255.255.255.224; blocks increment by 32 in the interesting octet.

**Q282. What is the subnet mask and block size for /29?**

**Answer:** 255.255.255.248; blocks increment by 8 in the interesting octet.

**Q283. What is the broadcast address of 198.51.100.130/27?**

**Answer:** 198.51.100.159; that /27 network begins at 198.51.100.128.

**Q284. Why can 192.0.2.35 not be a normal host in 192.0.2.32/30?**

**Answer:** It is the directed broadcast address; ordinary hosts are .33 and .34. RFC 3021 /31 point-to-point links are different.

**Q285. Why are two hosts with 192.168.1.20/24 and 192.168.2.20/24 not directly in the same IPv4 subnet?**

**Answer:** The /24 prefixes differ; they normally need routing to communicate between those networks.

**Q286. If 10.0.15.254 uses /21, what is its network prefix?**

**Answer:** 10.0.8.0/21; the /21 mask is 255.255.248.0.

**Q287. When finding IPv4 host count, why does the formula 2^h minus 2 have exceptions?**

**Answer:** A /31 point-to-point link can use both addresses under RFC 3021, while /32 identifies a single host route.

**Q288. What does wildcard 0.0.0.255 match when paired with 192.168.10.0?**

**Answer:** All IPv4 source addresses in 192.168.10.0/24; zero bits match, and one bits are ignored.

#### Switching, VLAN and security scenarios (13 questions)

**Q289. An access port has been assigned VLAN 40 but hosts still fail to communicate. Name three checks.**

**Answer:** Verify VLAN 40 exists, the port is operational and assigned correctly, the host IP/mask is correct, and any trunk carries VLAN 40 if crossing switches.

**Q290. Why might two correctly configured trunk ports still fail to carry VLAN 30?**

**Answer:** The VLAN may be excluded, inactive/missing, blocked by STP, mismatched in native VLAN treatment, or physically down.

**Q291. What should be examined first before applying BPDU Guard?**

**Answer:** Whether the interface truly connects only to an end host rather than to another switch or bridge.

**Q292. Which issue could trigger an err-disabled port after an extra PC is attached?**

**Answer:** Port security MAC-count violation, depending on configured violation mode.

**Q293. What is the main danger of using default interface as a rollback command?**

**Answer:** It resets all interface settings, potentially destroying correct VLAN, ACL, IP, EtherChannel or security configuration.

**Q294. Why is STP still useful with two physical links between the same switches?**

**Answer:** It avoids Layer 2 loops by blocking redundant paths unless links are intentionally bundled as a supported logical channel.

**Q295. What must match for LACP EtherChannel to form on two switches?**

**Answer:** Compatible member interfaces, speed/duplex and switching configuration, compatible LACP negotiation and supported device features.

**Q296. What happens if both LACP endpoints are passive?**

**Answer:** Neither initiates negotiation, so the expected LACP EtherChannel generally does not form.

**Q297. Why is enabling PortFast on a switch uplink risky?**

**Answer:** It bypasses normal edge-port transition expectations and may introduce transient loops; BPDU Guard can also disable that uplink.

**Q298. A VLAN SVI has an IP address but cannot reach another subnet on a Layer 2 switch. What may be needed?**

**Answer:** A correct switch ip default-gateway for management traffic, and a router that routes the VLANs.

**Q299. What is the difference between DHCP snooping trust and port security?**

**Answer:** DHCP snooping distinguishes legitimate server-facing ports and learns bindings; port security restricts MAC use on a switch port.

**Q300. Why might Dynamic ARP Inspection block valid hosts?**

**Answer:** Missing or incorrect DHCP snooping bindings or static ARP ACLs can make legitimate ARP packets appear untrusted.

**Q301. What is the security issue with permitting an unnecessary VLAN on a trunk?**

**Answer:** It extends that VLAN's Layer 2 reachability to more links/devices than needed, enlarging exposure and configuration risk.

#### Routing and end-to-end troubleshooting scenarios (12 questions)

**Q302. A router has a /16 static route and a /24 OSPF route matching the destination. Which matters first when forwarding?**

**Answer:** The installed /24 longest-prefix match wins; administrative distance is used when comparing candidate route sources for the same prefix.

**Q303. A remote subnet can receive pings but replies never arrive. What common requirement is missing?**

**Answer:** A correct return route, return-path ACL permission, or correct gateway on the remote network.

**Q304. An OSPF neighbor remains stuck in an incomplete state. Name checks before changing area design.**

**Answer:** Check physical/IP connectivity, subnet, area, network type, timers, authentication, MTU where applicable, and matching OSPF setup.

**Q305. Why is OSPF router interface priority not equivalent to OSPF route cost?**

**Answer:** Priority influences DR/BDR election on some networks; route cost contributes to shortest-path calculation.

**Q306. An EIGRP-learned route does not appear. What should you inspect?**

**Answer:** Neighbor table, AS number, participating interface/network selection, route policy, feasibility, and any better route source.

**Q307. A default route exists, but a specific destination is unreachable. Why may that happen?**

**Answer:** The path might have missing next-hop reachability, no return route, ACL/NAT issues, or a more-specific route to a bad next hop.

**Q308. Why should you ping the local gateway before troubleshooting Internet DNS?**

**Answer:** A failed local-gateway test points toward address, link or VLAN problems that DNS configuration cannot repair.

**Q309. What does traceroute help reveal that ping alone may not?**

**Answer:** The sequence of routed hops toward a destination, though firewalls and unresponsive hops can obscure the path.

**Q310. What is a routing loop?**

**Answer:** Packets circulate among routers because of inconsistent routing information until their TTL/hop limit expires.

**Q311. Why might administrative distance 90 not automatically beat a static /24 when the EIGRP prefix is /16?**

**Answer:** Longest-prefix match chooses between installed destination prefixes first; AD is used among competing routes of the same prefix.

**Q312. What is a passive interface in OSPF commonly used for?**

**Answer:** Advertising a connected network without forming an OSPF neighbor on that interface, such as a client-only LAN.

**Q313. Why can two adjacent routers ping but fail to form OSPF neighbors?**

**Answer:** IP reachability does not guarantee matching OSPF area, timers, authentication, network type, or enabled interfaces.

#### DHCP, DNS, NAT, wireless and application troubleshooting (14 questions)

**Q314. A DHCP client is on VLAN 10 and the DHCP server is on VLAN 20. What routing feature is commonly needed?**

**Answer:** A DHCP relay/helper address on the VLAN 10 client-facing routed interface, unless another relay or server design is in place.

**Q315. A Packet Tracer server assigns DHCP leases. Will a router always show those in show ip dhcp binding?**

**Answer:** No; router DHCP binding tables normally show leases from that router's own DHCP service, not leases managed by an external Server device.

**Q316. A client has a correct IP address but no hostname resolution. Which client setting is critical?**

**Answer:** Its configured DNS server address and whether that DNS service has the requested name record.

**Q317. A web page works by IP but not by its hostname. Which protocol likely needs inspection?**

**Answer:** DNS, including the client's DNS address, records and network reachability.

**Q318. Why can HTTP fail when an ICMP ping succeeds?**

**Answer:** The web service may be disabled, the port/ACL blocked, a URL/host mismatch may exist, or the server app may be broken.

**Q319. A PAT router has no entries after configuration. What should you generate before declaring a problem?**

**Answer:** Permitted inside-to-outside traffic that should match the NAT selection and reach a valid outside destination.

**Q320. What do ip nat inside and ip nat outside label?**

**Answer:** Which router interfaces are the inside and outside boundaries for NAT processing.

**Q321. Why doesn't an ACL used for NAT overload necessarily protect a network as a firewall?**

**Answer:** The NAT selection ACL chooses translated addresses; it does not automatically filter all inbound or outbound flows like an interface ACL.

**Q322. What is the difference between inside local and inside global in NAT?**

**Answer:** Inside local is the inside host's address as seen internally; inside global is the translated address representing that host externally.

**Q323. What three things should be verified when a Wi-Fi client sees an SSID but cannot connect?**

**Answer:** Security mode, exact passphrase/authentication, and compatible wireless adapter/AP configuration.

**Q324. A Wi-Fi client associates but cannot reach the gateway. What checks come next?**

**Answer:** Check IP assignment/DHCP, subnet, gateway, client isolation, router LAN interface and any ACL.

**Q325. Does hiding an SSID provide meaningful Wi-Fi security?**

**Answer:** No. It does not encrypt traffic or prevent a determined observer from learning the SSID.

**Q326. A WPA2-only Packet Tracer AP lacks WPA3 settings. What should you do?**

**Answer:** Use the strongest compatible mode consistent with the activity; don't claim the simulator implements WPA3 if it does not.

**Q327. Why does enabling DHCP on a wireless home router sometimes cause problems in a larger lab?**

**Answer:** It may introduce an unauthorized second DHCP server or overlapping scope; check the device's assigned LAN/router role.

#### Security and management decision questions (12 questions)

**Q328. Why is an enable secret preferred to a legacy enable password on IOS?**

**Answer:** Enable secret uses an IOS-supported one-way hash rather than the legacy plain-text password configuration style.

**Q329. Why isn't service password-encryption equivalent to secure password hashing?**

**Answer:** It weakly obfuscates some stored plaintext credentials, often using reversible Type 7 encoding.

**Q330. What is required before disabling Telnet in favor of SSH on a remote device?**

**Answer:** Confirm a working SSH service, reachable management IP, valid key/authentication and alternate console recovery if SSH breaks.

**Q331. What does the AAA acronym stand for in device administration?**

**Answer:** Authentication, Authorization and Accounting.

**Q332. Why is using privilege 15 for every account a poor default?**

**Answer:** It gives broad administrative power; privileges should match each account's authorized responsibilities.

**Q333. What is the main difference between a standard ACL and an extended IPv4 ACL?**

**Answer:** Standard ACLs generally match source IP; extended ACLs additionally match destination, protocol and transport ports.

**Q334. An extended ACL denies TCP destination port 80 but permits all other IP. Is HTTPS automatically blocked?**

**Answer:** No. HTTPS usually uses TCP 443 (or HTTP/3 over UDP 443), which this specific TCP/80 deny does not match.

**Q335. Why can adding a permit ip any any line make a restrictive ACL ineffective?**

**Answer:** It allows all otherwise unmatched IP traffic, potentially bypassing restrictions that should exist after the specific statements.

**Q336. What does an implicit ACL deny mean when only two permit entries exist?**

**Answer:** Any traffic matching neither permit entry is denied, even if no explicit deny line is visible.

**Q337. Why should you inspect VTY lines before setting transport input ssh?**

**Answer:** Different lines or AAA policies may control logins; changing only one line range can leave unintended access or lock out management.

**Q338. Which protocol is best for encrypted switch management: Telnet, TFTP or SSH?**

**Answer:** SSH; Telnet is normally unencrypted, and TFTP is for file transfers rather than interactive administration.

**Q339. Why shouldn't you clear logs while investigating a suspected device compromise?**

**Answer:** Logs may be the only preserved evidence of changes and may be required by the competition activity.

#### Commonly mistaken vocabulary and quiz distractors (12 questions)

**Q340. Is OSPF a Cisco-only routing protocol?**

**Answer:** No. OSPF is an open standards-based link-state IGP supported by many vendors.

**Q341. Are TCP and UDP port numbers part of the OSI Session layer?**

**Answer:** No. Port numbers belong to Layer 4, the Transport layer; the Session layer is Layer 5.

**Q342. Does EIGRP's default metric automatically use load and reliability?**

**Answer:** No. The classic default composite metric primarily uses bandwidth and delay; additional factors are not used by default.

**Q343. Does ICMP itself use TCP port 1?**

**Answer:** No. ICMPv4 is IP protocol number 1, not TCP or UDP port 1.

**Q344. Does a router normally forward IPv4 Layer 2 broadcasts between VLANs?**

**Answer:** No. Broadcast domains are separated by Layer 3 boundaries; specific relay features can forward selected requests.

**Q345. Is a switch solely a collision-domain device?**

**Answer:** No. Switch ports normally separate collision domains, but VLANs also divide broadcast domains.

**Q346. Is a subnet mask the same thing as a wildcard mask?**

**Answer:** No. Subnet masks mark prefix bits with ones; Cisco ACL wildcard bits use zeros for bits that must match.

**Q347. Is 192.168.0.0/16 the only private Class C-like range?**

**Answer:** No. RFC 1918 also reserves 10.0.0.0/8 and 172.16.0.0/12; modern subnetting is classless.

**Q348. Does a default gateway automatically supply DNS?**

**Answer:** No. The gateway routes off-subnet traffic; DNS resolution requires a DNS service/configuration.

**Q349. If ping returns no reply, can you conclude the host is down?**

**Answer:** No. Firewalls, ACLs, routing issues and ICMP filtering can prevent replies while the host is active.

**Q350. Does an interface shown as up/up guarantee the application service works?**

**Answer:** No. It confirms link/interface state, not DNS, HTTP, authentication, routing or higher-layer access.

**Q351. Is DNS always UDP 53 and never TCP?**

**Answer:** No. DNS can use UDP or TCP 53 depending on message size, transfers, and transport behavior.

#### Packet Tracer activity and troubleshooting literacy (10 questions)

**Q352. What is the difference between a .pkt file and a .pka activity?**

**Answer:** A .pkt is a saved topology/network; a .pka can include activity instructions, locked functions and assessment data.

**Q353. What can you infer from a Packet Tracer task that hides Check Results?**

**Answer:** Very little about scoring. You must verify stated requirements using normal device output and client tests.

**Q354. Why does a Packet Tracer completion percentage not necessarily equal official CyberPatriot score?**

**Answer:** The activity and competition course may apply separate assessment/submission rules; displayed local feedback is not always official score.

**Q355. What is the most useful next step after an IOS command returns Invalid input detected?**

**Answer:** Check the current CLI mode and model, use question-mark help, and verify whether that IOS simulator supports the feature.

**Q356. What is Simulation Mode most useful for?**

**Answer:** Observing packet exchanges and troubleshooting protocols such as ARP, ICMP, DNS, DHCP or HTTP across the topology.

**Q357. If the first ping fails and the second works, what common benign reason might explain it?**

**Answer:** ARP/neighbor discovery or initial convergence had not yet completed; recheck without assuming the first loss is a permanent fault.

**Q358. Why should you test at least one traffic flow that an ACL should allow and one it should deny?**

**Answer:** A single negative result cannot tell whether the ACL correctly filters only unwanted traffic or breaks everything.

**Q359. Why is Save As useful before changing a Packet Tracer activity?**

**Answer:** It can preserve a working copy for comparison/recovery when the activity allows it; follow competition file handling rules.

**Q360. What should be done after successful device running-config verification?**

**Answer:** Save via copy running-config startup-config when appropriate, and save/submit the Packet Tracer activity by the prescribed method.

**Q361. How should an unknown Cisco CLI option be approached during the quiz or practice lab?**

**Answer:** Identify the exact device and mode, consult supported syntax/help or authorized notes, and avoid guessing potentially destructive commands.

---

### Detailed networking concepts, diagrams in words, subnetting and protocol tables (integrated from the former general Cisco guide)

The content below preserves the explanatory networking theory from the former combined Cisco guide, so **all core concepts now live in this quiz guide** instead of forcing you to open the Packet Tracer procedures. The questions above remain the main searchable study path.

##### Networking basics

##### The OSI and TCP/IP models

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

##### Network devices

| Device | Layer | What it does |
|---|---|---|
| **Hub** | 1 | Repeats every signal out every port. Old and slow, because everyone shares the bandwidth. |
| **Switch** | 2 | Connects devices in the same network. Learns MAC addresses and sends each frame only out the right port. |
| **Router** | 3 | Connects *different* networks and picks the path for each packet using IP addresses. |
| **Access point (AP)** | 2 | Lets wireless devices join a wired network. |
| **Firewall** | 3 and up | Allows or blocks traffic based on rules. |

##### Addresses and traffic types

- A **MAC address** (Media Access Control) is the physical address burned into a network card. It is 48 bits, written as 12 hexadecimal digits, like `00:1A:2B:3C:4D:5E`. Switches use it. It only matters on the local network.
- An **IP address** (Internet Protocol) is the logical address you set in software, like `192.168.1.10`. Routers use it to move packets between networks.
- **Unicast** goes to one device. **Broadcast** goes to every device on the local network (the MAC address `FF:FF:FF:FF:FF:FF`). **Multicast** goes to a group of devices that asked for it.
- Routers do **not** forward broadcasts. Each router interface is the edge of a **broadcast domain**.

##### TCP vs UDP

| | TCP (Transmission Control Protocol) | UDP (User Datagram Protocol) |
|---|---|---|
| Connection | Sets up a connection first (three-way handshake: SYN, SYN-ACK, ACK) | No setup, just sends |
| Reliable? | Yes. Numbers the data, confirms delivery, resends lost pieces | No. Lost data stays lost |
| Speed | Slower, more overhead | Faster, less overhead |
| Used for | Web pages, email, file transfer, SSH | DNS lookups, DHCP, video calls, streaming, online games |

##### The protocols that make a network work

- **DHCP** (Dynamic Host Configuration Protocol) gives a device its IP address, subnet mask, default gateway and DNS server automatically. The four steps are **DORA**: **D**iscover (the client broadcasts "is there a DHCP server?"), **O**ffer (a server offers an address), **R**equest (the client asks for that address), **A**cknowledge (the server confirms).
- **DNS** (Domain Name System) turns names like `www.example.com` into IP addresses.
- **ARP** (Address Resolution Protocol) finds the MAC address that goes with an IPv4 address on the local network. The question is a broadcast ("who has 192.168.1.1?"), the answer is unicast.
- **NAT** (Network Address Translation) lets many devices with private addresses share one public address on the internet. The router rewrites the addresses as traffic passes through.
- **ICMP** (Internet Control Message Protocol) carries error and test messages. `ping` and `traceroute` use it.
- The **default gateway** is the router address a device sends traffic to when the destination is on a *different* network. If it's wrong or missing, a PC can reach its own network but nothing beyond it.

#### IPv4 addressing and subnetting

An IPv4 address is **32 bits**, written as four numbers (octets) from 0 to 255: `192.168.1.10`. The **subnet mask** says which part is the **network** and which part is the **host** (the device).

##### Binary in one minute

Each octet is 8 bits. The bit values, left to right, are:

| 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |
|---|---|---|---|---|---|---|---|

Add up the values where the bit is 1. For example, `11000000` = 128 + 64 = **192**, and `10101100` = 128 + 32 + 8 + 4 = **172**.

##### Classes (historical) and special ranges

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

##### CIDR and subnet masks

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

##### Step-by-step: find the network, broadcast and hosts

1. Find the **interesting octet**: the one where the mask is not 255 and not 0.
2. **Block size** = 256 − the mask value in that octet.
3. List the multiples of the block size (0, block, 2 × block, …). The **network address** is the biggest multiple that is less than or equal to the IP's value in that octet. Octets after it become 0.
4. The **broadcast address** is the next network address minus 1. Octets after the interesting one become 255.
5. **First host** = network address + 1. **Last host** = broadcast address − 1.
6. **Number of hosts** = 2^(32 − prefix) − 2.

##### Worked example 1: 192.168.10.77/26

- /26 = mask `255.255.255.192`. The interesting octet is the 4th.
- Block size = 256 − 192 = **64**. Networks: .0, .64, .128, .192.
- 77 falls between 64 and 128, so the network is **192.168.10.64**.
- Broadcast = 128 − 1 = **192.168.10.127**.
- Hosts: **192.168.10.65** to **192.168.10.126**. That is 2^6 − 2 = **62** hosts.

##### Worked example 2: 172.16.45.200/20

- /20 = mask `255.255.240.0`. The interesting octet is the 3rd.
- Block size = 256 − 240 = **16**. Networks in the 3rd octet: 0, 16, 32, 48, …
- 45 falls between 32 and 48, so the network is **172.16.32.0**.
- Broadcast: the next network is 172.16.48.0, so the broadcast is **172.16.47.255**.
- Hosts: **172.16.32.1** to **172.16.47.254**. That is 2^12 − 2 = **4,094** hosts.

##### Worked example 3: 10.1.1.5/30

- /30 = mask `255.255.255.252`. Block size = **4**. Networks: .0, .4, .8, …
- Network **10.1.1.4**, broadcast **10.1.1.7**, hosts **10.1.1.5** and **10.1.1.6** (2 hosts).
- A /30 is common on a link between two routers, because the link needs exactly two addresses.

##### Picking a mask for a number of hosts

Find the smallest number of host bits where 2^(host bits) − 2 is at least the number of hosts you need. Example: you need 50 hosts. 2^5 − 2 = 30 is too small, 2^6 − 2 = 62 is enough. That's 6 host bits, so the prefix is 32 − 6 = **/26**.

##### IPv6 basics

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

#### Common ports

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

### Additional short-answer questions — commonly missed network mechanics

The following new questions are original and reinforce the network topics emphasized by public competition checklists and Cisco foundational materials.

**Q362. Which IOS command displays locally known IPv4-to-MAC address mappings?**

**Answer:** show ip arp (or show arp on supporting platforms). This shows the router/device ARP cache, not DNS records.

**Q363. Which IOS command helps identify learned switch MAC addresses and their ports?**

**Answer:** show mac address-table; learned entries can be VLAN-specific.

**Q364. Which configuration change allows a supported Layer 3 switch to route between SVIs?**

**Answer:** ip routing in global configuration mode, together with correct VLAN interfaces, routes and operational links.

**Q365. What is the difference between a port assigned to an access VLAN and a trunk VLAN?**

**Answer:** An access port normally carries one data VLAN without a tag; a trunk carries multiple VLANs using 802.1Q tagging.

**Q366. Why does a single successful local ping not prove an end-to-end website works?**

**Answer:** It checks only one reachability path; DNS, TCP/HTTP service, ACL and application state may still fail.

**Q367. What does a duplex mismatch often cause on an Ethernet link?**

**Answer:** Poor performance, late collisions or input errors on legacy half-duplex sides, and retransmissions; modern auto-negotiation should be checked.

**Q368. Why is fiber often preferred between distant buildings?**

**Answer:** It provides electrical isolation and resistance to electromagnetic interference, with higher distance capabilities depending on optics.

**Q369. What is the purpose of a Link Aggregation Control Protocol (LACP) bundle?**

**Answer:** Combine compatible physical links into one logical channel; LACP negotiates membership rather than merely connecting extra cables.

**Q370. What happens if both LACP peers are configured passive?**

**Answer:** Neither initiates negotiation, so a LACP bundle usually does not form.

**Q371. What does an EtherChannel Port-channel interface represent?**

**Answer:** The logical interface bundling member physical links so switching/routing sees a single aggregate link.

**Q372. If two PCs in one VLAN fail to communicate, should you add a default route first?**

**Answer:** No. Check physical connection, access VLAN, port security, host IP/mask and spanning-tree forwarding before changing routing.

**Q373. What is the primary advantage of RSTP over traditional STP?**

**Answer:** It converges faster after many topology changes while still preventing Layer 2 loops.

**Q374. Why is a switch port's configured native VLAN a security and connectivity concern?**

**Answer:** Untagged frames can be classified unexpectedly if the connected trunk endpoints disagree, potentially leaking or disrupting traffic.

**Q375. What information does an IPv4 client get from DHCP besides its address?**

**Answer:** Usually subnet mask, default gateway and DNS servers, as allowed by the DHCP server configuration.

**Q376. What is the purpose of DHCP snooping's trusted interface designation?**

**Answer:** Permit DHCP server responses only from approved server-facing paths, reducing rogue DHCP server risks.

**Q377. Can a router's DHCP binding table prove leases assigned by a separate Packet Tracer server?**

**Answer:** No. Check the server's DHCP service/client IP configuration; the router's own binding table may be empty.

**Q378. What is the difference between IPv6 Router Advertisement and DHCPv6?**

**Answer:** RA announces routers/prefix information and flags; DHCPv6 supplies addresses and/or configuration as used by the network.

**Q379. Why do IPv6 clients still require Neighbor Discovery when they know the destination IPv6 address?**

**Answer:** They need link-layer neighbor resolution and/or router information; IPv6 does not use ARP.

**Q380. How can an ACL with a permit for TCP 80 still block other services?**

**Answer:** The implicit deny blocks unmatched traffic unless additional permit statements allow them.

**Q381. Why might an allowed ACL entry appear to have zero matches even when a task works?**

**Answer:** The flow may use a different interface/direction, or the simulator may not implement complete counter behavior.

**Q382. What is the main difference between NAT overload and an interface ACL?**

**Answer:** PAT/NAT overload translates addresses and transport ports; an interface ACL determines whether specified packet flows are permitted.

**Q383. What is the risk of changing every remote line to transport input ssh without first checking SSH service?**

**Answer:** It can lock out legitimate remote administration if SSH keys, IP reachability or credentials are not working.

**Q384. Which common standard port does BGP use, and how does it differ from OSPF transport?**

**Answer:** BGP normally uses TCP 179; OSPF uses IP protocol 89 directly, not a TCP/UDP port.

**Q385. How can a correct DNS A record still fail to provide name resolution?**

**Answer:** The client may use the wrong DNS server, be unable to route to it, or be blocked by a firewall/ACL; record correctness alone is insufficient.


---

<a id="stage-6"></a>
## Part 6 — Final Review and Sources

> [!TIP]
> ✅ **Final review:** Recheck objectives, answers, configuration and any submission rules.


Review all missed terms, official course modules and the permitted reference policy before any assessment.

### Last-minute quiz review checklist

- [ ] OSI Layers 1–7, major PDUs, TCP/IP 4-layer mapping
- [ ] Hub, switch, router, access point, firewall, modem and NIC roles
- [ ] MAC versus IP, unicast/broadcast/multicast/anycast
- [ ] /24 through /30 block sizes, network/broadcast/host counts and /31 exception
- [ ] IPv4 private ranges, loopback, link-local, gateway, CIDR and wildcard masks
- [ ] IPv6 notation, link-local, SLAAC, RA, NDP, no broadcast
- [ ] TCP/UDP; DHCP DORA; ARP/DNS/NAT/PAT/ICMP; common application services
- [ ] Important ports: 20/21, 22, 23, 25, 53, 67/68, 69, 80, 110/143, 123, 161/162, 179, 389, 443, 445, 587, 993/995, 3389
- [ ] VLAN/trunk/SVI, router-on-a-stick, STP/BPDU Guard, port security, LACP
- [ ] Static/default routes, longest prefix, administrative distance, RIP/OSPF/EIGRP/BGP
- [ ] Standard versus extended ACL, implicit deny, direction and wildcard
- [ ] AAA, SSH versus Telnet, IDS/IPS, VPN, 802.1X, RADIUS/TACACS+, Wi-Fi WPA2/WPA3
- [ ] Cisco IOS mode prompts and common show/configure commands
- [ ] Protocol and standards organizations: IEEE, IETF, IANA, ICANN, IAB, IRTF, ISOC, ITU-T
- [ ] Scenario skills: explain **why** a host cannot reach a gateway, server, DNS record, other VLAN or remote network
- [ ] Current official module scope, actual assessment rules and whether outside references are permitted

**This is original practice, not an official or leaked answer key.** Review the assigned NetAcad modules before using these notes to study.

---

### Where to study more (public references)

1. **Official first:** [CyberPatriot current competition challenges](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round), [CyberPatriot training materials](https://www.uscyberpatriot.org/competition/training-materials), [Cisco NetAcad CyberPatriot Content Course](https://www.netacad.com/courses/cyberpatriot-content). The official Content Course should be used for the exact assigned module material.
2. **Community starting point:** [Networking for CyberPatriot Quizlet](https://quizlet.com/846446350/networking-for-cyberpatriot-flash-cards/) (protocols, OSI/TCP models, standards bodies; independently verify details), [CyberPatriot Study Guide Quizlet](https://quizlet.com/212436050/cyber-patriot-study-guide-flash-cards/) (additional historical study terms; not an official answer bank).
3. **CyberPatriot training overviews:** [CCA CyberPatriot](https://sites.google.com/view/cca-cyberpatriot/program-info/cyberpatriot), [Cyber4Youth CyberPatriot Cisco training](https://cyber4youth.com/learn/cyberpatriot) (independent), [Discovery Middle School CyberPatriot training materials](https://dms.madisoncity.k12.al.us/cyberpatriot-training-materials).
4. **Technical fact-checking:** [Cisco support documentation](https://www.cisco.com/c/en/us/support/), [Cisco routing administrative distance](https://www.cisco.com/c/en/us/support/docs/ip/border-gateway-protocol-bgp/15986-admin-distance.html), [IANA port-number registry](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml).

**Source note:** These questions and answers are **original summaries**, built around common topics appearing in public study materials and Cisco's documented behavior. Do not assume student-made flashcards are always accurate. **Not** a reproduction of NetAcad's protected quizzes or an endorsement of any third-party site.

---

### Related guides in this repository

- [Cisco CLI, concepts and Packet Tracer](packet-tracer.md)
- [Cisco switching, routing and troubleshooting](packet-tracer.md#22-consolidated-troubleshooting-reference)
- [Cisco folder index](../README.md)

---

