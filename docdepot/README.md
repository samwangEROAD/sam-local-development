# docdepot

docdepot generates docker-compose files for testing EROAD components locally.

## Before you start

By default components will use dynamic configuration and discovery for the dev environment.

It's important to note that if you are testing a component that will do database migrations, those
migrations will happen on the dev database unless you link the appropriate database container in 
your compose file. 

## Generating a docker compose file

Get the latest release of **docdepot** from https://github.com/eroad/local-development/releases

```
chmod +x ~/Downloads/docdepot
mv ~/Downloads/docdepot /usr/local/bin/
docdepot generate [image_name,image_name...]
```

## Removing the docdepot containers and network  
```
docdepot rm [--force]
```

## Adding a new image

Add your component to the **docdepot.yml** template file.

## Examples

### Portal, deploying war from your local maven repo
```
docdepot generate portal 
```

### Portal, built from pull request 42
```
docdepot generate portal:PR-1200 
```

### Latest Portal, pointing to DVIR built from pull request 42
```
docdepot generate portal:latest dvir:PR-42 
```

### Latest Portal, latest DVIR, pointing DVIR to a fresh database
```
docdepot generate portal:latest dvir:latest dvir-rds
```

### Postgres and Rabbitmq so that you can run component tests from your IDE
```
docdepot generate postgres rabbitmq
```

### Overriding dynamic config

Add your properties in **~/.docdepot/tmp/dynamicconfig.properties**.