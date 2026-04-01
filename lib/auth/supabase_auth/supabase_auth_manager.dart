import 'dart:async';

import 'package:flutter/material.dart';
import '/auth/auth_manager.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'email_auth.dart';

import 'apple_auth.dart';
import 'supabase_user_provider.dart';

export '/auth/base_auth_user_provider.dart';

class SupabaseAuthManager extends AuthManager
    with EmailSignInManager, AppleSignInManager, AnonymousSignInManager {
  @override
  Future signOut() {
    return SupaFlow.client.auth.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn) {
        print('Error: delete user attempted with no logged in user!');
        return;
      }
      await currentUser?.delete();
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email change confirmation email sent')),
    );
  }

  @override
  Future updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update password attempted with no logged in user!');
        return;
      }
      await currentUser?.updatePassword(newPassword);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password updated successfully')),
    );
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  }) async {
    try {
      await SupaFlow.client.auth
          .resetPasswordForEmail(email, redirectTo: redirectTo);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return null;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent')),
    );
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    // If the current session is anonymous, capture the UID so we can
    // reassign its scans to the real account after sign-in.
    final anonUid = _anonUidIfAnonymous();

    final result = await _signInOrCreateAccount(
      context,
      () => emailSignInFunc(email, password),
    );

    if (result != null && anonUid != null) {
      await _claimAnonScans(anonUid);
    }

    return result;
  }

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    // If already anonymous, link the email to the existing anonymous account
    // instead of creating a new one — the UUID stays the same, so all scans
    // are automatically preserved.
    if (_isCurrentUserAnonymous()) {
      return _linkEmailToAnonymousAccount(context, email, password);
    }
    return _signInOrCreateAccount(
      context,
      () => emailCreateAccountFunc(email, password),
    );
  }

  /// Returns the current user's UID only when the user is anonymous.
  String? _anonUidIfAnonymous() {
    if (!_isCurrentUserAnonymous()) return null;
    return currentUser?.uid;
  }

  bool _isCurrentUserAnonymous() =>
      (currentUser as MiRRADevSupabaseUser?)?.isAnonymous ?? false;

  /// Converts the anonymous account to a permanent email/password account.
  /// The user ID does NOT change, so all existing scans are preserved.
  Future<BaseAuthUser?> _linkEmailToAnonymousAccount(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await SupaFlow.client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
      final user = response.user;
      final authUser = user == null ? null : MiRRADevSupabaseUser(user);
      if (authUser != null) {
        currentUser = authUser;
        AppStateNotifier.instance.update(authUser);
      }
      return authUser;
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return null;
    }
  }

  /// Calls the Supabase RPC that reassigns scans owned by [anonUid] to the
  /// currently authenticated user. Non-fatal if the RPC doesn't exist yet.
  Future<void> _claimAnonScans(String anonUid) async {
    try {
      await SupaFlow.client
          .rpc('claim_anonymous_scans', params: {'anon_uid': anonUid});
    } catch (_) {
      // Migration is best-effort; never block the sign-in flow.
    }
  }

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) =>
      _signInOrCreateAccount(context, appleSignInFunc);

  @override
  Future<BaseAuthUser?> signInAnonymously(BuildContext context) async {
    try {
      final response = await SupaFlow.client.auth.signInAnonymously();
      final user = response.user;
      final authUser = user == null ? null : MiRRADevSupabaseUser(user);
      if (authUser != null) {
        currentUser = authUser;
        AppStateNotifier.instance.update(authUser);
      }
      return authUser;
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      return null;
    }
  }

  /// Tries to sign in or create an account using Supabase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<User?> Function() signInFunc,
  ) async {
    try {
      final user = await signInFunc();
      final authUser = user == null ? null : MiRRADevSupabaseUser(user);

      // Update currentUser here in case user info needs to be used immediately
      // after a user is signed in. This should be handled by the user stream,
      // but adding here too in case of a race condition where the user stream
      // doesn't assign the currentUser in time.
      if (authUser != null) {
        currentUser = authUser;
        AppStateNotifier.instance.update(authUser);
      }
      return authUser;
    } on AuthException catch (e) {
      final errorMsg = e.message.contains('User already registered')
          ? 'Error: The email is already in use by a different account'
          : 'Error: ${e.message}';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      return null;
    }
  }
}
