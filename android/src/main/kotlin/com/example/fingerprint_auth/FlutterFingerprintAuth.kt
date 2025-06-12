package com.example.fingerprint_auth

import android.content.Context
import androidx.annotation.NonNull // <-- ADD THIS IMPORT
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executor
import java.util.concurrent.Executors // <-- ADD THIS IMPORT

/** FingerprintAuthPlugin */
class FingerprintAuthPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  /// The MethodChannel that will interact with Flutter.
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
    private lateinit var context: Context
      private var currentActivity: FragmentActivity? = null
        private lateinit var executor: Executor

          override fun onAttachedToEngine(
            @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
          ) {
            channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fingerprint_auth")
            channel.setMethodCallHandler(this)
            context = flutterPluginBinding.applicationContext
            executor = Executors.newSingleThreadExecutor()
          }

          override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
            when (call.method) {
              "authenticate" -> authenticate(call, result)
              "canAuthenticate" -> canAuthenticate(result)
              "isActivityAttached" -> result.success(currentActivity != null) // AJOUTEZ CETTE LIGNE
              else -> result.notImplemented()
            }
          }

          private fun canAuthenticate(@NonNull result: Result) {
            val biometricManager = BiometricManager.from(context)
            when (biometricManager.canAuthenticate(
              BiometricManager.Authenticators.BIOMETRIC_WEAK or
              BiometricManager.Authenticators.BIOMETRIC_STRONG
            )
            ) {
              BiometricManager.BIOMETRIC_SUCCESS -> result.success(true)
              BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE,
              BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE,
              BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> result.success(false)
              else -> result.success(false)
            }
          }

          private fun authenticate(call: MethodCall, @NonNull result: Result) {
            if (currentActivity == null) {
              result.error("NO_ACTIVITY", "Plugin not attached to an Activity.", null)
              return
            }

            val title = call.argument<String>("title") ?: "Authentication Required"
            val subtitle = call.argument<String>("subtitle") ?: ""
            val negativeButtonText = call.argument<String>("negativeButtonText") ?: "Use Password"

            val promptInfo =
            BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(subtitle)
            .setNegativeButtonText(negativeButtonText)
            .setAllowedAuthenticators(
              BiometricManager.Authenticators.BIOMETRIC_WEAK or
              BiometricManager.Authenticators.BIOMETRIC_STRONG
            )
            .build()

            val biometricPrompt =
            BiometricPrompt(
              currentActivity!!,
              executor,
              object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                  super.onAuthenticationError(errorCode, errString)
                  // Callbacks are on the main thread, but result.error needs to be on
                  // platform thread
                  // To ensure thread safety, call result.error on the main thread
                  currentActivity!!.runOnUiThread {
                    result.error("AUTH_ERROR", errString.toString(), errorCode)
                  }
                }

                override fun onAuthenticationSucceeded(
                  authResult: BiometricPrompt.AuthenticationResult
                ) {
                  super.onAuthenticationSucceeded(authResult)
                  currentActivity!!.runOnUiThread { result.success(true) }
                }

                override fun onAuthenticationFailed() {
                  super.onAuthenticationFailed()
                  // This is called when the biometric sensor doesn't recognize the input.
                  // It doesn't necessarily mean an error, just a failed attempt.
                  // We can choose to send false or a specific error code.
                  currentActivity!!.runOnUiThread {
                    result.success(false) // Indicate a failed attempt
                  }
                }
              }
            )

            biometricPrompt.authenticate(promptInfo)
          }

          override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
            channel.setMethodCallHandler(null)
          }

          // ActivityAware interface methods
          override fun onAttachedToActivity(binding: ActivityPluginBinding) {
            currentActivity = binding.activity as FragmentActivity
          }

          override fun onDetachedFromActivityForConfigChanges() {
            currentActivity = null
          }

          override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
            currentActivity = binding.activity as FragmentActivity
          }

          override fun onDetachedFromActivity() {
            currentActivity = null
          }
}
