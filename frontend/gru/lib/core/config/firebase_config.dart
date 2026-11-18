import 'package:firebase_core/firebase_core.dart';

/// Configuração do Firebase usada SÓ para o login social
/// (Google / Microsoft / Apple).
///
/// Como preencher (uma vez só):
///  1. console.firebase.google.com → criar projeto → "Adicionar app" → Web.
///  2. Copie os valores do `firebaseConfig` para as constantes abaixo
///     (essas chaves do Firebase Web não são secretas).
///  3. Authentication → Sign-in method → ative Google e Microsoft (e Apple, se
///     tiver conta Apple Developer paga).
///  4. Authentication → Settings → Authorized domains → adicione
///     `messiasbalieiro.github.io`.
///
/// Enquanto estiver vazio, os botões sociais avisam que ainda não foram
/// configurados (o resto do site funciona normalmente).
class FirebaseConfig {
  FirebaseConfig._();

  static const String apiKey =
      String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String authDomain =
      String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: '');
  static const String projectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  static const String appId =
      String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const String messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');

  static bool get configurado =>
      apiKey.isNotEmpty &&
      authDomain.isNotEmpty &&
      projectId.isNotEmpty &&
      appId.isNotEmpty;

  static FirebaseOptions get options => const FirebaseOptions(
        apiKey: apiKey,
        authDomain: authDomain,
        projectId: projectId,
        appId: appId,
        messagingSenderId: messagingSenderId,
      );
}
