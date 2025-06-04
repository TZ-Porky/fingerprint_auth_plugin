import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fingerprint_auth_method_channel.dart';

abstract class FingerprintAuthPlatform extends PlatformInterface {
  /// Constructs a FingerprintAuthPlatform.
  FingerprintAuthPlatform() : super(token: _token);

  static final Object _token = Object();

  static FingerprintAuthPlatform _instance = MethodChannelFingerprintAuth();

  /// The default instance of [FingerprintAuthPlatform] to use.
  ///
  /// Defaults to [MethodChannelFingerprintAuth].
  static FingerprintAuthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FingerprintAuthPlatform] when
  /// they register themselves.
  static set instance(FingerprintAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
