import 'package:flutter_test/flutter_test.dart';
import 'package:waec_wizzard/data/question_repository.dart';
import 'package:waec_wizzard/data/paper_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads mathematics 2000 questions from bundled asset', () async {
    final years = await QuestionRepository.instance.yearsFor('mathematics');
    expect(years, isNotEmpty);

    final questions = await QuestionRepository.instance.questionsFor('mathematics', '2000');
    expect(questions, isNotEmpty);
    expect(questions.first.options.length, 4);
  });

  test('loads papers manifest', () async {
    final papers = await PaperRepository.instance.papersFor('mathematics');
    expect(papers, isNotEmpty);
  });
}
