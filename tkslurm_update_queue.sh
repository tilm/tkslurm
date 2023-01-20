#!/bin/sh

if [ -z ${TKSLURM_LOGDIR} ]
then
  echo "export TKSLURM_LOGDIR=foo is missing"
fi

# todo
# 1. ps -o pid,state,command called multiple times, inefficient
# 2. dont grep large files periodically


# find out which processes are running
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_crunning
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_prunning
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_frunning
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_erunning

truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_cstopped
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_pstopped
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_fstopped
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_estopped

truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_crunningstopped
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_prunningstopped
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_frunningstopped
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_erunningstopped

# find out which processes are finished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_cfinished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_pfinished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_ffinished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_efinished

# find out which processes have failed
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_cerror
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_perror
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_ferror
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_eerror

paste -d '\n' ${TKSLURM_LOGDIR}/tkslurm_cqueue \
 ${TKSLURM_LOGDIR}/tkslurm_pqueue \
 ${TKSLURM_LOGDIR}/tkslurm_fqueue \
 ${TKSLURM_LOGDIR}/tkslurm_equeue|while \
 read a_command && \
 read a_pgrep && \
 read a_isfinish && \
 read a_iserror
do

  a_isrunning="pgrep -cf \"^${a_pgrep}$\">/dev/null"
  a_isstopped="pgrep_stopped.sh \"^${a_pgrep}$\""

  isrunning=0;
  isstopped=0;

  if eval ${a_isrunning} || false
  then
    echo "$a_command" >>${TKSLURM_LOGDIR}/tkslurm_crunningstopped
    echo "$a_pgrep" >>${TKSLURM_LOGDIR}/tkslurm_prunningstopped
    echo "$a_finish" >>${TKSLURM_LOGDIR}/tkslurm_frunningstopped
    echo "$a_error" >>${TKSLURM_LOGDIR}/tkslurm_erunningstopped
    isrunning=1;
  fi;

  if eval ${a_isstopped} || false
  then
    echo "$a_command" >>${TKSLURM_LOGDIR}/tkslurm_cstopped
    echo "$a_pgrep" >>${TKSLURM_LOGDIR}/tkslurm_pstopped
    echo "$a_finish" >>${TKSLURM_LOGDIR}/tkslurm_fstopped
    echo "$a_error" >>${TKSLURM_LOGDIR}/tkslurm_estopped
    isstopped=1;
  fi;

  if [ $isrunning -eq 1 -a $isstopped -eq 0 ] || false
  then
    echo "$a_command" >>${TKSLURM_LOGDIR}/tkslurm_crunning
    echo "$a_pgrep" >>${TKSLURM_LOGDIR}/tkslurm_prunning
    echo "$a_finish" >>${TKSLURM_LOGDIR}/tkslurm_frunning
    echo "$a_error" >>${TKSLURM_LOGDIR}/tkslurm_erunning
  fi;

  if eval ${a_isfinish} || false
  then
    echo "$a_command" >>${TKSLURM_LOGDIR}/tkslurm_cfinished
    echo "$a_pgrep" >>${TKSLURM_LOGDIR}/tkslurm_pfinished
    echo "$a_finish" >>${TKSLURM_LOGDIR}/tkslurm_ffinished
    echo "$a_error" >>${TKSLURM_LOGDIR}/tkslurm_efinished
  fi;

  if eval ${a_iserror} || false
  then
    echo "$a_command" >>${TKSLURM_LOGDIR}/tkslurm_cerror
    echo "$a_running" >>${TKSLURM_LOGDIR}/tkslurm_perror
    echo "$a_finish" >>${TKSLURM_LOGDIR}/tkslurm_ferror
    echo "$a_error" >>${TKSLURM_LOGDIR}/tkslurm_eerror
  fi;
done;

cat ${TKSLURM_LOGDIR}/tkslurm_cqueue\
  |grep -vxf ${TKSLURM_LOGDIR}/tkslurm_crunning\
  |grep -vxf ${TKSLURM_LOGDIR}/tkslurm_cfinished\
  |grep -vxf ${TKSLURM_LOGDIR}/tkslurm_cerror\
  >${TKSLURM_LOGDIR}/tkslurm_cnotstarted




