#!/bin/bash
#Created on 30/09/2014 by Benjamin Lowe
#This script creates a rsync copy of a source directory to a destination directory

#Usage: Specify $src and $dst folders, then type, 'crontab -e' to run this script periodically, providing crontab with the location of this bash script:
# 0 19 * * 5 /bin/sh LOCATION_OF_THIS_SCRIPT/rsync.sh
#This will run the back up at 1900 every friday
#You can check for crontab jobs by typing: crontab -l


#Log Files:

#At the src we will have the most recent sync log at $src/most_recent_rsync_"$src_identifier".log 
#At the src ~/rsync_logs we will have a complete dated record of all rsyncs
#At the destination we will have a record of the most up to date rsync log at $dst/ 


#create a directory to store source record of rsyncs if it doesnt exist
mkdir -p ~/rsync_logs
rsync_log_dir=~/rsync_logs #this folder will contain a full list of all rsyncs with dates


#who am I? and where am I? when am I?
me=`whoami`
pc=`hostname`
date=`date "+%m-%d-%y_%H-%M"`


src=/home/bml1g12/test/src # remember to add trailing backslash to provide the contents of the folder
dst=/home/bml1g12/test/dest # no trailing backslash to copy into destination folder 
src_identifier=`echo -n $src | tail -c 3` # create a 3 charachter identifer based on the source folder name

echo "`date` Running Rsync from $src to $dst on hostname:$pc user:$me" > tmp_datetime.log
rsync -h -s -z --log-file=$rsync_log_dir/"$date"_"$src_identifier"_rsync.log -avs --stats --update --exclude-from '/home/bml1g12/my_scripts/rsync_exclude_me.txt' $src/ $dst >> $src/tmp_rsync.log

#Ensure that a copy of the most up the date log is placed in the $src
cat tmp_datetime.log ~/rsync_logs/"$date"_"$src_identifier"_rsync.log $src/tmp_rsync.log > $src/most_recent_"$src_identifier"_rsync.log
#overwrite the rsync log in $rsync_log_dir with a full .log including when and how it was run
cat tmp_datetime.log ~/rsync_logs/"$date"_"$src_identifier"_rsync.log $src/tmp_rsync.log > $rsync_log_dir/"$date"_"$src_identifier"_rsync.log

#clear up tmp files. The exclude files list in rsync can be used to ensure these arent rsynced over
rm tmp_datetime.log
rm $src/tmp_rsync.log 

#Ensure that a copy of the most up the date log is placed in the $dst 
#cat $src/most_recent_rsync_"$src_identifier".log | ssh bml1g12@ssh.soton.ac.uk:$dst/ "cat >> most_recent_rsync_"$src_identifier".log"
cat $src/most_recent_"$src_identifier"_rsync.log >> $dst/most_recent_"$src_identifier"_rsync.log
