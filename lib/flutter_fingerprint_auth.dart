import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_fingerprint_auth/flutter_fingerprint_auth_platform_interface.dart';

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
  } on PlatformException catch (e) { // <-- L'exception 'e' est maintenant utilisée
    // Ici, on ré-lance l'exception pour qu'elle puisse être traitée par l'appelant
    // C'est ce que votre code fait déjà, donc l'avertissement est bizarre si vous n'avez pas de 'print'
    // Mais si vous avez un 'print' commenté, le linter peut le voir comme inutilisé
    // Décommenter ou ajouter un print pour montrer l'utilisation
    print("Authentication error in plugin: ${e.code} - ${e.message}"); // Exemple d'utilisation
    rethrow; // Re-throw the exception for the calling app to handle
  }
}

  /// Checks if the plugin is fully attached to an Android Activity and ready to show UI.
  static Future<bool> isActivityAttached() async {
    final bool? result = await _channel.invokeMethod<bool>('isActivityAttached');
    return result ?? false;
  }

  Future<String?> getPlatformVersion() {
    return FingerprintAuthPlatform.instance.getPlatformVersion();
  }
}
