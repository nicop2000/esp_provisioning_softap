import 'package:equatable/equatable.dart';

abstract class WifiEvent extends Equatable {
  const WifiEvent();

  @override
  List<Object> get props => [];
}

// events for BLE provisioning
class WifiEventLoadBLE extends WifiEvent {
  const WifiEventLoadBLE(this.selectedDevice);
  final Map<String, dynamic> selectedDevice;

  @override
  List<Object> get props => [selectedDevice];
}

class WifiEventConnectingBLE extends WifiEvent {}

class WifiEventScanningBLE extends WifiEvent {}

class WifiEventScannedBLE extends WifiEvent {}

class WifiEventLoadedBLE extends WifiEvent {
  const WifiEventLoadedBLE({required this.wifiName});
  final String wifiName;

  @override
  List<Object> get props => [wifiName];
}

class WifiEventStartProvisioningBLE extends WifiEvent {
  const WifiEventStartProvisioningBLE({
    required this.ssid,
    required this.password,
  });
  final String ssid;
  final String password;

  @override
  List<Object> get props => [ssid, password];
}

// events for softap provisioning
class WifiEventLoadSoftAP extends WifiEvent {}

class WifiEventConnectingSoftAP extends WifiEvent {}

class WifiEventScanningSoftAP extends WifiEvent {}

class WifiEventScannedSoftAP extends WifiEvent {}

class WifiEventLoadedSoftAP extends WifiEvent {
  const WifiEventLoadedSoftAP({this.wifiName});
  final String wifiName;

  @override
  List<Object> get props => [wifiName];
}

class WifiEventStartProvisioningSoftAP extends WifiEvent {
  const WifiEventStartProvisioningSoftAP({this.ssid, this.password});
  final String ssid;
  final String password;

  @override
  List<Object> get props => [ssid, password];
}
