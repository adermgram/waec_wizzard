import 'package:flutter/material.dart';

class Subject {
  final String slug;
  final String name;
  final IconData icon;
  final Color color;

  const Subject({
    required this.slug,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// The 11 WAEC subjects carried over from the original question bank.
const List<Subject> kSubjects = [
  Subject(slug: 'mathematics', name: 'Mathematics', icon: Icons.functions, color: Color(0xFF4C6EF5)),
  Subject(slug: 'english', name: 'English Language', icon: Icons.menu_book, color: Color(0xFFE8590C)),
  Subject(slug: 'physics', name: 'Physics', icon: Icons.bolt, color: Color(0xFF1971C2)),
  Subject(slug: 'chemistry', name: 'Chemistry', icon: Icons.science, color: Color(0xFF2F9E44)),
  Subject(slug: 'biology', name: 'Biology', icon: Icons.eco, color: Color(0xFF37B24D)),
  Subject(slug: 'government', name: 'Government', icon: Icons.account_balance, color: Color(0xFF862E9C)),
  Subject(slug: 'accounting', name: 'Financial Accounting', icon: Icons.calculate, color: Color(0xFFF08C00)),
  Subject(slug: 'commerce', name: 'Commerce', icon: Icons.storefront, color: Color(0xFFD9480F)),
  Subject(slug: 'economics', name: 'Economics', icon: Icons.trending_up, color: Color(0xFF0CA678)),
  Subject(slug: 'agriculture', name: 'Agricultural Science', icon: Icons.agriculture, color: Color(0xFF66A80F)),
  Subject(slug: 'geography', name: 'Geography', icon: Icons.public, color: Color(0xFF1098AD)),
];

Subject subjectBySlug(String slug) =>
    kSubjects.firstWhere((s) => s.slug == slug, orElse: () => kSubjects.first);
