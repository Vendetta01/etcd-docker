#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables
source /usr/bin/environment.sh

# functions
function initialize {
    logit "INFO" "Initializing..."

    # TODO: use confd to init etcd-config
    logit "DEBUG" "Starting etcd with ETCDD_CLIENT_SETUP_PORT for initialization"
    /usr/bin/etcd --listen-client-urls ${CLIENT_SETUP_URL} \
	--advertise-client-urls ${CLIENT_SETUP_URL} \
	--name 'etcd' \
	--data-dir '/etcd-data' &
    ETCD_PID=$!

    logit "INFO" "Wait for etcd initialization instance to run"
    while [[ ! $(${INIT_WRAPPER_ETCDCTL} endpoint status) ]]; do
	logit "DEBUG" "Waiting for etcd initialization instance"
	sleep 1
    done

    if [[ -e "${IMPORT_DIR}" ]]; then
	logit "DEBUG" "Importing from directory: ${IMPORT_DIR}"
	# Set etcd_import_dir mode to init (=1)
	/usr/bin/etcd_import_dir_init.sh ${IMPORT_DIR}
    fi

    # Stop etcd initialization instance
    logit "INFO" "Stopping etcd initialization instance..."
    kill ${ETCD_PID}
    wait

    touch "$FIRST_START_FILE_URL"

    logit "INFO" "Initialization done"
}


# main
if [[ ! -e "$FIRST_START_FILE_URL" ]]; then
    initialize
fi

# Start etcd
logit "INFO" "Starting etcd..."
exec /usr/bin/etcd "$@"

