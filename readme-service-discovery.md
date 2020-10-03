# Service Discovery

[Traefik](https://traefik.io) is being used to act as a load-balancer and proxy for the
various micro and data services. Traefik requires access to your Docker Host. On a local dev
box this means sharing the `/var/run/docker.sock` file with the container, but on remote
hosts, exposing the remote docker host port either insecure in a highly trusted environment
(port 2375), or over SSL (2376).

The build process will automatically use the local docker socket file unless otherwise
configured.

To fully use the service discovery feature, a local DNS service has been added. This allows
for local host resolution of the *.example.dev domain name.

__Note:__ it is suggested to move the base data services into a separate project so that they
can be shared with other micro services.

### Exposed Services

 * http://dns.example.dev/ - DNSMasq console
 * http://proxy.example.dev/ - Traefik Console / Monitoring
 * http://rabbit.example.dev/ - RabbitMQ Management Panel

### Resources

 * https://traefik.io/
 * https://docs.traefik.io/#the-traefik-quickstart-using-docker
 * https://docs.traefik.io/configuration/backends/docker/
 * https://docs.traefik.io/configuration/acme/
 * https://github.com/jpillora/docker-dnsmasq

## Setup Local DNS Resolution

These instructions are for macOS. For other operating systems, Google it or set custom DNS
servers to use your localhost port 1034.

Create a new resolver configuration file:

```shell script
sudo mkdir /etc/resolver
cd /etc/resolver
sudo nano -w example.dev
```

Add the following contents to this file:

```text
domain example.dev
nameserver 127.0.0.1
port 1034
search_order 10
```

Save the changes (Ctrl+O) (oh, not zero) and exit (Ctrl+X).

Check your DNS via `sudo scutil --dns` it should have output similar to:

```text
resolver #8
  domain   : example.dev
  nameserver[0] : 127.0.0.1
  port     : 1034
  flags    : Request A records, Request AAAA records
  reach    : 0x00030002 (Reachable,Local Address,Directly Reachable Address)
  order    : 10

DNS configuration (for scoped queries)

resolver #1
  nameserver[0] : 8.8.8.8
  nameserver[1] : 8.8.4.4
  if_index : 8 (en0)
  flags    : Scoped, Request A records
  reach    : 0x00000002 (Reachable)
```

Finally: make sure any local `/etc/hosts` entries are removed otherwise they will interfere with
the DNS resolution. Either comment them out or delete the lines entirely.

__Note:__ `/etc/resolver` only reloads on _file_ changes, not file _edits_. If you make a mistake
and need to reload the file, `sudo touch tmp` and then `sudo rm tmp` to force a reload.

__Note:__ you may need to clear your dns cache as well: `sudo killall -HUP mDNSResponder`

## Automatic Service Discovery

Traefik acts as a proxy and load balancer in a similar way to nginx. It listens on port 80 (or any other)
and provides a gui (usually on 8080, but proxy.example.dev:80 gives access as well). LetsEncrypt can
be setup to provide SSL as well as HTTP auth etc.

To register containers with Traefik (called `proxy` in this project), you need to label the container
with specific tags. Any web service should be labeled with:

 * traefik.enable
 * traefik.http.* with configuration directives
 
By default, Traefik will _not_ register new services - they must be explicitly configured.

For example: to expose the example App API and have Traefik route it:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: src/Resources/docker/dev/app/Dockerfile
    networks:
      - backend
    labels:
      traefik.enable: true
      traefik.http.routers.app.rule: "Host(`app.example.dev`)"
      traefik.http.routers.app.tls: true
      traefik.http.services.app.loadbalancer.server.port: 8080
```

By default, the proxy service has automatic SSL forwarding on all hosts, however each app still
needs to explicitly set this. If you are using a `.dev` domain name, then these must be served over
SSL.

Each of the `http` config options needs setting to the services name that this config applies to.
In this example, the service name is "app" - that is the key under the services. This is then used
in each of the router and services options. If your service is named "webserver" then these labels
would be written as:

```yaml
services:
  webserver:
    labels:
      traefik.enable: true
      traefik.http.routers.webserver.rule: "Host(`app.example.dev`)"
      traefik.http.routers.webserver.tls: true
      traefik.http.services.webserver.loadbalancer.server.port: 8080
``` 

The `server.port` is the INTERNAL container port that Traefik should forward requests to. Typically
this is whatever is exposed in the containers Dockerfile e.g.: 8080, 9000, 5432, etc etc. If there
is only one port exposed, this option can be left of, however if there is more than one it must
be provided.

All that is left to do is `dc up -d` and Traefik will pick up the new container and it will be made
available via whatever hostname was set (presuming you are also using the DNS resolver).

If you `dc down` services will automatically be removed.

As the Traefik config is done through labels, they can be added safely to docker-compose files
without interfering with any other configuration. 

__Note:__ you should ensure that any services use the same named network that Traefik is running
under to avoid issues with routing. By default the network name is: `mycompany_network_backend`.
You should change this to reflect your projects name; then in services that need registering
ensure that an external network is defined:

```yaml
networks:
  mycompany_network_backend:
    external: true
```
