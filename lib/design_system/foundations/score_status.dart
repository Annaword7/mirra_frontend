import 'package:flutter/material.dart';

/// Semantic color + score/status foundation (Design Review Initiative 4).
///
/// Single source of truth for the product **score ramp**, the ingredient
/// **status palette**, and their **non-color cues** (grade letter / icon).
/// Before this file the same logic was copy-pasted and *contradicted itself*
/// across the app:
///   • the 5-tier score ramp lived in 3 files (share_card, imagedetailed_main,
///     imagedetailed_top_raited);
///   • `working`/`borderline`/`decorative` were colored three different ways
///     (product_card_v2, score_breakdown painter, ingredient_bubbles) — most
///     notably `working` was green on two surfaces but amber on a third.
///
/// These are **pure, context-free functions** (const palette) so painters and
/// non-widget code can use them without a `BuildContext`. The app has a single
/// light theme, so there is no dark-mode branching.

// ── Score ramp (0–100) ───────────────────────────────────────────────────────
// Canonical 5-tier ramp (the value already used by the 3 duplicated sites).
const Color kScoreA = Color(0xFF1B5E20); // ≥75  dark green
const Color kScoreB = Color(0xFF43A047); // ≥65  green
const Color kScoreC = Color(0xFFC0CA33); // ≥55  lime
const Color kScoreD = Color(0xFFFFB300); // ≥45  amber
const Color kScoreE = Color(0xFFFF7043); // ≥35  orange
const Color kScoreF = Color(0xFFD32F2F); // <35  red

/// Color for a 0–100 product score.
Color semanticScoreColor(num score) {
  if (score >= 75) return kScoreA;
  if (score >= 65) return kScoreB;
  if (score >= 55) return kScoreC;
  if (score >= 45) return kScoreD;
  if (score >= 35) return kScoreE;
  return kScoreF;
}

/// Letter grade for a 0–100 product score. Doubles as the score's **non-color
/// cue** (redundant with [semanticScoreColor] for color-blind users).
String scoreGrade(num score) {
  if (score >= 75) return 'A';
  if (score >= 65) return 'B';
  if (score >= 55) return 'C';
  if (score >= 45) return 'D';
  if (score >= 35) return 'E';
  return 'F';
}

// ── Ingredient status palette ────────────────────────────────────────────────
// Canonical mapping (approved): working = good → green, borderline = amber,
// decorative & unknown = grey.
const Color kStatusWorking = Color(0xFF1B5E20); // green — good for the skin
const Color kStatusBorderline = Color(0xFFFFB300); // amber — on the edge
const Color kStatusDecorative = Color(0xFF9E9E9E); // grey — decorative only
const Color kStatusUnknown = Color(0xFFBDBDBD); // grey — status unknown

/// Accent color for an ingredient status (`working` / `borderline` /
/// `decorative`); anything else is treated as unknown.
Color statusColor(String? status) => switch (status) {
      'working' => kStatusWorking,
      'borderline' => kStatusBorderline,
      'decorative' => kStatusDecorative,
      _ => kStatusUnknown,
    };

/// Icon for an ingredient status — the status's **non-color cue** so meaning
/// is not carried by color alone.
IconData statusIcon(String? status) => switch (status) {
      'working' => Icons.check_circle_rounded,
      'borderline' => Icons.warning_amber_rounded,
      'decorative' => Icons.remove_circle_outline_rounded,
      _ => Icons.help_outline_rounded,
    };
