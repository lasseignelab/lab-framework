#!/bin/bash

md5_description() {
  cat <<EOF
  Calculates a combined MD5 checksum for one or more files.
EOF
}

md5_help() {
  md5_description
  echo

  cat <<EOF
  The "md5" command produces a combined MD5 checksum for all the files
  specified.  It will show a list of all files included to ensure that the
  result is as expected.

  Usage:
    lab md5 FILE...

    FILE... can be one or more file and/or directory specifications.

  Example:
    $ lab md5 *

    Files included:
    43bd364a97a38fb1da7c57e6381886c1  lab-cli/LICENSE
    b794df25f796ac80680c0e4d27308bce  lab-cli/commands/md5.sh
    0d9281c3586c420130bcb5d25c8a151a  lab-cli/lab
    5e79c988140af1b7bd5735b0bf96306b  lab-cli/README.md
    783a44ffae97afbce3f1649c5ff517a5  lab-cli/install.sh

    Combined MD5 checksum:
    a225199964b84bdeef33bafe3df7c10b
EOF
}

md5() {
  echo -e '\nFiles included:'
  md5_find "${@:1}"
  echo -e '\nCombined MD5 checksum:'
  md5_find "${@:1}" | cut -d ' ' -f1 | sort | md5sum | cut -d ' ' -f1
  echo
}

###############################################################################
# Finds all matching files and produces an MD5 checksum for each file.
#
# Usage:
# > md5_find FILE...
#
# Example:
# > md5_file ~/bin/lab-cli/commands
# 91845ed3e6ed80b6c93ffa4bc0587c42  bin/lab-cli/commands/md5dir.sh
# d2760f02c9d55fb4bf78d9ed0b398c4d  bin/lab-cli/commands/md5.sh
#
###############################################################################
md5_find() {
  find "${@:1}" -type f ! -path '*/\.*' -exec md5sum {} +
}
