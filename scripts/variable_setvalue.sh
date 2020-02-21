#!/usr/bin/env bash

VARPATH=$1
VARVALUE=$2

if [ "$#" != "2" ];then
   echo "Usage: $0 <path> <value>"
   exit 1
fi

. authenticate.sh

curl -s -k -H "$AUTH_TOKEN" \
  --data "$VARVALUE" \
  "https://$URL/secrets/$ACCT/variable/$VARPATH"
