#! /usr/bin/env bash
STARTTIME=$(date +%s)
set -o monitor 
# means: run background processes in a separate processes...
trap add_next_job CHLD 
# execute add_next_job when we receive a child complete signal
todo_array=($(seq 251 300)) # places output into an array
index=0
max_jobs=4

function add_next_job {
    # if still jobs to do then add one
    if [[ $index -lt ${#todo_array[*]} ]]
    # apparently stackoverflow doesn't like bash syntax
    # the hash in the if is not a comment - rather it's bash awkward way of getting its length
    then
        echo adding job ${todo_array[$index]}
        Rscript generator.R ${todo_array[$index]} & 
        # replace the line above with the command you want
        index=$(($index+1))
    fi
}

function do_job {
    echo "starting job $1"
    sleep 2
}

# add initial set of jobs
while [[ $index -lt $max_jobs ]]
do
    add_next_job
done

# wait for all jobs to complete
wait
echo "done"
ENDTIME=$(date +%s)
echo $(($ENDTIME - $STARTTIME))
