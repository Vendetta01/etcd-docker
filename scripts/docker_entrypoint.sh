#!/bin/bash

# Exit immmideiatley if a command exits with a non-zero status.
set -e

# Variables
FIRST_START_FILE_URL=/tmp/first_start_done
SECRET_SSL_CRT=/run/secrets/etcd_client_ssl_crt
SECRET_SSL_KEY=/run/secrets/etcd_client_ssl_key
SECRET_ROOT_CRT=/run/secrets/root_ca_crt

# functions
function create_etcdctl_wrapper {
    echo "Creating etcdctl_wrapper..."
    echo -e "#!/bin/bash\n/usr/bin/etcdctl --endpoints \$(hostname):2379 --cert ${SECRET_SSL_CRT} --key ${SECRET_SSL_KEY} --cacert ${SECRET_ROOT_CRT} \$@" > /usr/bin/etcdctl_wrapper.sh
    chmod 755 /usr/bin/etcdctl_wrapper.sh
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
	create_etcdctl_wrapper
	initialize &
fi


# Start etcd
exec /usr/bin/etcd "$@"
