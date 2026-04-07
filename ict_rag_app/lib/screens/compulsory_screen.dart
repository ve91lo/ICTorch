import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../widgets/gradient_card.dart';
import 'topic_list_screen.dart';
import 'profile_screen.dart';

class CompulsoryScreen extends StatefulWidget {
  const CompulsoryScreen({super.key});

  @override
  State<CompulsoryScreen> createState() => _CompulsoryScreenState();
}

class _CompulsoryScreenState extends State<CompulsoryScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final modules = state.compulsoryModules
        .where((m) => m.title.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Compulsory Modules',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
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
                      state.user.name.isNotEmpty ? state.user.name[0].toUpperCase() : 'S',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search modules...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete all compulsory modules to advance',
                      style: TextStyle(color: AppColors.primaryLight, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: modules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final m = modules[i];
                  return ModuleProgressCard(
                    title: m.title,
                    completedTopics: m.completedTopics,
                    totalTopics: m.topics.length,
                    isRequired: m.isRequired,
                    icon: ModuleHelper.getIcon(m.id),
                    iconColor: ModuleHelper.getColor(m.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TopicListScreen(module: m)),
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
}
