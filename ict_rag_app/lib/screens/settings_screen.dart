import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance
            _buildSectionTitle('Appearance'),
            const SizedBox(height: 12),
            _buildThemeCard(context, state),
            const SizedBox(height: 24),

            // General
            _buildSectionTitle('General'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _SettingsTile(
                icon: Icons.text_fields_rounded,
                iconColor: AppColors.accent,
                title: 'Font Size',
                trailing: Text('Medium', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ),
              _SettingsTile(
                icon: Icons.download_rounded,
                iconColor: AppColors.primary,
                title: 'Auto-cache Notes',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // About
            _buildSectionTitle('About'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primaryLight,
                title: 'App Version',
                trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.warning,
                title: 'Terms of Service',
                trailing: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: AppColors.accentPink,
                title: 'Privacy Policy',
                trailing: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, AppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildThemeOption(
            context,
            icon: Icons.light_mode_rounded,
            label: 'Light',
            mode: AppThemeMode.light,
            isActive: state.themeMode == AppThemeMode.light,
            state: state,
          ),
          _buildThemeOption(
            context,
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            mode: AppThemeMode.dark,
            isActive: state.themeMode == AppThemeMode.dark,
            state: state,
          ),
          _buildThemeOption(
            context,
            icon: Icons.brightness_2_rounded,
            label: 'OLED',
            mode: AppThemeMode.oled,
            isActive: state.themeMode == AppThemeMode.oled,
            state: state,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required AppThemeMode mode,
    required bool isActive,
    required AppState state,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => state.setThemeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.white : AppColors.textMuted, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
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

  Widget _buildSettingsCard(List<_SettingsTile> tiles) {
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
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tile.iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tile.icon, color: tile.iconColor, size: 20),
                ),
                title: Text(tile.title, style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                trailing: tile.trailing,
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

class _SettingsTile {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
  });
}
