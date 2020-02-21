#!/usr/bin/env bash

. authenticate.sh 

url="https://$URL/resources/$ACCT"
curl -s -k -H "$AUTH_TOKEN" $url
