#!/bin/bash

export OKTA_USERNAME=${OKTA_USERNAME:=}
export OKTA_PASSWORD=${OKTA_PASSWORD:=}
export ROLE_NUMBER_SELECTION=${ROLE_NUMBER_SELECTION:=-1}
okta-awscli -u ${OKTA_USERNAME} -p ${OKTA_PASSWORD} -r ${ROLE_NUMBER_SELECTION}

$(aws ecr get-login --no-include-email --region ap-southeast-2)
