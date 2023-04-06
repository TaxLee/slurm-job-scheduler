#!/bin/bash

# This script loops through all subdirectories in the current directory,
# submitting a Slurm job for each directory based on the SlurmRun script.
# It checks for existing tarball files and running or pending jobs on the
# specified node before submitting a new job.

# Set the target node
node="node2"

# Loop through all subdirectories in the current directory
for dir in */; do

    # Wait for 2 seconds before starting the loop as the Slurm scheduler may not have updated the job status
    sleep 2

    # Set the name of the tarball file
    tarball="${dir%/}.tar.gz"
    
    # Check if the tarball file already exists in the subdirectory
    if [ -f "$tarball" ]; then
        echo "Skipping directory: $dir (tarball file already exists)"
        continue
    fi
    
    # Echo the name of the subdirectory
    echo "Entering directory: $dir"
    
    # Change to the subdirectory
    cd "$dir" || exit

    # Check if there are any running or pending jobs on the target node
    running_jobs=$(squeue -t running --noheader | grep -E "n${node: -1}_")
    pending_jobs=$(squeue -t pending --noheader | grep -E "n${node: -1}_")

    if [ -z "$running_jobs" ] && [ -z "$pending_jobs" ]; then
        # If there are no running or pending jobs, submit a new job to run SlurmRun
        echo "No running or pending jobs on $node, submitting new job"
        sbatch SlurmRun
    elif [ -z "$pending_jobs" ]; then
        # If there are no pending jobs, submit the new job after the running job ID on the given node
        echo "Waiting for previous job(s) to complete on $node"
        running_job_id=$(squeue -t running --noheader | grep -E "n${node: -1}_" | awk '{print $1}' | tail -n 1)
        echo "Submitting new job after running job ID $running_job_id"
        sbatch --dependency=afterany:"$running_job_id" SlurmRun
    else
        # If there are pending jobs, find the last job ID on the target node and submit the new job after that job ID
        echo "Waiting for previous job(s) to complete on $node"
        last_job_id=$(squeue -t pending --noheader | grep -E "n${node: -1}_" | awk '{print $1}' | tail -n 1)
        echo "Submitting new job after job ID $last_job_id"
        sbatch --dependency=afterany:"$last_job_id" SlurmRun
    fi

    
    # Change back to the parent directory
    cd .. || exit
done
