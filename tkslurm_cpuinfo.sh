#!/bin/zsh

# free swap memory
a=$(free -m|grep Swap|sed "s/  */T/g"|cut -f3 -d'T')

# cpu stats
b=$(cat /proc/stat|grep "cpu "|cut -f3- -d' ')
sleep 1
c=$(cat /proc/stat|grep "cpu "|cut -f3- -d' ')
b1=$(echo $b|cut -f1 -d' ')
b2=$(echo $b|cut -f2 -d' ')
b3=$(echo $b|cut -f3 -d' ')
b4=$(echo $b|cut -f4 -d' ')
b5=$(echo $b|cut -f5 -d' ')
b6=$(echo $b|cut -f6 -d' ')
b7=$(echo $b|cut -f7 -d' ')

c1=$(echo $c|cut -f1 -d' ')
c2=$(echo $c|cut -f2 -d' ')
c3=$(echo $c|cut -f3 -d' ')
c4=$(echo $c|cut -f4 -d' ')
c5=$(echo $c|cut -f5 -d' ')
c6=$(echo $c|cut -f6 -d' ')
c7=$(echo $c|cut -f7 -d' ')

b1=$((${c1} - ${b1}))
b2=$((${c2} - ${b2}))
b3=$((${c3} - ${b3}))
b4=$((${c4} - ${b4}))
b5=$((${c5} - ${b5}))
b6=$((${c6} - ${b6}))
b7=$((${c7} - ${b7}))

b=$((100 * ${b5} / (${b1}+${b2}+${b3}+${b4}+${b5}+${b6}+${b7})))
c=$((100 * ${b4} / (${b1}+${b2}+${b3}+${b4}+${b5}+${b6}+${b7})))


echo "$a $b $c"






