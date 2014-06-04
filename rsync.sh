#!/bin/bash
rsync -h -i -z --log-file=$HOME/rsync.log -avs --delete --stats iridis4:/home/bml1g12/my_scripts/ /home/bml1g12/my_scripts/
