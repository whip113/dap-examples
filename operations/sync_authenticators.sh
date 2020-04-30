#!/usr/bin/env bash

 CONTAINER_NAME=dap

 CONT=1

 INFO="$(curl -sk https://localhost/info)"

 if [[ "$INFO" == *"\"role\": \"master\""* ]];then
     CONT=0
 elif [[ "$INFO" == *"\"role\": \"follower\""* ]];then
     CONT=0
 fi

 if [ $CONT ]; then
     echo "Role is master or follower..."
     enabled="$(docker exec $CONTAINER_NAME \
         evoke variable list \
         | grep CONJUR_AUTHENTICATORS | cut -f2 -d=)"

     configured="$(echo "$INFO" \
         | jq -r '.authenticators.configured | join(",")')"

     if [ "$enabled" != "$configured" ]; then
         docker exec $CONTAINER_NAME \
             evoke variable set \
             CONJUR_AUTHENTICATORS \
             "$configured"
     fi
 else
     echo "Role is standby..."
 fi
