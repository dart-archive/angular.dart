#!/bin/bash

dartdoc lib/angular.dart lib/mock/mock.dart \
    --package-root=packages/ \
    --mode=static \
    --exclude-lib=js,metadata
