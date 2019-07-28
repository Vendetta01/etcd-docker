#!/bin/bash

# Exit immmideiatley if a command exits with a non-zero status.
set -e

# Variables
FIRST_START_FILE_URL=/tmp/first_start_done

# functions
function initialize {
	echo "Initializing..."
	echo "Wait for etcd to run"
	while [ ! $(/usr/bin/etcdctl_wrapper.sh endpoint status) ]; do sleep 1; echo "DEBUG: Waiting for etcd"; done

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
	initialize &
fi


# Start etcd
exec /usr/bin/etcd "$@"
