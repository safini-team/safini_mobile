import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';

void main() {
  group('finiDemoEnabled', () {
    test('a release or profile build never serves fixtures', () {
      expect(finiDemoEnabled(debugBuild: false, define: true), isFalse);
      expect(finiDemoEnabled(debugBuild: false, define: false), isFalse);
    });

    test('a debug build needs the define', () {
      expect(finiDemoEnabled(debugBuild: true, define: false), isFalse);
      expect(finiDemoEnabled(debugBuild: true, define: true), isTrue);
    });
  });

  test('the test run itself has no FINI_DEMO define', () {
    expect(isFiniDemo, isFalse);
    expect(finiDemoState, isNull);
  });

  group('finiDemoStateFrom', () {
    test('matches a state by name', () {
      for (final state in FiniDemoState.values) {
        expect(finiDemoStateFrom(state.name), state);
      }
    });

    test('unknown or empty falls back to the first state', () {
      expect(finiDemoStateFrom(''), FiniDemoState.androidChildWithUsage);
      expect(finiDemoStateFrom('nope'), FiniDemoState.androidChildWithUsage);
    });
  });
}
