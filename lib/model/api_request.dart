import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

/// A request given an [id] and some [data].
class ApiRequest {
  /// A unique identifier represented as a [Uint8].
  ///
  /// Must be in range from 0 to 255 inclusive.
  final int id;

  /// A list of of integers that must comply to the type [Uint8].
  final Uint8List? data;

  ApiRequest({
    required this.id,
    this.data,
  }) {
    if (id < 0 || id > 255) {
      throw ArgumentError('Must be in range [0, 255]', 'id');
    }
  }

  /// Create a request using an encoded UTF-8 string as the [data].
  factory ApiRequest.fromUtf8({
    required int id,
    required String data,
  }) {
    return ApiRequest(id: id, data: Uint8List.fromList(utf8.encode(data)));
  }

  /// Convert the request into a socket-compatible [Uint8List].
  Uint8List toIntList() {
    final request = [id];
    if (data != null) {
      request.addAll(data!);
    }
    return Uint8List.fromList(request);
  }
}
