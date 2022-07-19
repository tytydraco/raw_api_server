import 'dart:io';

import 'package:raw_api_server/model/api_request.dart';
import 'package:raw_api_server/raw_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('API client', () {
    final client = RawApiClient(port: 9999, host: 'localhost');

    test('Send request before connect', () async {
      expect(() => client.sendRequest(ApiRequest(id: 0)), throwsStateError);
    });

    test('Disconnect before connect', () async {
      expect(() => client.disconnect(), throwsStateError);
    });

    test('Connect', () async {
      final mockServerSocket =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, 9999);
      await client.connect();
      expect(client.hasConnected, isTrue);
      await mockServerSocket.close();
    });

    test('Send request', () async {
      final mockServerSocket =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, 9999);

      final serverListenerFuture = mockServerSocket.listen((socket) {
        socket.listen((data) async {
          expect(data.toList(), equals([0]));
          await mockServerSocket.close();
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
