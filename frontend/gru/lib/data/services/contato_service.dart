import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';

/// Envia as perguntas do formulário da Home por e-mail para a equipe,
/// usando o FormSubmit (não precisa de backend próprio).
class ContatoService {
  const ContatoService();

  /// Retorna `true` se o envio foi aceito.
  Future<bool> enviar({required String mensagem, String? emailRetorno}) async {
    try {
      final resposta = await http
          .post(
            Uri.parse(ApiConfig.contatoEndpoint),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': 'Visitante do site G.R.U',
              if (emailRetorno != null && emailRetorno.isNotEmpty)
                'email': emailRetorno,
              'message': mensagem,
              '_subject': 'Nova pergunta pelo site G.R.U',
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        return false;
      }
      final dados = jsonDecode(resposta.body);
      final ok = dados is Map ? dados['success'] : null;
      return ok == true || ok == 'true';
    } catch (_) {
      return false;
    }
  }
}
