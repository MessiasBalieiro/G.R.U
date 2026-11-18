import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/config/firebase_config.dart';

enum ProvedorSocial { google, apple, microsoft }

class SocialPerfil {
  const SocialPerfil(
      {required this.idToken, required this.email, required this.nome});
  final String idToken;
  final String email;
  final String nome;
}

class SocialAuthException implements Exception {
  const SocialAuthException(this.mensagem, {this.cancelado = false});
  final String mensagem;

  /// `true` quando a pessoa só fechou a janela de login (não é erro).
  final bool cancelado;
}

/// Faz o login com Google / Microsoft / Apple pelo Firebase Authentication
/// e devolve o token que o backend do G.R.U valida.
class SocialAuthService {
  Future<SocialPerfil> entrar(ProvedorSocial provedor) async {
    if (!FirebaseConfig.configurado) {
      throw const SocialAuthException(
        'O login social ainda não foi configurado. '
        'Use e-mail e senha por enquanto.',
      );
    }
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: FirebaseConfig.options);
    }

    final auth = FirebaseAuth.instance;
    final provider = _criarProvider(provedor);
    try {
      final cred = kIsWeb
          ? await auth.signInWithPopup(provider)
          : await auth.signInWithProvider(provider);
      final user = cred.user;
      final token = await user?.getIdToken();
      final email = user?.email ??
          (cred.additionalUserInfo?.profile?['email'] as String?);
      if (user == null || token == null || email == null || email.isEmpty) {
        throw const SocialAuthException(
            'Não conseguimos obter o e-mail dessa conta.');
      }
      final nome = (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : email.split('@').first;
      // O G.R.U usa a própria sessão; não mantemos a do Firebase.
      await auth.signOut();
      return SocialPerfil(idToken: token, email: email, nome: nome);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
        case 'user-cancelled':
          throw const SocialAuthException('', cancelado: true);
        case 'popup-blocked':
          throw const SocialAuthException(
              'O navegador bloqueou a janela de login. Libere pop-ups e tente de novo.');
        case 'unauthorized-domain':
          throw const SocialAuthException(
              'Este site não está autorizado no Firebase (Authorized domains).');
        case 'operation-not-allowed':
          throw const SocialAuthException(
              'Esse tipo de login não está ativado no Firebase.');
        case 'account-exists-with-different-credential':
          throw const SocialAuthException(
              'Já existe uma conta com esse e-mail usando outro método de login.');
        default:
          throw SocialAuthException(
              'Não foi possível entrar agora (${e.code}).');
      }
    }
  }

  AuthProvider _criarProvider(ProvedorSocial p) {
    switch (p) {
      case ProvedorSocial.google:
        return GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile')
          ..setCustomParameters({'prompt': 'select_account'});
      case ProvedorSocial.microsoft:
        return OAuthProvider('microsoft.com')
          ..addScope('email')
          ..addScope('profile')
          ..setCustomParameters({'prompt': 'select_account'});
      case ProvedorSocial.apple:
        return OAuthProvider('apple.com')
          ..addScope('email')
          ..addScope('name');
    }
  }
}
