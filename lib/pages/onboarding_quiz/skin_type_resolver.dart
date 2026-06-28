/// Deterministic "не знаю свой тип кожи" resolver.
///
/// Maps the three lifestyle micro-questions (spec §2, step 1b) to exactly one
/// of the four base skin types. Pure and side-effect-free so it can be unit
/// tested and reused. See docs/onboarding_spec.md in the backend repo.

/// Midday shine across the face.
enum ShineLevel { none, tzone, all }

/// Tightness right after washing.
enum TightLevel { no, some, strong }

/// Visible pores.
enum PoreLevel { none, tzone, wide }

/// Resolves the base skin type from the three answers.
///
/// Rules are evaluated top-down, first match wins (27 combinations → one of
/// 'dry' | 'oily' | 'combination' | 'normal'):
///   1. shine=all OR pores=wide              → oily
///   2. shine=tzone OR pores=tzone           → combination
///   3. tight=strong                         → dry
///   4. tight=some AND shine=none AND pores=none → dry
///   5. otherwise                            → normal
String resolveSkinType({
  required ShineLevel shine,
  required TightLevel tight,
  required PoreLevel pores,
}) {
  if (shine == ShineLevel.all || pores == PoreLevel.wide) {
    return 'oily';
  }
  if (shine == ShineLevel.tzone || pores == PoreLevel.tzone) {
    return 'combination';
  }
  if (tight == TightLevel.strong) {
    return 'dry';
  }
  if (tight == TightLevel.some &&
      shine == ShineLevel.none &&
      pores == PoreLevel.none) {
    return 'dry';
  }
  return 'normal';
}
