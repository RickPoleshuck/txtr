import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:txtr_app/src/services/preference_service.dart';

void main() {
  group('Unit Tests', () {
    test('PreferenceService', () async {
      WidgetsFlutterBinding.ensureInitialized();
      await PreferenceService().put('abc', 'def');
      final result = await PreferenceService().get('abc');
      expect('def', result);
    });
  });
}
