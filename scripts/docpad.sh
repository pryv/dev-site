#!/bin/sh

# Run the DocPad command passed in argument

command=$1

if [ -z "$command" ]
then
  echo "
Expected a DocPad command argument. Examples:
  'run' runs a small server serving the generated website, keeping track of source changes
  'generate' generates the website from the source into the 'out' folder
  'clean' cleans up the 'out' folder
"
  exit 1
fi

# working dir fix
scriptsFolder=$(cd $(dirname "$0"); pwd)
cd $scriptsFolder/..

./node_modules/docpad/bin/docpad $command
