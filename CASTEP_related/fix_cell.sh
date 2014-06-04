#!/bin/bash

echo "the file provided is " $1

sed -i 's:O_00PBE.usp:/home/bml1g12/project/pseudopotentials/Civeralli/O_01_CBgga.usp:' $1
sed -i 's:Si_00PBE.usp:/home/bml1g12/project/pseudopotentials/Civeralli/Si_01_Vgga.usp:' $1
sed -i 's:H_00PBE.usp:/home/bml1g12/project/pseudopotentials/Civeralli/H_01_CBgga.usp:' $1

#sed creates dos ^M line endings. using ex, which is the cmd version of vi  Ican fix this:

ex $1 <<EOEX
:e ++ff=dos
:setlocal ff=unix
:wq
EOEX

echo "The File now looks like this in the BLOCK SPECIES_POT region:"

grep -A 5 "%BLOCK SPECIES_POT" $1



echo "The file has been edited. It's `date`"
