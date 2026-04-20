import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';
import '../models/user_model.dart';

class ApiService {
  final String baseUrl = "http://192.168.1.9/car_api/fetch_cars.php";
  final String loginUrl = "http://192.168.1.9/car_api/login.php";

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
        body: {'email': email, 'password': password},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true) {
        return UserModel.fromJson(body);
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
      Uri.parse("http://192.168.1.9/car_api/get_weekly_views.php"),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      // Convert the list of JSON objects into a list of numbers (y-axis values)
      return jsonList.map((item) => double.parse(item['total_views'])).toList();
    } else {
      return [0, 0, 0, 0, 0, 0, 0]; // Return empty chart if failed
    }
  }
}
