import 'dart:io';

import 'package:raw_api_server/model/api_request.dart';
import 'package:raw_api_server/raw_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('API client', () {
    final mockServerSocket =
        ServerSocket.bind(InternetAddress.loopbackIPv4, 9999);
    final client = RawApiClient(port: 9999, host: 'localhost');

    test('Send request before connect', () async {
      expect(() => client.sendRequest(ApiRequest(id: 0)), throwsStateError);
    });

    test('Disconnect before connect', () async {
      expect(() => client.disconnect(), throwsStateError);
    });

    test('Connect', () async {
      await mockServerSocket;
      await client.connect();
      expect(client.hasConnected, isTrue);
    });

    test('Send request', () async {
      final server = await mockServerSocket;

      final serverListenerFuture = server.listen((socket) {
        socket.listen((data) async {
          expect(data.toList(), equals([0]));
          await server.close();
        });
      }).asFuture();

      client.sendRequest(ApiRequest(id: 0));

      expect(serverListenerFuture, completes);
    });

    test('Double connect', () async {
      expect(client.connect(), throwsStateError);
    });

    test('Disconnect', () async {
      client.disconnect();
      expect(client.hasConnected, isFalse);
    });
  });
}
