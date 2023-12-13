import 'dart:convert';
import 'dart:typed_data';

import 'package:esp_provisioning_softap/esp_provisioning_softap.dart';
import 'package:esp_provisioning_softap/logger.dart';
import 'package:esp_provisioning_softap/src/proto/dart/constants.pb.dart';
import 'package:esp_provisioning_softap/src/proto/dart/session.pb.dart';
import 'package:esp_provisioning_softap/src/proto/dart/wifi_config.pb.dart';
import 'package:esp_provisioning_softap/src/proto/dart/wifi_constants.pb.dart'
    as wifi_constants;
import 'package:esp_provisioning_softap/src/proto/dart/wifi_scan.pb.dart';
import 'package:meta/meta.dart';

@immutable
class Provisioning {
  const Provisioning({
    required this.transport,
    required this.security,
  });

  final Transport transport;
  final Security security;

  Future<void> establishSession() async {
    SessionData? responseData;
    await transport.connect();
    while (true) {
      final request = await security.securitySession(responseData);
      if (request == null) {
        return;
      }
      final response = await transport.sendReceive(
        'prov-session',
        request.writeToBuffer(),
      );
      if (response?.isEmpty ?? true) {
        throw Exception('Empty response');
      }
      responseData = SessionData.fromBuffer(List<int>.from(response!));
    }
  }

  Future<void> dispose() async {
    return transport.disconnect();
  }

  Future<List<Map<String, dynamic>>?> startScanWiFi() async {
    return scan();
  }

  Future<WiFiScanPayload> startScanResponse(Uint8List? data) async {
    final uint8list = await security.decrypt(data!);
    final respPayload = WiFiScanPayload.fromBuffer(List<int>.from(uint8list));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanStart) {
      throw Exception('Invalid expected message type $respPayload');
    }
    return respPayload;
  }

  Future<WiFiScanPayload> startScanRequest({
    bool blocking = true,
    bool passive = false,
    int groupChannels = 5,
    int periodMs = 0,
  }) async {
    final scanStart = CmdScanStart()
      ..blocking = blocking
      ..passive = passive
      ..groupChannels = groupChannels
      ..periodMs = periodMs;

    final payload = WiFiScanPayload()
      ..msg = WiFiScanMsgType.TypeCmdScanStart
      ..cmdScanStart = scanStart;

    final reqData = await security.encrypt(payload.writeToBuffer());
    final respData = await transport.sendReceive('prov-scan', reqData);

    return startScanResponse(respData);
  }

  Future<WiFiScanPayload> scanStatusResponse(Uint8List? data) async {
    final uint8list = await security.decrypt(data!);
    final respPayload = WiFiScanPayload.fromBuffer(List<int>.from(uint8list));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanStatus) {
      throw Exception('Invalid expected message type $respPayload');
    }
    return respPayload;
  }

  Future<WiFiScanPayload> scanStatusRequest() async {
    final payload = WiFiScanPayload()..msg = WiFiScanMsgType.TypeCmdScanStatus;
    final reqData = await security.encrypt(payload.writeToBuffer());
    final respData = await transport.sendReceive('prov-scan', reqData);
    return scanStatusResponse(respData);
  }

  Future<List<Map<String, dynamic>>> scanResultRequest({
    int startIndex = 0,
    int count = 0,
  }) async {
    final cmdScanResult = CmdScanResult()
      ..startIndex = startIndex
      ..count = count;

    final payload = WiFiScanPayload()
      ..msg = WiFiScanMsgType.TypeCmdScanResult
      ..cmdScanResult = cmdScanResult;

    final reqData = await security.encrypt(payload.writeToBuffer());
    final respData = await transport.sendReceive('prov-scan', reqData);
    return scanResultResponse(respData);
  }

  Future<List<Map<String, dynamic>>> scanResultResponse(Uint8List? data) async {
    final respPayload =
        WiFiScanPayload.fromBuffer(await security.decrypt(data!));
    if (respPayload.msg != WiFiScanMsgType.TypeRespScanResult) {
      throw Exception('Invalid expected message type $respPayload');
    }
    return respPayload.respScanResult.entries.map((e) {
      return {
        'ssid': utf8.decode(e.ssid),
        'channel': e.channel,
        'rssi': e.rssi,
        'bssid': e.bssid,
        'auth': e.auth.toString(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>?> scan({
    bool blocking = true,
    bool passive = false,
    int groupChannels = 5,
    int periodMs = 0,
  }) async {
    logger.d('Scan Started');
    await startScanRequest(
      blocking: blocking,
      passive: passive,
      groupChannels: groupChannels,
      periodMs: periodMs,
    );
    final status = await scanStatusRequest();
    final resultCount = status.respScanStatus.resultCount;
    final ret = <Map<String, dynamic>>[];
    if (resultCount > 0) {
      var index = 0;
      var remaining = resultCount;
      while (remaining > 0) {
        final count = remaining > 4 ? 4 : remaining;
        final data = await scanResultRequest(startIndex: index, count: count);
        ret.addAll(data);
        remaining -= count;
        index += count;
      }
    }
    return ret;
  }

  Future<void> sendWifiConfig({
    required String ssid,
    required String password,
  }) async {
    final cmdSetConfig = CmdSetConfig()
      ..ssid = utf8.encode(ssid)
      ..passphrase = utf8.encode(password);

    final payload = WiFiConfigPayload()
      ..msg = WiFiConfigMsgType.TypeCmdSetConfig
      ..cmdSetConfig = cmdSetConfig;

    final reqData = await security.encrypt(payload.writeToBuffer());
    final respData = await transport.sendReceive('prov-config', reqData);
    final respRaw = await security.decrypt(respData!);
    final respPayload = WiFiConfigPayload.fromBuffer(respRaw);
    if (respPayload.respSetConfig.status == Status.Success) {
      return;
    }

    throw Exception('Invalid expected message type $respPayload');
  }

  Future<bool> applyWifiConfig() async {
    final payload = WiFiConfigPayload()
      ..msg = WiFiConfigMsgType.TypeCmdApplyConfig;

    final reqData = await security.encrypt(payload.writeToBuffer());
    final respData = await transport.sendReceive('prov-config', reqData);
    final respRaw = await security.decrypt(respData!);
    final respPayload = WiFiConfigPayload.fromBuffer(respRaw);
    return (respPayload.respApplyConfig.status == Status.Success);
  }

  Future<ConnectionStatus> getStatus() async {
    final cmdGetStatus = CmdGetStatus();

    final payload = WiFiConfigPayload()
      ..msg = WiFiConfigMsgType.TypeCmdGetStatus
      ..cmdGetStatus = cmdGetStatus;

    final reqData = await security.encrypt(payload.writeToBuffer());
    final respData = await transport.sendReceive('prov-config', reqData);
    final respRaw = await security.decrypt(respData!);
    final respPayload = WiFiConfigPayload.fromBuffer(respRaw);

    switch (respPayload.respGetStatus.staState) {
      case wifi_constants.WifiStationState.Connected:
        return ConnectionStatus(
          state: WifiConnectionState.connected,
          ip: respPayload.respGetStatus.connected.ip4Addr,
        );
      case wifi_constants.WifiStationState.Connecting:
        return ConnectionStatus(state: WifiConnectionState.connecting);
      case wifi_constants.WifiStationState.Disconnected:
        return ConnectionStatus(state: WifiConnectionState.disconnected);
      case wifi_constants.WifiStationState.ConnectionFailed:
        switch (respPayload.respGetStatus.failReason) {
          case wifi_constants.WifiConnectFailedReason.AuthError:
            return ConnectionStatus(
              state: WifiConnectionState.connectionFailed,
              failedReason: WifiConnectFailedReason.authError,
            );
          case wifi_constants.WifiConnectFailedReason.NetworkNotFound:
            return ConnectionStatus(
              state: WifiConnectionState.connectionFailed,
              failedReason: WifiConnectFailedReason.networkNotFound,
            );
          case _:
            return ConnectionStatus(
              state: WifiConnectionState.connectionFailed,
            );
        }
      case _:
        return ConnectionStatus(
          state: WifiConnectionState.connectionFailed,
          failedReason: WifiConnectFailedReason.authError,
        );
    }
  }

  Future<Uint8List> sendReceiveCustomData(
    Uint8List data, {
    int packageSize = 256,
    String endpoint = 'custom-data',
  }) async {
    var i = data.length;
    const offset = 0;
    var ret = <int>[];
    while (i > 0) {
      final needToSend =
          data.sublist(offset, i < packageSize ? i : packageSize);
      final encrypted = await security.encrypt(needToSend);
      final newData = await transport.sendReceive(endpoint, encrypted);

      if ((newData?.length ?? 0) > 0) {
        final decrypted = await security.decrypt(newData!);
        ret += List.from(decrypted);
      }
      i -= packageSize;
    }
    return Uint8List.fromList(ret);
  }
}
