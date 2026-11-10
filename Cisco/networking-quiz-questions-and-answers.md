# Cisco networking quiz — common questions and short answers

**Purpose:** A searchable, open-ended **question → correct answer** bank for studying CyberPatriot Cisco **multiple-choice concepts**. There are **no A–D answer choices**, no proprietary NetAcad test questions, and no Packet Tracer lab exercises here. Read the question, try to answer from memory, then check the answer. During permitted reference-based study, press **Ctrl+F** to find a term.

> [!IMPORTANT]
> **Official training takes priority.** The CyberPatriot XIX (2026–27) [round-specific topic schedule](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round) identifies the NetAcad modules that count in each round. These questions are independently written practice, not official quiz wording or an answer key. The exact live quiz, question count and permitted references must follow the current rules and competition instructions, not a third-party web page.

## CyberPatriot XIX: which NetAcad modules to study?

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

## Jump to topic

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

## Network basics and core vocabulary

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

## OSI model, TCP/IP model, and data flow

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

## Network devices, physical media, and Ethernet

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

## IPv4 addressing and subnetting

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

## IPv6 basics

**Q077. How many bits are in an IPv6 address?**

**Answer:** 128 bits, commonly represented as eight groups of hexadecimal digits.

**Q078. What does :: mean in IPv6 notation?**

**Answer:** Compression of one contiguous run of all-zero 16-bit groups; it can appear only once in an address.

**Q079. What is an IPv6 link-local address?**

**Answer:** An address typically from fe80::/10 for communication on the same link; it is not routed across normal IPv6 routers.

**Q080. What is an IPv6 global unicast address?**

**Answer:** A routable unicast address, commonly allocated from 2000::/3.

**Q081. What is an IPv6 unique local address?**

**Answer:** A privately scoped IPv6 address from fc00::/7, commonly using locally assigned fd00::/8 addresses.

**Q082. What is the IPv6 loopback address?**

**Answer:** ::1/128.

**Q083. Does IPv6 use broadcast addresses?**

**Answer:** No. IPv6 uses multicast and unicast (including anycast) instead of broadcast.

**Q084. What is NDP?**

**Answer:** Neighbor Discovery Protocol, an ICMPv6-based mechanism for discovering neighbors, routers and link information; it replaces ARP's main job.

**Q085. What are SLAAC and DHCPv6?**

**Answer:** SLAAC builds IPv6 addresses using router advertisements; DHCPv6 can provide addresses and/or additional configuration, depending on network design.

**Q086. What are router advertisements (RA)?**

**Answer:** ICMPv6 messages from routers that communicate prefixes, default-router availability and configuration flags.

**Q087. What is an IPv6 prefix length?**

**Answer:** The number of leading network bits, written /n; /64 is common for LAN subnets supporting SLAAC.

**Q088. What is IPv6 hop limit?**

**Answer:** The IPv6 equivalent of IPv4 TTL, decreased by routers to prevent indefinite circulation.

## TCP, UDP, applications and common protocols

**Q089. How do TCP and UDP differ?**

**Answer:** TCP is connection-oriented and provides ordered, retransmitted byte-stream delivery; UDP is connectionless, with minimal transport guarantees.

**Q090. What is the TCP three-way handshake?**

**Answer:** SYN, SYN-ACK, ACK, establishing a TCP connection.

**Q091. What are TCP sequence numbers and acknowledgments for?**

**Answer:** Tracking received byte ranges and enabling loss recovery and ordered delivery.

**Q092. What is a TCP/UDP port number?**

**Answer:** A 16-bit identifier used by transport protocols to distinguish services and application endpoints.

**Q093. What are well-known, registered, and dynamic/private ports?**

**Answer:** 0–1023 well-known/system, 1024–49151 registered/user, and 49152–65535 dynamic/private.

**Q094. What is DNS?**

**Answer:** Domain Name System, which resolves names and stores records such as A, AAAA, MX and CNAME; usually UDP 53, sometimes TCP 53.

**Q095. What is an A record versus an AAAA record?**

**Answer:** A maps a name to an IPv4 address; AAAA maps a name to an IPv6 address.

**Q096. What is an MX record?**

**Answer:** A DNS record identifying mail exchangers for a domain.

**Q097. What is DHCP?**

**Answer:** Dynamic Host Configuration Protocol, which supplies clients with IP configuration such as address, subnet mask, gateway and DNS servers.

**Q098. What are the DHCP DORA steps?**

**Answer:** Discover → Offer → Request → Acknowledge, the common initial IPv4 lease process.

**Q099. Which UDP ports does DHCPv4 normally use?**

**Answer:** Server 67 and client 68.

**Q100. What is BOOTP?**

**Answer:** Bootstrap Protocol, a predecessor of DHCP used to provide startup IP information and boot-related configuration.

**Q101. What is HTTP and its usual port?**

**Answer:** Hypertext Transfer Protocol for web requests/responses, typically TCP 80.

**Q102. What is HTTPS and its usual port?**

**Answer:** HTTP protected by TLS, normally TCP 443; HTTP/3 may use QUIC over UDP 443.

**Q103. What is FTP and which ports matter?**

**Answer:** File Transfer Protocol, traditionally TCP 21 for control and TCP 20 for active-mode data; passive-mode data uses negotiated ports.

**Q104. What is TFTP?**

**Answer:** Trivial File Transfer Protocol, a simple UDP-based file transfer protocol that initially uses UDP 69; it has no built-in authentication or encryption.

**Q105. What is SSH and its standard port?**

**Answer:** Secure Shell, an encrypted remote access protocol typically using TCP 22.

**Q106. What is Telnet and why is it discouraged?**

**Answer:** A remote terminal protocol normally using TCP 23; classic Telnet transmits credentials and data without encryption.

**Q107. What is SMTP?**

**Answer:** Simple Mail Transfer Protocol for email transfer; commonly TCP 25 for server-to-server and TCP 587 for message submission.

**Q108. What are POP3 and IMAP?**

**Answer:** POP3 normally retrieves/downloads email (TCP 110, TLS TCP 995); IMAP synchronizes messages on a server (TCP 143, TLS TCP 993).

**Q109. What are SNMP and SNMP traps?**

**Answer:** Simple Network Management Protocol manages/monitors devices, normally UDP 161; notifications/traps commonly use UDP 162.

**Q110. What is NTP?**

**Answer:** Network Time Protocol, synchronizing device clocks, normally UDP 123.

**Q111. What is Syslog?**

**Answer:** A system for forwarding log messages to a logging service, often UDP 514; modern deployments also use TCP/TLS variants.

**Q112. What is RDP and its common port?**

**Answer:** Microsoft Remote Desktop Protocol, typically TCP and/or UDP 3389.

**Q113. What is LDAP and LDAPS?**

**Answer:** Lightweight Directory Access Protocol, commonly TCP/UDP 389; LDAP over TLS is commonly TCP 636.

**Q114. What is SMB and its modern direct-hosted port?**

**Answer:** Server Message Block for file/printer shares, typically TCP 445.

**Q115. What is ICMP used for?**

**Answer:** Network diagnostics and control/error messages, such as echo requests and replies; ICMP itself has no TCP/UDP port number.

**Q116. What is ARP?**

**Answer:** Address Resolution Protocol, used on IPv4 local networks to find a MAC address for a known on-link IPv4 address.

**Q117. What is PPP?**

**Answer:** Point-to-Point Protocol, a Layer 2 protocol for direct serial or other point-to-point connections.

**Q118. What is PPPoE?**

**Answer:** PPP over Ethernet, often used by broadband providers to carry PPP sessions over Ethernet links.

## DNS, DHCP, NAT, and traffic delivery

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

## Switching, VLANs, trunks, and Layer 2 security

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

## Routing, OSPF, EIGRP, RIP, and BGP

**Q154. What is a routing table?**

**Answer:** A table of destination prefixes and next hops or interfaces a router uses to forward IP traffic.

**Q155. What is a static route?**

**Answer:** A route manually configured by an administrator rather than learned from a dynamic routing protocol.

**Q156. What is a dynamic routing protocol?**

**Answer:** A protocol through which routers exchange reachability information and adapt to topology changes.

**Q157. What is an IGP?**

**Answer:** Interior Gateway Protocol, used for routing within one administrative routing domain, such as OSPF, IS-IS, RIP, or EIGRP.

**Q158. What is an EGP?**

**Answer:** Exterior Gateway Protocol, typically referring to BGP for exchanging reachability between autonomous systems.

**Q159. What is RIP?**

**Answer:** Routing Information Protocol, a distance-vector IGP using hop count as its metric; RIPv2 supports classless routes.

**Q160. What is the maximum usable hop count in RIP?**

**Answer:** 15 hops; 16 means unreachable.

**Q161. What is OSPF?**

**Answer:** Open Shortest Path First, a link-state IGP using link-state advertisements and shortest-path calculations to build routes.

**Q162. What metric does OSPF commonly use?**

**Answer:** Cost, often derived from interface bandwidth under Cisco configurations; total path cost is the sum of link costs.

**Q163. What is OSPF area 0?**

**Answer:** The backbone area to which other normal OSPF areas connect, directly or by supported virtual-link design.

**Q164. What is an OSPF LSA?**

**Answer:** Link-State Advertisement containing topology or routing information used in building the OSPF link-state database.

**Q165. What are an OSPF DR and BDR?**

**Answer:** Designated Router and Backup Designated Router, elected on certain multiaccess network types to reduce adjacency overhead.

**Q166. What is EIGRP?**

**Answer:** Enhanced Interior Gateway Routing Protocol, a Cisco-originated advanced distance-vector IGP using the DUAL algorithm.

**Q167. What metric does EIGRP use by default?**

**Answer:** A composite metric primarily based on minimum path bandwidth and cumulative interface delay; other factors exist but are not included by default.

**Q168. What is DUAL?**

**Answer:** Diffusing Update Algorithm, used by EIGRP to determine loop-free routes and alternatives.

**Q169. What is BGP?**

**Answer:** Border Gateway Protocol, a path-vector interdomain routing protocol commonly used between autonomous systems on the Internet.

**Q170. What is an autonomous system (AS)?**

**Answer:** A set of networks governed by a common routing policy, identified by an autonomous system number for BGP.

**Q171. What is administrative distance?**

**Answer:** A Cisco preference value for route sources when competing routes to the same prefix exist; lower is normally preferred.

**Q172. What are common default Cisco administrative distances?**

**Answer:** Connected 0, static 1, internal EIGRP 90, OSPF 110, RIP 120; configurable values can differ.

**Q173. What is longest prefix match?**

**Answer:** The forwarding choice of the most specific matching installed route, such as preferring a /24 over a /16 for the same destination.

**Q174. What is a next hop?**

**Answer:** The neighboring router/address to which a packet is sent on the way toward its destination.

**Q175. What is route convergence?**

**Answer:** The process by which routers update their topology/routing information after a change until the network reaches a consistent state.

## Network security and wireless concepts

**Q176. What are the CIA triad's three goals?**

**Answer:** Confidentiality (prevent unauthorized disclosure), Integrity (prevent unauthorized alteration), and Availability (keep services accessible when needed).

**Q177. What is the principle of least privilege?**

**Answer:** Grant each user, device or service only the permissions necessary for its authorized job.

**Q178. What is an ACL?**

**Answer:** Access Control List, ordered permit/deny rules used to filter traffic or control access on supported devices.

**Q179. What is the difference between standard and extended Cisco IPv4 ACLs?**

**Answer:** Standard ACLs primarily match source IPv4 addresses; extended ACLs can match source/destination, protocol, and transport ports.

**Q180. What does implicit deny mean in an ACL?**

**Answer:** Traffic that matches none of the permit statements is denied at the end of the ACL.

**Q181. What is ACL wildcard-mask logic?**

**Answer:** A 0 bit means match the corresponding address bit; a 1 bit means ignore it.

**Q182. What is defense in depth?**

**Answer:** Using multiple complementary security controls so a single failure does not expose the entire system.

**Q183. What is segmentation?**

**Answer:** Dividing networks into distinct zones or VLANs with controlled routing and filtering to limit unnecessary access.

**Q184. What is a DMZ?**

**Answer:** A network zone for externally reachable services separated by policy from internal systems.

**Q185. What is an IDS versus an IPS?**

**Answer:** An intrusion detection system alerts on suspicious activity; an intrusion prevention system can actively block it.

**Q186. What is a VPN?**

**Answer:** A virtual private network providing an encrypted or otherwise protected logical tunnel over another network, depending on the protocol.

**Q187. What is 802.1X?**

**Answer:** Port-based network access control using EAP with an authenticator such as a switch/AP and usually a back-end authentication server.

**Q188. What is RADIUS?**

**Answer:** A centralized AAA protocol, often used for network access authentication and accounting; common UDP ports are 1812 and 1813.

**Q189. What is TACACS+?**

**Answer:** A Cisco-originated AAA protocol typically using TCP 49 and separating authentication, authorization and accounting.

**Q190. What is AAA?**

**Answer:** Authentication establishes identity; Authorization determines permissions; Accounting records activity.

**Q191. What is SSH preferred over Telnet?**

**Answer:** SSH encrypts authentication and management traffic; classic Telnet exposes them in plaintext.

**Q192. What is DHCP snooping?**

**Answer:** A Layer 2 security feature that blocks untrusted DHCP server messages and can build client binding data.

**Q193. What is Dynamic ARP Inspection (DAI)?**

**Answer:** A switch protection that checks ARP packets against trusted bindings or ARP ACLs to reduce ARP spoofing.

**Q194. What is ARP spoofing?**

**Answer:** Sending falsified ARP information to redirect local IPv4 traffic, possibly enabling interception or disruption.

**Q195. What is a rogue access point?**

**Answer:** An unauthorized wireless AP that can bypass network controls or attract clients.

**Q196. What is a wireless SSID?**

**Answer:** Service Set Identifier, the name identifying a Wi-Fi network; hiding it is not reliable security.

**Q197. What is WPA2 versus WPA3?**

**Answer:** Wi-Fi security generations; WPA3-Personal uses SAE, while WPA2-Personal commonly uses a pre-shared-key handshake.

**Q198. Why is WEP insecure?**

**Answer:** Its legacy cryptographic design has practical weaknesses; it should not be used to secure modern Wi-Fi.

**Q199. What is 802.11?**

**Answer:** The IEEE family of wireless LAN standards used by Wi-Fi, including revisions such as 802.11n/ac/ax/be.

**Q200. What is a VLAN hopping attack?**

**Answer:** An attack exploiting trunking or VLAN-tag handling weaknesses to reach traffic in unintended VLANs; careful trunk and access-port settings help mitigate it.

## Cisco IOS and Packet Tracer terminology

**Q201. What is Cisco IOS?**

**Answer:** Cisco Internetwork Operating System, the software used to configure and operate many Cisco routers and switches.

**Q202. What are Cisco user EXEC and privileged EXEC modes?**

**Answer:** User EXEC usually shows `>` with limited commands; privileged EXEC shows `#` and allows broader show and administration commands.

**Q203. What does `enable` do?**

**Answer:** Moves from user EXEC to privileged EXEC mode when authorized; it may request the configured enable secret.

**Q204. What does `configure terminal` do?**

**Answer:** Enters global configuration mode so device configuration can be changed.

**Q205. What do `(config)#` and `(config-if)#` indicate?**

**Answer:** Global configuration mode and interface configuration mode, respectively.

**Q206. What does `exit` versus `end` do?**

**Answer:** `exit` backs out one configuration level; `end` returns directly to privileged EXEC.

**Q207. What does `show running-config` display?**

**Answer:** The current active configuration held in memory.

**Q208. What does `show startup-config` display?**

**Answer:** The saved configuration used at startup, when one is stored.

**Q209. How do you save the current configuration on typical IOS?**

**Answer:** Use `copy running-config startup-config` from privileged EXEC after verifying settings.

**Q210. What does `show ip interface brief` reveal?**

**Answer:** Interface addresses and operational/line-protocol status; it helps identify down or administratively down interfaces.

**Q211. What does `administratively down` mean?**

**Answer:** The interface was manually disabled, often with `shutdown`.

**Q212. What does `no shutdown` do?**

**Answer:** Removes the administrative shutdown setting on a selected interface; it does not fix physical cable/VLAN problems.

**Q213. What does `show vlan brief` display?**

**Answer:** The switch's VLAN IDs/names and commonly associated access ports.

**Q214. What does `show interfaces trunk` display?**

**Answer:** Trunk links and information such as allowed VLANs and tagging behavior on supported switches.

**Q215. What does `show ip route` display?**

**Answer:** The IPv4 routing table, including connected and learned routes.

**Q216. What does `show access-lists` display?**

**Answer:** Configured ACL entries and, on supported platforms, match counters.

**Q217. What is `service password-encryption`?**

**Answer:** A Cisco IOS feature that obfuscates certain plaintext password representations; it is not equivalent to strong modern password hashing.

**Q218. What is an `enable secret`?**

**Answer:** A privileged EXEC password stored using a one-way hash type supported by the IOS release; generally preferable to legacy `enable password`.

**Q219. What does `line vty` configure?**

**Answer:** Settings for virtual terminal lines used by remote administrative sessions.

**Q220. What does `transport input ssh` do?**

**Answer:** Allows SSH on selected VTY lines while excluding Telnet for those lines.

**Q221. What does `show cdp neighbors` do?**

**Answer:** Lists directly connected Cisco Discovery Protocol neighbors when CDP is enabled.

**Q222. What does `show logging` do?**

**Answer:** Displays device log messages and configured logging information on supported IOS.

**Q223. What is Packet Tracer?**

**Answer:** Cisco's network simulation tool for designing, configuring and troubleshooting virtual network devices; not all real IOS features are simulated.

## Standards organizations and network governance

**Q224. What does IEEE stand for and what does it standardize?**

**Answer:** Institute of Electrical and Electronics Engineers; it publishes many networking standards, including Ethernet (802.3) and Wi-Fi (802.11).

**Q225. What does IETF stand for?**

**Answer:** Internet Engineering Task Force, which develops Internet technical standards and publishes many RFCs.

**Q226. What is an RFC?**

**Answer:** Request for Comments, a publication in the Internet technical document series; RFCs may be standards, informational, experimental or other types.

**Q227. What is the IAB?**

**Answer:** Internet Architecture Board, which provides architecture oversight and guidance for Internet standards work.

**Q228. What is the IRTF?**

**Answer:** Internet Research Task Force, which coordinates longer-term Internet research groups.

**Q229. What is ISOC?**

**Answer:** Internet Society, a nonprofit supporting an open, globally connected Internet and related communities.

**Q230. What is IANA?**

**Answer:** Internet Assigned Numbers Authority functions, coordinating global Internet numbers and protocol parameter registries within ICANN's ecosystem.

**Q231. What is ICANN?**

**Answer:** Internet Corporation for Assigned Names and Numbers, which coordinates key Internet naming and addressing systems and performs IANA functions through its affiliate.

**Q232. What are TIA and EIA associated with?**

**Answer:** Telecommunications Industry Association and former Electronic Industries Alliance; historically important in structured cabling and telecommunications standards.

**Q233. What is ITU-T?**

**Answer:** The ITU Telecommunication Standardization Sector, which develops telecommunications standards and recommendations.

## Short scenario questions: choose the concept

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

## High-speed reference: common port numbers

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

## Fast contrasts often used as distractors

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

## Where to study more (public references)

1. **Official first:** [CyberPatriot current competition challenges](https://www.uscyberpatriot.org/competition/current-competition/challenges-by-round), [CyberPatriot training materials](https://www.uscyberpatriot.org/competition/training-materials), [Cisco NetAcad CyberPatriot Content Course](https://www.netacad.com/courses/cyberpatriot-content). The official Content Course should be used for the exact assigned module material.
2. **Community starting point:** [Networking for CyberPatriot Quizlet](https://quizlet.com/846446350/networking-for-cyberpatriot-flash-cards/) (protocols, OSI/TCP models, standards bodies; independently verify details), [CyberPatriot Study Guide Quizlet](https://quizlet.com/212436050/cyber-patriot-study-guide-flash-cards/) (additional historical study terms; not an official answer bank).
3. **CyberPatriot training overviews:** [CCA CyberPatriot](https://sites.google.com/view/cca-cyberpatriot/program-info/cyberpatriot), [Cyber4Youth CyberPatriot Cisco training](https://cyber4youth.com/learn/cyberpatriot) (independent), [Discovery Middle School CyberPatriot training materials](https://dms.madisoncity.k12.al.us/cyberpatriot-training-materials).
4. **Technical fact-checking:** [Cisco support documentation](https://www.cisco.com/c/en/us/support/), [Cisco routing administrative distance](https://www.cisco.com/c/en/us/support/docs/ip/border-gateway-protocol-bgp/15986-admin-distance.html), [IANA port-number registry](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml).

**Source note:** These questions and answers are **original summaries**, built around common topics appearing in public study materials and Cisco's documented behavior. Do not assume student-made flashcards are always accurate. **Not** a reproduction of NetAcad's protected quizzes or an endorsement of any third-party site.

## Related guides in this repository

- [Cisco CLI, concepts and Packet Tracer](cisco-networking.md)
- [Cisco switching, routing and troubleshooting](cisco-switch-routing-troubleshooting.md)
- [Cisco folder index](README.md)
