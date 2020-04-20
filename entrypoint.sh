#!/bin/bash

# Exit on any error and show execution of all commands for debugging if something goes wrong
set -ex

cd "$GITHUB_WORKSPACE"
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

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

EXIT_VAL=0

while read -r FILENAME; do
    FAILED="false"
    # Failure is passed to stderr so we need to redirect that to grep so we can pretty print some useful output instead of the deafult
    # Success is passed to stdout, so we need to redirect that separately so we can capture either case.

    # Allow failures here so we can capture exit status
    set +e
    OUT=$(uncrustify --check${CONFIG} -f ${FILENAME} -l CPP 2>&1 | grep -e ^FAIL -e ^PASS | awk '{ print $2 }'; exit ${PIPESTATUS[0]})
    
    # Stop allowing failures again
    set -e 
    
    RETURN_VAL=$?
    if [[ $RETURN_VAL -gt 0 ]]; then
        echo "$OUT failed style checks."
        FAILED="true"
        EXIT_VAL=$RETURN_VAL
    else
        echo "$OUT passed style checks."
    fi

    if [[ -n "$INPUT_CHECKSTD" ]] && [[ "$INPUT_CHECKSTD" == "true" ]]; then
        # Counts occurrences of std:: that aren't in comments and have a leading space (except if it's inside pointer brackets, eg: <std::thing>)
        RETURN_VAL=$(sed -n '/^.*\/\/.*/!s/ std:://p; /^.* std::.*\/\//s/ std:://p; /^.*\<.*std::.*\>/s/std:://p;' "${FILENAME}" | wc -l)
        if [[ $RETURN_VAL -gt $EXIT_VAL ]]; then
            if [[ "$FAILED" != "true" ]]; then
                echo "${FILENAME} failed style checks."
            fi
            EXIT_VAL=$RETURN_VAL
        fi
    fi
done < <(git diff --name-status --diff-filter=AM origin/master...${BRANCH_NAME} -- '*.cpp' '*.h' '*.hpp' '*.cxx' | awk '{ print $2 }' )

exit $EXIT_VAL
