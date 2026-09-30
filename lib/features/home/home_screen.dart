import 'package:flutter/material.dart';

import '../calculator/calculator_screen.dart';
import '../quiz/quiz_subject_screen.dart';
import '../theory/theory_subject_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('WAEC Wizard')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Practice smarter for WAEC.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Past questions and study papers, all offline.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              _ModeCard(
                icon: Icons.quiz_rounded,
                title: 'Practice Quiz',
                description: 'Timed multiple-choice questions from real past papers, 2000–2005.',
                color: scheme.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuizSubjectScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Theory & Past Papers',
                description: 'Browse bundled past-paper PDFs by subject.',
                color: scheme.tertiary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TheorySubjectScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                icon: Icons.calculate_rounded,
                title: 'Calculator',
                description: 'Scientific calculator for working through problems.',
                color: scheme.secondary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CalculatorScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
