import '/backend/supabase/database/tables/users.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'search_widget.dart' show SearchWidget;
import 'package:flutter/material.dart';

class SearchModel extends FlutterFlowModel<SearchWidget> {
  // ── NL input ────────────────────────────────────────────────────────────────
  FocusNode? phraseFocusNode;
  TextEditingController? phraseController;
  String phraseValidationError = '';

  // ── Facets & sort ────────────────────────────────────────────────────────────
  // facetName → selected value keys
  Map<String, Set<String>> activeFacets = {};
  String sortMode = 'fit';

  // ── Request state ────────────────────────────────────────────────────────────
  bool isParsing = false;
  bool isSearching = false;
  String unparsed = '';

  // ── Results ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> results = [];
  int totalCount = 0;
  String? nextCursor;
  bool hasMore = false;
  String? narrowestFacet;
  bool hasSearched = false;

  // ── User profile (for fit scoring) ──────────────────────────────────────────
  UsersRow? userProfile;

  Map<String, dynamic> buildProfile() => {
        'skin_type': userProfile?.skinType,
        'goals': userProfile?.skinGoals ?? [],
        'sensitivity': userProfile?.skinSensitivity ?? false,
        'acne_prone': userProfile?.acneProne ?? false,
      };

  Map<String, List<String>> buildFacetsBody() {
    final out = <String, List<String>>{};
    activeFacets.forEach((k, v) {
      if (v.isNotEmpty) out[k] = v.toList();
    });
    return out;
  }

  bool get hasAnyFacet => activeFacets.values.any((s) => s.isNotEmpty);

  @override
  void initState(BuildContext context) {
    phraseController = TextEditingController();
    phraseFocusNode = FocusNode();
  }

  @override
  void dispose() {
    phraseController?.dispose();
    phraseFocusNode?.dispose();
  }
}
