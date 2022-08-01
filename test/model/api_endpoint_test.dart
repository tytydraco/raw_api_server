import 'package:raw_api_server/model/api_endpoint.dart';
import 'package:test/test.dart';

void main() {
  group('Invalid endpoint ID', () {
    test('Less than min', () {
      expect(() => ApiEndpoint(id: -1), throwsArgumentError);
    });
  });
}
