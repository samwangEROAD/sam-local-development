#!/bin/bash

set -e

AWK=awk
if [[ "$(uname)" == 'Darwin' ]]; then
	AWK=gawk
fi

$(grep -ve "^$" -ve "^#"  ~/.aws/credentials \
	| ${AWK} -F ' *= *' \
	'{
		if ($1 ~ /^\[/)
			section=$1;
		else if ($1 !~ /^$/ && section == "[default]" )
			print "export " toupper($1) "=" $2
	}')

export AWS_DEFAULT_REGION=ap-southeast-2
export AWS_REGION=${AWS_DEFAULT_REGION}
export DEPOT_ENVIRONMENT=${DEPOT_ENVIRONMENT:=dev}
$(aws ecr get-login --no-include-email)
docker-compose up
