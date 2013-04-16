#!/bin/sh

DART_FLAGS='--enable-type-checks --enable-asserts' \
   open -a Dartium $@
