import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/gradient_card.dart';

class QuizResultsScreen extends StatelessWidget {
  final Quiz quiz;
  final List<QuizQuestion> questions;
  final Map<int, String> answers;
  final int correctCount;
  final List<String> userAnswers;

  const QuizResultsScreen({
    super.key,
    required this.quiz,
    required this.questions,
    required this.answers,
    required this.correctCount,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final score = total > 0 ? (correctCount / total * 100).round() : 0;
    final isGood = score >= 70;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Score card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  gradient: isGood ? AppGradients.primary : AppGradients.pinkBlue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (isGood ? AppColors.primary : AppColors.accentPink).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      isGood ? Icons.emoji_events_rounded : Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isGood ? 'Excellent Work!' : 'Keep Practicing!',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('You scored', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '$score%',
                      style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$correctCount out of $total correct',
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Question review header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Question Review',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),

              // Question review
              ...List.generate(questions.length, (i) {
                final q = questions[i];
                final userAnswer = i < userAnswers.length ? userAnswers[i] : (answers[i] ?? '');
                final isCorrect = userAnswer == q.answer;
                final userAnswerText = userAnswer.isNotEmpty && q.options.containsKey(userAnswer)
                    ? '$userAnswer. ${q.options[userAnswer]}'
                    : 'Not answered';
                final correctAnswerText = '${q.answer}. ${q.options[q.answer] ?? ''}';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCorrect
                          ? AppColors.accent.withValues(alpha: 0.4)
                          : AppColors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question header with icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? AppColors.accent.withValues(alpha: 0.15)
                                  : AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isCorrect ? Icons.check : Icons.close,
                              color: isCorrect ? AppColors.accent : AppColors.error,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Q${i + 1}. ${q.question}',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // User answer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.accent.withValues(alpha: 0.08)
                              : AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                              color: isCorrect ? AppColors.accent : AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your answer: $userAnswerText',
                                style: TextStyle(
                                  color: isCorrect ? AppColors.accent : AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Show correct answer if wrong
                      if (!isCorrect) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: AppColors.accent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Correct answer: $correctAnswerText',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Explanation
                      if (q.explanation.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                q.explanation,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Buttons
              GlowingButton(
                text: 'Retake Quiz',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Back to Quizzes', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
