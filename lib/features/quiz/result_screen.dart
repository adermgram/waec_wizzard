import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../models/subject.dart';
import 'quiz_screen.dart';
import 'review_answers_screen.dart';

class ResultScreen extends StatelessWidget {
  final Subject subject;
  final String year;
  final int score;
  final int total;
  final List<Question> questions;
  final List<int> givenAnswers;

  const ResultScreen({
    super.key,
    required this.subject,
    required this.year,
    required this.score,
    required this.total,
    required this.questions,
    required this.givenAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = total == 0 ? 0.0 : score / total;
    final message = _messageFor(percent);

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: percent,
                          strokeWidth: 12,
                          backgroundColor: scheme.surfaceContainerHigh,
                          color: subject.color,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score/$total',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${(percent * 100).round()}%',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.name} · $year',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReviewAnswersScreen(
                          subject: subject,
                          questions: questions,
                          givenAnswers: givenAnswers,
                        ),
                      ),
                    ),
                    child: const Text('Review answers'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            QuizScreen(subject: subject, year: year),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    child: const Text('Back to home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _messageFor(double percent) {
    if (percent >= 0.8) return 'Excellent work!';
    if (percent >= 0.6) return 'Good job, keep practicing!';
    if (percent >= 0.4) return 'Not bad — a bit more revision will help.';
    return 'Keep at it, you’ll get there.';
  }
}
