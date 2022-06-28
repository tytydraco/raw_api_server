import 'dart:io';
import 'dart:typed_data';

import 'package:raw_api_server/model/api_request.dart';

class RawApiClient {
  final int port;
  final String host;
  final Duration? timeout;
  final void Function(Socket)? onConnect;
  final void Function(Socket, Uint8List)? onReceive;
  final void Function(Socket, dynamic)? onError;
  final void Function(Socket)? onDone;

  late final Socket socket;

  RawApiClient({
    required this.port,
    required this.host,
    this.timeout,
    this.onConnect,
    this.onReceive,
    this.onError,
    this.onDone,
  });

  Future<void> connect() async {
    socket = await Socket.connect(
      host,
      port,
      timeout: timeout,
    );

    onConnect?.call(socket);

    socket.listen(
      (data) => onReceive == null ? null : onReceive!(socket, data),
      onError: onError == null ? null : (error) => onError!(socket, error),
      onDone: onDone == null ? null : () => onDone!(socket),
    );
  }

  void sendRequest(ApiRequest request) {
    socket.add(request.toIntList());
  }

  void disconnect() {
    socket.destroy();
  }
}