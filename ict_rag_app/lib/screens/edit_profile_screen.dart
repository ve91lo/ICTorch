import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _selectedYear;
  String? _selectedGrade;

  final _years = ['S4', 'S5', 'S6'];
  final _grades = ['5**', '5*', '5', '4', '3', '2', '1'];

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _selectedYear = user.yearOfStudy;
    _selectedGrade = user.expectedDseGrade;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Name cannot be empty'), backgroundColor: AppColors.error),
      );
      return;
    }
    context.read<AppState>().updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      yearOfStudy: _selectedYear,
      expectedDseGrade: _selectedGrade,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Profile updated'), backgroundColor: AppColors.success),
    );
  }

  void _showPhotoPickerSheet() {
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
    final user = context.watch<AppState>().user;
    final avatarImage = _getAvatarImage(user);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _showPhotoPickerSheet,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Name
            _buildLabel('Display Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),

            // Email
            _buildLabel('Email'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              style: TextStyle(color: user.isGoogleUser ? AppColors.textMuted : AppColors.textPrimary),
              enabled: !user.isGoogleUser,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
                suffixIcon: user.isGoogleUser
                    ? Icon(Icons.lock_outline, color: AppColors.textMuted, size: 18)
                    : null,
              ),
            ),
            if (user.isGoogleUser)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Email is managed by Google', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            const SizedBox(height: 24),

            // Year of Study
            _buildLabel('Year of Study'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: _years.map((year) {
                  final isActive = _selectedYear == year;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedYear = year),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            year,
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.textMuted,
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Expected DSE Grade
            _buildLabel('Expected DSE ICT Grade'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _grades.map((grade) {
                final isActive = _selectedGrade == grade;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGrade = grade),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: isActive ? null : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Center(
                      child: Text(
                        grade,
                        style: TextStyle(
                          color: isActive ? Colors.white : AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
    );
  }
}
