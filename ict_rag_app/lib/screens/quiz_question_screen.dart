import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/api_service.dart';
import '../services/local_cache.dart';
import '../widgets/gradient_card.dart';
import 'quiz_results_screen.dart';

const _tips = [
  'TCP/IP is the backbone protocol suite of the internet.',
  'A byte consists of 8 bits and can represent 256 different values.',
  'SQL stands for Structured Query Language.',
  'Encryption converts plaintext into ciphertext for security.',
  'An algorithm is a step-by-step procedure to solve a problem.',
  'RAM is volatile memory \u2014 data is lost when power is off.',
  'HTML, CSS, and JavaScript are the core web technologies.',
  'A firewall monitors and filters incoming and outgoing network traffic.',
  'Normalization reduces data redundancy in database design.',
  'Binary search is much faster than linear search on sorted data.',
  'HTTPS adds encryption to HTTP using TLS/SSL.',
  'An IP address uniquely identifies a device on a network.',
  'Cloud computing delivers services over the internet on demand.',
  'Phishing tricks users into revealing sensitive information.',
  'A flowchart visually represents the steps in a process.',
];

class QuizQuestionScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizQuestionScreen({super.key, required this.quiz});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> with TickerProviderStateMixin {
  final _api = ApiService();
  final List<QuizQuestion> _questions = [];
  final Map<int, String> _answers = {};
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;

  // Loading animation
  int _tipIndex = 0;
  Timer? _tipTimer;
  late AnimationController _pulseController;
  late AnimationController _spinController;
  int _questionsLoaded = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _tipIndex = Random().nextInt(_tips.length);
    _tipTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() { _loading = true; _error = null; _questionsLoaded = 0; });
    _questions.clear();
    try {
      final level = context.read<AppState>().userLevel;
      final module = context.read<AppState>().getModuleById(widget.quiz.moduleId);
      final topicName = module?.title ?? widget.quiz.title;

      for (int i = 0; i < widget.quiz.questionCount; i++) {
        final q = await _api.quizQuery('$topicName - question ${i + 1}', level);
        _questions.add(q);
        if (mounted) setState(() => _questionsLoaded = i + 1);
      }

      // Cache the questions
      await LocalCache.saveQuizQuestions(
        widget.quiz.id,
        _questions.map((q) => {
          'question': q.question,
          'options': q.options,
          'answer': q.answer,
          'explanation': q.explanation,
        }).toList(),
      );

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      // Try loading from cache
      final cached = await LocalCache.getQuizQuestions(widget.quiz.id);
      if (cached != null && cached.isNotEmpty) {
        _questions.addAll(cached.map((c) => QuizQuestion.fromJson(c)));
        if (mounted) setState(() => _loading = false);
      } else if (mounted) {
        setState(() { _error = e.toString(); _loading = false; });
      }
    }
  }

  void _selectOption(String option) {
    setState(() => _answers[_currentIndex] = option);
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showResults();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  bool get _isQuizFinished => _answers.length == _questions.length && _questions.isNotEmpty;

  Future<bool> _onWillPop() async {
    // If quiz is finished or still loading or errored, allow back without prompt
    if (_isQuizFinished || _loading || _error != null || _questions.isEmpty) {
      return true;
    }

    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Quit Quiz?',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to quit? Your progress will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Continue', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Quit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    return shouldQuit ?? false;
  }

  void _showResults() {
    int correct = 0;
    final userAnswersList = <String>[];
    for (int i = 0; i < _questions.length; i++) {
      final userAnswer = _answers[i] ?? '';
      userAnswersList.add(userAnswer);
      if (userAnswer == _questions[i].answer) correct++;
    }

    final score = _questions.isNotEmpty ? correct / _questions.length : 0.0;

    // Save to local cache
    LocalCache.saveQuizResult({
      'quizId': widget.quiz.id,
      'quizTitle': widget.quiz.title,
      'score': score,
      'correct': correct,
      'total': _questions.length,
      'date': DateTime.now().toIso8601String(),
      'questions': _questions.map((q) => q.toJson()).toList(),
      'userAnswers': userAnswersList,
    });

    // Save quiz attempt via AppState
    context.read<AppState>().addQuizAttempt(QuizAttempt(
      quizTitle: widget.quiz.title,
      quizId: widget.quiz.id,
      score: score,
      date: DateTime.now(),
      attempts: 1,
      questions: List<QuizQuestion>.from(_questions),
      userAnswers: userAnswersList,
    ));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultsScreen(
          quiz: widget.quiz,
          questions: _questions,
          answers: _answers,
          correctCount: correct,
          userAnswers: userAnswersList,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoadingScreen();

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load quiz', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadQuestions, child: const Text('Retry')),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back', style: TextStyle(color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final selected = _answers[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                      onPressed: () async {
                        final shouldPop = await _onWillPop();
                        if (shouldPop && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.quiz.title, style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(progress * 100).round()}%', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question ${_currentIndex + 1} of ${_questions.length}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 12),
                      Text(q.question, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600, height: 1.4)),
                      const SizedBox(height: 24),
                      ...q.options.entries.map((entry) {
                        final isSelected = selected == entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => _selectOption(entry.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder, width: isSelected ? 2 : 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(child: Text(entry.key, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold))),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(child: Text(entry.value, style: TextStyle(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 15))),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Questions answered: ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        Text('${_answers.length} / ${_questions.length}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_questions.length, (i) {
                        final isActive = i == _currentIndex;
                        final isAnswered = _answers.containsKey(i);
                        return GestureDetector(
                          onTap: () => setState(() => _currentIndex = i),
                          child: Container(
                            width: 32, height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : isAnswered ? AppColors.primary.withValues(alpha: 0.3) : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isActive ? AppColors.primary : AppColors.cardBorder),
                            ),
                            child: Center(
                              child: Text('${i + 1}', style: TextStyle(color: isActive || isAnswered ? Colors.white : AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _currentIndex > 0 ? _previous : null,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _currentIndex > 0 ? AppColors.cardBorder : AppColors.surfaceLight),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Previous', style: TextStyle(color: _currentIndex > 0 ? AppColors.textSecondary : AppColors.textMuted)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GlowingButton(
                            text: _currentIndex == _questions.length - 1 ? 'Finish Quiz' : 'Next Question',
                            onPressed: selected != null ? _next : null,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    final loadProgress = widget.quiz.questionCount > 0
        ? _questionsLoaded / widget.quiz.questionCount
        : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated spinner
              AnimatedBuilder(
                animation: _spinController,
                builder: (_, child) => Transform.rotate(
                  angle: _spinController.value * 2 * pi,
                  child: child,
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.accent,
                        AppColors.accentPink,
                        AppColors.accentBlue,
                        AppColors.primary,
                      ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                    child: const Icon(Icons.quiz_rounded, color: AppColors.primary, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Opacity(
                  opacity: 0.6 + _pulseController.value * 0.4,
                  child: Text(
                    'Generating Your Quiz',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preparing ${widget.quiz.questionCount} questions...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: loadProgress,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_questionsLoaded / ${widget.quiz.questionCount} ready',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),

              const Spacer(),

              // Rotating tip
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey(_tipIndex),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 18),
                          const SizedBox(width: 8),
                          const Text('Did you know?', style: TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _tips[_tipIndex],
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
