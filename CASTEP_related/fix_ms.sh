#!/bin/bash

cell=`echo *.cell`

echo "the file provided is " $cell
echo "EDITING CELL FILE..."
sed -i 's:O_00PBE.usp:/home/bml1g12/project/pseudopotentials/Civeralli/O_01_CBgga.usp:' $cell
sed -i 's:Si_00PBE.usp:/home/bml1g12/project/pseudopotentials/Civeralli/Si_01_Vgga.usp:' $cell
sed -i 's:H_00PBE.usp:/home/bml1g12/project/pseudopotentials/Civeralli/H_01_CBgga.usp:' $cell

#sed creates dos ^M line endings. using ex, which is the cmd version of vi  Ican fix this:

ex $cell <<EOEX
:e ++ff=dos
:setlocal ff=unix
:wq
EOEX

echo "The File now looks like this in the BLOCK SPECIES_POT region:"

grep -A 5 "%BLOCK SPECIES_POT" $cell



echo "The file has been edited. It's `date`"

echo "EDITING PARAM FILE..."

param=`echo *.param`
echo "the file provided is " $param

if grep -q geom_method $param; then
    sed -i 's/geom_method.*/geom_method : LBFGS/' $param
    grep geom_method $param
else
    echo "geom_method : LBFGS" >> $param
    echo "appending geom_method : LBFGS"
fi

if grep -q opt_strategy $param; then
    sed -i 's/opt_strategy.*/opt_strategy : speed/' $param
    grep opt_strategy $param
else
    echo "opt_strategy : speed" >> $param
    echo "appending  opt_strategy : speedS"
fi

if grep -q num_backup_iter $param; then
    sed -i 's/num_backup_iter.*/num_backup_iter : 1/' $param
    grep num_backup_iter $param
else
    echo "num_backup_iter : 1" >> $param
    echo "appending num_backup_iter : 1"
fi

if grep -q iprint $param; then
    sed -i 's/iprint.*/iprint : 2/' $param
    grep iprint $param
else
    echo "iprint : 2" >> $param
    echo "appending iprint : 2"
fi

if grep -q calculate_stress $param; then
    sed -i 's/calculate_stress.*/calculate_stress : TRUE/' $param
    grep iprint $param
else
    echo "calculate_stress : TRUE" >> $param
    echo "appending calculate_stress : TRUE"
fi


#sed creates dos ^M line endings. using ex, which is the cmd version of vi  Ican fix this:

ex $param <<EOEX
:e ++ff=dos
:setlocal ff=unix
:wq
EOEX


echo "The file has been edited. It's `date`."
echo "(Remember to check k point, ecutoff and constraints etc.)"
