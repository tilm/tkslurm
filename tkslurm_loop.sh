#!/bin/zsh

if [ -z ${TKSLURM_LOGDIR} ]
then
  echo "export TKSLURM_LOGDIR=foo is missing"
fi
if [ ! ${TKSLURM_NRJOBS} ]
then
  echo "export TKSLURM_NRJOBS=4 is missing"
  return
fi
if [ ! ${TKSLURM_DELAY} ]
then
  echo "export TKSLURM_DELAY=300 is missing"
  return
fi

echo "export TKSLURM_NRJOBS=${TKSLURM_NRJOBS};export TKSLURM_DELAY=${TKSLURM_DELAY};">${TKSLURM_LOGDIR}/tkslurm_init.sh


while true
do
  tkslurm_update_queue.sh

  nr_running=$(cat ${TKSLURM_LOGDIR}/tkslurm_crunning|wc -l )
  nr_finished=$(cat ${TKSLURM_LOGDIR}/tkslurm_cfinished|wc -l )
  nr_error=$(cat ${TKSLURM_LOGDIR}/tkslurm_cerror|wc -l )
  nr_notstarted=$(cat ${TKSLURM_LOGDIR}/tkslurm_cnotstarted|wc -l )
  
  d=$(date "+%FT%T")
  echo "${d}: running:$nr_running; finished:$nr_finished; error:$nr_error; notstarted:$nr_notstarted; jobtarget:${TKSLURM_NRJOBS}"

  if [ ${nr_running} -lt ${TKSLURM_NRJOBS}  -a $nr_notstarted -gt 0 ]
  then
    # start only a single job in order to watch ressources
    a1=$(head -n1 ${TKSLURM_LOGDIR}/tkslurm_cnotstarted)
    echo "${d}: starting ${a1}"
    eval ${a1}
  elif [ ${nr_running} -gt ${TKSLURM_NRJOBS} ]
  then
    # stop
    j=$(( ${nr_running} - ${TKSLURM_NRJOBS} ))
    tac ${TKSLURM_LOGDIR}/tkslurm_krunning|head -n${j}|while read a1
    do
      echo "${d}: requeueing ${a1}"
      eval "${a1}"
    done;
  fi

  #writes a new tkslurm_init.sh file
  tkslurm_adjust_nrjobs.sh $nr_notstarted ${TKSLURM_DELAY}
  # read the new variables
  . ${TKSLURM_LOGDIR}/tkslurm_init.sh
done

