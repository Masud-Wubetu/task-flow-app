import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();
  final _base   = Uri.parse(ApiConstants.baseUrl);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> get(String path, {Map<String, String>? params}) async {
    try {
      final uri = _base.replace(
        path: path,
        queryParameters: params,
      );
      final res = await _client.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));
      return _handleResponse(res);
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final uri = _base.replace(path: path);
      final res = await _client
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));
      return _handleResponse(res);
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final uri = _base.replace(path: path);
      final res = await _client
          .put(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));
      return _handleResponse(res);
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final uri = _base.replace(path: path);
      final res = await _client
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));
      return _handleResponse(res);
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body);
    } else if (res.statusCode == 404) {
      throw ApiException('Resource not found.', statusCode: 404);
    } else if (res.statusCode >= 500) {
      throw ApiException('Server error. Please try again later.',
          statusCode: res.statusCode);
    } else {
      throw ApiException('Something went wrong (${res.statusCode}).',
          statusCode: res.statusCode);
    }
  }
}
