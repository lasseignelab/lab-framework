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

    Cloning into 'PKD_Research'...
    done.

    Create an empty repository for 'PKD_Research' on GitHub by using the
    following link and settings:

      https://github.com/organizations/lasseignelab/repositories/new

      * No template
      * Owner: lasseignelab
      * Repository name: PKD_Research
      * Private
      * No READEME file
      * No .gitignore
      * No license

    Once the Github repository has been created, run the following commands to
    upload the new project to Github:
      cd PKD_Research
      git push origin main

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

  # Find the lab framework installion directory.
  installed_directory=$(dirname "$(command -v lab)")

  # If the project doesn't exist then create it.
  if [ -d "$project_name" ]; then
    echo "Error: The directory '$project_name' already exists."
    exit 1
  fi
  echo
  git clone "$installed_directory"/project-template "$project_name"

  # If the project template clone succeeded then configure the repo.
  cd "$project_name" || echo "Error: Directory '$project_name' does not exist."
  if [ -d ".git" ]; then
    git remote remove origin
    git remote add origin git@github.com:lasseignelab/"$project_name".git

    echo
    cat <<EOF
Create an empty repository for '$project_name' on GitHub by using the
following link and settings:

  https://github.com/organizations/$github_account/repositories/new

  * No template
  * Owner: $github_account
  * Repository name: $project_name
  * Private
  * No READEME file
  * No .gitignore
  * No license

Once the Github repository has been created, run the following commands to
upload the new project to Github:
  cd $project_name
  git push origin main

Happy researching!!!

EOF
  fi
}

