#!/usr/bin/env python3
"""
Mirra i18n translator.

Fills missing language entries in `kTranslationsMap` inside
lib/flutter_flow/internationalization.dart using an LLM, preserving the file's
existing structure, comments and ordering (diffs are additions only).

Source of truth stays the Dart map — we do NOT migrate to .arb. The map is parsed
with a small Dart-string-aware tokenizer (handles escaped quotes, multi-line
wrapped values and adjacent string concatenation produced by `dart format`).

Usage:
    OPENAI_API_KEY=... python3 tools/i18n/translate.py --langs de
    python3 tools/i18n/translate.py --langs de,fr,ja --model gpt-4.1
    python3 tools/i18n/translate.py --langs de --dry-run      # report only
    python3 tools/i18n/translate.py --langs de --mock         # no API, placeholder text

After running, verify with: `dart format <file>` and `flutter analyze`.
"""

import argparse
import json
import os
import sys
from dataclasses import dataclass, field

DEFAULT_FILE = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "lib",
    "flutter_flow",
    "internationalization.dart",
)

START_MARKER = "final kTranslationsMap = <Map<String, Map<String, String>>>["
END_MARKER = "].reduce("

LANG_NAMES = {
    "en": "English", "ru": "Russian", "es": "Spanish", "de": "German",
    "fr": "French", "it": "Italian", "pt": "Portuguese", "zh": "Chinese (Simplified)",
    "ja": "Japanese", "ko": "Korean", "tr": "Turkish", "nl": "Dutch", "pl": "Polish",
    "id": "Indonesian", "th": "Thai", "vi": "Vietnamese", "ar": "Arabic", "hi": "Hindi",
    "uk": "Ukrainian", "sv": "Swedish", "da": "Danish", "cs": "Czech", "fi": "Finnish",
    "no": "Norwegian", "ro": "Romanian", "hu": "Hungarian", "el": "Greek", "he": "Hebrew",
    "ms": "Malay", "ca": "Catalan", "hr": "Croatian", "sk": "Slovak",
}

# Brand terms that must never be translated.
DO_NOT_TRANSLATE = ["Mirra", "INCI", "PRO", "Key Facts"]

LANG_INDENT = "      "  # 6 spaces — matches `      'en':` inside each key map.


# ----------------------------------------------------------------------------
# Dart-string-aware tokenizer for the kTranslationsMap region
# ----------------------------------------------------------------------------

@dataclass
class Token:
    type: str   # 'STR' | '{' | '}' | '[' | ']' | ':' | ','
    value: str  # decoded text for STR, else the punctuation char
    start: int  # absolute index in the full source
    end: int    # absolute index just past the token


_ESCAPES = {"n": "\n", "t": "\t", "r": "\r", "b": "\b", "f": "\f",
            "'": "'", '"': '"', "\\": "\\", "$": "$", "/": "/"}


def _decode_string(src, i):
    """Parse a single-quoted Dart string starting at src[i] == \"'\". Returns (value, end)."""
    assert src[i] == "'"
    out = []
    i += 1
    while i < len(src):
        c = src[i]
        if c == "\\":
            nxt = src[i + 1]
            if nxt == "u":
                if src[i + 2] == "{":
                    j = src.index("}", i + 3)
                    out.append(chr(int(src[i + 3:j], 16)))
                    i = j + 1
                else:
                    out.append(chr(int(src[i + 2:i + 6], 16)))
                    i += 6
                continue
            out.append(_ESCAPES.get(nxt, nxt))
            i += 2
            continue
        if c == "'":
            return "".join(out), i + 1
        out.append(c)
        i += 1
    raise ValueError("unterminated string literal at %d" % i)


def tokenize(src, region_start, region_end):
    """Tokenize src[region_start:region_end]; positions are absolute."""
    tokens = []
    i = region_start
    while i < region_end:
        c = src[i]
        if c in " \t\r\n":
            i += 1
        elif c == "/" and src[i + 1] == "/":
            nl = src.find("\n", i)
            i = region_end if nl == -1 else nl
        elif c in "{}[]:,":
            tokens.append(Token(c, c, i, i + 1))
            i += 1
        elif c == "'":
            value, end = _decode_string(src, i)
            tokens.append(Token("STR", value, i, end))
            i = end
        else:
            raise ValueError("unexpected char %r at %d" % (c, i))
    return tokens


@dataclass
class Entry:
    key: str
    langs: dict            # lang_code -> decoded value
    insert_at: int         # absolute index where new lang lines are inserted
    had_trailing_comma: bool


def parse_entries(tokens):
    """Find `'<key>': { '<lang>': '<value>', ... }` entries."""
    entries = []
    i, n = 0, len(tokens)
    while i < n:
        if (tokens[i].type == "STR" and i + 2 < n
                and tokens[i + 1].type == ":" and tokens[i + 2].type == "{"):
            key = tokens[i].value
            j = i + 3
            langs, insert_at, had_comma = {}, None, False
            while tokens[j].type != "}":
                lang = tokens[j].value
                assert tokens[j + 1].type == ":", "expected ':' after lang %r" % lang
                k = j + 2
                parts, val_end = [], None
                while tokens[k].type == "STR":           # adjacent string concat
                    parts.append(tokens[k].value)
                    val_end = tokens[k].end
                    k += 1
                langs[lang] = "".join(parts)
                if tokens[k].type == ",":
                    insert_at, had_comma = tokens[k].end, True
                    k += 1
                else:
                    insert_at, had_comma = val_end, False
                j = k
            entries.append(Entry(key, langs, insert_at, had_comma))
            i = j + 1
            if i < n and tokens[i].type == ",":
                i += 1
        else:
            i += 1
    return entries


# ----------------------------------------------------------------------------
# Encoding + translation
# ----------------------------------------------------------------------------

def dart_escape(s):
    s = s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
    s = s.replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
    return s


def lang_name(code):
    return LANG_NAMES.get(code, code)


def build_system_prompt(source, target):
    dnt = ", ".join("'%s'" % t for t in DO_NOT_TRANSLATE)
    return (
        "You are a professional mobile-app localization translator for 'Mirra', a "
        "skincare cosmetic-ingredient analyzer app. Translate short UI strings from "
        f"{lang_name(source)} to {lang_name(target)}.\n"
        "Rules:\n"
        f"- Keep brand/product terms untranslated: {dnt}.\n"
        "- Keep proper nouns and cosmetic INCI ingredient names (Latin) as-is.\n"
        "- Natural, concise wording suited to a mobile UI; keep length close to the source.\n"
        "- Preserve placeholders, emoji, punctuation, capitalization style and any "
        "leading/trailing whitespace.\n"
        "- Preserve line breaks: '\\n' in the input must stay '\\n' in the output.\n"
        "- Return only the translation, no quotes or commentary.\n"
        'Respond as JSON: {"translations": ["...", ...]} preserving the input order and count.'
    )


def translate_batch(texts, source, target, model, client):
    messages = [
        {"role": "system", "content": build_system_prompt(source, target)},
        {"role": "user", "content": json.dumps({"strings": texts}, ensure_ascii=False)},
    ]
    resp = client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=0,
        response_format={"type": "json_object"},
    )
    data = json.loads(resp.choices[0].message.content)
    out = data.get("translations")
    if not isinstance(out, list) or len(out) != len(texts):
        raise RuntimeError(
            "model returned %s translations for %d inputs" % (
                len(out) if isinstance(out, list) else "non-list", len(texts)))
    return out


def translate_robust(texts, source, target, model, client):
    """Batch translate, tolerant to the model returning a wrong item count.

    Retries the batch once, then falls back to per-item translation (a size-1
    request reliably returns exactly one item). Last resort keeps the source
    string, which the app renders via its English fallback."""
    for attempt in range(2):
        try:
            return translate_batch(texts, source, target, model, client)
        except (RuntimeError, json.JSONDecodeError, ValueError):
            if attempt == 0:
                continue
    out = []
    for item in texts:
        try:
            r = translate_batch([item], source, target, model, client)
            out.append(r[0] if r else item)
        except Exception:
            out.append(item)
    return out


def chunked(seq, size):
    for i in range(0, len(seq), size):
        yield seq[i:i + size]


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description="Fill missing translations in kTranslationsMap.")
    ap.add_argument("--file", default=DEFAULT_FILE)
    ap.add_argument("--langs", required=True, help="comma-separated target codes, e.g. de,fr,ja")
    ap.add_argument("--source", default="en")
    ap.add_argument("--model", default=os.environ.get("MIRRA_I18N_MODEL", "gpt-4.1"))
    ap.add_argument("--batch-size", type=int, default=40)
    ap.add_argument("--dry-run", action="store_true", help="report counts, write nothing")
    ap.add_argument("--mock", action="store_true", help="no API; insert «<lang>» placeholder text")
    args = ap.parse_args()

    targets = [c.strip() for c in args.langs.split(",") if c.strip()]
    with open(args.file, encoding="utf-8") as f:
        text = f.read()

    start = text.index(START_MARKER) + len(START_MARKER)
    end = text.index(END_MARKER, start)
    tokens = tokenize(text, start, end)
    entries = parse_entries(tokens)
    print("Parsed %d translation keys." % len(entries))

    # Collect tasks: (entry, lang) needing translation, deduped source text per lang.
    per_lang_missing = {t: [] for t in targets}     # lang -> list[Entry]
    for e in entries:
        src = e.langs.get(args.source, "")
        if not src:
            continue
        for t in targets:
            cur = e.langs.get(t, "")
            if not cur:
                per_lang_missing[t].append(e)

    total_missing = sum(len(v) for v in per_lang_missing.values())
    for t in targets:
        print("  %s: %d missing" % (t, len(per_lang_missing[t])))
    if total_missing == 0:
        print("Nothing to translate.")
        return
    if args.dry_run:
        print("Dry run — no changes written.")
        return

    client = None
    if not args.mock:
        try:
            from openai import OpenAI
        except ImportError:
            sys.exit("openai package not installed. Run: pip install openai")
        api_key = os.environ.get("OPENAI_API_KEY") or os.environ.get("MIRRAOPENAIKEYWEBSEARCH")
        if not api_key:
            sys.exit("Set OPENAI_API_KEY (or MIRRAOPENAIKEYWEBSEARCH), or use --mock.")
        client = OpenAI(api_key=api_key)

    # entry.key -> {lang: translated_value} to insert
    additions = {}
    for t in targets:
        ents = per_lang_missing[t]
        if not ents:
            continue
        # Dedupe identical source strings to save API calls.
        uniq = {}
        for e in ents:
            uniq.setdefault(e.langs[args.source], None)
        sources = list(uniq.keys())
        print("Translating %d unique strings -> %s ..." % (len(sources), t))
        for batch in chunked(sources, args.batch_size):
            if args.mock:
                results = ["«%s» %s" % (t, s) for s in batch]
            else:
                results = translate_robust(batch, args.source, t, args.model, client)
            for s, r in zip(batch, results):
                uniq[s] = r
        for e in ents:
            additions.setdefault(e.key, {})[t] = uniq[e.langs[args.source]]

    # Build insertions: (position, text). Apply high -> low so offsets stay valid.
    inserts = []
    by_key = {e.key: e for e in entries}
    added = 0
    for key, lang_map in additions.items():
        e = by_key[key]
        chunk = ""
        for t in targets:
            if t in lang_map:
                chunk += "\n%s'%s': '%s'," % (LANG_INDENT, t, dart_escape(lang_map[t]))
                added += 1
        if not e.had_trailing_comma:
            chunk = "," + chunk
        inserts.append((e.insert_at, chunk))

    inserts.sort(key=lambda x: x[0], reverse=True)
    new_text = text
    for pos, chunk in inserts:
        new_text = new_text[:pos] + chunk + new_text[pos:]

    with open(args.file, "w", encoding="utf-8") as f:
        f.write(new_text)
    print("Inserted %d translations across %d keys into %s"
          % (added, len(additions), args.file))
    print("Now run: dart format %s && flutter analyze" % args.file)


if __name__ == "__main__":
    main()
