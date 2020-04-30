#!/usr/bin/env bash

HOST=$1
PORTNUMBER=443

echo -n | \
  openssl s_client -connect $HOST:$PORTNUMBER -servername $HOST | \
  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
