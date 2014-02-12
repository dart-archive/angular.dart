#!/bin/bash
. $(dirname $0)/env.sh

# Temporary during transition period from dartdoc to docgen.

if [ ! -x "$DART_DOCGEN" ]; then
    # Fall back on old dartdoc
    DART_DOCGEN=$DARTDOC
fi

$DART_DOCGEN \
    --package-root=packages/ \
    --out doc \
    --mode=static \
    --exclude-lib=js,metadata,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers,date_format_internal,date_symbols,angular.util \
    packages/angular/angular.dart lib/mock/module.dart \
