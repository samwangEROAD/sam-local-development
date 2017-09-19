#!/bin/bash
okta-awscli
$(aws ecr get-login --no-include-email --region ap-southeast-2)
