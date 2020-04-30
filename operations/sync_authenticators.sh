#!/usr/bin/env bash

CONTAINER_NAME=dap

docker exec $CONTAINER_NAME \
  evoke variable set \
  CONJUR_AUTHENTICATORS \
  $(curl -sk https://localhost/info \
    | jq -r '.authenticators.configured | join(",")')
