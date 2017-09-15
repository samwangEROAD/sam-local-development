#!/bin/bash
$(grep -ve "^$" -ve "^#"  ~/.aws/credentials \
	| awk -F ' *= *' \
	'{
		if ($1 ~ /^\[/)
			section=$1;
		else if ($1 !~ /^$/ && section == "[default]" )
			print "export " toupper($1) "=" $2
	}')

export AWS_DEFAULT_REGION=ap-southeast-2
$(aws ecr get-login --no-include-email)
docker-compose up
