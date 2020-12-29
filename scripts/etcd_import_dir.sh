#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -eo pipefail

# Variables
source /usr/bin/environment.sh
RETRY_SLEEP_TIME=1
MAX_RETRY_ATTEMPTS=10

# Functions
function run_with_retry {
    cmd=$1
    max_retry=$2
    sleep_time=$3
    cmd_on_error=$4
    cmd_on_success=$5

    put_attempt=0
    while [[ ${put_attempt} -lt ${max_retry} ]]; do
	eval "${cmd}" && break || true
	sleep $sleep_time
	((put_attempt++)) || true
    done
    if [[ ${put_attempt} -ge ${max_retry} ]]; then
	eval "${cmd_on_error}"
    else
	eval "${cmd_on_success}"
    fi
}


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
	logit "debug" "Creating directory key ${dir@Q}"
	run_with_retry \
	    "printf \"%s\" \"${E3CH_DIR_VAL}\" | ${CMD_ETCDCTL} put -- ${dir}" \
	    ${MAX_RETRY_ATTEMPTS} \
	    ${RETRY_SLEEP_TIME} \
	    "logit \"ERROR\" \"Creating directory key failed: ${dir@Q}\""
    done
fi

for i in $(find . -type f ! -name '*.secret'); do
    key=${i:1}
    if [[ "${key:0:1}" != "/" ]]; then
	logit "info" "Skipping invalid key not starting with '/': ${key@Q}"
	continue
    fi
    
    logit "debug" "Importing key: ${key@Q}"

    # Delete last character if it is a newline before putting into etcd
    # (makes editing much easier)
    if [[ "$(tail -c 1 $i | xxd -p -c 1 -l 1)" != "0a" ]]; then
	logit "debug" "Importing without trimming"
	run_with_retry \
	    "cat $i | ${CMD_ETCDCTL} put -- ${key}" \
	    ${MAX_RETRY_ATTEMPTS} \
	    ${RETRY_SLEEP_TIME} \
	    "logit \"ERROR\" \"Creating directory key failed: ${dir@Q}\""
    else
	logit "debug" "Importing with trimming"
	run_with_retry \
	    "cat $i | head -c -1 | ${CMD_ETCDCTL} put -- ${key}" \
	    ${MAX_RETRY_ATTEMPTS} \
	    ${RETRY_SLEEP_TIME} \
	    "logit \"ERROR\" \"Creating directory key failed: ${dir@Q}\""
    fi
done
cd $TMP_CWD

