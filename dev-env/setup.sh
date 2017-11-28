#!/bin/sh

# This script sets up the Pryv API documentation build environment

# working dir fix
scriptsFolder=$(cd $(dirname "$0"); pwd)
cd $scriptsFolder/..

# check for well known prereqs that might be missing
hash git 2>&- || { echo >&2 "I require git."; exit 1; }
hash yarn 2>&- || { echo >&2 "I require node and yarn."; exit 1; }

echo "
Installing Node modules from 'package.json' if necessary...
"
yarn install

if [ ! -d build ]
then
  echo "
Setting up 'build' folder for publishing to GitHub pages...
"
  git clone git@github.com:pryv/pryv.github.io.git build
fi

echo "


If no errors were listed above, the setup is complete.
See the README for more info on writing and publishing.
"
