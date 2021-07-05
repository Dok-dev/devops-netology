#!/bin/bash

run_test(){
 while :; do
  curl http://$1:80 > /dev/null #2>&1

  if (( $? != 0 )); then
   date_time="$(date)"
   echo $date_time $1 Fail >> error.log
   exit 1
  fi

  sleep 2
 done
}

run_test "192.168.17.60"
run_test "173.194.222.113"
run_test "87.250.250.242"
