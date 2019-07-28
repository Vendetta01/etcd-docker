ARG ETCDCTL_API

FROM alpine:edge AS BUILD

LABEL local.podewitz.version="3.3.13"
LABEL local.podewitz.maintainer="Nils Podewitz <nils.podewitz@googlemail.com>"

ENV VERSION=3.3.13
ENV ETCDCTL_API=${ETCDCTL_API:-3}
ENV DOCKER_DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download
ENV DOCKER_INSTALL_DIRECTORY=/app/etcd

RUN apk add --update --no-cache bash curl git vim


RUN mkdir -p ${DOCKER_INSTALL_DIRECTORY}
RUN curl -L ${DOCKER_DOWNLOAD_URL}/v${VERSION}/etcd-v${VERSION}-linux-amd64.tar.gz -o /tmp/etcd-v${VERSION}-linux-amd64.tar.gz
RUN tar xzvf /tmp/etcd-v${VERSION}-linux-amd64.tar.gz -C ${DOCKER_INSTALL_DIRECTORY}/ --strip-components=1
RUN rm -f /tmp/etcd-v${VERSION}-linux-amd64.tar.gz
RUN ln -s ${DOCKER_INSTALL_DIRECTORY}/etcd /usr/bin/etcd
RUN ln -s ${DOCKER_INSTALL_DIRECTORY}/etcdctl /usr/bin/etcdctl


# Configure
COPY ./etcd.conf.yml.example_test /etc/etcd/etcd.conf.yml
COPY ./scripts/etcdctl_wrapper.sh /usr/bin/etcdctl_wrapper.sh
COPY scripts/* /usr/bin/


WORKDIR ${DOCKER_INSTALL_DIRECTORY}

EXPOSE 2379 2380

VOLUME ["/etcd-data"]
ENTRYPOINT ["docker_entrypoint.sh"]
CMD ["--config-file", "/etc/etcd/etcd.conf.yml"]

COPY ./test.kv /tmp/test.kv
ENV ETCD_IMPORT_FILE=/tmp/test.kv


FROM alpine:edge AS RELEASE

ENV ETCDCTL_API=${ETCDCTL_API:-3}

RUN apk add --update --no-cache bash

COPY --from=BUILD /usr/bin/etcd /usr/bin/etcd
COPY --from=BUILD /usr/bin/etcdctl /usr/bin/etcdctl
COPY scripts/* /usr/bin/

