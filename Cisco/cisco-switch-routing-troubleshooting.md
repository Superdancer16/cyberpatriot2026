# Cisco Packet Tracer: VLANs, ACLs, port security, and troubleshooting

Use alongside the [main Cisco guide](cisco-networking.md). These are **manual examples**, not scripts. Commands vary by model and simulator image. Preserve the Packet Tracer activity file using **File → Save As** when allowed; obey the specific activity requirements.

## 1. Begin with a baseline

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

## 2. PC cannot reach its gateway: check access VLAN and trunk

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

## 3. Trunk missing a VLAN

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

## 4. Inter-VLAN routing via router-on-a-stick

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

## 5. Port security: identify a legitimate edge port first

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

## 6. STP / BPDU Guard: edge ports are not uplinks

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

## 7. Extended ACLs: direction and wildcard mask

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

## 8. DHCP, DHCP snooping and DAI

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

## 9. SSH management and save procedure

- [ ] Confirmed approved access, remote management authentication and final connections.

~~~text
show ip ssh
show running-config
show startup-config
show logging
~~~

See [main Cisco guide: configure SSH](cisco-networking.md#configure-ssh) for complete hostname, RSA key, VTY/local authentication and SSH transport steps. Use the actual authorized credentials and device capabilities.

After successful verification, save:

~~~text
copy running-config startup-config
~~~

**Do not save a broken state just because commands were accepted.**

## Fast diagnosis table

| Symptom | Check first | Check next |
|---|---|---|
| Link is down | Cable and shutdown status | Connected interface/device |
| PCs in one VLAN cannot talk | PC IP/mask and access VLAN | Trunks, port security, STP |
| PC cannot ping gateway | VLAN and router subinterface | ACL and host gateway |
| Inter-VLAN communication fails | Routes and gateway | ACL direction and return path |
| DHCP fails | VLAN, pool and relay | Snooping trust, scope exhaustion |
| SSH fails | Management IP reachability | Keys, VTY lines, users and transport |

## References

- [Cisco Support: Switches](https://www.cisco.com/c/en/us/support/switches/index.html)
- [Cisco Support: Routers](https://www.cisco.com/c/en/us/support/routers/index.html)
- [Cisco Networking Academy / Packet Tracer](https://www.netacad.com/)
- [CyberPatriot Toolkit](https://github.com/Ripper1004/CyberPatriot-Toolkit/tree/main/docs)
- [CyberPatriot community checklists](https://github.com/chessischess/cyberpatriot-checklist)

**All examples are defensive lab instructions. Match every command to the activity requirements, interface names, supported IOS version and required connectivity.**
