#!/bin/bash
. $(dirname $0)/env.sh

# Temporary during transition period from use of dartdoc to docgen.
if [ -x "$DART_DOCGEN" ]; then
    DOC_CMD="$DART_DOCGEN"
    MODE_OPTION=
elif [ -x "$DARTDOC" ]; then
    DOC_CMD="$DARTDOC"
    MODE_OPTION="--mode=static"
fi

echo "Generating documentation using $DOC_CMD $MODE_OPTION"
"$DOC_CMD" $MODE_OPTION \
    --package-root=packages/ \
    --out docs \
    --start-page=angular \
    --exclude-lib=js,metadata,mdn,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers,date_format_internal,date_symbols,angular.util \
    --no-include-sdk \
    ./ lib/mock/module.dart


