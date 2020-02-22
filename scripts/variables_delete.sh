#!/usr/bin/env bash

if [ "$#" != "2" ];then
    echo "Usage: $0 <var_file>
    exit 1
fi

DEL_VAR_FILE=del_vars.txt
DEL_POLICY_FILE=delete.yml

[ -e $DEL_POLICY_FILE ] && rm $DEL_POLICY_FILE

for i in $(cat $DEL_VAR_FILE);do
  cat << EOF >> $DEL_POLICY_FILE
- !delete
  record: !variable $i

EOF
done
