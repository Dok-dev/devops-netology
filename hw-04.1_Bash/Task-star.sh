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
