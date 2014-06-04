#!/bin/bash
#lists jobs that are not finished and are not running
#need to give arguement of directory - in quotes eg. "*/" would give all directories in current directory.


abort() {
  echo >&2
  echo "Aborting!" >&2
  echo >&2
  exit $errcode
}



if [ $# -eq "0" ] ; then
echo "Improper invocation." >&2
echo "You need to supply the name of the directory  in quotes 
eg. -d \"*/\" would give all directories in current directory. 
-c  is completed jobs
-f  is failed jobs 
-r  is still running jobs
-s  is jobs that need to be ran still" 
    errcode=1; abort
else


me=`whoami`
# flag options
while getopts "d: k:  fcrs " flag; do
if [ "$flag" == "?" ]; then
echo "Improper invocation." >&2
echo "You need to supply the name of the directory  in quotes 
eg. -d \"*/\" would give all directories in current directory. 
-c  is completed jobs
-f  is failed jobs 
r  is still running jobs
-s  is jobs that need to be ran still
-k convergence criteria wanted for energy convergene (kcal/mol)
eg. -k 0.2 (defualt 0.3 kcal.mol)" &>2
    errcode=1; abort
	fi
	if [ "$flag" == "d" ]; then where=$OPTARG ; fi
	if [ "$flag" == "k" ]; then criteria=`echo $OPTARG | awk '{printf ("%3i", $i*100)}'` ; else criteria="30" ; fi
	if [ "$flag" == "c" ] ; then job=1 ; fi 
	if [ "$flag" == "f" ] ; then job=2 ; fi
	if [ "$flag" == "r" ] ; then job=3 ; fi
	if [ "$flag" == "s" ] ; then job=4 ; fi
done


if [ $job == 2 ] ; then

	qstat -f | grep Output_Path -A2 | sed "/--/d" | awk '{ if (NR%3 == 0 ) printf("%s%s%s \n", prev2, prev, $0 ) ; ; prev2=prev ; prev=$0  }' | sed "s/\t//g" | awk '{print $3}'  | sed "s/log_//" > /tmp/tmp.${me}qstaf

	for i in ${where}*.out* ; do if ( ! grep -q completed $i && ! grep -q `echo $i |  sed "s/.out.*//"` /tmp/tmp.${me}qstaf ) ; then echo $i has failed ; fi ; done 



elif [  $job == 1 ]  ;then 

	for i in ${where}*.out* ; do
		 if (  grep -q completed $i ) ; then 
			convergence=`grep "<-- CG" -B1 $i | awk '{ A[NR-1] = $3 } END { printf("%9.8f", (A[1] - A[0])*627.509) }'`
			achieved=`grep "<-- CG" -B1 $i | awk '{ A[NR-1] = $3 } END { printf("%3i", ((A[1] - A[0])*627.509)*-100) }'`
			if [ "$achieved" -lt "$criteria" ] ; then 
				echo -e  $i "\x1b[32;01m energy convergence="  $convergence" kcal/mol \x1b[39;49;00m " ;
			else
				echo -e  $i "\x1b[31;01m energy convergence="  $convergence" kcal/mol \x1b[39;49;00m " ;
			fi
#			echo -e  $i \\t "convergence="  $convergence" kcal/mol" ;
		fi
	done

elif [ $job == 3 ] ; then

qstat -f | grep Output_Path -A2 | sed "/--/d" | awk '{ if (NR%3 == 0 ) printf("%s%s%s \n", prev2, prev, $0 ) ; ; prev2=prev ; prev=$0  }' | sed "s/\t//g" | awk '{print $3}'  | sed "s/log_//" > /tmp/tmp.${me}qstaf
showq -w user=$me -r | grep ${me}  > /tmp/tmp.${me}shqr

for i in `cat /tmp/tmp.${me}shqr | awk  '{print $1}'` 
 do 
        echo $i ` cat /tmp/tmp.${me}qstaf  | grep \/.*\/${me}.*${i} -o `   
 done > /tmp/tmp.${me}.run


for i in ${where}*.out* ; do if (  grep  -q ${i//.out/} /tmp/tmp.${me}.run) ; then echo $i still running ; fi ; done

elif [ $job == 4 ] ; then

qstat -f | grep Output_Path -A2 | sed "/--/d" | awk '{ if (NR%3 == 0 ) printf("%s%s%s \n", prev2, prev, $0 ) ; ; prev2=prev ; prev=$0  }' | sed "s/\t//g" | awk '{print $3}'  | sed "s/log_//" > /tmp/tmp.${me}qstaf

for i in ${where}*.dat ; do if [ ! -f ${i//dat/out} ] ; then  if ( !  grep -q `echo $i |  sed "s/.dat//"` /tmp/tmp.${me}qstaf ) ; then echo $i " hasn't been ran (isn't queuing)" ; fi ; fi ; done


fi



fi
