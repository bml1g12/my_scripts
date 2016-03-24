#!/bin/bash

#Usage: run script in folder above cars directory with no arguments. Specify number of files in the head -n x statament. 

lastnfiles=1
rm curvestraj.pgp
rm tmp_pstrip.car
rm tmp_pwaterstrip.car
rm tmp.pdb

touch curvestraj.pgp
echo "MODEL        1" >> curvestraj.pgp

i=2
for file in `ls ./cars/*.car -lf | sort -V | head -n 3 `;
do
  echo "Processing $file"
   
  #Remove Phosphate group so that Babel can recognise a correctly terminated DNA sequence    
  sed '/P19/d' $file > tmp_pstrip.car
  #Remove water and silica so that Babel can have an easier job recognising the DNA (+ less disk space wasted on water)
  ~/my_scripts/remove_water_from_car.awk < tmp_pstrip.car > tmp_pwaterstrip.car
  
  #ions are seperated by "end" statements sometimes, this will cause problems later so we need to remove these lines and put in an end at the end
  sed '/end/d' tmp_pwaterstrip.car > tmp
  echo "end" >> tmp
  mv tmp tmp_pwaterstrip.car

  # Use Babel to convert to PDB. This should recognise the Nucelotide, and the message  "nohcounts" indicates this is succesful. 
  # The final PDB should have bases labeled and numbered. I've noticed if the sodium ions are present SOMETIMES this can cause this to fail; maybe
  # because it recognises them as part of the DNA sequence...
  babel -icar tmp_pwaterstrip.car -opdb tmp.pdb
  #Wrap PDB snapshots to central frame, as curves+ doesn't understand PBCs. Write to a file called "newpdb.pdb"
  vmd -dispdev text -eofexit tmp.pdb < ~/my_scripts/wrappdb.tcl 
  
  ##append previous output to curvestraj.pgp
  cat curvestraj.pgp newpdb.pdb > new.pdb
  mv new.pdb curvestraj.pgp
  echo "ENDMDL" >> curvestraj.pgp
  i=$[$i +1]
done

#sed -i '$ d' curvestraj.pgp #remove the last "ENDMDL" statement
