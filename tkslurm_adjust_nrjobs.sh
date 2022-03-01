#!/bin/zsh

delay=$1
maxjobs=$2
nr_notstarted=$3
nr_running=$4
nr_stopped=$5


# reads the state file tkslurm_init
# changes the state
# writes the state file

a=$(tkslurm_cpuinfo.sh ${delay})
# idle iowait swap

# a1 = full swap in percent
fullswap=$(echo $a|cut -f3 -d ' ')
# a2 = wa-load in percent
iowait=$(echo $a|cut -f2 -d ' ')
# a3 = idle in percent
idle=$(echo $a|cut -f1 -d ' ')

# number cpus is maximum for nrjobs
mc=$(cat /proc/cpuinfo|grep processor|wc -l)

d=$(date "+%FT%T")
if [ ${nr_running} -eq 0 ] ;then
  efficiency=100
else
  efficiency=$(( ${mc}*(100-${idle})/${nr_running}))
fi
# lod is average cpu per running process
echo "${d}: swap:$fullswap; wait: $iowait; \
idle: $idle; efficiency=$efficiency; \
nr_notstarted: ${nr_notstarted}; \
nr_running: ${nr_running}; \
nr_stopped: ${nr_stopped};">&2

nr_runningorstopped=$((${nr_running}+${nr_stopped}))

# gegeben:
# efficiency - cpuload/processes
# fullswap - fullswap/swap
# iowait - iowait percent
# idle - idle percent

. ${TKSLURM_LOGDIR}/tkslurm_init.sh

if [ \( $fullswap -gt 100 -o $idle -lt 5 -o $iowait -ge 1 -o $efficiency -lt 95 \) -a ${nr_running} -gt 0 ]
then
  # sleep
  echo "sleep"
elif [ $fullswap -gt 60                                  -a ${nr_runningorstopped} -gt 0 ]
then
  # kill
  echo "kill"
elif [ $fullswap -lt 100 -a $idle -gt 20 -a $iowait -le 0 -a ${nr_stopped} -gt 0 ]
then
  # wakeup
  echo "wakeup"
elif [ $idle -gt 20 -a $fullswap -lt 20 -a $iowait -le 0 \
 -a ${nr_stopped} -le 0 -a ${nr_notstarted} -gt 0 \
 -a ${nr_runningorstopped} -lt ${maxjobs} ]
then
  # start
  echo "start"
else
  echo "donothing"
fi







