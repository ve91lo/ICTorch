import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Supabase cloud sync service — only active for Google sign-in users.
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  static bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  // --- User ---
  static Future<void> upsertUser(UserProfile user, String googleId) async {
    if (!isInitialized) return;
    await _client.from('users').upsert({
      'google_id': googleId,
      'name': user.name,
      'email': user.email,
      'year_of_study': user.yearOfStudy,
      'expected_dse_grade': user.expectedDseGrade,
      'photo_url': user.photoUrl,
      'selected_elective': null,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'google_id');
  }

  static Future<Map<String, dynamic>?> fetchUser(String googleId) async {
    if (!isInitialized) return null;
    final response = await _client
        .from('users')
        .select()
        .eq('google_id', googleId)
        .maybeSingle();
    return response;
  }

  // --- Topic Progress ---
  static Future<void> syncTopicProgress(String userId, List<String> completedTopicIds) async {
    if (!isInitialized) return;
    final rows = completedTopicIds.map((topicId) => {
      'user_id': userId,
      'topic_id': topicId,
      'completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    }).toList();

    if (rows.isNotEmpty) {
      await _client.from('topic_progress').upsert(rows, onConflict: 'user_id,topic_id');
    }
  }

  static Future<List<String>> fetchCompletedTopics(String userId) async {
    if (!isInitialized) return [];
    final response = await _client
        .from('topic_progress')
        .select('topic_id')
        .eq('user_id', userId)
        .eq('completed', true);
    return (response as List).map((r) => r['topic_id'] as String).toList();
  }

  // --- Quiz Attempts ---
  static Future<void> syncQuizAttempt(String userId, QuizAttempt attempt) async {
    if (!isInitialized) return;
    await _client.from('quiz_attempts').insert({
      'user_id': userId,
      'quiz_id': attempt.quizId,
      'quiz_title': attempt.quizTitle,
      'score': attempt.score,
      'questions': attempt.questions?.map((q) => q.toJson()).toList(),
      'answers': attempt.userAnswers,
      'completed_at': attempt.date.toIso8601String(),
    });
  }

  static Future<List<QuizAttempt>> fetchQuizAttempts(String userId) async {
    if (!isInitialized) return [];
    final response = await _client
        .from('quiz_attempts')
        .select()
        .eq('user_id', userId)
        .order('completed_at', ascending: false);
    return (response as List).map((r) => QuizAttempt(
      quizTitle: r['quiz_title'] ?? '',
      quizId: r['quiz_id'],
      score: (r['score'] ?? 0.0).toDouble(),
      date: DateTime.parse(r['completed_at']),
      attempts: 1,
      questions: r['questions'] != null
          ? (r['questions'] as List).map((q) => QuizQuestion.fromJson(q)).toList()
          : null,
      userAnswers: r['answers'] != null ? List<String>.from(r['answers']) : null,
    )).toList();
  }

  // --- Selected Elective ---
  static Future<void> updateSelectedElective(String userId, String? electiveId) async {
    if (!isInitialized) return;
    await _client.from('users').update({
      'selected_elective': electiveId,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
