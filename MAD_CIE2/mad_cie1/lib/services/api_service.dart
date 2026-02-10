import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  // For Web use localhost, for Android emulator use 10.0.2.2
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return 'http://10.0.2.2:5000/api';
  }

  // ── Login ──
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // ── Sign Up ──
  static Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String mobile,
    required String dob,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'mobile': mobile,
        'dob': dob,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // ── Forgot Password ──
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  // ── Add Transaction ──
  static Future<Map<String, dynamic>> addTransaction({
    required String userId,
    required String category,
    required String title,
    required double amount,
    required String type,
    String note = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'category': category,
        'title': title,
        'amount': amount,
        'type': type,
        'note': note,
      }),
    );
    return jsonDecode(response.body);
  }

  // ── Get Transactions ──
  static Future<Map<String, dynamic>> getTransactions(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // ── Get Category Summary ──
  static Future<Map<String, dynamic>> getCategorySummary(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/summary/$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // ── Delete Transaction ──
  static Future<Map<String, dynamic>> deleteTransaction(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }
}
