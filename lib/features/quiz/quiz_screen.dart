import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../data/question_repository.dart';
import '../../models/question.dart';
import '../../models/subject.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Subject subject;
  final String year;

  const QuizScreen({super.key, required this.subject, required this.year});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final Future<List<Question>> _future;
  final AudioPlayer _player = AudioPlayer();

  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  final List<int> _givenAnswers = [];

  @override
  void initState() {
    super.initState();
    _future = QuestionRepository.instance.questionsFor(widget.subject.slug, widget.year);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _selectOption(Question question, int optionIndex) {
    if (_answered) return;
    final correct = optionIndex == question.answerIndex;
    setState(() {
      _selected = optionIndex;
      _answered = true;
      _givenAnswers.add(optionIndex);
      if (correct) _score++;
    });
    _player.play(AssetSource(correct ? 'audio/correct.mp3' : 'audio/wrong.mp3'));
  }

  void _next(int total, List<Question> questions) {
    if (_index + 1 >= total) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            subject: widget.subject,
            year: widget.year,
            score: _score,
            total: total,
            questions: questions,
            givenAnswers: _givenAnswers,
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit quiz?'),
        content: const Text('Your progress on this attempt will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quit')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text('${widget.subject.name} · ${widget.year}')),
        body: FutureBuilder<List<Question>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final questions = snapshot.data!;
            if (questions.isEmpty) {
              return const Center(child: Text('No questions found for this selection.'));
            }
            final question = questions[_index];
            final total = questions.length;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_index + 1) / total,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceContainerHigh,
                        color: widget.subject.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Question ${_index + 1} of $total',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.text,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 20),
                            for (var i = 0; i < question.options.length; i++) ...[
                              _OptionTile(
                                label: question.options[i],
                                state: _stateFor(question, i),
                                onTap: () => _selectOption(question, i),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _answered ? () => _next(total, questions) : null,
                        child: Text(_index + 1 >= total ? 'Finish' : 'Next question'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _OptionState _stateFor(Question question, int optionIndex) {
    if (!_answered) return _OptionState.idle;
    if (optionIndex == question.answerIndex) return _OptionState.correct;
    if (optionIndex == _selected) return _OptionState.wrong;
    return _OptionState.disabled;
  }
}

enum _OptionState { idle, correct, wrong, disabled }

class _OptionTile extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({required this.label, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color background = scheme.surfaceContainerHigh;
    Color border = Colors.transparent;
    Color foreground = scheme.onSurface;
    IconData? icon;

    switch (state) {
      case _OptionState.idle:
        break;
      case _OptionState.correct:
        background = scheme.primaryContainer;
        border = scheme.primary;
        icon = Icons.check_circle;
        break;
      case _OptionState.wrong:
        background = scheme.errorContainer;
        border = scheme.error;
        icon = Icons.cancel;
        break;
      case _OptionState.disabled:
        foreground = scheme.onSurfaceVariant;
        break;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: state == _OptionState.idle ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(color: foreground, fontSize: 15))),
              if (icon != null) Icon(icon, color: border),
            ],
          ),
        ),
      ),
    );
  }
}
