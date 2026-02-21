import 'dart:developer' as developer;
import 'package:chronoflow/core/constants.dart';
import 'package:freerasp/freerasp.dart';

class RaspService {
  static Future<void> initialize() async {
    final config = TalsecConfig(
      watcherMail: Constants.raspWatcherEmail,
      killOnBypass: true,
    );

    final callback = ThreatCallback(
      onAppIntegrity: () => _handleThreat('App integrity'),
      onObfuscationIssues: () => _handleThreat('Obfuscation issues'),
      onDebug: () => _handleThreat('Debugging'),
      onDeviceBinding: () => _handleThreat('Device binding'),
      onDeviceID: () => _handleThreat('Device ID'),
      onHooks: () => _handleThreat('Hooks'),
      onPasscode: () => _handleThreat('Passcode not set'),
      onPrivilegedAccess: () => _handleThreat('Privileged access'),
      onSecureHardwareNotAvailable: () => _handleThreat('Secure hardware not available'),
      onSimulator: () => _handleThreat('Simulator'),
      onSystemVPN: () => _handleThreat('System VPN'),
      onDevMode: () => _handleThreat('Developer mode'),
      onADBEnabled: () => _handleThreat('USB debugging enabled'),
      onUnofficialStore: () => _handleThreat('Unofficial store'),
      onScreenshot: () => _handleThreat('Screenshot'),
      onScreenRecording: () => _handleThreat('Screen recording'),
      onMultiInstance: () => _handleThreat('Multi instance'),
      onUnsecureWiFi: () => _handleThreat('Unsecure wifi'),
      onLocationSpoofing: () => _handleThreat('Location spoofing'),
      onTimeSpoofing: () => _handleThreat('Time spoofing'),
      onAutomation: () => _handleThreat('Automation detected'),
      onMalware: (suspiciousApps) => _handleThreat('Suspicious apps', suspiciousApps),
    );

    await Talsec.instance.attachListener(callback);
    await Talsec.instance.start(config);
  }

  static void _handleThreat(String threatType, [Object? details]) {
    final message = details != null ? '$threatType: $details' : threatType;
    developer.log(
      'Security Threat Detected: $message',
      name: 'Security.RASP',
      level: 1000,
    );
  }
}
