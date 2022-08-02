import 'dart:io';

import 'package:raw_api_server/raw_api_server.dart';

final api = RawApiServer(
  port: 6543,
  endpoints: [
    ApiEndpoint(
      id: 0,
      handler: (socket, data) => socket.write('Pong.'),
    ),
  ],
);

final pingRequest = ApiRequest.fromUtf8(
  id: 0,
  data: 'Ping!',
);

final client = RawApiClient(
  port: 6543,
  host: 'localhost',
  onReceive: (socket, data) =>
      stdout.writeln('Received: ${String.fromCharCodes(data)}'),
);

Future<void> main() async {
  await api.start();
  await client.connect();

  stdout.writeln('Sending a ping!');
  client.sendRequest(pingRequest);
  await Future<void>.delayed(const Duration(seconds: 2));

  client.disconnect();
  await api.stop();
}
