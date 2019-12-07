#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables
source /usr/bin/environment.sh

# Set CMD_ETCDCTL before invocation of etcd_import_dir.sh
CMD_ETCDCTL=${INIT_WRAPPER_ETCDCTL} /usr/bin/etcd_import_dir.sh $@

