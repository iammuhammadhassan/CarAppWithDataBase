import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';

class ApiService {
  // Use your laptop's IP address
  final String baseUrl = "http://192.168.1.11/car_api/fetch_cars.php";

  Future<List<Car>> getCars() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        // Map the JSON list to a List of Car objects
        return body.map((dynamic item) => Car.fromJson(item)).toList();
      } else {
        throw "Could not fetch data";
      }
    } catch (e) {
      // ignore: avoid_print
      print("API Error: $e");
      return []; // Return empty list if server is off
    }
  }
}