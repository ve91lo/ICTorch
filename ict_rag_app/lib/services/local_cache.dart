import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCache {
  static const _notesPrefix = 'cached_notes_';
  static const _quizPrefix = 'cached_quiz_';
  static const _quizResultsKey = 'quiz_results_history';

  // Notes caching
  static Future<void> saveNotes(String topicId, Map<String, dynamic> notes) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('$_notesPrefix$topicId', jsonEncode(notes));
  }

  static Future<Map<String, dynamic>?> getNotes(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_notesPrefix$topicId');
    if (data != null) return jsonDecode(data) as Map<String, dynamic>;
    return null;
  }

  // Quiz results caching
  static Future<void> saveQuizResult(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_quizResultsKey) ?? [];
    existing.insert(0, jsonEncode(result));
    if (existing.length > 50) existing.removeLast();
    prefs.setStringList(_quizResultsKey, existing);
  }

  static Future<List<Map<String, dynamic>>> getQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_quizResultsKey) ?? [];
    return existing.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  // Quiz questions caching
  static Future<void> saveQuizQuestions(String quizId, List<Map<String, dynamic>> questions) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('$_quizPrefix$quizId', jsonEncode(questions));
  }

  static Future<List<Map<String, dynamic>>?> getQuizQuestions(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_quizPrefix$quizId');
    if (data != null) {
      return (jsonDecode(data) as List).cast<Map<String, dynamic>>();
    }
    return null;
  }
}
