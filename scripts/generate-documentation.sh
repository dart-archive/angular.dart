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
    angular.dart \
    animate/module.dart \
    utils.dart \
    change_detection/watch_group.dart \
    core/module.dart \
    core_dom/module.dart \
    filter/module.dart \
    directive/module.dart \
    mock/module.dart \
    perf/module.dart \
    playback/playback_data.dart \
    playback/playback_http.dart \
    routing/module.dart \
    tools/common.dart \
    tools/expression_extractor.dart \
    tools/io.dart \
    tools/io_impl.dart \
    tools/source_crawler_impl.dart \
    tools/source_metadata_extractor.dart \
    tools/template_cache_annotation.dart \
    tools/template_cache_generator.dart

cd ..

DOCVIEWER_DIR="dartdoc-viewer";
if [ ! -d "$DOCVIEWER_DIR" ]; then
  git clone https://github.com/angular/dartdoc-viewer.git -b angular-skin $DOCVIEWER_DIR
fi;

head CHANGELOG.md | awk 'NR==2' | sed 's/^# //' > docs/VERSION
rm -rf $DOCVIEWER_DIR/client/web/docs/
mv docs/ $DOCVIEWER_DIR/client/web/docs/
(cd $DOCVIEWER_DIR/client; pub build)
