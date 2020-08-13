# Traefik SSL

Traefik natively supports LetsEncrypt and other SSL mechanisms. If you have an external IP then
read the docs: https://docs.traefik.io/https/acme/

If you wish to use your own self-generated cert or a manually configured LetsEncrypt, read on.

## Generating a self-signed SSL cert

Traefik requires an SSL certificate. Use the following in dev to generate a self-signed cert:

__Note:__ be sure to first edit the `req.cnf` file BEFORE generating the certificate!

```shell script
cd config/docker/proxy/certs
openssl req -x509 -nodes -days 800 -newkey rsa:2048 -keyout server.key -out server.pem -config req.cnf -sha256
```

This step uses the `req.cnf` configuration file. This contains default answers to the SSL signing
questions. Be sure to update it with your details / dev domain (the default is example.dev).

To install a revised cert stop all services and then force build the containers.

This certificate will need adding to your Keychain in order to use it. It should be flagged as "trusted".
Once added to the keychain, you will need to restart any browsers for them to see the new certificate.

Only use this option in your dev environment!

Instead of a self-signed cert, you could use a free wildcard SSL or any other issued SSL cert.

## LetsEncrypt

[ZeroSSL](https://zerossl.com) can be used to create a LetsEncrypt certificate. This requires that you
have a domain that you have control over and can set for responding to LetsEncrypt enquiries.

ZeroSSL will generate an Account Key. You must save this to `account.key` as it will be used next
time you need to issue an SSL cert. This account key will be linked to verifying your domain.

Follow the instructions at: https://zerossl.com/free-ssl/#crt

Be sure to save the Certificate Signing Request as `server.csr` so you can re-use it later.

Once the certificate has been generated and validated copy the PEM into `server.pem`.

To install a revised cert stop all services and then force build the containers.

__Note:__ the correct account key must be used, otherwise the DNS validation will fail.
