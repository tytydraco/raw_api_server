import 'dart:io';
import 'dart:typed_data';

/// An endpoint to relate an [id] to a function [handler].
class ApiEndpoint {
  /// Create a new [ApiEndpoint] given an [id] and an optional [handler].
  ApiEndpoint({
    required this.id,
    this.handler,
  }) {
    if (id < 0) {
      throw ArgumentError('Must not be negative', 'id');
    }
  }

  /// A unique identifier.
  final int id;

  /// A function handler given a client [Socket] and data as a [Uint8List].
  final void Function(Socket socket, Uint8List data)? handler;
}
