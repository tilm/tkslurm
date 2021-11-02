#!/bin/zsh

maxjobs=$1

. ${TKSLURM_LOGDIR}/tkslurm_init.sh


a=$(tkslurm_cpuinfo.sh)
# a1 = free swap in kb
a1=$(echo $a|cut -f1 -d ' ')
# a2 = wa-load in percent
a2=$(echo $a|cut -f2 -d ' ')
# a3 = idle in percent
a3=$(echo $a|cut -f3 -d ' ')

# number cpus is maximum for nrjobs
mc=$(cat /proc/cpuinfo|grep processor|wc -l)

if [ $a1 -gt 300000 -a ${TKSLURM_NRJOBS} -gt 0 ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} - 1))
  echo "reduce due to swap"
elif [ $a2 -gt 10 -a ${TKSLURM_NRJOBS} -gt 0 ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} - 1))
  echo "reduce due to io"
elif [ $a3 -gt 30 -a $a1 -lt 150000 -a $a2 -le 2 -a ${TKSLURM_NRJOBS} -lt $maxjobs -a ${TKSLURM_NRJOBS} -lt $mc ]
then
  TKSLURM_NRJOBS=$((${TKSLURM_NRJOBS} + 1))
  echo "increase due to idle and lowswap and lowio"
fi

echo "export TKSLURM_NRJOBS=${TKSLURM_NRJOBS};export TKSLURM_DELAY=${TKSLURM_DELAY};">${TKSLURM_LOGDIR}/tkslurm_init.sh







