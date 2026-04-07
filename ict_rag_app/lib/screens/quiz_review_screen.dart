import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class QuizReviewScreen extends StatelessWidget {
  final QuizAttempt attempt;

  const QuizReviewScreen({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final questions = attempt.questions ?? [];
    final userAnswers = attempt.userAnswers ?? [];
    final score = attempt.score;
    final daysAgo = DateTime.now().difference(attempt.date).inDays;
    final dateStr = daysAgo == 0 ? 'Today' : daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago';

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Review', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: score >= 0.7 ? AppGradients.primary : null,
                color: score < 0.7 ? AppColors.card : null,
                borderRadius: BorderRadius.circular(16),
                border: score < 0.7 ? Border.all(color: AppColors.cardBorder) : null,
              ),
              child: Column(
                children: [
                  Text(
                    attempt.quizTitle,
                    style: TextStyle(
                      color: score >= 0.7 ? Colors.white : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(score * 100).round()}%',
                    style: TextStyle(
                      color: score >= 0.7 ? Colors.white : _scoreColor(score),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr \u2022 ${questions.length} questions',
                    style: TextStyle(
                      color: score >= 0.7 ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Question Review',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            if (questions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Text(
                    'Detailed question data not available for this attempt',
                    style: TextStyle(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            ...questions.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;
              final userAnswer = idx < userAnswers.length ? userAnswers[idx] : '';
              final isCorrect = userAnswer == q.answer;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCorrect
                        ? AppColors.success.withValues(alpha: 0.5)
                        : AppColors.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question header
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_rounded : Icons.close_rounded,
                            color: isCorrect ? AppColors.success : AppColors.error,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Question ${idx + 1}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Question text
                    Text(
                      q.question,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 14),

                    // Options
                    ...q.options.entries.map((opt) {
                      final isUserChoice = opt.key == userAnswer;
                      final isCorrectAnswer = opt.key == q.answer;
                      Color optBg = Colors.transparent;
                      Color optBorder = AppColors.cardBorder;
                      Color optText = AppColors.textSecondary;

                      if (isCorrectAnswer) {
                        optBg = AppColors.success.withValues(alpha: 0.1);
                        optBorder = AppColors.success.withValues(alpha: 0.4);
                        optText = AppColors.success;
                      } else if (isUserChoice && !isCorrect) {
                        optBg = AppColors.error.withValues(alpha: 0.1);
                        optBorder = AppColors.error.withValues(alpha: 0.4);
                        optText = AppColors.error;
                      }

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: optBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: optBorder),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${opt.key}.',
                              style: TextStyle(color: optText, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                opt.value,
                                style: TextStyle(color: optText, fontSize: 13),
                              ),
                            ),
                            if (isCorrectAnswer)
                              Icon(Icons.check_circle, color: AppColors.success, size: 16),
                            if (isUserChoice && !isCorrect)
                              Icon(Icons.cancel, color: AppColors.error, size: 16),
                          ],
                        ),
                      );
                    }),

                    // Explanation
                    if (q.explanation.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                q.explanation,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Color _scoreColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.5) return AppColors.warning;
    return AppColors.error;
  }
}
