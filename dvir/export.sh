#!/bin/bash

$(grep -ve "^$" -ve "^#"  ~/.aws/credentials \
	| awk -F ' *= *' \
	'{
		if ($1 ~ /^\[/)
			section=$1;
		else if ($1 !~ /^$/ && section == "[default]" )
			print "export " toupper($1) "=" $2
	}')
export AWS_REGION=ap-southeast-2
export AWS_DYNAMODB_TABLE_PROPERTY=devConfigurationDynamoTableProperties

configuration-cmd export -n dvir
