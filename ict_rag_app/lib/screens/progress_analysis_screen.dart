import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../services/api_service.dart';

class ProgressAnalysisScreen extends StatefulWidget {
  const ProgressAnalysisScreen({super.key});

  @override
  State<ProgressAnalysisScreen> createState() => _ProgressAnalysisScreenState();
}

class _ProgressAnalysisScreenState extends State<ProgressAnalysisScreen> {
  final _api = ApiService();
  String? _recommendation;
  List<String> _keyPoints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() => _loading = true);
    try {
      final state = context.read<AppState>();
      final user = state.user;

      // Build a context prompt from user's actual progress
      final completedModules = state.compulsoryModules
          .where((m) => m.progress == 1.0)
          .map((m) => m.title)
          .toList();
      final inProgressModules = state.compulsoryModules
          .where((m) => m.progress > 0 && m.progress < 1.0)
          .map((m) => '${m.title} (${(m.progress * 100).round()}%)')
          .toList();
      final notStarted = state.compulsoryModules
          .where((m) => m.progress == 0)
          .map((m) => m.title)
          .toList();

      final prompt = '''Analyze this HKDSE ICT student's progress and give study recommendations.
Overall progress: ${(user.overallProgress * 100).round()}%
Topics completed: ${user.topicsCompleted}/${user.totalTopics}
Quizzes completed: ${user.quizzesCompleted}/${user.totalQuizzes}
Completed modules: ${completedModules.isEmpty ? 'None' : completedModules.join(', ')}
In-progress modules: ${inProgressModules.isEmpty ? 'None' : inProgressModules.join(', ')}
Not started: ${notStarted.isEmpty ? 'None' : notStarted.join(', ')}
Study streak: ${user.streakDays} days
Study hours: ${user.studyHours}h

Give a short comment (max 4 sentences) on their performance, then give exactly 3 key study recommendations as bullet points starting with "-".''';

      final reply = await _api.chatQuery(prompt, state.userLevel);

      // Parse key points
      final lines = reply.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final bullets = <String>[];
      final commentLines = <String>[];
      for (final line in lines) {
        if (line.trim().startsWith('-') || line.trim().startsWith('\u2022')) {
          bullets.add(line.trim().replaceFirst(RegExp(r'^[\-\u2022]\s*'), ''));
        } else {
          commentLines.add(line.trim());
        }
      }

      if (mounted) {
        setState(() {
          _recommendation = commentLines.take(4).join(' ');
          _keyPoints = bullets.take(3).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recommendation = 'Unable to generate analysis right now. Please try again later.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Progress Analysis',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Overall score ring
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: user.overallProgress,
                          strokeWidth: 12,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(user.overallProgress * 100).round()}%',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          Text('Overall', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats grid
              Row(
                children: [
                  _MiniStat(icon: Icons.book, label: 'Topics', value: '${user.topicsCompleted}/${user.totalTopics}', color: AppColors.accent),
                  const SizedBox(width: 10),
                  _MiniStat(icon: Icons.quiz, label: 'Quizzes', value: '${user.quizzesCompleted}/${user.totalQuizzes}', color: AppColors.accentBlue),
                  const SizedBox(width: 10),
                  _MiniStat(icon: Icons.local_fire_department, label: 'Streak', value: '${user.streakDays}d', color: AppColors.warning),
                ],
              ),
              const SizedBox(height: 24),

              // Module breakdown
              Text('Module Progress', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...state.compulsoryModules.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ModuleBar(title: m.title, progress: m.progress),
              )),
              const SizedBox(height: 24),

              // AI Recommendation
              Text('AI Study Recommendations', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              if (_loading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                      const SizedBox(height: 12),
                      Text('Analyzing your performance...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                )
              else ...[
                if (_recommendation != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            const Text('Performance Comment', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(_recommendation!, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5)),
                      ],
                    ),
                  ),
                if (_keyPoints.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ...List.generate(_keyPoints.length, (i) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('${i + 1}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_keyPoints[i], style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4)),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ModuleBar extends StatelessWidget {
  final String title;
  final double progress;

  const _ModuleBar({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation(
                  progress == 1.0 ? AppColors.accent : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(progress * 100).round()}%', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
