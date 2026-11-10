# Packet Tracer and network fundamentals

## Build an addressing table

For each device record interface, IPv4 or IPv6 address, prefix, gateway and VLAN. Example: 192.0.2.77/26 is in 192.0.2.64/26, with broadcast .127 and usable hosts .65–.126. The /26 block size is 64, so .77 lies in the .64–.127 block.

## Check the topology

Confirm physical links and interface state, then VLAN membership, trunk settings, gateways and routes. Use read-only show ip interface brief, show vlan brief and show ip route where supported. Compare observed output to the task diagram.

## Management and verification

Restrict management access to authorized administrators and intended interfaces according to the brief. Check permitted connectivity in order: local link, gateway, remote subnet, then name resolution. Save only after verifying the expected behavior and follow the task’s submission instructions.
