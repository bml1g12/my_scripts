#!/bin/bash
#Ben Lowe
#25/04/2014
#Simple script to extract energy components from a converged ONETEP calculation. iterated over all numeric subfolders and grabs the filename

filename=$1

echo "dir, kinetic, ploc, pnonloc, hartree, xc, ewald, total"
for dir in `find . -maxdepth 1 -type d -name '[0-9]*'`
do
 #echo "entering $dir"
 cd $dir
 kinetic=`grep 'CALCULATION SUMMARY' -B 17 $filename.onetep | grep 'Kinetic' | awk {'print $4'}`
 ploc=`grep 'CALCULATION SUMMARY' -B 17 $filename.onetep | grep 'Total' -B 999 |  grep 'Pseudopotential (local)' | awk {'print $5'}`
 pnonloc=`grep 'CALCULATION SUMMARY' -B 17 $filename.onetep | grep 'Pseudopotential (non-local)' | awk {'print $4'}`
 hartree=`grep 'CALCULATION SUMMARY' -B 17 $filename.onetep | grep 'Total' -B 999 | grep 'Hartree' | awk {'print $4'}`
 xc=`grep 'CALCULATION SUMMARY' -B 17 $filename.onetep | grep 'Exchange-correlation' | awk {'print $4'}`
 ewald=`grep 'CALCULATION SUMMARY' -B 17 $filename.onetep | grep 'Ewald' | awk {'print $4'}`
 total=`grep 'CALCULATION SUMMARY' -B 17 $filename.onetep | grep 'Total' | awk {'print $4'}`
 echo "${dir:2}, $kinetic, $ploc, $pnonloc, $hartree, $xc, $ewald, $total"
 #Note: the above is a string subsisituion to cut off './' using ${var:2}
 cd ..
done

