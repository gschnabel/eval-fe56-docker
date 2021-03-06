#!/bin/bash

service ssh start 
rstudio-server start
mongod --fork --logpath /var/log/mongod.log

export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8

# map the user in the container to some external user
sed -i "s/^username:x:[0-9]\+:[0-9]\+/username:x:$extUID:$extGID/" /etc/passwd
chown "username:username" /home/username
cd /home/username
chown -R "username:username" .ssh calcdir remcalcdir talysResults eval-fe56

# run a command that keeps the container
# alive when it is restarted.
# this is to make sure that a container
# can be inspected more easily when
# restarted after termination.
state_file="/root/cont_executed"
if [ -f "$state_file" ]; then
    cnt=$(cat $state_file)
    cnt=$(($cnt+1))
    echo $cnt > "$state_file"
    while true; do sleep 1; done    
fi
echo 1 > "$state_file"

# start an interactive session inside the container
if [ $1 = 'interactive' ]; then
    su username
elif [ $1 = 'interactive_root' ]; then
    /bin/bash
# run an evaluation and stop the container once finished
elif [ $1 = 'test_eval' ]; then
    su -c "cd eval-fe56; Rscript --vanilla run_pipeline.R" username
elif [ $1 = 'full_eval' ]; then
    su -c "cd eval-fe56; mv config.R test_config.R; mv config.R.fulleval config.R; Rscript --vanilla run_pipeline.R" username
fi
