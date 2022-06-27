import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:raw_api_server/model/api_endpoint.dart';

class RawApiServer {
  final int port;
  final List<ApiEndpoint>? endpoints;
  final void Function(Socket)? onConnect;
  final void Function(Socket, dynamic)? onError;
  final void Function(Socket)? onDone;

  late final ServerSocket serverSocket;

  RawApiServer({
    required this.port,
    this.endpoints,
    this.onConnect,
    this.onError,
    this.onDone,
  });
  
  void _handleConnection(Socket socket) {
    onConnect?.call(socket);
    socket.listen(
      (data) {
        if (data.isEmpty) {
          return;
        }

        final id = data[0];
        final args = data.sublist(1);

        endpoints
          ?.firstWhereOrNull((element) => element.id == id)
          ?.onCall?.call(socket, args);
      },
      onError: onError == null ? null : (error) => onError!(socket, error),
      onDone: onDone == null ? null : () => onDone!(socket),
    );
  }

  Future<void> start() async {
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    serverSocket.listen((socket) => _handleConnection(socket));
  }

  Future<void> stop() async {
    await serverSocket.close();
  }
}