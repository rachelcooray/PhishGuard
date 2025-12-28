import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Backend connection test', () async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/'));
    expect(response.statusCode, 200);
    final json = jsonDecode(response.body);
    expect(json['status'], 'active');
  });
}
