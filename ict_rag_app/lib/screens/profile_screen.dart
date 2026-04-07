import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'learning_history_screen.dart';
import 'help_support_screen.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showPhotoPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 22),
                ),
                title: Text('Camera', style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AppState>().pickProfilePhoto(ImageSource.camera);
                },
              ),
              Divider(height: 1, indent: 60, color: AppColors.cardBorder),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library_rounded, color: AppColors.accent, size: 22),
                ),
                title: Text('Gallery', style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AppState>().pickProfilePhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage(dynamic user) {
    if (user.localPhotoPath != null && File(user.localPhotoPath!).existsSync()) {
      return FileImage(File(user.localPhotoPath!));
    } else if (user.photoUrl != null) {
      return NetworkImage(user.photoUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    final avatarImage = _getAvatarImage(user);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.isOled
                        ? [const Color(0xFF0D0820), const Color(0xFF000000)]
                        : AppColors.isDark
                            ? [const Color(0xFF1A1040), const Color(0xFF0A0E21)]
                            : [const Color(0xFFE8E0F0), const Color(0xFFF5F7FA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showPhotoPickerSheet(context),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary,
                            backgroundImage: avatarImage,
                            child: avatarImage == null
                                ? Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.background, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    if (user.yearOfStudy != null || user.expectedDseGrade != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (user.yearOfStudy != null)
                            _InfoChip(label: user.yearOfStudy!),
                          if (user.yearOfStudy != null && user.expectedDseGrade != null)
                            const SizedBox(width: 8),
                          if (user.expectedDseGrade != null)
                            _InfoChip(label: 'Target: ${user.expectedDseGrade!}'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Summary
                    Text(
                      'Progress Summary',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatBox(
                          value: '${(user.overallProgress * 100).round()}%',
                          label: 'Overall',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        _StatBox(
                          value: '${user.topicsCompleted}',
                          label: 'Topics',
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 10),
                        _StatBox(
                          value: '${user.badges}',
                          label: 'Badges',
                          color: AppColors.accentPink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Learning Statistics
                    Text(
                      'Learning Statistics',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _LearningStatCard(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.warning,
                            value: '${user.streakDays} days',
                            label: 'Streak',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LearningStatCard(
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.accentBlue,
                            value: '${user.studyHours}h',
                            label: 'Study Time',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quiz Attempt Records
                    Text(
                      'Quiz Attempt Records',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...state.quizAttempts.map((attempt) => _QuizAttemptTile(attempt: attempt)),

                    if (state.quizAttempts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            'No quiz attempts yet',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Menu Items
                    Text(
                      'Account',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(context, [
                      _MenuItem(
                        icon: Icons.edit_rounded,
                        iconColor: AppColors.primary,
                        title: 'Edit Profile',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.settings_rounded,
                        iconColor: AppColors.accentBlue,
                        title: 'Settings',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        iconColor: AppColors.warning,
                        title: 'Notifications',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.history_rounded,
                        iconColor: AppColors.accent,
                        title: 'Learning History',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningHistoryScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        iconColor: AppColors.primaryLight,
                        title: 'Help & Support',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    _buildMenuCard(context, [
                      _MenuItem(
                        icon: Icons.delete_outline_rounded,
                        iconColor: AppColors.error,
                        title: 'Clear App Data',
                        onTap: () => _showClearDataDialog(context),
                      ),
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.error,
                        title: 'Sign Out',
                        isLast: true,
                        onTap: () => _showSignOutDialog(context),
                      ),
                    ]),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: item.iconColor == AppColors.error ? AppColors.error : AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(height: 1, indent: 60, color: AppColors.cardBorder),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear App Data', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This will clear all cached notes, quiz results, and saved preferences. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AppState>().clearAppData();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('App data cleared'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
              );
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback? onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onTap,
    this.isLast = false,
  });
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _LearningStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _LearningStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizAttemptTile extends StatelessWidget {
  final dynamic attempt;

  const _QuizAttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final daysAgo = DateTime.now().difference(attempt.date).inDays;
    final dateStr = daysAgo == 0 ? 'Today' : daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago';

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
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.quiz_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt.quizTitle,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(attempt.score * 100).round()}% \u2022 $dateStr \u2022 ${attempt.attempts} attempts',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}
