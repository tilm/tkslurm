
You have some commands to evaluate and
dont know how much ressources it costs. 
The loop shell script starts and stops
as many processes as good for the machine.

Necessary initial environment:
export TKSLURM_NRJOBS=4
export TKSLURM_DELAY=2
export TKSLURM_LOGDIR=/tmp

The TKSLURM_NRJOBS will change during evaluation
according to tkslurm_adjust_nrjobs.sh

Job definition:
Each row stands for a job, all files must provide the same number of rows.
Files can be changed all the time.
${TKSLURM_LOGDIR}/tkslurm_cqueue - (C)ommands to evaluate
${TKSLURM_LOGDIR}/tkslurm_rqueue - commands which return true if the job is (r)unning
${TKSLURM_LOGDIR}/tkslurm_kqueue - commands which (k)ill the job
${TKSLURM_LOGDIR}/tkslurm_fqueue - commands which return true if the job has been (f)inished with success
${TKSLURM_LOGDIR}/tkslurm_equeue - commands which return true if the job has been finished with an (e)rror

Advantage wrt slurm:
No knowledge of memory/cpu consumption necessary.
No knowledge of hardware ressources necessary.
Online change of queue and nr of parallel jobs according
to pct value measures possible.
The command for killing and restarting the job is
user defined.

Limitations:
You are responsible that the commands work,
if a job terminates with an indefinite state,
it will be restartet again and again.
No Job distribution over network.

example for job file creation:
truncate -s0 /tmp/tkslurm_cqueue
truncate -s0 /tmp/tkslurm_rqueue
truncate -s0 /tmp/tkslurm_kqueue
truncate -s0 /tmp/tkslurm_fqueue
truncate -s0 /tmp/tkslurm_equeue
for i in 16 17 18 19 20
do;
b1="setsid bash -c \"(sleep $i&&echo ready||echo error)>/tmp/joblog${i}\"&|"
b2="pgrep -cf \"sleep ${i}\">/dev/null"
b3="pkill -f \"sleep ${i}\""
b4="grep -q ready /tmp/joblog${i} 2>/dev/null"
b5="grep -qi error /tmp/joblog${i} 2>/dev/null"
echo $b1>>/tmp/tkslurm_cqueue
echo $b2>>/tmp/tkslurm_rqueue
echo $b3>>/tmp/tkslurm_kqueue
echo $b4>>/tmp/tkslurm_fqueue
echo $b5>>/tmp/tkslurm_equeue
done

Start the scheduler:
tkslurm_loop.sh


