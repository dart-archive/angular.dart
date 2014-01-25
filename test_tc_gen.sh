#!/bin/sh
# Runs template cache generator for test files.

if [ -z "$DART_SDK" ]; then
    echo "ERROR: You need to set the DART_SDK environment variable to your dart sdk location"
    exit 1
fi

set -v

dart bin/template_cache_generator.dart test/tools/test_files/templates/main.dart $DART_SDK test/tools/generated.dart generated test/tools/test_files/templates/ '/test/tools/test_files,rewritten;package:,package/' MyComponent3
