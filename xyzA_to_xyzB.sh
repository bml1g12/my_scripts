#!/bin/bash
#24/04/2014 Benjaming Lowe
#Provide a .xyz file (with ATOM COUNT, HEADER) in angstroms and returns it in bohr (with and without, header atom count, seperate files)
#Usage: ./script.sh inputname.xyz 
#Outputs inputname_bohr.xyz  

#note: babel -imol2 *.mol2 -oxyz -m 
#will convert all mol2 files in the folder to xyz

filename=$1
echo "Filename is $filename"
basename=$(basename "$filename" .xyz)
echo "basename is $basename"
sed -n '1,2p' $1 > header.tmp
sed -n '3,9999p' $1 > xyz_angstrom.tmp

cat xyz_angstrom.tmp | awk '{printf("%2s    %10.6f     %10.6f %10.6f\n", $1, $2/0.529177249, $3/0.529177249, $4/0.529177249 ) }' > xyz_bohr.tmp

cat xyz_bohr.tmp > $basename\_bohr_coord.xyz
cat header.tmp xyz_bohr.tmp > $basename\_bohr.xyz

rm header.tmp
rm xyz_angstrom.tmp
rm xyz_bohr.tmp
