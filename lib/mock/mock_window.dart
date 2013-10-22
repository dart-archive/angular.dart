part of angular.mock;

@proxy
class MockWindow extends Mock implements Window {
  MockHistory history = new MockHistory();
  MockLocation location = new MockLocation();
  MockDocument document = new MockDocument();

  StreamController<PopStateEvent> onPopStateController =
      new StreamController<PopStateEvent>();
  StreamController<Event> onHashChangeController =
      new StreamController<Event>();
  StreamController<MouseEvent> onClickController =
      new StreamController<MouseEvent>();


  Stream<PopStateEvent> get onPopState => onPopStateController.stream;
  Stream<Event> get onHashChange => onHashChangeController.stream;
  Stream<Event> get onClick => onClickController.stream;

}

@proxy
class MockHistory extends Mock implements History {}

@proxy
class MockLocation extends Mock implements Location {}

@proxy
class MockDocument extends Mock implements HtmlDocument {}
