#!/bin/bash

NODE1="manjarobook"
REGISTRY=quay.io/coreos/etcd
DATA_DIR="etcd-data"

docker volume create --name ${DATA_DIR}

docker run \
	-p 2379:2379 \
	-p 2380:2380 \
	--volume ${DATA_DIR}:/${DATA_DIR} \
	--name etcd ${REGISTRY}:latest \
	/usr/local/bin/etcd \
	--data-dir=${DATA_DIR} --name node1 \
	--initial-advertise-peer-urls http://${NODE1}:2380 \
	--listen-peer-urls http://0.0.0.0:2380 \
	--advertise-client-urls http://${NODE1}:2379 \
	--listen-client-urls http://0.0.0.0:2379 \
	--initial-cluster node1=http://${NODE1}:2380
