import 'dart:io';

import 'package:raw_api_server/raw_api_client.dart';
import 'package:test/test.dart';

void main() {
  test('API client', () async {
    final client = RawApiClient(
      port: 1234,
      host: 'does.not.exist',
      onConnect: (socket) {
        print('Connected');
      },
      onDisconnect: (socket) {
        print('Disconnected');
      },
      onReceive: (socket, data) {
        print('Received data');
      },
    );

    expect(
        () async => await client.connect(timeout: const Duration(seconds: 1)),
        throwsException);
  });
}
