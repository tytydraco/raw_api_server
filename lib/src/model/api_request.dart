import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:raw_api_server/src/utils/byte_ops.dart';

/// A request given an [id] and some [data].
class ApiRequest {
  /// Creates a new [ApiRequest] given an [id] and some optional [data].
  ApiRequest({
    required this.id,
    this.idWidth = 4,
    this.data,
  }) {
    if (id < 0) {
      throw ArgumentError('Must not be negative', 'id');
    }
  }

  /// Create a request using an encoded UTF-8 string as the [data].
  factory ApiRequest.fromUtf8({
    required int id,
    required String data,
  }) {
    return ApiRequest(id: id, data: Uint8List.fromList(utf8.encode(data)));
  }

  /// A unique identifier represented.
  final int id;

  /// The number of bytes to reserve for the endpoint id.
  final int idWidth;

  /// A list of of integers that must comply to the type [Uint8].
  final Uint8List? data;

  /// Convert the request into a socket-compatible [Uint8List].
  Uint8List toIntList() {
    final request = [...intToUint8List(id, idWidth)];
    if (data != null) request.addAll(data!);
    return Uint8List.fromList(request);
  }
}
