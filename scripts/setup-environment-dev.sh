#!/bin/sh

# This script sets up the Pryv API documentation development environment

# working dir fix
scriptsFolder=$(cd $(dirname "$0"); pwd)
cd $scriptsFolder/..

# check for well known prereqs that might be missing
hash git 2>&- || { echo >&2 "I require 'git'."; exit 1; }

echo "
Checking for NVM..."
if [ ! -d ~/.nvm ]
then
  echo "Not found, installing...
"
  git clone git://github.com/creationix/nvm.git ~/.nvm
else
  echo "OK"
fi

echo "
Syncing NVM...
"
. ~/.nvm/nvm.sh # this line should be added to your .bash_profile as well
nvm sync

nodeVersion=v0.8.2
echo "
Installing Node $nodeVersion if necessary...
"
nvm install $nodeVersion
nvm use $nodeVersion # the equivalent line should be added to your .bash_profile as well

echo "
Installing Node modules from 'package.json' if necessary...
"
npm install

if [ ! -d out ]
then
  echo "
Setting up 'out' folder for publishing to pryv.github.io...
"
  git clone git@github.com:pryv/pryv.github.io.git out
fi

echo "


If no errors were listed above, the setup is complete.
See the README for more info on writing and publishing the doc.
"
