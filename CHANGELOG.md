## [2.0.0] - 2023-10-12

> Author: [@jeroen-meijer](https://github.com/jeroen-meijer)

- **feat!**: Many classes have been altered in small and significant ways. In particular, expect these types of changes:
  - Most classes are now marked immutable.
  - Functions that previously returned a `Future<bool>` now return a `Future<void>`. In cases where these functions returned `false`, they now throw an exception.
  - Functions that internally caught exceptions and returned `null` now throw those exceptions.
- **chore!: upgrade Dart SDK constraint to 3.0.0 or higher, upgrade Flutter SDK constraint to 3.10.0 or higher.**
- feat: add `logger.dart` for consumer-customizable logging (import `package:esp_provisioning_softap/logger.dart` and set `logger` as desired).
- chore: add [`very_good_analysis`](https://pub.dev/packages/very_good_analysis) package and linter rules and fix all issues.
- chore: upgrade all dependencies to latest versions.
- chore: format all files.

## [1.0.3] - 2022-09-17

- Update Kotlin Version from 1.3.50 to 1.5.20

## [1.0.2] - 2022-05-02

- Minor bugfixes in provisioning process.

## [1.0.1] - 2022-03-25

- Minor bugfixes. sendReceiveCustomData-Endpoint can now be specified.

## [1.0.0] - 2022-03-24

- Stable release for Espressif Esp32 Soft Ap provisioning with protobuf and cryptography with null-safety. Based on version 1.0.1 from esp_softap_provisioning.
