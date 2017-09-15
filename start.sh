#!/bin/bash
if [[ "$(uname)" == 'Linux' ]]; then
	AWK=awk
elif [[ "$(uname)" == 'Darwin' ]]; then
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
$(aws ecr get-login --no-include-email)
docker-compose up
