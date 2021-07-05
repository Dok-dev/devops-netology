#!/bin/bash

run_test(){
 for ((i=1; i < 6; i++)); do
  curl http://$1:80

  if [ $? == "0" ]; then
   result="online"
  else
   result="fail"
  fi

  date_time="$(date)"
  echo $date_time $1 $result >> curl.log
 done
}

run_test "192.168.0.1"
run_test "173.194.222.113"
run_test "87.250.250.242"