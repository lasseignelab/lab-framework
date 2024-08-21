#!/bin/bash

help_description() {
  cat <<EOF
  Shows help for the lab command line tool.
EOF
}

help_help() {
  help_description
  echo

  cat <<EOF
  The "help" command will display help for all the commands available for the
  lab command.

  Usage:
    lab help [COMMAND]

    COMMAND - optional parameter of command to show help for. If not command
      is provided then a list of all commands with a brief description will
      be shown.

  Example:
    $ lab help

    Commands:

    help  Shows help for the lab command line tool.
    md5   Calculates a combined MD5 checksum for one or more files.
EOF
}

help() {
  echo

  # Check if a parameter was provided
  if [ "$#" -eq 0 ]; then
    cat <<EOF
  Usage: lab COMMAND ...

  Commands:
    The following subcommands are available.

  COMMAND
EOF

    # Directory containing the scripts
    COMMANDS_DIR="$SCRIPT_DIR"/commands

    {
      # Loop through each script file in the directory
      for script in "$COMMANDS_DIR"/*.sh; do
        # Get the base name of the script (e.g., md5 for md5.sh)
        script_name=$(basename "$script" .sh)

        # Construct the function name
        description_function="${script_name}_description"

        # Check if the function exists
        if declare -f "$description_function" > /dev/null; then
          printf '    %s:' "$script_name"

          # Call the function
          "$description_function"
        else
          echo "Function $description_function not found in $script"
        fi
      done
    } | column -t -s ':'
  else
    # Retrieve the command name from the first parameter
    command_name=$1
    # Construct the function name
    help_function="${command_name}_help"
    # Call the function
    "$help_function"
  fi
  echo
}
