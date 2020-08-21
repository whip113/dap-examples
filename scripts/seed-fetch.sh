#!/usr/bin/env bash

function prompt_confirm {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; return 0 ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac
  done
}

function _docker_prefix_cmd {
    if [ "$(command -v docker)" = "" ]; then
        echo "Could not find docker! Is it installed?"
        exit 1
    fi
    if [ "$(docker ps >/dev/null 2>&1)" = "1" ]; then
         echo "sudo "
         return
    fi
    echo ""
}

DOCKERCMD="$(_docker_prefix_cmd)docker"

URL=""
while true; do
    read -p "Please enter the master server hostname: " URL
    if [ -z "$URL" ]; then
        prompt_confirm "Master hostname cannot be empty. Try again? " || exit
        continue
    fi

    if [ -z "$(grep "$URL" /etc/hosts)" ]; then
        RESOLVE_CMD="getent hosts"
        if [ "$(command -v getent)" = "" ]; then
            # probably on a Mac
            RESOLVE_CMD="nslookup"
        fi

        $RESOLVE_CMD $URL >/dev/null 2>&1
        if [ "$?" != "0" ]; then
            echo "DNS ISSUE: $URL was not resolvable: $RESOLVE_CMD $URL"
            exit 1
        fi
    fi

    break
done

ACCT="$(curl -sk https://$URL/info | grep account | awk -F'"' '{print $4}')"
if [ -z "$ACCT" ];then
    echo "ACCT: Unable to determine the organization account name. Has the master been configured? Is it reachable?"
    exit 1
fi

read -p "DAP Username: " CUSER; printf "\n"

while true; do
    read -p "$CUSER Password: " -s admin1; printf "\n"
    read -p "Confirm Password: " -s confirm1; printf "\n"
    if [ "$admin1" = "$confirm1" ]; then
        break
    else
        prompt_confirm "Password did not match. Try again?" || exit
        continue
    fi
done

CPASS="$admin1"

while true; do
    read -r -n 1 -p "Is this a [s]tandby or a [f]ollower [s|f]: " SROLEREPLY
    case $SROLEREPLY in
      [sS]) echo ; SROLE="standby"; BODY_PREFIX=""; break; ;;
      [fF]) echo ; SROLE="follower"; BODY_PREFIX="follower_hostnames="; break; ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac

    prompt_confirm "You selected '$SROLE'. Is this correct" || continue
    break
done

while true; do
    read -p "What is this server's hostname: " SHOST
    prompt_confirm "You selected '$SHOST'. Is this correct" || continue
    break
done

while true; do
    CONTAINER_NAME="$(docker ps --format "{{.ID}}\{{.Image}}\{{.Names}}" | grep conjur-appliance | awk -F\\ '{print $NF}')"
    if [ -z "$CONTAINER_NAME" ];then
        CNAME_LABEL=":"
    else
        CNAME_LABEL=" [$CONTAINER_NAME]:"
    fi
    read -p "DAP container name$CNAME_LABEL" CNAME_USER; printf "\n"
    if [ "$CNAME_LABEL" = ":" ]; then
        if [ -z "$CNAME_USER" ]; then
            prompt_confirm "Container name cannot be empty. Try again?" || exit
            continue
        fi
    else
        if [ ! -z "$CNAME_USER" ]; then
            CONTAINER_NAME="$CNAME_USER"
        fi
    fi

    if [ -z "$($DOCKERCMD ps --format "{{.ID}}\{{.Image}}\{{.Names}}" | grep "$CONTAINER_NAME")" ]; then
        prompt_confirm "Container with name '$CONTAINER_NAME' could not be found. Try again?" || exit
        continue
    fi

    break
done

echo "Configuration Summary"
echo "====================="
echo "User: $CUSER"
echo "Role: $SROLE"
echo "Hostname: $SHOST"
echo "Container: $CONTAINER_NAME"
echo "====================="
echo ""
prompt_confirm "Is the above information correct?" || exit

AUTO_UNPACK="n"
prompt_confirm "Automatically unpack seed? " && AUTO_UNPACK="y" 

api_key=$(curl -sk --user $CUSER:$CPASS "https://$URL/authn/$ACCT/login")
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
token="$(echo -n $auth_result | base64 | tr -d '\r\n')"

AUTH_TOKEN="Authorization: Token token=\"$token\""

if [ "$AUTO_UNPACK" = "y" ]; then
curl -ks -H "$AUTH_TOKEN" https://$URL/configuration/$ACCT/seed/$SROLE -d"$BODY_PREFIX$SHOST" | \
    docker exec $CONTAINER_NAME evoke unpack seed -
else
    temp_seed_name=$(mktemp "seedfile.XXXX")
    curl -o $temp_seed_name -ks -H "$AUTH_TOKEN" https://$URL/configuration/$ACCT/seed/$SROLE -d"$BODY_PREFIX$SHOST" 
    echo "Seed contents ----"
    tar -tf $temp_seed_name
    echo "------------------"
    echo "If the above is correct, run: cat $temp_seed_name | $DOCKERCMD exec $CONTAINER_NAME evoke unpack seed - && rm $temp_seed_name"
fi
