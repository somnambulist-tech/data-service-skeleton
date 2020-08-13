
FROM alpine:3.11

RUN apk --update add ca-certificates \
    && apk update \
    && apk upgrade \
    && apk --no-cache add -U \
    # Packages
    bash \
    curl \
    openssl \
    tini \
    syslog-ng-json \
    syslog-ng-xml \
    syslog-ng-sql \
    syslog-ng-scl \
    syslog-ng-redis \
    syslog-ng-map-value-pairs \
    syslog-ng-tags-parser \
    syslog-ng-add-contextual-data \
    syslog-ng-http \
    syslog-ng \
    syslog-ng-amqp \
    # Clean up
    && rm -rf /var/cache/apk/* /tmp/*

COPY config/docker/logger/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

ENV NGDATA /var/log/syslog-ng

RUN mkdir -p "$NGDATA" && chmod 777 "$NGDATA"

VOLUME /var/log/syslog-ng

EXPOSE 514/udp 601/tcp 6514/tcp

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/bin/sh", "-c", "/usr/sbin/syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf"]
