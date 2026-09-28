import 'dart:convert';

import 'package:http/http.dart' as http;

final _httpClient = http.Client();

Uri _buildUri(String basePath, String path, [Map<String, dynamic>? queryParams]) {
  final uri = Uri.parse(basePath);
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

Map<String, String> _defaultHeaders(String? authHeaderKey, [Map<String, String>? extra]) {
  final headers = <String, String>{'Accept': 'application/json'};
  if (authHeaderKey != null && authHeaderKey.isNotEmpty) {
    headers['Authorization'] = 'key $authHeaderKey';
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

Future<http.Response> _sendWithRetry(Future<http.Response> Function() requestFn) async {
  int attempts = 0;
  while (true) {
    attempts++;
    final resp = await requestFn();
    if (resp.statusCode == 429 && attempts <= 4) {
      // Rebrickable might throttle heavily if multiple delete requests hit quickly.
      await Future.delayed(Duration(seconds: 1 + attempts));
      continue;
    }
    return resp;
  }
}

Future<dynamic> apiGet(
  String basePath,
  String path, {
  String? authHeaderKey,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
}) async {
  final uri = _buildUri(basePath, path, queryParameters);
  final resp = await _sendWithRetry(() => _httpClient.get(uri, headers: _defaultHeaders(authHeaderKey, headers)));
  return _decodeResponse(resp);
}

Future<dynamic> apiPost(
  String basePath,
  String path, {
  required String authHeaderKey,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
  Object? body,
  bool form = false,
}) async {
  final uri = _buildUri(basePath, path, queryParameters);
  final h = _defaultHeaders(authHeaderKey, headers);
  Object? payload = body;
  if (form) {
    h['Content-Type'] = 'application/x-www-form-urlencoded';
    if (body is Map) payload = _formEncode(body);
  } else {
    if (body != null) {
      h['Content-Type'] = 'application/json';
      payload = json.encode(body);
    }
  }
  final resp = await _sendWithRetry(() => _httpClient.post(uri, headers: h, body: payload));
  return _decodeResponse(resp);
}

Future<dynamic> apiPut(
  String basePath,
  String path, {
  required String authHeaderKey,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
  Object? body,
  bool form = false,
}) async {
  final uri = _buildUri(basePath, path, queryParameters);
  final h = _defaultHeaders(authHeaderKey, headers);
  Object? payload = body;
  if (form) {
    h['Content-Type'] = 'application/x-www-form-urlencoded';
    if (body is Map) payload = _formEncode(body);
  } else {
    if (body != null) {
      h['Content-Type'] = 'application/json';
      payload = json.encode(body);
    }
  }
  final resp = await _sendWithRetry(() => _httpClient.put(uri, headers: h, body: payload));
  return _decodeResponse(resp);
}

Future<dynamic> apiDelete(
  String basePath,
  String path, {
  required String authHeaderKey,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
}) async {
  final uri = _buildUri(basePath, path, queryParameters);
  final resp = await _sendWithRetry(() => _httpClient.delete(uri, headers: _defaultHeaders(authHeaderKey, headers)));
  return _decodeResponse(resp);
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException: status=$statusCode body=$body';
}
