#!/bin/bash

#extract lines form a nwchem .nwo, just the liens with atoms on it into a non-seperated file
# put the exact load of strings for the specific molecule into the egrep
awk 'c&&c--;/'\-step'/{c=14}' Rb.nwo | egrep '(1 Si)|(2 O)|(3 H)|(4 O)|(5 H)|(6 H)|(7 H)|(8 H)' | awk {'print $2" "$4" "$5" "$6'} > tmp.xyz
#convert from Bohr to Angstroms
cat tmp.xyz | awk '{printf("%2s    %10.6f     %10.6f %10.6f\n", $1, $2*0.529177249, $3*0.529177249, $4*0.529177249 ) }' > tmp_ang.xyz
#replace number here with the number of atoms
echo "\n8 \ncomment" > optimised_nwchem.xyz
sed '0~8 s/$/\n8 \ncomment/g' < tmp_ang.xyz >> optimised_nwchem.xyz
#rm tmp.xyz 
#rm tmp_ang.xyz 

