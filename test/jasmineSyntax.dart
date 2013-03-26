import 'package:unittest/unittest.dart';

it(name, fn) => test(name, fn);
iit(name, fn) => solo_test(name, fn);
xit(name, fn) {}

describe(name, fn) => group(name, fn);

beforeEach(fn) => setUp(fn);
afterEach(fn) => tearDown(fn);
