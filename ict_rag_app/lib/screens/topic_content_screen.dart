import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/api_service.dart';
import '../services/local_cache.dart';
import '../widgets/gradient_card.dart';

class TopicContentScreen extends StatefulWidget {
  final String moduleId;
  final Topic topic;
  final int topicIndex;
  final int totalTopics;

  const TopicContentScreen({
    super.key,
    required this.moduleId,
    required this.topic,
    required this.topicIndex,
    required this.totalTopics,
  });

  @override
  State<TopicContentScreen> createState() => _TopicContentScreenState();
}

class _TopicContentScreenState extends State<TopicContentScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _notes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Try loading from cache first
    final cached = await LocalCache.getNotes(widget.topic.id);
    if (cached != null) {
      if (mounted) setState(() { _notes = cached; _loading = false; });
      return;
    }

    try {
      final level = context.read<AppState>().userLevel;
      if (!mounted) return;
      final notes = await _api.notesQuery(
        'Explain the topic: ${widget.topic.title}',
        level,
      );
      // Save to cache
      await LocalCache.saveNotes(widget.topic.id, notes);
      if (mounted) setState(() { _notes = notes; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _markComplete() {
    context.read<AppState>().completeTopic(widget.moduleId, widget.topic.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.topicIndex + 1) / widget.totalTopics;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Topic ${widget.topicIndex + 1} of ${widget.totalTopics}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topic.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.textMuted, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.topic.readMinutes} min read',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (_loading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 16),
                              Text('Loading content...', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else if (_error != null)
                      _buildError()
                    else if (_notes != null)
                      _buildNotes(),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  if (widget.topicIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Previous', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  if (widget.topicIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlowingButton(
                      text: widget.topic.isCompleted ? 'Completed' : 'Mark Complete',
                      onPressed: widget.topic.isCompleted ? null : _markComplete,
                      gradient: widget.topic.isCompleted
                          ? const LinearGradient(colors: [AppColors.accent, AppColors.accent])
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text('Failed to load content', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadNotes, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    final title = _notes!['title'] ?? '';
    final sections = _notes!['sections'] as List<dynamic>? ?? [];
    final summary = _notes!['summary'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
        ],
        ...sections.map((s) {
          final heading = s['heading'] ?? '';
          final points = (s['points'] as List<dynamic>?) ?? [];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (heading.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        heading,
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ...points.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.circle, color: AppColors.accent, size: 6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.toString(),
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        }),
        if (summary.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Summary', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(summary, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
