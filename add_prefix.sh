#!/bin/bash
echo "Usage: 'prefix' will add prefix to all files in folder"

for f in *; do
    mv $f $1_$f 
done
