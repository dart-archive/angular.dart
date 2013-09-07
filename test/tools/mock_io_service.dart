library angular.mock_io;

import 'package:angular/tools/io.dart';

class MockIoService implements IoService {

  Map<String, String> mockData;

  MockIoService(this.mockData);

  String readAsStringSync(String filePath) {
    if (!mockData.containsKey(filePath)) {
      throw 'file not found';
    }
    return mockData[filePath];
  }

  void visitFs(String rootDir, visitor(String file)) {
    mockData.keys.forEach((file) => visitor(file));
  }
}
