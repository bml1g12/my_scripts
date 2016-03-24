#!/bin/bash
#usage < input.pdb > output_fixed.pdb
awk '
BEGIN{n=1}
{
if (FNR <= 9) print $0;  

else if (FNR > 9 && $1 == "ATOM" && $3 != "P") 
    {print substr($0, 1, 24) n substr($0,27)}
    if ($3 == "P") 
        {n++
        print substr($0, 1, 24) n substr($0,27)}
        
else if ($1 != "ATOM" && FNR >9)
    {print $0}
}
'
