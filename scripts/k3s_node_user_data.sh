#!/bin/bash
# Author: Jan Kapellen <jk@solutr.com>
# User-Data for k3s master node
set -euo pipefail
IFS=$'\n\t'

# upgrade
sudo apt-get -y update
sudo apt-get -y upgrade

# install fun tools
sudo apt-get -y install jq 

export MAIN_HOST=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.k3s_main')

export NODE_IP4=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/vnics/ | jq -r '.[].privateIp')
export CLUSTER_CIDR=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.k3s_cluster_cidr')
export SERVICE_CIDR=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.k3s_service_cidr')
export VCN_CIDR_IPV4=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.vcn_v4_cidr')
export VCN_CIDR_IPV6=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.vcn_v6_cidr')

sleep 30 # in the hope that the ipv6 address is configured afterwards

export NODE_IP6=$(sudo ip -6 -j address show dev enp0s3 | jq -r '.[].addr_info[] | if .scope == "global" then .local else empty end')

if [[ -z "$NODE_IP6" ]]; then
  echo "Warning: no ipv6 address found!"
  export NODE_IP="${NODE_IP4}"
else
  export NODE_IP="${NODE_IP4},${NODE_IP6}"
fi

# oci uses iptables in ubuntu images to make your life miserable
# refer to https://docs.k3s.io/installation/requirements
for tcp_port in 6443 10250 2379 2380 10250; do
  sudo -E iptables -I INPUT -s ${VCN_CIDR_IPV4} -p tcp -m state --state NEW -m tcp --dport ${tcp_port} -j ACCEPT
  sudo -E ip6tables -I INPUT -s ${VCN_CIDR_IPV6} -p tcp -m state --state NEW -m tcp --dport ${tcp_port} -j ACCEPT
done

for udp_port in 8472 51820 51821; do
  sudo -E iptables -I INPUT -s ${VCN_CIDR_IPV4} -p udp -m udp --dport ${udp_port} -j ACCEPT
  sudo -E ip6tables -I INPUT -s ${VCN_CIDR_IPV6} -p udp -m udp --dport ${udp_port} -j ACCEPT
done

sudo -E iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null
sudo -E ip6tables-save | sudo tee /etc/iptables/rules.v6 > /dev/null


export K3S_TOKEN=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.k3s_secret')


curl -sfL https://get.k3s.io | sudo -E sh -s - server --node-ip "${NODE_IP}" --cluster-cidr "${CLUSTER_CIDR}" --service-cidr "${SERVICE_CIDR}" --server https://${MAIN_HOST}:6443