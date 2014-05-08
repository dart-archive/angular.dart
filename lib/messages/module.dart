library angular.messages;

import 'package:di/di.dart';
import 'package:angular/application.dart';
import 'package:angular/core/annotation_src.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core_dom/module_internal.dart';

part 'ng_messages.dart';

class MessagesModule extends Module {
  MessagesModule() {
    bind(NgMessages, toValue: null);
    bind(NgMessage, toValue: null);
  }
}
