final List<Function> integrationTests = [];

void addIntegrationTest(Function fn) {
  integrationTests.add(fn);
}

Future<void> callIntegrationTests() async {
  for (final fn in integrationTests) {
    if (fn is Future<void> Function()) {
      await fn();
    } else {
      fn();
    }
  }
}
