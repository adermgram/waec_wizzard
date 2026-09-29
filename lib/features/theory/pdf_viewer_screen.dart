import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../models/paper.dart';

class PdfViewerScreen extends StatelessWidget {
  final Paper paper;

  const PdfViewerScreen({super.key, required this.paper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(paper.title)),
      body: SfPdfViewer.asset(paper.assetPath),
    );
  }
}
