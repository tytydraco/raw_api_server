import 'package:raw_api_server/model/api_endpoint.dart';
import 'package:raw_api_server/model/api_request.dart';
import 'package:raw_api_server/raw_api_client.dart';
import 'package:raw_api_server/raw_api_server.dart';

/// Instance of our custom API server
final api = RawApiServer(
  // Port to host our server on
  port: 6543,
  // When a client connects to us, call this first. This is useful to gather
  // client information before serving them.
  onConnect: (socket) => print('Connected: ${socket.remoteAddress.address}'),
  // Handle stream errors here; if they are unhandled, an exception will be
  // thrown instead.
  onError: (socket, error) {
    print(error);
    socket.destroy();
  },
  // When a client disconnects, this is the final call made
  onDone: (socket) {
    print('Server disconnected from ${socket.remoteAddress.address}:${socket.remotePort}');
  },
  // Give a list of registered endpoints to check for. If a client sends us a
  // request with an id that is already registered here, the respective function
  // will be called.
  endpoints: [
    ApiEndpoint(
      // Each endpoint needs a unique id that has not been registered to the
      // server already. It is sent over TCP as a single Uint8, so the range for
      // the id is [0, 255] inclusive.
      id: 0,
      // Each call passes the client and the remaining data as a Uint8List
      onCall: (socket, data) {
        // Echo the arguments sent by the client
        print('${socket.remoteAddress.address}: ${String.fromCharCodes(data)}');
        // Reply to them
        socket.write('I hear you loud and clear');
      }
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
    print('Client connected to ${socket.remoteAddress.address}:${socket.remotePort}');
  },
  // When the server sends us data, handle it here. We are passed the server
  // socket and the data sent as a Uint8List.
  onReceive: (socket, data) {
    print('Client received: ${String.fromCharCodes(data)}');
  },
  // Handle stream errors here; if they are unhandled, an exception will be
  // thrown instead.
  onError: (socket, error) {
    print(error);
    socket.destroy();
  },
  // When we disconnect from the server, this is the final call made
  onDone: (socket) {
    print('Client disconnected from server');
  }
);

Future<void> main() async {
  // Start our API server
  await api.start();
  // Tell our client to try connecting to it now
  await client.connect();
  // Send a request with ID 0 (previously registered by out server)
  client.sendRequest(
    // Build a formal API request using UTF-8 data rather than a Uint8List
    ApiRequest.fromUtf8(
      id: 0,
      data: 'Hello world'
    )
  );
  // Give ample time for the server to respond to us
  await Future.delayed(Duration(seconds: 1));
  // Disconnect our client from the server
  client.disconnect();
  // Stop the server
  await api.stop();
}
