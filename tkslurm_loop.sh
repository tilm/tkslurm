#!/bin/zsh


HDIR=$(dirname $(readlink -f $0))
CFILE=$HDIR/tkslurm.conf

CFG=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--set)
      shift # past argument
      CFG+=("$1")
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      echo "Unknown option $1"
      exit 1
     ;;
  esac
done


if [ ${#CFG[@]} != 0 ];
then
  CFILE1=$(mktemp)
  echo ${CFG[@]}|tr ' ' '\n'|while read a;
  do
    a1=$(echo $a|cut -f1 -d'=')
    a2=$(echo $a|cut -f2 -d'=')
    if grep -q "^${a1}=" ${CFILE} ;
    then
      sed 's@^'${a1}'=.*@'${a1}'='${a2}'@' ${CFILE} >${CFILE1}
    else
      cat ${CFILE} <(echo -e "${a1}=${a2}") >${CFILE1}
    fi
    mv -f ${CFILE1} ${CFILE}
  done;
  exit;
fi;

CFILE1=$(sed "s/^\(.*\)=\(.*\)$/export \1=\2/" ${CFILE})
cat ${CFILE}
echo ${CFILE1}

while true
do
  CFILE1=$(sed "s/^\(.*\)=\(.*\)$/export \1=\2/" ${CFILE})
. ${CFILE}
. <(echo "${CFILE1}")

  echo "evaluate queue"
  tkslurm_update_queue.sh
  echo "evaluate queue ready"
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

  todo=$(tkslurm_adjust_nrjobs.sh ${nr_notstarted} ${nr_running} ${nr_stopped});
  if [ $todo = "start" ]
  then
    a1=$(head -n1 ${TKSLURM_LOGDIR}/tkslurm_cnotstarted)
    echo "${d}: *** starting ${a1}">&2
    eval ${a1}
  elif [ $todo = "kill" ]
  then
    a1=$(tail -n1 ${TKSLURM_LOGDIR}/tkslurm_prunningstopped)
    echo "${d}: ### kill ${a1}">&2
    pkill --signal SIGCONT -f "${a1}"
    pkill -f "${a1}"
  elif [ $todo = "sleep" ]
  then
    a1=$(tail -n1 ${TKSLURM_LOGDIR}/tkslurm_prunning)
    echo "${d}: ### sleep ${a1}">&2
    pkill --signal SIGSTOP -f "${a1}"
  elif [ $todo = "wakeup" ]
  then
    a1=$(head -n1 ${TKSLURM_LOGDIR}/tkslurm_pstopped)
    echo "${d}: *** wakeup ${a1}">&2
    pkill --signal SIGCONT -f "${a1}"
  fi;

done

