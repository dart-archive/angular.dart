part of angular.mock;

@proxy
class MockWindow extends Mock implements Window {
  MockHistory history = new MockHistory();
  MockLocation location = new MockLocation();
  MockDocument document = new MockDocument();

  dart_async.StreamController<PopStateEvent> onPopStateController =
      new dart_async.StreamController<PopStateEvent>();
  dart_async.StreamController<Event> onHashChangeController =
      new dart_async.StreamController<Event>();
  dart_async.StreamController<MouseEvent> onClickController =
      new dart_async.StreamController<MouseEvent>();


  dart_async.Stream<PopStateEvent> get onPopState => onPopStateController.stream;
  dart_async.Stream<Event> get onHashChange => onHashChangeController.stream;
  dart_async.Stream<Event> get onClick => onClickController.stream;

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockHistory extends Mock implements History {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockLocation extends Mock implements Location {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockDocument extends Mock implements HtmlDocument {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
