#!/bin/bash

export AWS_REGION=${AWS_REGION:=ap-southeast-2}

if [[ -x ~/.local/bin/gimme-aws-creds ]] || [[ -n `which gimme-aws-creds` ]]
then
    gimme-aws-creds
else
    export OKTA_USERNAME=${OKTA_USERNAME:=}
    export OKTA_PASSWORD=${OKTA_PASSWORD:=}
    export ROLE_NUMBER_SELECTION=${ROLE_NUMBER_SELECTION:=-1}
    okta-awscli -u ${OKTA_USERNAME} -p ${OKTA_PASSWORD} -r ${ROLE_NUMBER_SELECTION}
fi

aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin \
    `aws sts get-caller-identity --query "Account" --output text`.dkr.ecr.${AWS_REGION}.amazonaws.com
