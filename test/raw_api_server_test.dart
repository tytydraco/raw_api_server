import 'package:raw_api_server/raw_api_server.dart';
import 'package:test/test.dart';

void main() {
  test('API server', () async {
    final api = RawApiServer(
      port: 1234,
      onConnect: (socket) {
        print('Connected');
      },
      onDisconnect: (socket) {
        print('Disconnected');
      },
    );

    await api.start();
    await api.stop();
  });
}