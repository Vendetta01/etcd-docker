#!/bin/bash

# Exit immmideiatley if a command exits with a non-zero status.
set -e

# Variables
FIRST_START_FILE_URL=/tmp/first_start_done
SECRET_SSL_CRT=/run/secrets/etcd_ssl_crt
SECRET_SSL_KEY=/run/secrets/etcd_ssl_key
SECRET_ROOT_CRT=/run/secrets/root_crt
ETCD_SSL_BASE_PATH=/etc/ssl
ETCD_SSL_CRT=${ETCD_SSL_BASE_PATH}/etcd_client.crt
ETCD_SSL_KEY=${ETCD_SSL_BASE_PATH}/etcd_client.key
ETCD_SSL_ROOT_CRT=${ETCD_SSL_BASE_PATH}/etcd_rootCA.crt

# functions
function copy_ssl {
    echo "Trying to copy ssl certificate and key from secret"
    if [[ -f "${SECRET_SSL_CRT}" && -f "${SECRET_SSL_KEY}" ]]; then
	echo "Found ssl cert and key in /run/secrets: copying to data-dir..."
	mkdir -p ${ETCD_SSL_BASE_PATH} && \
	    cp -a ${SECRET_SSL_CRT} ${ETCD_SSL_CRT} && \
	    cp -a ${SECRET_SSL_KEY} ${ETCD_SSL_KEY} || \
	    echo "ERROR: ssl cert and key could not be copied!"
    fi
    if [[ -f "${SECRET_ROOT_CRT}" ]]; then
	echo "Root CA found, installing..."
	mkdir -p ${ETCD_SSL_BASE_PATH} && \
	    cp -a ${SECRET_ROOT_CRT} ${ETCD_SSL_ROOT_CRT}
    fi
}

function initialize {
	echo "Initializing..."
	echo "Wait for etcd to run"
	while [[ ! $(/usr/bin/etcdctl_wrapper.sh endpoint status) ]]; do sleep 1; echo "DEBUG: Waiting for etcd"; done

	if [[ -e "${ETCD_IMPORT_FILE}" ]]; then
		echo "DEBUG: Importing..."
		while read -r line; do
			# Split line
			read -ra kv <<< "$line"
			KEY="${kv[0]}"
			VALUE="${kv[@]:1}"
			printf "DEBUG: kv[0]: ${KEY}: kv[1]: ${VALUE}\n"
			printf "${VALUE}" | \
				/usr/bin/etcdctl_wrapper.sh put -- ${KEY}
		done < ${ETCD_IMPORT_FILE}
	fi

	touch "$FIRST_START_FILE_URL"
}


# main
if [[ ! -e "$FIRST_START_FILE_URL" ]]; then
	# Do stuff
	copy_ssl
	initialize &
fi


# Start etcd
exec /usr/bin/etcd "$@"
