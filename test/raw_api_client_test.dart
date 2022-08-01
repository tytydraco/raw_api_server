import 'dart:io';

import 'package:raw_api_server/model/api_request.dart';
import 'package:raw_api_server/raw_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('API client', () {
    final localServerSocket =
        ServerSocket.bind(InternetAddress.loopbackIPv4, 9999);
    final client = RawApiClient(port: 9999, host: 'localhost');

    test('Send request before connect', () async {
      expect(() => client.sendRequest(ApiRequest(id: 0)), throwsStateError);
    });

    test('Disconnect before connect', () async {
      expect(client.disconnect, throwsStateError);
    });

    test('Connect', () async {
      await localServerSocket;
      await client.connect();
      expect(client.hasConnected, isTrue);
    });

    test('Send request', () async {
      final server = await localServerSocket;

      final serverListener = server.listen((socket) {
        socket.listen((data) async {
          expect(data.toList(), [0, 0, 0, 0]);
          await server.close();
        });
      });

      final serverListenerFuture = serverListener.asFuture(null);

      client.sendRequest(ApiRequest(id: 0));

      await expectLater(serverListenerFuture, completes);
      await serverListener.cancel();
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
