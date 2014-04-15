#!/bin/bash

rm -rf ../karma-snapshot
mkdir ../karma-snapshot
cd ../karma-snapshot

URL=http://localhost:9876
FILES=$(curl $URL/debug.html --silent | grep \'/base | cut -f2 -d \')

for FILE in $FILES
do
  echo $FILE
  curl $URL$FILE --output .$FILE --create-dirs --silent
done

echo ================


curl $URL/debug.html --silent | sed -e 's/\/base/\.\/base/' > debug.html
curl $URL/__adapter_dart_unittest.dart --silent | sed -e 's/\/base/\./' > __adapter_dart_unittest.dart
curl $URL/__adapter_dart_unittest.dart.js --silent | sed -e 's/\/base/\./' > __adapter_dart_unittest.dart.js
