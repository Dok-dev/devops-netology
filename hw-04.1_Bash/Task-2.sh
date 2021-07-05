#!/bin/bash

# Условия не очень ясны, исхожу из того, что выполнение скрипта должно прекращаться при недоступности сервиса

while ((1==1)):
do
  curl https://localhost:4757
  if (( $? != 0 ))
  #а лучше так:
  #if ! curl https://localhost:4757
  then
    date >> curl.log
    exit 1
  fi
  sleep 2
done