#!/bin/bash

# Variables
export FIRST_START_FILE_URL=/tmp/first_start_done
export SECRET_SSL_CRT=/etc/ssl/etcd_client.crt
export SECRET_SSL_KEY=/etc/ssl/etcd_client.key
export SECRET_ROOT_CRT=/etc/ssl/root_ca.crt
export CLIENT_PORT=2379
export CLIENT_SETUP_PORT=9999
export E3CH_MODE_DEFAULT=1
export E3CH_DIR_VAL_DEFAULT="__e3ch_dir_dwTvSi8XOFw=__"
export DEFAULT_LOG_LEVEL="info"

export CLIENT_SETUP_URL=http://localhost:${CLIENT_SETUP_PORT}

export WRAPPER_ETCDCTL="/usr/bin/etcdctl --endpoints $(hostname):${CLIENT_PORT} --cert ${SECRET_SSL_CRT} --key ${SECRET_SSL_KEY} --cacert ${SECRET_ROOT_CRT}"
export INIT_WRAPPER_ETCDCTL="/usr/bin/etcdctl --endpoints ${CLIENT_SETUP_URL}"


declare -A LOG_LEVELS
LOG_LEVELS=([none]=0 [error]=10 [info]=20 [warn]=30 [debug]=40)


if [[ ! ${LOG_LEVEL+x} ]]; then
    LOG_LEVEL=${DEFAULT_LOG_LEVEL}
fi
LOG_LEVEL_I=${LOG_LEVELS[$LOG_LEVEL]}

# functions
logit () {
    param_log_level=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    param_log_level_i=${LOG_LEVELS[$param_log_level]}
    if [[ ${param_log_level_i} -le ${LOG_LEVEL_I} ]]; then
	echo "$(date -Iseconds): ${1^^}: ${@:2}"
    fi
}

