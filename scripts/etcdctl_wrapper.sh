#!/bin/bash

etcdctl --endpoints $(hostname):2379 --cert /etc/ssl/etcd_client.crt --key /etc/ssl/etcd_client.key --cacert /etc/ssl/etcd_rootCA.crt $@

