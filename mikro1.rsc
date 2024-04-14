###############################################################################
#
# mikro1 configuration
#  model = RB5009UPr+S+IN
#  RouterOS 7.15beta8
#  software id = 4CKA-22DL
#
# VLAN  IP                Usage
# -----------------------------------------
#  100  192.168.100.0/24  Base / Management
#  200  192.168.120.0/24  Server LAN
#  300  192.168.130.0/24  Laptops, Printers, IoT/House
#  400  192.168.140.0/24  VOIP
#  500  192.168.150.0/24  Neighbor
#
# Port VLANS            Usage
# -----------------------------------------
#  1    -               WAN1 - Fiber Provider (req EAP auth)
#  2    100,200,300     wap2
#  3    100,200,300     sw2
#  4    400             ATA
#  5    200             server
#  6    100,200,300     wap3
#  7    100,200,300,500 sw1
#  8    100             Admin
# SFP   100             Disabled
#
###############################################################################
/system identity set name=mikro1

#######################################
# Global Secrets (template)
#######################################

# Fiber EAP Authentication
# :global ATTPORT "ether1"
# :global ATTMAC "xx:xx:xx:xx:xx:xx"
# :global ATTCA "CA_*.pem"
# :global ATTCLIENT "Client_*.pem"
# :global ATTKEY "PrivateKey_PKCS1_*.pem"
# Assign WiFi SSID and Password here
# :global SSIDMAIN "main"
# :global SSIDGUEST "guest"
# :global WPA2MAIN "password"
# :global WPA2GUEST "password"
# :global SERVERIP "192.168.120.2/32"
# :global PRINTERIP "192.168.120.3/32"

# Commented out settings - Legacy from RouterOS 6.x setup
# :global WPA2ADMIN "password"
# :global SSIDADMIN "admin"
# MAC of device from default config.  Certificates use the same MAC (all caps) but no ':'s
# :global CAPSCERTCA "CAPsMAN-CA-xxxxxxxxxxxx.crt"
# :global CAPSCERT "CAPsMAN-xxxxxxxxxxxx.crt"
# Assign WiFi channels here
# :global WAP12G  "CHx"
# :global WAP22G  "CHx"
# :global WAP32G  "CHxx"
# :global WAP15G  "CHxx"
# :global WAP25G  "CHxxx"
# :global WAP35G  "CHxx"
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
/system clock set time="22:00:00"
/system clock set date="mar/30/2024"
/system ntp client set enabled=yes servers=time.cloudflare.com

/log warning "Checkpoint 1"

# AT&T EAP Authentication
/certificate import file-name=$ATTCA passphrase=""
/certificate import file-name=$ATTCLIENT passphrase=""
/certificate import file-name=$ATTKEY passphrase=""
/interface ethernet set [ find default-name=$ATTPORT ] mac-address=$ATTMAC \
  comment="MAC is set to the AT&T Residential Gateway, to match EAP authentication"
/interface dot1x client add certificate=$ATTCLIENT eap-methods=eap-tls \
  identity=$ATTMAC anon-identity=$ATTMAC interface=$ATTPORT

/log warning "Checkpoint 2"
#######################################
# Bridge
#######################################
/interface bridge add name=BR1 protocol-mode=none vlan-filtering=no comment="Disable VLANs while we configure"
/interface bridge add ingress-filtering=no name=BR_ATT protocol-mode=none vlan-filtering=yes comment="AT&T Fiber Port Bridge"

# Ingress
/interface bridge port
add bridge=BR_ATT interface=ether1                                                                           ingress-filtering=no  comment="fiber"
add bridge=BR1    interface=ether2           trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="wap2"
add bridge=BR1    interface=ether3           trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="sw2"
add bridge=BR1    interface=ether4  pvid=400             frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="ata"
add bridge=BR1    interface=ether5  pvid=200             frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="server"
add bridge=BR1    interface=ether6           trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="wap3"
add bridge=BR1    interface=ether7           trusted=yes frame-types=admit-only-vlan-tagged                  ingress-filtering=yes comment="sw1"
add bridge=BR1    interface=ether8  pvid=100             frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="Admin"
#add bridge=BR1 interface=sfp-sfpplus1 pvid=100    frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes comment="Admin"

# Egress
/interface bridge vlan
add bridge=BR1 tagged=BR1,ether2,ether3,ether6,ether7 vlan-ids=100
add bridge=BR1 tagged=BR1,ether2,ether3,ether6,ether7 vlan-ids=200
add bridge=BR1 tagged=BR1,ether2,ether3,ether6,ether7 vlan-ids=300
add bridge=BR1 tagged=BR1                             vlan-ids=400
add bridge=BR1 tagged=BR1,ether7                      vlan-ids=500

/log warning "Checkpoint 3"
#######################################
# IP Addressing & Routing
#   The script will auto-add and remove to the WAN_IPS address list for hairpin NAT support
#     ... this allows using a router's FQDN from internal and external
#######################################
/ip firewall connection tracking set udp-timeout=10s
/ip firewall address-list add comment="wan1" disabled=yes list=WAN_IPS
/ip dhcp-client add disabled=no interface=BR_ATT default-route-distance=1 comment="WAN1 IP" \
  script=":if (\$bound=1) do={ \
    /ip firewall address-list set [/ip firewall address-list find where comment=\"wan1\" && list=WAN_IPS] address=\$\"lease-address\" disabled=no; \
  } else={ \
    /ip firewall address-list set [/ip firewall address-list find where comment=\"wan1\" && list=WAN_IPS] disabled=yes; \
  }"

# For mutiple ISPs and auto fail-over:
#   Setting the route distance allows for auto-failover
#
# /ip firewall address-list add comment="wan2" disabled=yes list=WAN_IPS
# /ip dhcp-client add disabled=no interface=ether2 default-route-distance=2 comment="WAN2 IP" \
#   script=":if (\$bound=1) do={ \
#     /ip firewall address-list set [/ip firewall address-list find where comment=\"wan2\" && list=WAN_IPS] address=\$\"lease-address\" disabled=no; \
#   } else={ \
#     /ip firewall address-list set [/ip firewall address-list find where comment=\"wan2\" && list=WAN_IPS] disabled=yes; \
#   }"

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

# DHCP Debug:
#/system/logging/add topics=dhcp
#/system/logging/remove [find topics~"dhcp" action=memory]

# Use Google DNS (when DoH not ready)
/ip dns set servers=8.8.8.8,8.8.4.4
/ip dns static
add address=8.8.8.8 name=dns.google
add address=8.8.4.4 name=dns.google

/log warning "Checkpoint 4"
###############################################################################
# Firewall
###############################################################################
/interface list add name=WAN
/interface list add name=VLAN
/interface list add name=BASE

/interface list member
add interface=BR_ATT   list=WAN
add interface=VLAN_100 list=BASE
add interface=VLAN_200 list=VLAN
add interface=VLAN_300 list=VLAN
add interface=VLAN_400 list=VLAN
add interface=VLAN_500 list=VLAN
#add interface=BR_ISP2 list=WAN

# Remove this for PPTP, or Load-Balancing issues
/ip settings set rp-filter=strict

/ip firewall filter
# input services the local router only at all the .1 addresses
add chain=input   action=accept               connection-state=established,related,untracked
add chain=input   action=drop                 connection-state=invalid
add chain=input   action=accept               protocol=icmp
add chain=input   action=accept               dst-address=127.0.0.1 comment="accept to local loopback (for CAPsMAN)" 
add chain=input   action=accept               dst-port=53 in-interface-list=VLAN protocol=udp
add chain=input   action=accept               dst-port=53 in-interface-list=VLAN protocol=tcp
add chain=input   action=accept               in-interface-list=BASE comment="Allow Management Vlan Full Access"
add chain=input   action=drop
#add chain=input   action=drop                 in-interface-list=!LAN comment="drop all not coming from LAN" 

# forward services the NAT / Routing
add chain=forward action=accept               ipsec-policy=in,ipsec
add chain=forward action=accept               ipsec-policy=out,ipsec
add chain=forward action=fasttrack-connection connection-state=established,related hw-offload=yes
add chain=forward action=accept               connection-state=established,related,untracked
add chain=forward action=drop                 connection-state=invalid
add chain=forward action=accept               connection-state=new in-interface-list=VLAN out-interface-list=WAN
add chain=forward action=accept               connection-state=new in-interface-list=BASE out-interface-list=WAN
add chain=forward action=accept dst-address=$SERVERIP in-interface-list=BASE comment="full server access from admin"
add chain=forward action=accept protocol=tcp dst-address=$SERVERIP in-interface=VLAN_500 dst-port=8234,32400 comment="plex server - guest vlan"
add chain=forward action=accept protocol=tcp dst-address=$SERVERIP in-interface=VLAN_300 dst-port=8234,32400 comment="plex server - neighbor vlan"
add chain=forward action=accept protocol=udp dst-address=$SERVERIP in-interface=VLAN_300 dst-port=1900,5353,32410-32414 comment="plex server - guest vlan"
add chain=forward action=accept protocol=udp dst-address=$SERVERIP in-interface=VLAN_500 dst-port=1900,5353,32410-32414 comment="plex server - neighbor vlan"
add chain=forward action=accept protocol=tcp dst-address=$SERVERIP in-interface=VLAN_300 dst-port=443 comment="https server - guest vlan"
add chain=forward action=accept protocol=tcp dst-address=$SERVERIP in-interface=VLAN_500 dst-port=443 comment="https server - neighbor vlan"
add chain=forward action=accept protocol=tcp dst-address=$SERVERIP in-interface=VLAN_300 dst-port=25565 comment="Minecraft Java server to Guest VLAN"
add chain=forward action=accept protocol=udp dst-address=$SERVERIP in-interface=VLAN_300 dst-port=19132 comment="Minecraft Bedrock server to Guest VLAN"
add chain=forward action=accept protocol=tcp dst-address=$PRINTERIP in-interface=VLAN_200 dst-port=443,515,631,9100,9400,9500,9501,65001,65002,65003,65004 comment="printer - main vlan TCP"
add chain=forward action=accept protocol=udp dst-address=$PRINTERIP in-interface=VLAN_200 dst-port=5353,9200,9300,9301,9302,3702 comment="printer - main vlan UDP"
add chain=forward action=accept protocol=tcp dst-address=$PRINTERIP in-interface=VLAN_300 dst-port=443,515,631,9100,9400,9500,9501,65001,65002,65003,65004 comment="printer - guest vlan TCP"
add chain=forward action=accept protocol=udp dst-address=$PRINTERIP in-interface=VLAN_300 dst-port=5353,9200,9300,9301,9302,3702 comment="printer - guest vlan UDP"
add chain=forward action=drop   dst-address=$PRINTERIP comment="Disable all other ports on printer"
add chain=forward action=accept connection-nat-state=dstnat comment="For port forwarding to VLANs"
add chain=forward action=drop
#add chain=forward action=drop                 connection-nat-state=!dstnat connection-state=new in-interface-list=WAN comment="drop all from WAN not DSTNATed" 

# Note that the port forwarding uses an address list not an interface list
#  this has a subtle effect of allowing a dynamic list which you need for a hairpin NAT
/ip firewall nat
add chain=srcnat  action=masquerade src-address=192.168.120.0/24 dst-address=192.168.120.0/24 comment="Hairpin NAT"
add chain=srcnat  action=masquerade ipsec-policy=out,none out-interface-list=WAN
add chain=dstnat  action=dst-nat to-addresses=$SERVERIP to-ports=80 protocol=tcp dst-address-list=WAN_IPS dst-port=80 comment="port forward http to server"
add chain=dstnat  action=dst-nat to-addresses=$SERVERIP to-ports=443 protocol=tcp dst-address-list=WAN_IPS dst-port=443 comment="port forward https to server"
add chain=dstnat  action=dst-nat to-addresses=$SERVERIP to-ports=22 protocol=tcp dst-address-list=WAN_IPS dst-port=2222 comment="port forward SSH to server"
add chain=dstnat  action=dst-nat to-addresses=$SERVERIP to-ports=32400 protocol=tcp dst-address-list=WAN_IPS dst-port=32400 comment="port forward plex to server"
add chain=dstnat  action=dst-nat to-addresses=$SERVERIP to-ports=25565 protocol=tcp dst-address-list=WAN_IPS dst-port=25565 comment="port forward minecraft java to server"
add chain=dstnat  action=dst-nat to-addresses=$SERVERIP to-ports=19132 protocol=udp dst-address-list=WAN_IPS dst-port=19132 comment="port forward minecraft bedrock to server"

/ipv6 settings set disable-ipv6=yes max-neighbor-entries=8192

# /ipv6 firewall address-list
# add address=::/128 comment="unspecified address" list=bad_ipv6
# add address=::1/128 comment="lo" list=bad_ipv6
# add address=fec0::/10 comment="site-local" list=bad_ipv6
# add address=::ffff:0.0.0.0/96 comment="ipv4-mapped" list=bad_ipv6
# add address=::/96 comment="ipv4 compat" list=bad_ipv6
# add address=100::/64 comment="discard only " list=bad_ipv6
# add address=2001:db8::/32 comment="documentation" list=bad_ipv6
# add address=2001:10::/28 comment="ORCHID" list=bad_ipv6
# add address=3ffe::/16 comment="6bone" list=bad_ipv6

# /ipv6 firewall filter
# add action=accept chain=input comment="accept established,related,untracked" connection-state=established,related,untracked
# add action=drop chain=input comment="drop invalid" connection-state=invalid
# add action=accept chain=input comment="accept ICMPv6" protocol=icmpv6
# add action=accept chain=input comment="accept UDP traceroute" port=33434-33534 protocol=udp
# add action=accept chain=input comment="accept DHCPv6-Client prefix delegation." dst-port=546 protocol=udp src-address=fe80::/10
# add action=accept chain=input comment="accept IKE" dst-port=500,4500 protocol=udp
# add action=accept chain=input comment="accept ipsec AH" protocol=ipsec-ah
# add action=accept chain=input comment="accept ipsec ESP" protocol=ipsec-esp
# add action=accept chain=input comment="accept all that matches ipsec policy" ipsec-policy=in,ipsec
# add action=drop chain=input comment="drop everything else not coming from LAN" in-interface-list=!LAN
# add action=accept chain=forward comment="accept established,related,untracked" connection-state=established,related,untracked
# add action=drop chain=forward comment="drop invalid" connection-state=invalid
# add action=drop chain=forward comment="drop packets with bad src ipv6" src-address-list=bad_ipv6
# add action=drop chain=forward comment="drop packets with bad dst ipv6" dst-address-list=bad_ipv6
# add action=drop chain=forward comment="rfc4890 drop hop-limit=1" hop-limit=equal:1 protocol=icmpv6
# add action=accept chain=forward comment="accept ICMPv6" protocol=icmpv6
# add action=accept chain=forward comment="accept HIP" protocol=139
# add action=accept chain=forward comment="accept IKE" dst-port=500,4500 protocol=udp
# add action=accept chain=forward comment="accept ipsec AH" protocol=ipsec-ah
# add action=accept chain=forward comment="accept ipsec ESP" protocol=ipsec-esp
# add action=accept chain=forward comment="accept all that matches ipsec policy" ipsec-policy=in,ipsec
# add action=drop chain=forward comment="drop everything else not coming from LAN" in-interface-list=!LAN

# For Auto-failover of WANs:
#/routing filter
#add action=passthrough chain=dynamic-in disabled=no set-check-gateway=ping comment="Failover ping check"

/log warning "Checkpoint 5"
#######################################
# Configuration Services / Router Security
#######################################
/user group set full policy="local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,password,web,sniff,sensitive,api,romon"
/ip neighbor discovery-settings set discover-interface-list=BASE
/ip service disable telnet,ftp,www,api,api-ssl

# Lock down some services on the router
/tool mac-server mac-winbox set allowed-interface-list=BASE
/tool mac-server set allowed-interface-list=BASE
/tool bandwidth-server set enabled=no
/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/ip cloud set ddns-enabled=no update-time=no
/ip ssh set strong-crypto=yes
/ip smb users set [ find default=yes ] disabled=yes
#/ip smb shares set [ find default=yes ] directory=/pub
/system note set show-at-login=no

/log warning "Checkpoint 6"
#######################################
# WiFi / CapsMAN
#######################################
/interface wifi security
add authentication-types=wpa2-psk,wpa3-psk ft=yes ft-over-ds=yes name=SEC_MAIN  passphrase=$WPA2MAIN
add authentication-types=wpa2-psk,wpa3-psk ft=yes ft-over-ds=yes name=SEC_GUEST passphrase=$WPA2GUEST
#add authentication-types=wpa2-psk,wpa3-psk ft=yes ft-over-ds=yes name=SEC_ADMIN passphrase=$WPA2ADMIN

/interface wifi capsman set enabled=yes interfaces=VLAN_100 \
  upgrade-policy=suggest-same-version package-path=/upgrade \
  certificate=auto ca-certificate=auto

/interface wifi datapath add bridge=BR1 name=DP_WIFI_GUEST client-isolation=yes
# client-isolation breaks Chromecast Audio devices, so disabled
/interface wifi datapath add bridge=BR1 name=DP_WIFI_MAIN  client-isolation=no

# Configurations
#   1 per (ssid/vlan, 2g channel, 5g) = 3 AP * 3 SSIDs * 2 Radios = 18 configs, assuming no overlapping channels
#
# Transmit Power Tuning to kludge host steering to 5G
#  1. 2G should be at least 7dB lower than 5G to account for frequency
#  2. Set the Max transmit power to match your clients (15-17dB) otherwise the AP is advertising to hosts it can't service
#  3. Lower all the settings if you have dense coverage or low interference
#add datapath=DP_AC name=CONF_GUEST_2G security=SEC_GUEST ssid=$SSIDGUEST country="United States" tx-power=$TXPWR2G
#add datapath=DP_AC name=CONF_MAIN_2G  security=SEC_MAIN  ssid=$SSIDMAIN  country="United States" tx-power=$TXPWR2G
#add datapath=DP_AC name=CONF_GUEST_5G security=SEC_GUEST ssid=$SSIDGUEST country="United States" tx-power=$TXPWR5G
#add datapath=DP_AC name=CONF_MAIN_5G  security=SEC_MAIN  ssid=$SSIDMAIN  country="United States" tx-power=$TXPWR5G
#add datapath=DP_AC name=CONF_ADMIN_2G security=SEC_ADMIN ssid=$SSIDADMIN country="United States" tx-power=$TXPWR2G hide-ssid=yes
#add datapath=DP_AC name=CONF_ADMIN_5G security=SEC_ADMIN ssid=$SSIDADMIN country="United States" tx-power=$TXPWR5G hide-ssid=yes
#
# NOTE: Do not add `manager=capsman` here unless you hate your life. This will come up as the CAP
#       seeing cAPSman and the router not seeing the CAP
/interface wifi configuration
add datapath=DP_WIFI_GUEST name=CONF_GUEST_2G security=SEC_GUEST ssid=$SSIDGUEST country="United States" channel.band=2ghz-n
add datapath=DP_WIFI_MAIN  name=CONF_MAIN_2G  security=SEC_MAIN  ssid=$SSIDMAIN  country="United States" channel.band=2ghz-n
add datapath=DP_WIFI_GUEST name=CONF_GUEST_5G security=SEC_GUEST ssid=$SSIDGUEST country="United States" channel.band=5ghz-ac skip-dfs-channels=10min-cac
add datapath=DP_WIFI_MAIN  name=CONF_MAIN_5G  security=SEC_MAIN  ssid=$SSIDMAIN  country="United States" channel.band=5ghz-ac skip-dfs-channels=10min-cac

/interface wifi provisioning
add action=create-dynamic-enabled master-configuration=CONF_GUEST_5G slave-configurations=CONF_MAIN_5G supported-bands=5ghz-ac
add action=create-dynamic-enabled master-configuration=CONF_GUEST_2G slave-configurations=CONF_MAIN_2G supported-bands=2ghz-n

# Channel Definition - Taken care of by new drivers/RouterOS 7
# Channel Selection - Letting routers auto-pick for now

# TODO(maxslug) is this not available on cAPSMANv2?
# Improve roaming by kicking clients off of weak APs
# /caps-man access-list add action=reject interface=any signal-range=-120..-88

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
#   Comment out during initial debug to prevent lockouts
#######################################
/interface bridge set BR1 vlan-filtering=yes comment="VLAN Filtering Enabled"

/log warning "Checkpoint 7"
#######################################
# Secure dns over HTTPS
#######################################
#
# TODO(maxslug) Add netwatch script to turn DoH on and off and grab cert the first time
#
#  NOTE: RouterOS does not failover when the DOH stops working :( Maybe this is fixed by now?
#  Google DOH settings (https://forum.mikrotik.com/viewtopic.php?t=160243#p822014)
#/tool fetch url=https://pki.goog/roots.pem
#/certificate import file-name=roots.pem passphrase=""
#/ip dns set use-doh-server=https://dns.google/dns-query verify-doh-cert=yes
#/ip dns set allow-remote-requests=yes cache-max-ttl=1d use-doh-server=https://dns.google/dns-query verify-doh-cert=yes
/ip dns set allow-remote-requests=yes cache-max-ttl=1d

#Switched from https://cloudflare-dns.com/dns-query due to reliability
#/tool fetch url="https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem"
#/certificate import file-name=DigiCertGlobalRootCA.crt.pem passphrase=""
#add address=104.16.248.249 name=cloudflare-dns.com type=A
#add address=104.16.249.249 name=cloudflare-dns.com type=A
#add address=2606:4700:4700::1001 name=ipv6a.cloudflare-dns.com type=AAAA
#add address=2606:4700:4700::1111 name=ipv6b.cloudflare-dns.com type=AAAA

### Script for certificate update
/system script add dont-require-permissions=no name=Certificate_Google \
  policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
  source="/tool fetch url=https://pki.goog/roots.pem\r\n/certificate import file-name=roots.pem passphrase=\"\""

### Schedule to update google certificate once a week
/system scheduler add comment="Google Certificate Update" interval=1w \
  policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
  name=Certificate_Google_Update on-event=Certificate_Google \
  start-date=mar/01/2024 start-time=04:20:00

### Script for DNS cache flush
# /system script add dont-require-permissions=no name=DNS_Flush_Cache \
#   policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
#   source="/ip dns cache flush"

### Schedule to flush dns cache everyday
# /system scheduler add comment="DoH Cache Flush" interval=1d \
#   policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
#   name="DNS Cache Flush" on-event=DNS_Flush_Cache \
#   start-date=nov/01/2020 start-time=05:00:00

/log warning "Checkpoint 8"
#######################################
# Install and Cleanup
#######################################
# 1. Install latest RouterOS and reboot
# 2. Install latest RouterBoard firmware and reboot
# 3. Upload the other certificates to Files if not already there
# 4. Check date/time if you're having EAP authentication issues
# 5. /system reset-configuration no-defaults=yes keep-users=yes skip-backup=yes run-after-reset=mikro1.rsc
