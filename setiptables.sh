#/bin/bash

# Version 2.0
# Script to reset IPTables after system reboot or reset tables if they get screwed up.


SC="TableSet"
VSN="2.0"
UN=$(pwd | cut -d / -f3)
IPTABLES="/sbin/iptables"

print() { printf "[${blue}+${NC}] $* \n" ; }

declare -x blue='\e[0;34m'
declare -x NX='\e[0m'

error() {
		print "WTF! You broke it!"
		quit
}

quit() {
	print "[Done!]"
	exit 2
}



echo "SetIPTables Script - Ver. 2.0";
echo "-----------------------------";
echo "[*] Clearing previous entries.";
$IPTABLES -F
$IPTABLES -X
$IPTABLES -t nat -F
$IPTABLES -t nat -X
$IPTABLES -t mangle -F
$IPTABLES -t mangle -X
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT
echo "[*] Setting Rules.";
#Chains
$IPTABLES -N flood
$IPTABLES -A flood -m limit --limit 1/s --limit-burst 20 -j RETURN
$IPTABLES -A flood -j LOG --log-prefix "SYN flood: "
$IPTABLES -A flood -j DROP

# ICMP Accept
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
$IPTABLES -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
$IPTABLES -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

# GLOBAL_ACCEPT

$IPTABLES -A INPUT  -i lo -s 127.0.0.1 -j ACCEPT
$IPTABLES -A OUTPUT -o lo -d 127.0.0.1 -j ACCEPT


$IPTABLES -A INPUT -s 50.23.47.206 -p tcp --source-port 1024:65535 --destination-port 2222 -m comment --comment "Wizard2" -j ACCEPT
$IPTABLES -A OUTPUT -d 50.23.47.206 -p tcp --source-port 2222 --destination-port 1024:65535 -m comment --comment "Wizard2" -j ACCEPT

$IPTABLES -A INPUT -s 24.28.5.0/24 -p tcp --source-port 1024:65535 --destination-port 2222 -m comment --comment "RR" -j ACCEPT
$IPTABLES -A OUTPUT -d 24.28.5.0/24 -p tcp --source-port 2222 --destination-port 1024:65535 -m comment --comment "RR" -j ACCEPT

# Services
# Incoming - service port from anywhere
$IPTABLES -A INPUT -p tcp --source-port 1024:65535 --destination-port 1024:65535 -m recent --name FTP --rcheck --seconds 10800 --rsource -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port 1024:65535 --destination-port 1024:65535 -m recent --name FTP --rcheck --seconds 10800 --rdest -j ACCEPT
$IPTABLES -A INPUT -p tcp --destination-port ftp -m recent --set --name FTP   --rdest -j ACCEPT

$IPTABLES -A INPUT -p tcp --source-port 1024:65535 --destination-port 1024:65535 -m recent --name Minecraft --rcheck --seconds 10800 --rsource -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port 1024:65535 --destination-port 1024:65535 -m recent --name Minecraft --rcheck --seconds 10800 --rdest -j ACCEPT
$IPTABLES -A INPUT -p tcp --destination-port 25565 -m recent --set --name Minecraft --rdest -m comment --comment "Minecraft" -j ACCEPT

$IPTABLES -A INPUT -p tcp --source-port 1024:65535 --destination-port http -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port http --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p udp --source-port 123 --destination-port 123 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port pop3 --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port imap --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p udp --source-port domain --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port domain --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port smtp --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port 1024:65535 --destination-port smtp -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port 1024:65535 --destination-port imap -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port 25 --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port 2222 --destination-port 1024:65535 -m comment --comment "port 2222" -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port mysql --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port https --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port 25565 --destination-port 1024:65535 -m comment --comment "Minecraft" -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port ftp --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port ftp-data --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p tcp --source-port 43 --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A INPUT -p udp --source-port 67 --destination-port 68 -j ACCEPT

# Outgoing - special FTP
$IPTABLES -A OUTPUT -p tcp --source-port 1024:65535 --destination-port 1024:65535 -m recent --name FTP --rcheck --seconds 10800 --rsource -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port 1024:65535 --destination-port 1024:65535 -m recent --name FTP --rcheck --seconds 10800 --rdest -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port ftp -m recent --set --name FTP   --rdest -j ACCEPT

# Outgoing - service port to anywhere
$IPTABLES -A OUTPUT -p tcp --source-port http --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p udp --source-port 123 --destination-port 123 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port pop3 --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port imap --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p udp --source-port domain --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port domain --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port smtp --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port 2222 --destination-port 1024:65535 -m comment --comment "port 2222" -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port mysql --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port https --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port 25565 --destination-port 1024:65535 -m comment --comment "Minecraft" -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port ftp --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port ftp-data --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --source-port 43 --destination-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p udp --source-port 68 --destination-port 67 -j ACCEPT

# Outgoing - any port to service port
$IPTABLES -A OUTPUT -p tcp --destination-port http --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port pop3 --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port imap --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p udp --destination-port domain --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port domain --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port smtp --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port 2222 --source-port 1024:65535 -m comment --comment "port 2222" -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port mysql --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port https --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port 25565 --source-port 1024:65535 -m comment --comment "Minecraft" -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port ftp --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port ftp-data --source-port 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --destination-port 43 --source-port 1024:65535 -j ACCEPT

# Incoming Drop Rules
$IPTABLES -A INPUT -p tcp --tcp-flags FIN,SYN,RST,ACK SYN -j flood
$IPTABLES -A INPUT -f -j DROP
$IPTABLES -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
$IPTABLES -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
#$IPTABLES -A INPUT  -s 0.0.0.0/8 -j DROP
#$IPTABLES -A INPUT  -s 127.0.0.0/8 -j DROP
$IPTABLES -A INPUT  -s 172.16.0.0/12 -j DROP
$IPTABLES -A INPUT  -s 192.168.0.0/16 -j DROP
$IPTABLES -A INPUT -p udp --destination-port domain -j ACCEPT
$IPTABLES -A INPUT -j LOG --log-level 7 --log-prefix "[Firewall - IN DROP] "
$IPTABLES -A INPUT -j DROP

# Outgoing Drop Rules
$IPTABLES -A OUTPUT -j LOG --log-level 7 --log-prefix "[Firewall - OUT DROP] "
$IPTABLES -A OUTPUT -j DROP

#echo "Done!"
quit
