import 'dart:io';
import 'dart:typed_data';

import 'package:raw_api_server/model/api_request.dart';

class RawApiClient {
  final int port;
  final String host;
  final void Function(Socket)? onConnect;
  final void Function(Socket, Uint8List)? onReceive;
  final void Function(Socket, dynamic)? onError;
  final void Function(Socket)? onDone;

  late final Socket _socket;

  RawApiClient({
    required this.port,
    required this.host,
    this.onConnect,
    this.onReceive,
    this.onError,
    this.onDone,
  });

  Future<void> connect({
    Duration? timeout
  }) async {
    _socket = await Socket.connect(
      host,
      port,
      timeout: timeout,
    );

    onConnect?.call(_socket);

    _socket.listen(
      (data) => onReceive == null ? null : onReceive!(_socket, data),
      onError: onError == null ? null : (error) => onError!(_socket, error),
      onDone: onDone == null ? null : () => onDone!(_socket),
    );
  }

  void sendRequest(ApiRequest request) {
    _socket.add(request.toIntList());
  }

  void disconnect() {
    _socket.destroy();
  }
}