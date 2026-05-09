import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String _apiHost = "http://192.168.1.8/car_api";
  final String baseUrl = "$_apiHost/fetch_cars.php";
  final String loginUrl = "$_apiHost/login.php";
  final String sellerStatsUrl = "$_apiHost/get_seller_stats.php";

  bool _isLoginSuccess(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'success';
    }

    return false;
  }

  Future<List<Car>> getCars() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);

        return body.map((dynamic item) => Car.fromJson(item)).toList();
      } else {
        throw "Could not fetch data";
      }
    } catch (e) {
      // ignore: avoid_print
      print("API Error: $e");
      return [];
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: {
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      if (_isLoginSuccess(decoded['success'])) {
        return UserModel.fromJson(decoded);
      }

      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Login API Error: $e');
      return null;
    }
  }

  Future<List<double>> fetchWeeklyViews() async {
    final response = await http.get(
      Uri.parse("http://192.168.1.8/car_api/get_weekly_views.php"),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      // Convert the list of JSON objects into a list of numbers (y-axis values)
      return jsonList.map((item) => double.parse(item['total_views'])).toList();
    } else {
      return [0, 0, 0, 0, 0, 0, 0]; // Return empty chart if failed
    }
  }

  Future<Map<String, dynamic>> fetchSellerStats(int id) async {
    // 1. Double check the IP matches your current 192.168.1.8
    const String url = "http://192.168.1.8/car_api/get_seller_stats.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        // 2. CRITICAL: body must be a Map<String, String>
        body: {"seller_id": id.toString()},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print("API Error: $e");
      return {"success": false, "listings": []};
    }
  }

  Future<bool> sendInquiry({
    required int vehicleId,
    required int sellerId,
    required int buyerId,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.8/car_api/send_inquiry.php"),
        body: {
          "vehicle_id": vehicleId.toString(),
          "seller_id": sellerId.toString(),
          "buyer_id": buyerId.toString(),
          "message": message?.trim().isNotEmpty == true
              ? message!.trim()
              : "I am interested in this ${DateTime.now()}",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print("Inquiry Error: $e");
      return false;
    }
  }

  Future<List<Car>> getSellerCars(int sellerId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_apiHost/get_seller_cars.php?seller_id=$sellerId&user_id=$sellerId",
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Car.fromJson(item)).toList();
      } else {
        // ignore: avoid_print
        print('Seller cars HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // ignore: avoid_print
      print("Seller cars API Error: $e");
      return [];
    }
  }
}
