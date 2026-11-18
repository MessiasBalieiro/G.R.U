/// Endereço da API do G.R.U (backend Node).
///
/// Defina na hora de rodar/gerar o app, sem mexer no código:
///   flutter run -d chrome --dart-define=GRU_API_URL=http://localhost:3000
///
/// Padrão: `http://localhost:3000` (backend rodando na mesma máquina do
/// navegador). Em produção, passe o endereço público da API.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'GRU_API_URL',
    defaultValue: 'https://backend-gru.vercel.app',
  );

  /// E-mail da equipe que recebe as perguntas do formulário da Home.
  static const String contatoEmail = 'gru.equipe.atendimento@gmail.com';

  /// Serviço gratuito (FormSubmit) que encaminha o formulário por e-mail,
  /// sem precisar de backend. Exige confirmar o e-mail uma única vez.
  static const String contatoEndpoint =
      'https://formsubmit.co/ajax/$contatoEmail';

  /// Link do APK Android (asset `gru.apk` da última Release do GitHub).
  /// Pode ser trocado na hora do build:
  ///   --dart-define=GRU_APK_URL=https://seu-link/gru.apk
  static const String apkUrl = String.fromEnvironment(
    'GRU_APK_URL',
    defaultValue:
        'https://github.com/MessiasBalieiro/G.R.U/releases/latest/download/gru.apk',
  );
}
