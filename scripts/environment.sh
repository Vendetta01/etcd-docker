#!/bin/bash

# Import envirnoment base
source /usr/bin/environment_base.sh

# Variables
export SECRET_SSL_CRT=/etc/ssl/etcd_client.crt
export SECRET_SSL_KEY=/etc/ssl/etcd_client.key
export SECRET_ROOT_CRT=/etc/ssl/root_ca.crt
export CLIENT_PORT=2379
export CLIENT_SETUP_PORT=9999
export E3CH_MODE_DEFAULT=1
export E3CH_DIR_VAL_DEFAULT="__e3ch_dir_dwTvSi8XOFw=__"

export CLIENT_SETUP_URL=http://localhost:${CLIENT_SETUP_PORT}

export WRAPPER_ETCDCTL="/usr/bin/etcdctl --endpoints $(hostname):${CLIENT_PORT} --cert ${SECRET_SSL_CRT} --key ${SECRET_SSL_KEY} --cacert ${SECRET_ROOT_CRT}"
export INIT_WRAPPER_ETCDCTL="/usr/bin/etcdctl --endpoints ${CLIENT_SETUP_URL}"

