#!/bin/bash
# gets the energies from AMBER out files ( not bond,angle,dihedral energies)
# -g gas energies
# -s solvated energies (if implicit solvent used) 

#gas=0;sol=0

#while getopts "gs" flag; do
#        if [ "$flag" == "?" ]; then
#                echo "Improper invocation." >&2
#                echo -e " flags \n
#                -g gas energy from AMBER outputs
#                -s solvated energy from amber outputs "&>2
#                   errcode=1; abort
#        fi
#        if [ "$flag" == "g" ] ; then gas=1 ; fi
#        if [ "$flag" == "s" ] ; then sol=1  ; fi

#done

#if [ $gas == 1 ] ; then
#for i in `ls complex_snapshot*pdb* -v1 | awk 'BEGIN{FS="."}{print $3}'`  ;         do  lig=$(echo `grep VDWAALS -A 1 -m1 ligand*out.${i} ` | awk '{printf("%s;%15.3f\n", $1, $3+$6+$13+$17+$20)}' |awk '{print $2}'  );         com=$(echo `grep VDWAALS -A 1 -m1 complex*out.${i} ` | awk '{printf("%s;%15.3f\n", $1, $3+$6+$13+$17+$20)}'|awk '{print $2}' );         host=$(echo `grep VDWAALS -A 1 -m1 host*out.${i} ` | awk '{printf("%s;%15.3f\n", $1, $3+$6+$13+$17+$20)}'|awk '{print $2}'  ); be=`echo $com $host $lig | awk '{print $1-$2-$3}'` ;    echo $i ";" $com ";" $host ";" $lig "; ;" $be ; done > MM-gas-energies 

#fi

#if [ $sol == 1 ] ; then

 #for i in `ls complex_snapshot*pdb* -v1 | awk 'BEGIN{FS="."}{print $3}'`  ;         do  lig=$(echo `grep VDWAALS -A 2 -m1 ligand*out.${i} ` | awk '{printf("%s;%15.3f\n", $1, $3+$6+$9+$13+$17+$20+$23)}' |awk '{print $2}'  );         com=$(echo `grep VDWAALS -A 2 -m1 complex*out.${i} ` | awk '{printf("%s;%15.3f\n", $1, $3+$6+$9+$13+$17+$20+$23)}'|awk '{print $2}' );         host=$(echo `grep VDWAALS -A 2 -m1 host*out.${i} ` | awk '{printf("%s;%15.3f\n", $1, $3+$6+$9+$13+$17+$20+$23)}'|awk '{print $2}'  ) ;  echo $i ";" $com ";" $host ";" $lig ";" `echo $com $host $lig | awk '{print $1-$2-$3}'` ; done > MM-solv-energies

#fi


#pulls out E_gas G_polar G_nonpolar G_Tot and stores in a variable

echo ";Complex ; ; ; ; Host ; ; ; ; Ligand ; ; ; ;; Binding energies
      ;gas ; polar; non polar ; total ; gas ; polar; non polar ; total ;gas ; polar; non polar ; total ; ;gas ; polar; non polar ; total " >     MM-energies-solvation.csv

for i in `ls complex_snapshot*.out* -v1 | awk -F"." '{if ($(NF-1) !=out )  print $(NF-1) ; else print $NF}'` ; do 
jj=`ls complex_snapshot*.out* -v1 | head -n1 |  awk -v ii=$i -F"." '{if ($(NF-1) !=out )  print ii".out" ; else print "out."ii}'`
echo $i
echo $jj
	lig=$(echo `grep VDW -m2 -A 1 ligand*${jj}  ` | awk '{OFS=";"}{ gas=$3+$6+$13+$17 ; spolar=$9 ; sapolar=$23 ; tot=gas+spolar+sapolar ; print gas, spolar, sapolar, tot }') ; 
	com=$(echo `grep VDW -m2 -A 1 complex*${jj} ` | awk '{OFS=";"}{ gas=$3+$6+$13+$17 ; spolar=$9 ; sapolar=$23 ; tot=gas+spolar+sapolar ; print gas, spolar, sapolar, tot }')
	host=$(echo `grep VDW -m2 -A 1  host*${jj} ` | awk '{OFS=";"}{ gas=$3+$6+$13+$17 ; spolar=$9 ; sapolar=$23 ; tot=gas+spolar+sapolar ; print gas, spolar, sapolar, tot }')

	BE_gas=`echo $(echo $lig | awk -F";" '{print $1}') $(echo $host | awk -F";" '{print $1}')  $(echo $com | awk -F";" '{print $1}') |awk '{print $3-$2-$1}'`
	BE_polar=`echo $(echo $lig | awk -F";" '{print $2}') $(echo $host | awk -F";" '{print $2}')  $(echo $com | awk -F";" '{print $2}') |awk '{print $3-$2-$1}'`
	BE_apolar=`echo $(echo $lig | awk -F";" '{print $3}') $(echo $host | awk -F";" '{print $3}')  $(echo $com | awk -F";" '{print $3}') |awk '{print $3-$2-$1}'`
	BE_tot=`echo $(echo $lig | awk -F";" '{print $4}') $(echo $host | awk -F";" '{print $4}')  $(echo $com | awk -F";" '{print $4}') |awk '{print $3-$2-$1}'`

	echo " $i; $com ; $host ; $lig ; ; $BE_gas ; $BE_polar ; $BE_apolar ; $BE_tot " >> MM-energies-solvation.csv
done

count=`ls com*.out* -1v | wc -l`
start="3"
end=$(echo "$count+2"|bc)

echo "
" >> MM-energies-solvation.csv

echo "MEAN;=average(B$start:B$end);=average(C$start:C$end);=average(D$start:D$end);=average(E$start:E$end);=average(F$start:F$end);=average(G$start:G$end);=average(H$start:H$end);=average(I$start:I$end);=average(J$start:J$end);=average(K$start:K$end);=average(L$start:L$end);=average(M$start:M$end); ;=average(O$start:O$end);=average(P$start:P$end);=average(Q$start:Q$end);=average(R$start:R$end)
MAX;=max(B$start:B$end);=max(C$start:C$end);=max(D$start:D$end);=max(E$start:E$end);=max(F$start:F$end);=max(G$start:G$end);=max(H$start:H$end);=max(I$start:I$end);=max(J$start:J$end);=max(K$start:K$end);=max(L$start:L$end);=max(M$start:M$end); ;=max(O$start:O$end);=max(P$start:P$end);=max(Q$start:Q$end);=max(R$start:R$end)
MIN;=min(B$start:B$end);=min(C$start:C$end);=min(D$start:D$end);=min(E$start:E$end);=min(F$start:F$end);=min(G$start:G$end);=min(H$start:H$end);=min(I$start:I$end);=min(J$start:J$end);=min(K$start:K$end);=min(L$start:L$end);=min(M$start:M$end); ;=min(O$start:O$end);=min(P$start:P$end);=min(Q$start:Q$end);=min(R$start:R$end) 
MEDIAN;=median(B$start:B$end);=median(C$start:C$end);=median(D$start:D$end);=median(E$start:E$end);=median(F$start:F$end);=median(G$start:G$end);=median(H$start:H$end);=median(I$start:I$end);=median(J$start:J$end);=median(K$start:K$end);=median(L$start:L$end);=median(M$start:M$end); ;=median(O$start:O$end);=median(P$start:P$end);=median(Q$start:Q$end);=median(R$start:R$end)
" >>  MM-energies-solvation.csv
