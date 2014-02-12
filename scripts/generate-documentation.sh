#!/bin/bash
. $(dirname $0)/env.sh

# Temporary during transition period from use of dartdoc to docgen.
if [ -x "$DART_DOCGEN" ]; then
    # docgen seems to freeze when it processes the angular.dart files
    # https://code.google.com/p/dart/issues/detail?id=16752
    # so disable it for now
    # DOC_CMD="$DART_DOCGEN"
    # MODE_OPTION=
    echo "DISABLING DOCUMENT GENERATION due to isses with docgen."
    echo "https://code.google.com/p/dart/issues/detail?id=16752"
    echo "----"
    echo "Reporting success none-the-less during this docgen beta period."
    exit 0;
elif [ -x "$DARTDOC" ]; then
    DOC_CMD="$DARTDOC"
    MODE_OPTION="--mode=static"
fi

echo "Generating documentation using $DOC_CMD"
"$DOC_CMD" $MODE_OPTION \
    --package-root=packages/ \
    --out doc \
    --exclude-lib=js,metadata,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers,date_format_internal,date_symbols,angular.util \
    packages/angular/angular.dart lib/mock/module.dart


