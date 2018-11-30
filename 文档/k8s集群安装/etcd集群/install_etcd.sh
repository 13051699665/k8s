#!/bin/bash

# Copyright 2014 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Create etcd.conf, etcd.service, and start etcd service.


mkdir -p /usr/local/kubernetes/config
mkdir -p /usr/local/kubernetes/bin

etcd_data_dir=/var/lib/etcd
mkdir -p ${etcd_data_dir}

#ETCD_NAME=${1:-"etcd01"}
#ETCD_INITIAL_CLUSTER=${3:-"etcd01=https://192.168.40.3:2380,etcd02=https://192.168.40.4:2380,etcd03=https://192.168.40.5:2380"}
#CURRENT_HOST_IP=`ip a | grep ens32 | grep 'inet ' | awk '{ print $2}'`

ETCD_NAME="$1"
ETCD_INITIAL_CLUSTER="$2"

if [ ! $ETCD_NAME ]; then
  echo "ENTER ETCD_NAME eg:etcd01"
  exit 1
fi

if [ ! $ETCD_INITIAL_CLUSTER ]; then
  echo "ENTER ETCD_INITIAL_CLUSTER eg:etcd01=https://192.168.40.3:2380,etcd02=https://192.168.40.4:2380,etcd03=https://192.168.40.5:2380"
  exit 1
fi

cp -rf bin/* /usr/local/kubernetes/bin
chmod +x /usr/local/kubernetes/bin/*

ETCD_LISTEN_IP=`ip a | grep ens32 | grep 'inet ' | awk '{ print $2}' | awk -F / '{print $1}'`
ETCD_DATA_DIR="${etcd_data_dir}/default.etcd"
ETCD_LISTEN_PEER_URLS="https://${ETCD_LISTEN_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${ETCD_LISTEN_IP}:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_LISTEN_IP}:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_LISTEN_IP}:2379"
CERT_FILE=/etc/etcd/ssl/etcd.pem
KEY_FILE=/etc/etcd/ssl/etcd-key.pem
PERR_CERT_FILE=/etc/etcd/ssl/etcd.pem
PERR_KEY_FILE=/etc/etcd/ssl/etcd-key.pem
TRUSTED_CA_FILE=/etc/etcd/ssl/ca.pem
PERR_TRUSTED_CA_FILE=/etc/etcd/ssl/ca.pem
cat <<EOF >/usr/local/kubernetes/config/etcd.conf
# [member]
ETCD_NAME="${ETCD_NAME}"
ETCD_DATA_DIR="${etcd_data_dir}/default.etcd"
ETCD_LISTEN_PEER_URLS="https://${ETCD_LISTEN_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${ETCD_LISTEN_IP}:2379"

#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_LISTEN_IP}:2380"
ETCD_INITIAL_CLUSTER="${ETCD_INITIAL_CLUSTER}"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_LISTEN_IP}:2379"

#[certs]
CERT_FILE=/etc/etcd/ssl/etcd.pem
KEY_FILE=/etc/etcd/ssl/etcd-key.pem
PERR_CERT_FILE=/etc/etcd/ssl/etcd.pem
PERR_KEY_FILE=/etc/etcd/ssl/etcd-key.pem
TRUSTED_CA_FILE=/etc/etcd/ssl/ca.pem
PERR_TRUSTED_CA_FILE=/etc/etcd/ssl/ca.pem
EOF

cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=${etcd_data_dir}
EnvironmentFile=-/usr/local/kubernetes/config/etcd.conf
ExecStart=/usr/local/kubernetes/bin/etcd \\
	--name=${ETCD_NAME} \\
	--data-dir=${ETCD_DATA_DIR} \\
	--listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \\
	--listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \\
	--advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \\
	--initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \\
	--initial-cluster=${ETCD_INITIAL_CLUSTER} \\
	--initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \\
	--initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} \\
    --cert-file=${CERT_FILE} \\
    --key-file=${KEY_FILE} \\
    --peer-cert-file=${PERR_CERT_FILE} \\
    --peer-key-file=${PERR_KEY_FILE} \\
    --trusted-ca-file=${TRUSTED_CA_FILE} \\
    --peer-trusted-ca-file=${PERR_TRUSTED_CA_FILE} \\
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
