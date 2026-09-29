import 'package:flutter/material.dart';

import '../../data/paper_repository.dart';
import '../../models/paper.dart';
import '../../models/subject.dart';
import 'pdf_viewer_screen.dart';

class PapersScreen extends StatelessWidget {
  final Subject subject;

  const PapersScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: FutureBuilder<List<Paper>>(
        future: PaperRepository.instance.papersFor(subject.slug),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final papers = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: papers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final paper = papers[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: subject.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.picture_as_pdf_rounded, color: subject.color),
                  ),
                  title: Text(paper.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PdfViewerScreen(paper: paper)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
