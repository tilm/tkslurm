#!/bin/zsh

maxjobs=$1

. ${TKSLURM_LOGDIR}/tkslurm_init.sh


a=$(tkslurm_cpuinfo.sh)
# a1 = free swap in percent
a1=$(echo $a|cut -f1 -d ' ')
# a2 = wa-load in percent
a2=$(echo $a|cut -f2 -d ' ')
# a3 = idle in percent
a3=$(echo $a|cut -f3 -d ' ')

# number cpus is maximum for nrjobs
mc=$(cat /proc/cpuinfo|grep processor|wc -l)

d=$(date "+%FT%T")

if [ $a1 -gt 60 -a ${TKSLURM_NRJOBS} -gt 0 ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} - 1))
  echo "${d}: reduce due to swap more than 60pct"
elif [ $a2 -gt 6 -a ${TKSLURM_NRJOBS} -gt 0 ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} - 1))
  echo "${d}: reduce due to io more than 6pct"
elif [ $a3 -gt 30 -a $a1 -lt 20 -a $a2 -le 2 -a ${TKSLURM_NRJOBS} -lt $maxjobs -a ${TKSLURM_NRJOBS} -lt $mc ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} + 1))
  echo "${d}: increase due to idle>30pct and swap<20pct and io<=2pct"
fi

echo "export TKSLURM_NRJOBS=${TKSLURM_NRJOBS};export TKSLURM_DELAY=${TKSLURM_DELAY};">${TKSLURM_LOGDIR}/tkslurm_init.sh







