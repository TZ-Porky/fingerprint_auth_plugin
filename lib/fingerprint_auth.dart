import 'dart:async';
import 'package:flutter/services.dart';

class FingerprintAuth {
  static const MethodChannel _channel =
      MethodChannel('fingerprint_auth');

  /// Checks if biometric authentication is available on the device.
  /// Returns true if available and enrolled, false otherwise.
  static Future<bool> canAuthenticate() async {
    final bool? result = await _channel.invokeMethod<bool>('canAuthenticate');
    return result ?? false;
  }

  /// Authenticates the user using biometrics.
  ///
  /// [title]: The title of the biometric prompt.
  /// [subtitle]: The subtitle of the biometric prompt.
  /// [negativeButtonText]: Text for the negative button (e.g., "Use Password").
  ///
  /// Returns `true` if authentication is successful, `false` if it fails (e.g., wrong fingerprint),
  /// or throws a [PlatformException] if an unrecoverable error occurs (e.g., too many attempts, no hardware).
  static Future<bool> authenticate({
    String title = 'Authentication Required',
    String subtitle = 'Verify your identity to proceed',
    String negativeButtonText = 'Use Password',
  }) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>(
        'authenticate',
        <String, dynamic>{
          'title': title,
          'subtitle': subtitle,
          'negativeButtonText': negativeButtonText,
        },
      );
      return success ?? false;
    } on PlatformException catch (e) {
      // Handle specific authentication errors if needed
      // print("Authentication error: ${e.code} - ${e.message}");
      rethrow; // Re-throw the exception for the calling app to handle
    }
  }

  /// Checks if the plugin is fully attached to an Android Activity and ready to show UI.
  static Future<bool> isActivityAttached() async {
    final bool? result = await _channel.invokeMethod<bool>('isActivityAttached');
    return result ?? false;
  }
}
