import 'dart:io';
import 'dart:typed_data';

class ApiEndpoint {
  final int id;
  final void Function(Socket socket, Uint8List data)? handler;

  ApiEndpoint({
    required this.id,
    this.handler,
  });
}