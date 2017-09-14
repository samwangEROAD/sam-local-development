# Local Development

The repo holds a collection of docker-compose.yml files that can be used to run
EROADs applications locally so that changes can be verified before merging.

## Structure

Each directory contains a `docker-compose.yml` and a `start.sh`. The `start.sh`
script extracts your AWS credentials from `~/.aws/credentials` so you must first
assume an AWS role, which can be done using
[okta-aws-cli-assume-role](https://github.com/eroad/okta-aws-cli-assume-role).

## Usage example

```
cd portal
okta-awscli
...
./start.sh
```
