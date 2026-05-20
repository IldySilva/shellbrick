import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialStorage {
  static const _opts = MacOsOptions(
    accessibility: KeychainAccessibility.unlocked,
  );

  static const _storage = FlutterSecureStorage(mOptions: _opts);

  static String _passwordKey(String hostId) =>
      'shellbrick.host.$hostId.password';

  static String _passphraseKey(String hostId) =>
      'shellbrick.host.$hostId.passphrase';

  Future<String?> loadPassword(String hostId) =>
      _storage.read(key: _passwordKey(hostId), mOptions: _opts);

  Future<void> savePassword(String hostId, String password) =>
      _storage.write(
        key: _passwordKey(hostId),
        value: password,
        mOptions: _opts,
      );

  Future<String?> loadPassphrase(String hostId) =>
      _storage.read(key: _passphraseKey(hostId), mOptions: _opts);

  Future<void> savePassphrase(String hostId, String passphrase) =>
      _storage.write(
        key: _passphraseKey(hostId),
        value: passphrase,
        mOptions: _opts,
      );

  Future<void> deleteCredentials(String hostId) async {
    await _storage.delete(key: _passwordKey(hostId), mOptions: _opts);
    await _storage.delete(key: _passphraseKey(hostId), mOptions: _opts);
  }
}
