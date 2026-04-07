import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import 'topic_list_screen.dart';
import 'profile_screen.dart';

class ElectiveScreen extends StatelessWidget {
  const ElectiveScreen({super.key});

  static const _descriptions = {
    'elective_database':
        'Master relational databases, advanced SQL, normalisation, and database administration for real-world data management.',
    'elective_web':
        'Build modern web applications with HTML/CSS, JavaScript, server-side programming, and responsive design.',
    'elective_algorithm':
        'Dive into advanced algorithms, data structures, recursion, OOP, and computational complexity analysis.',
  };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final electives = state.electiveModules;
    final selectedId = state.selectedElectiveId;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Elective Module',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                      state.user.name.isNotEmpty
                          ? state.user.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedId != null
                          ? 'You have selected an elective. Tap any module to preview topics.'
                          : 'Select one elective module for progress tracking and quizzes.',
                      style: TextStyle(color: AppColors.accent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Elective cards
            Expanded(
              child: ListView.separated(
                itemCount: electives.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final m = electives[i];
                  final isSelected = selectedId == m.id;
                  final moduleColor = ModuleHelper.getColor(m.id);
                  final moduleIcon = ModuleHelper.getIcon(m.id);
                  final description = _descriptions[m.id] ?? '';

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? moduleColor : AppColors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tappable area -> preview topics
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TopicListScreen(module: m),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: moduleColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(moduleIcon, color: moduleColor, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              m.title,
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: moduleColor.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Selected',
                                                style: TextStyle(
                                                  color: moduleColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${m.topics.length} topics${isSelected ? ' \u2022 ${(m.progress * 100).round()}% complete' : ''}',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textMuted,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Progress bar (only for selected)
                        if (isSelected) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: m.progress,
                                backgroundColor: AppColors.surfaceLight,
                                valueColor: AlwaysStoppedAnimation(moduleColor),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],

                        // Select button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          child: SizedBox(
                            width: double.infinity,
                            child: isSelected
                                ? OutlinedButton.icon(
                                    onPressed: null,
                                    icon: Icon(Icons.check_circle, size: 18, color: moduleColor),
                                    label: Text(
                                      'Currently Selected',
                                      style: TextStyle(color: moduleColor, fontSize: 13),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: moduleColor.withValues(alpha: 0.4)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () => _onSelectElective(context, state, m.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: moduleColor.withValues(alpha: 0.15),
                                      foregroundColor: moduleColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Select this module',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelectElective(BuildContext context, AppState state, String moduleId) {
    // If an elective is already selected and user picks a different one, warn
    if (state.selectedElectiveId != null && state.selectedElectiveId != moduleId) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Change Elective?',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Changing your elective will reset your elective progress tracking and quiz subject. Continue?',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                state.selectElective(moduleId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      state.selectElective(moduleId);
    }
  }
}
