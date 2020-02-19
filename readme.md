# Data Service Starter Project

This is a skeleton project that pre-configures a shared data services project to act
as the storage / front-end for micro services. It is intended to be used in conjunction
with the [Symfony Micro Service](https://github.com/somnambulist-tech/micro-service-skeleton)
and provides the DNS, proxy, rabbit queue and database(s).

It includes:

 * commented docker-compose.yml file
 * docker configuration including Postgres, dns, Traefik, and RabbitMQ
 * docker is configured to use Docker volumes
 * Tideways config is ready to go for PHP profiling (uncomment to use)
 
Assorted readme files are included for different parts of the service setup:

 * [Service Discovery](readme-service-discovery.md)
 * [Setting up SSL](readme-ssl.md)

## Getting Started

From GitHub, create a new repository from the data-service-skeleton template and then check it out to
your dev machine. Alternatively checkout a detached copy from GitHub and then push to a new repo later.

Customise the base files as you see fit; change names, (especially the service names), config values etc
to suite your needs. Then: `docker-compose up -d` to start the docker environment in dev mode.
Be sure to read [Service Discovery](readme-service-discovery.md) to understand some of how the docker
environment is setup.

### Recommended First Steps

This project uses `example.dev` and placeholders though out. Your first step should be to set the project
names, and dev domain that you will use.

The domain name is set in several places, it is strongly recommended to change this to something more
useful. The following files should be updated:

 * .env
 * docker-compose*.yml
 * src/Resources/docker/proxy/traefik.toml
 * src/Resources/docker/proxy/certs/req.cnf
 * src/Resources/docker/dns/Dockerfile

#### Configured Services

The following docker services are pre-configured for development:

 * PostgreSQL 12
 * RabbitMQ 3.7 + management console
 * DNSmasq
 * syslog-ng 3.22
 * Traefik 1.7
 * Tideways

#### Docker Service Names

The Docker container names will be prefixed by a project name defined in the `.env` file. This is
the constant `COMPOSE_PROJECT_NAME`. If you remove it, the current folder name will be used instead.
For example: you create a new project called "db-service", without setting the COMPOSE constant
the containers started via `docker-compose` will be prefixed with `db-service_`. If you have a
lot of docker projects, they may have similar folder names, so using this constant avoids collisions.

#### DNS Resolution

DNSmasq is included to provide local DNS resolution to avoid needing entries in your /etc/hosts file.
Be sure to check out the instructions in [Service Discovery](readme-service-discovery.md).

If you use a remote docker host, then the scripts will check for the following shell constants:

 * DNS_HOST_IP
 * DOCKER_HOST
 * DOCKER_HOST_ALT

`DNS_HOST_IP` is the IP address of the _host_ running DNSmasq i.e. the docker host IP address.
`DOCKER_HOST` is the host name of the docker host, and must be fully qualified. For example:
`DOCKER_HOST="tcp://my-docker-host.example.dev:2375"`. This is presuming you have a trusted
docker host that is not secured. If you do not have DNS translation, then `DOCKER_HOST_ALT`
can be used with the IP address of the docker host: `DOCKER_HOST_ALT="tcp://192.168.1.2:2375"`
The `_HOST_` constants are used in `docker-compose.yml` on the proxy service.

## Contributing

Contributions are welcome! Spot an error, want additional docs or something better explaining? Then
create a ticket on the project, or open a PR.
