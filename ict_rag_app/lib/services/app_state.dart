import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'persistence_service.dart';
import 'supabase_service.dart';

class AppState extends ChangeNotifier {
  UserProfile _user = const UserProfile(
    name: 'Student',
    email: 'student@school.edu',
  );

  bool _isLoggedIn = false;
  AppThemeMode _themeMode = AppThemeMode.dark;
  String? _selectedElectiveId;
  String? _googleId;
  String? _supabaseUserId;

  // Quiz size mode: true = byte-sized (5 questions), false = big ones
  bool _byteSizedQuiz = true;

  // Notification settings
  bool _notifyStudyReminders = true;
  bool _notifyQuizResults = true;
  bool _notifyNewContent = true;
  bool _notifyStreakReminders = true;
  bool _notifyWeeklyReport = false;

  // ---------- Compulsory Modules ----------
  final List<Module> _compulsoryModules = [
    Module(
      id: 'comp_networks',
      title: 'Internet and Communications',
      category: 'compulsory',
      isRequired: true,
      topics: [
        Topic(id: 'cn1', title: 'Networking and Internet Basics', readMinutes: 20),
        Topic(id: 'cn2', title: 'Internet Services and Applications', readMinutes: 25),
        Topic(id: 'cn3', title: 'Network Protocols', readMinutes: 20),
        Topic(id: 'cn4', title: 'Network Security', readMinutes: 25),
        Topic(id: 'cn5', title: 'IP Addressing and Subnetting', readMinutes: 30),
        Topic(id: 'cn6', title: 'Network Topologies', readMinutes: 15),
        Topic(id: 'cn7', title: 'Wireless Networking', readMinutes: 20),
        Topic(id: 'cn8', title: 'Cloud Computing', readMinutes: 25),
      ],
    ),
    Module(
      id: 'programming',
      title: 'Programming Fundamentals',
      category: 'compulsory',
      isRequired: true,
      topics: [
        Topic(id: 'pf1', title: 'Introduction to Programming', readMinutes: 20),
        Topic(id: 'pf2', title: 'Variables and Data Types', readMinutes: 20),
        Topic(id: 'pf3', title: 'Control Structures', readMinutes: 25),
        Topic(id: 'pf4', title: 'Functions and Procedures', readMinutes: 25),
        Topic(id: 'pf5', title: 'Arrays and Strings', readMinutes: 25),
        Topic(id: 'pf6', title: 'File Handling', readMinutes: 20),
        Topic(id: 'pf7', title: 'Algorithm Design', readMinutes: 30),
        Topic(id: 'pf8', title: 'Sorting and Searching', readMinutes: 30),
        Topic(id: 'pf9', title: 'Pseudocode and Flowcharts', readMinutes: 20),
        Topic(id: 'pf10', title: 'Debugging and Testing', readMinutes: 20),
      ],
    ),
    Module(
      id: 'database',
      title: 'Database Systems',
      category: 'compulsory',
      isRequired: true,
      topics: [
        Topic(id: 'db1', title: 'Introduction to Databases', readMinutes: 15),
        Topic(id: 'db2', title: 'Relational Database Design', readMinutes: 25),
        Topic(id: 'db3', title: 'SQL Basics', readMinutes: 25),
        Topic(id: 'db4', title: 'Data Normalization', readMinutes: 30),
        Topic(id: 'db5', title: 'Database Management', readMinutes: 20),
        Topic(id: 'db6', title: 'Data Integrity and Security', readMinutes: 20),
      ],
    ),
    Module(
      id: 'info_processing',
      title: 'Information Processing',
      category: 'compulsory',
      isRequired: true,
      topics: [
        Topic(id: 'ip1', title: 'Introduction to Information Processing', readMinutes: 15),
        Topic(id: 'ip2', title: 'Data Representation', readMinutes: 25),
        Topic(id: 'ip3', title: 'Data Manipulation and Analysis', readMinutes: 25),
        Topic(id: 'ip4', title: 'Office Automation', readMinutes: 20),
      ],
    ),
    Module(
      id: 'computer_system',
      title: 'Computer Systems',
      category: 'compulsory',
      isRequired: true,
      topics: [
        Topic(id: 'cs1', title: 'Basic Machine Organisation', readMinutes: 25),
        Topic(id: 'cs2', title: 'System Software', readMinutes: 20),
        Topic(id: 'cs3', title: 'Computer Hardware', readMinutes: 20),
      ],
    ),
  ];

  // ---------- Elective Modules (matching database categories) ----------
  final List<Module> _electiveModules = [
    Module(
      id: 'elective_database',
      title: 'Database',
      category: 'elective',
      isElective: true,
      topics: [
        Topic(id: 'edb1', title: 'Relational Database Concepts', readMinutes: 25),
        Topic(id: 'edb2', title: 'Entity-Relationship Modelling', readMinutes: 30),
        Topic(id: 'edb3', title: 'Advanced SQL Queries', readMinutes: 30),
        Topic(id: 'edb4', title: 'Database Normalisation (1NF–3NF)', readMinutes: 25),
        Topic(id: 'edb5', title: 'Database Administration', readMinutes: 20),
        Topic(id: 'edb6', title: 'Data Dictionary and Integrity', readMinutes: 20),
        Topic(id: 'edb7', title: 'Indexing and Query Optimisation', readMinutes: 25),
        Topic(id: 'edb8', title: 'Database Security and Backup', readMinutes: 20),
      ],
    ),
    Module(
      id: 'elective_web',
      title: 'Web Application',
      category: 'elective',
      isElective: true,
      topics: [
        Topic(id: 'ew1', title: 'Web Development Fundamentals', readMinutes: 20),
        Topic(id: 'ew2', title: 'HTML and CSS', readMinutes: 25),
        Topic(id: 'ew3', title: 'Client-Side Scripting (JavaScript)', readMinutes: 30),
        Topic(id: 'ew4', title: 'Server-Side Programming', readMinutes: 30),
        Topic(id: 'ew5', title: 'Web Application Architecture', readMinutes: 25),
        Topic(id: 'ew6', title: 'Web Security', readMinutes: 20),
        Topic(id: 'ew7', title: 'Responsive Web Design', readMinutes: 20),
        Topic(id: 'ew8', title: 'Web APIs and Services', readMinutes: 25),
      ],
    ),
    Module(
      id: 'elective_algorithm',
      title: 'Algorithm and Programming',
      category: 'elective',
      isElective: true,
      topics: [
        Topic(id: 'ea1', title: 'Advanced Algorithm Design', readMinutes: 30),
        Topic(id: 'ea2', title: 'Recursion', readMinutes: 25),
        Topic(id: 'ea3', title: 'Data Structures (Stacks, Queues)', readMinutes: 30),
        Topic(id: 'ea4', title: 'Linked Lists and Trees', readMinutes: 30),
        Topic(id: 'ea5', title: 'Sorting Algorithms Analysis', readMinutes: 25),
        Topic(id: 'ea6', title: 'Searching Algorithms', readMinutes: 20),
        Topic(id: 'ea7', title: 'Object-Oriented Programming', readMinutes: 30),
        Topic(id: 'ea8', title: 'Algorithm Complexity (Big-O)', readMinutes: 25),
      ],
    ),
  ];

  List<Quiz> _quizzes = [];
  final List<QuizAttempt> _quizAttempts = [];

  // ---------- Getters ----------
  UserProfile get user => _user;
  String get userLevel => _user.derivedDifficulty;
  bool get isLoggedIn => _isLoggedIn;
  List<Module> get compulsoryModules => _compulsoryModules;
  List<Module> get electiveModules => _electiveModules;
  String? get selectedElectiveId => _selectedElectiveId;
  Module? get selectedElective =>
      _selectedElectiveId != null ? getModuleById(_selectedElectiveId!) : null;
  List<Quiz> get quizzes => _quizzes;
  List<QuizAttempt> get quizAttempts => _quizAttempts;
  AppThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode != AppThemeMode.light;
  bool get byteSizedQuiz => _byteSizedQuiz;
  bool get isGoogleUser => _user.isGoogleUser;

  bool get notifyStudyReminders => _notifyStudyReminders;
  bool get notifyQuizResults => _notifyQuizResults;
  bool get notifyNewContent => _notifyNewContent;
  bool get notifyStreakReminders => _notifyStreakReminders;
  bool get notifyWeeklyReport => _notifyWeeklyReport;

  List<Module> get continueModules {
    final tracked = [..._compulsoryModules];
    if (selectedElective != null) tracked.add(selectedElective!);
    return tracked.where((m) => m.progress > 0 && m.progress < 1.0).toList();
  }

  int get quizQuestionCount {
    if (_byteSizedQuiz) return 5;
    if (userLevel == 'advanced') return 20;
    return 10;
  }

  // ---------- Initialization ----------
  Future<void> initialize() async {
    _themeMode = await PersistenceService.loadThemeMode();

    final savedUser = await PersistenceService.loadUser();
    if (savedUser != null) {
      _user = savedUser;
      _isLoggedIn = true;
    }

    _selectedElectiveId = await PersistenceService.loadSelectedElective();

    // Restore completed topics
    final completedIds = await PersistenceService.loadCompletedTopics();
    final allModules = [..._compulsoryModules, ..._electiveModules];
    for (final module in allModules) {
      for (final topic in module.topics) {
        if (completedIds.contains(topic.id)) {
          topic.isCompleted = true;
        }
      }
    }

    // Restore quiz attempts
    final attempts = await PersistenceService.loadQuizAttempts();
    _quizAttempts.addAll(attempts);

    // Restore notifications
    final notifs = await PersistenceService.loadNotifications();
    _notifyStudyReminders = notifs['studyReminders'] ?? true;
    _notifyQuizResults = notifs['quizResults'] ?? true;
    _notifyNewContent = notifs['newContent'] ?? true;
    _notifyStreakReminders = notifs['streakReminders'] ?? true;
    _notifyWeeklyReport = notifs['weeklyReport'] ?? false;

    // Restore profile photo
    final photoPath = await PersistenceService.loadProfilePhotoPath();
    if (photoPath != null) {
      _user = _user.copyWith(localPhotoPath: photoPath);
    }

    _rebuildQuizzes();
    _recalculateProgress();
    notifyListeners();
  }

  // ---------- Auth ----------
  void login(String name, {
    String? email,
    String? yearOfStudy,
    String? expectedDseGrade,
    bool isGoogleUser = false,
    String? photoUrl,
    String? googleId,
  }) {
    _isLoggedIn = true;
    _googleId = googleId;
    final displayName = name.isEmpty ? 'Student' : name;
    _user = UserProfile(
      name: displayName,
      email: email ?? '${displayName.toLowerCase().replaceAll(' ', '.')}@student.edu',
      yearOfStudy: yearOfStudy,
      expectedDseGrade: expectedDseGrade,
      isGoogleUser: isGoogleUser,
      photoUrl: photoUrl,
    );
    _recalculateProgress();
    _rebuildQuizzes();
    _persist();
    PersistenceService.markSetupComplete();
    notifyListeners();
  }

  void signOut() {
    _isLoggedIn = false;
    _googleId = null;
    _supabaseUserId = null;
    _user = const UserProfile(name: 'Student', email: 'student@school.edu');
    // Reset all topic completions
    for (final m in [..._compulsoryModules, ..._electiveModules]) {
      for (final t in m.topics) {
        t.isCompleted = false;
      }
    }
    _quizAttempts.clear();
    _selectedElectiveId = null;
    _rebuildQuizzes();
    PersistenceService.clearAll();
    notifyListeners();
  }

  // ---------- Profile ----------
  void updateProfile({String? name, String? email, String? yearOfStudy, String? expectedDseGrade}) {
    _user = _user.copyWith(
      name: name,
      email: email,
      yearOfStudy: yearOfStudy,
      expectedDseGrade: expectedDseGrade,
    );
    _recalculateProgress();
    _persist();
    notifyListeners();
  }

  Future<void> pickProfilePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final savedPath = '${dir.path}/profile_photo.jpg';
      await File(picked.path).copy(savedPath);
      _user = _user.copyWith(localPhotoPath: savedPath);
      PersistenceService.saveProfilePhotoPath(savedPath);
      _persist();
      notifyListeners();
    }
  }

  // ---------- Theme ----------
  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    PersistenceService.saveThemeMode(mode);
    notifyListeners();
  }

  // ---------- Elective Selection (single) ----------
  void selectElective(String moduleId) {
    _selectedElectiveId = moduleId;
    _rebuildQuizzes();
    _recalculateProgress();
    PersistenceService.saveSelectedElective(moduleId);
    _persist();
    notifyListeners();
  }

  // ---------- Quiz Size Toggle ----------
  void setByteSizedQuiz(bool value) {
    _byteSizedQuiz = value;
    notifyListeners();
  }

  // ---------- Topic Completion ----------
  void completeTopic(String moduleId, String topicId) {
    final allModules = [..._compulsoryModules, ..._electiveModules];
    for (final module in allModules) {
      if (module.id == moduleId) {
        for (final topic in module.topics) {
          if (topic.id == topicId) {
            topic.isCompleted = true;
            _recalculateProgress();
            _persistCompletedTopics();
            _persist();
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  // ---------- Quiz Attempts ----------
  void addQuizAttempt(QuizAttempt attempt) {
    _quizAttempts.insert(0, attempt);
    if (_quizAttempts.length > 50) _quizAttempts.removeLast();
    PersistenceService.saveQuizAttempts(_quizAttempts);
    _recalculateProgress();
    _persist();
    notifyListeners();
  }

  // ---------- Notifications ----------
  void setNotification(String key, bool value) {
    switch (key) {
      case 'studyReminders': _notifyStudyReminders = value;
      case 'quizResults': _notifyQuizResults = value;
      case 'newContent': _notifyNewContent = value;
      case 'streakReminders': _notifyStreakReminders = value;
      case 'weeklyReport': _notifyWeeklyReport = value;
    }
    PersistenceService.saveNotifications({
      'studyReminders': _notifyStudyReminders,
      'quizResults': _notifyQuizResults,
      'newContent': _notifyNewContent,
      'streakReminders': _notifyStreakReminders,
      'weeklyReport': _notifyWeeklyReport,
    });
    notifyListeners();
  }

  // ---------- Clear Data ----------
  Future<void> clearAppData() async {
    await PersistenceService.clearAll();
  }

  // ---------- Helpers ----------
  Module? getModuleById(String id) {
    final allModules = [..._compulsoryModules, ..._electiveModules];
    for (final module in allModules) {
      if (module.id == id) return module;
    }
    return null;
  }

  void _rebuildQuizzes() {
    // Find the compulsory module with the lowest progress to recommend
    Module? weakest;
    for (final m in _compulsoryModules) {
      if (weakest == null || m.progress < weakest.progress) {
        weakest = m;
      }
    }

    _quizzes = [
      ..._compulsoryModules.map((m) => Quiz(
        id: 'q_${m.id}',
        title: '${m.title} Quiz',
        moduleId: m.id,
        questionCount: quizQuestionCount,
        estimatedMinutes: (quizQuestionCount * 2),
        isRecommended: weakest != null && m.id == weakest.id,
      )),
    ];
    if (_selectedElectiveId != null) {
      final elective = getModuleById(_selectedElectiveId!);
      if (elective != null) {
        _quizzes.add(Quiz(
          id: 'q_${elective.id}',
          title: '${elective.title} Quiz',
          moduleId: elective.id,
          questionCount: quizQuestionCount,
          estimatedMinutes: (quizQuestionCount * 2),
        ));
      }
    }
  }

  void _recalculateProgress() {
    final tracked = [..._compulsoryModules];
    if (selectedElective != null) tracked.add(selectedElective!);
    final totalTopics = tracked.fold(0, (sum, m) => sum + m.topics.length);
    final completed = tracked.fold(0, (sum, m) => sum + m.completedTopics);
    final progress = totalTopics > 0 ? completed / totalTopics : 0.0;
    _user = _user.copyWith(
      overallProgress: progress,
      topicsCompleted: completed,
      totalTopics: totalTopics,
      quizzesCompleted: _quizAttempts.length,
      totalQuizzes: _quizzes.length,
    );
  }

  void _persistCompletedTopics() {
    final allModules = [..._compulsoryModules, ..._electiveModules];
    final ids = <String>[];
    for (final m in allModules) {
      for (final t in m.topics) {
        if (t.isCompleted) ids.add(t.id);
      }
    }
    PersistenceService.saveCompletedTopics(ids);
  }

  void _persist() {
    PersistenceService.saveUser(_user);
    // Sync to Supabase for Google users (fire and forget)
    if (_user.isGoogleUser && _googleId != null) {
      SupabaseService.upsertUser(_user, _googleId!);
      if (_supabaseUserId != null) {
        _persistCompletedTopics();
        SupabaseService.syncTopicProgress(_supabaseUserId!, _getCompletedTopicIds());
      }
    }
  }

  List<String> _getCompletedTopicIds() {
    final ids = <String>[];
    for (final m in [..._compulsoryModules, ..._electiveModules]) {
      for (final t in m.topics) {
        if (t.isCompleted) ids.add(t.id);
      }
    }
    return ids;
  }
}
