/// Textos estáticos usados nas telas.
///
/// Mantidos centralizados para facilitar troca de copy no futuro
/// (e uma eventual internacionalização, se o projeto crescer).
class AppStrings {
  AppStrings._();

  static const appName = 'G.R.U';
  static const appFullName = 'Gerenciador de Resíduos Urbanos';

  // Home - Quem Somos
  static const problemaTitulo = 'Problema';
  static const problemaTexto =
      'Grande parte dos resíduos urbanos é descartada de forma incorreta, '
      'sobrecarregando aterros e poluindo rios, ruas e áreas verdes das '
      'nossas cidades.';

  static const solucaoTitulo = 'Solução';
  static const solucaoTexto =
      'Lixeiras inteligentes conectadas monitoram o volume de resíduos em '
      'tempo real, otimizando as rotas de coleta e reduzindo o desperdício.';

  static const gruTitulo = 'G.R.U';
  static const gruTexto =
      'Uma plataforma que une hardware, software e comunidade para tornar '
      'a gestão de resíduos urbanos mais eficiente, transparente e acessível.';

  // Home - Lixeira Inteligente
  static const lixeiraInteligenteTitulo = 'Lixeira Inteligente';
  static const lixeiraInteligenteTexto =
      'Sensores identificam o nível de ocupação e o tipo de resíduo '
      'descartado, enviando esses dados direto para o painel do G.R.U.';

  // FAQ
  static const faqTitulo = 'Alguma pergunta para o G.R.U?';
  static const faqSubtitulo = 'Envie sua pergunta ou feedback para nós!';
  static const faqRespondidasTitulo = 'Dúvidas já respondidas';
  static const List<({String pergunta, String resposta})> faqItens = [
    (
      pergunta: 'Como funciona a lixeira inteligente?',
      resposta:
          'Sensores instalados na lixeira medem o nível de ocupação e '
          'identificam o tipo de resíduo descartado. Esses dados são enviados '
          'automaticamente para o painel do G.R.U, onde você acompanha tudo '
          'em tempo real.',
    ),
    (
      pergunta: 'Quais cidades já usam o G.R.U?',
      resposta:
          'O G.R.U ainda está em desenvolvimento e em fase de testes, então '
          'não temos cidades parceiras por enquanto. Se quiser ser uma das '
          'primeiras, é só nos enviar uma mensagem pelo campo acima!',
    ),
    (
      pergunta: 'Como minha instituição pode participar?',
      resposta:
          'Crie uma conta na tela de Cadastro informando o nome da sua '
          'instituição. Depois, na Área de Trabalho, você cadastra suas '
          'lixeiras e coletores e acompanha tudo pelo painel.',
    ),
  ];
}
