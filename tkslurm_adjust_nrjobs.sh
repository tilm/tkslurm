#!/bin/zsh

nr_unfinished=$1
delay=$2

# reads the state file tkslurm_init
# changes the state
# writes the state file

a=$(tkslurm_cpuinfo.sh ${delay})
# nice iowait swap

# a1 = free swap in percent
a1=$(echo $a|cut -f3 -d ' ')
# a2 = wa-load in percent
a2=$(echo $a|cut -f2 -d ' ')
# a3 = idle in percent
a3=$(echo $a|cut -f1 -d ' ')

# number cpus is maximum for nrjobs
mc=$(cat /proc/cpuinfo|grep processor|wc -l)

d=$(date "+%FT%T")
echo "${d}: swap:$a1; waload: $a2; idle: $a3; unfinishedjobs: ${nr_unfinished}; nrcpus: ${mc}"

. ${TKSLURM_LOGDIR}/tkslurm_init.sh
if [ $a1 -gt 60 -a ${TKSLURM_NRJOBS} -gt 0 ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} - 1))
  echo "${d}: reduce due to swap > 60pct"
elif [ $a2 -gt 7 -a ${TKSLURM_NRJOBS} -gt 0 ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} - 1))
  echo "${d}: reduce due to io >7 pct"
elif [ $a3 -lt 5 -a ${TKSLURM_NRJOBS} -gt 0 ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} - 1))
  echo "${d}: reduce due to idle < 5pct"
elif [ $a3 -gt 30 -a $a1 -lt 50 -a $a2 -le 0 -a ${TKSLURM_NRJOBS} -lt ${nr_unfinished} -a ${TKSLURM_NRJOBS} -lt $mc ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} + 1))
  echo "${d}: increase due to idle>30pct and swap<50pct and io<=0pct"
fi

echo "export TKSLURM_NRJOBS=${TKSLURM_NRJOBS};export TKSLURM_DELAY=${TKSLURM_DELAY};">${TKSLURM_LOGDIR}/tkslurm_init.sh







