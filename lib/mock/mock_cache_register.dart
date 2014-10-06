part of angular.mock;

/**
 * This is a null implementation of CacheRegister used in tests.
 */
@Injectable()
class MockCacheRegister implements CacheRegister {
  void registerCache(String name, cache) {}
  List<CacheRegisterStats> get stats {}
  void clear([String name]) {}
}