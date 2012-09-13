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

echo "


If no errors were listed above, the app setup is complete.

To start the app (example - check the code for the list of config options):
    node source/app.js --database.name <name> --http.httpPort <port>
"
