import 'dart:convert';

/// A request given an [id] and some [data].
class ApiRequest {
  final int id;
  final List<int>? data;

  ApiRequest({
    required this.id,
    this.data,
  });

  /// Create a request using an encoded UTF-8 string as the [data].
  factory ApiRequest.fromUtf8({
    required int id,
    required String data,
  }) {
    return ApiRequest(id: id, data: utf8.encode(data));
  }

  /// Convert the request into a socket-compatible [Uint8List].
  List<int> toIntList() {
    final request = [id];
    if (data != null) {
      request.addAll(data!);
    }
    return request;
  }
}