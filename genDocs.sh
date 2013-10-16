#!/bin/bash

dartdoc \
    --package-root=packages/ \
    --mode=static \
    --exclude-lib=js,metadata,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers \
    lib/angular.dart lib/mock/mock.dart \
