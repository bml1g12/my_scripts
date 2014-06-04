#!/bin/bash

#compresses all files in the current directory without going into sub directory

if [ "$#" == "0" ]; then
    echo "Provide basename of output directory"
    exit 1
fi


#the \+ on the end ensures it runs it all on one line rather than an excectuion for each file
find . -maxdepth 1 -type f \( -iname "*" \) -exec tar jcvf $1.tar.bz2 {} \+
#find . -maxdepth 1 -type f \( -iname "*" ! -iname "*.check_bak" \) -exec tar jcvf $1.tar.bz2 {} \+
