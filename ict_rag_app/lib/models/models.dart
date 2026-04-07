import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, oled }

class UserProfile {
  final String name;
  final String email;
  final double overallProgress;
  final int topicsCompleted;
  final int totalTopics;
  final int quizzesCompleted;
  final int totalQuizzes;
  final int badges;
  final int streakDays;
  final double studyHours;
  final String? yearOfStudy;
  final String? expectedDseGrade;
  final bool isGoogleUser;
  final String? photoUrl;
  final String? localPhotoPath;

  const UserProfile({
    required this.name,
    required this.email,
    this.overallProgress = 0.0,
    this.topicsCompleted = 0,
    this.totalTopics = 31,
    this.quizzesCompleted = 0,
    this.totalQuizzes = 4,
    this.badges = 0,
    this.streakDays = 0,
    this.studyHours = 0.0,
    this.yearOfStudy,
    this.expectedDseGrade,
    this.isGoogleUser = false,
    this.photoUrl,
    this.localPhotoPath,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    double? overallProgress,
    int? topicsCompleted,
    int? totalTopics,
    int? quizzesCompleted,
    int? totalQuizzes,
    int? badges,
    int? streakDays,
    double? studyHours,
    String? yearOfStudy,
    String? expectedDseGrade,
    bool? isGoogleUser,
    String? photoUrl,
    String? localPhotoPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      overallProgress: overallProgress ?? this.overallProgress,
      topicsCompleted: topicsCompleted ?? this.topicsCompleted,
      totalTopics: totalTopics ?? this.totalTopics,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      badges: badges ?? this.badges,
      streakDays: streakDays ?? this.streakDays,
      studyHours: studyHours ?? this.studyHours,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      expectedDseGrade: expectedDseGrade ?? this.expectedDseGrade,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'overallProgress': overallProgress,
    'topicsCompleted': topicsCompleted,
    'totalTopics': totalTopics,
    'quizzesCompleted': quizzesCompleted,
    'totalQuizzes': totalQuizzes,
    'badges': badges,
    'streakDays': streakDays,
    'studyHours': studyHours,
    'yearOfStudy': yearOfStudy,
    'expectedDseGrade': expectedDseGrade,
    'isGoogleUser': isGoogleUser,
    'photoUrl': photoUrl,
    'localPhotoPath': localPhotoPath,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'Student',
    email: json['email'] ?? '',
    overallProgress: (json['overallProgress'] ?? 0.0).toDouble(),
    topicsCompleted: json['topicsCompleted'] ?? 0,
    totalTopics: json['totalTopics'] ?? 31,
    quizzesCompleted: json['quizzesCompleted'] ?? 0,
    totalQuizzes: json['totalQuizzes'] ?? 4,
    badges: json['badges'] ?? 0,
    streakDays: json['streakDays'] ?? 0,
    studyHours: (json['studyHours'] ?? 0.0).toDouble(),
    yearOfStudy: json['yearOfStudy'],
    expectedDseGrade: json['expectedDseGrade'],
    isGoogleUser: json['isGoogleUser'] ?? false,
    photoUrl: json['photoUrl'],
    localPhotoPath: json['localPhotoPath'],
  );

  /// Derive difficulty level from year of study and expected grade
  String get derivedDifficulty {
    if (yearOfStudy == 'S6') return 'advanced';
    if (yearOfStudy == 'S5') return 'intermediate';
    if (yearOfStudy == 'S4') return 'beginner';
    // Fallback to expected grade
    if (expectedDseGrade != null) {
      if (['5**', '5*', '5'].contains(expectedDseGrade)) return 'advanced';
      if (['4', '3'].contains(expectedDseGrade)) return 'intermediate';
      return 'beginner';
    }
    return 'intermediate';
  }
}

class Module {
  final String id;
  final String title;
  final List<Topic> topics;
  final bool isRequired;
  final bool isElective;
  final String category;

  const Module({
    required this.id,
    required this.title,
    required this.topics,
    this.isRequired = false,
    this.isElective = false,
    required this.category,
  });

  int get completedTopics => topics.where((t) => t.isCompleted).length;
  double get progress => topics.isEmpty ? 0.0 : completedTopics / topics.length;
}

class Topic {
  final String id;
  final String title;
  final String content;
  final int readMinutes;
  bool isCompleted;

  Topic({
    required this.id,
    required this.title,
    this.content = '',
    this.readMinutes = 20,
    this.isCompleted = false,
  });
}

class Quiz {
  final String id;
  final String title;
  final String moduleId;
  int questionCount;
  final int estimatedMinutes;
  final bool isRecommended;
  double? bestScore;

  Quiz({
    required this.id,
    required this.title,
    required this.moduleId,
    this.questionCount = 5,
    this.estimatedMinutes = 10,
    this.isRecommended = false,
    this.bestScore,
  });
}

class QuizQuestion {
  final String question;
  final Map<String, String> options;
  final String answer;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: Map<String, String>.from(json['options'] ?? {}),
      answer: json['answer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'answer': answer,
    'explanation': explanation,
  };
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? keyPoints;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.keyPoints,
  });
}

class QuizAttempt {
  final String quizTitle;
  final String? quizId;
  final double score;
  final DateTime date;
  final int attempts;
  final List<QuizQuestion>? questions;
  final List<String>? userAnswers;

  const QuizAttempt({
    required this.quizTitle,
    this.quizId,
    required this.score,
    required this.date,
    required this.attempts,
    this.questions,
    this.userAnswers,
  });

  Map<String, dynamic> toJson() => {
    'quizTitle': quizTitle,
    'quizId': quizId,
    'score': score,
    'date': date.toIso8601String(),
    'attempts': attempts,
    'questions': questions?.map((q) => q.toJson()).toList(),
    'userAnswers': userAnswers,
  };

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
    quizTitle: json['quizTitle'] ?? '',
    quizId: json['quizId'],
    score: (json['score'] ?? 0.0).toDouble(),
    date: DateTime.parse(json['date']),
    attempts: json['attempts'] ?? 1,
    questions: json['questions'] != null
        ? (json['questions'] as List).map((q) => QuizQuestion.fromJson(q)).toList()
        : null,
    userAnswers: json['userAnswers'] != null
        ? List<String>.from(json['userAnswers'])
        : null,
  );
}

/// Module icon and color helpers
class ModuleHelper {
  static IconData getIcon(String moduleId) {
    switch (moduleId) {
      case 'comp_networks': return Icons.hub_rounded;
      case 'programming': return Icons.code_rounded;
      case 'database': return Icons.storage_rounded;
      case 'info_processing': return Icons.analytics_rounded;
      case 'computer_system': return Icons.memory_rounded;
      case 'elective_database': return Icons.table_chart_rounded;
      case 'elective_web': return Icons.web_rounded;
      case 'elective_algorithm': return Icons.functions_rounded;
      default: return Icons.book_rounded;
    }
  }

  static Color getColor(String moduleId) {
    switch (moduleId) {
      case 'comp_networks': return const Color(0xFF4FC3F7);
      case 'programming': return const Color(0xFF00D4AA);
      case 'database': return const Color(0xFF6C63FF);
      case 'info_processing': return const Color(0xFFFFAB40);
      case 'computer_system': return const Color(0xFFFF6B9D);
      case 'elective_database': return const Color(0xFF6C63FF);
      case 'elective_web': return const Color(0xFF4FC3F7);
      case 'elective_algorithm': return const Color(0xFF00D4AA);
      default: return const Color(0xFF6C63FF);
    }
  }
}
