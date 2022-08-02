import 'package:raw_api_server/raw_api_server.dart';
import 'package:raw_api_server/src/raw_api_server.dart';
import 'package:test/test.dart';

void main() {
  group('API server', () {
    final api = RawApiServer(port: 8888);

    test('Duplicate endpoint IDs', () {
      expect(
        () {
          RawApiServer(
            port: 8888,
            endpoints: [
              ApiEndpoint(id: 0),
              ApiEndpoint(id: 0),
            ],
          );
        },
        throwsArgumentError,
      );
    });

    test('Stop before start', () {
      expect(api.stop(), throwsStateError);
    });

    test('Start', () async {
      await api.start();
      expect(api.hasStarted, isTrue);
    });

    test('Double start', () async {
      expect(api.start(), throwsStateError);
    });

    test('Stop', () async {
      await api.stop();
      expect(api.hasStarted, isFalse);
    });
  });
}
