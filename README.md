# lab-cli
A command line interface for computational lab work.

# Installation
```
cd $USER_HOME
mkdir bin
cd bin
git clone https://github.com/lasseignelab/lab-cli.git
. lab-cli/install.sh
source ~/.bash_profile
```
# Update
```
cd $USER_HOME/bin/lab-cli
git pull origin main
```
# Usage
The `lab` CLI provides commands to help with reproducible research.
```
lab <command> params...
```

## md5dir
The `lab md5dir` command will produce an md5sum for all the contents of a directory.  This makes it easy to determine whether the contents of one directory are identical to another.

Definition:
```
lab md5dir <directory>
```
Example:
```
lab md5dir ./
e0313390b2418cb38cb5a4a03d993e0b
```
