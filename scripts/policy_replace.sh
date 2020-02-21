#!/usr/bin/env bash

if [ "$#" != "2" ];then
    echo "Usage: $0 <branch> <policy_file>"
    exit 1
fi

. authenticate.sh

POLICYBRANCH=$1
POLICY_FILE=$2

url="https://$URL/policies/$ACCT/policy/$POLICYBRANCH"
curl -s -k -H "$AUTH_TOKEN" \
  -X PUT \
  -d "$(< $POLICY_FILE )" \
  $url > policy-load.out

cat policy-load.out
