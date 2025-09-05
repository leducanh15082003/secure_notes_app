import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class NoteService {
  static const String baseUrl = "http://10.0.2.2:8080/api/notes";

  static Future<List<Map<String, dynamic>>> fetchNotes() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load notes');
  }

  static Future<bool> createNote(String title, String content) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> updateNote(int id, String title, String content) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteNote(int id) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
}
