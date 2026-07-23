import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/countryselector/countryselector_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_language_selector.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/design_system/components/app_text_field.dart';
import '/design_system/components/app_button.dart';
import 'dart:async';
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'onboarding_profile_model.dart';
export 'onboarding_profile_model.dart';

class OnboardingProfileWidget extends StatefulWidget {
  const OnboardingProfileWidget({super.key});

  static String routeName = 'Onboarding_Profile';
  static String routePath = '/onboardingProfile';

  @override
  State<OnboardingProfileWidget> createState() =>
      _OnboardingProfileWidgetState();
}

class _OnboardingProfileWidgetState extends State<OnboardingProfileWidget>
    with TickerProviderStateMixin {
  late OnboardingProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Type scale — same 3 sizes as the quiz step.
  static const double _fsTitle = 24;
  static const double _fsBody = 16;
  static const double _fsSub = 13;
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  final animationsMap = <String, AnimationInfo>{};

  static const _avatarUrls = [
    'https://pjapsfbztorijypnldam.supabase.co/storage/v1/object/public/images/avatars/image2.png',
    'https://pjapsfbztorijypnldam.supabase.co/storage/v1/object/public/images/avatars/image4.png',
    'https://pjapsfbztorijypnldam.supabase.co/storage/v1/object/public/images/avatars/image6.png',
    'https://pjapsfbztorijypnldam.supabase.co/storage/v1/object/public/images/avatars/image5.png',
    'https://pjapsfbztorijypnldam.supabase.co/storage/v1/object/public/images/avatars/image7.png',
    'https://pjapsfbztorijypnldam.supabase.co/storage/v1/object/public/images/avatars/image8.png',
    'https://pjapsfbztorijypnldam.supabase.co/storage/v1/object/public/images/avatars/image9.png',
    'https://pjapsfbztorijypnldam.supabase.co/storage/v1/object/public/images/avatars/image10.png',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingProfileModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() => _isKeyboardVisible = visible);
      });
    }

    _model.firstNameTextController ??= TextEditingController();
    _model.firstNameFocusNode ??= FocusNode();
    _model.lastNameTextController ??= TextEditingController();
    _model.lastNameFocusNode ??= FocusNode();

    // Generate random suggestions immediately; update to name-based once both fields are filled.
    _model.username1 = 'user${random_data.randomInteger(1000, 9999)}';
    _model.username2 = 'scan${random_data.randomInteger(100, 999)}';
    _model.username3 = 'health${random_data.randomInteger(10, 99)}';

    _model.lastNameFocusNode!.addListener(() async {
      final fn = _model.firstNameTextController.text;
      final ln = _model.lastNameTextController.text;
      if (fn.isEmpty || ln.isEmpty) return;
      _model.username1 = '$fn${ln[0]}${random_data.randomInteger(10, 99)}';
      _model.username2 = '${fn[0]}$ln${random_data.randomInteger(10, 99)}';
      _model.username3 = '$fn${random_data.randomInteger(1000, 9999)}';
      safeSetState(() {});
    });
    _model.nicknameTextController ??= TextEditingController();
    _model.nicknameFocusNode ??= FocusNode();

    animationsMap.addAll({
      'columnOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    if (!isWeb) _keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      storageFolderPath: 'user_profile_images',
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 90,
      allowPhoto: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      textColor: FlutterFlowTheme.of(context).primaryText,
      pickerFontFamily: 'Sora',
    );
    if (selectedMedia == null) return;
    if (!selectedMedia
        .every((m) => validateFileFormat(m.storagePath, context))) return;

    safeSetState(() => _model.isDataUploading_uploadDataCvi2 = true);
    var selectedUploadedFiles = <FFUploadedFile>[];
    var downloadUrls = <String>[];
    try {
      selectedUploadedFiles = selectedMedia
          .map((m) => FFUploadedFile(
                name: m.storagePath.split('/').last,
                bytes: m.bytes,
                height: m.dimensions?.height,
                width: m.dimensions?.width,
                blurHash: m.blurHash,
                originalFilename: m.originalFilename,
              ))
          .toList();
      downloadUrls = await uploadSupabaseStorageFiles(
        bucketName: 'images',
        selectedFiles: selectedMedia,
      );
    } finally {
      _model.isDataUploading_uploadDataCvi2 = false;
    }
    if (selectedUploadedFiles.length == selectedMedia.length &&
        downloadUrls.length == selectedMedia.length) {
      safeSetState(() {
        _model.uploadedLocalFile_uploadDataCvi2 = selectedUploadedFiles.first;
        _model.uploadedFileUrl_uploadDataCvi2 = downloadUrls.first;
      });
    } else {
      safeSetState(() {});
      return;
    }
    if (_model.uploadedFileUrl_uploadDataCvi2.isNotEmpty) {
      _model.profilePicture = _model.uploadedFileUrl_uploadDataCvi2;
      safeSetState(() {});
    }
  }

  // ─────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────

  Widget _sectionCard(Widget child) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: FlutterFlowTheme.of(context).labelSmall.override(
            fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: _fsSub,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
          ),
    );
  }

  // ─────────────────────────────────────────────
  // Section builders
  // ─────────────────────────────────────────────

  Widget _buildAvatarSection() {
    final theme = FlutterFlowTheme.of(context);
    final hasPhoto =
        _model.profilePicture != null && _model.profilePicture!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(FFLocalizations.of(context).getText('7s3y7mvj')),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Upload circle with camera badge
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.alternate,
                      image: hasPhoto
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(_model.profilePicture!),
                            )
                          : null,
                      border: Border.all(
                        color: hasPhoto ? theme.primary : theme.alternate,
                        width: 2,
                      ),
                    ),
                    child: hasPhoto
                        ? null
                        : Icon(Icons.person_rounded,
                            color: theme.secondaryText, size: 36),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.secondaryBackground, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Preset avatars
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _avatarUrls.map((url) {
                  final selected = _model.profilePicture == url;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      safeSetState(() => _model.profilePicture = url);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? theme.primary : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    Widget nameField({
      required TextEditingController? controller,
      required FocusNode focusNode,
      required String hintKey,
      required String autofill,
      required FormFieldValidator<String>? validator,
    }) {
      return AppTextField(
        controller: controller,
        focusNode: focusNode,
        hintText: FFLocalizations.of(context).getText(hintKey),
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        autofillHints: [autofill],
        validator: validator,
        inputFormatters: [
          if (!isAndroid && !isiOS)
            TextInputFormatter.withFunction((oldValue, newValue) {
              return TextEditingValue(
                selection: newValue.selection,
                text: newValue.text
                    .toCapitalization(TextCapitalization.words),
              );
            }),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Your name'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: nameField(
                controller: _model.firstNameTextController,
                focusNode: _model.firstNameFocusNode!,
                hintKey: '806chf8j',
                autofill: AutofillHints.givenName,
                validator: _model.firstNameTextControllerValidator
                    .asValidator(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: nameField(
                controller: _model.lastNameTextController,
                focusNode: _model.lastNameFocusNode!,
                hintKey: '3s25dejy',
                autofill: AutofillHints.familyName,
                validator: _model.lastNameTextControllerValidator
                    .asValidator(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsernameSection() {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Username'),
        const SizedBox(height: 10),
        AppTextField(
          controller: _model.nicknameTextController,
          focusNode: _model.nicknameFocusNode,
          onChanged: (_) => EasyDebounce.debounce(
            '_model.nicknameTextController',
            const Duration(milliseconds: 400),
            () => safeSetState(() {}),
          ),
          textInputAction: TextInputAction.next,
          hintText: FFLocalizations.of(context).getText('r07lmjc9'),
          maxLength: 20,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          showCounter: false,
          validator:
              _model.nicknameTextControllerValidator.asValidator(context),
          inputFormatters: [
            if (!isAndroid && !isiOS)
              TextInputFormatter.withFunction((oldValue, newValue) {
                return TextEditingValue(
                  selection: newValue.selection,
                  text: newValue.text
                      .toCapitalization(TextCapitalization.none),
                );
              }),
          ],
        ),
        ...[
          const SizedBox(height: 10),
          Text(
            FFLocalizations.of(context).getText('razzzfb3'),
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              fontSize: _fsSub,
              color: theme.primaryText,
              letterSpacing: 0,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _usernameChip(_model.username1),
              _usernameChip(_model.username2),
              _usernameChip(_model.username3),
            ],
          ),
        ],
      ],
    );
  }

  Widget _usernameChip(String? username) {
    if (username == null) return const SizedBox.shrink();
    final theme = FlutterFlowTheme.of(context);
    final selected = _model.nicknameTextController.text == username;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        safeSetState(() => _model.nicknameTextController.text = username);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.accent1 : theme.alternate,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? theme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          username,
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
              fontSize: _fsSub,
            color: selected ? theme.primary : theme.primaryText,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
      ),
    );
  }

  Widget _buildPrefsSection() {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(FFLocalizations.of(context).getText('otyd40i2')),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: FlutterFlowLanguageSelector(
            width: double.infinity,
            height: 50,
            backgroundColor: theme.surfaceMuted,
            borderColor: Colors.transparent,
            dropdownIconColor: theme.secondaryText,
            borderRadius: 14,
            textStyle: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              fontSize: _fsBody,
              color: theme.primaryText,
              letterSpacing: 0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
            hideFlags: true,
            flagSize: 24,
            flagTextGap: 8,
            currentLanguage: FFLocalizations.of(context).languageCode,
            languages: FFLocalizations.languages(),
            onChanged: (lang) => setAppLanguage(context, lang),
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: _model.countryselectorModel,
          updateCallback: () => safeSetState(() {}),
          child: CountryselectorWidget(textSize: 16),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final keyboardVisible = isWeb
        ? MediaQuery.viewInsetsOf(context).bottom > 0
        : _isKeyboardVisible;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // ── Scrollable content ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                    child: Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            FFLocalizations.of(context).getText('zte082q6'),
                            style: theme.headlineMedium.override(
                              fontFamily: theme.headlineMediumFamily,
              fontSize: _fsTitle,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              useGoogleFonts: !theme.headlineMediumIsCustom,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            FFLocalizations.of(context).getText('lf9tgr4o'),
                            style: theme.bodyMedium.override(
                              fontFamily: theme.bodyMediumFamily,
              fontSize: _fsBody,
                              color: theme.primaryText,
                              letterSpacing: 0,
                              useGoogleFonts: !theme.bodyMediumIsCustom,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Avatar
                          _sectionCard(_buildAvatarSection()),
                          const SizedBox(height: 12),

                          // Name
                          _sectionCard(_buildNameSection()),
                          const SizedBox(height: 12),

                          // Username
                          _sectionCard(_buildUsernameSection()),
                          const SizedBox(height: 12),

                          // Language + Country
                          _sectionCard(_buildPrefsSection()),
                        ],
                      ).animateOnPageLoad(
                          animationsMap['columnOnPageLoadAnimation']!),
                    ),
                  ),
                ),

                // ── Continue button (outside scroll) ──
                if (!keyboardVisible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: AppButton(
                      label: FFLocalizations.of(context).getText('spc42q3x'),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        if (_model.formKey.currentState == null ||
                            !_model.formKey.currentState!.validate()) return;
                        await UsersTable().update(
                          data: {
                            'first_name':
                                _model.firstNameTextController.text,
                            'last_name': _model.lastNameTextController.text,
                            'profile_image': _model.profilePicture,
                            'nickname': _model.nicknameTextController.text,
                            'onboarded': true,
                          },
                          matchingRows: (rows) =>
                              rows.eqOrNull('id', currentUserUid),
                        );
                        context.goNamed(TakeorUploadPageWidget.routeName);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
