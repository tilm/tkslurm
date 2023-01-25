#!/bin/zsh

nr_notstarted=$1
nr_running=$2
nr_stopped=$3

if [ -z ${TKSLURM_LOGDIR} ]
then
  echo "export TKSLURM_LOGDIR=foo is missing"
fi



# reads the state file tkslurm_init
# changes the state
# writes the state file

a=$(tkslurm_cpuinfo.sh)
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
# iowait - iowait percent *10
# idle - idle percent

# . ${TKSLURM_LOGDIR}/tkslurm_init.sh

if [ \( $fullswap -gt 100 \
  -o $idle -lt $TKSLURM_IDLE_SLEEP_LT \
  -o $iowait -ge $TKSLURM_IOWAIT_SLEEP_GE \
  -o $efficiency -lt $TKSLURM_EFF_SLEEP_LT \) \
  -a ${nr_running} -gt 0 ]
then
  # sleep
  echo "sleep"
elif [ $fullswap -gt $TKSLURM_SWAP_KILL_GT \
  -a ${nr_runningorstopped} -gt 0 ]
then
  # kill
  echo "kill"
elif [ $fullswap -lt 100 \
  -a $idle -gt $TKSLURM_IDLE_WAKEUP_GT \
  -a $iowait -le $TKSLURM_IOWAIT_WAKEUP_LE \
  -a ${nr_stopped} -gt 0 ]
then
  # wakeup
  echo "wakeup"
elif [ $idle -gt $TKSLURM_IDLE_START_GT \
 -a $fullswap -lt $TKSLURM_SWAP_START_LT \
 -a $iowait -le $TKSLURM_IOWAIT_START_LE \
 -a ${nr_stopped} -le 0 \
 -a ${nr_notstarted} -gt 0 \
 -a ${nr_runningorstopped} -lt ${TKSLURM_MAXJOBS} ]
then
  # start
  echo "start"
else
  echo "donothing"
fi




