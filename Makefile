
REGISTRY:=npodewitz
IMAGE_NAME:=etcd
CONTAINER_NAME:=${IMAGE_NAME}
DOCKER_RUN_ARGS:=-p 2379:2379 -p 2380:2380
VERSION:=


.PHONY: build build-nc run debug debug-exec stop up clean

build:
	docker build -t ${REGISTRY}/${IMAGE_NAME} .

build-nc:
	docker build -t --no-cache -t ${REGISTRY}/${IMAGE_NAME} .

run:
	docker run -it --name ${CONTAINER_NAME} ${DOCKER_RUN_ARGS} ${REGISTRY}/${IMAGE_NAME}

debug:
	docker run -it --name ${CONTAINER_NAME} --entrypoint /bin/bash ${REGISTRY}/${IMAGE_NAME}

debug-exec:
	docker exec -it ${CONTAINER_NAME} /bin/bash

stop:
	-docker stop ${CONTAINER_NAME}

up: clean build run

clean: stop
	-docker rm -v ${CONTAINER_NAME}
