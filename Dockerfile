ARG ETCDCTL_API=3
ARG ETCDCTL_VERSION=3.4.1

FROM alpine:edge AS BUILD


ARG ETCDCTL_API
ARG ETCDCTL_VERSION
ENV DOCKER_DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download
ENV DOCKER_INSTALL_DIRECTORY=/app/etcd

LABEL local.podewitz.etcd.version=${ETCDCTL_VERSION}
LABEL local.podewitz.etcd.maintainer="Nils Podewitz <nils.podewitz@googlemail.com>"


RUN apk add --update --no-cache bash curl git vim

RUN mkdir -p ${DOCKER_INSTALL_DIRECTORY}
RUN curl -L ${DOCKER_DOWNLOAD_URL}/v${ETCDCTL_VERSION}/etcd-v${ETCDCTL_VERSION}-linux-amd64.tar.gz -o /tmp/etcd-v${ETCDCTL_VERSION}-linux-amd64.tar.gz
RUN tar xzvf /tmp/etcd-v${ETCDCTL_VERSION}-linux-amd64.tar.gz -C ${DOCKER_INSTALL_DIRECTORY}/ --strip-components=1
RUN rm -f /tmp/etcd-v${ETCDCTL_VERSION}-linux-amd64.tar.gz
RUN ln -s ${DOCKER_INSTALL_DIRECTORY}/etcd /usr/bin/etcd
RUN ln -s ${DOCKER_INSTALL_DIRECTORY}/etcdctl /usr/bin/etcdctl

# Configure
COPY ./etcd.conf.yml.example /etc/etcd/etcd.conf.yml
COPY scripts/* /usr/bin/

WORKDIR ${DOCKER_INSTALL_DIRECTORY}

EXPOSE 2379 2380

VOLUME ["/etcd-data"]
ENTRYPOINT ["docker_entrypoint.sh"]
CMD ["--config-file", "/etc/etcd/etcd.conf.yml"]


FROM alpine:edge AS RELEASE

ARG ETCDCTL_API
ARG ETCDCTL_VERSION

LABEL local.podewitz.etcd.version=${ETCDCTL_VERSION}
LABEL local.podewitz.etcd.maintainer="Nils Podewitz <nils.podewitz@googlemail.com>"


RUN apk add --update --no-cache bash

RUN addgroup -g 10001 etcduser && \
    adduser -S -u 10001 -G etcduser etcduser && \
    mkdir -p /etcd-data && \
    chown etcduser:etcduser /etcd-data
USER etcduser

COPY --from=BUILD /usr/bin/etcd /usr/bin/etcd
COPY --from=BUILD /usr/bin/etcdctl /usr/bin/etcdctl
COPY ./etcd.conf.yml.example /etc/etcd/etcd.conf.yml
COPY scripts/* /usr/bin/

WORKDIR /tmp

EXPOSE 2379 2380

VOLUME ["/etcd-data"]
ENTRYPOINT ["docker_entrypoint.sh"]
CMD ["--config-file", "/etc/etcd/etcd.conf.yml"]

