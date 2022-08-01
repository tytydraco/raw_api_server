import 'dart:io';
import 'dart:typed_data';

import 'package:raw_api_server/api_request.dart';

/// A simple socket-based API client to connect to a [port] on a [host] server.
class RawApiClient {
  /// Create a new [RawApiClient] given a [port] and a [host]. Callbacks can be
  /// optionally provided.
  RawApiClient({
    required this.port,
    required this.host,
    this.idWidth = 4,
    this.onConnect,
    this.onReceive,
    this.onDisconnect,
  }) {
    _checkValidIdWidth();
  }

  /// Port to connect to.
  final int port;

  /// Host to connect to.
  final String host;

  /// The number of bytes to reserve for the endpoint id.
  final int idWidth;

  /// A callback passing the server [Socket] when a connection is first
  /// established.
  final void Function(Socket socket)? onConnect;

  /// A callback passing the server [Socket] and any sent data as a [Uint8List]
  /// coming from the server.
  final void Function(Socket socket, Uint8List data)? onReceive;

  /// A callback passing the server [Socket] when the client disconnects
  /// from the server.
  final void Function(Socket socket)? onDisconnect;

  bool _hasConnected = false;

  /// True if the client has established a connection with the server.
  bool get hasConnected => _hasConnected;

  late final Socket _socket;

  /// Assert that the [idWidth] value is within a valid range.
  ///
  /// Throws an [ArgumentError] if the value is less than or equal to zero.
  void _checkValidIdWidth() {
    if (idWidth <= 0) throw ArgumentError('Width must be > 0', 'idWidth');
  }

  /// Attempt to make a connection with the remote server.
  ///
  /// A maximum [timeout] can be optionally specified.
  /// Throws a [StateError] if the client is already connected.
  Future<void> connect({Duration? timeout}) async {
    if (_hasConnected) {
      throw StateError('Client is already connected');
    }

    _socket = await Socket.connect(
      host,
      port,
      timeout: timeout,
    );

    _hasConnected = true;

    onConnect?.call(_socket);

    _socket.listen(
      (data) => onReceive == null ? null : onReceive!(_socket, data),
      onDone: onDisconnect == null ? null : () => onDisconnect!(_socket),
    );
  }

  /// Send a [request] to the server in the form of an [ApiRequest].
  ///
  /// Throws a [StateError] if the client is disconnected.
  void sendRequest(ApiRequest request) {
    if (!_hasConnected) {
      throw StateError('Client is not connected');
    }

    _socket.add(request.toIntList());
  }

  /// Disconnect from the remote server.
  ///
  /// Throws a [StateError] if the client is disconnected.
  void disconnect() {
    if (!_hasConnected) {
      throw StateError('Client is not connected');
    }

    _socket.destroy();

    _hasConnected = false;
  }
}
