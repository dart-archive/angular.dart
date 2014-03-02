#!/bin/bash
. $(dirname $0)/env.sh

# Use the -d flag to set the directory for the dartdoc viewer build files
while getopts ":d:" opt ; do

 case $opt in
    d)
      DOCVIEWER_DIR=$OPTARG
      DOCDIR_OPTION="--out "$DOCVIEWER_DIR"/web/docs"
      echo "Generated docs will be output to: $DOCVIEWER_DIR/web/docs" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Use -d to specify the directory where the dartdoc viewer pubspec.yaml is located." >&2
      exit 1
      ;;
  esac
done

# Temporary during transition period from use of dartdoc to docgen.
if [ -x "$DART_DOCGEN" ]; then
    DOC_CMD="$DART_DOCGEN"
    MODE_OPTION="--start-page=angular \
                     --exclude-lib=js,metadata,meta,mirrors,intl,number_symbols,number_symbol_data,intl_helpers,date_format_internal,date_symbols,angular.util \
                     --no-include-sdk"

elif [ -x "$DARTDOC" ]; then
    DOC_CMD="$DARTDOC"
    MODE_OPTION="--mode=static"
fi

echo "Generating documentation using $DOC_CMD $MODE_OPTION $DOCDIR_OPTION"
"$DOC_CMD" $MODE_OPTION $DOCDIR_OPTION \
    --package-root=packages/ \
    lib/angular.dart lib/utils.dart lib/change_detection/watch_group.dart lib/core/module.dart lib/core_dom/module.dart lib/filter/module.dart lib/directive/module.dart lib/mock/module.dart lib/perf/module.dart lib/playback/playback_data.dart lib/playback/playback_http.dart lib/routing/module.dart lib/tools/common.dart lib/tools/expression_extractor.dart lib/tools/io.dart lib/tools/io_impl.dart lib/tools/source_crawler_impl.dart lib/tools/source_metadata_extractor.dart lib/tools/template_cache_annotation.dart lib/tools/template_cache_generator.dart

if [ -x "$DART_DOCGEN" ]; then
# Set the Version for dartdoc-viewer
    head CHANGELOG.md | awk 'NR==2' | sed 's/^# //' > VERSION
    mv VERSION $DOCVIEWER_DIR/web/docs
    (cd $DOCVIEWER_DIR; pub build)

fi
