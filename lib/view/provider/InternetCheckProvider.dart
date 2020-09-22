import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

enum InternetConnectivityStatus {
  notConnected,
  noWirelessConnection,
  connected
}

class InternetCheckProvider {
  Future<bool> get isInternetAvailable async {
    final result = await http.get("https://www.example.com");
    return result.statusCode == 200;
  }
}
