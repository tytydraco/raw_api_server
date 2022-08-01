import 'dart:typed_data';

/// Convert a [Uint8List] into an [int]. The maximum length of [Uint8List] is 7
/// as to fit in a standard [int].
///
/// Throws an [ArgumentError] if the length of the [list] is greater than 7.
int uint8ListToInt(Uint8List list) {
  if (list.length > 7) {
    throw ArgumentError('List length is out of range [0, 8)', 'list');
  }

  var value = 0;
  for (var i = 0; i < list.length; i++) {
    value <<= 8;
    value |= list[i];
  }

  return value;
}

/// Convert an [int] into a [Uint8List]. The maximum length of [Uint8List] is 7
/// as to fit in a standard [int].
///
/// Throws an [ArgumentError] if the [length] of the list is greater than 7.
Uint8List intToUint8List(int value, [int length = 7]) {
  if (length > 7) {
    throw ArgumentError('List length is out of range [0, 8)', 'length');
  }

  final list = Uint8List(length);

  var working = value;
  for (var i = length - 1; i >= 0; i--) {
    final nextInt = working % 256;
    list[i] = nextInt;
    working >>= 8;
  }

  return list;
}
