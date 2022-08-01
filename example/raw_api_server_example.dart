import 'dart:io';

import 'package:raw_api_server/api_endpoint.dart';
import 'package:raw_api_server/api_request.dart';
import 'package:raw_api_server/raw_api_client.dart';
import 'package:raw_api_server/raw_api_server.dart';

/// Instance of our custom API server
final api = RawApiServer(
  // Port to host our server on
  port: 6543,
  // When a client connects to us, call this first. This is useful to gather
  // client information before serving them.
  onConnect: (socket) =>
      stdout.writeln('Connected: ${socket.remoteAddress.address}'),
  // When a client disconnects, this is the final call made
  onDisconnect: (socket) =>
      stdout.writeln('Disconnected: ${socket.remoteAddress.address}'),
  // Give a list of registered endpoints to check for. If a client sends us a
  // request with an id that is already registered here, the respective function
  // will be called.
  endpoints: [
    ApiEndpoint(
      // Each endpoint needs a unique id that has not been registered to the
      // server already. It is sent over TCP as a single Uint8, so the range
      // for the id is [0, 256).
      id: 0,
      // Each call passes the client and the remaining data as a Uint8List
      handler: (socket, data) {
        // Echo the arguments sent by the client
        stdout.writeln(
          '${socket.remoteAddress.address}: '
          '${String.fromCharCodes(data)}',
        );
        // Reply to them
        socket.write('I hear you loud and clear');
      },
    ),
  ],
);

/// Instance of an example client
final client = RawApiClient(
  // Port that our server is hosted on
  port: 6543,
  // Host or IP address of our server
  host: 'localhost',
  // When we connect to the server, call this first
  onConnect: (socket) {
    stdout.writeln('Client connected to ${socket.remoteAddress.address}');
  },
  // When the server sends us data, handle it here. We are passed the server
  // socket and the data sent as a Uint8List.
  onReceive: (socket, data) {
    stdout.writeln('Client received: ${String.fromCharCodes(data)}');
  },
  // When we disconnect from the server, this is the final call made
  onDisconnect: (socket) {
    stdout.writeln('Client disconnected from server');
  },
);

Future<void> main() async {
  // Start our API server
  await api.start();
  // Tell our client to try connecting to it now
  await client.connect();
  // Send a request with ID 0 (previously registered by out server)
  client.sendRequest(
    // Build a formal API request using UTF-8 data rather than a Uint8List
    ApiRequest.fromUtf8(id: 0, data: 'Hello world'),
  );
  // Give ample time for the server to respond to us
  await Future<void>.delayed(const Duration(seconds: 1));
  // Disconnect our client from the server
  client.disconnect();
  // Stop the server
  await api.stop();
}
