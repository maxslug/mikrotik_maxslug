###############################################################################
# sep/06/2020 21:35:55 by RouterOS 6.47.3
# model = CRS109-8G-1S-2HnD
# software id = 10AT-2ZPI
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
#  1    100,200,300     mikro1  [POE in]
#  2    200             laptop
#  3    200             <lan>
#  4    200             <lan>
#  5    300             <guest>
#  6    300             <guest>
#  7    100             <admin>
#  8    200             desktop
# SFP   -               <disabled>
###############################################################################
#
#######################################
# Global Secrets (template)
#######################################
# :global BRIDGEMAC "xx:xx:xx:xx:xx:xx"
# :global SSIDBACKUP "backup"
# :global WPA2BACKUP "password"
/system identity set name=sw2
/system clock set time-zone-name=America/Los_Angeles
/system ntp client set enabled=yes server-dns-names=time.cloudflare.com
/lcd set default-screen=informative-slideshow

/interface bridge
add admin-mac=$BRIDGEMAC auto-mac=no fast-forward=no mtu=1500 name=BR1 \
  protocol-mode=none vlan-filtering=no comment="vlan off during configuration"

/interface wireless security-profiles set [ find default=yes ] authentication-types=wpa2-psk mode=dynamic-keys wpa2-pre-shared-key=$WPA2BACKUP
/interface wireless set [ find default-name=wlan1 ] ssid=$SSIDBACKUP \
    antenna-gain=0 band=2ghz-g/n channel-width=20/40mhz-XX \
    country="united states3" disabled=no distance=indoors \
    frequency=auto frequency-mode=manual-txpower mode=ap-bridge wireless-protocol=802.11

/interface ethernet disable sfp1

# VLAN ingress
/interface bridge port
add bridge=BR1 interface=ether1       trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="router1"
add bridge=BR1 interface=ether2       pvid=200    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="laptop"
add bridge=BR1 interface=ether3       pvid=200    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="spare lan"
add bridge=BR1 interface=ether4       pvid=200    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="spare lan"
add bridge=BR1 interface=ether5       pvid=300    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="spare guest"
add bridge=BR1 interface=ether6       pvid=300    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="spare guest"
add bridge=BR1 interface=ether7       pvid=100    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="admin"
add bridge=BR1 interface=ether8       pvid=200    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="desktop"
add bridge=BR1 interface=wlan1        pvid=300

# VLAN egress
/interface bridge vlan
add bridge=BR1 tagged=BR1,ether1            vlan-ids=100
add bridge=BR1 tagged=ether1                vlan-ids=200
add bridge=BR1 tagged=ether1 untagged=wlan1 vlan-ids=300
add bridge=BR1 tagged=ether1                vlan-ids=500

/interface vlan add interface=BR1 name=VLAN_100 vlan-id=100
/interface vlan add interface=BR1 name=VLAN_200 vlan-id=200
/interface vlan add interface=BR1 name=VLAN_300 vlan-id=300

/interface list add name=BASE
/interface list member add interface=VLAN_100 list=BASE

/ip address add address=192.168.100.3/24 interface=VLAN_100
/ip dns set allow-remote-requests=no servers=192.168.100.1
/ip route add distance=1 gateway=192.168.100.1

#######################################
# Configuration Services / Switch Security
#######################################
/ip neighbor discovery-settings set discover-interface-list=BASE
/ip service disable telnet,ftp,www,api,api-ssl
/tool mac-server mac-winbox set allowed-interface-list=BASE
/tool mac-server set allowed-interface-list=BASE
/tool bandwidth-server set enabled=no
/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/ip cloud set ddns-enabled=no update-time=no
/ip ssh set strong-crypto=yes

#######################################
# Turn on VLAN mode
#######################################
# Only allow ingress packets without tags on Access Ports
/interface bridge port
set bridge=BR1 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged [find interface=wlan1]

/interface bridge set BR1 vlan-filtering=yes comment="VLANs enabled"
