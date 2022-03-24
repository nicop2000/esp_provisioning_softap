import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp_provisioning_softap/esp_provisioning_softap.dart';

void main() {
  const MethodChannel channel = MethodChannel('esp_provisioning_softap');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await EspSoftapProvisioning.platformVersion, '42');
  // });
}
