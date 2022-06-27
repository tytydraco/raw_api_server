import 'package:raw_api_server/model/api_endpoint.dart';
import 'package:raw_api_server/model/api_request.dart';
import 'package:raw_api_server/raw_api_client.dart';
import 'package:raw_api_server/raw_api_server.dart';

Future<void> main() async {
  var api = RawApiServer(
    port: 6543,
    endpoints: [
      ApiEndpoint(
        id: 0,
        onCall: (socket, args) {
          print('Endpoint: ${socket.remoteAddress.address}: args: ${String.fromCharCodes(args)}');
          socket.write('Loud and clear');
        }
      ),
    ],
    onConnect: (socket) {
      print('Server connected to ${socket.remoteAddress.address}:${socket.remotePort}');
    },
    onError: (socket, error) {
      print(error);
      socket.close();
    },
    onDone: (socket) {
      print('Server disconnected from ${socket.remoteAddress.address}:${socket.remotePort}');
    }
  );

  final client = RawApiClient(
    port: 6543,
    host: 'localhost',
    onConnect: (socket) {
      print('Client connected to ${socket.remoteAddress.address}:${socket.remotePort}');
    },
    onReceive: (socket, data) {
      print('Client received: ${String.fromCharCodes(data)}');
    },
    onError: (socket, error) {
      print(error);
      socket.destroy();
    },
    onDone: (socket) {
      print('Client disconnected from server');
    }
  );

  await api.start();
  await client.connect();
  await client.sendRequest(
    ApiRequest.fromUtf8(
      id: 0,
      stringArgs: 'Hello world'
    )
  );
  await Future.delayed(Duration(seconds: 1));
  client.disconnect();
  await api.stop();
}
