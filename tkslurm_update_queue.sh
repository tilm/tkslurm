#!/bin/sh

if [ -z ${TKSLURM_LOGDIR} ]
then
  echo "export TKSLURM_LOGDIR=foo is missing"
fi

# find out which processes are running
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_crunning
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_rrunning
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_krunning
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_frunning
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_erunning

# find out which processes are finished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_cfinished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_rfinished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_kfinished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_ffinished
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_efinished

# find out which processes have failed
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_cerror
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_rerror
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_kerror
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_ferror
truncate -s 0 ${TKSLURM_LOGDIR}/tkslurm_eerror

paste -d '\n' ${TKSLURM_LOGDIR}/tkslurm_cqueue \
 ${TKSLURM_LOGDIR}/tkslurm_rqueue \
 ${TKSLURM_LOGDIR}/tkslurm_kqueue \
 ${TKSLURM_LOGDIR}/tkslurm_fqueue \
 ${TKSLURM_LOGDIR}/tkslurm_equeue|while \
 read a_command && \
 read a_running && \
 read a_kill && \
 read a_finish && \
 read a_error
do
  if eval ${a_running} || false
  then
    echo "$a_command" >>${TKSLURM_LOGDIR}/tkslurm_crunning
    echo "$a_running" >>${TKSLURM_LOGDIR}/tkslurm_rrunning
    echo "$a_kill" >>${TKSLURM_LOGDIR}/tkslurm_krunning
    echo "$a_finish" >>${TKSLURM_LOGDIR}/tkslurm_frunning
    echo "$a_error" >>${TKSLURM_LOGDIR}/tkslurm_erunning
  fi;

  if eval ${a_finish} || false
  then
    echo "$a_command" >>${TKSLURM_LOGDIR}/tkslurm_cfinished
    echo "$a_running" >>${TKSLURM_LOGDIR}/tkslurm_rfinished
    echo "$a_kill" >>${TKSLURM_LOGDIR}/tkslurm_kfinished
    echo "$a_finish" >>${TKSLURM_LOGDIR}/tkslurm_ffinished
    echo "$a_error" >>${TKSLURM_LOGDIR}/tkslurm_efinished
  fi;

  if eval ${a_error} || false
  then
    echo "$a_command" >>${TKSLURM_LOGDIR}/tkslurm_cerror
    echo "$a_running" >>${TKSLURM_LOGDIR}/tkslurm_rerror
    echo "$a_kill" >>${TKSLURM_LOGDIR}/tkslurm_kerror
    echo "$a_finish" >>${TKSLURM_LOGDIR}/tkslurm_ferror
    echo "$a_error" >>${TKSLURM_LOGDIR}/tkslurm_eerror
  fi;
done;

cat ${TKSLURM_LOGDIR}/tkslurm_cqueue\
  |grep -vxf ${TKSLURM_LOGDIR}/tkslurm_crunning\
  |grep -vxf ${TKSLURM_LOGDIR}/tkslurm_cfinished\
  |grep -vxf ${TKSLURM_LOGDIR}/tkslurm_cerror\
  >${TKSLURM_LOGDIR}/tkslurm_cnotstarted




