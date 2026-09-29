import 'package:flutter/material.dart';

import '../../data/paper_repository.dart';
import '../../models/subject.dart';
import '../../widgets/subject_card.dart';
import 'papers_screen.dart';

class TheorySubjectScreen extends StatelessWidget {
  const TheorySubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theory & Past Papers')),
      body: FutureBuilder<Set<String>>(
        future: PaperRepository.instance.availableSubjects(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final available = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: kSubjects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final subject = kSubjects[index];
              final hasPapers = available.contains(subject.slug);
              return SubjectCard(
                subject: subject,
                subtitle: hasPapers ? 'Past papers available' : 'No papers bundled yet',
                onTap: hasPapers
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PapersScreen(subject: subject)),
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
