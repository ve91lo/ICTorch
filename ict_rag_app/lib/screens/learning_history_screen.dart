import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import 'quiz_review_screen.dart';

class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allModules = [...state.compulsoryModules, ...state.electiveModules];

    // Collect all completed topics with their module names
    final completedItems = <_HistoryItem>[];
    for (final module in allModules) {
      for (final topic in module.topics) {
        if (topic.isCompleted) {
          completedItems.add(_HistoryItem(
            topicTitle: topic.title,
            moduleTitle: module.title,
            readMinutes: topic.readMinutes,
          ));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Learning History', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: completedItems.isEmpty && state.quizAttempts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No learning history yet', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Start completing topics to see your history',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Topics Completed', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '${completedItems.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Read Time', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '${completedItems.fold(0, (sum, item) => sum + item.readMinutes)} min',
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (completedItems.isNotEmpty) ...[
                    Text(
                      'Completed Topics',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    ...completedItems.map((item) => _HistoryTile(item: item)),

                    const SizedBox(height: 24),
                  ],

                  // Quiz attempts
                  if (state.quizAttempts.isNotEmpty) ...[
                    Text(
                      'Quiz History',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...state.quizAttempts.map((attempt) {
                      final daysAgo = DateTime.now().difference(attempt.date).inDays;
                      final dateStr = daysAgo == 0 ? 'Today' : daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago';
                      final hasReviewData = attempt.questions != null;
                      return GestureDetector(
                        onTap: hasReviewData
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizReviewScreen(attempt: attempt),
                                  ),
                                )
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _scoreColor(attempt.score).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.quiz_rounded, color: _scoreColor(attempt.score), size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(attempt.quizTitle, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 2),
                                    Text('$dateStr \u2022 ${attempt.attempts} attempts', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(
                                '${(attempt.score * 100).round()}%',
                                style: TextStyle(color: _scoreColor(attempt.score), fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (hasReviewData) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
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

class _HistoryItem {
  final String topicTitle;
  final String moduleTitle;
  final int readMinutes;

  const _HistoryItem({
    required this.topicTitle,
    required this.moduleTitle,
    required this.readMinutes,
  });
}

class _HistoryTile extends StatelessWidget {
  final _HistoryItem item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.topicTitle, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('${item.moduleTitle} \u2022 ${item.readMinutes} min read', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
