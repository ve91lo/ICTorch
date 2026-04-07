import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Local-first persistence service using SharedPreferences.
/// All data is stored locally. For Google users, data is also synced to Supabase.
class PersistenceService {
  static const _keyUser = 'user_profile';
  static const _keySetupComplete = 'setup_complete';
  static const _keyThemeMode = 'theme_mode';
  static const _keySelectedElective = 'selected_elective';
  static const _keyCompletedTopics = 'completed_topics';
  static const _keyQuizAttempts = 'quiz_attempts_v2';
  static const _keyNotifications = 'notification_settings';
  static const _keyProfilePhoto = 'local_profile_photo';

  // --- Setup ---
  static Future<bool> isSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySetupComplete) ?? false;
  }

  static Future<void> markSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySetupComplete, true);
  }

  // --- User Profile ---
  static Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Future<UserProfile?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data != null) {
      return UserProfile.fromJson(jsonDecode(data));
    }
    return null;
  }

  // --- Theme ---
  static Future<void> saveThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  static Future<AppThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyThemeMode);
    if (name != null) {
      return AppThemeMode.values.firstWhere((m) => m.name == name, orElse: () => AppThemeMode.dark);
    }
    return AppThemeMode.dark;
  }

  // --- Selected Elective ---
  static Future<void> saveSelectedElective(String? moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    if (moduleId != null) {
      await prefs.setString(_keySelectedElective, moduleId);
    } else {
      await prefs.remove(_keySelectedElective);
    }
  }

  static Future<String?> loadSelectedElective() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedElective);
  }

  // --- Completed Topics ---
  static Future<void> saveCompletedTopics(List<String> topicIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompletedTopics, topicIds);
  }

  static Future<List<String>> loadCompletedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompletedTopics) ?? [];
  }

  // --- Quiz Attempts (with full Q&A) ---
  static Future<void> saveQuizAttempts(List<QuizAttempt> attempts) async {
    final prefs = await SharedPreferences.getInstance();
    final data = attempts.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_keyQuizAttempts, data);
  }

  static Future<List<QuizAttempt>> loadQuizAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_keyQuizAttempts) ?? [];
    return data.map((e) => QuizAttempt.fromJson(jsonDecode(e))).toList();
  }

  // --- Notification Settings ---
  static Future<void> saveNotifications(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotifications, jsonEncode(settings));
  }

  static Future<Map<String, bool>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyNotifications);
    if (data != null) {
      return Map<String, bool>.from(jsonDecode(data));
    }
    return {};
  }

  // --- Profile Photo ---
  static Future<void> saveProfilePhotoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfilePhoto, path);
  }

  static Future<String?> loadProfilePhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfilePhoto);
  }

  // --- Clear All ---
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
