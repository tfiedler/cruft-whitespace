#!/usr/bin/env bash
set -x

echo "1" > /proc/sys/net/ipv4/ip_forward # NOW

IPT="iptables" 

# What port?
LBP1="80"
# For Source NAT
SOURCE1="192.168.50.2"

# Destination #1
DEST1="192.168.50.10"
DESTALIAS1="web1"

# Destination #2
DEST2="192.168.50.20"
DESTALIAS2="web2"

${IPT} -F
${IPT} -X
${IPT} -P INPUT ACCEPT
${IPT} -P FORWARD ACCEPT
${IPT} -P OUTPUT ACCEPT

${IPT} -t nat -N snat
${IPT} -t nat -N ${DESTALIAS1}
${IPT} -t nat -N ${DESTALIAS2}

${IPT} -t nat -A PREROUTING -m state --state NEW -m statistic --mode nth --every 2 -j ${DESTALIAS1}
${IPT} -t nat -A PREROUTING -m state --state NEW -m statistic --mode nth --every 1 -j ${DESTALIAS2}

${IPT} -t nat -A POSTROUTING -j snat
${IPT} -t nat -A snat -j SNAT --to-source ${SOURCE1}

${IPT} -t nat -A web1 -j LOG --log-prefix "dnat-to-${DESTALIAS1}: " --log-level 6
${IPT} -t nat -A web1 -p tcp -m tcp --dport ${LBP1} -j DNAT --to-destination ${DEST1}:${LBP1}
${IPT} -t nat -A web2 -j LOG --log-prefix "dnat-to-${DESTALIAS2}: " --log-level 6
${IPT} -t nat -A web2 -p tcp -m tcp --dport ${LBP1} -j DNAT --to-destination ${DEST2}:${LBP1}


${IPT} -A INPUT -p tcp -m state --state NEW -m tcp --dport ${LBP1} -j LOG --log-prefix "LB_${LBP1}_FAILED: "
${IPT} -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
${IPT} -A INPUT -i lo -j ACCEPT
${IPT} -A INPUT  -m limit --limit 5/s --limit burst 10 -p icmp -m icmp --icmp-type 8 -j ACCEPT
${IPT} -A INPUT -m state --state NEW -p tcp -m tcp --dport 22 -j ACCEPT
${IPT} -A INPUT -j DROP

