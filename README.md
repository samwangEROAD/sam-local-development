# Local Development

The repo holds a collection of docker-compose.yml files that can be used to run
EROADs applications locally so that changes can be verified before merging.

## Structure

Each directory contains a `docker-compose.yml`. The `start.sh` script at the root of repository
extracts your AWS credentials from `~/.aws/credentials`, so you must first
assume an AWS role using
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

### Selecting development environment
Local Development is set to use the DEV environment as default. This can be changed using the DEPOT_ENVIRONMENT variable before running the start.sh script. Example:
```bash
export DEPOT_ENVIRONMENT=test
../start.sh
```

### Expose portal to network (linux only)

Run ./expose.sh to allow others on the network to access your portal.

If you are getting the error: Access Denied (publickey) try solving by running

```
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```


# Troubleshooting

## Adding user to docker group
```
sudo gpasswd --add ${USER} docker
newgrp docker
```
## Host is unreachable 

If when running start.sh a load of exceptions are thrown showing "host is unreachable" and others, make sure nothing else (like virtualbox) is running on the IP address specified in the docker-compose.yml file. If so, change these IP addresses in docker-compose.yml.

## Creating network "something_app_net" with driver "bridge"

Where something is the name of a component/folder eg eld. If you're trying to start local-development in a different folder (eg, you started it in portal but are now working in eld) you will need to delete the previous docker network app_net.

```
docker network ls
```
Will show a network with the name something_app_net which you will need to delete.

```
docker network rm something_app_net
```
Will remove the conflicting network. You should be able to run start.sh successfully afterwards.


## Mapping ports on Mac
If you are having trouble accessing your portal instance, try adding a mapping for port 8080 to local port 80 in the docker-compose.yml file (e.g. **local-development/portal/docker-compose.yml**).

To access the remote JVM for debugging, also add a mapping for port 8000.
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
      - 8000:8000
    ...
```
After that, you should be able to navigate to http://127.0.0.1 and everything should be fine!

If you feel like you could use some adrenaline in your day, you could try this:
https://github.com/AlmirKadric-Published/docker-tuntap-osx
