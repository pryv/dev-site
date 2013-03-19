#!/bin/bash

# Automatically updates the API version number in the documentation, assuming the API server code
# repository is located at `../api-server` from the present repo's root.

# working dir fix
scriptsFolder=$(cd $(dirname "$0"); pwd)
cd $scriptsFolder/..

SOURCE_PATH=../api-server/package.json
TARGET_PATH=src/documents/reference.html.jade

if [ ! -f $SOURCE_PATH ]
then
  echo >&2 "Expected $SOURCE_PATH to exist from repo root"
  exit 1
fi

# fetch version from api-server repo
VERSION=`sed -n 's/.*"version": "\(.*\)".*/\1/p' $SOURCE_PATH`
# replace in-file
sed -i .bak "/.*var apiVersion = .*/ s/'.*'/'$VERSION'/" $TARGET_PATH
# remove sed mandatory backup (haven't found a way to avoid the backup)
rm $TARGET_PATH.bak

echo "
Successfully set version to $VERSION in $TARGET_PATH (using $SOURCE_PATH as reference).
"
