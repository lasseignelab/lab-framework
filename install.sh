#!/bin/bash

# Check if $HOME/bin is already in PATH
if ! grep -q "\$HOME/bin/lab-framework" ~/.bash_profile; then
  echo "Adding $HOME/bin/lab-framework to PATH in .bash_profile"
  echo "export PATH=\"\$PATH:\$HOME/bin/lab-framework\"" >> ~/.bash_profile
else
  echo "$HOME/bin/lab-framework is already in PATH"
fi
