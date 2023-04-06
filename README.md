# slurm-job-scheduler
A Bash script to automate the submission of Slurm jobs on a specified node, taking into account running and pending jobs on the target node.

## Description

This script simplifies the process of submitting Slurm jobs by automatically managing job dependencies on a specific compute node. It loops through all the subdirectories in the current directory and submits jobs, ensuring that each new job is queued after the last job on the target node. **Note that the name of the Slurm job needs to contain "n{node number}_" for the script to work correctly.**

## Usage

1. Clone this repository or download the `submitJobs.sh` script.
2. Modify the `node` variable in the script to target the desired compute node.
3. Ensure that the script has executable permissions by running `chmod +x submitJobs.sh`.
4. Run the script using `./submitJobs.sh`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
