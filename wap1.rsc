###############################################################################
# RouterOS 6.45.9
# model = RBcAPGi-5acD2nD (cAP AC)
# software id = 4375-9B59
#
# Port VLANS            Usage
# -----------------------------------------
#  1    100,200,300,500 mikro1
#  2    100             <Admin>
#
###############################################################################

#######################################
# Global Secrets (template)
#######################################
# :global BRIDGEMAC "xx:xx:xx:xx:xx:xx"
# :global SSIDBACKUP "backup"
# :global WPA2BACKUP "password"

/system identity set name=wap1
/system clock set time-zone-name=America/Los_Angeles
/system ntp client set enabled=yes server-dns-names=time.cloudflare.com

#######################################
# Mode button will switch LEDs on now and timeout after 1h
#######################################
/system led settings set all-leds-off=after-1h
/system script add name=led-switch source={ \
  :if ([system leds settings get all-leds-off] = "after-1h") \
    do={ /system leds settings set all-leds-off=never} \
    else={ /system leds settings set all-leds-off=after-1h } \
}
/system routerboard mode-button set enabled=yes
/system routerboard mode-button set on-event=led-switch

/interface bridge
add admin-mac=$BRIDGEMAC auto-mac=no name=BR1 protocol-mode=none vlan-filtering=no \
  comment="VLAN disabled during configure"
/interface vlan add interface=BR1 name=VLAN_100 vlan-id=100

# VLAN Ingress
/interface bridge port
add bridge=BR1 interface=ether1 trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="trunk"
add bridge=BR1 interface=ether2 pvid=100    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="Admin"
#set bridge=BR1 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes [find interface=wlan1]
#set bridge=BR1 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes [find interface=wlan2]

# VLAN Egress
/interface bridge vlan
add bridge=BR1 tagged=ether1,BR1 vlan-ids=100
add bridge=BR1 tagged=ether1     vlan-ids=200
add bridge=BR1 tagged=ether1     vlan-ids=300

# Local Static IP
/ip address add interface=VLAN_100 address=192.168.100.11/24
/ip route add distance=1 gateway=192.168.100.1
/ip dns set servers=192.168.100.1

# managed by CAPsMAN
#/interface wireless
#set [ find default-name=wlan1 ] ssid=MikroTik disabled=no
#set [ find default-name=wlan2 ] ssid=MikroTik disabled=no

/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik

# Turn on CAPsMAN mode
/interface wireless cap
set bridge=BR1 discovery-interfaces=VLAN_100 caps-man-addresses=192.168.100.1 enabled=yes interfaces=wlan1,wlan2
/interface wireless cap set certificate=request

#######################################
# Configuration Services / WAP Security
#######################################
# Ensure only visibility and availability from BASE_VLAN, the MGMT network
/interface list add name=BASE
/interface list member add interface=VLAN_100 list=BASE
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
/interface bridge set BR1 vlan-filtering=yes comment="vlan enabled"

#######################################
# Final Configuration Steps
#######################################
# 1. Upgrade RouterOS
#
# 2. Upgrade RouterBoard Firmware
#   /system routerboard upgrade
#   (wait for message of completion)
#   /system reboot
