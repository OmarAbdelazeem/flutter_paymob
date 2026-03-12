/// Backend API configuration.
///
/// For Android emulator: use http://10.0.2.2:3000
/// For iOS simulator: use http://localhost:3000
/// For physical device: use your machine's LAN IP (e.g. http://192.168.1.x:3000)
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
