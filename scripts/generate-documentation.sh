#!/bin/bash
. $(dirname $0)/env.sh

# Temporary during transition period from use of dartdoc to docgen.
if [ -x "$DART_DOCGEN" ]; then
    DOC_CMD="$DART_DOCGEN"
    MODE_OPTION=
else
    DOC_CMD="$DARTDOC"
    MODE_OPTION="--mode=static"
fi

echo Generating documentation using $DOC_CMD
$DOC_CMD \
    --package-root=packages/ \
    --out doc \
    $MODE_OPTION \ 
    --exclude-lib=js,metadata,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers,date_format_internal,date_symbols,angular.util \
    packages/angular/angular.dart lib/mock/module.dart

