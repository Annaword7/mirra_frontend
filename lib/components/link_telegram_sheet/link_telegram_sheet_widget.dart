import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

const _botName = '@Mirra_app_bot';

class _BotNameChip extends StatefulWidget {
  const _BotNameChip({required this.botName});
  final String botName;

  @override
  State<_BotNameChip> createState() => _BotNameChipState();
}

class _BotNameChipState extends State<_BotNameChip> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.botName));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.botName,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 18,
              color: _copied
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF555555),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for linking a Telegram account to the current app account.
/// The user pastes the code (or deep link) issued by the bot's /link command;
/// it is redeemed via the `link-telegram` edge function.
class LinkTelegramSheet extends StatefulWidget {
  const LinkTelegramSheet({super.key});

  @override
  State<LinkTelegramSheet> createState() => _LinkTelegramSheetState();
}

class _LinkTelegramSheetState extends State<LinkTelegramSheet> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    debugPrint('[link-tg] submit tapped; code="$code" '
        'jwt=${currentJwtToken.isNotEmpty ? "present(${currentJwtToken.length})" : "EMPTY"}');
    if (code.isEmpty || _submitting) {
      debugPrint('[link-tg] aborted early (empty=${code.isEmpty}, submitting=$_submitting)');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _submitting = true);

    debugPrint('[link-tg] calling link-telegram edge function...');
    final response = await LinkTelegramCall.call(
      token: currentJwtToken,
      code: code,
    );
    debugPrint('[link-tg] response status=${response.statusCode} '
        'succeeded=${response.succeeded} body=${response.jsonBody}');

    if (!mounted) return;
    setState(() => _submitting = false);

    final ok = response.succeeded && (LinkTelegramCall.ok(response.jsonBody) ?? false);
    debugPrint('[link-tg] parsed ok=$ok errCode=${LinkTelegramCall.errorCode(response.jsonBody)}');
    if (ok) {
      Navigator.of(context).pop();
      _toast(FFLocalizations.of(context).getText('lt_linked'));
      return;
    }

    final errCode = LinkTelegramCall.errorCode(response.jsonBody);
    _toast(_errorText(context, errCode));
  }

  String _errorText(BuildContext context, String? code) {
    switch (code) {
      case 'expired':
        return FFLocalizations.of(context).getText('lt_code_expired');
      case 'invalid_code':
        return FFLocalizations.of(context).getText('lt_invalid_code');
      default:
        return FFLocalizations.of(context).getText('lt_could_not_link');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            FFLocalizations.of(context).getText('cm_link_telegram'),
            style: theme.headlineMedium.override(
              fontFamily: theme.headlineMediumFamily,
              color: const Color(0xFF1A1A1A),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              useGoogleFonts: !theme.headlineMediumIsCustom,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FFLocalizations.of(context).getText('lt_instructions'),
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: const Color(0xFF1A1A1A),
              fontSize: 16,
              letterSpacing: 0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          const SizedBox(height: 12),
          _BotNameChip(botName: _botName),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_submitting,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: FFLocalizations.of(context).getText('lt_code_or_link'),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                disabledBackgroundColor: theme.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      FFLocalizations.of(context).getText('lt_link_btn'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
