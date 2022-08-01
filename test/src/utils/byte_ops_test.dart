import 'dart:typed_data';

import 'package:raw_api_server/src/utils/byte_ops.dart';
import 'package:test/test.dart';

void main() {
  group('Int to Uint8List', () {
    test('Too long', () {
      expect(() => intToUint8List(256, 8), throwsArgumentError);
    });

    test('Int to Uint8List', () {
      expect(intToUint8List(256, 2), [1, 0]);
    });
  });

  group('Uint8List to int', () {
    test('Too long', () {
      expect(uint8ListToInt(Uint8List.fromList([1, 0])), 256);
    });
  });
}