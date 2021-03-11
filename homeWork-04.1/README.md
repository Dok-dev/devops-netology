# Домашнее задание «4.1. Командная оболочка Bash: Практические навыки»

**1 - задание.**

`c=a+b`  # с - будет присвоена строка 'a+b'    
`d=$a+$b`  # d - бует присвоена строка из начений 1'+'2    
`e=$(($a+$b))`  # e - будет передан результат арифметической операции сложения значений переменных а и в, т.е 3.

---

**2 - задание.**

Условия не очень ясны, исходя из того, что выполнение скрипта должно прекращаться при доступности сервиса:
```bash
while : # в оригинале не предусморен выход из цикла,а конструкция ((1==1)) вообще не требуется
do
  curl https://localhost:4757
  if (($?==0))
  #а лучше так:
  #if curl https://localhost:4757
  then
    date >> curl.log
    exit 0
  fi
  sleep 1 # непонятно зачем нужен такой интенсивный тест да еще с записью в лог, добавил паузу 1 сек
done
```

Исходя из того, что выполнение скрипта должно прекращаться при недоступности сервиса:
```bash
while :
do
  curl https://localhost:4757
  if (( $? != 0 ))
  #а лучше так:
  #if ! curl https://localhost:4757
  then
    date >> curl.log
    exit 1
  fi
  sleep 1
done
```

---

**3 - задание.**

```bash
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

```

**4 - задание.**

```bash
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
```

---

**Дополнительное задание (со звездочкой).**

```bash
#!/bin/sh
#
# code for file .git/hoks/commit-msg

task_code='(\[[0-9]{2}-[a-zA-Z]*-[0-9]{2}-[a-zA-Z]*\])'

msg_len=$(wc -m $1 | cut -d' ' -f1)


if (( $msg_len > 31 )); then
  echo "Aborting commit. Your commit message is longer then 30 characters." >&2
  exit 1
fi


if ! grep -iqE "$task_code" "$1"; then
  echo "Aborting commit. Your commit message is missing task code like [01-script-01-test]" >&2
  exit 1
fi
```