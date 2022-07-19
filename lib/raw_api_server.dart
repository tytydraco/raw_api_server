import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:raw_api_server/model/api_endpoint.dart';

/// A simple socket-based API server hosting on a given [port].
class RawApiServer {
  /// Port to connect to.
  final int port;

  /// A list of [ApiEndpoint]s that the server will scan client data for.
  final Iterable<ApiEndpoint>? endpoints;

  /// A callback passing the client [socket] when a connection is first
  /// established.
  final void Function(Socket socket)? onConnect;

  /// A callback passing the client [socket] when a client disconnects
  /// from the server.
  final void Function(Socket socket)? onDisconnect;

  bool _hasStarted = false;

  /// True if the server has been started.
  bool get hasStarted => _hasStarted;

  late final ServerSocket _serverSocket;

  RawApiServer({
    required this.port,
    this.endpoints,
    this.onConnect,
    this.onDisconnect,
  }) {
    _checkUniqueEndpointIds();
  }

  /// Assert that every endpoint has a unique id.
  ///
  /// Throws an [ArgumentError] if there are any duplicate ids.
  void _checkUniqueEndpointIds() {
    if (endpoints == null) {
      return;
    }

    final ids = endpoints!.map((e) => e.id).toList();
    final idsSet = ids.toSet().toList();

    final unique = (ids.length == idsSet.length);
    if (!unique) {
      throw ArgumentError(
          'Provided endpoints do not have unique id values', 'endpoints');
    }
  }

  /// Handle and listen to a newly-connected client [socket].
  void _handleConnection(Socket socket) {
    onConnect?.call(socket);
    socket.listen(
      (data) {
        if (data.isEmpty) {
          return;
        }

        final id = data[0];
        final realData = data.sublist(1);

        // Call the matching endpoint handler if one exists
        endpoints
            ?.firstWhereOrNull((endpoint) => endpoint.id == id)
            ?.handler
            ?.call(socket, realData);
      },
      onDone: onDisconnect == null ? null : () => onDisconnect!(socket),
    );
  }

  /// Start the server and begin listening for clients.
  ///
  /// Throws a [StateError] if the server has already been started.
  Future<void> start() async {
    if (_hasStarted) {
      throw StateError('Server is already started');
    }
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket.listen((socket) => _handleConnection(socket));
    _hasStarted = true;
  }

  /// Stop the server from accepting any new clients.
  ///
  /// Throws a [StateError] if the server is stopped already.
  Future<void> stop() async {
    if (!_hasStarted) {
      throw StateError('Server is not started');
    }
    await _serverSocket.close();
    _hasStarted = false;
  }
}
