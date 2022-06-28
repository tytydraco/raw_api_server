import 'dart:convert';

class ApiRequest {
  final int id;
  final List<int>? data;

  ApiRequest({
    required this.id,
    this.data,
  });

  factory ApiRequest.fromUtf8({
    required int id,
    required String data,
  }) {
    return ApiRequest(id: id, data: utf8.encode(data));
  }

  List<int> toIntList() {
    final request = [id];
    if (data != null) {
      request.addAll(data!);
    }
    return request;
  }
}