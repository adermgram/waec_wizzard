import 'package:flutter/material.dart';

import '../../data/question_repository.dart';
import '../../models/subject.dart';
import '../../widgets/subject_card.dart';
import 'year_select_screen.dart';

class QuizSubjectScreen extends StatelessWidget {
  const QuizSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice Quiz')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: kSubjects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = kSubjects[index];
          return FutureBuilder<List<String>>(
            future: QuestionRepository.instance.yearsFor(subject.slug),
            builder: (context, snapshot) {
              final years = snapshot.data ?? const [];
              final loading = !snapshot.hasData;
              final subtitle = loading
                  ? 'Loading…'
                  : years.isEmpty
                      ? 'No questions available'
                      : '${years.length} year${years.length == 1 ? '' : 's'} available';
              return SubjectCard(
                subject: subject,
                subtitle: subtitle,
                onTap: (!loading && years.isNotEmpty)
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => YearSelectScreen(subject: subject, years: years),
                          ),
                        )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
