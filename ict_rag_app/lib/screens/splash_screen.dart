import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_card.dart';
import '../services/app_state.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  // 0 = splash, 1 = name entry (non-google), 2 = onboarding
  int _step = 0;

  final _nameController = TextEditingController();
  String? _googleName;
  String? _googleEmail;
  String? _googlePhotoUrl;
  String? _googleId;
  bool _isGoogleUser = false;

  String? _selectedYear;
  String? _selectedGrade;

  final _years = ['S4', 'S5', 'S6'];
  final _grades = ['5**', '5*', '5', '4', '3', '2', '1'];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        setState(() {
          _googleName = account.displayName ?? '';
          _googleEmail = account.email;
          _googlePhotoUrl = account.photoUrl;
          _googleId = account.id;
          _isGoogleUser = true;
          _step = 2; // skip name entry, go to onboarding
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _goToOnboarding() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _step = 2);
  }

  void _finishOnboarding() {
    final name = _isGoogleUser ? (_googleName ?? 'Student') : _nameController.text.trim();
    context.read<AppState>().login(
      name,
      email: _googleEmail,
      yearOfStudy: _selectedYear,
      expectedDseGrade: _selectedGrade,
      isGoogleUser: _isGoogleUser,
      photoUrl: _googlePhotoUrl,
      googleId: _googleId,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.isDark
                ? AppColors.isOled
                    ? [const Color(0xFF000000), const Color(0xFF050510), const Color(0xFF000000)]
                    : [const Color(0xFF0A0E21), const Color(0xFF111730), const Color(0xFF0A0E21)]
                : [const Color(0xFFF5F7FA), const Color(0xFFEEF1F6), const Color(0xFFF5F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _buildSplashView();
      case 1: return _buildNameEntryView();
      case 2: return _buildOnboardingView();
      default: return _buildSplashView();
    }
  }

  Widget _buildSplashView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset(
            'assets/images/splash_icon.png',
            width: 140,
            height: 140,
          ),
          const SizedBox(height: 32),
          Text(
            'ICTorch',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Master Technology Skills',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const Spacer(flex: 3),

          // Google Sign-In button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      color: const Color(0xFF4285F4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              label: Text('Sign in with Google', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.cardBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppColors.card,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Continue without Google
          GlowingButton(
            text: 'Continue without Google',
            onPressed: () => setState(() => _step = 1),
          ),
          const SizedBox(height: 16),
          Text(
            'Senior Secondary ICT Learning Platform',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNameEntryView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(),
          Icon(Icons.menu_book_rounded, size: 56, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'What\'s your name?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text('Enter your name to personalise your experience', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
            ),
            style: TextStyle(color: AppColors.textPrimary),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _goToOnboarding(),
          ),
          const SizedBox(height: 32),
          GlowingButton(
            text: 'Next',
            onPressed: _goToOnboarding,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _step = 0),
            child: Text('Back', style: TextStyle(color: AppColors.textSecondary)),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildOnboardingView() {
    final displayName = _isGoogleUser ? (_googleName ?? 'there') : _nameController.text.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.school_rounded, size: 56, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  'Hi $displayName!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us about your studies so we can\npersonalise your learning',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 36),

                // Year of Study
                _buildSectionLabel('Year of Study'),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                year,
                                style: TextStyle(
                                  color: isActive ? Colors.white : AppColors.textMuted,
                                  fontSize: 15,
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
                const SizedBox(height: 28),

                // Expected DSE Grade
                _buildSectionLabel('Expected DSE ICT Grade'),
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

                const Spacer(),
                const SizedBox(height: 32),

                GlowingButton(
                  text: 'Start Learning',
                  onPressed: _finishOnboarding,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _finishOnboarding,
                  child: Text('Skip this step', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
