#!/bin/zsh


delay=$1

a1=$(sar -S -u ALL ${delay} 1|grep "Average"|grep "\."|sed "s/  */ /g"|cut -f4,6,12 -d' ')


a=$(echo $a1|head -n1|cut -f3 -d' '|cut -f1 -d'.')
b=$(echo $a1|head -n1|cut -f2 -d' '|cut -f1 -d'.')
c=$(echo $a1|tail -n1|cut -f1 -d' '|cut -f1 -d'.')

# idle waload swap
echo "$a $b $c"






