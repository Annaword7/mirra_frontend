/// Shared layout constants (Design Review Initiative 13).
///
/// The bottom nav bar height is the anchor other layouts should reference so
/// magic offsets stay coordinated (review B13). Note: the team rewrote the
/// navbar since the review (height is now 121, not the review's 108), so the
/// capture-screen offsets that hand-tune around it (takeor_upload's
/// `bottom: 320` illustration + `bottom: 100 + safeArea` action zone) should be
/// re-derived from this constant only after a navbar re-review + on-device check
/// — not blind — and are intentionally left untouched here.
library;

/// Height of the bottom navigation bar (`navbar_widget`).
const double kNavBarHeight = 121.0;
