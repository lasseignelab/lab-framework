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
  include a directory structure, Github actions, and stubbed out files.

  Usage:
    lab new GITHUB_OWNER PROJECT_NAME

    GITHUB_OWNER Github owner the project repo will be created under.  This may
                 be a personal or organization account.
    PROJECT_NAME Name of the project which will match the Github repo name.

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
    echo "Usage: lab new GITHUB_OWNER PROJECT_NAME"
    echo "Use the 'lab help new' command for detailed help."
    return 1
  fi
  github_account=$1
  project_name=$2

  # If the project directory exists then abort.
  if [ -d "$project_name" ]; then
    echo "Error: The directory '$project_name' already exists."
    return 1
  fi

  # If Github SSH is not configured then abort.
  if ! ssh -T git@github.com 2>&1 | grep -q 'successfully authenticated'; then
    github_docs="https://docs.github.com/en"
    github_ssh_docs="$github_docs/authentication/connecting-to-github-with-ssh"
    cat <<EOF

Github SSH is not configured or there's an issue. Please configure SSH keys
for Github before proceeding.

To setup SSH for connecting to Github do the following steps:
  1) Check for existing SSH keys:
     $github_ssh_docs/checking-for-existing-ssh-keys
  2) If no key exists, generate a new SSH key:
     $github_ssh_docs/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
  3) Add a new SSH key to your github user account:
     $github_ssh_docs/adding-a-new-ssh-key-to-your-github-account

EOF
    return 1
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
    return 0
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

