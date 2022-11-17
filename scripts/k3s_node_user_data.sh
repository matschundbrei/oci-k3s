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

export K3S_TOKEN=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.k3s_secret')
export K3S_MAIN_HOST=$(curl -sSL -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.metadata.k3s_main')

curl -sfL https://get.k3s.io | sudo -E sh -s - server --server https://${K3S_MAIN_HOST}:6443