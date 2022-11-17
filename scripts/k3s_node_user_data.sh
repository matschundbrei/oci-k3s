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

export K3S_TOKEN=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.k3s_secret')


curl -sfL https://get.k3s.io | sudo -E sh -s - server --node-ip "${NODE_IP4}" --cluster-cidr "${CLUSTER_CIDR}" --service-cidr "${SERVICE_CIDR}" --server https://${MAIN_HOST}:6443