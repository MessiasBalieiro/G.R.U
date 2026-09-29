/// Endereço da API do G.R.U (backend Node).
///
/// Defina na hora de rodar/gerar o app, sem mexer no código:
///   flutter run --dart-define=GRU_API_URL=http://192.168.0.10:3000
///
/// Padrão: `http://10.0.2.2:3000`, que é o "localhost do PC" visto de dentro
/// do EMULADOR Android. Num celular físico use o IP do PC na rede Wi-Fi
/// (o celular e o PC precisam estar na mesma rede).
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'GRU_API_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
