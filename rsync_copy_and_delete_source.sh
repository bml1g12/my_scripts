#!/bin/bash
# script.sh remote_source local_destination
# copies contents of remote_source_folder (not folder itself) files with compression, deleting all files at source.
# then deletes the folder

#untested

#$1=remote_machine_source e.g. m2
#$2=remote_machine_source_folder  e.g. /home/project/
#$3=destination:/folder/location e.g. .
rsync --stats -avz --remove-source-files $1:$2 $3
sleep 0.1
echo "deleting files on remote server"
ssh $1 rm -r $2 
