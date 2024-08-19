#!/bin/bash

# Check if $HOME/bin is already in PATH
if ! grep -q "\$HOME/bin/lab-cli" ~/.bash_profile; then
  echo "Adding $HOME/bin/lab-cli to PATH in .bash_profile"
  echo "export PATH=\"\$PATH:\$HOME/bin/lab-cli\"" >> ~/.bash_profile
else
  echo "$HOME/bin/lab-cli is already in PATH"
fi
