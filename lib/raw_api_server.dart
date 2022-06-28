import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:raw_api_server/exceptions/duplicate_id_exception.dart';
import 'package:raw_api_server/exceptions/invalid_id_exception.dart';
import 'package:raw_api_server/model/api_endpoint.dart';

class RawApiServer {
  final int port;
  final Iterable<ApiEndpoint>? endpoints;
  final void Function(Socket)? onConnect;
  final void Function(Socket, dynamic)? onError;
  final void Function(Socket)? onDone;

  late final ServerSocket _serverSocket;

  RawApiServer({
    required this.port,
    this.endpoints,
    this.onConnect,
    this.onError,
    this.onDone,
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
      throw DuplicateIdException('Provided endpoints do not have unique id values');
    }
  }

  void _checkValidEndpointIds() {
    if (endpoints == null) {
      return;
    }

    final ids = endpoints!.map((e) => e.id).toList();
    for (int id in ids) {
      if (id < 0 || id > 255) {
        throw InvalidIdException('Id is not within range [0, 255]: $id');
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
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket.listen((socket) => _handleConnection(socket));
  }

  Future<void> stop() async {
    await _serverSocket.close();
  }
}