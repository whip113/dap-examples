#!/usr/bin/env bash

. authenticate.sh

POLICY_FILE=root.yml
POLICYBRANCH=root
# ACCT=$ACCT

url="https://$URL/policies/$ACCT/policy/$POLICYBRANCH"
curl -sk -H "$AUTH_TOKEN" \
  -X PUT \
  -d $(< $POLICY_FILE ) \
  $url > policy-load.out

cat policy-load.out
