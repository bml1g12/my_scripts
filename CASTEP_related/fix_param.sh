#!/bin/bash

echo "the file provided is " $1

if grep -q geom_method $1; then
    sed -i 's/geom_method.*/geom_method : LBFGS/' $1
    grep geom_method $1
else
    echo "geom_method : LBFGS" >> $1
    echo "appending geom_method : LBFGS"
fi

if grep -q opt_strategy $1; then
    sed -i 's/opt_strategy.*/opt_strategy : speed/' $1
    grep opt_strategy $1
else
    echo "opt_strategy : speed" >> $1
    echo "appending  opt_strategy : speedS"
fi

if grep -q num_backup_iter $1; then
    sed -i 's/num_backup_iter.*/num_backup_iter : 1/' $1
    grep num_backup_iter $1
else
    echo "num_backup_iter : 1" >> $1
    echo "appending num_backup_iter : 1"
fi

if grep -q iprint $1; then
    sed -i 's/iprint.*/iprint : 2/' $1
    grep iprint $1
else
    echo "iprint : 2" >> $1
    echo "appending iprint : 2"
fi

if grep -q calculate_stress $1; then
    sed -i 's/calculate_stress.*/calculate_stress : TRUE/' $1
    grep iprint $1
else
    echo "calculate_stress : TRUE" >> $1
    echo "appending calculate_stress : TRUE"
fi


#sed creates dos ^M line endings. using ex, which is the cmd version of vi  Ican fix this:

ex $1 <<EOEX
:e ++ff=dos
:setlocal ff=unix
:wq
EOEX


echo "The file has been edited. It's `date`."
echo "(Remember to check k point, ecutoff and constraints etc.)"
