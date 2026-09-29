import 'package:flutter/material.dart';

import '../../models/subject.dart';
import 'quiz_screen.dart';

class YearSelectScreen extends StatelessWidget {
  final Subject subject;
  final List<String> years;

  const YearSelectScreen({super.key, required this.subject, required this.years});

  @override
  Widget build(BuildContext context) {
    final sortedYears = [...years]..sort();
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a past-question year',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.3,
                ),
                itemCount: sortedYears.length,
                itemBuilder: (context, index) {
                  final year = sortedYears[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(subject: subject, year: year),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          year,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: subject.color,
                              ),
                        ),
                      ),
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
