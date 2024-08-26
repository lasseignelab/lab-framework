#!/bin/bash

new_description() {
  cat <<EOF
  Creates a new reproducible research project.
EOF
}

new_help() {
  new_description
  echo

  cat <<EOF
  The "new" command produces a new reproducible research project based on
  a project template that adheres to a set of conventions.  The conventions
  include a directory structure, Github actions, stubbed out files.

  Usage:
    lab new GITHUB_ACCOUNT PROJECT_NAME

    GITHUB_ACCOUNT Github account the project repo will be created under.
    PROJECT_NAME   Name of the project which will match the Github repo name.

  Example:
    $ lab new lasseignelab PKD_Research

    Create an empty repository for 'PKD_Research' on GitHub by using the
    following link and settings:

      https://github.com/organizations/lasseignelab/repositories/new

      * No template
      * Owner: lasseignelab
      * Repository name: PKD_Research
      * Private
      * No README file
      * No .gitignore
      * No license

    Where you able to create a repository (y/N)? y


    Cloning into 'PKD_Research'...
    done.

    ...

    Happy researching!!!
EOF
}

new() {
  # Check that both parameters were passed
  if [ "$#" -ne 2 ]; then
    echo "Error: incorrect number of parameters"
    echo "Usage: lab new GITHUB_ACCOUNT PROJECT_NAME"
    return 1
  fi
  github_account=$1
  project_name=$2

  # If the project directory exists then abort.
  if [ -d "$project_name" ]; then
    echo "Error: The directory '$project_name' already exists."
    exit 1
  fi

  # Find the lab framework installion directory.
  installed_directory=$(dirname "$(command -v lab)")

  # Prompt the researcher to create a repository on Github
  cat <<EOF

Create an empty repository for '$project_name' on GitHub by using the
following link and settings:

  https://github.com/organizations/$github_account/repositories/new

  * No template
  * Owner: $github_account
  * Repository name: $project_name
  * Private
  * No README file
  * No .gitignore
  * No license

EOF

  echo -n "Where you able to create a repository (y/N)? "
  read -r response
  response=${response,,}
  echo
  if [[ "$response" != "y" ]]; then
    echo "New project creation aborted."
    echo
    exit 0
  fi

  # Clone, configure, and push the project.
  echo
  git clone "$installed_directory"/project-template "$project_name"
  cd "$project_name" || echo "Error: Directory '$project_name' does not exist."
  if [ -d ".git" ]; then
    rm -rf .git
    git init
    git remote add origin git@github.com:"$github_account"/"$project_name".git
    git add .
    git commit -m "Initial commit"
    git branch -m master main
    git push origin main

    echo
    echo "Happy researching!!!"
    echo
  fi
}

