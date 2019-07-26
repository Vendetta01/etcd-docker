FROM alpine:edge

#LABEL maintainer="..."
#LABEL ..

ENV VERSION=3.3.13
ENV ETCDCTL_API=3
ENV DOCKER_DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download
ENV DOCKER_INSTALL_DIRECTORY=/app/etcd

RUN apk add --update --no-cache bash curl
#RUN apk add --update --no-cache --virtual .build-deps git

RUN curl -L ${DOCKER_DOWNLOAD_URL}/v${VERSION}/etcd-v${VERSION}-linux-amd64.tar.gz -o /tmp/etcd-v${VERSION}-linux-amd64.tar.gz
RUN mkdir -p ${DOCKER_INSTALL_DIRECTORY}
RUN tar xzvf /tmp/etcd-v${VERSION}-linux-amd64.tar.gz -C ${DOCKER_INSTALL_DIRECTORY}/ --strip-components=1
RUN rm -f /tmp/etcd-v${VERSION}-linux-amd64.tar.gz
RUN ln -s ${DOCKER_INSTALL_DIRECTORY}/etcd /usr/bin/etcd
RUN ln -s ${DOCKER_INSTALL_DIRECTORY}/etcdctl /usr/bin/etcdctl

#RUN apk del .build-deps

# Configure
COPY ./etcd.conf.yml.example_test /etc/etcd/etcd.conf.yml

COPY ./etcdctl_wrapper.sh /usr/bin/etcdctl_wrapper.sh


WORKDIR ${DOCKER_INSTALL_DIRECTORY}

EXPOSE 2379 2380

VOLUME ["/etcd-data"]
ENTRYPOINT ["etcd", "--config-file", "/etc/etcd/etcd.conf.yml"]
#CMD ["--config-file", "/etc/etcd/etcd.conf.yml"]

