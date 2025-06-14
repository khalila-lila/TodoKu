import 'dart:convert';
import 'package:http/http.dart' as http;
import 'task.dart';

class ApiService {
  // Ubah baseUrl ke 127.0.0.1
  static const String baseUrl = 'http://127.0.0.1:8000/api/tasks';

  static Future<List<TaskModel>> getTasks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => TaskModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<bool> addTask(TaskModel task) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateTask(TaskModel task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteTask(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}