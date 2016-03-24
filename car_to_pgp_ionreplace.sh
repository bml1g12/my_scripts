#!/bin/bash

rm curvestraj.pgp
rm tmp_pstrip.car
rm tmp_pwaterstrip.car
rm tmp.pdb

touch curvestraj.pgp
echo "MODEL        1" >> curvestraj.pgp

i=2
for file in `ls /local/scratch/bml1g12/ElectrolyteDynamics/1000mM_DNA/cars/*.car -lf | sort -V | tail -n 500`;
do
  echo "================Processing ${file} ===================="
   
  #Remove Phosphate group so that Babel can recognise a correctly terminated DNA sequence    
  sed '/P19/d' $file > tmp_pstrip.car
  #Remove water and silica so that Babel can have an easier job recognising the DNA (+ less disk space wasted on water)
  ~/my_scripts/remove_water_from_car.awk < tmp_pstrip.car > tmp_pwaterstrip.car
  
  ~/my_scripts/extract_ions2pdb.sh tmp_pwaterstrip.car #produces tmp2_ions.pdb and tmp_pwaterionstrip.car (ions pdb and no ions car)
 
  # Use Babel to convert to PDB. This should recognise the Nucelotide, and the message  "nohcounts" indicates this is succesful. 
  # The final PDB should have bases labeled and numbered. I've noticed if the sodium ions are present SOMETIMES this can cause this to fail; maybe because it recognises them as part of the DNA sequence...
  babel -icar tmp_pwaterionstrip.car -opdb tmp.pdb

  #now we need to merge the tmp2_ions.pdb with the tmp.pdb
  #paste contents of file1 into file2 before 'CONECT' statement 
  line=$(grep -n 'CONECT' tmp.pdb | cut -d ":" -f 1) #list of line numbers with CONECT on them
  line=$(echo $line | awk {'print $1'}) #First line number with CONECT on it
  { head -n $(($line-1)) tmp.pdb; cat tmp2_ions.pdb; tail -n +$line tmp.pdb; } > tmp3_merged.pdb #inset tmp2_ions.pdb before first occurance of CONECT in tmp.pdb 

  #Wrap PDB snapshots to central frame, as curves+ doesn't understand PBCs. Write to a file called "newpdb.pdb"
  vmd -dispdev text -eofexit tmp3_merged.pdb < ~/my_scripts/wrappdb.tcl 
  rm tmp3_merged.pdb
  rm tmp.pdb
  rm tmp2_ions.pdb
 
  ##append previous output to curvestraj.pgp
  cat curvestraj.pgp newpdb.pdb > tmp_curvestraj.pgp
  mv tmp_curvestraj.pgp curvestraj.pgp
  echo "ENDMDL" >> curvestraj.pgp
  echo "MODEL        $i" >> curvestraj.pgp
  i=$[$i +1]
done

sed -i '$ d' curvestraj.pgp #remove the last "MODEL     $i" statement
