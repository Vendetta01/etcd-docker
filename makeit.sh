#!/bin/bash

docker container rm -v etcd; docker build -t npodewitz/etcd:test . && docker run -p 2379:2379 -p 2380:2380 --name etcd npodewitz/etcd:test
