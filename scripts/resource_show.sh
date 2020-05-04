#!/usr/bin/env bash

. authenticate.sh

if [ "$#" -ne "2" ]; then
    echo "Usage: $0 <type> <path>"
    echo "Example: $0 policy root"
    exit 1
fi

url="https://$URL/resources/$ACCT/$1/$2"

curl -s -k -H "$AUTH_TOKEN" $url
