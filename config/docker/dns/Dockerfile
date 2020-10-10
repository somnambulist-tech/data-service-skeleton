
FROM jpillora/dnsmasq

ARG DNS_HOST_IP=${DNS_HOST_IP:-"127.0.0.1"}
ARG PROJECT_DOMAIN=${PROJECT_DOMAIN:-"example.dev"}
ENV HTTP_USER="admin"
ENV HTTP_PASS="admin-dns-secret"

COPY config/docker/dns/dnsmasq.conf /etc/dnsmasq.conf
RUN echo "address=/${PROJECT_DOMAIN}/${DNS_HOST_IP:-}" >> /etc/dnsmasq.conf
