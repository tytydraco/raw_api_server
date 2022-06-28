import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:raw_api_server/model/api_endpoint.dart';

class RawApiServer {
  final int port;
  final Iterable<ApiEndpoint>? endpoints;
  final void Function(Socket)? onConnect;
  final void Function(Socket)? onDisconnect;

  bool _hasStarted = false;
  bool get hasStarted => _hasStarted;

  late final ServerSocket _serverSocket;

  RawApiServer({
    required this.port,
    this.endpoints,
    this.onConnect,
    this.onDisconnect,
  }) {
    _checkUniqueEndpointIds();
    _checkValidEndpointIds();
  }

  void _checkUniqueEndpointIds() {
    if (endpoints == null) {
      return;
    }

    final ids = endpoints!.map((e) => e.id).toList();
    final idsSet = ids.toSet().toList();

    final unique = (ids.length == idsSet.length);
    if (!unique) {
      throw AssertionError('Provided endpoints do not have unique id values');
    }
  }

  void _checkValidEndpointIds() {
    if (endpoints == null) {
      return;
    }

    final ids = endpoints!.map((e) => e.id).toList();
    for (int id in ids) {
      if (id < 0 || id > 255) {
        throw AssertionError('Id is not within range [0, 255]: $id');
      }
    }
  }
  
  void _handleConnection(Socket socket) {
    onConnect?.call(socket);
    socket.listen(
      (data) {
        if (data.isEmpty) {
          return;
        }

        final id = data[0];
        final realData = data.sublist(1);

        endpoints
          ?.firstWhereOrNull((element) => element.id == id)
          ?.handler?.call(socket, realData);
      },
      onDone: onDisconnect == null ? null : () => onDisconnect!(socket),
    );
  }

  Future<void> start() async {
    if (_hasStarted) {
      throw StateError('Server is already started');
    }
    _hasStarted = true;
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket.listen((socket) => _handleConnection(socket));
  }

  Future<void> stop() async {
    if (!_hasStarted) {
      throw StateError('Server is already stopped');
    }
    _hasStarted = false;
    await _serverSocket.close();
  }
}