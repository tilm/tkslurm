tkslurm - dynamic micro workload manager in shell

You have some commands to evaluate and
dont know how much ressources it costs. 
The loop shell script starts and stops
the proper number of processes according
to the available ressources.

Necessary initial environment:
export TKSLURM_NRJOBS=4
export TKSLURM_DELAY=2
export TKSLURM_LOGDIR=/tmp

The TKSLURM_NRJOBS will change during evaluation
according to tkslurm_adjust_nrjobs.sh

Job definition files:
5 files must provide the same number of rows,
each row stands for a job,
the user can change the files at any time.
The files are used for the following tasks:
${TKSLURM_LOGDIR}/tkslurm_cqueue - (C)ommand to evaluate
${TKSLURM_LOGDIR}/tkslurm_rqueue - command which returns true if the job is (r)unning
${TKSLURM_LOGDIR}/tkslurm_kqueue - command which (k)ills the job
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
it will be restartet again and again.
User has to synchronize workload files if
jobs are scheduled on more than one machine.
There is a single queue, no priority queue,
user has to reorder queue files if necessary.

example for job file creation with the base command "sleep":
truncate -s0 /tmp/tkslurm_cqueue
truncate -s0 /tmp/tkslurm_rqueue
truncate -s0 /tmp/tkslurm_kqueue
truncate -s0 /tmp/tkslurm_fqueue
truncate -s0 /tmp/tkslurm_equeue
rm /tmp/joblog*
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
./tkslurm_loop.sh

The output is:
2021-11-19T15:21:25: running:0; finished:0; error:0; notstarted:5; jobtarget:4
2021-11-19T15:21:25: starting setsid bash -c "(sleep 16&&echo ready||echo error)>/tmp/joblog16"&|
2021-11-19T15:21:33: swap:13; waload: 0; idle: 94; unfinishedjobs: 5; nrcpus: 4
2021-11-19T15:21:33: running:1; finished:0; error:0; notstarted:4; jobtarget:4
2021-11-19T15:21:33: starting setsid bash -c "(sleep 17&&echo ready||echo error)>/tmp/joblog17"&|
2021-11-19T15:21:35: swap:13; waload: 0; idle: 93; unfinishedjobs: 5; nrcpus: 4
2021-11-19T15:21:35: running:2; finished:0; error:0; notstarted:3; jobtarget:4
2021-11-19T15:21:35: starting setsid bash -c "(sleep 18&&echo ready||echo error)>/tmp/joblog18"&|
2021-11-19T15:21:37: swap:13; waload: 0; idle: 93; unfinishedjobs: 5; nrcpus: 4
2021-11-19T15:21:37: running:3; finished:0; error:0; notstarted:2; jobtarget:4
2021-11-19T15:21:37: starting setsid bash -c "(sleep 19&&echo ready||echo error)>/tmp/joblog19"&|
2021-11-19T15:21:39: swap:13; waload: 0; idle: 94; unfinishedjobs: 5; nrcpus: 4
2021-11-19T15:21:39: running:4; finished:0; error:0; notstarted:1; jobtarget:4
2021-11-19T15:21:41: swap:13; waload: 0; idle: 92; unfinishedjobs: 5; nrcpus: 4
2021-11-19T15:21:41: running:3; finished:1; error:0; notstarted:1; jobtarget:4
2021-11-19T15:21:41: starting setsid bash -c "(sleep 20&&echo ready||echo error)>/tmp/joblog20"&|
2021-11-19T15:21:44: swap:13; waload: 0; idle: 93; unfinishedjobs: 4; nrcpus: 4
2021-11-19T15:21:44: running:4; finished:1; error:0; notstarted:0; jobtarget:4
2021-11-19T15:21:46: swap:13; waload: 0; idle: 93; unfinishedjobs: 4; nrcpus: 4
2021-11-19T15:21:46: running:4; finished:1; error:0; notstarted:0; jobtarget:4
2021-11-19T15:21:48: swap:13; waload: 0; idle: 93; unfinishedjobs: 4; nrcpus: 4
2021-11-19T15:21:48: running:4; finished:1; error:0; notstarted:0; jobtarget:4
2021-11-19T15:21:50: swap:13; waload: 0; idle: 93; unfinishedjobs: 4; nrcpus: 4
2021-11-19T15:21:50: running:3; finished:2; error:0; notstarted:0; jobtarget:4
2021-11-19T15:21:52: swap:13; waload: 0; idle: 94; unfinishedjobs: 3; nrcpus: 4
2021-11-19T15:21:52: running:3; finished:2; error:0; notstarted:0; jobtarget:4
2021-11-19T15:21:54: swap:13; waload: 0; idle: 94; unfinishedjobs: 3; nrcpus: 4
2021-11-19T15:21:54: running:2; finished:3; error:0; notstarted:0; jobtarget:4
2021-11-19T15:21:57: swap:13; waload: 0; idle: 94; unfinishedjobs: 2; nrcpus: 4
2021-11-19T15:21:57: running:1; finished:4; error:0; notstarted:0; jobtarget:4
2021-11-19T15:21:59: swap:13; waload: 9; idle: 83; unfinishedjobs: 1; nrcpus: 4
2021-11-19T15:21:59: reduce due to io >7 pct
2021-11-19T15:21:59: running:1; finished:4; error:0; notstarted:0; jobtarget:3
2021-11-19T15:22:01: swap:13; waload: 0; idle: 91; unfinishedjobs: 1; nrcpus: 4
2021-11-19T15:22:01: running:1; finished:4; error:0; notstarted:0; jobtarget:3
2021-11-19T15:22:03: swap:13; waload: 0; idle: 86; unfinishedjobs: 1; nrcpus: 4
2021-11-19T15:22:03: running:0; finished:5; error:0; notstarted:0; jobtarget:3
2021-11-19T15:22:05: swap:13; waload: 0; idle: 71; unfinishedjobs: 0; nrcpus: 4

