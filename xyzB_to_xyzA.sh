#!/bin/bash
#24/04/2014 Benjaming Lowe
#Provide a .xyz coordinates (NO HEADER, ATOM COUNT) in bohr and returns it in angstrom (with and without HEADER, ATOM COUNT, seperate files)
#Usage: ./script.sh inputname.xyz 
#Outputs inputname_ang.xyz  

#note: babel -imol2 *.mol2 -oxyz -m 
#will convert all mol2 files in the folder to xyz

filename=$1
echo "Filename is $filename"
basename=$(basename "$filename" .xyz)
echo "basename is $basename"
#sed -n '1,2p' $1 > header.tmp
#sed -n '3,9999p' $1 > xyz_bohr.tmp

atom_count=`wc -l $filename | awk {'print $1'}`
echo "$atom_count" > header.tmp
echo "header" >> header.tmp

cat $filename | awk '{printf("%2s    %10.6f     %10.6f %10.6f\n", $1, $2*0.529177249, $3*0.529177249, $4*0.529177249 ) }' > xyz_ang.tmp

cat xyz_ang.tmp > $basename\_ang_coord.xyz
cat header.tmp xyz_ang.tmp > $basename\_ang.xyz

rm -f header.tmp
rm -f xyz_angstrom.tmp
rm -f xyz_bohr.tmp
