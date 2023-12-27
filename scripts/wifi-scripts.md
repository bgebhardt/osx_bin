# Wifi scripts and tools

see in Obsidian vault - [wifi-scripts.md](hook://file/ZY0507MAP?p=YmluL3NjcmlwdHM=&n=wifi%2Dscripts%2Emd)

A set of scripts, tools, articles and notes to check wifi


/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan

# Check Gebhardt wifi connection quality

This script will check for an increase in noise level.

Steps
- Check if wifi connected
- Check noise level - agrCtlNoise: 0
- Alert on noise level or disconnection
- Check 
- Check last transmit rate - if low many times in a row alert

similar to battery script created in Scripts directory

# yFi app
Great menubar app to detect your transmission rate. 
In my network the rate varies brom 150-170 to 800 a lot so I can't really use it to reconnect or notify.

[yFi - stay connected to your WiFi](https://yfi.coderose.io/)
[rose-m/yFi-app: yFi App is a small macOS status bar application that helps you keep a good WiFi connection.](https://github.com/rose-m/yFi-app)

# Monitoring Network Strength
from [Test Wireless Signal Strength from Command Line of Mac OS X](https://osxdaily.com/2010/07/07/test-wireless-signal-strength-from-the-command-line/)
see link for even better ideas in the comments.

> while true; do /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep CtlRSSI; sleep 0.5; done
agrCtlRSSI: -46
agrCtlRSSI: -48

*single line version*
clear; while x=1; do /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep CtlRSSI | sed -e 's/^.*://g' | xargs -I SIGNAL printf "\rRSSI dBm: SIGNAL"; sleep 0.5; done

# Monitor Wifi Noise

> while true; do /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep CtlNoise; sleep 0.5; done
agrCtlNoise: -89


# Example of my networks scans

## Text info from option-click on Wifi menu

Gebhardt

IP Address: 10.0.0.179
Router: 10.0.0.1
Security: WPA2 Personal
BSSID: 32:bb:e5:54:bd:15
Channel: 44 (5 GHZ, 80 MHz)
Country Code: US
RSSI: -38 dBm
Noise: -90 dBm
Tx Rate: 144 Mbps
PHY Mode: 802.11ac
MCS Index: 8
NSS: 2

## Good state
Connected to Brady's room xpod.
     agrCtlRSSI: -37 to -41
    agrCtlNoise: -89
     lastTxRate: 780
        maxRate: 867

/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
     agrCtlRSSI: -41
     agrExtRSSI: 0
    agrCtlNoise: -89
    agrExtNoise: 0
          state: running
        op mode: station
     lastTxRate: 780
        maxRate: 867
lastAssocStatus: 0
    802.11 auth: open
      link auth: wpa2-psk
          BSSID:
           SSID: Gebhardt
            MCS: 8
  guardInterval: 400
            NSS: 2
        channel: 44,80

## Bad state - disconnected or connected to Gateway
Seeing noise at 0 is bad
    agrCtlNoise: 0

/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
     agrCtlRSSI: -41
     agrExtRSSI: 0
    agrCtlNoise: 0
    agrExtNoise: 0
          state: running
        op mode: station
     lastTxRate: 650
        maxRate: 867
lastAssocStatus: 0
    802.11 auth: open
      link auth: wpa2-psk
          BSSID:
           SSID: Gebhardt
            MCS: 7
  guardInterval: 800
            NSS: 2
        channel: 44,80

## Example connected to GebhardtN2
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
     agrCtlRSSI: -64
     agrExtRSSI: 0
    agrCtlNoise: -89
    agrExtNoise: 0
          state: running
        op mode: station
     lastTxRate: 6
        maxRate: 144
lastAssocStatus: 0
    802.11 auth: open
      link auth: wpa2-psk
          BSSID:
           SSID: GebhardtN2
            MCS: 0
  guardInterval: 800
            NSS: 1
        channel: 8

## Example when disconnected
look for state scanning or authenticating or init

/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
     agrCtlRSSI: 0
     agrExtRSSI: 0
    agrCtlNoise: 0
    agrExtNoise: 0
          state: scanning
        op mode:
     lastTxRate: 0
        maxRate: 0
lastAssocStatus: 0
    802.11 auth: open
      link auth: wpa2-psk
          BSSID:
           SSID:
            MCS: -1
  guardInterval: -1
            NSS: -1
        channel: 1

/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
     agrCtlRSSI: 0
     agrExtRSSI: 0
    agrCtlNoise: 0
    agrExtNoise: 0
          state: authenticating
        op mode:
     lastTxRate: 0
        maxRate: 0
lastAssocStatus: 65535
    802.11 auth: open
      link auth: wpa2-psk
          BSSID:
           SSID:
            MCS: -1
  guardInterval: -1
            NSS: -1
        channel: 1

# Example commands and outputs

some cmds assume a symlink

## Create a symlink to the AirPort command in Terminal
ln -s /System/Library/PrivateFrameworks/Apple80211.framework/
Versions/Current/Resources/airport /Usr/bin/airport

## View available Wi-Fi networks
airport -s

## Join Wi-Fi network
networksetup -setairportnetwork en0 SSID_OF_WIRELESS_NETWORK WIRELESS_NETWORK_PASSPHRASE

# Create a Wi-Fi network profile
networksetup -addpreferredwirelessnetworkatindex en0 SSID_OF_NETWORK INDEX_NUMBER SECURITY_OF_WIRELESS_NETWORK WIRELESS_NETWORK_PASSPHRASE

## Enable or Disable Wi-Fi
networksetup -setairportpower en0 on (or off)

## airport help
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --help
Supported arguments:
 -c[<arg>] --channel=[<arg>]    Set arbitrary channel on the card
 -z        --disassociate       Disassociate from any network
 -I        --getinfo            Print current wireless status, e.g. signal info, BSSID (requires sudo), port type etc.
 -s[<arg>] --scan=[<arg>]       Perform a wireless broadcast scan.
				   Will perform a directed scan if the optional <arg> is provided.
				   BSSID and country code information requires sudo.
 -x        --xml                Print info as XML
 -P        --psk                Create PSK from specified pass phrase and SSID.
				   The following additional arguments must be specified with this command:
                                  --password=<arg>  Specify a WPA password
                                  --ssid=<arg>      Specify SSID when creating a PSK
 -h        --help               Show this help

## airport scan
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan

                            SSID BSSID             RSSI CHANNEL HT CC SECURITY (auth/unicast/group)
    DIRECT-81-HP ENVY Photo 7800                   -88  44,+1   Y  -- RSN(PSK/AES/AES)
                     xfinitywifi                   -88  36      Y  -- NONE
                    whlinksysnew                   -83  44      Y  -- RSN(PSK/AES/AES)
                  ontheair-guest                   -79  149     Y  -- RSN(PSK/AES/AES)
                           Gnvna                   -79  157     Y  -- RSN(PSK/AES/AES)
                     xfinitywifi                   -79  157     Y  -- NONE
                         XFINITY                   -79  157     Y  -- RSN(802.1x/AES/AES)
                        ontheair                   -78  149     Y  -- RSN(PSK/AES/AES)
                  ontheair-guest                   -78  149     Y  -- RSN(PSK/AES/AES)
                  ontheair-guest                   -75  149     Y  -- RSN(PSK/AES/AES)
                    TMOBILE-WiFi                   -74  161     Y  -- RSN(PSK,SAE/AES/AES)
                        ontheair                   -73  149     Y  -- RSN(PSK/AES/AES)
                       dannernet                   -72  11      Y  -- RSN(PSK/AES/AES)
                        ontheair                   -70  1       Y  -- RSN(PSK/AES/AES)
                  ontheair-guest                   -69  1       Y  -- RSN(PSK/AES/AES)
                    TP-Link_B672                   -68  2       Y  -- WPA(PSK/AES,TKIP/TKIP) RSN(PSK/AES,TKIP/TKIP)
                         TEG-1K3                   -64  8       Y  -- RSN(PSK/AES,TKIP/TKIP)
                    whlinksysnew                   -63  9       Y  -- RSN(PSK/AES/AES)
                      GebhardtN2                   -63  8       Y  -- WPA(PSK/TKIP,AES/TKIP) RSN(PSK/TKIP,AES/TKIP)
                        ontheair                   -61  11      Y  -- RSN(PSK/AES/AES)
                  ontheair-guest                   -61  11      Y  -- RSN(PSK/AES/AES)
                     GebhardtWAP                   -60  3       Y  -- RSN(PSK/AES/AES)
                        Gebhardt                   -55  6       Y  -- RSN(PSK/AES/AES)
                    TMOBILE-WiFi                   -54  6       Y  -- RSN(PSK,SAE/AES/AES)
                    TMOBILE-WiFi                   -68  40      Y  -- RSN(PSK,SAE/AES/AES)
                        Gebhardt                   -66  44      Y  -- RSN(PSK/AES/AES)
                        Gebhardt                   -34  1       Y  -- RSN(PSK/AES/AES)
                         XFINITY                   -58  157     Y  -- RSN(802.1x/AES/AES)
                     xfinitywifi                   -58  157     Y  -- NONE
                        Gebhardt                   -58  157     Y  -- RSN(PSK/AES/AES)
                        Gebhardt                   -39  44      Y  -- RSN(PSK/AES/AES)

## networksetup -listallhardwareports

Hardware Port: Ethernet Adapter (en4)
Device: en4
Ethernet Address: 56:e3:99:8e:ae:c0

Hardware Port: Ethernet Adapter (en5)
Device: en5
Ethernet Address: 56:e3:99:8e:ae:c1

Hardware Port: AX88179A
Device: en6
Ethernet Address: a0:ce:c8:9e:45:fc

Hardware Port: Ethernet Adapter (en7)
Device: en7
Ethernet Address: 56:e3:99:8e:ae:c2

Hardware Port: Thunderbolt Bridge
Device: bridge0
Ethernet Address: 36:f3:ca:e5:3e:c0

Hardware Port: Wi-Fi
Device: en0
Ethernet Address: c8:89:f3:b6:f4:41

Hardware Port: Thunderbolt 1
Device: en1
Ethernet Address: 36:f3:ca:e5:3e:c0

Hardware Port: Thunderbolt 2
Device: en2
Ethernet Address: 36:f3:ca:e5:3e:c4

Hardware Port: Thunderbolt 3
Device: en3
Ethernet Address: 36:f3:ca:e5:3e:c8

VLAN Configurations
===================



# Research links

[How to manage Wi-Fi with Terminal commands on OS X | TechRepublic](https://www.techrepublic.com/article/pro-tip-manage-wi-fi-with-terminal-commands-on-os-x/)

[Mac Terminal WiFi Commands - MattCrampton.com](https://www.mattcrampton.com/blog/managing_wifi_connections_using_the_mac_osx_terminal_command_line/) - has info on common networksetup commands for turning airport off/on, connecting to a network, etc.


[Test Wireless Signal Strength from Command Line of Mac OS X](https://osxdaily.com/2010/07/07/test-wireless-signal-strength-from-the-command-line/)

## MCS
Info on MCS index
[What is the MCS Index?](https://netbeez.net/blog/what-is-mcs-index/)

MCS in my network varies between 7 and 8.
Channel is 44 and width is 80 Mhz
NS = Spacial Streams which is 2.

/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
     agrCtlRSSI: -41
     agrExtRSSI: 0
    agrCtlNoise: 0
    agrExtNoise: 0
          state: running
        op mode: station
     lastTxRate: 650
        maxRate: 867
lastAssocStatus: 0
    802.11 auth: open
      link auth: wpa2-psk
          BSSID:
           SSID: Gebhardt
            MCS: 7
  guardInterval: 800
            NSS: 2
        channel: 44,80