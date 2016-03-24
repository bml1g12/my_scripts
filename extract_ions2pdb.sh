#!/bin/bash
#Babel has issues convering cars with ions near to DNA. So this script:
#Extracts ions from car. Produces pdb. Produces a pdb file from just the ions. Then cuts out the HETATMs into a tmp2_ions.pdb
#Also produces car with ions stripped "tmp_pwaterionstrip.car"
#Usage: supply 1st argument as .car file

awk '{if (NR <= 5) {print $0}}' $1 > tmp_ions.car  #print header
awk '{if (($7 == "na+") || ($7 == "cl-") || ($7 == "mg+2")) {print $0}}' $1 >> tmp_ions.car
awk '{if (($7 != "na+") && ($7 != "cl-") && ($7 != "mg+2")) {print $0}}' $1 > tmp_pwaterionstrip.car 
echo "end" >> tmp_ions.car
babel -icar tmp_ions.car -opdb tmp1_ions.pdb
rm tmp_ions.car
awk '{if ($1 == "HETATM") {print $0}}' tmp1_ions.pdb > tmp2_ions.pdb
rm tmp1_ions.pdb


