import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:esp_provisioning_softap/esp_provisioning_softap.dart';
import 'package:esp_provisioning_softap/logger.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:string_validator/string_validator.dart';

@immutable
class TransportHTTP implements Transport {
  TransportHTTP({
    required this.hostname,
    this.timeout = const Duration(seconds: 10),
    http.Client? client,
  })  : assert(
          isURL(hostname),
          'hostname is required to be a valid URL',
        ),
        client = client ?? http.Client(),
        headers = {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          HttpHeaders.acceptHeader: 'text/plain',
        };

  final String hostname;
  final Duration timeout;
  final Map<String, String> headers;
  final http.Client client;

  @override
  Future<bool> connect() async {
    return true;
  }

  @override
  Future<void> disconnect() async {
    client.close();
  }

  void _updateCookie(http.Response response) {
    final rawCookie = response.headers[HttpHeaders.setCookieHeader];
    if (rawCookie != null) {
      final index = rawCookie.indexOf(';');
      headers[HttpHeaders.cookieHeader] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  @override
  Future<Uint8List?> sendReceive(String epName, Uint8List data) async {
    try {
      logger.d('Connecting to $hostname/$epName');
      final response = await client
          .post(
            Uri.http(
              hostname,
              '/$epName',
            ),
            headers: headers,
            body: data,
          )
          .timeout(timeout);

      _updateCookie(response);
      if (response.statusCode == 200) {
        logger.d('Connection successful');
        return response.bodyBytes;
      } else {
        logger.d('Connection failed - HTTP-Status ${response.statusCode}');
        throw Exception(
          'ESP Device is not responding. HTTP-Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Unknown error in transport_http.dart - '
        'Connection error (${e.runtimeType})$e',
      );
    }
  }
}
