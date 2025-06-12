import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fingerprint_auth/flutter_fingerprint_auth.dart';
import 'package:flutter_fingerprint_auth/flutter_fingerprint_auth_platform_interface.dart';
import 'package:flutter_fingerprint_auth/flutter_fingerprint_auth_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFingerprintAuthPlatform
    with MockPlatformInterfaceMixin
    implements FingerprintAuthPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FingerprintAuthPlatform initialPlatform = FingerprintAuthPlatform.instance;

  test('$MethodChannelFingerprintAuth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFingerprintAuth>());
  });

  test('getPlatformVersion', () async {
    FingerprintAuth fingerprintAuthPlugin = FingerprintAuth();
    MockFingerprintAuthPlatform fakePlatform = MockFingerprintAuthPlatform();
    FingerprintAuthPlatform.instance = fakePlatform;

    expect(await fingerprintAuthPlugin.getPlatformVersion(), '42');
  });
}
