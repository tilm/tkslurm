#!/bin/zsh

# print machine state

a1=$(sar -S -u ALL ${TKSLURM_DELAY} 1|grep "Average"\
|grep "\."|sed "s/  */ /g"|cut -f4,6,12 -d' ')

# we get 2 lines:
# 1st: from -s option=swap, 4th col=swapusage%
# 2nd: from -u section=cpu, 6=iowait,12=idle


a=$(echo $a1|head -n1|cut -f3 -d' '\
|awk 'BEGIN{OFMT="%.0f"}{print 1*$1}')
b=$(echo $a1|head -n1|cut -f2 -d' '\
|awk 'BEGIN{OFMT="%.0f"}{print 10*$1}')
c=$(echo $a1|tail -n1|cut -f1 -d' '\
|awk 'BEGIN{OFMT="%.0f"}{print 1*$1}')

# idle 10*waload swap
echo "$a $b $c"






