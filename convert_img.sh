#!/bin/bash
echo "Usage: 'convert_img.sh tga tiff' will convert all tga's in the folder to tiff"

for img in *.$1; do
    filename=${img%.*}
    convert "$filename.$1" "$filename.$2"
done
