###############################################################################
#
# mikro1 configuration
#     model = RB4011iGS+
#     Baseline:
#       RouterOS 6.47.3
#       software id = 1EMK-5D1S
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
#  1    -               WAN1 - Fiber Provider (req EAP auth)
#  2    -               WAN2 - WISP - TODO:
#  3    300             Printer
#  4    400             ATA
#  5    200             <LAN>
#  6    100,200,300     wap3
#  7    100,200,300     wap2
#  8    200             server
#  9    100,200,300     sw2
# 10    100,200,300,500 sw1
# SFP   100             <admin>
#
###############################################################################
/system identity set name=mikro1

#######################################
# Global Secrets (template)
#######################################
# MAC of device from default config.  Certificates use the same MAC (all caps) but no ':'s
# :global BRIDGEMAC "xx:xx:xx:xx:xx:xx"
# :global CAPSCERTCA "CAPsMAN-CA-xxxxxxxxxxxx.crt"
# :global CAPSCERT "CAPsMAN-xxxxxxxxxxxx.crt"
# Fiber EAP Authentication
# :global ATTPORT "ether1"
# :global ATTMAC "xx:xx:xx:xx:xx:xx"
# :global ATTCA "CA_*.pem"
# :global ATTCLIENT "Client_*.pem"
# :global ATTKEY "PrivateKey_PKCS1_*.pem"
# Assign WiFi SSID and Password here
# :global SSIDMAIN "main"
# :global SSIDADMIN "admin"
# :global SSIDGUEST "guest"
# :global WPA2MAIN "password"
# :global WPA2ADMIN "password"
# :global WPA2GUEST "password"
# Assign WiFi channels here
# :global WAP12G  "CHx"
# :global WAP22G  "CHx"
# :global WAP32G  "CHxx"
# :global WAP15G  "CHxx"
# :global WAP25G  "CHxxx"
# :global WAP35G  "CHxx"
# use `/caps-man radio print` and `/caps-man interface hw-info <capN>` to figure out MAC addresses
# :global WAP1RADIO2G "xx:xx:xx:xx:xx:xx"
# :global WAP1RADIO5G "xx:xx:xx:xx:xx:xx"
# :global WAP2RADIO2G "xx:xx:xx:xx:xx:xx"
# :global WAP2RADIO5G "xx:xx:xx:xx:xx:xx"
# :global WAP3RADIO2G "xx:xx:xx:xx:xx:xx"
# :global WAP3RADIO5G "xx:xx:xx:xx:xx:xx"
# :global TXPWR2G "9"
# :global TXPWR5G "17"

#######################################
# Date and Time
# !!! NOTE: Set the date and time below before configuring
#           This is required for EAP to be succesful so you can to the NTP server
#           it's a chicken-n-egg problem.
#           Alternately, use an NTP server on your LAN
#######################################
/system clock set time-zone-name=America/Los_Angeles
/system clock set time="15:38:00"
/system clock set date="sep/19/2020"
/system ntp client set enabled=yes server-dns-names=time.cloudflare.com


#######################################
# Ethernet Port configuration
#######################################
/interface ethernet switch port
set 0 default-vlan-id=0
set 1 default-vlan-id=0
set 2 default-vlan-id=0
set 3 default-vlan-id=0
set 4 default-vlan-id=0
set 5 default-vlan-id=0
set 6 default-vlan-id=0
set 7 default-vlan-id=0
set 8 default-vlan-id=0
set 9 default-vlan-id=0
set 10 default-vlan-id=0
set 11 default-vlan-id=0

# AT&T EAP Authentication
/certificate import file-name=$ATTCA passphrase=""
/certificate import file-name=$ATTCLIENT passphrase=""
/certificate import file-name=$ATTKEY passphrase=""
/interface ethernet set [ find default-name=$ATTPORT ] mac-address=$ATTMAC \
  comment="MAC is set to the AT&T Residential Gateway, to match EAP authentication"
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/interface dot1x client add certificate=$ATTCLIENT eap-methods=eap-tls identity=$ATTMAC interface=$ATTPORT

#######################################
# Bridge
#######################################
/interface bridge add admin-mac=$BRIDGEMAC auto-mac=no name=BR1 protocol-mode=none vlan-filtering=no \
  comment="create one bridge, set VLAN mode off while we configure"

# Ingress
/interface bridge port
# ether1 - WAN1, not bridged
# ether2 - WAN2, not bridged
add bridge=BR1 interface=ether3       pvid=300    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="printer"
add bridge=BR1 interface=ether4       pvid=400    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="ata"
add bridge=BR1 interface=ether5       pvid=200    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="Admin"
add bridge=BR1 interface=ether6       trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="wap3"
add bridge=BR1 interface=ether7       trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="wap2"
add bridge=BR1 interface=ether8       pvid=200    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="server"
add bridge=BR1 interface=ether9       trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="sw2"
add bridge=BR1 interface=ether10      trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="sw1"
add bridge=BR1 interface=sfp-sfpplus1 pvid=100    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="Admin"

# Egress
/interface bridge vlan
add bridge=BR1 tagged=BR1,ether6,ether7,ether9,ether10 vlan-ids=100
add bridge=BR1 tagged=BR1,ether6,ether7,ether9,ether10 vlan-ids=200
add bridge=BR1 tagged=BR1,ether6,ether7,ether9,ether10 vlan-ids=300
add bridge=BR1 tagged=BR1                              vlan-ids=400
add bridge=BR1 tagged=BR1,ether10                      vlan-ids=500

#######################################
# IP Addressing & Routing
#   Setting the route distance allows for auto-failover
#   The script will auto-add and remove to the WAN_IPS address list for hairpin NAT support
#     ... this allows using a router's FQDN from internal and external
#######################################
/ip firewall address-list add comment="wan1" disabled=yes list=WAN_IPS
/ip firewall address-list add comment="wan2" disabled=yes list=WAN_IPS
/ip dhcp-client add disabled=no interface=ether1 default-route-distance=1 comment="WAN1 IP" \
  script=":if (\$bound=1) do={ \
    /ip firewall address-list set [/ip firewall address-list find where comment=\"wan1\" && list=WAN_IPS] address=\$\"lease-address\" disabled=no; \
  } else={ \
    /ip firewall address-list set [/ip firewall address-list find where comment=\"wan1\" && list=WAN_IPS] disabled=yes; \
  }"
/ip dhcp-client add disabled=no interface=ether2 default-route-distance=2 comment="WAN2 IP" \
  script=":if (\$bound=1) do={ \
    /ip firewall address-list set [/ip firewall address-list find where comment=\"wan2\" && list=WAN_IPS] address=\$\"lease-address\" disabled=no; \
  } else={ \
    /ip firewall address-list set [/ip firewall address-list find where comment=\"wan2\" && list=WAN_IPS] disabled=yes; \
  }"

/interface vlan add interface=BR1 name=VLAN_100 vlan-id=100
/interface vlan add interface=BR1 name=VLAN_200 vlan-id=200
/interface vlan add interface=BR1 name=VLAN_300 vlan-id=300
/interface vlan add interface=BR1 name=VLAN_400 vlan-id=400
/interface vlan add interface=BR1 name=VLAN_500 vlan-id=500

/ip address add interface=VLAN_100 address=192.168.100.1/24
/ip address add interface=VLAN_200 address=192.168.120.1/24
/ip address add interface=VLAN_300 address=192.168.130.1/24
/ip address add interface=VLAN_400 address=192.168.140.1/24
/ip address add interface=VLAN_500 address=192.168.150.1/24

/ip pool add name=POOL_100 ranges=192.168.100.40-192.168.100.254
/ip pool add name=POOL_200 ranges=192.168.120.40-192.168.120.254
/ip pool add name=POOL_300 ranges=192.168.130.40-192.168.130.254
/ip pool add name=POOL_400 ranges=192.168.140.40-192.168.140.254
/ip pool add name=POOL_500 ranges=192.168.150.40-192.168.150.254

/ip dhcp-server add address-pool=POOL_100 interface=VLAN_100 name=DHCP_100 disabled=no
/ip dhcp-server add address-pool=POOL_200 interface=VLAN_200 name=DHCP_200 disabled=no
/ip dhcp-server add address-pool=POOL_300 interface=VLAN_300 name=DHCP_300 disabled=no
/ip dhcp-server add address-pool=POOL_400 interface=VLAN_400 name=DHCP_400 disabled=no
/ip dhcp-server add address-pool=POOL_500 interface=VLAN_500 name=DHCP_500 disabled=no

/ip dhcp-server network add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1
/ip dhcp-server network add address=192.168.120.0/24 dns-server=192.168.100.1 gateway=192.168.120.1
/ip dhcp-server network add address=192.168.130.0/24 dns-server=192.168.100.1 gateway=192.168.130.1
/ip dhcp-server network add address=192.168.140.0/24 dns-server=192.168.100.1 gateway=192.168.140.1
/ip dhcp-server network add address=192.168.150.0/24 dns-server=192.168.100.1 gateway=192.168.150.1

# Secure dns over HTTPS
#  NOTE: RouterOS does not failover when the DOH stops working :(
#  Switched from https://cloudflare-dns.com/dns-query due to reliability
#  Google DOH settings (https://forum.mikrotik.com/viewtopic.php?t=160243#p822014)
/ip dns set servers=8.8.8.8,8.8.4.4
/certificate import file-name=DigiCertGlobalRootCA.crt.pem passphrase=""
/tool fetch url=https://pki.goog/roots.pem
/certificate import file-name=roots.pem passphrase=""
/ip dns set use-doh-server=https://dns.google/dns-query verify-doh-cert=yes
/ip dns set allow-remote-requests=yes cache-max-ttl=1d use-doh-server=https://dns.google/dns-query verify-doh-cert=yes
/ip dns static
add address=8.8.8.8 name=dns.google
add address=8.8.4.4 name=dns.google
add address=104.16.248.249 name=cloudflare-dns.com type=A
add address=104.16.249.249 name=cloudflare-dns.com type=A
add address=2606:4700:4700::1001 name=ipv6a.cloudflare-dns.com type=AAAA
add address=2606:4700:4700::1111 name=ipv6b.cloudflare-dns.com type=AAAA

### Script for certificate update
/system script add dont-require-permissions=no name=Certificate_Google \
  policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
  source="/tool fetch url=https://pki.goog/roots.pem\r\n/certificate import file-name=roots.pem passphrase=\"\""

### Script for DNS cache flush
/system script add dont-require-permissions=no name=DNS_Flush_Cache \
  policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
  source="/ip dns cache flush"

### Schedule to update google certificate once a week
/system scheduler add comment="Google Certificate Update" interval=1w \
  policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
  name=Certificate_Google_Update on-event=Certificate_Google \
  start-date=nov/01/2020 start-time=04:20:00

### Schedule to flush dns cache everyday
/system scheduler add comment="DoH Cache Flush" interval=1d \
  policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
  name="DNS Cache Flush" on-event=DNS_Flush_Cache \
  start-date=nov/01/2020 start-time=05:00:00

###############################################################################
# Firewall
###############################################################################
/interface list add name=WAN
/interface list add name=VLAN
/interface list add name=BASE

/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=WAN
add interface=VLAN_100 list=BASE
add interface=VLAN_200 list=VLAN
add interface=VLAN_300 list=VLAN
add interface=VLAN_400 list=VLAN
add interface=VLAN_500 list=VLAN

# Remove this for PPTP, or Load-Balancing issues
/ip settings set rp-filter=strict

/ip firewall filter
# input services the local router only at all the .1 addresses
add chain=input   action=accept               connection-state=established,related,untracked
add chain=input   action=drop                 connection-state=invalid
add chain=input   action=accept               protocol=icmp
add chain=input   action=accept               dst-port=53 in-interface-list=VLAN protocol=udp
add chain=input   action=accept               dst-port=53 in-interface-list=VLAN protocol=tcp
add chain=input   action=accept               in-interface-list=BASE comment="Allow Management Vlan Full Access"
add chain=input   action=drop

# forward services the NAT / Routing
add chain=forward action=accept               ipsec-policy=in,ipsec
add chain=forward action=accept               ipsec-policy=out,ipsec
add chain=forward action=fasttrack-connection connection-state=established,related
add chain=forward action=accept               connection-state=established,related,untracked
add chain=forward action=drop                 connection-state=invalid
add chain=forward action=accept               connection-state=new in-interface-list=VLAN out-interface-list=WAN
add chain=forward action=accept               connection-state=new in-interface-list=BASE out-interface-list=WAN
add chain=forward action=accept dst-address=192.168.120.2 in-interface-list=BASE comment="full server access from admin"
add chain=forward action=accept protocol=tcp dst-address=192.168.120.2 in-interface=VLAN_500 dst-port=8234,32400 comment="plex server - guest vlan"
add chain=forward action=accept protocol=tcp dst-address=192.168.120.2 in-interface=VLAN_300 dst-port=8234,32400 comment="plex server - neighbor vlan"
add chain=forward action=accept protocol=udp dst-address=192.168.120.2 in-interface=VLAN_300 dst-port=1900,5353,32410-32414 comment="plex server - guest vlan"
add chain=forward action=accept protocol=udp dst-address=192.168.120.2 in-interface=VLAN_500 dst-port=1900,5353,32410-32414 comment="plex server - neighbor vlan"
add chain=forward action=accept protocol=tcp dst-address=192.168.120.2 in-interface=VLAN_300 dst-port=443 comment="https server - guest vlan"
add chain=forward action=accept protocol=tcp dst-address=192.168.120.2 in-interface=VLAN_500 dst-port=443 comment="https server - neighbor vlan"
add chain=forward action=accept protocol=tcp dst-address=192.168.130.3 in-interface=VLAN_200 dst-port=443,9100 comment="printer - main vlan jetdirect"
add chain=forward action=accept protocol=tcp dst-address=192.168.130.3 in-interface=VLAN_300 dst-port=443,515,631,9100,9400,9500,9501,65001,65002,65003,65004 comment="printer - guest vlan TCP"
add chain=forward action=accept protocol=udp dst-address=192.168.130.3 in-interface=VLAN_300 dst-port=5353,9200,9300,9301,9302,3702 comment="printer - guest vlan UDP"
add chain=forward action=drop   dst-address=192.168.130.3/32 comment="Disable all other ports on printer"
add chain=forward action=accept               connection-nat-state=dstnat comment="For port forwarding to VLANs"
add chain=forward action=drop

# Note that the port forwarding uses an address list not an interface list
#  this has a subtle effect of allowing a dynamic list which you need for a hairpin NAT
/ip firewall nat
add chain=srcnat  action=masquerade src-address=192.168.120.0/24 dst-address=192.168.120.0/24 comment="Hairpin NAT"
add chain=srcnat  action=masquerade ipsec-policy=out,none out-interface-list=WAN
add chain=dstnat  action=dst-nat to-addresses=192.168.120.2 to-ports=80 protocol=tcp dst-address-list=WAN_IPS dst-port=80 comment="port forward http to server"
add chain=dstnat  action=dst-nat to-addresses=192.168.120.2 to-ports=443 protocol=tcp dst-address-list=WAN_IPS dst-port=443 comment="port forward https to server"
add chain=dstnat  action=dst-nat to-addresses=192.168.120.2 to-ports=22 protocol=tcp dst-address-list=WAN_IPS dst-port=2222 comment="port forward SSH to server"
add chain=dstnat  action=dst-nat to-addresses=192.168.120.2 to-ports=32400 protocol=tcp dst-address-list=WAN_IPS dst-port=32400 comment="port forward plex to server"

/routing filter
add action=passthrough chain=dynamic-in disabled=no set-check-gateway=ping comment="Failover ping check"

#######################################
# Configuration Services / Router Security
#######################################
/user group set full policy="local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,password,web,sniff,sensitive,api,romon,dude,tikapp"
/ip neighbor discovery-settings set discover-interface-list=BASE
/ip service disable telnet,ftp,www,api,api-ssl
/dude set enabled=no

# During Debug and Bring-up
/tool mac-server set allowed-interface-list=BASE
/tool mac-server mac-winbox set allowed-interface-list=BASE

# Production
#/tool mac-server set allowed-interface-list=none
#/tool mac-server mac-winbox set allowed-interface-list=none
#/tool mac-server ping set enabled=no
/tool bandwidth-server set enabled=no
/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/ip cloud set ddns-enabled=no update-time=no
/ip ssh set strong-crypto=yes

#######################################
# WiFi / CapsMAN
#######################################
# Guest WiFi members can't see each other
/caps-man datapath
add bridge=BR1 client-to-client-forwarding=yes local-forwarding=yes name=DP100 vlan-id=100 vlan-mode=use-tag
add bridge=BR1 client-to-client-forwarding=yes local-forwarding=yes name=DP200 vlan-id=200 vlan-mode=use-tag
add bridge=BR1 client-to-client-forwarding=no  local-forwarding=yes name=DP300 vlan-id=300 vlan-mode=use-tag

# Channel Defintion
#   Only adding 80MHz channels for 5G for 802.11AC support
#
# From the CAP AC in "united states3" locked mode
# /interface wireless info country-info "united states3"
#   ranges: 2402-2472/b,g,gn20,gn40(30dBm)
#           5170-5250/a,an20,an40,ac20,ac40,ac80,ac160,ac80+80(30dBm)/indoor
#           5735-5835/a,an20,an40,ac20,ac40,ac80,ac160,ac80+80(30dBm)/outdoor
# /interface wireless info allowed-channels interface=wlan1
#  channels: 2412/20/g(28dBm),2417/20/g(28dBm),2422/20/g(28dBm),2427/20/g(28dBm),2432/20/g(28dBm),2437/20/g(28dBm),2442/20/g(28dBm),2447/20/g(28dBm),
#            2452/20/g(28dBm),2457/20/g(28dBm),2462/20/g(28dBm)
# /interface wireless info allowed-channels interface=wlan2
#  channels: 5180/20/a(28dBm),5185/20/a(28dBm),5190/20/a(28dBm),5195/20/a(28dBm),5200/20/a(28dBm),5205/20/a(28dBm),5210/20/a(28dBm),5215/20/a(28dBm),
#            5220/20/a(28dBm),5225/20/a(28dBm),5230/20/a(28dBm),5235/20/a(28dBm),5240/20/a(28dBm),5745/20/a(28dBm),5750/20/a(28dBm),5755/20/a(28dBm),
#            5760/20/a(28dBm),5765/20/a(28dBm),5770/20/a(28dBm),5775/20/a(28dBm),5780/20/a(28dBm),5785/20/a(28dBm),5790/20/a(28dBm),5795/20/a(28dBm),
#            5800/20/a(28dBm),5805/20/a(28dBm),5810/20/a(28dBm),5815/20/a(28dBm),5820/20/a(28dBm),5825/20/a(28dBm)
/caps-man channel
add band=2ghz-g/n  frequency=2412 name=CH1
add band=2ghz-g/n  frequency=2417 name=CH2
add band=2ghz-g/n  frequency=2422 name=CH3
add band=2ghz-g/n  frequency=2427 name=CH4
add band=2ghz-g/n  frequency=2432 name=CH5
add band=2ghz-g/n  frequency=2437 name=CH6
add band=2ghz-g/n  frequency=2442 name=CH7
add band=2ghz-g/n  frequency=2447 name=CH8
add band=2ghz-g/n  frequency=2452 name=CH9
add band=2ghz-g/n  frequency=2457 name=CH10
add band=2ghz-g/n  frequency=2462 name=CH11
add band=5ghz-n/ac frequency=5180 name=CH36  control-channel-width=20mhz extension-channel=Ceee
add band=5ghz-n/ac frequency=5200 name=CH40  control-channel-width=20mhz extension-channel=eCee
add band=5ghz-n/ac frequency=5220 name=CH44  control-channel-width=20mhz extension-channel=eeCe
add band=5ghz-n/ac frequency=5240 name=CH48  control-channel-width=20mhz extension-channel=eeeC
add band=5ghz-n/ac frequency=5745 name=CH149 control-channel-width=20mhz extension-channel=Ceee
add band=5ghz-n/ac frequency=5765 name=CH153 control-channel-width=20mhz extension-channel=eCee
add band=5ghz-n/ac frequency=5785 name=CH157 control-channel-width=20mhz extension-channel=eeCe
add band=5ghz-n/ac frequency=5805 name=CH161 control-channel-width=20mhz extension-channel=eeeC

# Configurations
#   1 per (ssid/vlan, 2g channel, 5g) = 3 AP * 3 SSIDs * 2 Radios = 18 configs, assuming no overlapping channels
# "united states3" is an exact setting to match a locked CAP-AC device for US Market
#
# Transmit Power Tuning to kludge host steering to 5G
#  1. 2G should be at least 7dB lower than 5G to account for frequency
#  2. Set the Max transmit power to match your clients (15-17dB) otherwise the AP is advertising to hosts it can't service
#  3. Lower all the settings if you have dense coverage or low interference
/caps-man configuration
# wap1 - 2G
add country="united states3" datapath=DP100 datapath.local-forwarding=yes datapath.vlan-id=100 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap1_2g_admin security.authentication-types=wpa2-psk security.passphrase=$WPA2ADMIN ssid=$SSIDADMIN hide-ssid=yes channel=$WAP12G channel.tx-power=$TXPWR2G
add country="united states3" datapath=DP200 datapath.local-forwarding=yes datapath.vlan-id=200 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap1_2g_main security.authentication-types=wpa2-psk security.passphrase=$WPA2MAIN ssid=$SSIDMAIN channel=$WAP12G channel.tx-power=$TXPWR2G
add country="united states3" datapath=DP300 datapath.local-forwarding=yes datapath.vlan-id=300 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap1_2g_guest security.authentication-types=wpa2-psk security.passphrase=$WPA2GUEST ssid=$SSIDGUEST channel=$WAP12G channel.tx-power=$TXPWR2G
# wap1 - 5G
add country="united states3" datapath=DP100 datapath.local-forwarding=yes datapath.vlan-id=100 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap1_5g_admin security.authentication-types=wpa2-psk security.passphrase=$WPA2ADMIN ssid=$SSIDADMIN hide-ssid=yes channel=$WAP15G channel.tx-power=$TXPWR5G
add country="united states3" datapath=DP200 datapath.local-forwarding=yes datapath.vlan-id=200 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap1_5g_main security.authentication-types=wpa2-psk security.passphrase=$WPA2MAIN ssid=$SSIDMAIN channel=$WAP15G channel.tx-power=$TXPWR5G
add country="united states3" datapath=DP300 datapath.local-forwarding=yes datapath.vlan-id=300 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap1_5g_guest security.authentication-types=wpa2-psk security.passphrase=$WPA2GUEST ssid=$SSIDGUEST channel=$WAP15G channel.tx-power=$TXPWR5G
# wap2 - 2G
add country="united states3" datapath=DP100 datapath.local-forwarding=yes datapath.vlan-id=100 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap2_2g_admin security.authentication-types=wpa2-psk security.passphrase=$WPA2ADMIN ssid=$SSIDADMIN hide-ssid=yes channel=$WAP22G channel.tx-power=$TXPWR2G
add country="united states3" datapath=DP200 datapath.local-forwarding=yes datapath.vlan-id=200 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap2_2g_main security.authentication-types=wpa2-psk security.passphrase=$WPA2MAIN ssid=$SSIDMAIN channel=$WAP22G channel.tx-power=$TXPWR2G
add country="united states3" datapath=DP300 datapath.local-forwarding=yes datapath.vlan-id=300 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap2_2g_guest security.authentication-types=wpa2-psk security.passphrase=$WPA2GUEST ssid=$SSIDGUEST channel=$WAP22G channel.tx-power=$TXPWR2G
# wap2 - 5G
add country="united states3" datapath=DP100 datapath.local-forwarding=yes datapath.vlan-id=100 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap2_5g_admin security.authentication-types=wpa2-psk security.passphrase=$WPA2ADMIN ssid=$SSIDADMIN hide-ssid=yes channel=$WAP25G channel.tx-power=$TXPWR5G
add country="united states3" datapath=DP200 datapath.local-forwarding=yes datapath.vlan-id=200 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap2_5g_main security.authentication-types=wpa2-psk security.passphrase=$WPA2MAIN ssid=$SSIDMAIN channel=$WAP25G channel.tx-power=$TXPWR5G
add country="united states3" datapath=DP300 datapath.local-forwarding=yes datapath.vlan-id=300 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap2_5g_guest security.authentication-types=wpa2-psk security.passphrase=$WPA2GUEST ssid=$SSIDGUEST channel=$WAP25G channel.tx-power=$TXPWR5G
# wap3 - 2G
add country="united states3" datapath=DP100 datapath.local-forwarding=yes datapath.vlan-id=100 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap3_2g_admin security.authentication-types=wpa2-psk security.passphrase=$WPA2ADMIN ssid=$SSIDADMIN hide-ssid=yes channel=$WAP32G channel.tx-power=$TXPWR2G
add country="united states3" datapath=DP200 datapath.local-forwarding=yes datapath.vlan-id=200 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap3_2g_main security.authentication-types=wpa2-psk security.passphrase=$WPA2MAIN ssid=$SSIDMAIN channel=$WAP32G channel.tx-power=$TXPWR2G
add country="united states3" datapath=DP300 datapath.local-forwarding=yes datapath.vlan-id=300 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap3_2g_guest security.authentication-types=wpa2-psk security.passphrase=$WPA2GUEST ssid=$SSIDGUEST channel=$WAP32G channel.tx-power=$TXPWR2G
# wap3 - 5G
add country="united states3" datapath=DP100 datapath.local-forwarding=yes datapath.vlan-id=100 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap3_5g_admin security.authentication-types=wpa2-psk security.passphrase=$WPA2ADMIN ssid=$SSIDADMIN hide-ssid=yes channel=$WAP35G channel.tx-power=$TXPWR5G
add country="united states3" datapath=DP200 datapath.local-forwarding=yes datapath.vlan-id=200 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap3_5g_main security.authentication-types=wpa2-psk security.passphrase=$WPA2MAIN ssid=$SSIDMAIN channel=$WAP35G channel.tx-power=$TXPWR5G
add country="united states3" datapath=DP300 datapath.local-forwarding=yes datapath.vlan-id=300 datapath.vlan-mode=use-tag datapath.bridge=BR1 \
  name=wap3_5g_guest security.authentication-types=wpa2-psk security.passphrase=$WPA2GUEST ssid=$SSIDGUEST channel=$WAP35G channel.tx-power=$TXPWR5G

# Assignments of Configurations to radios
#  1 per access point radio = 3 AP x 2 radios = 6 Total
#  Removed admin from 2G
/caps-man provisioning
add action=create-dynamic-enabled master-configuration=wap1_2g_main slave-configurations=wap1_2g_guest               radio-mac=$WAP1RADIO2G
add action=create-dynamic-enabled master-configuration=wap1_5g_main slave-configurations=wap1_5g_admin,wap1_5g_guest radio-mac=$WAP1RADIO5G
add action=create-dynamic-enabled master-configuration=wap2_2g_main slave-configurations=wap2_2g_guest               radio-mac=$WAP2RADIO2G
add action=create-dynamic-enabled master-configuration=wap2_5g_main slave-configurations=wap2_5g_admin,wap2_5g_guest radio-mac=$WAP2RADIO5G
add action=create-dynamic-enabled master-configuration=wap3_2g_main slave-configurations=wap3_2g_guest               radio-mac=$WAP3RADIO2G
add action=create-dynamic-enabled master-configuration=wap3_5g_main slave-configurations=wap3_5g_admin,wap3_5g_guest radio-mac=$WAP3RADIO5G

/caps-man manager interface
set [ find default=yes ] forbid=yes
add disabled=no interface=VLAN_100

# Improve roaming by kicking clients off of weak APs
/caps-man access-list
add action=reject interface=any signal-range=-120..-88

# TODO: It appears you can't export the certificate private key
#   This means that every time you do a /system reset-configuration you will need to
#   Clear out the certificates from EVERY access point:
#     /interface wireless cap set enabled=no
#     /certificate print
#     /certificate remove numbers=0,1
/caps-man manager set ca-certificate=auto certificate=auto enabled=yes \
  require-peer-certificate=no upgrade-policy=suggest-same-version
:log warning message="If this is a fresh load, don't forget to clear the certificates on each CAP and restart the cap interface"

#
# Check for certificates in Files and load them
# The first time you run, it will use auto, then run /caps-man manager print to get the generated cert names
#   NOTE: if you were to use auto at every /system reset your WAPs will fail due to Bad Handshake
#         And you will need to remove their certs and restart /interface wireless cap on each
# :if ( ([:len [/file find name=($CAPSCERTCA . ".crt")]] > 0) and \
#       ([:len [/file find name=($CAPSCERT . ".crt")]] > 0) ) do={ \
#   :log info message="Loading existing certificates for CaPSMAN"; \
#   :put "Loading existing certificates for CaPSMAN"; \
#   /certificate import file-name=($CAPSCERTCA . ".crt") passphrase=""; \
#   /certificate import file-name=($CAPSCERT . ".crt") passphrase=""; \
#   :delay 3000ms; \
#   /caps-man manager set ca-certificate=$CAPSCERTCA certificate=$CAPSCERT enabled=yes \
#       require-peer-certificate=no upgrade-policy=suggest-same-version; \
#   /caps-man manager print; \
# } else={ \
#   :log warning message="Creating new certificates for CaPSMAN"; \
#   :put "Creating new certificates for CaPSMAN"; \
#   /caps-man manager set ca-certificate=auto certificate=auto enabled=yes \
#       require-peer-certificate=no upgrade-policy=suggest-same-version; \
#   /caps-man manager print; \
#   :delay 10000ms; \
#   /caps-man manager print; \
#   /certificate export-certificate [/caps-man manager get generated-ca-certificate] file-name=$CAPSCERTCA; \
#   /certificate export-certificate [/caps-man manager get generated-certificate]    file-name=$CAPSCERT; \
# }

#######################################
# Turn on VLAN mode
#######################################
/interface bridge set BR1 vlan-filtering=yes comment="VLAN Filtering Enabled"

#######################################
# Install and Cleanup
#######################################
# 1. Install latest RouterOS
#
# 2. Install latest RouterBoard firmware
#
# 3. If you don't already have the CA for DNS imported, this has to be done w/ the device up
#   /tool fetch url="https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem"
#
# 4. Upload the other certificates to Files if not already there
#
# 5. Check date/time if you're having EAP authentication issues
#
# 6. /system reset-configuration no-defaults=yes keep-users=yes skip-backup=yes run-after-reset=mikro1.rsc
