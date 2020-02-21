#!/usr/bin/env bash

if [ "$#" != "2" ];then
   echo "Usage: $0 <path> <value>"
   exit 1
fi

VARPATH=$1
VARVALUE=$2

. authenticate.sh

curl -s -k -H "$AUTH_TOKEN" \
  --data "$VARVALUE" \
  "https://$URL/secrets/$ACCT/variable/$VARPATH"
