"""
One-off migration script: extracts the hardcoded question bank out of the old
Android app's QuestionData.java into structured JSON for the Flutter rebuild.

The `year` argument baked into many `new Question(...)` calls is unreliable
(a chunk of records pass a running question-index instead of the real year -
a bug in the original app). The enclosing `add<Subject>Questions<YEAR>(...)`
method name is the trustworthy source of subject + year, so we parse method
bodies rather than individual constructor args for that part.

Not part of the app itself - run once, commit the generated JSON, done.
"""
import io
import json
import re
import sys
from html import unescape
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

SRC = Path(r"C:\Users\aderm\Dev\MYApp\app\src\main\java\com\mudasiru\waecwizard\QuestionData.java")
OUT_DIR = Path(r"C:\Users\aderm\Dev\waec_wizzard\assets\data")

METHOD_SUBJECT_SLUGS = {
    "AgriculturalScience": "agriculture",
    "Biology": "biology",
    "Chemistry": "chemistry",
    "Commerce": "commerce",
    "Economics": "economics",
    "English": "english",
    "FinancialAccounting": "accounting",
    "Geography": "geography",
    "Government": "government",
    "Mathematics": "mathematics",
    "Physics": "physics",
}

SUBJECT_DISPLAY_NAMES = {
    "agriculture": "Agricultural Science",
    "biology": "Biology",
    "chemistry": "Chemistry",
    "commerce": "Commerce",
    "economics": "Economics",
    "english": "English Language",
    "accounting": "Financial Accounting",
    "geography": "Geography",
    "government": "Government",
    "mathematics": "Mathematics",
    "physics": "Physics",
}

METHOD_RE = re.compile(
    r"private static void add([A-Za-z]+)Questions(\d{4})\(List<Question> questions\)\s*\{"
)


def parse_java_string(lit: str) -> str:
    out = []
    i = 0
    while i < len(lit):
        c = lit[i]
        if c == "\\" and i + 1 < len(lit):
            nxt = lit[i + 1]
            if nxt == "n":
                out.append("\n")
                i += 2
                continue
            if nxt == "t":
                out.append("\t")
                i += 2
                continue
            if nxt in ('"', "\\"):
                out.append(nxt)
                i += 2
                continue
            out.append(nxt)  # unknown escape (LaTeX-ish \( \) \pi) - keep the char
            i += 2
            continue
        out.append(c)
        i += 1
    return "".join(out)


SUP_MAP = {
    "0": "\u2070", "1": "\u00b9", "2": "\u00b2", "3": "\u00b3", "4": "\u2074",
    "5": "\u2075", "6": "\u2076", "7": "\u2077", "8": "\u2078", "9": "\u2079",
    "+": "\u207a", "-": "\u207b", "n": "\u207f", "x": "\u02e3", "o": "\u1d52",
    "i": "\u2071",
}
SUB_MAP = {
    "0": "\u2080", "1": "\u2081", "2": "\u2082", "3": "\u2083", "4": "\u2084",
    "5": "\u2085", "6": "\u2086", "7": "\u2087", "8": "\u2088", "9": "\u2089",
}


def superscriptify(s: str) -> str:
    return "".join(SUP_MAP.get(ch, ch) for ch in s)


def subscriptify(s: str) -> str:
    return "".join(SUB_MAP.get(ch, ch) for ch in s)


def clean_html(raw: str) -> str:
    s = raw
    s = re.sub(r"<sup>(.*?)</sup>", lambda m: superscriptify(m.group(1)), s, flags=re.S)
    s = re.sub(r"<sub>(.*?)</sub>", lambda m: subscriptify(m.group(1)), s, flags=re.S)
    s = re.sub(r"</?p>", "", s)
    s = re.sub(r"<br\s*/?>", "\n", s)
    s = re.sub(r"<[^>]+>", "", s)
    s = s.replace("\\(", "").replace("\\)", "")
    s = s.replace("\\pi", "\u03c0")
    s = re.sub(r"\\frac\{([^{}]*)\}\{([^{}]*)\}", r"(\1/\2)", s)
    s = unescape(s)
    s = s.strip()
    s = re.sub(r"[ \t]+", " ", s)
    return s


def strip_line_comments(text: str) -> str:
    """Blank out `// ...` line comments, string-aware, preserving line/char positions."""
    out = list(text)
    in_str = False
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if in_str:
            if c == "\\" and i + 1 < n:
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            i += 1
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            j = i
            while j < n and text[j] != "\n":
                out[j] = " "
                j += 1
            i = j
            continue
        i += 1
    return "".join(out)


def find_matching_brace(text: str, open_pos: int) -> int:
    """Given index of an opening '{', return index of its matching '}',
    respecting string literals so braces inside e.g. \\frac{}{} don't confuse it."""
    depth = 0
    in_str = False
    i = open_pos
    while i < len(text):
        c = text[i]
        if in_str:
            if c == "\\" and i + 1 < len(text):
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            i += 1
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("unbalanced braces")


def split_top_level_args(s: str):
    args = []
    buf = []
    depth = 0
    in_str = False
    i = 0
    while i < len(s):
        c = s[i]
        if in_str:
            buf.append(c)
            if c == "\\" and i + 1 < len(s):
                buf.append(s[i + 1])
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            buf.append(c)
            i += 1
            continue
        if c in "([{":
            depth += 1
            buf.append(c)
            i += 1
            continue
        if c in ")]}":
            depth -= 1
            buf.append(c)
            i += 1
            continue
        if c == "," and depth == 0:
            args.append("".join(buf))
            buf = []
            i += 1
            continue
        buf.append(c)
        i += 1
    if buf:
        args.append("".join(buf))
    return args


def extract_calls(text: str):
    """Find every `new Question( ... )` call within `text`, balanced across lines."""
    calls = []
    marker = "new Question("
    idx = 0
    while True:
        start = text.find(marker, idx)
        if start == -1:
            break
        pos = start + len(marker)
        depth = 1
        in_str = False
        buf = []
        while pos < len(text) and depth > 0:
            c = text[pos]
            if in_str:
                buf.append(c)
                if c == "\\" and pos + 1 < len(text):
                    buf.append(text[pos + 1])
                    pos += 2
                    continue
                if c == '"':
                    in_str = False
                pos += 1
                continue
            if c == '"':
                in_str = True
                buf.append(c)
                pos += 1
                continue
            if c == "(":
                depth += 1
                buf.append(c)
                pos += 1
                continue
            if c == ")":
                depth -= 1
                if depth == 0:
                    break
                buf.append(c)
                pos += 1
                continue
            buf.append(c)
            pos += 1
        calls.append("".join(buf))
        idx = pos + 1
    return calls


def parse_field(raw: str):
    raw = raw.strip()
    if raw.startswith('"') and raw.endswith('"'):
        return clean_html(parse_java_string(raw[1:-1]))
    return raw


def main():
    text = strip_line_comments(SRC.read_text(encoding="utf-8"))

    by_subject_year = {}
    excluded = {}
    mismatches = 0
    total = 0
    unknown_methods = 0

    for m in METHOD_RE.finditer(text):
        method_subject, method_year = m.group(1), m.group(2)
        subject_slug = METHOD_SUBJECT_SLUGS.get(method_subject)
        if subject_slug is None:
            print("SKIP (unknown method subject):", method_subject)
            unknown_methods += 1
            continue

        body_start = m.end() - 1  # position of the opening '{'
        try:
            body_end = find_matching_brace(text, body_start)
        except ValueError as e:
            print(f"FAIL in add{method_subject}Questions{method_year}: {e} (starts at char {body_start})")
            raise
        body = text[body_start + 1 : body_end]

        for call in extract_calls(body):
            fields = split_top_level_args(call)
            if len(fields) != 8:
                snippet = call[:150].encode("ascii", "replace").decode("ascii")
                print("SKIP (unexpected arg count):", len(fields), snippet)
                continue
            question, opt1, opt2, opt3, opt4, correct, _subject_raw, _year_raw = (
                parse_field(f) for f in fields
            )
            options = [opt1, opt2, opt3, opt4]
            try:
                answer_index = options.index(correct)
            except ValueError:
                # Inherited data bug from the old app: the "correct" text doesn't
                # match any option, so the question was unanswerable there too.
                # Drop it from the shipped bank rather than carry it forward broken.
                mismatches += 1
                excluded.setdefault(subject_slug, {}).setdefault(method_year, []).append(
                    {"question": question, "options": options, "correctRaw": correct}
                )
                continue

            record = {"question": question, "options": options, "answerIndex": answer_index}
            by_subject_year.setdefault(subject_slug, {}).setdefault(method_year, []).append(record)
            total += 1

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = {}
    for subject_slug, years in by_subject_year.items():
        manifest[subject_slug] = {
            "name": SUBJECT_DISPLAY_NAMES[subject_slug],
            "years": sorted(years.keys()),
        }
        out_path = OUT_DIR / f"{subject_slug}.json"
        out_path.write_text(json.dumps(years, ensure_ascii=False, indent=1), encoding="utf-8")
        count = sum(len(v) for v in years.values())
        print(f"{subject_slug}: {count} questions across years {sorted(years.keys())}")

    (OUT_DIR / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=1), encoding="utf-8"
    )
    (OUT_DIR / "_excluded_broken.json").write_text(
        json.dumps(excluded, ensure_ascii=False, indent=1), encoding="utf-8"
    )

    print(f"\nTOTAL questions written: {total}")
    print(f"Excluded (correct answer text didn't match any option - bad source data): {mismatches}")
    print(f"Unknown methods skipped: {unknown_methods}")


if __name__ == "__main__":
    main()
