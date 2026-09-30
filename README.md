# WAEC Wizard

An offline study companion for WAEC past questions, built with Flutter. Rebuilt from
the ground up as a modern, multiplatform replacement for an older single-platform
Android/Java app.

## Features

- **Practice Quiz** — multiple-choice past questions across 11 subjects (English,
  Mathematics, Physics, Chemistry, Biology, Government, Financial Accounting,
  Commerce, Economics, Agricultural Science, Geography), spanning 2000–2005, with
  a review-answers screen after each attempt showing what was missed and why.
- **Theory & Past Papers** — bundled past-paper PDFs per subject, viewed in-app.
- **Calculator** — a scientific calculator (trig, inverse trig, logs, powers,
  roots, constants, DEG/RAD toggle) built on a real expression parser rather than
  an `eval`-style hack.

Everything works fully offline — no network calls, no accounts, no analytics.

## Project structure

```
lib/
  models/        Plain data classes (Question, Subject, Paper)
  data/          Repositories that load bundled JSON assets
  features/      One folder per screen/flow (home, quiz, theory, calculator)
  theme/         App-wide Material 3 theme
assets/
  data/          Question banks + subject/paper manifests (JSON)
  pdfs/          Bundled past-paper PDFs
  audio/         Correct/wrong sound effects
  icon/          Launcher icon source images (carried over from the original
                 app's ic_launcher-playstore.png / adaptive icon foreground)
tool/
  extract_questions.py   One-off migration script - see below
```

## Where the question bank came from

The original Android app kept its ~3,000-question bank hardcoded inside a single
4,760-line Java file (`QuestionData.java`), including a data-entry bug where a
chunk of records had a running question-index in place of the actual year, and
~170 questions whose "correct answer" text didn't match any of the 4 listed
options (so they were unanswerable even in the original app).

`tool/extract_questions.py` parses that file directly, recovers the correct
year from each method's name rather than the buggy embedded argument, and drops
the ~170 broken records (kept for reference in
`tool/excluded_broken_questions.json`, not shipped in the app) rather than
carrying broken quiz questions into the rebuild. Run it once if the source data
ever changes; the output already lives in `assets/data/`.

## Running

```
flutter pub get
flutter run
```

## Testing

```
flutter analyze
flutter test
```

Covers the calculator's expression engine and UI, and the question/paper
repositories. The quiz, review-answers, and theory/PDF-viewer screens are
currently verified manually rather than with automated widget tests.
