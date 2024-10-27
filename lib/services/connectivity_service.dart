/// A service that provides connectivity status and internet availability checks.
///
/// The `ConnectivityService` class uses the `connectivity_plus` package to monitor
/// connectivity changes and the `http` package to verify internet access.
///
/// This service is implemented as a singleton, accessible via the `instance` field.
///
/// Example usage:
/// ```dart
/// final connectivityService = ConnectivityService.instance;
/// final isConnected = await connectivityService.checkConnectivity();
/// ```
///
/// Methods:
/// - `Stream<bool> get onConnectedChanged`: A stream that emits a boolean value
///   indicating whether the device is connected to the internet.
/// - `Future<bool> checkConnectivity()`: Checks the current connectivity status
///   and verifies internet access.
/// - `Future<bool> _checkInternet()`: A private method that attempts to make an
///   HTTP GET request to verify internet access.
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._init();
  final Connectivity _connectivity = Connectivity();

  ConnectivityService._init();

  Stream<bool> get onConnectedChanged =>
      _connectivity.onConnectivityChanged.asyncMap((result) async {
        if (result == ConnectivityResult.none) {
          return false;
        }
        final hasInternet = await _checkInternet();
        return hasInternet;
      });

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      }

      final hasInternet = await _checkInternet();
      return hasInternet;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'),
          )
          .timeout(
            const Duration(seconds: 5),
          );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
