class Paper {
  final String subjectSlug;
  final String title;
  final String file;

  const Paper({
    required this.subjectSlug,
    required this.title,
    required this.file,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      subjectSlug: json['subject'] as String,
      title: json['title'] as String,
      file: json['file'] as String,
    );
  }

  String get assetPath => 'assets/pdfs/$file';
}
