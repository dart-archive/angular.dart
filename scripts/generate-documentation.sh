#!/bin/bash
. $(dirname $0)/env.sh

# Temporary change to delete the Build Status image markdown from the README (image md not supported by dartdoc-viewer)
echo '******************************'
echo '** GENERATING DOCUMENTATION **'
echo '******************************'
cp README.md README-orig.md
cat README-orig.md | sed "1s/^AngularDart.*/AngularDart/" > README.md

# Dart doc can not be run from the same directory as dartdoc-viewer
# see: https://code.google.com/p/dart/issues/detail?id=17231

( echo "Generating documentation"
  "$DART_DOCGEN" $DOC_OPTION $DOCDIR_OPTION \
    --out docs \
    --start-page=angular \
    --exclude-lib=js,metadata,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers,date_format_internal,date_symbols,angular.util \
    --no-include-sdk \
    --package-root=packages \
    lib/angular.dart \
    lib/application_factory.dart \
    lib/application_factory_static.dart \
    lib/application.dart lib/introspection.dart \
    lib/animate/module.dart \
    lib/core/annotation.dart \
    lib/core/module.dart \
    lib/directive/module.dart \
    lib/formatter/module.dart \
    lib/routing/module.dart \
    lib/mock/module.dart \
    lib/perf/module.dart \
)

# Revert the temp copy of the README.md file
rm README.md
mv README-orig.md README.md

DOCVIEWER_DIR="dartdoc-viewer";
if [[ $1 == update ]]; then
  rm -rf $DOCVIEWER_DIR/client/build/web/docs/
  mv docs $DOCVIEWER_DIR/client/build/web/docs
  exit;
fi

echo '--------------------------'
echo '-- DOCS: dartdoc-viewer --'
echo '--------------------------'
if [ ! -d "$DOCVIEWER_DIR" ]; then
   git clone https://github.com/angular/dartdoc-viewer.git -b angular-skin $DOCVIEWER_DIR
else
   (cd $DOCVIEWER_DIR; git pull origin angular-skin)
fi;

# Create a version file from the current build version
doc_version=`head CHANGELOG.md | awk 'NR==2' | sed 's/^# //'`
dartsdk_version=`cat $DARTSDK/version`
head_sha=`git rev-parse --short HEAD`

echo $doc_version at $head_sha \(with Dart SDK $dartsdk_version\) > docs/VERSION

rm -rf $DOCVIEWER_DIR/client/web/docs/
mv docs/ $DOCVIEWER_DIR/client/web/docs/
echo '---------------------'
echo '-- DOCS: pub build --'
echo '---------------------'
(cd $DOCVIEWER_DIR/client; pub build)


