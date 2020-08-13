
#
# Reverse Proxy for web services
#

FROM traefik:v2.2

COPY config/docker/proxy/traefik.yaml /etc/traefik/dynamic_conf/conf.yml
COPY config/docker/proxy/certs/* /etc/traefik/certs/
