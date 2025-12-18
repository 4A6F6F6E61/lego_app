import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const String _basePath = 'https://rebrickable.com';

final _httpClient = http.Client();

Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
  final uri = Uri.parse(_basePath);
  final newPath = uri.path.endsWith('/')
      ? '${uri.path}${path.replaceFirst('/', '')}'
      : '${uri.path}$path';
  final combined = uri.replace(path: newPath, queryParameters: _encodeQuery(queryParams));
  return combined;
}

Map<String, String>? _encodeQuery(Map<String, dynamic>? qp) {
  if (qp == null) return null;
  final out = <String, String>{};
  qp.forEach((k, v) {
    if (v == null) return;
    out[k] = v is List ? v.join(',') : v.toString();
  });
  return out;
}

Map<String, String> _defaultHeaders(String apiKey, [Map<String, String>? extra]) {
  final headers = <String, String>{'Accept': 'application/json'};
  if (apiKey.isNotEmpty) {
    headers['Authorization'] = 'key $apiKey';
  }
  if (extra != null) headers.addAll(extra);
  return headers;
}

dynamic _decodeResponse(http.Response resp) {
  final code = resp.statusCode;
  if (code >= 200 && code < 300) {
    if (resp.body.isEmpty) return null;
    try {
      return json.decode(resp.body);
    } catch (_) {
      return resp.body;
    }
  }
  throw ApiException(code, resp.body);
}

String _formEncode(Map m) => m.entries
    .map(
      (e) =>
          '${Uri.encodeQueryComponent(e.key.toString())}=${Uri.encodeQueryComponent(e.value.toString())}',
    )
    .join('&');

Future<dynamic> apiGet(
  String path, {
  required String apiKey,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
}) async {
  final uri = _buildUri(path, queryParameters);
  final resp = await _httpClient.get(uri, headers: _defaultHeaders(apiKey, headers));
  return _decodeResponse(resp);
}

Future<dynamic> apiPost(
  String path, {
  required String apiKey,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
  Object? body,
  bool form = false,
}) async {
  final uri = _buildUri(path, queryParameters);
  final h = _defaultHeaders(apiKey, headers);
  Object? payload = body;
  if (form) {
    h['Content-Type'] = 'application/x-www-form-urlencoded';
    if (body is Map) payload = _formEncode(body as Map);
  } else {
    if (body != null) {
      h['Content-Type'] = 'application/json';
      payload = json.encode(body);
    }
  }
  final resp = await _httpClient.post(uri, headers: h, body: payload);
  return _decodeResponse(resp);
}

Future<dynamic> apiPut(
  String path, {
  required String apiKey,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
  Object? body,
  bool form = false,
}) async {
  final uri = _buildUri(path, queryParameters);
  final h = _defaultHeaders(apiKey, headers);
  Object? payload = body;
  if (form) {
    h['Content-Type'] = 'application/x-www-form-urlencoded';
    if (body is Map) payload = _formEncode(body as Map);
  } else {
    if (body != null) {
      h['Content-Type'] = 'application/json';
      payload = json.encode(body);
    }
  }
  final resp = await _httpClient.put(uri, headers: h, body: payload);
  return _decodeResponse(resp);
}

Future<dynamic> apiDelete(
  String path, {
  required String apiKey,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
}) async {
  final uri = _buildUri(path, queryParameters);
  final resp = await _httpClient.delete(uri, headers: _defaultHeaders(apiKey, headers));
  return _decodeResponse(resp);
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException: status=$statusCode body=$body';
}
