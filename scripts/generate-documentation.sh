#!/bin/bash
. $(dirname $0)/env.sh


# Dart doc can not be run from the same directory as dartdoc-viewer
# see: https://code.google.com/p/dart/issues/detail?id=17231
cd lib

echo "Generating documentation"
"$DART_DOCGEN" $DOC_OPTION $DOCDIR_OPTION \
    --out ../docs \
    --start-page=angular \
    --exclude-lib=js,metadata,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers,date_format_internal,date_symbols,angular.util \
    --no-include-sdk \
    --package-root=../packages/ \
    ../lib/angular.dart \
    ../lib/utils.dart \
    ../lib/change_detection/watch_group.dart \
    ../lib/core/module.dart \
    ../lib/core_dom/module.dart \
    ../lib/filter/module.dart \
    ../lib/directive/module.dart \
    ../lib/mock/module.dart \
    ../lib/perf/module.dart \
    ../lib/playback/playback_data.dart \
    ../lib/playback/playback_http.dart \
    ../lib/routing/module.dart \
    ../lib/tools/common.dart \
    ../lib/tools/expression_extractor.dart \
    ../lib/tools/io.dart \
    ../lib/tools/io_impl.dart \
    ../lib/tools/source_crawler_impl.dart \
    ../lib/tools/source_metadata_extractor.dart \
    ../lib/tools/template_cache_annotation.dart \
    ../lib/tools/template_cache_generator.dart

cd ..

DOCVIEWER_DIR="dartdoc-viewer";
if [ ! -d "$DOCVIEWER_DIR" ]; then
  git clone https://github.com/angular/dartdoc-viewer.git -b angular-skin $DOCVIEWER_DIR
fi;

head CHANGELOG.md | awk 'NR==2' | sed 's/^# //' > docs/VERSION
rm -rf $DOCVIEWER_DIR/client/web/docs/
mv docs/ $DOCVIEWER_DIR/client/web/docs/
(cd $DOCVIEWER_DIR/client; pub build)
