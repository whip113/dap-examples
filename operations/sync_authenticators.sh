 #!/usr/bin/env bash

 CONTAINER_NAME=dap

 enabled="$(docker exec $CONTAINER_NAME \
     evoke variable list \
     | grep CONJUR_AUTHENTICATORS | cut -f2 -d=)"

 configured="$(curl -sk https://localhost/info \
     | jq -r '.authenticators.configured | join(",")')"

 if [ "$enabled" != "$configured" ]; then
     docker exec $CONTAINER_NAME \
         evoke variable set \
         CONJUR_AUTHENTICATORS \
         "$configured"
 fi
