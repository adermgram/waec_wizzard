import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/question.dart';

/// Loads the bundled per-subject question banks (extracted from the original
/// app's hardcoded QuestionData.java into `assets/data/{subject}.json`) and
/// the manifest describing which years are available for each subject.
class QuestionRepository {
  QuestionRepository._();
  static final QuestionRepository instance = QuestionRepository._();

  Map<String, dynamic>? _manifest;
  final Map<String, Map<String, List<Question>>> _cache = {};

  Future<Map<String, dynamic>> _loadManifest() async {
    if (_manifest != null) return _manifest!;
    final raw = await rootBundle.loadString('assets/data/manifest.json');
    _manifest = jsonDecode(raw) as Map<String, dynamic>;
    return _manifest!;
  }

  /// Years (e.g. "2000" through "2005") that have a quiz question bank for [subjectSlug].
  Future<List<String>> yearsFor(String subjectSlug) async {
    final manifest = await _loadManifest();
    final entry = manifest[subjectSlug] as Map<String, dynamic>?;
    if (entry == null) return const [];
    return List<String>.from(entry['years'] as List);
  }

  Future<List<Question>> questionsFor(String subjectSlug, String year) async {
    final subjectYears = _cache[subjectSlug];
    if (subjectYears != null && subjectYears.containsKey(year)) {
      return subjectYears[year]!;
    }

    final raw = await rootBundle.loadString('assets/data/$subjectSlug.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    final bySlugCache = _cache.putIfAbsent(subjectSlug, () => {});
    for (final entry in decoded.entries) {
      final list = (entry.value as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList();
      bySlugCache[entry.key] = list;
    }

    return bySlugCache[year] ?? const [];
  }
}
