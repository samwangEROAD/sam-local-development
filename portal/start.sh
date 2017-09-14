#!/bin/bash
$(grep -ve "^$" -ve "^#"  ~/.aws/credentials \
	| awk -F ' *= *' \
	'{
		if ($1 ~ /^\[/)
			section=$1;
		else if ($1 !~ /^$/ && section == "[default]" )
			print "export " toupper($1) "=" $2
	}')

docker-compose up
