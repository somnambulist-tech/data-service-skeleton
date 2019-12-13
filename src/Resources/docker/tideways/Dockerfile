
# https://support.tideways.com/article/89-install-in-docker-with-compose

FROM debian:stable-slim

RUN apt-get update && apt-get install -yq --no-install-recommends gnupg2 curl sudo ca-certificates

RUN echo 'deb http://s3-eu-west-1.amazonaws.com/tideways/packages debian main' > /etc/apt/sources.list.d/tideways.list && \
    curl -sS 'https://s3-eu-west-1.amazonaws.com/tideways/packages/EEB5E8F4.gpg' | apt-key add -
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -yq tideways-daemon && \
    apt-get autoremove --assume-yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# sets up the env explicitly as dev; see: https://support.tideways.com/article/42-environments
ENTRYPOINT ["tideways-daemon", " --env=dev", "--hostname=tideways-daemon", "--address=0.0.0.0:9135", "--udp=0.0.0.0:8135"]
