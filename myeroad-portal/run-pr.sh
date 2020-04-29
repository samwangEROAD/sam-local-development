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

$(aws ecr get-login --no-include-email)

# Write ENV to .env file for docker-compose use
echo "PR_NUMBER=$1" > .env

# Always pull image first, as later commits to this PR will create new images with the same Tag (PR-*).
# In case of Tag with the same Digest, it will be skipped.
docker-compose pull

docker-compose up
