import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/paper.dart';

/// Loads the bundled past-paper PDF manifest (assets/data/papers.json).
class PaperRepository {
  PaperRepository._();
  static final PaperRepository instance = PaperRepository._();

  List<Paper>? _papers;

  Future<List<Paper>> _loadAll() async {
    if (_papers != null) return _papers!;
    final raw = await rootBundle.loadString('assets/data/papers.json');
    final decoded = jsonDecode(raw) as List;
    _papers = decoded.map((e) => Paper.fromJson(e as Map<String, dynamic>)).toList();
    return _papers!;
  }

  Future<List<Paper>> papersFor(String subjectSlug) async {
    final all = await _loadAll();
    return all.where((p) => p.subjectSlug == subjectSlug).toList();
  }

  /// Subject slugs that have at least one bundled paper.
  Future<Set<String>> availableSubjects() async {
    final all = await _loadAll();
    return all.map((p) => p.subjectSlug).toSet();
  }
}
