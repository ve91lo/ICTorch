import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://your-ict-rag.fly.dev';

  Future<String> chatQuery(String question, String level) async {
    final res = await http.post(
      Uri.parse('$baseUrl/query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'user_level': level,
        'response_type': 'chat',
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['answer'] ?? '';
    }
    throw Exception('API error: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> notesQuery(String question, String level) async {
    final res = await http.post(
      Uri.parse('$baseUrl/query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'user_level': level,
        'response_type': 'notes',
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final answer = data['answer'];
      if (answer is Map<String, dynamic>) return answer;
      return jsonDecode(answer);
    }
    throw Exception('API error: ${res.statusCode}');
  }

  Future<QuizQuestion> quizQuery(String topic, String level) async {
    final res = await http.post(
      Uri.parse('$baseUrl/query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': 'Generate a multiple choice quiz question about: $topic',
        'user_level': level,
        'response_type': 'quiz',
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final answer = data['answer'];
      if (answer is Map<String, dynamic>) {
        return QuizQuestion.fromJson(answer);
      }
      return QuizQuestion.fromJson(jsonDecode(answer));
    }
    throw Exception('API error: ${res.statusCode}');
  }

  Future<bool> healthCheck() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['status'] == 'ready';
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
