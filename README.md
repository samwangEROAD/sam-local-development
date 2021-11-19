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

# Local Docker build with ECR

## What is ECR

ECR is AWS Elastic Container Registry, which holds the docker images that our pipelines produce and also mirrors
public images like `amazoncorretto:17-alpine`

When building docker images locally base images often are pulled from our EROAD ECR docker registry rather than 
directly from docker hub. This is now the expected case as docker hub have introducing rate limiting (and we see
errors if we pull images too frequently from docker hub and exceed their rate limit).

Refer to (eroad/ecr-mirror)[https://github.com/eroad/ecr-mirror] for details on how public third party images are
synced to our ECR registry.  

#### Example - Pulling `amazoncorretto:17-alpine` from docker hub
```bash
FROM amazoncorretto:17-alpine
```

#### Example: Pulling `amazoncorretto:17-alpine` from the EROAD ECR
```bash
FROM 212136148154.dkr.ecr.ap-southeast-2.amazonaws.com/mirrored/docker.io/library/amazoncorretto:17-alpine
```

We pull public third party docker images via ECR to avoid issues with docker hub rate limiting.


## Steps for using ECR

To use ECR we need to authenticate with the ECR docker registry. The following are the steps for this.

Note that [get-login.sh](https://github.com/eroad/local-development/blob/master/get-login.sh) can be used
to automate these steps.

### Step 1: gimme-aws-creds

Ensure you have AWS credentials. Run `gimme-aws-creds` to get or refresh AWS credentials.

Notes:
- If this seems to hang waiting for Google Auth prompt try turning off the VPN.
- When prompted for 2 Google Auth tokens use 2 different tokens (Do not use the same token twice) 

The below command gets/refreshes AWS credentials for the role `IamRoleSsoEngineeringReadOnly`

```bash
docker run --rm -it -v $HOME/.aws:/root/.aws -v $HOME/.okta_aws_login_config:/root/okta_aws_login_config gimme-aws-creds -p IamRoleSsoEngineeringReadOnly
```

### Step 2: Check current aws credentials

```bash
aws sts get-caller-identity
```
Should output something like:
```
{
    "UserId": "...:robin.bygrave",
    "Account": "...",
    "Arn": "..."
}
```

Note that the Account value here is the `account-id` we use to login to ECR.

### Step 3: Docker login to ECR

Perform `docker login` to ERC using our AWS credentials. To do so execute a command like the one below making sure we 
change the `account-id` with your own AWS accountId (12 digit integer - shown in output of `aws sts get-caller-identity`).

- change the `account-id` in the command below with your own AWS accountId
- change the region from `ap-southeast-2` if needed

```bash
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin account-id.dkr.ecr.ap-southeast-2.amazonaws.com
```

### Step 4: Confirm

We can confirm by pulling an image from ECR. For example, the command below pulls `amazoncorretto:17-alpine` via ECR.

```bash
docker pull 212136148154.dkr.ecr.ap-southeast-2.amazonaws.com/mirrored/docker.io/library/amazoncorretto:17-alpine
```

When successful we see output like: 
``` 
17-alpine: Pulling from mirrored/docker.io/library/amazoncorretto
Digest: sha256:ff8ce3c4125ec3da58f2dc2bb3847d0d2bcd14b18678a3b45a3849d14267f49b
Status: Image is up to date for 212136148154.dkr.ecr.ap-southeast-2.amazonaws.com/mirrored/docker.io/library/amazoncorretto:17-alpine
212136148154.dkr.ecr.ap-southeast-2.amazonaws.com/mirrored/docker.io/library/amazoncorretto:17-alpine
```

When we are not logged in to docker ECR we would see output like below suggesting we are not authenticated.
```
Error response from daemon: pull access denied for 212136148154.dkr.ecr.ap-southeast-2.amazonaws.com/mirrored/docker.io/library/amazoncorretto, 
  repository does not exist or may require 'docker login': 
  denied: Your authorization token has expired. Reauthenticate and try again.
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
