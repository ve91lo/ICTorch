import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/gradient_card.dart';
import 'quiz_question_screen.dart';
import 'profile_screen.dart';

class QuizSelectionScreen extends StatelessWidget {
  const QuizSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recommended = state.quizzes.where((q) => q.isRecommended).toList();
    final allQuizzes = state.quizzes;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Practice Quizzes',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      context.read<AppState>().user.name.isNotEmpty ? context.read<AppState>().user.name[0].toUpperCase() : 'S',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recommended
            if (recommended.isNotEmpty) ...[
              Text(
                'Recommended for You',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Quiz size toggle
              _QuizSizeToggle(state: state),
              const SizedBox(height: 14),

              ...recommended.map((quiz) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecommendedQuizCard(
                  quiz: quiz,
                  moduleName: state.getModuleById(quiz.moduleId)?.title ?? '',
                  onStart: () {
                    quiz.questionCount = state.quizQuestionCount;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizQuestionScreen(quiz: quiz),
                      ),
                    );
                  },
                ),
              )),
              const SizedBox(height: 8),
              Text(
                'Test your knowledge and track your progress',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
            ],

            // If no recommended, still show the toggle above "All Quizzes"
            if (recommended.isEmpty) ...[
              _QuizSizeToggle(state: state),
              const SizedBox(height: 20),
            ],

            // All Quizzes
            Text(
              'All Quizzes',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...allQuizzes.map((quiz) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _QuizCard(
                quiz: quiz,
                onTap: () {
                  quiz.questionCount = state.quizQuestionCount;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizQuestionScreen(quiz: quiz),
                    ),
                  );
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _QuizSizeToggle extends StatelessWidget {
  final AppState state;

  const _QuizSizeToggle({required this.state});

  @override
  Widget build(BuildContext context) {
    final isByteSized = state.byteSizedQuiz;
    final bigCount = state.userLevel == 'advanced' ? 20 : 10;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => state.setByteSizedQuiz(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isByteSized
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isByteSized ? AppColors.primary : AppColors.cardBorder,
                  width: isByteSized ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flash_on_rounded,
                    color: isByteSized ? AppColors.primary : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Byte-sized (5)',
                    style: TextStyle(
                      color: isByteSized ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: isByteSized ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => state.setByteSizedQuiz(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !isByteSized
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !isByteSized ? AppColors.primary : AppColors.cardBorder,
                  width: !isByteSized ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    color: !isByteSized ? AppColors.primary : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Big ones ($bigCount)',
                    style: TextStyle(
                      color: !isByteSized ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: !isByteSized ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendedQuizCard extends StatelessWidget {
  final dynamic quiz;
  final String moduleName;
  final VoidCallback onStart;

  const _RecommendedQuizCard({required this.quiz, required this.moduleName, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Recommended',
                  style: TextStyle(color: AppColors.accentPink, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.quiz_rounded, color: AppColors.primary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quiz.title,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your progress in $moduleName',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            '${quiz.questionCount} questions  \u2022  ${quiz.estimatedMinutes} min',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          GlowingButton(text: 'Start Quiz Now', onPressed: onStart, height: 44),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final dynamic quiz;
  final VoidCallback onTap;

  const _QuizCard({required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.quiz_rounded, color: AppColors.accentBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${quiz.questionCount} questions  \u2022  ${quiz.estimatedMinutes} min',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  if (quiz.bestScore != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Best: ${(quiz.bestScore! * 100).round()}%',
                          style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
