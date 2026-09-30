import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../models/subject.dart';

class ReviewAnswersScreen extends StatelessWidget {
  final Subject subject;
  final List<Question> questions;
  final List<int> givenAnswers;

  const ReviewAnswersScreen({
    super.key,
    required this.subject,
    required this.questions,
    required this.givenAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Answers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: questions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _ReviewCard(
            index: index,
            question: questions[index],
            givenAnswer: givenAnswers[index],
            accent: subject.color,
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int index;
  final Question question;
  final int givenAnswer;
  final Color accent;

  const _ReviewCard({
    required this.index,
    required this.question,
    required this.givenAnswer,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wasCorrect = givenAnswer == question.answerIndex;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: wasCorrect ? scheme.primaryContainer : scheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        wasCorrect ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: wasCorrect ? scheme.primary : scheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        wasCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: wasCorrect ? scheme.primary : scheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < question.options.length; i++) ...[
              _AnswerRow(
                label: question.options[i],
                isCorrectAnswer: i == question.answerIndex,
                isGivenAnswer: i == givenAnswer,
              ),
              if (i != question.options.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final bool isCorrectAnswer;
  final bool isGivenAnswer;

  const _AnswerRow({
    required this.label,
    required this.isCorrectAnswer,
    required this.isGivenAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color background = scheme.surfaceContainerHigh;
    Color border = Colors.transparent;
    Color foreground = scheme.onSurface;
    IconData? icon;
    String? tag;

    if (isCorrectAnswer) {
      background = scheme.primaryContainer;
      border = scheme.primary;
      icon = Icons.check_circle;
      tag = isGivenAnswer ? 'Your answer · correct' : 'Correct answer';
    } else if (isGivenAnswer) {
      background = scheme.errorContainer;
      border = scheme.error;
      icon = Icons.cancel;
      foreground = scheme.onErrorContainer;
      tag = 'Your answer';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: foreground, fontSize: 14.5)),
                if (tag != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: border,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (icon != null) Icon(icon, color: border, size: 20),
        ],
      ),
    );
  }
}
