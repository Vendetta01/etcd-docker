#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables
source /usr/bin/environment.sh

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 path"
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "Directory '$1' does not exist! Exiting..."
    exit 2
fi

if [[ ! ${E3CH_MODE+x} ]]; then
    E3CH_MODE=${E3CH_MODE_DEFAULT}
fi
if [[ ! ${E3CH_DIR_VAL+x} ]]; then
    E3CH_DIR_VAL=${E3CH_DIR_VAL_DEFAULT}
fi


for i in $(/usr/bin/etcdctl_wrapper.sh get "/" --prefix --keys-only); do
    logit "debug" "exporting key: '${i}'"
    if [[ "${i:0:1}" != "/"  || "{i:1:1}" == "/" ]]; then
	logit "info" "Skipping invalid key (begins either with '//' or not with '/'): '${i}'"
	continue
    fi
    out_file_url=${i:1}

    if [[ ${E3CH_MODE} -ne 0 ]]; then
	value=$(/usr/bin/etcdctl_wrapper.sh get "$i" --print-value-only)
	if [[ "${value}" == "${E3CH_DIR_VAL}" ]]; then
	    logit "debug" "Skipping directory key: '${i}'"
	    continue
	fi
    fi
    
    mkdir -p $(dirname "${out_file_url}")
    /usr/bin/etcdctl_wrapper.sh get "$i" --print-value-only > ${out_file_url}
done

