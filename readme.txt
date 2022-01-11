tkslurm - dynamic micro workload manager in shell

You have some commands to evaluate and
dont know how much ressources it costs. 
The loop shell script starts and stops
the proper number of processes according
to the available ressources.

Necessary initial environment:
export TKSLURM_MAXJOBS=24
export TKSLURM_DELAY=2
export TKSLURM_LOGDIR=/tmp

Job definition files:
4 files must provide the same number of rows,
each row stands for a job,
the user can change the files at any time.
The files are used for the following tasks:
${TKSLURM_LOGDIR}/tkslurm_cqueue - (C)ommand to evaluate
${TKSLURM_LOGDIR}/tkslurm_pqueue - (p)grep string in process list
${TKSLURM_LOGDIR}/tkslurm_fqueue - command which returns true if the job has been (f)inished with success
${TKSLURM_LOGDIR}/tkslurm_equeue - command which returns true if the job has been finished with an (e)rror
Useful commands are: setsid, disown, pgrep, pkill, grep,
see the example.

Advantage wrt slurm:
No knowledge of memory/cpu/io consumption necessary.
No knowledge of hardware ressources necessary.
Running on a dedicated machine not necessary.
Jobs are startet one by one with a user defined delay
in order to smooth io requests and allows for checking
the new cpu/mnemory/io load.
Online change of queue possible.
Nr of parallel jobs changes according
to user defined rules based on free share of 
hardware ressources. The commands used for interacting with
the jobs like killing and restarting the job are
fully user defined.
If a job gets killed by oom or whatever,
it normally gets restarted. Depending on user defined 
command in tkslurm_equeue, it is possible to detect any kind of error
and prevent a requeue.

Limitations:
You are responsible that the commands work,
if a job terminates with an indefinite state,
it will be restarted again and again.
For small processlists, because every jobs state
will queried every cycle.
There is a single queue, no priority queue,
user has to reorder queue files if necessary.
No explicit support for running on a cluster,
but it is possible with logfiles in nfs for fqueue and equeue,
and ssh pgrep calls in rqueue and kqueue.

example for job file creation with the base command "sleep":

export TKSLURM_MAXJOBS=4
export TKSLURM_DELAY=2
export TKSLURM_LOGDIR=/tmp
truncate -s0 /tmp/tkslurm_cqueue
truncate -s0 /tmp/tkslurm_pqueue
truncate -s0 /tmp/tkslurm_fqueue
truncate -s0 /tmp/tkslurm_equeue
rm /tmp/joblog*
for i in 5 51 52 510 1 12
do;
b1="setsid bash -c \"(sleep $i&&echo ready||echo error)>/tmp/joblog${i}\"&|"
b2="sleep ${i}"
b3="grep -q ready /tmp/joblog${i} 2>/dev/null"
b4="grep -qi error /tmp/joblog${i} 2>/dev/null"
echo $b1>>/tmp/tkslurm_cqueue
echo $b2>>/tmp/tkslurm_pqueue
echo $b3>>/tmp/tkslurm_fqueue
echo $b4>>/tmp/tkslurm_equeue
done
./tkslurm_loop.sh

The output is:
