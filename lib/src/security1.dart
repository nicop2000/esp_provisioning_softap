import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:esp_provisioning_softap/src/cryptor.dart';
import 'package:esp_provisioning_softap/src/logger.dart';
import 'package:esp_provisioning_softap/src/proto/dart/sec1.pb.dart';
import 'package:esp_provisioning_softap/src/proto/dart/session.pb.dart';
import 'package:esp_provisioning_softap/src/security.dart';
import 'package:flutter/foundation.dart';

class Security1 implements Security {
  Security1({
    required this.pop,
    this.sessionState = SecurityState.request1,
    this.verbose = false,
  });

  final String pop;
  final bool verbose;
  late SimpleKeyPairData clientKey;
  late List<int> clientPubKey;
  late SimplePublicKey devicePublicKey;
  late Uint8List deviceRandom;
  final Cryptor crypt = Cryptor();

  final algorithm = Cryptography.instance.x25519();

  SecurityState sessionState;

  @override
  Future<Uint8List> encrypt(Uint8List data) async {
    logger.i('raw data before encryption: $data');
    return crypt.crypt(data);
  }

  @override
  Future<Uint8List> decrypt(Uint8List data) async {
    logger.i('Decrypt');
    return encrypt(data);
  }

  Future<void> _generateKey() async {
    // creates client key with X25519 algo
    clientKey = await (await algorithm.newKeyPair()).extract();
  }

  Uint8List _xor(Uint8List a, Uint8List b) {
    // XOR two inputs of type `bytes`
    final ret = Uint8List(max(a.length, b.length));
    for (var i = 0; i < max(a.length, b.length); i++) {
      // Convert the characters to corresponding 8-bit ASCII codes
      // then XOR them and store in byte array
      final a0 = i < a.length ? a[i] : 0;
      final b0 = i < b.length ? b[i] : 0;
      ret[i] = a0 ^ b0;
    }
    return ret;
  }

  @override
  Future<SessionData?> securitySession(SessionData? responseData) async {
    switch (sessionState) {
      case SecurityState.request1:
        sessionState = SecurityState.response1Request2;
        return setup0Request();
      case _ when responseData == null:
        throw Exception('Response data is null but was expected.');
      case SecurityState.response1Request2:
        sessionState = SecurityState.response2;
        await setup0Response(responseData);
        return setup1Request(responseData);
      case SecurityState.response2:
        sessionState = SecurityState.finished;
        await setup1Response(responseData);
        return null;
      case _:
        throw Exception(
          'securitySession called with '
          'invalid sessionState: ${sessionState.name}',
        );
    }
  }

  Future<SessionData> setup0Request() async {
    final setupRequest = SessionData()..secVer = SecSchemeVersion.SecScheme1;
    await _generateKey();
    final sc0 = SessionCmd0();
    await clientKey.extractPublicKey().then((publicKey) {
      sc0.clientPubkey = publicKey.bytes;
      clientPubKey = publicKey.bytes;
    });

    final sec1 = Sec1Payload()..sc0 = sc0;
    setupRequest.sec1 = sec1;
    logger.i('setup0Request: clientPubkey = $clientPubKey');
    return setupRequest;
  }

  Future<SessionData?> setup0Response(SessionData responseData) async {
    final setupResp = responseData;
    if (setupResp.secVer != SecSchemeVersion.SecScheme1) {
      throw Exception('Invalid sec scheme');
    }
    devicePublicKey = SimplePublicKey(
      setupResp.sec1.sr0.devicePubkey,
      type: KeyPairType.x25519,
    );
    deviceRandom = Uint8List.fromList(setupResp.sec1.sr0.deviceRandom);

    logger.i(
      'setup0Response:Device public key $devicePublicKey\n'
      'setup0Response:Device random $deviceRandom',
    );

    final sharedKey = await algorithm.sharedSecretKey(
      keyPair: clientKey,
      remotePublicKey: devicePublicKey,
    );

    await sharedKey.extractBytes().then((sharedSecret) async {
      Uint8List sharedKeyBytes;
      logger.i(
        'setup0Response: Shared key calculated: $sharedSecret',
      );
      final sink = Sha256().newHashSink()
        ..add(utf8.encode(pop))
        ..close();
      final hash = await sink.hash();
      sharedKeyBytes = _xor(
        Uint8List.fromList(sharedSecret),
        Uint8List.fromList(hash.bytes),
      );
      logger.i({
        'setup0Response': {
          'pop': pop,
          'hash': hash.bytes,
          'sharedK': sharedKeyBytes,
        },
      });

      await crypt.init(sharedKeyBytes, deviceRandom);
      logger.i({
        'setup0Response': {
          'cipherSecretKey': sharedKeyBytes,
          'cipherNonce': deviceRandom,
        },
      });
      return setupResp;
    });
    return null;
  }

  Future<SessionData> setup1Request(SessionData responseData) async {
    logger.i('setup1Request $devicePublicKey');
    final clientVerify =
        await encrypt(Uint8List.fromList(devicePublicKey.bytes));

    logger.i('client verify $clientVerify');

    final sc1 = SessionCmd1()..clientVerifyData = clientVerify;

    final sec1 = Sec1Payload()
      ..msg = Sec1MsgType.Session_Command1
      ..sc1 = sc1;

    final setupRequest = SessionData()
      ..secVer = SecSchemeVersion.SecScheme1
      ..sec1 = sec1;

    logger.i('setup1Request finished');
    return setupRequest;
  }

  Future<SessionData?> setup1Response(SessionData responseData) async {
    logger.i('setup1Response');
    final setupResp = responseData;
    if (setupResp.secVer == SecSchemeVersion.SecScheme1) {
      final deviceVerify = setupResp.sec1.sr1.deviceVerifyData;
      logger.i('Device verify: $deviceVerify');
      final encClientPubkey = await decrypt(
        Uint8List.fromList(setupResp.sec1.sr1.deviceVerifyData),
      );
      logger
        ..i('encClientPubkey: $encClientPubkey')
        ..i('clientKey.publicKey.bytes: $clientPubKey');

      if (!listEquals(encClientPubkey, clientPubKey)) {
        throw Exception('Mismatch in device verify');
      }
      return null;
    }
    throw Exception('Unsupported security protocol');
  }
}
