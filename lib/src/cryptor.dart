import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class Cryptor {
  static const _channel = MethodChannel('esp_provisioning_softap');

  Future<T> _invokeMethod<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    final res = await _channel.invokeMethod(method, arguments);
    if (res is! T) {
      throw Exception('''
Invalid return type after running method channel call.

The method channel call for "$method" returned a value of type ${res.runtimeType} which is not assignable to the expected return type of $T.

-- Call details --
Method:
"$method"

Arguments:
${arguments == null ? 'none' : const JsonEncoder.withIndent('  ').convert(arguments)}
''');
    }

    return res;
  }

  Future<bool> init(Uint8List key, Uint8List iv) {
    return _invokeMethod('init', {'key': key, 'iv': iv});
  }

  Future<Uint8List> crypt(Uint8List data) {
    return _invokeMethod('crypt', {'data': data});
  }
}
