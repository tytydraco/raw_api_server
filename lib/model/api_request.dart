import 'dart:convert';

class ApiRequest {
  final int id;
  final List<int>? args;

  ApiRequest({
    required this.id,
    this.args,
  });

  factory ApiRequest.fromUtf8({
    required int id,
    required String stringArgs,
  }) {
    return ApiRequest(id: id, args: utf8.encode(stringArgs));
  }

  List<int> toIntList() {
    final request = [id];
    if (args != null) {
      request.addAll(args!);
    }
    return request;
  }
}