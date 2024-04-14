###############################################################################
# RouterOS 7.15beta8
# model = CRS109-8G-1S-2HnD
# software id = 6X0V-XSJM
#
# VLAN  IP                Usage
# -----------------------------------------
#  100  192.168.100.0/24  Base / Management
#  200  192.168.120.0/24  Normal LAN
#  300  192.168.130.0/24  Guest / IOT
#  400  192.168.140.0/24  VOIP
#  500  192.168.150.0/24  Neighbor
#
# Port VLANS            Usage
# -----------------------------------------
# Bot Row
#  1    100,200,300     mikro1 [POE In]
#  3    200             Server Direct
#  5    200             Printer
#  7    100             Admin
# Top Row
#  2    300             Spare
#  4    300             Spare
#  6    300             Spare
#  8    100             Admin
# SFP   -               <disabled>
# wlan1 200             Backup WiFi
###############################################################################

#######################################
# Global Secrets (template)
#######################################
# :global SSIDBACKUP "backup"
# :global WPA2BACKUP "password"

/system identity set name=sw2
/system clock set time="16:11:00"
/system clock set date="mar/29/2024"
/system clock set time-zone-name=America/Los_Angeles
/system ntp client set enabled=yes servers=time.cloudflare.com
/lcd set default-screen=informative-slideshow

/log warning "Checkpoint 1"
/interface bridge
add name=BR1 fast-forward=no mtu=1500 protocol-mode=none vlan-filtering=no comment="Disable VLAN during config"

# Note: The new /wifi is only available for .ac devices and newer (Wifi 5 Wave 2)
/interface wireless security-profiles set [ find default=yes ] \
  authentication-types=wpa2-psk mode=dynamic-keys wpa2-pre-shared-key=$WPA2BACKUP
/interface wireless set [ find default-name=wlan1 ] \
  band=2ghz-g/n channel-width=20/40mhz-eC country="united states" disabled=no frequency=auto installation=indoor ssid=$SSIDBACKUP

/interface ethernet set [ find default-name=sfp1 ] disabled=yes

# VLAN ingress
/interface vlan add interface=BR1 name=VLAN_100 vlan-id=100
/interface vlan add interface=BR1 name=VLAN_200 vlan-id=200
/interface vlan add interface=BR1 name=VLAN_300 vlan-id=300

/interface bridge port
add bridge=BR1 interface=ether1       trusted=yes frame-types=admit-only-vlan-tagged                  comment="mikro1"
add bridge=BR1 interface=ether3       pvid=200    frame-types=admit-only-untagged-and-priority-tagged comment="Server VLAN"
add bridge=BR1 interface=ether5       pvid=200    frame-types=admit-only-untagged-and-priority-tagged comment="Printer"
add bridge=BR1 interface=ether7       pvid=100    frame-types=admit-only-untagged-and-priority-tagged comment="Admin 1"
add bridge=BR1 interface=ether2       pvid=300    frame-types=admit-only-untagged-and-priority-tagged comment="Spare 2"
add bridge=BR1 interface=ether4       pvid=300    frame-types=admit-only-untagged-and-priority-tagged comment="Spare 4"
add bridge=BR1 interface=ether6       pvid=300    frame-types=admit-only-untagged-and-priority-tagged comment="Spare 6"
add bridge=BR1 interface=ether8       pvid=100    frame-types=admit-only-untagged-and-priority-tagged comment="Admin 2"
add bridge=BR1 interface=wlan1        pvid=200    frame-types=admit-only-untagged-and-priority-tagged comment="WiFi"

# VLAN egress
/interface bridge vlan
add bridge=BR1 tagged=BR1,ether1 untagged=ether7                             vlan-ids=100
add bridge=BR1 tagged=BR1,ether1 untagged=wlan1,ether3                       vlan-ids=200
add bridge=BR1 tagged=BR1,ether1 untagged=ether5,ether2,ether4,ether6,ether8 vlan-ids=300

/log warning "Checkpoint 2"
# IP Settings
/ip settings set max-neighbor-entries=8192
/ipv6 settings set disable-ipv6=yes max-neighbor-entries=8192

/ip address add address=192.168.100.3/24 interface=VLAN_100
/ip dns set allow-remote-requests=no servers=192.168.100.1
/ip route add distance=1 gateway=192.168.100.1

#######################################
# Configuration Services / Switch Security
#######################################
/interface list add name=BASE
/interface list member add interface=VLAN_100 list=BASE
/ip neighbor discovery-settings set discover-interface-list=BASE
/tool mac-server mac-winbox set allowed-interface-list=BASE
/tool mac-server set allowed-interface-list=BASE
/ip service disable telnet,ftp,www,api,api-ssl
/tool bandwidth-server set enabled=no
/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/ip cloud set ddns-enabled=no update-time=no
/ip ssh set strong-crypto=yes
/system note set show-at-login=no

/log warning "Checkpoint 3"
#######################################
# Turn on VLAN mode
#######################################
/interface bridge set BR1 vlan-filtering=yes comment="VLANs enabled"

/log warning "Checkpoint 4"
#######################################
# Final Configuration Steps
#######################################
# 1. Upgrade RouterOS and reboot
# 2. Upgrade RouterBoard Firmware and reboot
# 3. Add wireless package and reboot
# 4. Check date/time set above
# 5. Copy this file to Files/
# 6. /system reset-configuration no-defaults=yes keep-users=yes skip-backup=yes run-after-reset=sw2.rsc
# 7. Debug, rinse, repeat
# 8. Do steps 4-7 again
#
# Use Port 7 for debug
