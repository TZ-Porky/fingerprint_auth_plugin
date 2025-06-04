
import 'fingerprint_auth_platform_interface.dart';

class FingerprintAuth {
  Future<String?> getPlatformVersion() {
    return FingerprintAuthPlatform.instance.getPlatformVersion();
  }
}
