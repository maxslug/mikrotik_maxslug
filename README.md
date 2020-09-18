# maxslug's Mikrotik Networking Configuration Files

<!-- Someday github will catch up to gitlab and support Mermaid -->
![Network Diagram](/doc/network.jpg)

This repo is to hold my configuration files for a complex home network based on
Mikrotik networking gear.  Thank you to all the mikrotik forum posters for all
this knowledge and hard work, especially `pcunite`!

To discuss this please join us here : https://forum.mikrotik.com/viewtopic.php?f=13&t=166330

## Design Goals

### WAN

- Dual ISPs with auto-failover
- Complete removal of AT&T router ("residential gateway") from the picture

### L1

- Disaggregation of routing and wifi into separate solutions
- Switched managed Ethernet
- Redundancy
- Power over Ethernet to allow centralized UPS

### L2 / L3

- VLAN separation of Guest, Primary, IOT, Neighbor, and VOIP networks

### Wireless

- Centrally managed access points
- Roaming / Hand-off imrovements
- Higher overlapping coverage at lower radio power rates

### L4+

- Port Forwarding over VLAN
- Secure DNS

## Nework Design

These are notes to go along with the config files

### Inventory

- 1 x Mikrotik RB4011iGS+ Router using RouterOS 6.47.3
- 2 x Mikrotik CRS109-8G-1S-2HnD Router/Switch/APs running RouterOS 6.47.3
- 3 x Mikrotik cAP AC (RBcAPGi-5acD2nD) using RouterOS 6.47.3

### VLANs

VLAN  |IP                |Usage
------|------------------|-----------------
 100  |192.168.100.0/24  |Base / Management
 200  |192.168.120.0/24  |Normal LAN
 300  |192.168.130.0/24  |Guest / IOT
 400  |192.168.140.0/24  |VOIP
 500  |192.168.150.0/24  |Neighbor

- For each subnet addresses `.1` through `.39` are reserved for static IP assignment. `.1` is the router.
- The WAN ports are not on VLANs
- Once configured, you will need to make a port be on `VLAN 100` to use WinBox.

### Router

- `192.168.100.1`


- The EAP Authentication protocol requires a set system clock. DHCP requires EAP. NTP requies DHCP.  This means you can't set the clock over the internet
because of a chicken-n-egg problem.  Make sure `mikro1.rsc` is modified with the current time before programming it. Or, if you have a local NTP server, use that.
- You will need to coax your authentication keys out of your AT&T gateway so you can run in `supplicant mode`.
- DNS is setup to use DNS over HTTP (DOH) which requires some certificates and hurdles.

### Switches

I was really only interested in an 8-port managed GigE switch, but for the same price these units include a 2G WiFi radio.

- `192.168.100.2`
- `192.168.100.3` (config not included)


- The radio in the switches are not part of CapsMAN
- I create a "backup" SSID out of these that should work if I need to hookup the old router, or if for some other reason CapsMAN fails.
- One of the APs is chained off of `sw1` due to physical topology

### Access Points

- `192.168.100.11`
- `192.168.100.12` (config not included)
- `192.168.100.13` (config not included)

Despite what the Mikrotik documentation says, you cannot fully remotely provision these. You will need to create a config file and add it to the AP.
After that, the wireless definitions will be automatic, but not the base config and security!

- `/system reset-configuration run-after-reset=wap.rsc` does not seem to work. I still had to manually load the file after reset
- Resetting into CAP mode (hold reset button till it gets to it's second mode after blinking) is a better starting point
- Certificates will be auto-provisioned by CapsMAN
- Whenever you do a `/system reset-configuration` on the router, it doesn't have the ability of saving the certificate keys,
so unless you are managing your certificates outside of RouterOS, you'll need to clear the certs on EACH access point
  - `/interface wireless cap set enabled=no`
  - `/certificate print`
  - `/certificate remove numbers=1,0`
  - `/interface wireless cap set enabled=yes`
- Spectral Scan and other cool tools are not supported by the cAP AC (or other 802.11ac products)
- You need to assign all channels manually, up to and including inputting all the frequencies. It's really strange that this isn't done
  for you based on your country setting.  See below.
- I scripted the mode button so that it will toggle the LEDs between "always on" and "turn off after 1h"

#### 802.11ac Band Planning

![5G Bands for 802.11ac](/doc/maxslug_802.11ac_5G_channels.png)

Here is a diagram I put together to understand the 802.11ac channel assignment

- DFS is the middle part of the spectral sandwich which requires fancy driver support and regulatory signoff
- DFS is not supported w/ the cAP AC, at least not for the ones locked to `united states3` region.  As far as I can tell.
- 802.11ac requires 80MHz channels, made up of 4 x 20MHz channels
- For any given 80 MHz chunk, there are 4 possible assignments, depending on which one you make the control channel
  - This is what gives you the `Ceee` `eCee` `eeCe` `eeeC` "walking ones" pattern.  I tried to depict this above
  - I only defined the channels that worked for my region
- I use WiFi analyzer (Windows, Android) to do a survey of least-busy bands at each AP physical location


#### cAP AP Wireless Features

They are lacking on the software-based features like MIMO, DFS, Beam Forming,
Handoff Protocols, Spectral Scan etc.

Mikrotik runs their own driver, and it seems to be developed in the 802.11n
era. The chipsets in these devices support these features, but they are not
enabled.  If I had to guess, I would say it's probably a mixture of licensing
from the chipset vendor, mountains of software development, and regulatory
issues that make it difficult for Mirkotik.

It's not a deal breaker, I'm still getting great performance.

One promising recent development is the porting of OpenWRT to these devices.
I'll probably do this once the dust settles, even though it will mean losing
CAPSMan, which I happen to enjoy.

## References

These are not in any particular order, but all my knowledge came from these, so
Thank You!!

### config

- https://wiki.mikrotik.com/wiki/Manual:Configuration_Management
- https://help.mikrotik.com/docs/display/ROS/First+Time+Configuration

### Security

- https://mum.mikrotik.com/presentations/UK18/presentation_6165_1539151116.pdf

### CAPSman

- https://wiki.mikrotik.com/wiki/Manual:CAPsMAN_with_VLANs
- https://wiki.mikrotik.com/wiki/Manual:Simple_CAPsMAN_setup
- https://forum.mikrotik.com/viewtopic.php?t=152188
- https://wiki.mikrotik.com/wiki/Manual:CAPsMAN_tips
- https://mum.mikrotik.com/presentations/BR14/Uldis.pdf
- https://forum.mikrotik.com/viewtopic.php?t=158379
- https://www.reddit.com/r/mikrotik/comments/cltszm/trouble_getting_vlan_working_on_cap_man/
- https://forum.mikrotik.com/viewtopic.php?t=155429
- https://www.gonscak.sk/?p=575

### Wifi Channel Planning / 802.11ac / CapsMAN

![802.11ac Channels](/doc/802.11ac%20channels.png)

![802.11ac Spectrum](/doc/802.11ac%20channels2.png)

![802.11ac 20MHz different Center channels](/doc/802.11ac%20channels%20different%20primaries.png)

![AC1200 Definition](/doc/ac1200.png)

![802.11ac Modulations](/doc/mcs%20modes%20ac1200%20867.png)

- https://forum.mikrotik.com/viewtopic.php?t=136476
- https://forum.mikrotik.com/viewtopic.php?t=125026
- https://wiki.mikrotik.com/wiki/Manual:Spectral_scan
- https://forum.mikrotik.com/viewtopic.php?t=150463
- https://forum.mikrotik.com/viewtopic.php?f=7&t=149815&p=737784#p737784
- http://www.revolutionwifi.net/revolutionwifi/2013/03/80211ac-channel-planning.html
- https://netbeez.net/blog/dfs-channels-wifi/
- https://en.wikipedia.org/wiki/IEEE_802.11ac
- https://en.wikipedia.org/wiki/List_of_WLAN_channels#5_GHz_or_5.9_GHz_(802.11a/h/j/n/ac/ax)
- http://www.revolutionwifi.net/revolutionwifi/2013/03/safely-using-80-mhz-channels-with.html
- https://systemzone.net/mikrotik-wifi-frequency-band-and-channel-width-explanation/

### band steering

- https://forum.mikrotik.com/viewtopic.php?t=127742
- https://forum.mikrotik.com/viewtopic.php?t=132817
- https://forum.openwrt.org/t/mikrotik-cap-ac-support/57828/28
- https://github.com/openwrt/openwrt/pull/3037

### vlans

- https://forum.mikrotik.com/viewtopic.php?t=143620
- https://forum.mikrotik.com/viewtopic.php?t=155266
- https://forum.mikrotik.com/viewtopic.php?t=163650
- https://forum.mikrotik.com/viewtopic.php?t=160224

### The Dude

- https://mikrotik.com/thedude
- https://wiki.mikrotik.com/wiki/Manual:The_Dude

### EAP auth

- https://forum.mikrotik.com/viewtopic.php?t=154954

### Bridging

- https://wiki.mikrotik.com/wiki/Manual:Interface/Bridge

### failover / balancing

- https://wiki.mikrotik.com/wiki/Load_Balancing
- https://forum.mikrotik.com/viewtopic.php?t=93222
- https://forum.mikrotik.com/viewtopic.php?f=23&t=157048

### secure DNS

- https://forum.mikrotik.com/viewtopic.php?t=164078
- https://wiki.mikrotik.com/wiki/Manual:IP/DNS#DNS_over_HTTPS

### Printer sharing

- https://forum.mikrotik.com/viewtopic.php?t=110540
- https://forum.mikrotik.com/viewtopic.php?t=145765

### port forwarding

- https://forum.mikrotik.com/viewtopic.php?f=2&t=112861&p=817432#p817432
- https://forum.mikrotik.com/viewtopic.php?t=130022
