import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';
import '../models/inquiry_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String _apiHost = "http://192.168.1.6/car_api";
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
      Uri.parse("$_apiHost/get_weekly_views.php"),
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
    // 1. Double check the IP matches your current 192.168.1.6
    const String url = "http://192.168.1.6/car_api/get_seller_stats.php";

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
        Uri.parse("$_apiHost/send_inquiry.php"),
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

  Future<List<Message>> fetchMessages(int inquiryId) async {
    try {
      final response = await http.get(
        Uri.parse("$_apiHost/get_messages.php?inquiry_id=$inquiryId"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((item) => Message.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch messages error: $e');
    }

    return [];
  }

  Future<bool> sendMessage({
    required int inquiryId,
    required int senderId,
    required String messageText,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_apiHost/send_message.php"),
        body: {
          'inquiry_id': inquiryId.toString(),
          'sender_id': senderId.toString(),
          'message_text': messageText,
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['success'] == true;
      }

      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Send message error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchInquiriesForSeller(
    int sellerId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$_apiHost/get_inquiries.php?seller_id=$sellerId"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch inquiries error: $e');
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> fetchInquiriesForBuyer(int buyerId) async {
    try {
      final response = await http.get(
        Uri.parse("$_apiHost/get_inquiries.php?buyer_id=$buyerId"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch buyer inquiries error: $e');
    }

    return [];
  }

  Future<bool> replyToInquiry({
    required int inquiryId,
    required String reply,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_apiHost/reply_inquiry.php"),
        body: {'inquiry_id': inquiryId.toString(), 'reply': reply},
      );

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['success'] == true;
      }

      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Reply inquiry error: $e');
      return false;
    }
  }

  Future<List<Inquiry>> fetchInquiries(int sellerId) async {
    try {
      final response = await http.post(
        Uri.parse("$_apiHost/get_seller_inquiries.php"),
        body: {'seller_id': sellerId.toString()},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          return (decoded['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => Inquiry.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch inquiries error: $e');
    }

    return [];
  }

  Future<List<Inquiry>> fetchBuyerInquiries(int buyerId) async {
    try {
      final response = await http.post(
        Uri.parse("$_apiHost/get_buyer_inquiries.php"),
        body: {'buyer_id': buyerId.toString()},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          return (decoded['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => Inquiry.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch buyer inquiries error: $e');
    }

    return [];
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

  Future<Inquiry?> getInquiryDetails(int inquiryId) async {
    try {
      final response = await http.get(
        Uri.parse("$_apiHost/get_inquiry_details.php?inquiry_id=$inquiryId"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return Inquiry.fromJson(decoded);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch inquiry details error: $e');
    }

    return null;
  }

  Future<Car?> getCarById(int vehicleId) async {
    try {
      final response = await http.get(
        Uri.parse("$_apiHost/get_car_by_id.php?vehicle_id=$vehicleId"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return Car.fromJson(decoded);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Fetch car by ID error: $e');
    }

    return null;
  }
}
