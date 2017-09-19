#!/bin/bash

# shellcheck disable=SC2091
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

PROPERTIES="$(configuration-cmd export -n dvir)"

DB_HOST="$(echo "${PROPERTIES}" | jq -r '."dvir.jdbc.admin.url"' | sed 's#jdbc:postgresql://##g; s#:5432/dvir##g')"
DB_USER="$(echo "${PROPERTIES}" | jq -r '."dvir.jdbc.admin.username"')"
DB_PASS="$(echo "${PROPERTIES}" | jq -r '."dvir.jdbc.admin.password"')"

PGPASSWORD=${DB_PASS} pg_dump -h "${DB_HOST}" -U "${DB_USER}" dvir > dvir.dump
