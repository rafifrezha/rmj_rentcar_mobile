import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/car.dart';
import '../models/rental.dart';

class ApiService {
  static String baseUrl =
      "https://rmjrentcar-86067911510.asia-southeast2.run.app";
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';

  // Login
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    print('Login response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['accessToken'] ?? data['token'];
      final user = data['user'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        if (user != null) {
          await prefs.setString(userKey, jsonEncode(user));
        }
        return {
          'token': token,
          'user': user != null ? User.fromJson(user) : null,
          'success': true,
        };
      } else {
        throw Exception('Invalid login response: missing token');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  // Register
  static Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return response.statusCode == 201;
  }

  // Get Cars
  static Future<List<Car>> getCars() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cars'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Car.fromJson(json)).toList();
    }
    return [];
  }

  // Create Rental
  static Future<bool> createRental(Rental rental) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    final response = await http.post(
      Uri.parse('$baseUrl/rentals/create'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(rental.toJson()),
    );
    print('Create rental response: ${response.statusCode} ${response.body}');
    // Tambahkan pengecekan error
    if (response.statusCode == 201) {
      return true;
    } else {
      // Coba tampilkan pesan error jika ada
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal membuat rental');
      } catch (_) {
        throw Exception('Gagal membuat rental');
      }
    }
  }

  // Get Rentals
  static Future<List<Rental>> getRentals(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    final response = await http.get(
      Uri.parse('$baseUrl/rentals?user_id=$userId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Rental.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Rental>> getRentalsForCar(int carId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    final response = await http.get(
      Uri.parse('$baseUrl/rentals'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Rental.fromJson(json))
          .where((r) => r.carId == carId)
          .toList();
    }
    return [];
  }

  static Future<bool> updateRentalStatus(int rentalId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    final response = await http.put(
      Uri.parse('$baseUrl/rentals/update/$rentalId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }

  // Batalkan sewa (delete rental dari database)
  static Future<bool> deleteRental(int rentalId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/rentals/delete/$rentalId',
      ), // sesuaikan dengan route backend
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
}
