import 'dart:io';
import 'dart:typed_data';

class ApiEndpoint {
  final int id;
  final void Function(Socket, Uint8List)? onCall;

  ApiEndpoint({
    required this.id,
    this.onCall,
  });
}