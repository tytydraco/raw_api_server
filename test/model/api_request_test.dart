import 'dart:convert';
import 'dart:typed_data';

import 'package:raw_api_server/model/api_request.dart';
import 'package:test/test.dart';

void main() {
  group('Invalid request ID', () {
    test('Less than min', () {
      expect(() => ApiRequest(id: -1), throwsArgumentError);
    });

    test('Greater than max', () {
      expect(() => ApiRequest(id: 256), throwsArgumentError);
    });
  });

  group('Api request data', () {
    test('To int list without data', () {
      final request = ApiRequest(id: 0);
      expect(request.toIntList(), Uint8List.fromList([0]));
    });

    test('To int list with Uint8 data', () {
      final request = ApiRequest(id: 0, data: Uint8List.fromList([1, 2, 3, 4]));
      expect(request.toIntList(), Uint8List.fromList([0, 1, 2, 3, 4]));
    });

    test('To int list with UTF-8 data', () {
      final request = ApiRequest.fromUtf8(id: 0, data: 'hello');
      expect(
        request.toIntList(),
        [0, ...Uint8List.fromList(utf8.encode('hello'))],
      );
    });
  });
}
