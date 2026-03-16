/// Backend API configuration.
///
/// For Android emulator: use http://10.0.2.2:3000
/// For iOS simulator: use http://localhost:3000
/// For physical device: use your machine's LAN IP (e.g. http://192.168.1.x:3000)
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  /// Paymob public key (from integration credentials). Used with client_secret
  /// from the backend when calling the official Paymob SDK. Can be overridden
  /// by session response if backend returns public_key.
  static const String paymobPublicKey = String.fromEnvironment(
    'PAYMOB_PUBLIC_KEY',
    defaultValue: '',
  );
}
