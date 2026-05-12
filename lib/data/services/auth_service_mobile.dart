import 'package:local_auth/local_auth.dart';

class AuthService {
  AuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<bool> isDeviceLockAvailable() async {
    try {
      return _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return _localAuth.authenticate(
        localizedReason: 'Unlock Blooom to view your private health data.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
