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
    defaultValue: 'http://localhost:3000',
  );
}
