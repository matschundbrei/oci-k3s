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

# TODO
# need to fetch secret from one of the buckets ..
# apparently they got an s3-compatible API:
# https://docs.oracle.com/en-us/iaas/api/#/en/s3objectstorage/20160918/

export K3S_TOKEN=$(shared_secret_todo)

export MASTER_IP=$(master_ip_address)

curl -sfL https://get.k3s.io | sudo -E sh -s - server --cluster-init

# TODO:
# Wait an appropriate amount of time and then store your own internal ipv4 address back to the contrib-store

