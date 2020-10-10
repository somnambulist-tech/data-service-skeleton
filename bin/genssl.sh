#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"; if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi;
if [[ -f "${DIR}/../.env" ]]; then . "${DIR}/../.env"; fi;

cd config/docker/proxy/certs

printf "Generating new self-signed SSL certificate in ${PWD}\n\n"

if [ ! -z "$PROJECT_DOMAIN" ]; then
  current=$(awk '/CN = *./ {print $(NF)}' req.cnf)
  current=${current/'*.'/''}

  printf "Updating domain '${current}' in req.cnf with '${PROJECT_DOMAIN}'\n"

  sed -i 'bak' "s/${current}/${PROJECT_DOMAIN}/g" req.cnf
  printf "   ...removing backup file\n"
  rm -f req.cnfbak
fi

openssl req -x509 -nodes -days 800 -newkey rsa:2048 -keyout server.key -out server.pem -config req.cnf -sha256 &>/dev/null

echo "
Certificate generated successfully

You will need to stop all services and rebuild the Traefik container, before it
can be used in this project.

Note: the PEM file must be added to your keychain / SSL auth list before accessing
any site, as it is untrusted.

On macOS add to your Certificates in KeyChain Access.app, or via CLI:
sudo security add-trusted-cert -d -r trustRoot -k \"/Library/Keychains/System.keychain\" ${PWD}/server.pem

"
