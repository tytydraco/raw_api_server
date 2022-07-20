import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

/// An endpoint to relate an [id] to a function [handler].
class ApiEndpoint {
  /// Create a new [ApiEndpoint].
  ApiEndpoint({
    required this.id,
    this.handler,
  }) {
    if (id < 0 || id > 255) {
      throw ArgumentError('Must be in range [0, 255]', 'id');
    }
  }

  /// A unique identifier represented as a [Uint8].
  ///
  /// Must be in range from 0 to 255 inclusive.
  final int id;

  /// A function handler given a client [Socket] and data as a [Uint8List].
  final void Function(Socket socket, Uint8List data)? handler;
}
