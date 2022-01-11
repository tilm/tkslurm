#!/bin/zsh

a=1
pgrep -f "$1"|while read pid;
do
  ps -o state -p ${pid}|tail -n1|grep -q T
  a=$?
done
# shit
test $a -eq 0
