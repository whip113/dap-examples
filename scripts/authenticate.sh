#!/usr/bin/env bash

URL=master.dap.bfloyd.machineidentity.io
ACCT=dap-dev
CUSER=admin
CPASS="Cyberark1"

# Login
api_key=$(curl -sk --user $CUSER:$CPASS https://$URL/authn/$ACCT/login)
if [ "$api_key" = "" ];then
   echo "Failure: Username/Password Incorrect"
   exit 1
fi

# Get Authentication Result
auth_result=$(curl -sk https://$URL/authn/$ACCT/$CUSER/authenticate -d "$api_key")
if [ "$auth_result" = "" ];then
  echo "Failure: Could not retrieve Auth Token with API Key"
  exit 1
fi

token=$(echo -n $auth_result | base64 | tr -d '\r\n')

AUTH_TOKEN="Authorization: Token token=\"$token\""

echo "Authorization: Token token=\"$token\""

