#!/bin/bash
#Take a .geom file and extracts the finalmost coordinate section. Produced vmd readable optimised.xyz
#input:./script.sh filename.geom
#output: optimised.xyz


filename=$1
basename=$(basename "$filename" .geom)
tac $filename > reverse
tail -n +2 reverse > reverse_no_whitespace #remove whitespace first line
grep -m 1 -B 999 '^[[:space:]]*$' reverse_no_whitespace > optimised_reversed #grab the optimised geometry based on new lines
tac optimised_reversed > optimised_geom #reverse the file
grep '<-- R' optimised_geom | awk {'print $1" "$3" "$4" "$5'} > bc.xyz

xyzB_to_xyzA.sh bc.xyz 

rm bc_ang_coord.xyz
echo "writing optimized.xyz"
mv bc_ang.xyz optimised.xyz

rm -f reverse
rm -f reverse_no_whitespace
rm -f optimised_reversed
rm -f optimised_geom
rm -f bc.xyz
