import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage what notifications you receive',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Learning'),
            const SizedBox(height: 12),
            _buildNotificationCard([
              _NotifTile(
                icon: Icons.alarm_rounded,
                iconColor: AppColors.primary,
                title: 'Study Reminders',
                subtitle: 'Daily reminders to keep your streak',
                value: state.notifyStudyReminders,
                onChanged: (v) => state.setNotification('studyReminders', v),
              ),
              _NotifTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.warning,
                title: 'Streak Reminders',
                subtitle: 'Don\'t lose your learning streak',
                value: state.notifyStreakReminders,
                onChanged: (v) => state.setNotification('streakReminders', v),
              ),
              _NotifTile(
                icon: Icons.auto_stories_rounded,
                iconColor: AppColors.accent,
                title: 'New Content',
                subtitle: 'When new topics or modules are added',
                value: state.notifyNewContent,
                onChanged: (v) => state.setNotification('newContent', v),
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionTitle('Assessment'),
            const SizedBox(height: 12),
            _buildNotificationCard([
              _NotifTile(
                icon: Icons.quiz_rounded,
                iconColor: AppColors.accentBlue,
                title: 'Quiz Results',
                subtitle: 'Summary after completing quizzes',
                value: state.notifyQuizResults,
                onChanged: (v) => state.setNotification('quizResults', v),
              ),
              _NotifTile(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.accentPink,
                title: 'Weekly Report',
                subtitle: 'Weekly learning progress summary',
                value: state.notifyWeeklyReport,
                onChanged: (v) => state.setNotification('weeklyReport', v),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildNotificationCard(List<_NotifTile> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final tile = entry.value;
          final isLast = entry.key == tiles.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tile.iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(tile.icon, color: tile.iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tile.title, style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(tile.subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch(
                      value: tile.value,
                      onChanged: tile.onChanged,
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, indent: 60, color: AppColors.cardBorder),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _NotifTile {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}
