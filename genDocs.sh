#!/bin/bash

dartdoc \
    --package-root=packages/ \
    --out doc \
    --mode=static \
    --exclude-lib=js,metadata,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers,date_format_internal,date_symbols,angular.util \
    lib/angular.dart lib/mock/module.dart \
