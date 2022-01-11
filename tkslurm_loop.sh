#!/bin/zsh

if [ -z ${TKSLURM_LOGDIR} ]
then
  echo "export TKSLURM_LOGDIR=foo is missing"
fi
if [ ! ${TKSLURM_DELAY} ]
then
  echo "export TKSLURM_DELAY=300 is missing"
  return
fi
if [ ! ${TKSLURM_MAXJOBS} ]
then
  echo "export TKSLURM_MAXJOBS=16 is missing"
  return
fi


# write state file tkslurm_init.sh
echo "export TKSLURM_NRJOBS=${TKSLURM_NRJOBS};export TKSLURM_DELAY=${TKSLURM_DELAY};">${TKSLURM_LOGDIR}/tkslurm_init.sh


while true
do
  tkslurm_update_queue.sh
  # process queue files
  # requires TKSLURM_LOGDIR
 
  nr_runningstopped=$(cat ${TKSLURM_LOGDIR}/tkslurm_crunningstopped|wc -l )
  nr_running=$(cat ${TKSLURM_LOGDIR}/tkslurm_crunning|wc -l )
  nr_stopped=$(cat ${TKSLURM_LOGDIR}/tkslurm_cstopped|wc -l )
  nr_finished=$(cat ${TKSLURM_LOGDIR}/tkslurm_cfinished|wc -l )
  nr_error=$(cat ${TKSLURM_LOGDIR}/tkslurm_cerror|wc -l )
  nr_notstarted=$(cat ${TKSLURM_LOGDIR}/tkslurm_cnotstarted|wc -l )
  nr_unfinished=$(( ${nr_running} + ${nr_notstarted}))
  
  d=$(date "+%FT%T")
  echo "${d}: running:$nr_running; stopped:$nr_stopped; finished:$nr_finished; error:$nr_error; notstarted:$nr_notstarted;">&2

  #read/change/write tkslurm_init.sh file
  todo=$(tkslurm_adjust_nrjobs.sh ${TKSLURM_DELAY} ${TKSLURM_MAXJOBS} ${nr_notstarted} ${nr_running} ${nr_stopped});
  if [ $todo = "start" ]
  then
    a1=$(head -n1 ${TKSLURM_LOGDIR}/tkslurm_cnotstarted)
    echo "${d}: starting ${a1}">&2
    eval ${a1}
  elif [ $todo = "kill" ]
  then
    a1=$(head -n1 ${TKSLURM_LOGDIR}/tkslurm_prunningstopped)
    echo "${d}: kill ${a1}">&2
    eval pkill --signal SIGCONT -f "${a1}"
    eval pkill -f "${a1}"
  elif [ $todo = "sleep" ]
  then
    a1=$(head -n1 ${TKSLURM_LOGDIR}/tkslurm_prunning)
    echo "${d}: sleep ${a1}">&2
    eval pkill --signal SIGSTOP -f "${a1}"
  elif [ $todo = "wakeup" ]
  then
    a1=$(head -n1 ${TKSLURM_LOGDIR}/tkslurm_pstopped)
    echo "${d}: wakeup ${a1}">&2
    eval pkill --signal SIGCONT -f "${a1}"
  fi;

done

