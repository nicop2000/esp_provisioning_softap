import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:esp_provisioning_softap/esp_provisioning_softap.dart';
import 'package:esp_provisioning_softap_example/softap_service.dart';
import 'package:esp_provisioning_softap_example/wifi_screen/wifi.dart';
import 'package:logger/logger.dart';

class WiFiBlocSoftAP extends Bloc<WifiEvent, WifiState> {
  WiFiBlocSoftAP() : super(WifiStateLoading());

  Provisioning? prov;
  Logger log = Logger(printer: PrettyPrinter());
  SoftAPService softApService = SoftAPService();

  @override
  Stream<WifiState> mapEventToState(WifiEvent event) async* {
    if (event is WifiEventLoadSoftAP) {
      yield* _mapLoadToState();
    } else if (event is WifiEventStartProvisioningSoftAP) {
      yield* _mapProvisioningToState(event);
    }
  }

  Stream<WifiState> _mapLoadToState() async* {
    yield WifiStateConnecting();
    try {
      const pop = 'abcd1234';
      if (Platform.isIOS) {
        prov = await softApService.startProvisioning('wifi-prov.local', pop);
      } else {
        prov = await softApService.startProvisioning('192.168.4.1:80', pop);
      }
    } catch (e) {
      log.e('Error connecting to device $e');
      yield const WifiStateError('Error connecting to device');
    }
    yield WifiStateScanning();
    try {
      final listWifi = await prov.startScanWiFi();
      yield WifiStateLoaded(wifiList: listWifi ?? []);
      log.v('Wifi $listWifi');
    } catch (e) {
      log.e('Error scan WiFi network $e');
      yield const WifiStateError('Error scan WiFi network');
    }
  }

  Stream<WifiState> _mapProvisioningToState(
    WifiEventStartProvisioningSoftAP event,
  ) async* {
    yield WifiStateProvisioning();
    final customData = utf8.encode('Some CUSTOM data0');
    final customBytes = Uint8List.fromList(customData);
    await prov.sendReceiveCustomData(customBytes);
    await prov.sendWifiConfig(ssid: event.ssid, password: event.password);
    await prov.applyWifiConfig();
    await Future.delayed(const Duration(seconds: 10));
    final connectionStatus = await prov.getStatus();

    if (connectionStatus.state == WifiConnectionState.connected) {
      yield WifiStateProvisionedSuccessfully();
    }
    /*else if (connectionStatus.state == 1){

    }*/
    else if (connectionStatus.state == WifiConnectionState.disconnected) {
      yield WifiStateProvisioningDisconnected();
    } else if (connectionStatus.state == WifiConnectionState.connectionFailed) {
      if (connectionStatus.failedReason == WifiConnectFailedReason.authError) {
        yield WifiStateProvisioningAuthError();
      } else if (connectionStatus.failedReason ==
          WifiConnectFailedReason.networkNotFound) {
        yield WifiStateProvisioningNetworkNotFound();
      }
    }
  }

  @override
  Future<void> close() {
    prov.dispose();
    return super.close();
  }
}
