/// A service that provides connectivity status and internet availability checks.
///
/// The `ConnectivityService` class uses the `connectivity_plus` package to monitor
/// connectivity changes and the `http` package to verify internet access.
///
/// This service is implemented as a GetX service, accessible via dependency injection.
///
/// Example usage:
/// ```dart
/// final connectivityService = Get.find<ConnectivityService>();
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
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_explorer/constants/service_constants.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onConnectedChanged =>
      _connectivity.onConnectivityChanged.asyncMap((results) async {
        if (results.contains(ConnectivityResult.none) || results.isEmpty) {
          return false;
        }
        final hasInternet = await _checkInternet();
        return hasInternet;
      });

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none) || results.isEmpty) {
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
            Uri.parse(ApiConstants.baseUrl + ApiConstants.randomMealEndpoint),
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
