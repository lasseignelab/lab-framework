#!/bin/bash

lab_run_description() {
  cat <<EOF
  Runs a lab framework job.
EOF
}

lab_run_help() {
  lab_run_description
  echo

  cat <<EOF
  The "run" command runs a lab framework job within the context of a
  reproducible research project.  It will configure the environment based
  on configuration defined by the current user.

  Usage:
    lab run [options] FILE

    FILE  File name of the job to run.

    Options:

    -e,--environment
               Specifies the environment to run jobs in.  Environments allow
               different setups for a pipeline.  For instance, a pipeline may
               use internal copies of data during development but download that
               data when the pipeline is ran in a different environment.
    -n,--dry-run
               Displays the contents of the job to run along with the context
               it will run in.

  Example:
    $ lab run src/data_download.sh
    Submitted batch job 29818073
EOF
}

lab_run() {
  lab_run_parse_commandline_parameters "$@"

  job_directory=$(dirname "$job_file")
  job_name=$(basename "${job_file%.*}")

  # In order to insert the framework functions into the job, the job
  # is broken up into 3 pieces and then put back together with the
  # framework functions right before the code.
  slurm_shebang=$(head -n 1 $job_file | grep -E "^#!" )
  slurm_header=$(grep "#SBATCH" $job_file)
  slurm_code=$(grep -v -E "(^#\!)|(#SBATCH)" "$job_file")

  # Location where the lab framework was installed.
  lab_install_path=$(command -v lab)
  lab_install_dir=$(dirname "$lab_install_path")

  # Put job back together with the framework function included.
  slurm_job=$(cat <<EOF
$slurm_shebang
$slurm_header
source $lab_install_dir/lib/functions.sh
$slurm_code
EOF
)

  # Setup the runtime environment for the job.
  if [ -n "$environment_override" ]; then
    LAB_ENV="$environment_override"
  fi
  source "$lab_install_dir/lib/environment.sh"


  # Specify the log file names with their full path. Log file names will
  # begin with <job name>-<date>-<time>-<username>. If the job is an array
  # job then the job array id and task id will be appended.
  log_full_path=$(realpath "$LAB_LOGS_PATH")
  log_file_name="${job_name%.*}_"$(date "+%Y%m%d_%H%M%S")"_%u"
  if grep -q -E "^#SBATCH +--array=" "$job_file"; then
    log_file_name="$log_file_name-%A-%a"
  fi

  # If it is a dry run then just display the environment variables and job
  # code. Otherwise, submit the job.
  if [[ "$dry_run" == "true" ]]; then
    lab_run_dry_run
  else
    sbatch -D "$job_directory" \
      --job-name="$LAB_PROJECT_NAME_${job_name%.*}" \
      --output "$log_full_path/$log_file_name.out" \
      --error "$log_full_path/$log_file_name.err" \
      <<EOF
$slurm_job
EOF
  fi
}

lab_run_dry_run() {
  echo
  echo "Environment: $LAB_ENV"
  echo
  # Display the framework environment variables.
  env | grep -E "^LAB"
  echo
  echo "Job: $job_name"
  echo
  # Display job code with line numbers.
  cat -n <<EOF
$slurm_job
EOF
  echo
}

lab_run_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o ne: --long dry-run,environment: -- "$@"); then
    echo "Use the 'lab help run' command for detailed help."
    exit 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  dry_run=false
  environment_override=""

  # Parse the optional named command line options
  while true; do
    case "$1" in
      -n|--dry-run)
        dry_run=true
        shift 1 ;;
      -e|--environment)
        environment_override=$2
        shift 2 ;;
      --)
        shift
        break;;
    esac
  done

  # Check that the required job file parameter was provided
  if [ "$#" -ne 1 ]; then
    echo "Error: incorrect number of parameters"
    echo "Usage: lab run [options] FILE"
    echo "Use the 'lab help run' command for detailed help."
    exit 1
  fi
  job_file="$1"
}
