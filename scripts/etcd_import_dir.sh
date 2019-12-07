#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables
source /usr/bin/environment.sh

# Set CMD_ETCDCTL as wrapper
if [[ ! ${CMD_ETCDCTL+x} || ${CMD_ETCDCTL} == "" ]]; then
    CMD_ETCDCTL=${WRAPPER_ETCDCTL}
fi

logit "DEBUG" "Starting etcd_import_dir.sh with: CMD_ETCDCTL: ${CMD_ETCDCTL}"

if [[ $# -lt 1 ]]; then
    logit "info" "Usage: $0 path"
    exit 1
fi

if [[ ! -d "$1" ]]; then
    logit "info" "Directory '$1' does not exist! Exiting..."
    exit 2
fi

if [[ ! ${E3CH_MODE+x} ]]; then
    E3CH_MODE=${E3CH_MODE_DEFAULT}
fi
if [[ ! ${E3CH_DIR_VAL+x} ]]; then
    E3CH_DIR_VAL=${E3CH_DIR_VAL_DEFAULT}
fi


TMP_CWD=$(pwd)
cd $1

if [[ ${E3CH_MODE} -ne 0 ]]; then
    for i in $(find . -type d ! -name .); do
	dir=${i:1}
	logit "debug" "Creating directory key '${dir}'"
	printf "%s" "${E3CH_DIR_VAL}" | ${CMD_ETCDCTL} put -- ${dir}
    done
fi

for i in $(find . -type f); do
    key=${i:1}
    if [[ "${key:0:1}" != "/" ]]; then
	logit "info" "Skipping invalid key not starting with '/': '${key}'"
	continue
    fi
    
    logit "debug" "Importing key: '${key}'"

    # Delete last character if it is a newline before putting into etcd
    # (makes editing much easier)
    if [[ "$(tail -c 1 $i | xxd -p -c 1 -l 1)" != "0a" ]]; then
	logit "debug" "Importing without trimming"
	cat $i | ${CMD_ETCDCTL} put -- ${key}
    else
	logit "debug" "Importing with trimming"
	cat $i | head -c -1 | ${CMD_ETCDCTL} put -- ${key}
    fi
done
cd $TMP_CWD

