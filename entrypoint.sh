#!/bin/bash

# Exit on any error and show execution of all commands for debugging if something goes wrong
set -e

cd "$GITHUB_WORKSPACE"
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Maintain support for uncrustify's ENV variable if it's passed in 
# from the actions file. Otherwise the actions file could have the
# configPath argument set
if [[ -z $UNCRUSTIFY_CONFIG ]] && [[ -z $INPUT_CONFIGPATH ]]; then
    CONFIG=" -c /default.cfg"
elif [[ -z $UNCRUSTIFY_CONFIG ]] && [[ -n $INPUT_CONFIGPATH ]]; then
    CONFIG=" -c $INPUT_CONFIGPATH"
# If both are set, use the command line flag.
elif [[ -n $UNCRUSTIFY_CONFIG ]] && [[ -n $INPUT_CONFIGPATH ]]; then
    CONFIG=" -c $INPUT_CONFIGPATH"
elif [[ -n $UNCRUSTIFY_CONFIG ]] && [[ -z $INPUT_CONFIGPATH ]]; then
    CONFIG=""
else
    CONFIG=" -c /default.cfg"
fi

while read -r FILENAME; do
    uncrustify ${CONFIG} -f ${FILENAME} -l CS -o ${FILENAME}
done < <(git diff --name-status --diff-filter=AM origin/${DEFAULT_BRANCH}...${BRANCH_NAME} -- '*.cs' | awk '{ print $2 }' )

echo "Config: ${CONFIG}"
echo "Changed files:"
git diff --name-status --diff-filter=AM origin/${DEFAULT_BRANCH}...${BRANCH_NAME} -- '*.cs' | awk '{ print $2 }'

exit 0
