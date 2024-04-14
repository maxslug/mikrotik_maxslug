###############################################################################
# RouterOS 7.15beta8
# model = RBcAPGi-5acD2nD (cAP AC)
# software id = 4375-9B59
#
# Port VLANS            Usage
# -----------------------------------------
#  1    100,200,300     mikro1
#  2    100             <Admin>
#
#  SSIDs
#   network   - Server - VLAN 200
#   network-g - Guest/Everything - VLAN 300
#   DISABLED: network-a - Admin - VLAN 100
#
# Scanning and Radio Info
#   /interface wifi scan 0    # 2G
#   /interface wifi scan 1    # 5G
#   /interface wifi flat-snoop 0 # 2G
#   /interface wifi flat-snoop 1 # 5G
# /interface/wifi/radio print detail
#   Flags: L - local
#    0 L radio-mac=48:8F:5A:xx:xx:xx tx-chains=0,1 rx-chains=0,1 bands=2ghz-g:20mhz,2ghz-n:20mhz,20/40mhz ciphers=tkip,ccmp,gcmp,ccmp-256,gcmp-256,cmac,gmac,cmac-256,gmac-256 min-antenna-gain=2 countries=Canada,United States
#        2g-channels=2412,2417,2422,2427,2432,2437,2442,2447,2452,2457,2462 max-interfaces=16 max-station-interfaces=3 max-peers=129 hw-type="IPQ4019" hw-caps=sniffer interface=wifi1 current-country=United States
#        current-channels=2412/g,2412/n,2412/n/Ce,2417/g,2417/n,2417/n/Ce,2422/g,2422/n,2422/n/Ce,2427/g,2427/n,2427/n/Ce,2432/g,2432/n,2432/n/Ce,2432/n/eC,2437/g,2437/n,2437/n/Ce,2437/n/eC,2442/g,2442/n,2442/n/Ce,2442/n/eC,2447/g,2447/n,2447/n/eC,
#                    2452/g,2452/n,2452/n/eC,2457/g,2457/n,2457/n/eC,2462/g,2462/n,2462/n/eC
#        current-gopclasses=81,83,84 current-max-reg-power=30
#   
#    1 L radio-mac=48:8F:5A:xx:xx:xx tx-chains=0,1 rx-chains=0,1 bands=5ghz-a:20mhz,5ghz-n:20mhz,20/40mhz,5ghz-ac:20mhz,20/40mhz,20/40/80mhz ciphers=tkip,ccmp,gcmp,ccmp-256,gcmp-256,cmac,gmac,cmac-256,gmac-256 min-antenna-gain=3
#        countries=Canada,United States 5g-channels=5180,5200,5220,5240,5260,5280,5300,5320,5500,5520,5540,5560,5580,5600,5620,5640,5660,5680,5700,5720,5745,5765,5785,5805,5825 max-interfaces=16 max-station-interfaces=3 max-peers=129 hw-type="IPQ4019"
#        hw-caps=sniffer interface=wifi2 current-country=United States
#        current-channels=5180/a,5180/n,5180/n/Ce,5180/ac,5180/ac/Ce,5180/ac/Ceee,5200/a,5200/n,5200/n/eC,5200/ac,5200/ac/eC,5200/ac/eCee,5220/a,5220/n,5220/n/Ce,5220/ac,5220/ac/Ce,5220/ac/eeCe,5240/a,5240/n,5240/n/eC,5240/ac,5240/ac/eC,5240/ac/eeeC,
#                    5260/a,5260/n,5260/n/Ce,5260/ac,5260/ac/Ce,5260/ac/Ceee,5280/a,5280/n,5280/n/eC,5280/ac,5280/ac/eC,5280/ac/eCee,5300/a,5300/n,5300/n/Ce,5300/ac,5300/ac/Ce,5300/ac/eeCe,5320/a,5320/n,5320/n/eC,5320/ac,5320/ac/eC,5320/ac/eeeC,5500/a,
#                    5500/n,5500/n/Ce,5500/ac,5500/ac/Ce,5500/ac/Ceee,5520/a,5520/n,5520/n/eC,5520/ac,5520/ac/eC,5520/ac/eCee,5540/a,5540/n,5540/n/Ce,5540/ac,5540/ac/Ce,5540/ac/eeCe,5560/a,5560/n,5560/n/eC,5560/ac,5560/ac/eC,5560/ac/eeeC,5580/a,5580/n,
#                    5580/n/Ce,5580/ac,5580/ac/Ce,5580/ac/Ceee,5600/a,5600/n,5600/n/eC,5600/ac,5600/ac/eC,5600/ac/eCee,5620/a,5620/n,5620/n/Ce,5620/ac,5620/ac/Ce,5620/ac/eeCe,5640/a,5640/n,5640/n/eC,5640/ac,5640/ac/eC,5640/ac/eeeC,5660/a,5660/n,
#                    5660/n/Ce,5660/ac,5660/ac/Ce,5660/ac/Ceee,5680/a,5680/n,5680/n/eC,5680/ac,5680/ac/eC,5680/ac/eCee,5700/a,5700/n,5700/n/Ce,5700/ac,5700/ac/Ce,5700/ac/eeCe,5720/a,5720/n,5720/n/eC,5720/ac,5720/ac/eC,5720/ac/eeeC,5745/a,5745/n,
#                    5745/n/Ce,5745/ac,5745/ac/Ce,5745/ac/Ceee,5765/a,5765/n,5765/n/eC,5765/ac,5765/ac/eC,5765/ac/eCee,5785/a,5785/n,5785/n/Ce,5785/ac,5785/ac/Ce,5785/ac/eeCe,5805/a,5805/n,5805/n/eC,5805/ac,5805/ac/eC,5805/ac/eeeC,5825/a,5825/n,5825/ac
#        current-gopclasses=115,116,117,118,119,120,121,122,123,125,126,127,128 current-max-reg-power=30
#
# /interface/wifi/radio reg-info
#   country: United States
#   number: 0
#     ranges: 2402-2472/30
#             5490-5730/24/dfs
#             5735-5835/30
#             5250-5330/24/dfs
#             5170-5250/30
#             5835-5895/30/indoor
#
###############################################################################
# /export file=wap2-default.rsc

/system identity set name=wap2
/system clock set time-zone-name=America/Los_Angeles
/system clock set time="16:00:00"
/system clock set date="mar/29/2024"
/system ntp client set enabled=yes servers=time.cloudflare.com

#######################################
# Mode button will switch LEDs on now and timeout after 1h
# The default in routerOS 17 now "dark mode"
#######################################
/system led settings set all-leds-off=after-1h
/system script add name=led-switch source={ \
  :if ([system leds settings get all-leds-off] = "after-1h") \
    do={ /system leds settings set all-leds-off=never} \
    else={ /system leds settings set all-leds-off=after-1h } \
}
/system routerboard mode-button set enabled=yes
/system routerboard mode-button set on-event=led-switch
/log warning "Checkpoint 1"

/interface bridge add name=BR1 protocol-mode=none vlan-filtering=no comment="VLAN disabled during configure"

# CAP-AC restriction, VLANs cannot be created by [new] CAPsMAN
/interface wifi
set [ find default-name=wifi1 ] configuration.manager=capsman .mode=ap disabled=no
set [ find default-name=wifi2 ] configuration.manager=capsman .mode=ap disabled=no
add master-interface=wifi1 name=wifi1_200 disabled=no
add master-interface=wifi2 name=wifi2_200 disabled=no

# Improve non-802.11r roaming by kicking clients off of weak APs
# TODO(maxslug) This used to be able to be done using /caps-main access-list.  Not a thing any more??
#   /caps-man access-list add action=reject interface=any signal-range=-120..-88
# This is suggested to be removed for improving 802.11r hand-off
/interface wifi access-list add action=reject disabled=no interface=any signal-range=-120..-88

/log warning "Checkpoint 2"

# VLAN Ingress
/interface bridge port
add bridge=BR1 interface=ether1 trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="trunk"
add bridge=BR1 interface=ether2    pvid=100 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="Admin"
add bridge=BR1 interface=wifi1     pvid=300 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="2G VLAN 300"
add bridge=BR1 interface=wifi1_200 pvid=200 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="2G VLAN 200"
add bridge=BR1 interface=wifi2     pvid=300 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="5G VLAN 300"
add bridge=BR1 interface=wifi2_200 pvid=200 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="5G VLAN 200"

# VLAN Egress
/interface bridge vlan
add bridge=BR1 tagged=ether1,BR1 untagged=ether2              vlan-ids=100
add bridge=BR1 tagged=ether1,BR1 untagged=wifi1_200,wifi2_200 vlan-ids=200
add bridge=BR1 tagged=ether1,BR1 untagged=wifi1,wifi2         vlan-ids=300

/interface vlan add interface=BR1 name=VLAN_100 vlan-id=100

/log warning "Checkpoint 3"
#/ip firewall connection tracking set udp-timeout=10s
/ip settings set max-neighbor-entries=8192
/ipv6 settings set disable-ipv6=yes max-neighbor-entries=8192

# Local Static IP
/ip address add interface=VLAN_100 address=192.168.100.12/24
/ip route add distance=1 gateway=192.168.100.1
/ip dns set servers=192.168.100.1

/log warning "Checkpoint 4"

# Turn on CAPsMAN mode
/interface wifi cap
set discovery-interfaces=VLAN_100 caps-man-addresses=192.168.100.1 enabled=yes slaves-static=yes

#######################################
# Configuration Services / WAP Security
#######################################
# Ensure only visibility and availability from BASE VLAN, the MGMT network
/interface list add name=BASE
/interface list member add interface=VLAN_100 list=BASE
/ip neighbor discovery-settings set discover-interface-list=BASE
/tool mac-server mac-winbox set allowed-interface-list=BASE
/tool mac-server set allowed-interface-list=BASE
/tool bandwidth-server set enabled=no
/ip service disable telnet,ftp,www,api,api-ssl
/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/ip cloud set ddns-enabled=no update-time=no
/ip ssh set strong-crypto=yes
/system note set show-at-login=no
/system package update set channel=development

#######################################
# Turn on VLAN mode
#######################################
/interface bridge set BR1 vlan-filtering=yes comment="VLANs enabled"

/log warning "Checkpoint 5"

#######################################
# Final Configuration Steps
#######################################
# 1. Upgrade RouterOS and reboot
# 2. Upgrade RouterBoard Firmware and reboot
# 3. Check date/time set above
# 4. Copy this file to Files/
# 5. /system reset-configuration no-defaults=yes keep-users=yes skip-backup=yes run-after-reset=wap2.rsc
# 6. Debug, rinse, repeat
# 7. Do steps 3-6 again
