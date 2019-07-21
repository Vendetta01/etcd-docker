#!/bin/bash

etcdctl --cert /etcd-data/fixtures/client/cert.pem --key /etcd-data/fixtures/client/key.pem --insecure-skip-tls-verify $@
