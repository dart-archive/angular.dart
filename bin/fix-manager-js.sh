#!/bin/bash
#
# Utility script to address issue reported [here](https://groups.google.com/forum/#!topic/angular-dart/hYY8WN_5OQc):
# `ERROR [karma]: [Error: error:24064064:random number generator:SSLEAY_RAND_BYTES:PRNG not seeded]`
# 
# Assumption: sed is in your path.

FILE="$(dirname $0)/../node_modules/karma/node_modules/socket.io/lib/manager.js"

if [ ! -e "$FILE" ]; then
    echo "Error: file does not exist '$FILE'"
    echo "Did you previously run 'npm install'?"
    exit 1;
fi

if [ ! -w "$FILE" ]; then
    echo "Sorry, but you don't have permission to modify '$FILE'"
    exit 1;
fi

sed -i -e 's/crypto.randomBytes/crypto.pseudoRandomBytes/g' "$FILE" \
 && echo "Successfully patched $FILE"

# End of script
