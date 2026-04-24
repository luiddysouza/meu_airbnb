import 'package:flutter_test/flutter_test.dart';

import 'package:meu_airbnb/core/services/base64_isolate_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Base64IsolateService', () {
    test('deve ter method encodarImagemBase64', () {
      expect(Base64IsolateService.encodarImagemBase64, isNotNull);
    });

    test('encodarImagemBase64 deve ser uma Function', () {
      expect(Base64IsolateService.encodarImagemBase64, isA<Function>());
    });

    test('classe deve existir e ter método static', () {
      expect(Base64IsolateService, isNotNull);
      expect(Base64IsolateService.encodarImagemBase64, isNotNull);
    });

    test('Base64IsolateService deve ter encoder method', () {
      expect([
        Base64IsolateService.encodarImagemBase64,
      ], everyElement(isA<Function>()));
    });
  });
}
