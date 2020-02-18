#!/usr/bin/env bash

DEL_VAR_FILE=del_vars.txt
DEL_POLICY_FILE=delete.yml

[ -e $DEL_POLICY_FILE ] && rm $DEL_POLICY_FILE

for i in $(cat $DEL_VAR_FILE);do
  cat << EOF >> $DEL_POLICY_FILE
- !delete
  record: !variable $i

EOF
done
