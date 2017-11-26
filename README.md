# Local Development

The repo holds a collection of docker-compose.yml files that can be used to run
EROADs applications locally so that changes can be verified before merging.

## Structure

Each directory contains a `docker-compose.yml` and a `start.sh`. The `start.sh`
script extracts your AWS credentials from `~/.aws/credentials` so you must first
assume an AWS role, which can be done using
[okta-aws-cli-assume-role](https://github.com/eroad/okta-aws-cli-assume-role).

## Prerequisites
* [AWS Command Line Interface](https://aws.amazon.com/cli/)
* [Docker](https://www.docker.com/)
* [Docker Compose] (https://docs.docker.com/compose/install/#install-compose) (The latest version)
* OpenJDK
* [jq](https://stedolan.github.io/jq)
* [okta-aws-cli-assume-role](https://github.com/eroad/okta-aws-cli-assume-role)
* [configuration-cmd](https://github.com/eroad/configuration-cmd)

## Usage example

```bash
./get-login.sh
cd portal
../start.sh
```

# Troubleshooting

## Adding user to docker group
```
sudo gpasswd --add ${USER} docker
newgrp docker
```
## Mapping ports on Mac
If you are having trouble accessing your portal instance, try adding a port mapping on **local-development/portal/docker-compose.yml**:
```
services:
  portal:
    image: 212136148154.dkr.ecr.ap-southeast-2.amazonaws.com/portal
    environment:
      ...
    networks:
      app_net:
        ipv4_address: 172.19.1.2
    links:
      - memcached:memcached
    ports:
      - 80:8080
    ...
```
After that, you should be able to navegate to http://localhost and everything should be fine!

If you feel like you could use some adrenaline in your day, you could try this:
https://github.com/AlmirKadric-Published/docker-tuntap-osx
