#!/bin/sh

# This script sets up the Pryv API documentation build environment

# working dir fix
scriptsFolder=$(cd $(dirname "$0"); pwd)
cd $scriptsFolder/..

# check for well known prereqs that might be missing
hash git 2>&- || { echo >&2 "I require git."; exit 1; }
hash yarn 2>&- || { echo >&2 "I require node and yarn."; exit 1; }


# resolve test-results dependency
if [ ! -d dependencies/test-results ]
then
  echo "Setting up 'source/test-results/_source' folder for test-results dependency."
  git clone git@github.com:pryv/test-results-pryv.io.git dependencies/test-results
fi

# ensure service-core dependency is up-to-date
cd dependencies/test-results
git checkout master
git pull
yarn install
cd $scriptsFolder/..

if [ -z "$1" ]
then
  # default branch used for service-core dependency
  coreBranch="release-1.2"
else
  coreBranch=$1
fi

# resolve service-core dependency
if [ ! -d dependencies/core ]
then
  echo "Setting up 'source/event-types/_source' folder for service-core dependency."
  git clone git@github.com:pryv/service-core.git dependencies/core
fi

if [ -z "$1" ]
then
  # default branch used for service-core dependency
  coreBranch="release-1.2"
else
  coreBranch=$1
fi

echo "Service-core dependency is targeting the following branch: $coreBranch"

# ensure service-core dependency is up-to-date
cd dependencies/core
git checkout $coreBranch
git pull
cd $scriptsFolder/..

# install node modules
echo "Installing Node modules from 'package.json' if necessary."
yarn install

# setup build folder
if [ ! -d build ]
then
  echo "Setting up 'build' folder for publishing to GitHub pages."
  git clone git@github.com:pryv/pryv.github.io.git build
fi

echo "


If no errors were listed above, the setup is complete.
See the README for more info on writing and publishing.
"
