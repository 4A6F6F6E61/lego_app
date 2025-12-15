import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String basePath;
  final http.Client _inner;

  ApiClient({http.Client? httpClient, String? basePath})
    : _inner = httpClient ?? http.Client(),
      basePath = basePath ?? 'https://rebrickable.com';

  Uri buildUri(String path, [Map<String, dynamic>? queryParams]) {
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

  Map<String, String> _defaultHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{'Accept': 'application/json'};
    headers['Authorization'] = "key ${dotenv.env['REBRICKABLE_API_KEY']}";
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = buildUri(path, queryParameters);
    final resp = await _inner.get(uri, headers: _defaultHeaders(headers));
    return _decodeResponse(resp);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = buildUri(path, queryParameters);
    final resp = await _inner.delete(uri, headers: _defaultHeaders(headers));
    return _decodeResponse(resp);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    bool form = false,
  }) async {
    final uri = buildUri(path, queryParameters);
    final h = _defaultHeaders(headers);
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
    final resp = await _inner.post(uri, headers: h, body: payload);
    return _decodeResponse(resp);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    bool form = false,
  }) async {
    final uri = buildUri(path, queryParameters);
    final h = _defaultHeaders(headers);
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
    final resp = await _inner.put(uri, headers: h, body: payload);
    return _decodeResponse(resp);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    bool form = false,
  }) async {
    final uri = buildUri(path, queryParameters);
    final h = _defaultHeaders(headers);
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
    final resp = await _inner.patch(uri, headers: h, body: payload);
    return _decodeResponse(resp);
  }

  String _formEncode(Map m) => m.entries
      .map(
        (e) =>
            '${Uri.encodeQueryComponent(e.key.toString())}=${Uri.encodeQueryComponent(e.value.toString())}',
      )
      .join('&');

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
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException: status=$statusCode body=$body';
}
